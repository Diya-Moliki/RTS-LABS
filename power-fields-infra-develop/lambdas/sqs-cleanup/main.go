package main

import (
	"context"
	"flag"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	awsSession "github.com/aws/aws-sdk-go/aws/session"
	awsSns "github.com/aws/aws-sdk-go/service/sns"
	awsSqs "github.com/aws/aws-sdk-go/service/sqs"
	"github.com/pkg/errors"
	"log"
	"os"
	"strconv"
	"strings"
)

const version = "1.0.1"

type (
	// SQS subscription of SNS topic
	subscription struct {
		arn      string
		queueArn string
	}

	// SNS topic with sqs subscriptions
	snsTopic struct {
		subscriptions []subscription
		arn           string
		svc           *awsSns.SNS
	}

	// SQS Queue object
	queue struct {
		url          string
		name         string
		messageCount int
		arn          string
	}

	// SQS queue list for SNS topic
	topicQueues struct {
		queues []queue
		svc    *awsSqs.SQS
	}
)

// dryRun global to disable steps
var dryRun = false

func main() {

	fmt.Printf("\nSQS Cleanup %s\n", version)

	awsProfile := flag.String("profile", "", "AWS profile to use")
	awsRegion := flag.String("region", env("AWS_REGION", "us-east-1"), "AWS region to use")
	maxMessages := flag.Int("max", envInt("MAX_MESSAGES", 10), "Queue name prefix to clean up")
	local := flag.Bool("local", false, "Run locally instead of on lambda")
	flag.BoolVar(&dryRun, "dry-run", false, "Dry run steps without actually deleting")

	flag.Parse()

	mainFunc := func(ctx context.Context, topicNames []string) {
		sqsCleanup(ctx, awsProfile, awsRegion, topicNames, maxMessages)
	}

	if *local {
		fmt.Println("Running from local")
		mainFunc(context.Background(), topicsFromArgs())
	} else {
		fmt.Println("Running from lambda")
		lambda.Start(mainFunc)
	}

}

func topicsFromArgs() []string {
	if len(flag.Args()) == 0 {
		log.Fatal("Topic list required as argument")
	}
	list := flag.Args()[0]
	list = strings.Trim(list, "[]")
	list = strings.ReplaceAll(list, " ", "")
	return strings.Split(list, ",")
}

func sqsCleanup(ctx context.Context, awsProfile, awsRegion *string, topicNames []string, maxMessages *int) {
	fmt.Printf("Topics: %v\n", topicNames)

	// configure AWS connection
	conf := aws.Config{
		Region: awsRegion,
	}

	if *awsProfile != "" {
		conf.Credentials = credentials.NewSharedCredentials("", *awsProfile)
	}

	fmt.Println("\nConnecting to AWS...")
	sess := awsSession.Must(awsSession.NewSession(&conf))

	for _, topicName := range topicNames {

		fmt.Printf("Getting SNS topic information for %s\n", topicName)
		topic, err := getTopic(ctx, topicName, awsSns.New(sess))
		if err != nil {
			log.Fatal(err)
		}

		fmt.Println("Getting SQS queue information...")
		queues, err := getTopicQueues(ctx, topicName, awsSqs.New(sess))
		if err != nil {
			log.Fatal(err)
		}

		fmt.Print("\nMatching queues: \n")
		for _, q := range queues.queues {
			fmt.Printf("%s: %d\n", q.name, q.messageCount)
		}

		// remove any old queues
		if err = queues.removeOldQueues(ctx, topic, *maxMessages); err != nil {
			log.Fatal(err)
		}
	}
}

// snsTopic functions

// getTopic populate snsTopic object for given topic name
func getTopic(ctx context.Context, topicName string, sns *awsSns.SNS) (*snsTopic, error) {

	topicResult, err := sns.CreateTopicWithContext(ctx, &awsSns.CreateTopicInput{
		Name: &topicName,
	})
	if err != nil || topicResult.TopicArn == nil {
		return nil, errors.Wrap(err, "problem getting SNS topic")
	}

	topic := &snsTopic{
		svc: sns,
		arn: *topicResult.TopicArn,
	}

	return topic, topic.populateSubscriptions(ctx, nil)
}

// populateSubscriptions creates the array of subscriptions for the sns topic
func (t *snsTopic) populateSubscriptions(ctx context.Context, nextToken *string) error {

	if nextToken == nil {
		t.subscriptions = []subscription{}
	}

	result, err := t.svc.ListSubscriptionsByTopicWithContext(ctx, &awsSns.ListSubscriptionsByTopicInput{
		NextToken: nextToken,
		TopicArn:  &t.arn,
	})
	if err != nil {
		return err
	}

	for _, sub := range result.Subscriptions {
		if empty(sub.SubscriptionArn) {
			fmt.Println("nil subscription arn encountered")
		} else if *sub.Protocol == "sqs" {
			t.subscriptions = append(t.subscriptions, subscription{
				arn:      *sub.SubscriptionArn,
				queueArn: *sub.Endpoint,
			})
		}
	}

	if !empty(result.NextToken) {
		return t.populateSubscriptions(ctx, result.NextToken)
	}
	return nil
}

// unsubscribe queue from SNS topic
func (t *snsTopic) unsubscribe(ctx context.Context, q queue) error {

	sub := t.findSubscription(q.arn)
	if sub == nil {
		return fmt.Errorf("no subscription found for queue %s", q.url)
	}

	if dryRun {
		fmt.Printf("DRY: Unsubscribe %s with arn %s\n", q.name, sub.arn)
	} else {
		_, err := t.svc.UnsubscribeWithContext(ctx, &awsSns.UnsubscribeInput{
			SubscriptionArn: &sub.arn,
		})
		if err != nil {
			return errors.Wrapf(err, "error unsubscribing queue %s", q.url)
		}
	}
	return nil
}

// findSubscription in object by arn
func (t *snsTopic) findSubscription(arn string) *subscription {
	for _, sub := range t.subscriptions {
		if sub.queueArn == arn {
			return &sub
		}
	}
	return nil
}

// topicQueues functions

// getTopicQueues populate topicQueues object for given topic name
func getTopicQueues(ctx context.Context, topicName string, svc *awsSqs.SQS) (*topicQueues, error) {

	sqs := &topicQueues{
		svc: svc,
	}

	queueList, err := svc.ListQueuesWithContext(ctx, &awsSqs.ListQueuesInput{
		QueueNamePrefix: &topicName,
	})
	if err != nil || queueList == nil {
		return nil, errors.Wrap(err, "problem getting queue list")
	}

	for _, url := range queueList.QueueUrls {
		if empty(url) {
			log.Println("received null queue url")
		} else {

			name := (*url)[strings.Index(*url, topicName):]

			attributes, err := svc.GetQueueAttributesWithContext(ctx, &awsSqs.GetQueueAttributesInput{
				QueueUrl:       url,
				AttributeNames: []*string{&numberOfMessagesAttr, &queueArnAttr},
			})
			if err != nil || attributes == nil {
				return nil, errors.Wrap(err, "problem getting queue attributes")
			}

			numMessagesStr, ok := attributes.Attributes[numberOfMessagesAttr]
			if !ok {
				return nil, errors.Wrapf(err, "%s did not have a number of messages", *url)
			}

			messageCount, err := strconv.Atoi(*numMessagesStr)

			arn := attributes.Attributes[queueArnAttr]
			if empty(arn) {
				return nil, fmt.Errorf("unable to get arn of queue %s", *url)
			}

			sqs.queues = append(sqs.queues, queue{
				url:          *url,
				name:         name,
				messageCount: messageCount,
				arn:          *arn,
			})

		}
	}

	return sqs, nil
}

// removeOldQueues Remove queues with more messages than given
func (s *topicQueues) removeOldQueues(ctx context.Context, topic *snsTopic, maxMessages int) error {

	fmt.Printf("\nRemoving all queues with more than %d messages...\n", maxMessages)

	var toRemove []queue

	for _, q := range s.queues {
		if q.messageCount > maxMessages {
			toRemove = append(toRemove, q)
		}
	}

	if len(toRemove) == 0 {
		fmt.Printf("no queues to remove\n")
	} else {
		fmt.Printf("removing %d queues\n", len(toRemove))
		for _, q := range toRemove {
			if err := topic.unsubscribe(ctx, q); err != nil {
				log.Println(err)
			}
			if err := s.deleteQueue(ctx, q); err != nil {
				log.Println(err)
			}
		}
	}
	return nil
}

// deleteQueue from SQS and object
func (s *topicQueues) deleteQueue(ctx context.Context, q queue) error {

	if dryRun {
		fmt.Printf("DRY: Deleting %s\n", q.name)
	} else {
		_, err := s.svc.DeleteQueueWithContext(ctx, &awsSqs.DeleteQueueInput{
			QueueUrl: &q.url,
		})
		if err != nil {
			return errors.Wrapf(err, "error deleting queue %s", q.name)
		}
	}

	queueIndex := 0
	for i, sliceQueue := range s.queues {
		if sliceQueue.arn == q.arn {
			queueIndex = i
			break
		}
	}

	s.queues = append(s.queues[:queueIndex], s.queues[queueIndex+1:]...)

	return nil
}

// generic helper functions

func envInt(name string, defaultValue int) int {

	returnVal := defaultValue
	if value, exists := os.LookupEnv(name); exists {
		if intValue, err := strconv.Atoi(value); err != nil {
			fmt.Printf("error parsing env %s for int value %s\n", name, value)
		} else {
			returnVal = int(intValue)
		}
	}
	return returnVal
}

func env(name, defaultValue string) string {

	if value, exists := os.LookupEnv(name); exists {
		return value
	}
	return defaultValue
}

func empty(str *string) bool {
	return str == nil || *str == ""
}

var numberOfMessagesAttr = awsSqs.QueueAttributeNameApproximateNumberOfMessages
var queueArnAttr = awsSqs.QueueAttributeNameQueueArn

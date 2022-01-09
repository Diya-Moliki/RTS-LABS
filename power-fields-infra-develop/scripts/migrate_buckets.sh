#!/bin/bash
# this script has been developed for ppp-1418
# 1. Run `ENVIRONMENT=dev TENANT=sat scripts/migrate_buckets.sh` from the root folder
# 2. apply new tf code in `buckets`, `cloudfront` and `ecs_service` folders
STATE_TO_MOVE=(
  aws_s3_bucket.app_config
  aws_s3_bucket.app_document_attachments
  aws_s3_bucket_policy.app_document_attachments
  aws_s3_bucket_policy.app_config
)
# todo maybe add more to above
cd terraform/live/nonprod/app/$ENVIRONMENT/$TENANT # other client
# cp -r ../../dev/rts/buckets . # for other clients
cd buckets
terragrunt init
cd ../ecs_service
rm -f ../buckets/source.tfstate
terragrunt state pull >../buckets/source.tfstate

cd ../buckets
rm -f dest.tfstate
terragrunt state pull >dest.tfstate

#do a backup just in case
cp source.tfstate source.tfstate.bak
cp dest.tfstate dest.tfstate.bak

for s in ${STATE_TO_MOVE[@]}; do
  # note - use terraform instead of terragrunt
  terraform state mv -state=source.tfstate -state-out=dest.tfstate $s $s
  if ! terraform state list -state=dest.tfstate $s; then
    #if the source doesn't have the resource it will exist with status 1 and print error "Error: Unknown resource"
    echo "Destination doesn't have ${s}"
    exit 1
  fi

  if terraform state list -state=source.tfstate $s; then
    #if the state doesn't have the resource it will exist with status 1 and print error "Error: Unknown resource"
    echo "Source still has ${s}"
    exit 1
  fi
done

echo "SUCCESS"

terragrunt state push dest.tfstate
cd ../ecs_service
##apparently tg can't get the state from a parent folder so have to copy it over
cp ../buckets/source.tfstate source.tfstate
terragrunt state push source.tfstate

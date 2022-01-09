#ConcurrencyLT
import datetime
import logging
import os
import time
from locust import TaskSet, task, HttpUser, User, user, between
import copy
import random
import json
import pdb


ts = time.time()
print(ts)

st = datetime.datetime.fromtimestamp(ts).strftime("%m.%d.%H.%M.%S")
print(st)

class UserBehavior(HttpUser):
    log = logging.getLogger("UserBehavior")
    #task_set = UserBehavior
    wait_time = between(1, 5)
    # host = "https://dom.api.qa.powerfields-dev.io"
    host = "https://rts.api.perf.powerfields-dev.io/"

    def __init__(self, parent):
        super(UserBehavior, self).__init__(parent)
        self.token = ""
        self.headers = {}

    def on_start(self):
        """Login on Start"""
        self.token = self.login()
        self.client.headers = {"Authorization": "Bearer " + self.token}
        self.log.info("Start complete with token %s", self.token)

    def on_stop(self):
        """on stop this is called when taskset is stopped"""
        self.logout()

    def login(self):
        payload = {"username": "clientadmin@rtslabs.com", "password": "Password!23", "recaptchaToken": None}
        headers = {"Content-Type": "application/json"}
        response = self.client.post("api/authenticate", json=payload, headers=headers, catch_response=True)
        return response.json()["id_token"]


    def logout(self):
        self.client.get("")
        # Log out does not exist - go to base URL

    @task(1)
    def get_documents(self):
        # Basic doc navigation
        self.client.get("api/documents/", headers=self.headers, catch_response=False, name='get_documents')

    @task(5)
    def post_documents(self):
        # Post Documents 3751=PJB 3752=Safety 
        # {"clientGroupId":1405,"formId":3901,"isRehuddle":false,"ownerId":15251,"submissionDate":"2020-07-15T19:43:32Z"}
        #Payload passes in Postman

        payload = {"clientGroupId": 1405, "formId":3901, "ownerId":15251, "submissionDate":"2020-07-26T19:33:56.296Z", "isRehuddle":False}
        postHeaders = copy.deepcopy(self.headers)
        #To avoid corrupting self.headers we deep copy then add other header fields we need
        postHeaders["Accepts"] = "application/json"
        postHeaders["Content-Type"] = "application/json"
        #print(postHeaders)
        self.client.post("api/documents/", data=json.dumps(payload), headers=postHeaders, catch_response=False)
        #set the above self.client equal to R and then following text
        # print("See message below --->")
        # print(json.dumps(r.json()))
        # print("See message abouve --->")    

    
    @task(1)
    def get_document_stats(self):
        #Get all Document type stats
        self.client.get("api/reports/forms", headers=self.headers, catch_response=False, name='get_document_stats')

    @task(1)
    def get_questions(self):
        #Get Questions Endpoint
        self.client.get("api/questions", headers=self.headers,catch_response=False, name='get_questions')

    @task(1)
    def get_defenses(self):
        #Get Defenses Endpoint
        self.client.get("api/resources", headers=self.headers, catch_response=False, name='get_defenses')

    @task(1)
    def get_role_mappers(self):
        #get role mappers
        self.client.get("api/role-mappers", headers=self.headers, catch_response=False, name='get_role_mappers')

    @task(1)
    def get_validations(self):
        #get validations
        self.client.get("api/validations", headers=self.headers, catch_response=False, name='get_validations')

    @task(0)
    def post_validations(self):
        #@TODO Fix posting its all trash
        self.client.post("api/validations", headers=self.headers, catch_response=False, name='post_validations')

    @task(1)
    def get_users(self):
        #get all users
        self.client.get("api/users", headers=self.headers, catch_response=False, name='get_users')

    @task(1)
    def get_users_FE(self):
        #Get whole page
        self.client.get('#people/users', name='get_users_FE')
        self.client.get('api/application-configs/dashboardSidebar', name='get_users_FE')
        self.client.options('api/application-configs/dashboardSidebar', name='get_users_FE')
        self.client.get('api/application-configs/logoConfigs', name='get_users_FE')
        self.client.options('api/application-configs/logoConfigs', name='get_users_FE')
        self.client.get('api/application-configs/mainNavigation', name='get_users_FE')
        self.client.options('api/application-configs/mainNavigation', name='get_users_FE')
        self.client.options('api/participants/aggregate-summary?', name='get_users_FE')
        self.client.get('api/participants/aggregate-summary?', name='get_users_FE')
        self.client.get('api/participants/summary?page=0&size=10&sort=firstName%2Casc', name='get_users_FE')
        self.client.options('api/participants/summary?page=0&size=10&sort=firstName%2Casc', name='get_users_FE')
        #people/users loads

    @task(1)
    def get_users_specific(self):
        self.client.get('#people/users', name='get_users_FE')
        self.client.get('api/application-configs/dashboardSidebar', name='get_users_FE')
        self.client.options('api/application-configs/dashboardSidebar', name='get_users_FE')
        self.client.get('api/application-configs/logoConfigs', name='get_users_FE')
        self.client.options('api/application-configs/logoConfigs', name='get_users_FE')
        self.client.get('api/application-configs/mainNavigation', name='get_users_FE')
        self.client.options('api/application-configs/mainNavigation', name='get_users_FE')
        self.client.options('api/participants/aggregate-summary?', name='get_users_FE')
        self.client.get('api/participants/aggregate-summary?', name='get_users_FE')
        self.client.get('api/participants/summary?page=0&size=10&sort=firstName%2Casc', name='get_users_FE')
        self.client.options('api/participants/summary?page=0&size=10&sort=firstName%2Casc', name='get_users_FE')
        #get specific user 1
        self.client.get('api/reports/participants/2120/submissions?&participantId=2120', name='get_specific_user')
        self.client.options('api/reports/participants/2120/submissions?&participantId=2120', name='get_specific_user')
        #get specific user 2
        self.client.get('api/reports/participants/2113/submissions?&participantId=2113', name='get_specific_user_2')
        self.client.options('api/reports/participants/2113/submissions?&participantId=2113', name='get_specific_user_2')



    @task(1)
    def get_work_addresses(self):
        #get all work addresses - API Test
        self.client.get("api/work-location-addresses", headers=self.headers, catch_response=False, name='get_work_addresses')

    @task(1)
    def oe_documents(self):
        #get oe documents
        #self.client.post('/api/document-oe/find', name='Document OE')
        self.client.get('api/resources/authors?size=200', name='Resource Page Load')
        self.client.options('api/resources/authors?size=200', name='Resource Page Load')
        self.client.get('api/application-configs/clientConfig', name='Resource Page Load')
        self.client.options('api/application-configs/clientConfig', name='Resource Page Load')
        self.client.get('api/application-configs/dashboardSidebar', name='Resource Page Load')
        self.client.options('api/application-configs/logoConfigs', name='Resource Page Load')
        self.client.get('api/application-configs/logoConfigs', name='Resource Page Load')
        self.client.options('api/application-configs/mainNavigation', name='Resource Page Load')
        self.client.get('api/application-configs/mainNavigation', name='Resource Page Load')
        self.client.get('api/resources?page=0&size=10&sort=lastModifiedDate%2Cdesc', name='Resource Page Load')
        self.client.options('api/resources?page=0&size=10&sort=lastModifiedDate%2Cdesc', name='Resource Page Specific')
        self.client.get('api/resources?page=0&size=10&sort=lastModifiedDate%2Cdesc', name='Resource Page Specific')
        #page is loaded

        self.client.options('api/document-oe/find', name='Document OE Specific')
        #doc1
        self.client.get('api/operational-experiences/22901', name='Document OE Specific')
        #doc2
        self.client.get('api/operational-experiences/14550', name='Document OE Specific')

    @task(1)
    #/api/builder/forms
    def get_builder_forms(self):
        self.client.get("api/builder/forms", headers=self.headers, catch_response=False, name='get builder forms')
        # with self.client.get("/api/builder/forms", headers=self.headers, catch_response=True) as response:
        #     if response.content != '209853':
        #         raise response.failure("Custom Message")
            
    @task(1)
    def get_work_order(self):
        self.client.get("api/work-locations", headers=self.headers, catch_response=False, name='get work orders')

    

    @task(1)
    def client_group_full_page(self):
        self.client.options('api/application-configs/logoConfigs',name='Client Group Options')
        self.client.options('api/application-configs/clientConfig',name='Client Group Options')
        self.client.options('api/application-configs/mainNavigation',name='Client Group Options')
        self.client.options('api/application-configs/dashboardSidebar',name='Client Group Options')
        self.client.get('api/client-groups/all-stats?page=0&size=10&sort=groupName%2Casc', name='Get Client Group All')
        self.client.options('api/client-groups/all-stats?page=0&size=10&sort=groupName%2Casc', name='Client Group Options')
        self.client.options('api/application-configs/dashboardSidebar', name='Client Group Options')

    @task(1)
    def client_group_specific(self):
        self.client.options('api/application-configs/logoConfigs',name='Client Group Options')
        self.client.options('api/application-configs/clientConfig',name='Client Group Options')
        self.client.options('api/application-configs/mainNavigation',name='Client Group Options')
        self.client.options('api/application-configs/dashboardSidebar',name='Client Group Options')
        self.client.options('api/participants/summary?page=0&clientGroupId=33858&size=10&sort=firstName%2Casc', name='Specific Client Group')
        self.client.options('api/participants/aggregate-summary?&clientGroupId=33858', name='Client Group Options')

    @task(1)
    def help_desk(self):
        self.client.get('#help-desk', headers=self.headers, name='help desk initial load')
        self.client.options('api/application-config/presigned-url/viewable', name='help desk load')
        self.client.options('api/application-configs/logoConfigs', name='help desk load')
        self.client.options('api/application-configs/clientConfig', name='help desk load')
        self.client.options('api/application-configs/mainNavigation', name='help desk load')
        self.client.options('api/application-configs/dashboardSidebar', name='help desk load')
        self.client.get('api/application-configs/logoConfigs', name='help desk load')
        self.client.get('api/application-configs/clientConfig', name='help desk load')
        self.client.get('api/application-configs/mainNavigation', name='help desk load')
        self.client.get('api/application-configs/dashboardSidebar', name='help desk load')
        self.client.options('api/application-config/presigned-url/viewable', name='help desk load')
        self.client.options('api/application-config/presigned-url/viewable', name='help desk load')
        self.client.options('api/application-config/presigned-url/viewable', name='help desk load')
        #For some reason this is called 3 times every single time, so ive added it 3 times  
    

    @task(1)
    def documents_page_load(self):
        #User navigates to Documents, moves around sorting submission date etc and then leaves
        #clicking on nothing else. 
        self.client.get('#documents', headers=self.headers, name='documents page load start')
        self.client.get('api/work-locations/2011/participants', name='documents page api calls'),
        self.client.options('api/work-locations/2011/participants', name='documents page api calls'),
        self.client.get('api/documents?sort=submissionDate,desc', name='documents page api calls'),
        self.client.options('api/documents?sort=submissionDate,desc', name='documents api calls'),
        self.client.get('api/forms/all', name='documents page api calls'),
        self.client.options('api/forms/all', name='documents page api calls'),
        self.client.get('api/forms/all?summary=true', name='documents page api calls'),
        self.client.options('api/forms/all?summary=true', name='documents page api calls'),        
        #End of Initial Load of Page

    @task(1)
    def documents_page_search(self):
        #User navigates to Documents, moves around sorting submission date etc and then leaves
        #clicking on nothing else. 
        self.client.get('#documents', headers=self.headers, name='documents page load start')
        self.client.get('api/work-locations/2011/participants', name='documents page api calls')
        self.client.options('api/work-locations/2011/participants', name='documents page api calls')
        self.client.get('api/documents?sort=submissionDate,desc', name='documents page api calls')
        self.client.options('api/documents?sort=submissionDate,desc', name='documents api calls')
        self.client.get('api/forms/all', name='documents page api calls')
        self.client.options('api/forms/all', name='documents page api calls')
        self.client.get('api/forms/all?summary=true', name='documents page api calls')
        self.client.options('api/forms/all?summary=true', name='documents page api calls')        
        #End of Initial Load of Page

        #Search by submission date ONLY 
        self.client.get('api/documents?sort=submissionDate,desc&minSubmissionDate=2020-05-24T04:00:00.000Z&maxSubmissionDate=2020-06-08T21:33:50.142Z', name='document search by date'),
        #Search by submission Date and PJB
        self.client.get('api/documents?sort=submissionDate,desc&minSubmissionDate=2020-05-24T04:00:00.000Z&maxSubmissionDate=2020-06-08T21:34:54.099Z&formTypeIds=2901', name='document search PJB'),
        self.client.options('api/documents?sort=submissionDate,desc&minSubmissionDate=2020-05-24T04:00:00.000Z&maxSubmissionDate=2020-06-08T21:34:54.099Z&formTypeIds=2901', name='document search PJB'),
        #Search by Submission Date and Safety Observation
        self.client.options('api/documents?sort=submissionDate,desc&minSubmissionDate=2020-05-24T04:00:00.000Z&maxSubmissionDate=2020-06-08T21:37:11.749Z&formTypeIds=2902', name='document search Safety'),
        self.client.get('api/documents?sort=submissionDate,desc&minSubmissionDate=2020-05-24T04:00:00.000Z&maxSubmissionDate=2020-06-08T21:37:11.749Z&formTypeIds=2902', name='document search Safety')
        

    @task(1)
    def documents_specific(self):
        #user navigates to documents, and selects a document, doing all API calls along the way
        self.client.get('#documents', headers=self.headers, name='documents page load start')
        self.client.get('api/work-locations/2011/participants', name='documents page api calls'),
        self.client.options('api/work-locations/2011/participants', name='documents page api calls'),
        self.client.get('api/documents?sort=submissionDate,desc', name='documents page api calls'),
        self.client.options('api/documents?sort=submissionDate,desc', name='documents api calls'),
        self.client.get('api/forms/all', name='documents page api calls'),
        self.client.options('api/forms/all', name='documents page api calls'),
        self.client.get('api/forms/all?summary=true', name='documents page api calls'),
        self.client.options('api/forms/all?summary=true', name='documents page api calls'),
        # self.client.options('api/documents/62051', name='get specific document') 
        # self.client.get('api/documents/62051', name='get specific document')#change the 36515 to a document in the DB
        # self.client.options('api/documents/61554', name='get specific document')
        # self.client.get('api/documents/61554', name='get specific document')#change the 61554 to a document in the DB


    @task(1)
    def report_page_full(self):
        self.client.get('#reports/', name='reports page initial navigation')
        self.client.options('api/application-configs/logoConfigs' ,name='reports page load')
        self.client.options('api/application-configs/clientConfig',name='reports page load')
        self.client.options('api/application-configs/mainNavigation',name='reports page load')
        self.client.options('api/application-configs/dashboardSidebar',name='reports page load')
        self.client.options('api/forms/all', name='reports page load')
        self.client.options('api/reports/forms?&onlySubordinates=false', name='reports page load')
        self.client.options('api/forms?&sort=name,asc&size=10&onlySubordinates=false', name='reports page load')
        self.client.options('api/client-groups?sort=name,asc&size=200', name='reports page load')
        self.client.get('api/application-configs/clientConfig', name='reports page load')
        self.client.get('api/application-configs/logoConfigs', name='reports page load')
        self.client.get('api/application-configs/mainNavigation', name='reports page load')
        self.client.get('api/application-configs/dashboardSidebar', name='reports page load')
        #All report page has loaded


    @task(1)
    def report_page_specific(self):
        self.client.get('#reports/', name='reports page load')
        self.client.options('api/application-configs/logoConfigs' ,name='reports page load')
        self.client.options('api/application-configs/clientConfig',name='reports page load')
        self.client.options('api/application-configs/mainNavigation',name='reports page load')
        self.client.options('api/application-configs/dashboardSidebar',name='reports page load')
        self.client.options('api/forms/all', name='reports page load')
        self.client.options('api/reports/forms?&onlySubordinates=false', name='reports page load')
        self.client.options('api/forms?&sort=name,asc&size=10&onlySubordinates=false', name='reports page load')
        self.client.options('api/client-groups?sort=name,asc&size=200', name='reports page load')
        self.client.get('api/application-configs/clientConfig', name='reports page load')
        self.client.get('api/application-configs/logoConfigs', name='reports page load')
        self.client.get('api/application-configs/mainNavigation', name='reports page load')
        self.client.get('api/application-configs/dashboardSidebar', name='reports page load')
        #All report page has loaded

        #Specific Report Loading
        #First Report
        self.client.get('api/reports/forms/6651?onlySubordinates=false', name='get specific report')
        self.client.get('api/documents?sort=title,asc&formIds=6651&submissionTypes=SUBMIT&clientGroupIds=33881&size=10&page=0', name='get specific report')
        self.client.options('api/reports/forms/6651?onlySubordinates=false&clientGroupIds=1701', name='get specific report')
        self.client.options('api/forms?&sort=name,asc&clientGroupIds=1851&formTypeId=6601&size=10&onlySubordinates=false', name='get specific report')
        #Second Report
        self.client.get('api/reports/forms?&onlySubordinates=false&clientGroupIds=1851', name='get specific report 2')
        self.client.get('api/forms?&sort=name,asc&clientGroupIds=1851&formTypeId=6601&size=10&onlySubordinates=false', name='get specific report 2')
        self.client.options('api/reports/forms?&onlySubordinates=false&clientGroupIds=1851',name='get specific report 2')
        self.client.options('api/forms?&sort=name,asc&clientGroupIds=1851&formTypeId=6601&size=10&onlySubordinates=false',name='get specific report 2')

    @task(1)
    def get_contracting_companies(self):
        #API- GET all contracting companies (companies with no params to filter)
        self.client.get("api/contracting-companies", headers=self.headers, catch_response=False, name='get_contracting_companies')

    @task(1)
    def get_datasource_history(self):
        #API - Data Source History
        self.client.get("api/data-source-history", headers=self.headers, catch_response=False,name='get_datasource_history')

    @task(1)
    def data_sets(self):
        
        self.client.get('api/application-configs/logoConfigs', name='data sets')
        self.client.get('api/application-configs/clientConfig', name='data sets')
        self.client.get('api/application-configs/mainNavigation', name='data sets')
        self.client.get('api/application-configs/dashboardSidebar', name='data sets')
        self.client.get('api/data-sources?page=0&size=10&sort=title%2Casc', name='data sets')
        self.client.options('api/data-sources?page=0&size=10&sort=title%2Casc', name='data sets')

        self.client.options('api/data-sources/3050', name='data sets specific')
        self.client.get('api/data-sources/3050', name='data sets specific')

    # @task(0)
    # def documents_page_parallel(self):
    #     from gevent.pool import Group
    #     group=Group()
    #     group.spawn(lambda: self.client.get('/#documents', name='documents page initial navigation'))
    #                 lambda: self.client.get('/api/work-locations/2011/participants', name='documents page load'))
    #     group.join()

class WebsiteUser(HttpUser):
    log = logging.getLogger("WebsiteUser")

    host = "https://rts.api.perf.powerfields-dev.io/"
    #Host manually should be input

    def setup(self):
        self.log.info("Setting up")
        logging.basicConfig(level=os.environ.get("LOGLEVEL", "INFO"))
    
  
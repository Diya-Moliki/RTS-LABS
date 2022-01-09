resource "aws_ssm_document" "deploy_locust" {
  name          = "deploy_locust"
  document_type = "Command"
  tags          = var.tags

  content = <<DOC
  {
    "schemaVersion": "2.2",
    "description": "Redeploy Locust with new locustfile from s3",
    "parameters": {

    },
    "mainSteps": [
    {
      "action": "aws:runShellScript",
      "name": "runShellScript",
      "inputs": {
        "runCommand":  [
                "#!/bin/bash", 
                "cd /opt/locust",
                "pwd",
                "sudo aws s3 sync s3://locustfiles.powerfields-dev.io/ /opt/locust/", 
                "ls",
                "sudo find ./ -name \"*.py\" -exec chmod +x {} \\;",
                "sudo docker rm $(docker ps -q -a) --force", 
                "echo Removed Locust Containers",
                "sudo docker run -d -p 8089:8089  --ulimit nofile=10000  -v $PWD:/opt/locust locustio/locust -f /opt/locust/LoadTestFull.py --logfile /opt/locust/log",
                "echo Successfully deployed Locust Container",
                "echo Navigate to locust.powerfields-dev.io:8089",
                ""
                ]
           }
    }
  ]
  }
DOC
}

# resource "aws_ssm_document" "deploy_locust_compose" {
#   name          = "deploy_locust_docker"
#   document_type = "Command"
#   tags = var.tags

#   content = <<DOC
#   {
#     "schemaVersion": "1.2",
#     "description": "Redeploy Locust with new locustfile from s3",
#     "parameters": {

#     },
#     "runtimeConfig": {
#       "aws:runShellScript": {
#         "properties": [
#           {
#             "id": "0.aws:runShellScript",
#             "runCommand": [
#                 "#!/bin/bash", 
#                 "cd /opt/locust",
#                 "sudo aws s3 cp s3://locustfiles.powerfields-dev.io/locustfile.py /opt/locust/locustfile.py", 
#                 "sudo chmod +x /opt/locust/locustfile.py", 
#                 "sudo docker-compose down", 
#                 "echo Removed Locust Containers",
#                 "sudo docker-compose up --scale worker=4 -d",
#                 "echo Successfully deployed Locust Container",
#                 "echo Navigate to locust.powerfields-dev.io:8089",
#                 ""
#                 ]
#           }
#         ]
#       }
#     }
#   }
# DOC
# }
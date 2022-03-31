# Insructions for deploying ECS cluster in to AWS using terraform and deploying ECS Service through AWS Codebuild whenever there is an update to code

## Prerequisites

To use this guide, you must have the following software components installed:

+ [Python](http://docs.python-guide.org/en/latest/starting/installation/) - a prerequisite for the AWS CLI
+ [PIP](https://pip.pypa.io/en/stable/installing/) - a prerequisite for the AWS CLI
+ [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
+ [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Step 1: Build an ECS Cluster

+ Navigate to the Option2/terraform folder and run below mentioned commands.

+ While executing terraform plan and apply commands, pass the appropriate values for ACCESS_KEY and SECRET_KEY these access credentials for the target AWS account.

```
terraform init

terraform plan -var AWS_ACCESS_KEY={} -var AWS_SECRET_KEY={}

terraform apply -var AWS_ACCESS_KEY={} -var AWS_SECRET_KEY={}
```

This terraform code will create an ECS Fargate cluster inside a vpc which has 2 public and 2 private subnets.

Once after successful terraform execution you should see an Output value for ALB. Note down this value inorder to test the app at the end.

## Step 2: Create an ECR Registry and CodeBuild project

1. Create a ECR registry by running the following command.
    + Change the hello-world to whatever name u like.

```
aws ecr create-repository --repository-name hello-world --region us-east-1
```

2. Update the parameters public-subnet1-id, public-subnet2-id, ecs-security-group and targetGroupArn with the appropriate values in service.json. You can get these values from terraform.tfstate file or from the AWS console.

3. Create a CodeBuild project which is used as a build agent instead of Jenkins.

    + Replace the ACC_NUM,Github location and if there are any other parameters whcih doesn't makes sense to u according to your project with the appropriate values in codebuild.json file.

    + This codebuild project will montitor the changes from your Git repository with the help of webhooks and will trigger a build for every change to ur repo.

    + This build will create a docker image as per ur Dockerfile and this image gets pushed to the ECR repo and also ECS Service will get refreshed every time with this build.

```
aws codebuild create-project --cli-input-json file://codebuild.json
```

## Step 3. Finally testing the service

+ Finally hit the ALB url which we noted down in Step1. If the deployment is successful then we should see Hello World msg.

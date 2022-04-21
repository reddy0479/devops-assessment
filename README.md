
### Option 1
#### Scenario

* We will build a Jenkins pipeline that pulls its configuration from another git repository that can be centrally managed by the whole devOps team.
* This pipeline should support running a Node.JS applications coverage tests and report back to a tool such as github the build status.

### Option 2
#### Scenario

* We will build a ECS cluster in AWS using Terraform
* Using AWS CodeBuild we will build a CI/CD flow that will monitor git repository for changes to a docker file, build and push the dockerfile to ECR and deploy it to ECS for testing.

## Solutions 

#### For Option 1 

* Navigate to the [Option1](https://github.com/reddy0479/devops-assessment/tree/main/Option1) folder you should see a [README](https://github.com/reddy0479/devops-assessment/tree/main/Option1/README.md) file with all the instructions for developing and testing this scenario. 
* This is the https://github.com/reddy0479/sample-nodejs Github Repo used for developing this solution.

#### For Option 2 

* Navigate to the [Option2](https://github.com/reddy0479/devops-assessment/tree/main/Option2) folder you should see a [README](https://github.com/reddy0479/devops-assessment/tree/main/Option2/README.md) file with all the instructions for developing and testing this scenario. 
* This is the https://github.com/reddy0479/aws-ecs-demo Github Repo used for developing this solution.

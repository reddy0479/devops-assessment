# Assessment

## Level 3
These options can take a hour to a few hours to complete depending on your technical aptitude

### Option 1
#### Scenario
* This assessment assumes as a Sr. devOps engineer you are expected to manage a Jenkins server.
* You need to build a Jenkins pipeline that pulls its configuration from another git repository that can be centrally managed by the whole devOps team.
* This pipeline should support running a Node.JS applications coverage tests and report back to a tool such as github the build status.
* This should all be written in IaC and CM code of your choice and placed in the Lvl3 folder under a folder called Option1.
* Instructions for use and building this solution should be included in the Option1 folder as well.

### Option 2
#### Scenario
* This assessment assumes as a Sr. devOps engineer you are expected to be able to build and manage a ECS cluster in AWS.
* You need to build a ECS cluster in AWS using Terraform.
* Using a CI/CD tool such a Jenkins or CodeBuild, build a CI/CD flow that will monitor your git repository for changes to a docker file, build and push the dockerfile to ECR and deploy it to ECS for testing.
* This should all be written in IaC and CM code of your choice and placed in the Lvl3 folder under a folder called Option1.
* Instructions for use and building this solution should be included in the Option2 folder as well.


## Solutions 

#### For Option 1 

* Navigate to the [Option1](https://github.com/reddy0479/devops-assessment/tree/main/Option1) folder you should see a [README](https://github.com/reddy0479/devops-assessment/tree/main/Option1/README.md) file with all the instructions for developing and testing this scenario. 
* This is the https://github.com/reddy0479/sample-nodejs Github Repo used for developing this solution.

#### For Option 2 

* Navigate to the [Option2](https://github.com/reddy0479/devops-assessment/tree/main/Option2) folder you should see a [README](https://github.com/reddy0479/devops-assessment/tree/main/Option2/README.md) file with all the instructions for developing and testing this scenario. 
* This is the https://github.com/reddy0479/aws-ecs-demo Github Repo used for developing this solution.
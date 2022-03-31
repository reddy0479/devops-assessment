# Insructions for setting up Continuous Delivery Pipeline for a NodeJs Application using Jenkins, GitHub

## Prerequisites

To use this guide, you must have the following software components installed:

+ [Python](http://docs.python-guide.org/en/latest/starting/installation/) - a prerequisite for the AWS CLI
+ [PIP](https://pip.pypa.io/en/stable/installing/) - a prerequisite for the AWS CLI
+ [jq](https://stedolan.github.io/jq/download/) - a command line utility for parsing JSON output
+ [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)
+ Github account

## Step 1: Setting up a Jenkins Server in AWS

Prerequiste for this step is you should have Admin or atleast sufficient access for an AWS account. Either default vpc or a vpc with atleast one public subnet is need for this operation.  

Inorder to setup the Jenkins server in AWS, We will deploy the provided cloudformation stack. You have to pass the vpc-id and public-subnet-id parameters for the successful deployment.  

1. Change the current working directory to Option1 folder in this repo and then execute the following command:

```
aws cloudformation create-stack --template-body file://ec2-jenkins-cft.yaml --stack-name jenkins-setup --capabilities CAPABILITY_IAM --tags Key=Name,Value=Jenkins --region us-east-1 --parameters ParameterKey=SubnetId,ParameterValue="public-subnet-id", ParameterKey=VpcId,ParameterValue="vpc-id"`
```  

+ To get the status of the stack

```
aws cloudformation describe-stacks --stack-name jenkins-setup --query 'Stacks[*].[StackId, StackStatus]'` at a command prompt.
```

2. Inorder to retrieve the public hostname of the Jenkins server.

```
aws ec2 describe-instances --filters "Name=tag:Name","Values=jenkins-ec2" | jq -r '.Reservations[].Instances[].NetworkInterfaces[].Association.PublicIp'
```

3. Retrieve the jenkins admin user password. There are couple of ways to retrieve this password.
    + First method is retrieve from secrets manager. We pushed this password during EC2 instance spin up from UserData script for easy retieval.

    ```
    aws secretsmanager get-secret-value --secret-id JenkinsPwd | jq -r '.SecretString'
    ```

    + Second method is login to EC2 instance terminal using AWS Systems Manager --> Sessions Manager service. This EC2 instance is already equipped with SSM access during spin up to facilitate this login process. With this method we don't have to manage the KeyPairs.

    ```
    cat /var/lib/jenkins/secrets/initialAdminPassword
    ```

## Step 2: Jenkins Configuration

1. Hit the Url http://<public_hostname>:8080 in the browser. You should get the public hostname of the Jenkins server from Step 1.2.

2. Paste the password you copied from the command `cat /var/lib/jenkins/secrets/initialAdminPassword` from Step 1.3, and then choose **Next**.
3. Choose **Install suggested plugins**.
4. Create your first admin user by providing the following information:

    + Username: `<username>`
    + Password: `<password>`
    + Confirm password: `<password>`
    + Full name: `<full_name>`
    + Email address: `<email_address>`

5. Choose **Save and finish**.
6. Choose **Start Using Jenkins**.
7. Install Jenkins plugins.

## Step 3: Integrate Jenkins and Github with each other
### Install Jenkins Plugins

1. Log in to Jenkins with your username and password created from 2.4.
2. On the main dashboard, click **Manage Jenkins** --> **Manage plugins** --> **Available** tab.
3. Select Github Integration, BlueOcean, Docker Plugin.
4. Choose **Download now and restart after install**.

### Configure Github

In this step we will create a new repo for storing our node js application and we will also integrate that repo with Jenkins server.

4. Login to your Github account and navigate to **Repositories** tab. and create a new repo there.

5. Enable webhooks on your new repo so Jenkins is notified whenever there is a change event in the repo.

    - Browse to newly created GitHub repo and navigate to **Settings** --> **Webhooks** --> **Add webhook**. As shown in this image enter the **Payload URL** as `Jenkins-PublicIP/github-webhook/` leave the remaining fields as it as and select the **Just the push event** option and finally **Update Webhook**

    ![alt text](https://github.com/reddy0479/devops-assessment/blob/test/images/github-webhook.png "Github")

    - Test the Webhook whether it is working fine or not by navigating to recent deliveries tab in the same section and you should see a successful delivery message there if evevrything is good.

    ![alt text](https://github.com/reddy0479/devops-assessment/blob/test/images/github-verify.png "Github")

6. Generate the **Personal Access Token** which is used as a access token for Jenkins integration such that Jenkins will have the ability to send the status of the builds back to the Github. Keep this token handy this will be used in later process.
    
    - In the upper-right corner of any page, click your profile photo, then click Settings --> Developer settings --> Personal access tokens --> Generate new token

    ![alt text](https://github.com/reddy0479/devops-assessment/blob/test/images/github-personal.png "Github")

### Jenkins Configuration

This configuration will help us to report back the build status to Github after every build.

7. Go to the Jenkins homepage and select **Manage Jenkins** --> **Configure System** --> **Github**

    ![alt text](https://github.com/reddy0479/devops-assessment/blob/test/images/jenkins-github.png "Jenkins")

8. Select the Username with Password option and then in the Username field enter your Github username and in the Password section enter the Personal Access Token generated from Step 3.6 and click Add at the bottom. 

    Finally Test Connection if everything configured properly we should see Credentials verified for user message. After this test don't forget to save this configuration by clicking the Save option at the end.
    
    ![alt text](https://github.com/reddy0479/devops-assessment/blob/test/images/github-cred.png "Jenkins")


## Step 4: Push the code to repo and see the Continuous Delivery cycle.

Finally create a simple hello-world nodejs applciation by cloning from this sampele repo https://github.com/reddy0479/sample-nodejs

Make any change to your code and when you push the code back to the Github a build will be triggered automatically in Jenkins server and it will report back the status to your Github repo.

Go to the commit section in your repo and you can see the build status of all the commits of your repo. This will be helpful when we are reviewing any Pull Requests as we can see whether the commit passes all the tests or not before approving it.

- Unit Test Status

    ![alt text](https://github.com/reddy0479/devops-assessment/blob/main/images/test-status.png "Jenkins")

- Pipeline Status

    ![alt text](https://github.com/reddy0479/devops-assessment/blob/main/images/pipeline-status.png "Jenkins")

- Commit Status

     ![alt text](https://github.com/reddy0479/devops-assessment/blob/main/images/commit-check.png "Jenkins")

- PR Status

     ![alt text](https://github.com/reddy0479/devops-assessment/blob/main/images/PR-check.png "Jenkins")
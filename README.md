# ☁️ Ghost in the Cloud

Welcome to the Ghost in the Cloud project, a project that hosts the Ghost platform in the cloud. The following instructions will guide you through the process of installation and provide an overview of the project's architecture.

# Table of Contents

- [💻 Installation](#-installation)
- [🔄 Updating the Code](#-updating-the-code)
- [🛠️ Update the Codepipeline](#️-update-the-codepipeline)
- [🗑️ Use Delete Posts Lambda](#️-use-delete-posts-lambda)
- [🏗️ Architecture Summary](#️-architecture-summary)
- [📚 Architecture Slides](#-architecture-slides)

# 💻 Installation

To set up this project on your own machine and AWS account, follow these steps:

1. Fork the following repositories:

- https://github.com/KoehlerClem/ghost_platform
- https://github.com/KoehlerClem/Ghost

2. Initialize the submodules in the Ghost Repository:

        git submodule update --init --recursive

3. Create a GitHub token with the permissions shown in the image below:

![Token Permissions](Documentation/TokenPermissions.png)

4. Run the deploy script with the following arguments:

        ./deploy.sh <aws-profile> <GitHubOwner> <ghost-aws-infra-repo> <ghost-repo> <git-branch> <github-token>
        
    For example: 
        
        ./deploy.sh default KoehlerClem ghost_platform Ghost main abc123SecretToken

Note: Only one branch per AWS account is supported. If you want to deploy multiple branches, you will need to create a new AWS account for each branch.

5. ☕️ Wait for the deployment to complete (this may take approximately 30 minutes).
6. In the AWS console, go to the CloudFormation stack and find the CloudFront output link.
7. Ghost is now deployed and ready to use at the CloudFront URL!

# 🔄 Updating the Code 

To update the AWS infrastructure or Ghost App, push your changes to the corresponding GitHub repository and branch you declared in the deploy script. The Codepipeline will automatically detect the changes and deploy the new version. 

On Pull request a CodeBuild will be run to test the changes. You can find an example pull request here: https://github.com/KoehlerClem/ghost_platform/pull/4

# 🛠️ Update the Codepipeline

To update the Codepipelines set the AWS profile:
    
    export aws_profile=<aws-profile>

Updating the Ghost AWS Cloudformation Pipeline:

    aws cloudformation deploy --template-file CICD/codepipeline_infra.yml --stack-name codepipeline-infra --capabilities CAPABILITY_IAM --profile $aws_profile

Updating the Ghost App Codepipeline:

    aws cloudformation deploy --template-file CICD/codepipeline_app.yml --stack-name codepipeline-app --capabilities CAPABILITY_IAM --profile $aws_profile
    

# 🗑️ Use Delete Posts Lambda

The Lambda uses (Ghosts token authentication)[https://ghost.org/docs/admin-api/#token-authentication]

To get a token, create a integration for the Posts Lambda in the Ghost admin panel:

1. Go to the Ghost admin panel and go to Settings.

![Lambda Integration](Documentation/integration1.png)
2. Go to Integrations.
![Lambda Integration](Documentation/integration2.png)
3. Click on "Add custom integration".
![Lambda Integration](Documentation/integration3.png)
4. Enter the name of the integration and get the Admin API Key

![Lambda Integration](Documentation/integration4.png)

In your AWS Console go to Lambdas and look for ghost-blog-Lambda. Create a test:

    { 
        "ghost_Admin_API_key": "YOUR_ADMIN_API_KEY_HERE" 
    }

Running the test will delete all posts.

# 🏗️ Architecture Summary

In the Ghost in the Cloud project, the Ghost platform is hosted in the cloud using the following architecture:

- The Ghost app is connected to a MySQL RDS database, which has a multi-AZ deployment for high availability.
- The Ghost app is a Node.js app running on an ECS cluster behind a load balancer.
- The Ghost app load balancer is behind a CloudFront deployment for improved performance and scalability.
- Different environments for teams are divided into separate AWS accounts, and a continuous integration pipeline is in place for both the Infrastructure as Code (IAS) and the Ghost app.

To ensure security and monitoring in the Ghost in the Cloud project, the following best practices have been implemented:

- Identity and Access Management (IAM) policies are used to control access to the ECS cluster, RDS database, and other resources and services.
- CloudTrail is enabled to log API calls made to the ECS cluster, RDS database, and other resources and services.
- Security groups and network ACLs are implemented to control inbound and outbound traffic to the ECS cluster, RDS database, and other resources and services.
- Amazon CloudWatch is used to monitor resource usage and alert on any thresholds being exceeded.

Additional security and monitoring best practices that could be implemented in the future include:

- AWS PrivateLink to securely connect resources and services over a private network connection.
- AWS Config to continuously monitor resource configurations and alert on any changes.
- Amazon GuardDuty to continuously monitor for malicious or unauthorized activity.

Overall, this architecture allows the Ghost platform to be hosted in the cloud with high availability, performance, and scalability. It also allows teams to work independently in their own environments while still ensuring that changes are seamlessly integrated and deployed. Security and monitoring best practices have also been implemented to ensure the security and stability of the Ghost platform in the cloud.

While the Ghost platform is hosted in the cloud, [the Ghost platform itself is not cloud-native](https://ghost.org/docs/faq/clustering-sharding-multi-server/). This means that the Ghost platform is not optimized for the cloud and does not take advantage of the cloud's scalability and elasticity. If the CDN is not enough to handle the traffic, we should consider scaling the database or Ghost platform vertically by increasing the CPU and memory of the task definition.

# 📚 Architecture Slides

For a visual overview of the Ghost in the Cloud project, check out the slides below:

![Ghost-Blog-AWS-Architecture.001](Documentation/Ghost-Blog-AWS-Architecture.001.png)
![Ghost-Blog-AWS-Architecture.002](Documentation/Ghost-Blog-AWS-Architecture.002.png)
![Ghost-Blog-AWS-Architecture.003](Documentation/Ghost-Blog-AWS-Architecture.003.png)
![Ghost-Blog-AWS-Architecture.004](Documentation/Ghost-Blog-AWS-Architecture.004.png)
![Ghost-Blog-AWS-Architecture.005](Documentation/Ghost-Blog-AWS-Architecture.005.png)
![Ghost-Blog-AWS-Architecture.006](Documentation/Ghost-Blog-AWS-Architecture.006.png)
![Ghost-Blog-AWS-Architecture.007](Documentation/Ghost-Blog-AWS-Architecture.007.png)
![Ghost-Blog-AWS-Architecture.008](Documentation/Ghost-Blog-AWS-Architecture.008.png)


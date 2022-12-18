set -e
git_branch=${1:?Please provide the git branch name which will be deployed to AWS, one branch per Account}
aws_profile=${2:?Please provide the AWS profile which will be used to deploy the project}
aws cloudformation deploy --template-file Infrastructure/ecr.yml --stack-name ghost-blog-ecr --profile $aws_profile

# build docker image and push to ECR
cd Ghost
docker build -t ghost . 
export ACCOUNT_ID="aws sts get-caller-identity --query Account --output text --profile $aws_profile"
docker tag ghost $ACCOUNT_ID.dkr.ecr.eu-central-1.amazonaws.com/ghost-blog:latest
aws ecr get-login-password --profile $aws_profile | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.eu-central-1.amazonaws.com
docker push $ACCOUNT_ID.dkr.ecr.eu-central-1.amazonaws.com/ghost-blog:latest

# push cloudformation templates to S3
cd ..
aws cloudformation deploy --template-file Infrastructure/s3.yml --stack-name ghost-blog-s3 --profile $aws_profile
aws s3 --profile $aws_profile sync ./Infrastructure s3://ghost-blog-templates

# deploy infastructure and ci/cd pipelines
aws cloudformation deploy --template-file Infrastructure/ghost_infra.yml --stack-name ghost-blog --capabilities CAPABILITY_IAM --profile $aws_profile
aws cloudformation deploy --template-file CICD/codepipeline_infra.yml --stack-name codepipeline-infra --capabilities CAPABILITY_IAM --parameters ParameterKey=GitHubBranch,ParameterValue=$git_branch --profile $aws_profile
aws cloudformation deploy --template-file CICD/codepipeline_app.yml --stack-name codepipeline-app --capabilities CAPABILITY_IAM --parameters ParameterKey=GitHubBranch,ParameterValue=$git_branch --profile $aws_profile
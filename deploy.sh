aws cloudformation deploy --template-file Infrastructure/ecr.yml --stack-name ghost-blog-ecr

# build docker image and push to ECR
cd Ghost
docker build -t ghost . 
export ACCOUNT_ID=`aws sts get-caller-identity --query "Account" --output text`
docker tag ghost $ACCOUNT_ID.dkr.ecr.eu-central-1.amazonaws.com/ghost-blog:latest
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.eu-central-1.amazonaws.com
docker push $ACCOUNT_ID.dkr.ecr.eu-central-1.amazonaws.com/ghost-blog:latest

# push cloudformation templates to S3
cd ..
aws cloudformation deploy --template-file Infrastructure/s3.yml --stack-name ghost-blog-s3
aws s3 sync ./Infrastructure s3://ghost-blog-s3

# deploy infastructure pipeline
aws cloudformation deploy --template-file Infrastructure/codepipeline_infra.yml --stack-name codepipeline-infra --capabilities CAPABILITY_IAM
# aws cloudformation deploy --template-file Infrastructure/ghost_infra.yml --stack-name ghost-blog --capabilities CAPABILITY_IAM
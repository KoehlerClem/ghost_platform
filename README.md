# ghost_platform


## Infrastructure Setup

1. create GitHub token (which permissions?)
2. run create_env.sh which:
    1. creates an aws account for the production env
    2. creates an s3 bucket for the templates
    3. uploads the templates
    4. adds the env to the codedeploy template



aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 674464173288.dkr.ecr.eu-central-1.amazonaws.com

docker build -t ghost . 
docker tag ghost 674464173288.dkr.ecr.eu-central-1.amazonaws.com/ghost-blog:latest

docker push 674464173288.dkr.ecr.eu-central-1.amazonaws.com/ghost-blog:latest


Prequisites

1. set db password

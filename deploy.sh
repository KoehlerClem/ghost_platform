set -e
PS4='Line ${LINENO}: '
set -x

aws_profile=${1:?Please provide branch and aws profile. Example: ./deploy.sh default main}
git_branch=${2:?Please provide branch and aws profile. Example: ./deploy.sh default main}

# push cloudformation templates to S3
cd ..
aws cloudformation deploy --template-file Infrastructure/s3.yml --stack-name ghost-blog-s3 --profile $aws_profile
aws s3 --profile $aws_profile sync ./Infrastructure s3://ghost-blog-templates

# deploy infastructure and ci/cd pipelines
aws cloudformation deploy --template-file Infrastructure/ghost_infra.yml --stack-name ghost-blog --capabilities CAPABILITY_IAM --parameters ParameterKey=IsInitialDeploy,ParameterValue=true --profile $aws_profile
aws cloudformation deploy --template-file CICD/codepipeline_app.yml --stack-name codepipeline-app --capabilities CAPABILITY_IAM --parameters ParameterKey=GitHubBranch,ParameterValue=$git_branch --profile $aws_profile &
aws cloudformation deploy --template-file CICD/codepipeline_infra.yml --stack-name codepipeline-infra --capabilities CAPABILITY_IAM --parameters ParameterKey=GitHubBranch,ParameterValue=$git_branch --profile $aws_profile
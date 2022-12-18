set -e
PS4='Line ${LINENO}: '
set -x

aws_profile=${1:?Please provide branch and aws profile. Example: ./deploy.sh default main}
git_branch=${2:?Please provide branch and aws profile. Example: ./deploy.sh default main}

# push cloudformation templates to S3
aws cloudformation deploy --template-file Infrastructure/s3.yml --stack-name ghost-blog-template-s3 --profile $aws_profile
template_bucket=`aws cloudformation --profile $aws_profile describe-stacks --stack-name ghost-blog-template-s3 --query "Stacks[?StackName=='ghost-blog-template-s3'][].Outputs[].OutputValue" --output text`
aws s3 --profile $aws_profile sync ./Infrastructure s3://$template_bucket

# deploy infastructure and ci/cd pipelines
aws cloudformation deploy --template-file Infrastructure/ghost_infra.yml --stack-name ghost-blog --capabilities CAPABILITY_IAM --profile $aws_profile
aws cloudformation deploy --template-file CICD/codepipeline_app.yml --stack-name codepipeline-app --capabilities CAPABILITY_IAM --parameter-overrides ParameterKey=GitHubBranch,ParameterValue=$git_branch --profile $aws_profile &
aws cloudformation deploy --template-file CICD/codepipeline_infra.yml --stack-name codepipeline-infra --capabilities CAPABILITY_IAM --parameter-overrides ParameterKey=GitHubBranch,ParameterValue=$git_branch --profile $aws_profile
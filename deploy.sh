set -e
aws_profile=${1:?Please provide branch, aws profile and GitHub Token. Example: ./deploy.sh default main GITHUB_ACCESS_TOKEN}
git_branch=${2:?Please provide branch, aws profile and GitHub Token. Example: ./deploy.sh default main GITHUB_ACCESS_TOKEN}
GITHUB_ACCESS_TOKEN=${3:?Please provide branch, aws profile and GitHub Token. Example: ./deploy.sh default main GITHUB_ACCESS_TOKEN}
aws secretsmanager create-secret --profile $aws_profile --name GITHUB_ACCESS --secret-string "{\"GITHUB_ACCESS_TOKEN\": \"$GITHUB_ACCESS_TOKEN\"} --force-overwrite-replica-secret
PS4='Line ${LINENO}: '
set -x


# push cloudformation templates to S3
aws cloudformation deploy --template-file Infrastructure/s3.yml --stack-name ghost-blog-template-s3 --profile $aws_profile
template_bucket=`aws cloudformation --profile $aws_profile describe-stacks --stack-name ghost-blog-template-s3 --query "Stacks[?StackName=='ghost-blog-template-s3'][].Outputs[].OutputValue" --output text`
aws s3 --profile $aws_profile sync ./Infrastructure s3://$template_bucket

# deploy infastructure and ci/cd pipelines
aws cloudformation deploy --template-file CICD/codepipeline_app.yml --stack-name codepipeline-app --capabilities CAPABILITY_IAM --parameter-overrides GitHubBranch=$git_branch --profile $aws_profile
aws cloudformation deploy --template-file CICD/codepipeline_infra.yml --stack-name codepipeline-infra --capabilities CAPABILITY_IAM --parameter-overrides GitHubBranch=$git_branch --profile $aws_profile
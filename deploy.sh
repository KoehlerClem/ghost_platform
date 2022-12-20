aws_profile=${1:?Please provide branch, aws profile and GitHub Token. Example: ./deploy.sh default KoehlerClem ghost_platform Ghost main GITHUB_ACCESS_TOKEN}
GitHubOwner=${2:?Please provide branch, aws profile and GitHub Token. Example: ./deploy.sh default KoehlerClem ghost_platform Ghost main GITHUB_ACCESS_TOKEN}
GitHubAWSInfraRepository=${3:?Please provide branch, aws profile and GitHub Token. Example: ./deploy.sh default KoehlerClem ghost_platform Ghost main GITHUB_ACCESS_TOKEN}
GitHubGhostRepository=${4:?Please provide branch, aws profile and GitHub Token. Example: ./deploy.sh default KoehlerClem ghost_platform Ghost main GITHUB_ACCESS_TOKEN}
git_branch=${5:?Please provide branch, aws profile and GitHub Token. Example: ./deploy.sh default KoehlerClem ghost_platform Ghost main GITHUB_ACCESS_TOKEN}
GITHUB_ACCESS_TOKEN=${6:?Please provide branch, aws profile and GitHub Token. Example: ./deploy.sh default KoehlerClem ghost_platform Ghost main GITHUB_ACCESS_TOKEN}
aws secretsmanager create-secret --profile $aws_profile --name GITHUB_ACCESS --secret-string "{\"GITHUB_ACCESS_TOKEN\": \"$GITHUB_ACCESS_TOKEN\"}"

set -e
PS4='Line ${LINENO}: '
set -x

# deploy infastructure and ci/cd pipelines
aws cloudformation deploy --template-file CICD/codepipeline_app.yml --stack-name codepipeline-app --capabilities CAPABILITY_IAM --parameter-overrides GitHubOwner=$GitHubOwner GitHubRepository=$GitHubGhostRepository GitHubBranch=$git_branch --profile $aws_profile
aws cloudformation deploy --template-file CICD/codepipeline_infra.yml --stack-name codepipeline-infra --capabilities CAPABILITY_IAM --parameter-overrides GitHubOwner=$GitHubOwner GitHubRepository=$GitHubAWSInfraRepository GitHubBranch=$git_branch --profile $aws_profile
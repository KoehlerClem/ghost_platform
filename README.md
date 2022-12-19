# ghost_platform


## Infrastructure Setup

https://docs.aws.amazon.com/dtconsole/latest/userguide/connections-update.html
1. create GitHub token (which permissions?)
2. run create_env.sh which:
    1. creates an aws account for the production env
    2. creates an s3 bucket for the templates
    3. uploads the templates
    4. adds the env to the codedeploy template


Clone the repository
initialise the submodules: git submodule update --init --recursive
Prequisites

1. set db password

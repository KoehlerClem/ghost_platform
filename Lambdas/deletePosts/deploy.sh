npm install
zip -r function.zip .
aws lambda update-function-code --function-name deletePosts --zip-file fileb://function.zip

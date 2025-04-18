# Idea to Deployment Workshop
This repo will contain everything relevant to setting up your URL Shortener service in AWS.

## Involved AWS Components
* IAM
* API Gateway
* Lambda
* DynamoDB
* S3

# Tutorial

### Creating AWS Resources
#### Creating IAM
#### Creating Lambda
#### Creating S3
#### Creating DynamoDB
#### Creating API Gateway
1. Create a REST API
   * Go to API Gateway in the AWS Console.
   * Click Create API → Choose REST API (not HTTP) → Build.
   * Set:
     * API name: e.g., url-shortener-api
     * Endpoint Type: Regional is fine.
     * IP address type: Select IPv4
   * Click Create API
2. Create Resource `/shorten`
   1. Click your `shortener-api` API
   2. Click `Create resource`
      1. Leave `Proxy resource` toggled OFF (leave it as is)
      2. Type `shorten` for the `Resource name`
      3. Leave `CORS (Cross Origin Resource Sharing)` disabled (leave it as is)
   3. Click `Create resource`
3. Create Method: POST /shorten
   1. Select `/shorten`
   2. Click Actions → Create Method → POST
   3. Integration type: Lambda Function
   4. Check "Use Lambda Proxy Integration"
   5. Lambda function: your Lambda name
   6. Click Save and confirm permissions
4. Click `/shorten` method and select `Enable CORS` within `Resource details`
   1. Allow OPTIONS,POST for the `Access-Control-Allow-Methods`
   2. Click `Save`
5. Create Resource: `/{short_code}`
   1. Click Actions → Create Resource
   2. Resource name: `{short_code}`
   3. Click Create Resource
6. Create Method: `GET` `/{short_code}`
   1. Select `/{short_code}`
   2. Click Actions → Create Method → GET
   3. Integration type: Lambda Function
   4. Use Lambda Proxy Integration
   5. Lambda function: your Lambda name
   6. Click `Save`
7. Click `/{short_code}` method and select `Enable CORS` within `Resource details`
   1. Allow OPTIONS,GET for the `Access-Control-Allow-Methods`
   2. Click `Save`
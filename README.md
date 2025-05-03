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
#### Step 1: Set Up IAM Role for Lambda
**Purpose**: Allow Lambda to access DynamoDB
**Steps:**
1. Go to IAM > Roles > Create role.
2. Select `AWS service` as trusted entity type.
3. For `Use case`, select `Lambda`
4. Attach policies:
   1.  `AmazonDynamoDBFullAccess` policy
   2.  `AWSLambdaBasicExecutionRole` policy
5. Name it `lambda-url-shortener-role`

#### Step 2: Create DynamoDB Table

**Purpose**: Store mappings of short code ↔ original URL
**Steps:**
1. Go to DynamoDB > Create table
2. Table name: `UrlShortenerTable`
3. Partition key: `short_key` (String)
4. Leave other settings default and create table

#### Step 3: Creating Lambda

**Purpose**: Handle short URL creation and redirection logic
**Steps**:

1. Go to Lambda > Create function
2. Name it `urlShortenerHandler`
3. Runtime: Python 3.12 (or latest)
4. Attach the IAM role from Step 1
5. Navigate to the `Configuration` Tab
   1. Click `Edit`
   2. Click `Add environment variable`
   3. Add environment variables: 
      1. For key fill in `TABLE_NAME`, For Value fill in `UrlShortenerTable`
      2. For key fill in `API_GATEWAY_URL`, For Value fill in `THIS WILL BE POPULATED AFTER API GATEWAY IS CREATED`
6. Paste the code for GET & POST URL logic from `lambda_function.py`

#### Step 4: Creating API Gateway
1. Create a REST API
   * Go to API Gateway in the AWS Console.
   * Click Create API → Choose REST API (not HTTP) → Build.
   * Set:
     * API name: e.g., `url-shortener-api`
     * Endpoint Type: `Regional` is fine.
     * IP address type: Select `IPv4`
   * Click `Create API`
2. Create Resource `/shorten`
   1. Click your `shortener-api` API
   2. Click `Create resource`
      1. Leave `Proxy resource` toggled OFF (leave it as is)
      2. Type `shorten` for the `Resource name`
      3. Leave `CORS (Cross Origin Resource Sharing)` disabled (leave it as is)
   3. Click `Create resource`
3. Create Method: POST /shorten
   1. Select `/shorten`
   2. Click Actions → Create Method → Method type: POST
   3. Integration type: Lambda Function
   4. Check "Use Lambda Proxy Integration"
   5. Lambda function: your Lambda name
   6. Click Save and confirm permissions
4. Click `/shorten` method and select `Enable CORS` within `Resource details`
   1. Allow OPTIONS,POST for the `Access-Control-Allow-Methods`
   2. Click `Save`
5. Click `/` and then click Create Resource: `/{short_code}`
   1. Click Actions → Create Resource
   2. Resource name: `{short_code}`
   3. Click Create Resource
6. Create Method: `GET` `/{short_code}`
   1. Select `/{short_code}`
   2. Click Actions → Create Method → GET
   3. Integration type: Lambda Function
   4. Check `Use Lambda Proxy Integration`
   5. Lambda function: your Lambda name
   6. Click `Save`
7. Click `/{short_code}` method and select `Enable CORS` within `Resource details`
   1. Allow OPTIONS,GET for the `Access-Control-Allow-Methods`
   2. Click `Save`
8. Click `Deploy API`
   1. For `Stage`, click `*New stage*`
   2. For `Stage name`, type in `v0`
   3. Click `Deploy`
      1. If successful, you'll see `Successfully created deployment for url-shortener-api2. This deployment is active for v0.` in green banner.
9. Once created and deployed, you will see something like `Resources - url-shortener-api (8tz35msz86)`, `8tz35msz86` will be your unique API Gateway ID. 
   1.  Fill this API Gateway ID into your Lambda's environment variable and replace the value for API_GATEWAY_URL with the API Gateway ID (In my case, it is `8tz35msz86`)
   2.  Similarly, in line 43 of index.html make sure to use the correct ID. Ex:     `const API_BASE = "https://8tz35msz86.execute-api.us-west-1.amazonaws.com/v0";`


#### Step 5 Upload Static Website to S3

**Purpose**: Host the frontend (HTML, CSS, JS)
**Steps**:
1. Create a new bucket (e.g., url-shortener123)
2. Enable static website hosting
   1. Within the `Properties` tab
   2. Scroll all the way down to the `Static website hosting` and click `Edit`
   3. Enable for `Static website hosting`
   4. For the Index document, type `index.hmtl`
   5. Keep the rest the same.
3. Upload index.html and any other files
4. Set permissions:
   1. Make sure to turn off `Block all public access`
   2. For `Bucket policy` paste the below snipped of Policy.

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::url-shortener1234/*"
        }
    ]
}
```
5. Use the static site endpoint (e.g., http://bucket-name.s3-website-region.amazonaws.com)

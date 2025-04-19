import json
import boto3
import hashlib

dynamodb = boto3.resource('dynamodb')
table_name = "url-shortener"
table = dynamodb.Table(table_name)

def generate_short_key(url):
    return hashlib.sha256(url.encode()).hexdigest()[:6]

def lambda_handler(event, context):
    print("Event:", json.dumps(event))

    method = event.get("httpMethod")
    path_params = event.get("pathParameters")
    
    headers = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Allow-Methods": "OPTION,POST,GET",
        "Content-Type": "application/json"
    }

    if method == "POST":
        try:
            body = json.loads(event.get("body", "{}"))
            long_url = body.get("url")

            if not long_url:
                raise ValueError("Missing 'url' in request body")

            short_key = generate_short_key(long_url)

            # Save to DynamoDB
            table.put_item(Item={
                'short_key': short_key,
                'long_url': long_url
            })

            short_url = f"https://ghwy4n1roj.execute-api.us-west-1.amazonaws.com/v0/{short_key}"

            return {
                "statusCode": 200,
                "headers": headers,
                "body": json.dumps({"shortUrl": short_url})
            }

        except Exception as e:
            return {
                "statusCode": 400,
                "headers": headers,
                "body": json.dumps({"message": str(e)})
            }

    elif method == "GET":
        try:
            short_key = path_params.get("short_code") if path_params else None
            if not short_key:
                raise ValueError("Missing short code in path")

            response = table.get_item(Key={'short_key': short_key})

            if 'Item' not in response:
                return {
                    "statusCode": 404,
                    "headers": headers,
                    "body": json.dumps({"message": "Short code not found"})
                }

            long_url = response['Item']['long_url']

            if not long_url.startswith("http"):
                long_url = "https://" + long_url

            return {
                "statusCode": 302,
                "headers": {
                    "Location": long_url  # This tells the browser to redirect
                },
                "body": ""
            }

        except Exception as e:
            return {
                "statusCode": 500,
                "headers": headers,
                "body": json.dumps({"message": str(e)})
            }

    return {
        "statusCode": 405,
        "headers": headers,
        "body": json.dumps({"message": f"Method {method} not allowed"})
    }

import json
import hashlib

POST_EVENT = {
    "resource": "/shorten",
    "path": "/shorten",
    "httpMethod": "POST",
    "body": "{\"url\":\"https://www.google.com/\"}",
}

GET_EVENT = {
    "resource": "/{short_code}",
    "path": "/d1a766",
    "httpMethod": "GET",
    "pathParameters": {
        "short_code": "d1a766"
    },
}

DATABASE = {}

def generate_short_key(url):
    """
    Generates a short key from the original URL
    """
    return hashlib.sha256(url.encode()).hexdigest()[:6]

def lambda_handler(event, context):
    # pseudocode:
    # if http method is GET
    #   get the short code from database 
    #   return the original URL for the shortcode
    # if http method is POST
    #   generate the short code from the original URL
    #   return the short code for the original URL
    pass

if __name__ == "__main__":
    print(lambda_handler(POST_EVENT, {}))
    print(lambda_handler(GET_EVENT, {}))

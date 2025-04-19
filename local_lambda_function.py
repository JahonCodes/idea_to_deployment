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
    "path": "/d0e196",
    "httpMethod": "GET",
    "pathParameters": {
        "short_code": "d0e196"
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
    if event['httpMethod'] == 'GET':
        event_parameters = event.get('pathParameters', {})
        short_code = event_parameters.get('short_code')
        return DATABASE.get(short_code)
    elif event['httpMethod'] == 'POST':
        body = json.loads(event.get('body', "{}"))
        url = body.get('url', '')
        generated_short_url = generate_short_key(url)
        DATABASE[generated_short_url] = url
        return generated_short_url

if __name__ == "__main__":
    print(lambda_handler(POST_EVENT, {}))
    print(lambda_handler(GET_EVENT, {}))
    print(DATABASE)
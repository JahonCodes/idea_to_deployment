locals {
  iam_role       = "lambda-url-shortener-role"
  ddb_name       = "UrlShortenerTable"
  lambda_name    = "urlShortenerHandler"
  s3_bucket_name = "url-shortener1234"
  api_name       = "url-shortener-api2"
}


resource "aws_iam_role" "url_shortener" {
  name        = local.iam_role
  description = "Allows Lambda functions to call AWS services on your behalf."
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "url_shortener_policy_attachment" {
  role       = aws_iam_role.url_shortener.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_lambda_function" "url_shortener_lambda" {
  function_name = local.lambda_name

  role = aws_iam_role.url_shortener.arn

  handler  = "lambda_function.lambda_handler"
  runtime  = "python3.13"
  filename = "lambda_function.zip"
  environment {
    variables = {
      TABLE_NAME      = local.ddb_name # your DynamoDB table name
      API_GATEWAY_URL = "wlub7qavv0"   # your API Gateway ID or custom domain
    }
  }
}

resource "aws_s3_bucket" "url_shortener_bucket" {
  bucket = local.s3_bucket_name
}

resource "aws_s3_bucket_website_configuration" "url_shortener_website" {
  bucket = aws_s3_bucket.url_shortener_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_dynamodb_table" "url_shortener_ddb" {
  name = local.ddb_name

  hash_key     = "short_key"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "short_key"
    type = "S"
  }
}

resource "aws_api_gateway_rest_api" "url_shortener_api" {
  name = local.api_name
}

resource "aws_api_gateway_resource" "url_shortener_short_code" {
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  parent_id   = aws_api_gateway_rest_api.url_shortener_api.root_resource_id
  path_part   = "{short_code}"
}

resource "aws_api_gateway_method" "url_shortener_short_code_get" {
  rest_api_id   = aws_api_gateway_rest_api.url_shortener_api.id
  resource_id   = aws_api_gateway_resource.url_shortener_short_code.id
  http_method   = "GET"
  authorization = "NONE"
  request_parameters = {
    "method.request.path.short_code" = true
  }
}

resource "aws_api_gateway_method_response" "get_response_200" {
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  resource_id = aws_api_gateway_resource.url_shortener_short_code.id
  http_method = aws_api_gateway_method.url_shortener_short_code_get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration" "get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.url_shortener_api.id
  resource_id             = aws_api_gateway_resource.url_shortener_short_code.id
  http_method             = aws_api_gateway_method.url_shortener_short_code_get.http_method
  integration_http_method = "POST" # Lambda function can only be invoked via POST
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.url_shortener_lambda.invoke_arn
  cache_key_parameters    = []
  content_handling        = "CONVERT_TO_TEXT"
  request_parameters      = {}
  request_templates       = {}
}

resource "aws_api_gateway_method" "url_shortener_short_code_options" {
  rest_api_id   = aws_api_gateway_rest_api.url_shortener_api.id
  resource_id   = aws_api_gateway_resource.url_shortener_short_code.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "option_response_200" {
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  resource_id = aws_api_gateway_resource.url_shortener_short_code.id
  http_method = aws_api_gateway_method.url_shortener_short_code_options.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = false
    "method.response.header.Access-Control-Allow-Headers" = false
    "method.response.header.Access-Control-Allow-Methods" = false
  }
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id          = aws_api_gateway_rest_api.url_shortener_api.id
  resource_id          = aws_api_gateway_resource.url_shortener_short_code.id
  http_method          = aws_api_gateway_method.url_shortener_short_code_options.http_method
  type                 = "MOCK"
  timeout_milliseconds = 29000
  request_templates = {
    "application/json" = jsonencode(
      {
        statusCode = 200
      }
    )
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.url_shortener_api.id
  resource_id = aws_api_gateway_resource.url_shortener_short_code.id
  http_method = aws_api_gateway_method.url_shortener_short_code_options.http_method
  status_code = aws_api_gateway_method_response.option_response_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.options_integration]
}

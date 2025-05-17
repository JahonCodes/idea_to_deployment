

resource "aws_iam_role" "url_shortener" {
  name        = "lambda-url-shortener-role"
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
  function_name = "urlShortenerHandler"

  role = aws_iam_role.url_shortener.arn

  handler  = "lambda_function.lambda_handler"
  runtime = "python3.13"
  filename = "lambda_function.zip"
  environment {
    variables = {
      TABLE_NAME      = "UrlShortenerTable" # your DynamoDB table name
      API_GATEWAY_URL = "wlub7qavv0"    # your API Gateway ID or custom domain
    }
  }
}

resource "aws_s3_bucket" "url_shortener_bucket" {
  bucket = "url-shortener1234"
}

data "archive_file" "lambda_function" { # <1>
  type             = "zip"
  source_file      = "${path.module}/../sam-app/hello-world/app.js"
  output_file_mode = "0666"
  output_path      = "${path.module}/../sam-app/build/app.js.zip"
}

resource "aws_s3_bucket" "lambda_sources" { # <2>
  acl = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_object" "object" { # <3>
  bucket = aws_s3_bucket.lambda_sources.bucket
  key = "function.zip"
  source = "${path.module}/../sam-app/build/app.js.zip"

  etag = data.archive_file.lambda_function.output_base64sha256
}

resource "aws_iam_role" "function_role" { # <4>
  name = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.iam_policy_document.json
}

data "aws_iam_policy_document" "iam_policy_document" { # <5>
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = [
        "lambda.amazonaws.com",
      ]
      type = "Service"
    }
    effect = "Allow"
  }
}

resource "aws_lambda_function" "function" { # <6>
  function_name = "HelloWorld"
  handler = "app.lambdaHandler"
  role = aws_iam_role.function_role.arn
  runtime = "nodejs14.x"
  s3_bucket = aws_s3_bucket.lambda_sources.bucket
  s3_key = aws_s3_bucket_object.object.key
  s3_object_version = aws_s3_bucket_object.object.version_id
}

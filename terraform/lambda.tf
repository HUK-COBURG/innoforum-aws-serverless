data "archive_file" "lambda_function" { # <1>
  type             = "zip"
  source_file      = "${path.module}/../sam-app/hello-world/app.js"
  output_file_mode = "0666"
  output_path      = "${path.module}/../sam-app/build/app.js.zip"
}

resource "aws_s3_bucket" "lambda_sources" { # <2>
  bucket = "lambda-bucket"
}

resource "aws_s3_bucket_versioning" "lambda_versioning" { # <2>
  bucket = aws_s3_bucket.lambda_sources.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.lambda_sources.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_kms_key" "kms_key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}


resource "aws_s3_object" "object" { # <3>
  bucket = aws_s3_bucket.lambda_sources.id
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
  s3_key = aws_s3_object.object.key
  s3_object_version = aws_s3_object.object.version_id
  tracing_config {
    mode = "PassThrough"
  }
}

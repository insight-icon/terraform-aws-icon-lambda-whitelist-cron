data "aws_caller_identity" "this" {}
data "aws_region" "this" {}

resource "aws_iam_role" "this" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_cloudwatch_event_rule" "this" {
  name = "every-five-minutes"
  description = "Fires every five minutes"
  schedule_expression = "rate(5 minutes)"
}

resource "aws_cloudwatch_event_target" "this" {
  rule = aws_cloudwatch_event_rule.this.name
  target_id = "this"
  arn = aws_lambda_function.this.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.this.arn
}

resource "aws_iam_policy" "this" {
  name = "${var.name}-logging-lambda"
  path = "/"
  description = ""

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

data "template_file" "cloudwatch_policy" {
  //  "${file("${path.module}/init.tpl")}"
  template = file("${path.module}/policies/cloudwatch-role-policy.json")
  vars = {
    name = var.name
    account_id = data.aws_caller_identity.this.account_id
  }
}

data "template_file" "s3_remote_state_policy" {
  template = file("${path.module}/policies/s3-remote-state-role-policy.json")
  vars = {
    name = var.name
    remote_state_bucket = var.terraform_state_bucket
  }
}

resource "aws_iam_role_policy" "cloudwatch_policy" {
  role = aws_iam_role.this.id
  policy = data.template_file.cloudwatch_policy.rendered
}

resource "aws_iam_role_policy" "remote_state_policy" {
  role = aws_iam_role.this.id
  policy = data.template_file.s3_remote_state_policy.rendered
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_role_policy_attachment" "vpc_policy" {
  role = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_cloudwatch_log_group" "lambda_cloudwatch_group" {
  name = var.name
}

// TODO:  Make packaging of lambda zip inline
//data template_file "lambda_function" {
//  template = file("${path.module}/lambda_function.py")
//}

//data template_file "tf_template" {
//  template = file("${path.module}/templates/main.tf")
//  vars = {
//    name = var.name
//    group = var.group
//    aws_region = data.aws_region.this.name
//    terraform_state_bucket = var.terraform_state_bucket
//  }
//}

//data template_file "lambda_tpl" {
//  template = file("${path.module}/lambda_function.py")
//  vars = {
//    name = var.name
//    group = var.group
//    aws_region = data.aws_region.this.name
//    terraform_state_bucket = var.terraform_state_bucket
//  }
//}

//resource "null_resource" "local" {
////  triggers = {
////    template = data.template_file.lambda_tpl.rendered
////  }
//  triggers = {
//    always_run = timestamp()
//  }
//
//  provisioner "local-exec" {
//    command = "echo ${data.template_file.lambda_tpl.rendered} > ~/tmp/lambda_function.py"
//  }
//  depends_on = [data.template_file.lambda_tpl]
//}

//resource "null_resource" "zip" {
//  triggers = {
//    always_run = timestamp()
//  }
//  provisioner "local-exec" {
//    command = "${path.module}/zip-lambda.sh"
//  }
//}

//data "archive_file" "lambda_zip" {
//  type        = "zip"
//  output_path = "${path.module}/lambda_function.zip"
//
//  source {
//    content  = data.template_file.lambda_function.rendered
//    filename = "lambda_function.py"
//  }
//
//  source {
//    content  = data.template_file.tf_template.rendered
//    filename = "templates/main.tf"
//  }
//
////  source {
////    content  = filemd5("${path.module}/terraform")
////    filename = "terraform"
////  }
//}

resource "aws_lambda_function" "this" {
  filename = "lambda_function.zip"

  source_code_hash = base64sha256(filemd5("${path.module}/lambda_function.zip"))
  //  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = "python3.6"
  function_name = var.name
  role = aws_iam_role.this.arn
  handler = "lambda_function.lambda_handler"

  timeout = 60
  memory_size = 512

  vpc_config {
    security_group_ids = var.security_group_ids
    subnet_ids = var.subnet_ids
  }

  environment {
    variables = {
      TF_VAR_terraform_state_bucket = var.terraform_state_bucket
      TF_VAR_name = var.sg_name
      TF_VAR_group = var.group
      TF_VAR_aws_region = data.aws_region.this.name
      TF_VAR_key = var.key
      TF_VAR_lock_table = var.lock_table
    }
  }

//  depends_on = [
//    null_resource.zip]
}



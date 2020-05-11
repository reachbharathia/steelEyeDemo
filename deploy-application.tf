data "aws_caller_identity" "current" {
}
#IAM Creation
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com", "codedeploy.amazonaws.com", "s3.amazonaws.com", "codepipeline.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "iam" {
  name  = format("%s-%s", var.resource_name_prefix, "IAM")
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "iam_custom_policy" {
  depends_on = [aws_iam_role.iam]

  name  = format("%s-%s", var.resource_name_prefix, "IAM-CUSTOM-POLICY")
  description = "A policy for Code Deploy"


  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWS",
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "logs:*",
                "elasticloadbalancing:*",
                "iam:*",
                "codedeploy:*",
                "codepipeline:*",
                "ec2:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "attach_custom_policy" {
  depends_on = [aws_iam_policy.iam_custom_policy]
 
  role       = "${aws_iam_role.iam.name}"
  policy_arn = "${aws_iam_policy.iam_custom_policy.arn}"
}

resource "aws_iam_instance_profile" "this" {

  name = format("%s-%s", var.resource_name_prefix, "INSTANCE-PROFILE")
  path = "/"
  role = aws_iam_role.iam.name
}

#S3 Creation for Application Deployment
resource "aws_s3_bucket" "this" {

  bucket        = var.bucket_name
  acl           = "private"
  force_destroy = true
  versioning {
    enabled     = true  
  } 
  server_side_encryption_configuration {
    rule {  
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }
  policy        = local.policy
}



# CodeDeploy and CodePipeline for Application Deploy.
resource "aws_codedeploy_app" "cd_app" {

  name             = format("%s-%s", var.resource_name_prefix, "CD-APP")
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "deployment_group" {

  app_name               = aws_codedeploy_app.cd_app.name
  deployment_group_name  = format("%s-%s", var.resource_name_prefix, "CD-DG")
  service_role_arn       = aws_iam_role.iam.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  deployment_style {
    deployment_type   = "IN_PLACE"
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "AppCode"
      type  = "KEY_AND_VALUE"
      value = "APPLICATION-NODE"
    }
  }

  
}

resource "aws_codepipeline" "codepipeline" {
  
depends_on = [aws_instance.application_nodes]
  name     = format("%s-%s", var.resource_name_prefix, "CodePipeline")
  role_arn = aws_iam_role.iam.arn

  

  artifact_store {
    location = aws_s3_bucket.this.id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "ApplicationSource"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["ApplicationArtifacts"]
      run_order        = 1

      configuration = {
        S3Bucket    = aws_s3_bucket.this.id
        S3ObjectKey = format("%s/%s", "application", "application.zip")
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "ApplicationDeploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["ApplicationArtifacts"]
      version         = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.cd_app.name
        DeploymentGroupName = format("%s-%s", var.resource_name_prefix, "CD-DG")
      }
    }
  }
}

#Upload Application Artifacts file to s3
resource "null_resource" "upload_artifacts" {
  depends_on = [aws_s3_bucket.this]
  provisioner "local-exec" {
    command = "sudo chmod -R 775 ${path.module}/files/"
  }
  provisioner "local-exec" {
    command = "${path.module}/files/upload_artifacts.sh \"${var.access_key}\" \"${var.secret_key}\" \"${var.token}\" \"${path.module}/files/appArtifacts/\" \"${aws_s3_bucket.this.id}\" "
  }
}

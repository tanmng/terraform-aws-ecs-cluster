resource null_resource tags_as_list_of_maps {
  count = "${length(keys(var.tags))}"

  triggers = "${map(
    "key", "${element(keys(var.tags), count.index)}",
    "value", "${element(values(var.tags), count.index)}",
    "propagate_at_launch", "true"
  )}"
}

data aws_ami ecs_optimized {
  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  most_recent = true
  owners      = ["591542846629"] # Amazon own Account ID
}

data aws_vpc private_vpc {
  id = "${var.vpc_id}"
}

data aws_region current {}

#--------------------------------------------------------------
# Data used for our IAM roles and policies
#--------------------------------------------------------------
data aws_iam_policy_document instance_assume_role_policy {
  statement {
    sid = "ECSInstanceAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# IAM policies for our EC2 instances
data aws_iam_policy_document instance_ec2_policy {
  statement {
    sid = "RegUnregToECSCluster"

    actions = [
      "ecs:DeregisterContainerInstance",
      "ecs:RegisterContainerInstance",
      "ecs:SubmitContainerStateChange",
      "ecs:SubmitTaskStateChange",
    ]

    resources = [
      "${aws_ecs_cluster.ecs_cluster.arn}",
    ]
  }

  statement {
    sid = "ManageAttributesOfInstancesInCluster"

    actions = [
      "ecs:PutAttributes",
      "ecs:DeleteAttributes",
    ]

    resources = [
      "${aws_ecs_cluster.ecs_cluster.arn}",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringEquals"
      variable = "ecs:cluster"

      values = [
        "${aws_ecs_cluster.ecs_cluster.arn}",
      ]
    }
  }

  statement {
    sid = "Telemetry"

    actions = [
      "ecs:StartTelemetrySession",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringEquals"
      variable = "ecs:cluster"

      values = [
        "${aws_ecs_cluster.ecs_cluster.arn}",
      ]
    }
  }

  statement {
    sid = "Poll"

    actions = [
      "ecs:Poll",
    ]

    resources = [
      "*",
    ]

    condition {
      test     = "StringEquals"
      variable = "ecs:cluster"

      values = [
        "${aws_ecs_cluster.ecs_cluster.arn}",
      ]
    }
  }
}

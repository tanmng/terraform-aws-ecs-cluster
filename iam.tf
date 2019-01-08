#--------------------------------------------------------------
# IAM Role and Policy for Instance in Our Cluster
#--------------------------------------------------------------
resource aws_iam_instance_profile ec2_profile {
  name_prefix = "ecs_cluster-${local.cluster_name}"
  role        = "${aws_iam_role.ec2_role.name}"
}

resource aws_iam_role ec2_role {
  name_prefix = "ecs_cluster-${local.cluster_name}"
  description = "IAM role for EC2 instances from ECS cluster ${local.cluster_name}"

  assume_role_policy = "${data.aws_iam_policy_document.instance_assume_role_policy.json}"
}

resource aws_iam_role_policy ec2_policy {
  name_prefix = "Reg-unreg-telemetri-etc-${local.cluster_name}"
  role        = "${aws_iam_role.ec2_role.id}"
  policy      = "${data.aws_iam_policy_document.instance_ec2_policy.json}"
}

resource aws_iam_role_policy ec2_generic_policy {
  name_prefix = "Discover-Poll"
  role        = "${aws_iam_role.ec2_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DiscoverPollEndpoint",
      "Effect": "Allow",
      "Action": [
        "ecs:DiscoverPollEndpoint"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

# This has to be loosen by design since we create various cloudwatch log groups with the service module
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/using_awslogs.html
resource aws_iam_role_policy ec2_cloudwatch_policy {
  name_prefix = "CloudWatch-log-${local.cluster_name}"
  role = "${aws_iam_role.ec2_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

# For some reason AWSLogs requires this ¯\_(ツ)_/¯
resource aws_iam_role_policy weird_access {
  name_prefix = "CloudWatch-weird-${local.cluster_name}"
  role        = "${aws_iam_role.ec2_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup"
      ],
      "Resource": ${jsonencode(formatlist("%s:*", list(
    aws_cloudwatch_log_group.ecs_init_log.arn,
    aws_cloudwatch_log_group.ecs_audit_log.arn,
    aws_cloudwatch_log_group.ecs_agent_log.arn,
  )))}
    }
  ]
}
EOF
}

resource aws_iam_role_policy_attachment ec2_ecr_readonly {
  role       = "${aws_iam_role.ec2_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource aws_iam_role_policy_attachment ec2_s3_readonly {
  role       = "${aws_iam_role.ec2_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

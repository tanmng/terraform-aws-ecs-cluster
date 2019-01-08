#-------------------------------------------------
# CloudWatch
#-------------------------------------------------
resource aws_cloudwatch_log_group ecs_init_log {
  name              = "ecs-init-${local.cluster_name}"
  retention_in_days = "${var.ecs_log_init_retention}"

  tags = "${merge(
    var.tags,
    map(
      "Name", "ecs-init-${local.cluster_name}",
      "Description", "Log group of ECS init running on ECS instances from cluster ${local.cluster_name}",
    )
  )}"
}

resource aws_cloudwatch_log_group ecs_audit_log {
  name              = "ecs-audit-${local.cluster_name}"
  retention_in_days = "${var.ecs_log_audit_retention}"

  tags = "${merge(
    var.tags,
    map(
      "Name", "ecs-audit-${local.cluster_name}",
      "Description", "Log group of ECS audit running on ECS instances from cluster ${local.cluster_name}",
    )
  )}"
}

resource aws_cloudwatch_log_group ecs_agent_log {
  name              = "ecs-agent-${local.cluster_name}"
  retention_in_days = "${var.ecs_log_agent_retention}"

  tags = "${merge(
    var.tags,
    map(
      "Name", "ecs-agent-${local.cluster_name}",
      "Description", "Log group of ECS agent running on ECS instances from cluster ${local.cluster_name}",
    )
  )}"
}

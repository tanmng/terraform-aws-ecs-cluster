#--------------------------------------------------------------
# ecs_cluster User Data Template
#--------------------------------------------------------------
data template_file init {
  template = "${file("${path.module}/templates/userdata.tpl")}"

  vars {
    region      = "${data.aws_region.current.name}"
    ecs_cluster = "${aws_ecs_cluster.ecs_cluster.name}"

    # Content of awslogs config file and ecs config - Base64 encoded to avoid any weird YAML issues - Yes yes, I know about "indent"
    ecs_conf_base64      = "${base64encode(data.template_file.ecs_conf.rendered)}"
    aws_cli_conf_base64  = "${base64encode(data.template_file.aws_cli_conf.rendered)}"
    aws_logs_conf_base64 = "${base64encode(data.template_file.aws_logs_conf.rendered)}"
  }
}

data template_file ecs_conf {
  template = "${file("${path.module}/templates/ecs.config.tpl")}"

  vars {
    ecs_cluster = "${aws_ecs_cluster.ecs_cluster.name}"
  }
}

data template_file aws_cli_conf {
  template = "${file("${path.module}/templates/awscli.conf.tpl")}"

  vars {
    region = "${data.aws_region.current.name}"
  }
}

data template_file aws_logs_conf {
  template = "${file("${path.module}/templates/awslogs.conf.tpl")}"

  vars {
    ecs_init_log_group  = "${aws_cloudwatch_log_group.ecs_init_log.name}"
    ecs_audit_log_group = "${aws_cloudwatch_log_group.ecs_audit_log.name}"
    ecs_agent_log_group = "${aws_cloudwatch_log_group.ecs_agent_log.name}"
  }
}

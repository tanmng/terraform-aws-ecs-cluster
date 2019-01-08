#---------------------------------------------------------------
# ecs_cluster Autoscaling Group
#---------------------------------------------------------------
resource aws_autoscaling_group asg {
  name_prefix               = "ecs_cluster-asg-${local.cluster_name}"
  vpc_zone_identifier       = ["${var.asg_subnets}"]
  launch_configuration      = "${aws_launch_configuration.lc.id}"
  max_size                  = "${var.asg_max_size}"
  min_size                  = "${var.asg_min_size}"
  desired_capacity          = "${var.asg_desired_size}"
  health_check_type         = "EC2"
  health_check_grace_period = "${var.asg_grace_period}"
  enabled_metrics           = ["${split(",", var.asg_enabled_metrics)}"]

  tags = ["${concat(
    list(
      map("key", "Name", "value", "${local.cluster_name}-ASG", "propagate_at_launch", true),
      map("key", "Description",    "value", "ECS instances running in the cluster ${local.cluster_name}",        "propagate_at_launch", true),
      map("key", "CanAccessCluster","value", "${local.cluster_name}",          "propagate_at_launch", true),
      map("key", "ECS_init_log_group","value", "${aws_cloudwatch_log_group.ecs_init_log.name}",          "propagate_at_launch", true),
      map("key", "ECS_audit_log_group","value", "${aws_cloudwatch_log_group.ecs_audit_log.name}",          "propagate_at_launch", true),
    ),
    null_resource.tags_as_list_of_maps.*.triggers)
  }"]

  /* lifecycle { */
  /*   ignore_changes = ["desired_capacity"] */
  /* } */
}

#---------------------------------------------------------------
# ecs_cluster Autoscaling Launch Configuration
#---------------------------------------------------------------
resource aws_launch_configuration lc {
  name_prefix          = "ecs_cluster-lc-${local.cluster_name}"
  image_id             = "${local.instance_ami}"
  instance_type        = "${var.instance_type}"
  key_name             = "${var.keypair}"
  security_groups      = ["${aws_security_group.sg.id}", "${var.additional_asg_sg}"]
  user_data            = "${data.template_file.init.rendered}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2_profile.id}"

  root_block_device {
    volume_type = "${var.root_volume_type}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

#---------------------------------------------------------------
# Set up autoscaling schedule for our clusters
#---------------------------------------------------------------
locals {
  all_scheduled_action_start_time = "${timeadd(timestamp(), "10m")}"

  ignore_changes_for_asg = ["desired_capacity"]
}

resource aws_autoscaling_schedule cluster_up_mien_nam {
  scheduled_action_name  = "up-mien-nam"
  desired_capacity       = 8
  start_time             = "${local.all_scheduled_action_start_time}"
  min_size               = -1
  max_size               = -1
  recurrence             = "50 8 * * *"                               # UTC
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  count                  = "${var.asg_auto_scale? 1 : 0}"

  lifecycle {
    ignore_changes = [
      "start_time",
    ]
  }
}

resource aws_autoscaling_schedule cluster_up_mien_trung {
  scheduled_action_name  = "up-mien-trung"
  desired_capacity       = 9
  start_time             = "${local.all_scheduled_action_start_time}"
  min_size               = -1
  max_size               = -1
  recurrence             = "50 9 * * *"                               # UTC
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  count                  = "${var.asg_auto_scale? 1 : 0}"

  lifecycle {
    ignore_changes = [
      "start_time",
    ]
  }
}

resource aws_autoscaling_schedule cluster_up_mien_bac {
  scheduled_action_name  = "up-mien-bac"
  desired_capacity       = 10
  start_time             = "${local.all_scheduled_action_start_time}"
  min_size               = -1
  max_size               = -1
  recurrence             = "50 10 * * *"                              # UTC
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  count                  = "${var.asg_auto_scale? 1 : 0}"

  lifecycle {
    ignore_changes = [
      "start_time",
    ]
  }
}

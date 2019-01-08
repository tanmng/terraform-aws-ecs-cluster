#---------------------------------------------------------------
# Define various outputs we will need for further work
#---------------------------------------------------------------
output cluster_name {
  description = "Name of the ECS cluster we created in this module"
  value       = "${aws_ecs_cluster.ecs_cluster.name}"
}

output instance_sg {
  description = "ID of the security group that we assigned onto our ECS instance. Use this to filter our the instance that you need"
  value       = "${aws_security_group.sg.id}"
}

output private_lb_sg {
  description = "Id of the security group that we created for internal LB. instance can access these SG freely and vice-versa"
  value       = "${aws_security_group.private_lb_sg.id}"
}

output public_lb_sg {
  description = "ID of the security group we created for public LB, LB with this SG can forward traffic onto our ECS instances"
  value       = "${aws_security_group.public_lb_sg.id}"
}

output nfs_sg {
  description = "ID of the security group we created for NFS, ECS instances can access FTP onto elements that have this SG"
  value       = "${join("", aws_security_group.cluster_nfs_sg.*.id)}"
}

output elasticsearch_sg {
  description = "ID of the security group we created for ElasticSearch, ECS instances can access ElasticSearch onto elements that have this SG"
  value       = "${join("", aws_security_group.cluster_elasticsearch_sg.*.id)}"
}

output rds_sg {
  description = "ID of the security group we created for RDS, ECS instances can access RDS onto elements that have this SG"
  value       = "${join("", aws_security_group.cluster_rds_sg.*.id)}"
}

output elasticache_sg {
  description = "ID of the security group we created for ElastiCache, ECS instances can access ElastiCache onto elements that have this SG"
  value       = "${join("", aws_security_group.cluster_elasticache_sg.*.id)}"
}

output redshift_sg {
  description = "ID of the security group we created for Redshift, ECS instances can access Redshift onto elements that have this SG"
  value       = "${join("", aws_security_group.cluster_redshift_sg.*.id)}"
}

output asg_name {
  description = "Name of the ASG running our cluster"
  value       = "${aws_autoscaling_group.asg.name}"
}

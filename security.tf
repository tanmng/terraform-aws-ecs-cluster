#--------------------------------------------------------------
# ecs_cluster security group for public ELB, assign this to any public ELB and it will be able to forward traffic our instances
#--------------------------------------------------------------
resource aws_security_group public_lb_sg {
  name_prefix = "ecs_cluster-public_lb-${local.cluster_name}"
  description = "Authorize connections from public load balancer to instances of the cluster ${local.cluster_name}"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(
    var.tags,
    map(
      "Name", "ecs_cluster-public_lb-${local.cluster_name}",
      "Description", "Authorize connections from public load balancer to instances of the cluster ${local.cluster_name}",
    )
  )}"
}

resource aws_security_group_rule allow_egress_all_from_public_lb_to_asg {
  type                     = "egress"
  from_port                = "${var.docker_ephemeral_port_from}"
  to_port                  = "${var.docker_ephemeral_port_to}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.public_lb_sg.id}"
  source_security_group_id = "${aws_security_group.sg.id}"
  description              = "Allow the public LB to forward all TCP traffics on docker ephemeral ports to internal instances"
}

#--------------------------------------------------------------
# ecs_cluster private_lb Security Group
#--------------------------------------------------------------
resource aws_security_group private_lb_sg {
  name_prefix = "ecs_cluster-private_lb-${local.cluster_name}"
  description = "Authorize connections from private load balancer to instances of the cluster ${local.cluster_name}"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(
    var.tags,
    map(
      "Name", "ecs_cluster-private_lb-${local.cluster_name}",
      "Description", "Authorize connections from private load balancer to instances of the cluster ${local.cluster_name}",
    )
  )}"
}

resource aws_security_group_rule allow_ingress_all_from_asg_to_internal_lb {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  security_group_id        = "${aws_security_group.private_lb_sg.id}"
  source_security_group_id = "${aws_security_group.sg.id}"
  description              = "Allow the private LB to receive all traffics from internal instances"
}

resource aws_security_group_rule allow_egress_all_from_private_lb_to_asg {
  type                     = "egress"
  from_port                = "${var.docker_ephemeral_port_from}"
  to_port                  = "${var.docker_ephemeral_port_to}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.private_lb_sg.id}"
  source_security_group_id = "${aws_security_group.sg.id}"
  description              = "Allow the private LB to forward all TCP traffics on docker ephemeral ports to internal instances"
}

#-------------------------------------------------------------
# ecs_cluster Host Security Group
#-------------------------------------------------------------
resource aws_security_group sg {
  name_prefix = "ecs_cluster-sg-${local.cluster_name}"
  description = "Authorize access to and from the EC2 instances running within our cluster ${local.cluster_name}"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(
    var.tags,
    map(
      "Name", "ecs_cluster-sg-${local.cluster_name}",
      "Description", "Authorize access to and from the EC2 instances running within our cluster ${local.cluster_name}",
    )
  )}"
}

resource aws_security_group_rule allow_ingress_all_public_lb {
  type                     = "ingress"
  from_port                = "${var.docker_ephemeral_port_from}"
  to_port                  = "${var.docker_ephemeral_port_to}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sg.id}"
  source_security_group_id = "${element(aws_security_group.public_lb_sg.*.id, 0)}"
  description              = "Allow the all TCP traffics on docker ephemeral ports from public LB to our instances"
}

resource aws_security_group_rule allow_ingress_all_private_lb {
  type                     = "ingress"
  from_port                = "${var.docker_ephemeral_port_from}"
  to_port                  = "${var.docker_ephemeral_port_to}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sg.id}"
  source_security_group_id = "${aws_security_group.private_lb_sg.id}"
  description              = "Allow the all TCP traffics on docker ephemeral ports from private LB to our instances"
}

resource aws_security_group_rule allow_egress_all_private_lb {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = -1
  security_group_id        = "${aws_security_group.sg.id}"
  source_security_group_id = "${aws_security_group.private_lb_sg.id}"
  description              = "Allow instances to communicate with our private LB on all protocols and ports"
}

resource aws_security_group_rule allow_egress_all_vpc_with_ephemeral_port {
  type              = "egress"
  from_port         = "${var.docker_ephemeral_port_from}"
  to_port           = "${var.docker_ephemeral_port_to}"
  protocol          = -1
  security_group_id = "${aws_security_group.sg.id}"
  cidr_blocks       = ["${data.aws_vpc.private_vpc.cidr_block}"]
  description       = "Allow instance to use communicate with the whole VPC on Docker Ephemeral ports"
}

resource aws_security_group_rule allow_ingress_all_vpc_on_ephemeral_port {
  type              = "ingress"
  from_port         = "${var.docker_ephemeral_port_from}"
  to_port           = "${var.docker_ephemeral_port_to}"
  protocol          = -1
  security_group_id = "${aws_security_group.sg.id}"
  cidr_blocks       = ["${data.aws_vpc.private_vpc.cidr_block}"]
  description       = "Allow instance to use accept incoming communication from the whole VPC on Docker Ephemeral ports"
}

resource aws_security_group_rule allow_egress_http_all {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow instance to use HTTP"
}

resource aws_security_group_rule allow_egress_https_all {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow instance to use HTTPS"
}

resource aws_security_group_rule allow_egress_puppet_all {
  type              = "egress"
  from_port         = 8140
  to_port           = 8140
  protocol          = "tcp"
  security_group_id = "${aws_security_group.sg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow puppet agent to connect to puppetserver"
}

#-------------------------------------------------------------
# SG for external resources
#-------------------------------------------------------------
# RDS
resource aws_security_group cluster_rds_sg {
  name_prefix = "ecs_cluster-rds-${local.cluster_name}"
  description = "SG to assigned to RDS instances/cluster so that instances from ${local.cluster_name} can access it"
  count       = "${var.create_sg_for_rds? 1 : 0}"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(
    var.tags,
    map(
      "Name", "ecs_cluster-rds-${local.cluster_name}",
      "Description", "SG to assigned to RDS instances/cluster so that instances from ${local.cluster_name} can access it",
    )
  )}"
}

resource aws_security_group_rule allow_egress_from_instances_to_rds {
  type                     = "egress"
  count                    = "${var.create_sg_for_rds? length(local.rds_tcp_ports) : 0}"
  from_port                = "${element(local.rds_tcp_ports, count.index)}"
  to_port                  = "${element(local.rds_tcp_ports, count.index)}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sg.id}"
  source_security_group_id = "${aws_security_group.cluster_rds_sg.id}"
  description              = "Allow instances from cluster to access RDS on TCP port ${element(local.rds_tcp_ports, count.index)}"
}

resource aws_security_group_rule allow_ingres_from_instances_to_rds {
  type                     = "ingress"
  count                    = "${var.create_sg_for_rds? length(local.rds_tcp_ports) : 0}"
  from_port                = "${element(local.rds_tcp_ports, count.index)}"
  to_port                  = "${element(local.rds_tcp_ports, count.index)}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cluster_rds_sg.id}"
  source_security_group_id = "${aws_security_group.sg.id}"
  description              = "Allow instances from cluster to access RDS on TCP port ${element(local.rds_tcp_ports, count.index)}"
}

# ElastiCache
resource aws_security_group cluster_elasticache_sg {
  name_prefix = "ecs_cluster-elasticache-${local.cluster_name}"
  description = "SG to assigned to ElasicCache instances/cluster so that instances from ${local.cluster_name} can access it"
  count       = "${var.create_sg_for_elasticache? 1 : 0}"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(
    var.tags,
    map(
      "Name", "ecs_cluster-elasticache-${local.cluster_name}",
      "Description", "SG to assigned to elasticache instances/cluster so that instances from ${local.cluster_name} can access it",
    )
  )}"
}

resource aws_security_group_rule allow_egress_from_instances_to_elasticache {
  type                     = "egress"
  count                    = "${var.create_sg_for_elasticache? length(local.elasticache_tcp_ports) : 0}"
  from_port                = "${element(local.elasticache_tcp_ports, count.index)}"
  to_port                  = "${element(local.elasticache_tcp_ports, count.index)}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sg.id}"
  source_security_group_id = "${aws_security_group.cluster_elasticache_sg.id}"
  description              = "Allow instances from cluster to access elasticache on TCP port ${element(local.elasticache_tcp_ports, count.index)}"
}

resource aws_security_group_rule allow_ingres_from_instances_to_elasticache {
  type                     = "ingress"
  count                    = "${var.create_sg_for_elasticache? length(local.elasticache_tcp_ports) : 0}"
  from_port                = "${element(local.elasticache_tcp_ports, count.index)}"
  to_port                  = "${element(local.elasticache_tcp_ports, count.index)}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cluster_elasticache_sg.id}"
  source_security_group_id = "${aws_security_group.sg.id}"
  description              = "Allow instances from cluster to access elasticache on TCP port ${element(local.elasticache_tcp_ports, count.index)}"
}

# NFS
resource aws_security_group cluster_nfs_sg {
  name_prefix = "ecs_cluster-nfs-${local.cluster_name}"
  description = "SG to assigned to ElasicCache instances/cluster so that instances from ${local.cluster_name} can access it"
  count       = "${var.create_sg_for_nfs? 1 : 0}"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(
    var.tags,
    map(
      "Name", "ecs_cluster-nfs-${local.cluster_name}",
      "Description", "SG to assigned to ElasicCache instances/cluster so that instances from ${local.cluster_name} can access it",
    )
  )}"
}

resource aws_security_group_rule allow_egress_from_instances_to_nfs {
  type                     = "egress"
  count                    = "${var.create_sg_for_nfs? length(local.nfs_tcp_ports) : 0}"
  from_port                = "${element(local.nfs_tcp_ports, count.index)}"
  to_port                  = "${element(local.nfs_tcp_ports, count.index)}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sg.id}"
  source_security_group_id = "${aws_security_group.cluster_nfs_sg.id}"
  description              = "Allow instances from cluster to access nfs on TCP port ${element(local.nfs_tcp_ports, count.index)}"
}

resource aws_security_group_rule allow_ingres_from_instances_to_nfs {
  type                     = "ingress"
  count                    = "${var.create_sg_for_nfs? length(local.nfs_tcp_ports) : 0}"
  from_port                = "${element(local.nfs_tcp_ports, count.index)}"
  to_port                  = "${element(local.nfs_tcp_ports, count.index)}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cluster_nfs_sg.id}"
  source_security_group_id = "${aws_security_group.sg.id}"
  description              = "Allow instances from cluster to access nfs on TCP port ${element(local.nfs_tcp_ports, count.index)}"
}

# ElasticSearch
resource aws_security_group cluster_elasticsearch_sg {
  name_prefix = "ecs_cluster-elasticsearch-${local.cluster_name}"
  description = "SG to assigned to ElasicCache instances/cluster so that instances from ${local.cluster_name} can access it"
  count       = "${var.create_sg_for_elasticsearch? 1 : 0}"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(
    var.tags,
    map(
      "Name", "ecs_cluster-elasticsearch-${local.cluster_name}",
      "Description", "SG to assigned to ElasicCache instances/cluster so that instances from ${local.cluster_name} can access it",
    )
  )}"
}

resource aws_security_group_rule allow_egress_from_instances_to_elasticsearch {
  type                     = "egress"
  count                    = "${var.create_sg_for_elasticsearch? length(local.elasticsearch_tcp_ports) : 0}"
  from_port                = "${element(local.elasticsearch_tcp_ports, count.index)}"
  to_port                  = "${element(local.elasticsearch_tcp_ports, count.index)}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sg.id}"
  source_security_group_id = "${aws_security_group.cluster_elasticsearch_sg.id}"
  description              = "Allow instances from cluster to access elasticsearch on TCP port ${element(local.elasticsearch_tcp_ports, count.index)}"
}

resource aws_security_group_rule allow_ingres_from_instances_to_elasticsearch {
  type                     = "ingress"
  count                    = "${var.create_sg_for_elasticsearch? length(local.elasticsearch_tcp_ports) : 0}"
  from_port                = "${element(local.elasticsearch_tcp_ports, count.index)}"
  to_port                  = "${element(local.elasticsearch_tcp_ports, count.index)}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cluster_elasticsearch_sg.id}"
  source_security_group_id = "${aws_security_group.sg.id}"
  description              = "Allow instances from cluster to access elasticsearch on TCP port ${element(local.elasticsearch_tcp_ports, count.index)}"
}

# redshift
resource aws_security_group cluster_redshift_sg {
  name_prefix = "ecs_cluster-redshift-${local.cluster_name}"
  description = "SG to assigned to ElasicCache instances/cluster so that instances from ${local.cluster_name} can access it"
  count       = "${var.create_sg_for_redshift? 1 : 0}"
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(
    var.tags,
    map(
      "Name", "ecs_cluster-redshift-${local.cluster_name}",
      "Description", "SG to assigned to ElasicCache instances/cluster so that instances from ${local.cluster_name} can access it",
    )
  )}"
}

resource aws_security_group_rule allow_egress_from_instances_to_redshift {
  type                     = "egress"
  count                    = "${var.create_sg_for_redshift? length(local.redshift_tcp_ports) : 0}"
  from_port                = "${element(local.redshift_tcp_ports, count.index)}"
  to_port                  = "${element(local.redshift_tcp_ports, count.index)}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.sg.id}"
  source_security_group_id = "${aws_security_group.cluster_redshift_sg.id}"
  description              = "Allow instances from cluster to access redshift on TCP port ${element(local.redshift_tcp_ports, count.index)}"
}

resource aws_security_group_rule allow_ingres_from_instances_to_redshift {
  type                     = "ingress"
  count                    = "${var.create_sg_for_redshift? length(local.redshift_tcp_ports) : 0}"
  from_port                = "${element(local.redshift_tcp_ports, count.index)}"
  to_port                  = "${element(local.redshift_tcp_ports, count.index)}"
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cluster_redshift_sg.id}"
  source_security_group_id = "${aws_security_group.sg.id}"
  description              = "Allow instances from cluster to access redshift on TCP port ${element(local.redshift_tcp_ports, count.index)}"
}

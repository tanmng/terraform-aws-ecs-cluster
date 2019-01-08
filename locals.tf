locals {
  cluster_name  = "${var.name_tag}"
  number_format = "%02d"

  # Allow user to overwrite the AMI
  instance_ami = "${length(var.asg_ami) > 0 ? var.asg_ami : data.aws_ami.ecs_optimized.id}"

  # List of TCP ports that we use to access our databases from EC2 instances
  rds_tcp_ports = [
    3306, # Aurora, MySQL and Mariadb
    1433, # MS SQL
    1521, # Oracle
    5432, # PostgreSQL
  ]

  # List of TCP ports that we use to access our elasticache (redis / memcached)
  elasticache_tcp_ports = [
    6379,  # Redis
    11211, # Memcached
  ]

  # List of TCP ports that we use to access NFS/EFS
  nfs_tcp_ports = [
    2049, # NFS
  ]

  # List of TCP ports that we use to access ElasticSearch
  elasticsearch_tcp_ports = [
    9200, # Web protocol
    9300, # Native protocol
  ]

  redshift_tcp_ports = [
    5439, # Redshift default port
  ]

  # Name prefix for elements
  asg_name_prefix_raw              = "ecs_cluster-asg-${local.cluster_name}"
  lc_name_prefix_raw               = "ecs_cluster-lc-${local.cluster_name}"
  asg_sg_name_prefix_raw           = "ecs_cluster-sg-${local.cluster_name}"
  external_lb_sg_name_prefix_raw   = "ecs_cluster-external_lb-${local.cluster_name}"
  internal_lb_sg_name_prefix_raw   = "ecs_cluster-internal_lb-${local.cluster_name}"
  rds_sg_name_prefix_raw           = "ecs_cluster-rds-${local.cluster_name}"
  elasticache_sg_name_prefix_raw   = "ecs_cluster-elasticache-${local.cluster_name}"
  nfs_sg_name_prefix_raw           = "ecs_cluster-nfs-${local.cluster_name}"
  elasticsearch_sg_name_prefix_raw = "ecs_cluster-elasticsearch-${local.cluster_name}"
  redshift_sg_name_prefix_raw      = "ecs_cluster-redshift-${local.cluster_name}"
}

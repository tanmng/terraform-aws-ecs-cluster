locals {
  cluster_name  = "${var.name_tag}"
  number_format = "%02d"

  # Allow user to overwrite the AMI
  instance_ami = "${length(var.asg_ami) > 0? var.asg_ami : data.aws_ami.ecs_optimized.id}"

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
  asg_name_prefix_raw = "ecs_cluster-asg-${local.cluster_name}"
  lc_name_prefix_raw = "ecs_cluster-lc-${local.cluster_name}"
}

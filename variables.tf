#--------------------------------------------------------------
# Global Variables
#--------------------------------------------------------------
variable vpc_id {
  description = "The VPC ID in which to deploy the ecs_cluster infrastructure."
  type        = "string"
}

#--------------------------------------------------------------
# ecs_cluster Tagging Variables
#--------------------------------------------------------------
variable tags {
  description = "Map of tags that we wish to set on our resources"
  type        = "map"
  default     = {}
}

variable name_tag {
  description = "A tag to append to the name of cluster"
}

#--------------------------------------------------------------
# Autoscaling Group Variables
#--------------------------------------------------------------
variable asg_subnets {
  description = "List of subnet IDs in which the ASG should launch resources."
  type        = "list"
}

variable asg_ami {
  description = "The ID of AMI which we want to use to launch our ECS instances, set to empty to use the AWS optimized AMI"
  type        = "string"
  default     = ""
}

variable asg_grace_period {
  description = "The number of seconds to wait after instance launch before starting health checks."
  default     = 30
}

variable asg_min_size {
  description = "The minimum size of the ASG that run our ECS cluster"
  default     = 1
}

variable asg_max_size {
  description = "The maximum size of the ASG that run our ECS cluster"
  default     = 20
}

variable asg_desired_size {
  description = "The desired size of the ASG that run our ECS cluster"
  default     = 1
}

variable asg_force_desired_size {
  description = "Specify whether we wish to force the desired size of our ASG - in case it's scaling"
  default     = false
}

variable root_volume_type {
  description = "The root volume type for the ecs_cluster host."
  type        = "string"
  default     = "gp2"
}

variable asg_enabled_metrics {
  description = "ASG group metrics to enable."
  type        = "string"
  default     = "GroupInServiceInstances,GroupMinSize"
}

variable additional_asg_sg {
  description = "List of additional security groups that we should set to the instances of the ECS cluster"
  type        = "list"
  default     = []
}

variable asg_auto_scale {
  description = "Whether we wish to use autoscale scheduled events on our ASG"
  default     = true
}

#--------------------------------------------------------------
# Launch Configuration Variables
#--------------------------------------------------------------
variable keypair {
  description = "The name of the Aws keypair to use when launching instances."
  type        = "string"
}

variable instance_type {
  description = "The instance type to deploy for ecs_cluster instances."
  type        = "string"
  default     = "t2.nano"
}

#--------------------------------------------------------------
# Load Balancing Variables
#--------------------------------------------------------------
variable docker_ephemeral_port_from {
  description = "The minimum port of docker ephemeral for the version running on our instances"
  default     = 32768
}

variable docker_ephemeral_port_to {
  description = "The maximum port of docker ephemeral for the version running on our instances"
  default     = 60999
}

#--------------------------------------------------------------
# Configuration of the Cloudwatch log groups we set up for ECS init and ECS audit
#--------------------------------------------------------------
variable ecs_log_init_retention {
  description = "Number of days which we wish to keep the logs of ECS init in cloudwatch"
  default     = 3
}

variable ecs_log_audit_retention {
  description = "Number of days which we wish to keep the logs of ECS audit in cloudwatch"
  default     = 3
}

variable ecs_log_agent_retention {
  description = "Number of days which we wish to keep the logs of ECS agent in cloudwatch"
  default     = 3
}

#--------------------------------------------------------------
# SG for EB instances / Elasticache / NFS / ElasticSearch created outside of this module
#--------------------------------------------------------------
variable create_sg_for_nfs {
  description = "Specify whether we should create a SG for NFS, this group can be assigned to any NFS boxes/EFS clusters so that our instances from cluster can access it"
  default     = false
}

variable create_sg_for_rds {
  description = "Specify whether we should create a SG for RDS, this group can be assigned to any AWS RDS instances/clusters so that our instances from cluster can access it"
  default     = false
}

variable create_sg_for_elasticache {
  description = "Specify whether we should create a SG for Elasticache, this group can be assigned to any AWS ElasticCache instances/clusters of EC2 instances running such service so that our instances from cluster can access it"
  default     = false
}

variable create_sg_for_elasticsearch {
  description = "Specify whether we should create a SG for elasticsearch, this group can be assigned to any elasticsearch boxes/EFS clusters so that our instances from cluster can access it"
  default     = false
}

variable create_sg_for_redshift {
  description = "Specify whether we should create a SG for redshift, this group can be assigned to any redshift instance/cluster so that our instances from cluster can access it"
  default     = false
}

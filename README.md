# terraform-aws-ecs-cluster

A terraform module to set up ECS cluster along with all resources required to run our services

## Assumption

The module assume that you have a VPC in AWS which has internet access. A VPC with public and private subnets is more preferable.
Also, you should have an ECS keypair available in the AWS region that you are launching this

## What will the module set up

The module will set up following resources:
* An AWS ECS cluster
* An AWS EC2 ASG that have instances running the [Amazon ECS-optimized
    AMI](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html)
    which will automatically register to the ECS cluster upon creation
* IAM instance profile and accompanying IAM role for the EC2 instances to
    register themselves with ECS and receive configuration data
* Cloudwatch log groups for
    * ECS agent
    * ECS init
    * ECS audit
* Security groups for following resources
    * Internal LB
    * External (internet-facing) LB
    * ASG
    > The SG that we set up for internal and external LB have the required
    rules to allow them to forward traffic to our instances (and receive traffic
    from our instances in the case of internal LB). The idea is to assign these
    SG to our ELB and that should take care of the forwarding side of the
    traffic
    * RDS instances/cluster (optional)
    * ElastiCache instances (optional)
    * EFS instances (optional)
    * ElasticSearch instances (optional)
    * Redshift
    > Similar to the LB SGs, the 5 optional security groups have all the rules
    required to allow connection from instances in the cluster

**To avoid any potential mishap, the IAM role for our ECS instance allow it to
only access the cluster we set up with the module. A tag with the name
`CanAccessCluster` will signify the name of the cluster as well**. Please
**ONLY** try to modify this behaviour if you really know what you are doing


## Usage

For a complete set up of VPC, ECS cluster, load balancers and services in AWS,
please see the [example repo](https://github.com/tanmng/aws-terraform-complete-ecs-example)

## Security Groups

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_asg_sg | List of additional security groups that we should set to the instances of the ECS cluster | list | `<list>` | no |
| asg_ami | The ID of AMI which we want to use to launch our ECS instances, set to empty to use the AWS optimized AMI | string | `` | no |
| asg_auto_scale | Whether we wish to use autoscale scheduled events on our ASG | string | `true` | no |
| asg_desired_size | The desired size of the ASG that run our ECS cluster | string | `1` | no |
| asg_enabled_metrics | ASG group metrics to enable. | string | `GroupInServiceInstances,GroupMinSize` | no |
| asg_force_desired_size | Specify whether we wish to force the desired size of our ASG - in case it's scaling | string | `false` | no |
| asg_grace_period | The number of seconds to wait after instance launch before starting health checks. | string | `30` | no |
| asg_max_size | The maximum size of the ASG that run our ECS cluster | string | `20` | no |
| asg_min_size | The minimum size of the ASG that run our ECS cluster | string | `1` | no |
| asg_subnets | List of subnet IDs in which the ASG should launch resources. | list | - | yes |
| create_sg_for_elasticache | Specify whether we should create a SG for Elasticache, this group can be assigned to any AWS ElasticCache instances/clusters of EC2 instances running such service so that our instances from cluster can access it | string | `false` | no |
| create_sg_for_elasticsearch | Specify whether we should create a SG for elasticsearch, this group can be assigned to any elasticsearch boxes/EFS clusters so that our instances from cluster can access it | string | `false` | no |
| create_sg_for_nfs | Specify whether we should create a SG for NFS, this group can be assigned to any NFS boxes/EFS clusters so that our instances from cluster can access it | string | `false` | no |
| create_sg_for_rds | Specify whether we should create a SG for RDS, this group can be assigned to any AWS RDS instances/clusters so that our instances from cluster can access it | string | `false` | no |
| create_sg_for_redshift | Specify whether we should create a SG for redshift, this group can be assigned to any redshift instance/cluster so that our instances from cluster can access it | string | `false` | no |
| docker_ephemeral_port_from | The minimum port of docker ephemeral for the version running on our instances | string | `32768` | no |
| docker_ephemeral_port_to | The maximum port of docker ephemeral for the version running on our instances | string | `60999` | no |
| ecs_log_agent_retention | Number of days which we wish to keep the logs of ECS agent in cloudwatch | string | `3` | no |
| ecs_log_audit_retention | Number of days which we wish to keep the logs of ECS audit in cloudwatch | string | `3` | no |
| ecs_log_init_retention | Number of days which we wish to keep the logs of ECS init in cloudwatch | string | `3` | no |
| instance_type | The instance type to deploy for ecs_cluster instances. | string | `t3.nano` | no |
| keypair | The name of the Aws keypair to use when launching instances. | string | - | yes |
| name_tag | A tag to append to the name of cluster | string | - | yes |
| root_volume_type | The root volume type for the ecs_cluster host. | string | `gp2` | no |
| tags | Map of tags that we wish to set on our resources | map | `<map>` | no |
| vpc_id | The VPC ID in which to deploy the ecs_cluster infrastructure. | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| asg_name | Name of the ASG running our cluster |
| cluster_name | Name of the ECS cluster we created in this module |
| elasticache_sg | ID of the security group we created for ElastiCache, ECS instances can access ElastiCache onto elements that have this SG |
| elasticsearch_sg | ID of the security group we created for ElasticSearch, ECS instances can access ElasticSearch onto elements that have this SG |
| external_lb_sg | ID of the security group we created for external LB, LB with this SG can forward traffic onto our ECS instances |
| instance_sg | ID of the security group that we assigned onto our ECS instance. Use this to filter our the instance that you need |
| internal_lb_sg | Id of the security group that we created for internal LB. instance can access these SG freely and vice-versa |
| nfs_sg | ID of the security group we created for NFS, ECS instances can access FTP onto elements that have this SG |
| rds_sg | ID of the security group we created for RDS, ECS instances can access RDS onto elements that have this SG |
| redshift_sg | ID of the security group we created for Redshift, ECS instances can access Redshift onto elements that have this SG |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

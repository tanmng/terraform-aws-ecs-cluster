#--------------------------------------------------------------
# Actual ECS cluster which will run the services
#--------------------------------------------------------------
resource aws_ecs_cluster ecs_cluster {
  name = "${local.cluster_name}"
}

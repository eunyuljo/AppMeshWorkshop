output "internal_load_balancer_dns" {
  description = "The DNS for the internal load balancer"
  value       = aws_lb.internal_load_balancer.dns_name
}

output "internal_load_balancer_arn" {
  description = "The ARN for the internal load balancer"
  value       = aws_lb.internal_load_balancer.arn
}

output "external_load_balancer_dns" {
  description = "The DNS for the external load balancer"
  value       = aws_lb.external_load_balancer.dns_name
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_one" {
  value = aws_subnet.private_subnet_one.id
}

output "private_subnet_two" {
  value = aws_subnet.private_subnet_two.id
}

output "private_subnet_three" {
  value = aws_subnet.private_subnet_three.id
}

# output "ecs_cluster_name" {
#   value = aws_ecs_cluster.ruby_asg.name
# }

output "stack_name" {
  value = var.stack_name
}

output "crystal_task_definition" {
  value = aws_ecs_task_definition.crystal_task.id
}

output "ruby_target_group_arn" {
  value = aws_lb_target_group.ruby_target_group.arn
}

output "crystal_target_group_arn" {
  value = aws_lb_target_group.crystal_target_group.arn
}

# output "container_security_group" {
#   value = aws_security_group.container_security_group.id
# }

output "crystal_ecr_repo" {
  value = aws_ecr_repository.crystal.repository_url
}

output "nodejs_ecr_repo" {
  value = aws_ecr_repository.nodejs.repository_url
}

output "ruby_autoscaling_group_name" {
  value = aws_autoscaling_group.ruby_asg.name
}

# output "ec2_external_role" {
#   value = aws_iam_role.ec2_external_instance_role.arn
# }

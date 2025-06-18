# output "load_balancer_dns" {
#   description = "The DNS name of the Application Load Balancer."
#   value       = aws_lb.main.dns_name
# }


# This data source is needed to fetch the public IP after the service is stable
output "instructions" {
  description = "Instructions to find the public IP of your container."
  value = <<EOT
Your Strapi container has been deployed. Because the Public IP is assigned dynamically by AWS,
you can find it after deployment using one of the methods below.

1. AWS Management Console:
   - Navigate to the ECS service named '${aws_ecs_service.main.name}' in the cluster '${aws_ecs_cluster.main.name}'.
   - Click on the 'Tasks' tab.
   - Click on the running task ID.
   - In the 'Network' section, you will find the 'Public IP'.

2. AWS CLI:
   - You can get the IP using the following command (requires AWS CLI and jq):
   aws ecs describe-tasks --cluster ${aws_ecs_cluster.main.name} --tasks $(aws ecs list-tasks --cluster ${aws_ecs_cluster.main.name} --service-name ${aws_ecs_service.main.name} --query 'taskArns[0]' --output text) --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value | [0]' --output text | xargs -I {} aws ec2 describe-network-interfaces --network-interface-ids {} --query 'NetworkInterfaces[0].Association.PublicIp' --output text

Your application will be available at: http://<YOUR_PUBLIC_IP>:1337
EOT
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "The name of the ECS service."
  value       = aws_ecs_service.main.name
}
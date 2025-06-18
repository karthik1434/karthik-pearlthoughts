# data "aws_ecs_task" "example" {
#   cluster = aws_ecs_cluster.my_cluster.id
#   task_id = "<TASK_ID>"  # You need to know this or fetch dynamically using `external` data source or CLI.
# }

# data "aws_network_interface" "task_eni" {
#   id = data.aws_ecs_task.example.attachments[0].details[?key=="networkInterfaceId"][0].value
# }

# output "ecs_fargate_task_public_ip" {
#   description = "Public IP of the ECS Fargate task"
#   value       = data.aws_network_interface.task_eni.association[0].public_ip
# }

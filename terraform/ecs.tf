resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = "${var.name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.public.id]
    security_groups = [aws_security_group.task_sg.id]
  }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.main.arn
#     container_name   = "${var.name}-strapi"
#     container_port   = 1337
#   }
  # This ensures that a new deployment is triggered when the task definition changes
  force_new_deployment = true
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
#   execution_role_arn       = "arn:aws:iam::123456789012:role/YourExistingEcsRoleName"

  container_definitions = jsonencode([
    {
      name      = var.name
      image     = "duggana1994/strapi-app:latest"
      essential = true
      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
        }
      ]
    #   environment = [
    #     {
    #       name  = "APP_KEYS",
    #       value = "someRandomKey1,someRandomKey2" # Replace with actual random keys
    #     },
    #     {
    #       name  = "API_TOKEN_SALT",
    #       value = "aRandomSaltValue" # Replace with an actual random salt
    #     },
    #     {
    #       name = "ADMIN_JWT_SECRET",
    #       value = "aRandomAdminJwtSecret" # Replace with an actual random secret
    #     },
    #     {
    #       name = "JWT_SECRET",
    #       value = "aRandomJwtSecret" # Replace with an actual random secret
    #     }
    #   ]
    }
  ])
}


# Security Group for the ECS Task
resource "aws_security_group" "task_sg" {
  name        = "${var.name}-task-sg"
  description = "Allow traffic from the LB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    security_groups = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-ecs-task-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
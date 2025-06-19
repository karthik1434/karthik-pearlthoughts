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
    assign_public_ip = true
  }

  force_new_deployment = true
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::607700977843:role/ecsTaskExecutionRole"

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

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.strapi.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs/strapi"
        }
      }
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
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

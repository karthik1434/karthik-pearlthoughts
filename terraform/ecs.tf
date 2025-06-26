resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name       = aws_ecs_cluster.main.name
  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
    base              = 0
  }
}

# ECS Service blue
resource "aws_ecs_service" "blue" {
  name            = "${var.name}-blue"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  # Add capacity provider strategy for Fargate Spot
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  network_configuration {
    subnets         = aws_subnet.public[*].id
    security_groups = [aws_security_group.task_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = "${var.name}-strapi"
    container_port   = 1337
  }
  depends_on = [aws_lb_listener.http]
  force_new_deployment = true
}

# # ECS Service green
# resource "aws_ecs_service" "green" {
#   name            = "${var.name}-green"
#   cluster         = aws_ecs_cluster.main.id
#   task_definition = aws_ecs_task_definition.app.arn
#   desired_count   = 0

#   deployment_controller {
#     type = "CODE_DEPLOY"
#   }

#   # Add capacity provider strategy for Fargate Spot
#   capacity_provider_strategy {
#     capacity_provider = "FARGATE_SPOT"
#     weight            = 1
#   }

#   network_configuration {
#     subnets         = aws_subnet.public[*].id
#     security_groups = [aws_security_group.task_sg.id]
#     assign_public_ip = true
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.green.arn
#     container_name   = "${var.name}-strapi"
#     container_port   = 1337
#   }
#   depends_on = [aws_lb_listener.http]
#   force_new_deployment = true
# }



data "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"
}

resource "aws_iam_role_policy_attachment" "ecs_exec_policy" {
  role       = data.aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}





# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name}-strapi"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn = data.aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "${var.name}-strapi"
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
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Cluster of FARGATE type
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "ecs-cluster"
}

# IAM Role for ecs-task
resource "aws_iam_role" "ecs_role" {
  name = "ecs-taskExecution-role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_policy" {
  name = "ecs_policy"
  role = aws_iam_role.ecs_role.id

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
  })
}

resource "aws_cloudwatch_log_group" "ecs-demo-cw" {
  name              = "ecs-demo"
  retention_in_days = 1
}

# Creates a task definition for ecs cluster
resource "aws_ecs_task_definition" "ecs-demo" {
  family = "hello-world"
  requires_compatibilities = [ "FARGATE" ]
  memory = "512"
  cpu = "256"
  network_mode = "awsvpc"
  execution_role_arn = aws_iam_role.ecs_role.arn

  container_definitions = <<EOF
[
  {
    "name": "hello-world",
    "image": "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/hello-world:latest",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80
      }
    ],
    healthCheck: {
    command: ["CMD-SHELL", "curl -f http://localhost/ || exit 1"]
    }
    "memory": 128,
    "cpu": 100,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "us-east-1",
        "awslogs-group": "ecs-demo",
        "awslogs-stream-prefix": "demo-ecs"
      }
    }
  }
]
EOF
}

resource "aws_ecs_service" "ecs-demo" {
  name            = "ecs-demo"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.ecs-demo.arn
  desired_count   = 1
  launch_type = "FARGATE"
  platform_version = "LATEST"
  network_configuration {
    subnets = [ aws_subnet.ecs-publicsubnet1.id, aws_subnet.ecs-publicsubnet2.id]
    security_groups = [ aws_security_group.vpc-ecs-sg.id ]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs-alb-tg.arn
    container_name   = "hello-world"
    container_port   = 80
  }

}

# Creates an application load balancer.
resource "aws_lb" "ecs-alb" {
  name               = "ecs-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.ecs-alb-sg.id]
  subnets            = [aws_subnet.ecs-publicsubnet1.id, aws_subnet.ecs-publicsubnet2.id]

  tags = {
    Name = "ecs-alb"
  }
  depends_on = [aws_internet_gateway.ecs-vpc-igw]
}

# Create a new target group for the application load balancer.
resource "aws_lb_target_group" "ecs-alb-tg" {
  name     = "ecs-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ecs-vpc.id
  target_type = "ip"
  
  health_check {
    enabled = true
  }
  depends_on = [aws_lb.ecs-alb]
}

# Create alb listener for http traffic
resource "aws_lb_listener" "ecs-alb-listener-http" {
  load_balancer_arn = aws_lb.ecs-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs-alb-tg.arn
  }
}

# SG for ecs tasks to allow http traffic.
resource "aws_security_group" "vpc-ecs-sg" {
  name        = "vpc-ecs-sg"
  vpc_id      = aws_vpc.ecs-vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-vpc-sg"
  }
}

# ALB security group.
resource "aws_security_group" "ecs-alb-sg" {
  name        = "ecs-alb-sg"
  vpc_id      = aws_vpc.ecs-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-alb-sg"
  }
}

# ALB Url 
output "alb_url" {
  value = "http://${aws_lb.ecs-alb.dns_name}"
}
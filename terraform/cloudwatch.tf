resource "aws_cloudwatch_log_group" "strapi" {
  name              = "/ecs/${var.name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "HighCPU-Alarm-Strapi"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "70"
  alarm_description   = "This alarm triggers if CPU > 70% for 2 minutes"
  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.main.name
  }
#   alarm_actions = [aws_sns_topic.alerts.arn] # Optional
}


resource "aws_cloudwatch_dashboard" "strapi_dashboard" {
  dashboard_name = "StrapiDashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x    = 0
        y    = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            [ "AWS/ECS", "CPUUtilization", "ClusterName", "${aws_ecs_cluster.main.name}", "ServiceName", "${aws_ecs_service.main.name}" ],
            [ ".", "MemoryUtilization", ".", ".", ".", "." ]
          ]
          view       = "timeSeries"
          stacked    = false
          region     = var.region
          title      = "ECS CPU & Memory"
        }
      }
    ]
  })
}


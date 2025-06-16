variable "aws_region" {
  description = "AWS region for the dashboard."
  type        = string
}

variable "dashboard_name" {
  description = "Name of the CloudWatch dashboard."
  type        = string
  default     = "EC2-Metrics-Dashboard"
}

variable "instances" {
  description = "List of instances with their configurations and metrics settings"
  type = list(object({
    instance_id    = string
    os_type        = string
    name           = string
    image_id       = string
    instance_type  = string
    ami_name       = string
    objectname     = optional(string, "Processor")
    volumes        = optional(list(string), [])
    drives         = optional(list(string), [])   # Windows drives override
    mounts         = optional(list(string), [])   # Linux mounts override
    metrics_config = object({
      cpu = object({
        namespace   = string
        metric_name = string
        dimensions  = map(string)
      })
      memory = object({
        namespace   = string
        metric_name = string
        dimensions  = map(string)
      })
      disk = object({
        namespace   = string
        metric_name = string
        dimensions  = map(string)
      })
    })
  }))
  default = []
}

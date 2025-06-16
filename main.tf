locals {
  linux_types     = ["linux", "ubuntu", "amazon-linux", "suse-linux"]
  linux_instances = [for instance in var.instances : instance if contains(local.linux_types, instance.os_type)]
  windows_instances = [for instance in var.instances : instance if instance.os_type == "windows"]
  instances = concat(local.linux_instances, local.windows_instances)

  # Default mount points
  linux_mounts   = ["/"]  # Simplified for basic monitoring
  windows_drives = ["C:"] # Default system drive

  # Basic widget dimensions
  widget_width  = 8
  widget_height = 6
  widgets_per_row = 3

  # Metric definitions
  windows_metrics = {
    cpu = {
      metric_name = "Processor % Processor Time"
      dimensions  = {
        objectname = "Processor"
        instance   = "_Total"
      }
      label = "CPU Usage"
      color = "#1f77b4"
    }
    memory = {
      metric_name = "Memory % Committed Bytes In Use"
      dimensions  = {
        objectname = "Memory"
      }
      label = "Memory Usage"
      color = "#2ca02c"
    }
    disk = {
      metric_name = "LogicalDisk % Free Space"
      dimensions  = {
        objectname = "LogicalDisk"
      }
      label = "Disk Space"
      color = "#ff7f0e"
    }
  }

  linux_metrics = {
    cpu = {
      metric_name = "cpu_usage_active"
      dimensions  = {
        cpu = "cpu0"
      }
      label = "CPU Usage"
      color = "#1f77b4"
    }
    memory = {
      metric_name = "mem_used_percent"
      dimensions  = {}
      label = "Memory Usage"
      color = "#2ca02c"
    }
    disk = {
      metric_name = "disk_used_percent"
      dimensions  = {}
      label = "Disk Usage"
      color = "#ff7f0e"
    }
  }
}

resource "aws_cloudwatch_dashboard" "all_ec2_dashboard" {
  dashboard_name = var.dashboard_name

  dashboard_body = jsonencode({
    widgets = flatten([
      # Windows Instance Widgets
      [
        for idx, instance in local.windows_instances : [
          # CPU Widget
          {
            type = "metric"
            x    = (idx * 3) % 24
            y    = floor((idx * 3) / 24) * 18
            width  = local.widget_width
            height = local.widget_height
            properties = {
              metrics = [
                [
                  "CWAgent",
                  local.windows_metrics.cpu.metric_name,
                  "InstanceId", instance.instance_id,
                  local.windows_metrics.cpu.dimensions.objectname, "Processor",
                  local.windows_metrics.cpu.dimensions.instance, "_Total",
                  {
                    label  = "${local.windows_metrics.cpu.label} - ${instance.instance_id}"
                    color  = local.windows_metrics.cpu.color
                  }
                ]
              ]
              view    = "timeSeries"
              stacked = false
              region  = var.aws_region
              title   = "Windows CPU - ${instance.instance_id}"
              period  = 300
              stat    = "Average"
            }
          },
          # Memory Widget
          {
            type = "metric"
            x    = ((idx * 3) + 1) % 24
            y    = floor((idx * 3) / 24) * 18
            width  = local.widget_width
            height = local.widget_height
            properties = {
              metrics = [
                [
                  "CWAgent",
                  local.windows_metrics.memory.metric_name,
                  "InstanceId", instance.instance_id,
                  local.windows_metrics.memory.dimensions.objectname, "Memory",
                  {
                    label = "${local.windows_metrics.memory.label} - ${instance.instance_id}"
                    color = local.windows_metrics.memory.color
                  }
                ]
              ]
              view    = "timeSeries"
              stacked = false
              region  = var.aws_region
              title   = "Windows Memory - ${instance.instance_id}"
              period  = 300
              stat    = "Average"
            }
          },
          # Disk Widget
          {
            type = "metric"
            x    = ((idx * 3) + 2) % 24
            y    = floor((idx * 3) / 24) * 18
            width  = local.widget_width
            height = local.widget_height
            properties = {
              metrics = [
                for drive in coalesce(instance.volumes, local.windows_drives) : [
                  "CWAgent",
                  local.windows_metrics.disk.metric_name,
                  "InstanceId", instance.instance_id,
                  local.windows_metrics.disk.dimensions.objectname, "LogicalDisk",
                  "instance", drive,
                  {
                    label = "${local.windows_metrics.disk.label} (${drive}) - ${instance.instance_id}"
                    color = local.windows_metrics.disk.color
                  }
                ]
              ]
              view    = "timeSeries"
              stacked = false
              region  = var.aws_region
              title   = "Windows Disk - ${instance.instance_id}"
              period  = 300
              stat    = "Average"
            }
          }
        ]
      ],
      # Linux Instance Widgets
      [
        for idx, instance in local.linux_instances : [
          # CPU Widget
          {
            type = "metric"
            x    = (idx * 3) % 24
            y    = floor((idx * 3) / 24) * 18 + (length(local.windows_instances) * 18)
            width  = local.widget_width
            height = local.widget_height
            properties = {
              metrics = [
                [
                  "CWAgent",
                  local.linux_metrics.cpu.metric_name,
                  "InstanceId", instance.instance_id,
                  "cpu", "cpu0",
                  {
                    label = "${local.linux_metrics.cpu.label} - ${instance.instance_id}"
                    color = local.linux_metrics.cpu.color
                  }
                ]
              ]
              view    = "timeSeries"
              stacked = false
              region  = var.aws_region
              title   = "Linux CPU - ${instance.instance_id}"
              period  = 300
              stat    = "Average"
            }
          },
          # Memory Widget
          {
            type = "metric"
            x    = ((idx * 3) + 1) % 24
            y    = floor((idx * 3) / 24) * 18 + (length(local.windows_instances) * 18)
            width  = local.widget_width
            height = local.widget_height
            properties = {
              metrics = [
                [
                  "CWAgent",
                  local.linux_metrics.memory.metric_name,
                  "InstanceId", instance.instance_id,
                  {
                    label = "${local.linux_metrics.memory.label} - ${instance.instance_id}"
                    color = local.linux_metrics.memory.color
                  }
                ]
              ]
              view    = "timeSeries"
              stacked = false
              region  = var.aws_region
              title   = "Linux Memory - ${instance.instance_id}"
              period  = 300
              stat    = "Average"
            }
          },
          # Disk Widget
          {
            type = "metric"
            x    = ((idx * 3) + 2) % 24
            y    = floor((idx * 3) / 24) * 18 + (length(local.windows_instances) * 18)
            width  = local.widget_width
            height = local.widget_height
            properties = {
              metrics = [
                for mount in coalesce(instance.volumes, local.linux_mounts) : [
                  "CWAgent",
                  local.linux_metrics.disk.metric_name,
                  "InstanceId", instance.instance_id,
                  "path", mount,
                  "fstype", mount == "/" ? "xfs" : "tmpfs",
                  {
                    label = "${local.linux_metrics.disk.label} (${mount}) - ${instance.instance_id}"
                    color = local.linux_metrics.disk.color
                  }
                ]
              ]
              view    = "timeSeries"
              stacked = false
              region  = var.aws_region
              title   = "Linux Disk - ${instance.instance_id}"
              period  = 300
              stat    = "Average"
            }
          }
        ]
      ]
    ])
  })
}

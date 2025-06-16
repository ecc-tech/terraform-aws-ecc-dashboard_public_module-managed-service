locals {
  metric_config = {
    default_dimensions = {
      windows = {
        cpu = {
          InstanceId    = true
          instance      = "_Total"
          objectname    = "Processor"
          ImageId       = true
          InstanceType  = true
        }
        memory = {
          InstanceId    = true
          objectname    = "Memory"
          ImageId       = true
          InstanceType  = true
        }
        disk = {
          InstanceId    = true
          objectname    = "LogicalDisk"
          instance      = "DISK_MOUNT"
        }
      }
      linux = {
        cpu = {
          InstanceId = true
        }
        memory = {
          InstanceId = true
        }
        disk = {
          InstanceId = true
          path      = "DISK_MOUNT"
          fstype    = "xfs"
        }
      }
    }
    
    namespaces = {
      windows = {
        cpu    = "CWAgent"
        memory = "CWAgent"
        disk   = "CWAgent"
      }
      linux = {
        cpu    = "CWAgent"
        memory = "CWAgent"
        disk   = "CWAgent"
      }
    }
    
    metric_names = {
      windows = {
        cpu    = "\\Processor Information(_Total)\\% Processor Time"
        memory = "\\Memory\\% Committed Bytes In Use"
        disk   = "\\LogicalDisk(*)\\% Free Space"
      }
      linux = {
        cpu    = "cpu_usage_active"
        memory = "mem_used_percent"
        disk   = "disk_used_percent"
      }
    }
  }
}

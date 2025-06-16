locals {
  # Helper function to format dimensions
  format_dimensions = {
    windows = {
      cpu = { for inst in var.instances :
        inst.instance_id => [
          ["InstanceId", inst.instance_id],
          ["instance", "_Total"],
          ["objectname", "Processor"],
          ["ImageId", inst.image_id],
          ["InstanceType", inst.instance_type]
        ]
      }
      memory = { for inst in var.instances :
        inst.instance_id => [
          ["InstanceId", inst.instance_id],
          ["objectname", "Memory"],
          ["ImageId", inst.image_id],
          ["InstanceType", inst.instance_type]
        ]
      }
      disk = { for inst in var.instances :
        inst.instance_id => [
          for drive in inst.drives : [
            ["InstanceId", inst.instance_id],
            ["objectname", "LogicalDisk"],
            ["instance", drive]
          ]
        ]
      }
    }
    linux = {
      cpu = { for inst in var.instances :
        inst.instance_id => [
          ["InstanceId", inst.instance_id]
        ]
      }
      memory = { for inst in var.instances :
        inst.instance_id => [
          ["InstanceId", inst.instance_id]
        ]
      }
      disk = { for inst in var.instances :
        inst.instance_id => [
          for mount in inst.mounts : [
            ["InstanceId", inst.instance_id],
            ["path", mount],
            ["fstype", "xfs"]
          ]
        ]
      }
    }
  }

  # Create the final metric widgets
  metric_widgets = {
    windows = {
      for inst in var.instances :
      inst.instance_id => {
        cpu = [
          local.metric_config.namespaces.windows.cpu,
          local.metric_config.metric_names.windows.cpu,
          local.format_dimensions.windows.cpu[inst.instance_id]
        ]
        memory = [
          local.metric_config.namespaces.windows.memory,
          local.metric_config.metric_names.windows.memory,
          local.format_dimensions.windows.memory[inst.instance_id]
        ]
        disk = [
          for dims in local.format_dimensions.windows.disk[inst.instance_id] : [
            local.metric_config.namespaces.windows.disk,
            local.metric_config.metric_names.windows.disk,
            dims
          ]
        ]
      } if inst.os_type == "windows"
    }
    linux = {
      for inst in var.instances :
      inst.instance_id => {
        cpu = [
          local.metric_config.namespaces.linux.cpu,
          local.metric_config.metric_names.linux.cpu,
          local.format_dimensions.linux.cpu[inst.instance_id]
        ]
        memory = [
          local.metric_config.namespaces.linux.memory,
          local.metric_config.metric_names.linux.memory,
          local.format_dimensions.linux.memory[inst.instance_id]
        ]
        disk = [
          for dims in local.format_dimensions.linux.disk[inst.instance_id] : [
            local.metric_config.namespaces.linux.disk,
            local.metric_config.metric_names.linux.disk,
            dims
          ]
        ]
      } if contains(["linux", "ubuntu", "amazon-linux", "suse-linux"], inst.os_type)
    }
  }
}

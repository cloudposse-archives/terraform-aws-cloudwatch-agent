variable "aggregation_dimensions" {
  description = "Specifies the dimensions that collected metrics are to be aggregated on"
  type        = "list"

  default = [
    ["InstanceId"],
    ["AutoScalingGroupName"],
  ]
}

variable "cpu_resources" {
  description = "Specifies that per-cpu metrics are to be collected. The only allowed value is *. If you include this field and value, per-cpu metrics are collected"
  type        = "string"
  default     = "\"resources\": [\"*\"],"
}

variable "disk_resources" {
  description = "If you specify an array of devices, CloudWatch collects metrics from only those devices. Otherwise, metrics for all devices are collected"
  type        = "list"
  default     = ["/"]
}

variable "userdata_part_content" {
  description = "The user data that should be passed along from the caller of the module."
  type        = "string"
  default     = ""
}

variable "userdata_part_content_type" {
  description = "What format is userdata_part_content in - eg 'text/cloud-config' or 'text/x-shellscript'."
  type        = "string"
  default     = "text/cloud-config"
}

variable "userdata_part_merge_type" {
  description = "Control how cloud-init merges user-data sections."
  type        = "string"
  default     = "list(append)+dict(recurse_array)+str()"
}

variable "namespace" {
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
  type        = "string"
  default     = ""
}

variable "environment" {
  description = "Environment, e.g. 'prod', 'staging', 'dev', 'pre-prod', 'UAT'"
  type        = "string"
  default     = ""
}

variable "name" {
  description = "Solution name, e.g. 'app' or 'jenkins'"
  type        = "string"
}

variable "metrics_config" {
  description = <<EOF
  "Which metrics should we send to cloudwatch, the default is standard. Setting this variable to advanced will send all the available metrics that are provided by the agent.
  You can find more information here https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-cloudwatch-agent-configuration-file-wizard.html"
EOF

  type    = "string"
  default = "standard"
}

variable "metrics_collection_interval" {
  description = <<EOF
  Specifies how often to collect the cpu metrics, overriding the global metrics_collection_interval specified in the agent section of the configuration file. If you set this value below 60 seconds, each metric is collected as a high-resolution metric.
EOF

  type    = "string"
  default = 60
}

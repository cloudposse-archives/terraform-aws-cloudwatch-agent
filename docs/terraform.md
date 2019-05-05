## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aggregation_dimensions | Specifies the dimensions that collected metrics are to be aggregated on. | list | `<list>` | no |
| cpu_resources | Specifies that per-cpu metrics are to be collected. The only allowed value is *. If you include this field and value, per-cpu metrics are collected. | string | `"resources": ["*"],` | no |
| disk_resources | Specifies an array of disk mount points. This field limits CloudWatch to collect metrics from only the listed mount points. You can specify * as the value to collect metrics from all mount points. Defaults to the root / mountpount. | list | `<list>` | no |
| metrics_collection_interval | Specifies how often to collect the cpu metrics, overriding the global metrics_collection_interval specified in the agent section of the configuration file. If you set this value below 60 seconds, each metric is collected as a high-resolution metric. | string | `60` | no |
| metrics_config | "Which metrics should we send to cloudwatch, the default is standard. Setting this variable to advanced will send all the available metrics that are provided by the agent.   You can find more information here https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create-cloudwatch-agent-configuration-file-wizard.html." | string | `standard` | no |
| name | Solution name, e.g. 'app'. | string | - | yes |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'. | string | - | yes |
| stage | Stage, e.g. 'prod', 'staging', 'dev', or 'test'. | string | `` | no |
| userdata_part_content | The user data that should be passed along from the caller of the module. | string | `` | no |
| userdata_part_content_type | What format is userdata_part_content in - eg 'text/cloud-config' or 'text/x-shellscript'. | string | `text/cloud-config` | no |
| userdata_part_merge_type | Control how cloud-init merges user-data sections. | string | `list(append)+dict(recurse_array)+str()` | no |

## Outputs

| Name | Description |
|------|-------------|
| iam_policy_document | The iam policy document that can be attached to a role policy |
| role_name | The role name that can be attached to the instance role |
| user_data | The user_data with the cloudwatch_agent configuration in base64 and gzipped |


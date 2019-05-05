<!-- This file was automatically generated by the `build-harness`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->
[![README Header][readme_header_img]][readme_header_link]

[![Cloud Posse][logo]](https://cpco.io/homepage)

# terraform-aws-cloudwatch-agent [![Build Status](https://travis-ci.org/cloudposse/terraform-aws-cloudwatch-agent.svg?branch=master)](https://travis-ci.org/cloudposse/terraform-aws-cloudwatch-agent) [![Latest Release](https://img.shields.io/github/release/cloudposse/terraform-aws-cloudwatch-agent.svg)](https://github.com/cloudposse/terraform-aws-cloudwatch-agent/releases/latest) [![Slack Community](https://slack.cloudposse.com/badge.svg)](https://slack.cloudposse.com)


Terraform module to install the CloudWatch agent on EC2 instances using `cloud-init`.


---

This project is part of our comprehensive ["SweetOps"](https://cpco.io/sweetops) approach towards DevOps. 
[<img align="right" title="Share via Email" src="https://docs.cloudposse.com/images/ionicons/ios-email-outline-2.0.1-16x16-999999.svg"/>][share_email]
[<img align="right" title="Share on Google+" src="https://docs.cloudposse.com/images/ionicons/social-googleplus-outline-2.0.1-16x16-999999.svg" />][share_googleplus]
[<img align="right" title="Share on Facebook" src="https://docs.cloudposse.com/images/ionicons/social-facebook-outline-2.0.1-16x16-999999.svg" />][share_facebook]
[<img align="right" title="Share on Reddit" src="https://docs.cloudposse.com/images/ionicons/social-reddit-outline-2.0.1-16x16-999999.svg" />][share_reddit]
[<img align="right" title="Share on LinkedIn" src="https://docs.cloudposse.com/images/ionicons/social-linkedin-outline-2.0.1-16x16-999999.svg" />][share_linkedin]
[<img align="right" title="Share on Twitter" src="https://docs.cloudposse.com/images/ionicons/social-twitter-outline-2.0.1-16x16-999999.svg" />][share_twitter]


[![Terraform Open Source Modules](https://docs.cloudposse.com/images/terraform-open-source-modules.svg)][terraform_modules]



It's 100% Open Source and licensed under the [APACHE2](LICENSE).







We literally have [*hundreds of terraform modules*][terraform_modules] that are Open Source and well-maintained. Check them out! 







## Usage


**IMPORTANT:** The `master` branch is used in `source` just as an example. In your code, do not pin to `master` because there may be breaking changes between releases.
Instead pin to the release tag (e.g. `?ref=tags/x.y.z`) of one of our [latest releases](https://github.com/cloudposse/terraform-aws-cloudwatch-agent/releases).



### Example with launch configuration:

```hcl
module "cloudwatch_agent" {
  source = "git::https://github.com/cloudposse/terraform-aws-cloudwatch-agent?ref=master"

  name = "cloudwatch_agent"
}

resource "aws_launch_configuration" "multipart" {
  name_prefix          = "cloudwatch_agent"
  image_id             = "${data.aws_ami.ecs-optimized.id}"
  iam_instance_profile = "${aws_iam_instance_profile.cloudwatch_agent.name}"
  instance_type        = "t2.micro"
  user_data_base64     = "${module.cloudwatch_agent.user_data}"
  security_groups      = ["${aws_security_group.ecs.id}"]
  key_name             = "${var.ssh_key_pair}"

  lifecycle {
    create_before_destroy = true
  }
}
```
### Example with using the role_policy_document:

```hcl
locals {
  application {
    name      = "cloudwatch_agent"
    stage     = "dev"
    namespace = "eg"
  }
}

module "label" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=master"
  environment = "${local.application["stage"]}"
  name        = "${local.application["name"]}"
  namespace   = "${local.application["namespace"]}"
}

module "cloudwatch_agent" {
  source = "git::https://github.com/cloudposse/terraform-aws-cloudwatch-agent?ref=master"

  name      = "${module.label.name}"
  stage     = "${module.label.environment}"
  namespace = "${module.label.namespace}"
}

resource "aws_launch_configuration" "multipart" {
  name_prefix          = "${module.label.name}"
  image_id             = "${data.aws_ami.ecs-optimized.id}"
  iam_instance_profile = "${aws_iam_instance_profile.cloudwatch_agent.name}"
  instance_type        = "t2.micro"
  user_data_base64     = "${module.cloudwatch_agent.user_data}"
  security_groups      = ["${aws_security_group.ecs.id}"]
  key_name             = "${var.ssh_key_pair}"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_iam_policy_document" "ec2_cloudwatch" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals = {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name = "${module.label.id}"

  assume_role_policy = "${data.aws_iam_policy_document.ec2_cloudwatch.json}"

  tags = {
    Name = "${module.label.id}"
  }
}

resource "aws_iam_role_policy" "cloudwatch_agent" {
  name   = "${module.label.id}"
  policy = "${module.cloudwatch_agent.iam_policy_document}"
  role   = "${aws_iam_role.ec2.id}"
}

resource "aws_iam_instance_profile" "cloudwatch_agent" {
  name_prefix = "${module.label.name}"
  role        = "${aws_iam_role.ec2.name}"
}
```

### Example with passing user-data and using the role from the module using advanced metrics configuration:

```hcl
module "cloudwatch_agent" {
  source = "git::https://github.com/cloudposse/terraform-aws-cloudwatch-agent?ref=master"

  name      = "cloudwatch_agent"
  stage     = "dev"
  namespace = "eg"

  metrics_config        = "advanced"
  userdata_part_content = "${data.template_file.cloud-init.rendered}"
}

data "template_file" "cloud-init" {
  template = "${file("${path.module}/cloud-init.yml")}"
}

resource "aws_launch_configuration" "multipart" {
  name_prefix          = "cloudwatch_agent"
  image_id             = "${data.aws_ami.ecs-optimized.id}"
  iam_instance_profile = "${aws_iam_instance_profile.cloudwatch_agent.name}"
  instance_type        = "t2.micro"
  user_data_base64     = "${module.cloudwatch_agent.user_data}"
  security_groups      = ["${aws_security_group.ecs.id}"]
  key_name             = "${var.ssh_key_pair}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "cloudwatch_agent" {
  name_prefix = "cloudwatch_agent"
  role        = "${module.cloudwatch_agent.role_name}"
}
```






## Makefile Targets
```
Available targets:

  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
  lint                                Lint terraform code

```
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




## Share the Love 

Like this project? Please give it a ★ on [our GitHub](https://github.com/cloudposse/terraform-aws-cloudwatch-agent)! (it helps us **a lot**) 

Are you using this project or any of our other projects? Consider [leaving a testimonial][testimonial]. =)


## Related Projects

Check out these related projects.

- [terraform-aws-ec2-instance](https://github.com/cloudposse/terraform-aws-ec2-instance) - Terraform Module for provisioning a general purpose EC2 host.
- [terraform-aws-cloudtrail-cloudwatch-alarms](https://github.com/cloudposse/terraform-aws-cloudtrail-cloudwatch-alarms) - Terraform module for creating alarms for tracking important changes and occurrences from cloudtrail.
- [terraform-aws-rds-cloudwatch-sns-alarms](https://github.com/cloudposse/terraform-aws-rds-cloudwatch-sns-alarms) - Terraform module that configures important RDS alerts using CloudWatch and sends them to an SNS topic
- [terraform-aws-cloudwatch-logs](https://github.com/cloudposse/terraform-aws-cloudwatch-logs) - Terraform Module to Provide a CloudWatch Logs Endpoint
- [terraform-aws-alb-target-group-cloudwatch-sns-alarms](https://github.com/cloudposse/terraform-aws-alb-target-group-cloudwatch-sns-alarms) - Terraform module to create CloudWatch Alarms on ALB Target level metrics.
- [terraform-aws-cloudwatch-flow-logs](https://github.com/cloudposse/terraform-aws-cloudwatch-flow-logs) - Terraform module for enabling flow logs for vpc and subnets.
- [terraform-aws-ecs-cloudwatch-autoscaling](https://github.com/cloudposse/terraform-aws-ecs-cloudwatch-autoscaling) - Terraform module to autoscale ECS Service based on CloudWatch metrics
- [terraform-aws-elasticache-cloudwatch-sns-alarms](https://github.com/cloudposse/terraform-aws-elasticache-cloudwatch-sns-alarms) - Terraform module that configures CloudWatch SNS alerts for ElastiCache
- [terraform-aws-efs-cloudwatch-sns-alarms](https://github.com/cloudposse/terraform-aws-efs-cloudwatch-sns-alarms) - Terraform module that configures CloudWatch SNS alerts for EFS
- [terraform-aws-ecs-cloudwatch-sns-alarms](https://github.com/cloudposse/terraform-aws-ecs-cloudwatch-sns-alarms) - Terraform module to create CloudWatch Alarms on ECS Service level metrics.
- [terraform-aws-ec2-cloudwatch-sns-alarms](https://github.com/cloudposse/terraform-aws-ec2-cloudwatch-sns-alarms) - Terraform module that configures CloudWatch SNS alerts for EC2 instances
- [terraform-aws-sqs-cloudwatch-sns-alarms](https://github.com/cloudposse/terraform-aws-sqs-cloudwatch-sns-alarms) - Terraform module for creating alarms for SQS and notifying endpoints
- [terraform-aws-lambda-cloudwatch-sns-alarms](https://github.com/cloudposse/terraform-aws-lambda-cloudwatch-sns-alarms) - Terraform module for creating a set of Lambda alarms and outputting to an endpoint



## Help

**Got a question?**

File a GitHub [issue](https://github.com/cloudposse/terraform-aws-cloudwatch-agent/issues), send us an [email][email] or join our [Slack Community][slack].

[![README Commercial Support][readme_commercial_support_img]][readme_commercial_support_link]

## Commercial Support

Work directly with our team of DevOps experts via email, slack, and video conferencing. 

We provide [*commercial support*][commercial_support] for all of our [Open Source][github] projects. As a *Dedicated Support* customer, you have access to our team of subject matter experts at a fraction of the cost of a full-time engineer. 

[![E-Mail](https://img.shields.io/badge/email-hello@cloudposse.com-blue.svg)][email]

- **Questions.** We'll use a Shared Slack channel between your team and ours.
- **Troubleshooting.** We'll help you triage why things aren't working.
- **Code Reviews.** We'll review your Pull Requests and provide constructive feedback.
- **Bug Fixes.** We'll rapidly work to fix any bugs in our projects.
- **Build New Terraform Modules.** We'll [develop original modules][module_development] to provision infrastructure.
- **Cloud Architecture.** We'll assist with your cloud strategy and design.
- **Implementation.** We'll provide hands-on support to implement our reference architectures. 



## Terraform Module Development

Are you interested in custom Terraform module development? Submit your inquiry using [our form][module_development] today and we'll get back to you ASAP.


## Slack Community

Join our [Open Source Community][slack] on Slack. It's **FREE** for everyone! Our "SweetOps" community is where you get to talk with others who share a similar vision for how to rollout and manage infrastructure. This is the best place to talk shop, ask questions, solicit feedback, and work together as a community to build totally *sweet* infrastructure.

## Newsletter

Signup for [our newsletter][newsletter] that covers everything on our technology radar.  Receive updates on what we're up to on GitHub as well as awesome new projects we discover. 

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/cloudposse/terraform-aws-cloudwatch-agent/issues) to report any bugs or file feature requests.

### Developing

If you are interested in being a contributor and want to get involved in developing this project or [help out](https://cpco.io/help-out) with our other projects, we would love to hear from you! Shoot us an [email][email].

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!


## Copyright

Copyright © 2017-2019 [Cloud Posse, LLC](https://cpco.io/copyright)



## License 

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.









## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## About

This project is maintained and funded by [Cloud Posse, LLC][website]. Like it? Please let us know by [leaving a testimonial][testimonial]!

[![Cloud Posse][logo]][website]

We're a [DevOps Professional Services][hire] company based in Los Angeles, CA. We ❤️  [Open Source Software][we_love_open_source].

We offer [paid support][commercial_support] on all of our projects.  

Check out [our other projects][github], [follow us on twitter][twitter], [apply for a job][jobs], or [hire us][hire] to help with your cloud strategy and implementation.



### Contributors

|  [![Nikola Velkovski][parabolic_avatar]][parabolic_homepage]<br/>[Nikola Velkovski][parabolic_homepage] |
|---|

  [parabolic_homepage]: https://github.com/parabolic
  [parabolic_avatar]: https://github.com/parabolic.png?size=150



[![README Footer][readme_footer_img]][readme_footer_link]
[![Beacon][beacon]][website]

  [logo]: https://cloudposse.com/logo-300x69.svg
  [docs]: https://cpco.io/docs
  [website]: https://cpco.io/homepage
  [github]: https://cpco.io/github
  [jobs]: https://cpco.io/jobs
  [hire]: https://cpco.io/hire
  [slack]: https://cpco.io/slack
  [linkedin]: https://cpco.io/linkedin
  [twitter]: https://cpco.io/twitter
  [testimonial]: https://cpco.io/leave-testimonial
  [newsletter]: https://cpco.io/newsletter
  [email]: https://cpco.io/email
  [commercial_support]: https://cpco.io/commercial-support
  [we_love_open_source]: https://cpco.io/we-love-open-source
  [module_development]: https://cpco.io/module-development
  [terraform_modules]: https://cpco.io/terraform-modules
  [readme_header_img]: https://cloudposse.com/readme/header/img?repo=cloudposse/terraform-aws-cloudwatch-agent
  [readme_header_link]: https://cloudposse.com/readme/header/link?repo=cloudposse/terraform-aws-cloudwatch-agent
  [readme_footer_img]: https://cloudposse.com/readme/footer/img?repo=cloudposse/terraform-aws-cloudwatch-agent
  [readme_footer_link]: https://cloudposse.com/readme/footer/link?repo=cloudposse/terraform-aws-cloudwatch-agent
  [readme_commercial_support_img]: https://cloudposse.com/readme/commercial-support/img?repo=cloudposse/terraform-aws-cloudwatch-agent
  [readme_commercial_support_link]: https://cloudposse.com/readme/commercial-support/link?repo=cloudposse/terraform-aws-cloudwatch-agent
  [share_twitter]: https://twitter.com/intent/tweet/?text=terraform-aws-cloudwatch-agent&url=https://github.com/cloudposse/terraform-aws-cloudwatch-agent
  [share_linkedin]: https://www.linkedin.com/shareArticle?mini=true&title=terraform-aws-cloudwatch-agent&url=https://github.com/cloudposse/terraform-aws-cloudwatch-agent
  [share_reddit]: https://reddit.com/submit/?url=https://github.com/cloudposse/terraform-aws-cloudwatch-agent
  [share_facebook]: https://facebook.com/sharer/sharer.php?u=https://github.com/cloudposse/terraform-aws-cloudwatch-agent
  [share_googleplus]: https://plus.google.com/share?url=https://github.com/cloudposse/terraform-aws-cloudwatch-agent
  [share_email]: mailto:?subject=terraform-aws-cloudwatch-agent&body=https://github.com/cloudposse/terraform-aws-cloudwatch-agent
  [beacon]: https://ga-beacon.cloudposse.com/UA-76589703-4/cloudposse/terraform-aws-cloudwatch-agent?pixel&cs=github&cm=readme&an=terraform-aws-cloudwatch-agent

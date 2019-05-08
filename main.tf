module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.7.0"
  stage      = "${var.stage}"
  name       = "${var.name}"
  namespace  = "${var.namespace}"
  attributes = ["cloudwatch-agent"]
}

data "template_file" "cloud_init_cloudwatch_agent" {
  template = "${file("${path.module}/templates/cloud_init.yaml")}"

  vars {
    cloudwatch_agent_configuration = "${var.metrics_config == "standard" ? base64encode(data.template_file.cloudwatch_agent_configuration_standard.rendered) : base64encode(data.template_file.cloudwatch_agent_configuration_advanced.rendered)}"
  }
}

data "template_file" "cloudwatch_agent_configuration_advanced" {
  template = "${file("${path.module}/templates/cloudwatch_agent_configuration_advanced.json")}"

  vars {
    aggregation_dimensions      = "${jsonencode(var.aggregation_dimensions)}"
    cpu_resources               = "${var.cpu_resources}"
    disk_resources              = "${jsonencode(var.disk_resources)}"
    metrics_collection_interval = "${var.metrics_collection_interval}"
  }
}

data "template_file" "cloudwatch_agent_configuration_standard" {
  template = "${file("${path.module}/templates/cloudwatch_agent_configuration_standard.json")}"

  vars {
    aggregation_dimensions      = "${jsonencode(var.aggregation_dimensions)}"
    cpu_resources               = "${var.cpu_resources}"
    disk_resources              = "${jsonencode(var.disk_resources)}"
    metrics_collection_interval = "${var.metrics_collection_interval}"
  }
}

data "template_cloudinit_config" "cloud_init_merged" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "userdata_part_cloudwatch.cfg"
    content      = "${data.template_file.cloud_init_cloudwatch_agent.rendered}"
    content_type = "text/cloud-config"
  }

  part {
    filename     = "userdata_part_caller.cfg"
    content      = "${var.userdata_part_content}"
    content_type = "${var.userdata_part_content_type}"
    merge_type   = "${var.userdata_part_merge_type}"
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

resource "aws_iam_role" "ec2_cloudwatch" {
  name = "${module.label.id}"

  assume_role_policy = "${data.aws_iam_policy_document.ec2_cloudwatch.json}"

  tags = {
    Name = "${module.label.id}"
  }
}

data "aws_iam_policy_document" "wildcard_cloudwatch_agent" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeTags",
      "cloudwatch:PutMetricData",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "wildcard_cloudwatch_agent" {
  name = "${module.label.id}"

  role   = "${aws_iam_role.ec2_cloudwatch.id}"
  policy = "${data.aws_iam_policy_document.wildcard_cloudwatch_agent.json}"
}

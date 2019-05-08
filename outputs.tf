output "user_data" {
  description = "The user_data with the cloudwatch_agent configuration in base64 and gzipped"
  value       = "${data.template_cloudinit_config.cloud_init_merged.rendered}"
}

output "role_name" {
  description = "The name of the created IAM role that can be assumed by the instance"
  value       = "${aws_iam_role.ec2_cloudwatch.name}"
}

output "iam_policy_document" {
  description = "The IAM policy document that can be attached to a role policy"
  value       = "${data.aws_iam_policy_document.wildcard_cloudwatch_agent.json}"
}

output "user_data" {
  description = "The user_data with the cloudwatch_agent configuration in base64 and gzipped"
  value       = "${data.template_cloudinit_config.cloud_init_merged.rendered}"
}

output "role_name" {
  description = "The role name that should be attached to the role policy"
  value       = "${aws_iam_role.ec2_cloudwatch.name}"
}

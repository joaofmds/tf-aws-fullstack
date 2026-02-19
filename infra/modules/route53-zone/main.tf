locals {
  merged_tags = merge(
    {
      ManagedBy = "terraform"
    },
    var.tags
  )
}

resource "aws_route53_zone" "this" {
  name = var.domain_name

  comment = var.comment != null ? var.comment : "Hosted zone for ${var.domain_name}"

  tags = merge(local.merged_tags, {
    Name = var.name != null ? var.name : "${var.domain_name}-zone"
  })
}

# Example `complete`

Exemplo completo de uso do módulo `aws-route53-acm-domains` com providers em múltiplas regiões.

## Como usar

```bash
terraform init
terraform plan \
  -var="amplify_app_id=dxxxxxxxxxxxx" \
  -var="amplify_branch_name=main" \
  -var="alb_dns_name=my-alb-123456.us-east-1.elb.amazonaws.com" \
  -var="alb_zone_id=Z35SXDOTRQ7X7K"
```

## Snippet de integração com ALB listener HTTPS

> Este recurso **não** é criado pelo módulo; use em outro stack/módulo que gerencia o ALB.

```hcl
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.backend.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = module.aws_route53_acm_domains.backend_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}
```

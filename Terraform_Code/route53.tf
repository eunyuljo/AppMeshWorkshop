# Route 53 Private Hosted Zone
resource "aws_route53_zone" "dns_hosted_zone" {
  name = "appmeshworkshop.hosted.local"

  vpc {
    vpc_id     = aws_vpc.main.id  # VPC 리소스를 참조
    vpc_region = var.region   # AWS 지역 변수 참조
  }

  comment = "Private hosted zone"
}

# Route 53 Record Set for Crystal
resource "aws_route53_record" "crystal_record_set" {
  zone_id = aws_route53_zone.dns_hosted_zone.zone_id  # Hosted Zone의 ID 참조
  name    = "crystal.appmeshworkshop.hosted.local"    # 레코드 이름
  type    = "A"                                      # A 레코드 타입

  alias {
    name                   = aws_lb.internal_load_balancer.dns_name  # Internal Load Balancer의 DNS 이름
    zone_id                = aws_lb.internal_load_balancer.zone_id   # Internal Load Balancer의 Hosted Zone ID
    evaluate_target_health = false
  }

  depends_on = [aws_lb.internal_load_balancer]  # Internal Load Balancer가 먼저 생성되도록 설정
}

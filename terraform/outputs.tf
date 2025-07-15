output "web1_public_ip" {
  description = "Public IP of Web Server 1"
  value       = aws_instance.web1.public_ip
}

output "web2_public_ip" {
  description = "Public IP of Web Server 2"
  value       = aws_instance.web2.public_ip
}

output "db_public_ip" {
  description = "Public IP of DB Server"
  value       = aws_instance.db.public_ip
}

output "db_private_ip" {
  description = "Private IP of DB Server"
  value       = aws_instance.db.private_ip
}

output "alb_dns_name" {
  description = "DNS name of the Load Balancer"
  value       = aws_lb.app_lb.dns_name
}

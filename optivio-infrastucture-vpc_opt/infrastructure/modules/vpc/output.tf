output "vpc_id" {
  value = aws_vpc.optivio.id
}
output "main_Public_subnet_1" {
  value = aws_subnet.main-public-1.id
}

output "main_Public_subnet_2" {
  value = aws_subnet.main-private-2.id
}

output "main_Private_subnet_1" {
  value = aws_subnet.main-private-1.id
}

output "main_Private_subnet_2" {
  value = aws_subnet.main-private-2.id
}
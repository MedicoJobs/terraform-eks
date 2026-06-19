resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-nat-eip"
  })
}

resource "terraform_data" "internet_gateway_dependency" {
  input = var.internet_gateway_id
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_id

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-nat"
  })

  depends_on = [terraform_data.internet_gateway_dependency]
}

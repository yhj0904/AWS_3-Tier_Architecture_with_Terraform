resource "tls_private_key" "key_pair" {
  algorithm = var.key_pair_algorithm
  rsa_bits  = var.key_pair_rsa_bits
}

resource "aws_key_pair" "key_pair" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.key_pair.public_key_openssh

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-KeyPair"
    }
  )
}

resource "local_file" "ssh_key" {
  filename        = "${aws_key_pair.key_pair.key_name}.pem"
  content         = tls_private_key.key_pair.private_key_pem
  file_permission = "0400"
}
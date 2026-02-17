resource "aws_iam_role" "ec2_ssm_role" {
  name = "healthcare-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    project = "healthcare"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "healthcare-ec2-profile"
  role = aws_iam_role.ec2_ssm_role.name
}


resource "aws_iam_service_linked_role" "dms" {
  aws_service_name = "dms.amazonaws.com"
}
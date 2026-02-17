resource "aws_launch_template" "app_lt" {
  name_prefix   = "healthcare-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
yum update -y
yum install -y nginx git

systemctl start nginx
systemctl enable nginx

cd /tmp
git clone https://github.com/startbootstrap/startbootstrap-creative.git

rm -rf /usr/share/nginx/html/*
cp -r startbootstrap-creative/* /usr/share/nginx/html/

chown -R nginx:nginx /usr/share/nginx/html
EOF
  )
}

resource "aws_autoscaling_group" "app_asg" {
  desired_capacity = 1
  min_size         = 1
  max_size         = 4

  vpc_zone_identifier = [
    aws_subnet.app_az1.id,
    aws_subnet.app_az2.id
  ]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]
}
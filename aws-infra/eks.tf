module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "prod-eks-cluster"
  cluster_version = "1.34"

  # ✅ Enable public API access for GitHub CI
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"] # restrict later

  # ✅ Use your custom VPC
  vpc_id = aws_vpc.main.id

  # ✅ Worker nodes in PRIVATE APP subnets
  subnet_ids = [
    aws_subnet.app_az1.id,
    aws_subnet.app_az2.id
  ]

  eks_managed_node_groups = {
    app_nodes = {
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 3
      desired_size = 1

      subnet_ids = [
        aws_subnet.app_az1.id,
        aws_subnet.app_az2.id
      ]
    }
  }

  enable_irsa = true

  tags = {
    project     = "healthcare"
    Environment = "prod"
  }
}
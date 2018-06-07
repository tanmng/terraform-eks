#------------------------------------------------------------------------------
# EKS Specific variables
#------------------------------------------------------------------------------
variable eks_cluster_name {
  description = "Name to set to the EKS cluster"
}

variable eks_subnets {
  description = "List of subnets in which we will run our EKS worker node"
  type        = "list"
}

#------------------------------------------------------------------------------
# General variable
#------------------------------------------------------------------------------
variable global_vpc_id {
  description = "ID of the VPC in which we want to set up EKS"
  type        = "string"
}

variable eks_ec2_key {
  description = "Name of the EC2 keypair that we wish to set onto our instances"
  type        = "string"
}

variable eks_ec2_ami {
  description = "AMI of the image that we wish to use to run our EKS instances"
  type        = "string"
  default     = ""
}

#------------------------------------------------------------------------------
# Tagging variables
#------------------------------------------------------------------------------
variable eks_tag_product {
  description = "Assigned in design phase. Is likely to span multiple AWS accounts."
  type        = "string"
}

variable eks_tag_sub_product {
  description = "Assigned in design phase. Used where an AWS account runs more than one service."
  type        = "string"
}

variable eks_tag_contact {
  description = "Specifies the group email address of the team responsible for the support of this resource."
  type        = "string"
}

variable eks_tag_cost_code {
  description = "Track costs to align with various costing sources: cost centre, project code, PnL budget."
  type        = "string"
}

variable eks_tag_environment {
  description = "Environment consists of 2 segments, separated by a dash. First segment: environment category (prod, dev or test). Second segment: Free form name to further describe the function of the environment."
  type        = "string"
}

variable eks_tag_cpm_backup {
  description = "Cloud Protection Manager backup policy where CPM has been configured to scan resources in an account looking for this tag name."
  type        = "string"
  default     = ""
}

variable eks_tag_orchestration {
  description = "Path to Git for control repository."
  type        = "string"
}

variable eks_tag_description {
  description = "A tag to describe what the resource is/does, such as the applications it runs."
  type        = "string"
  default     = "eks"
}

#------------------------------------------------------------------------------
# Security Group related
#------------------------------------------------------------------------------

variable eks_cp_to_wn_from_port {
  description = "The From port for the rules connecting our control plane to worker node"
  default     = 1024
}

variable eks_cp_to_wn_to_port {
  description = "The to port for the rules connecting our control plane to worker node"
  default     = 65535
}

variable eks_allow_worker_node_all_egress {
  description = "Specify whether you wish to allow worker node egress everwhere on all ports"
  default     = true
}

variable eks_workernode_additional_sgs {
  description = "List of additional security that you wish to set onto our worker node instaces, might try Bastion source"
  default     = []
}

#------------------------------------------------------------------------------
# Autoscaling related
#------------------------------------------------------------------------------
variable eks_workernode_asg_min {
  description = "Min size of the ASG running worker node for EKS cluster"
  default     = 1
}

variable eks_workernode_asg_max {
  description = "Max size of the ASG running worker node for EKS cluster"
  default     = 2
}

variable eks_workernode_asg_desired_size {
  description = "Desired size of the ASG running worker nodes for our EKS cluster"
  default     = 2
}

variable eks_instance_type {
  default = "m5.large"
}

variable eks_ami_mapping {
  description = "Mapping from region to the EKS optimized AMI, you can update this but it is probably OK to use the one in here"
  type        = "map"

  default = {
    us-east-1 = "ami-dea4d5a1"
    us-west-2 = "ami-73a6e20b"
  }
}

#------------------------------------------------------------------------------
# Whether we wish to use local workstation to grant the instance to join our cluster
#------------------------------------------------------------------------------
variable eks_grant_from_ws {
  description = "Whether we wish to use local workstation to grant the instance to join our cluster"
  default     = false
}

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
# Tagging variables
#------------------------------------------------------------------------------
variable eks_tag_environment {
  description = "Environment tag of the EKS deployment"
  type        = "string"
}

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

variable eks_additional_asg_tags {
  description = "A list of maps that contain custom tags to add to the eks ASG and possibly the instances."
  type        = "list"
  default     = []
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

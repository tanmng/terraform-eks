# HS Terraform EKS

A module to set up EKS with Terraform >:)

## Note on AWS provider

[Terraform AWS
provider](https://github.com/terraform-providers/terraform-provider-aws) started
supporting Amazon EKS from June 5 2018 on release `1.22.0` ([related ChangeLog](https://github.com/terraform-providers/terraform-provider-aws/blob/master/CHANGELOG.md#1220-june-05-2018), so we include
a requirement for this in `terraform.tf`. Please make sure you upgrade to this
version or later of the provider.

## Note on Instance type

According to the [values provided by
AWS](https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-06-05/amazon-eks-nodegroup.yaml), we 
will have to set the max number of pods that we can run on a node. This is done
by using the mapping stored in `local.max_pod_per_node`. This added the benefit
of forcing any user to set the instance to the allowed values.

## Note on Network availability

Since right now (June 6th 2018), EKS does not support `us-east-1a`, please make
sure none of the subnets you provide in `eks_subnets` is from that AZ

## Note on VPC taggings

Please note that once we use any subnets for EKS, [AWS will add some tags on
it](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html). This
might cause a conflict with the module where we set up the VPC (ie. the VPC
module will detect an unknown tag and try remove it)

If you are setting up the VPC using [Core engineering VPC module](https://gitlab.et-scm.com/elsevier-core-engineering/rp-terraform-vpc)
please consider using the variable `vpc_additional_tags` to set up the tags
beforehand and void any possible conflicts.

An example:
```terraform
module vpc {
  source = "git::ssh://git@gitlab.et-scm.com/elsevier-core-engineering/rp-terraform-vpc.git?ref=2.4.1"

  vpc_name                    = "${var.vpc_name}"
  vpc_subnet                  = "${var.global_vpc_subnet}"
  vpc_tag_product             = "${var.global_tag_product}"
  vpc_tag_sub_product         = "${var.global_tag_sub_product}"
  vpc_tag_contact             = "${var.global_contact_tag}"
  vpc_tag_cost_code           = "${var.global_tag_cost_code}"
  vpc_tag_environment         = "${var.global_tag_environment}"
  vpc_tag_orchestration       = "${var.global_tag_orchestration}"
  vpc_tag_description         = "Playground for Openshift"
  global_private_subnets      = "${var.global_private_subnets}"
  global_public_subnets       = "${var.global_public_subnets}"
  global_availability_zones   = "${var.global_availability_zones}"
  global_elsevier_cidr_blocks = "${var.global_elsevier_cidr_blocks}"

 # Callan is your cluster name, you can use multiple tags
  vpc_additional_tags = "${map(
    "kubernetes.io/cluster/callahan", "shared"
  )}"
}
```

## Note on Security Group

According to [AWS documentation on EKS security
group](https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html),
you can set up the security group for worker nodes and control plane according
to the minimum requirements or the recommended way.

**Since you will be running applications on these worker node, you will want to
set additional security group(s) on them to grant the access for those
application**

The module try to accommodate all possible settings that you might wish to have.
Even including the ability to set additional security group onto the node and
plane instances.

In particular, you can control whether the worker node has egress connection
everywhere or not, which port range is allowed for communication between control
plane and worker node.

The default setting of the module follow the recommended set up as per AWS
guide, but you can always switch to other settings. As mentioned earlier, you
can even add more security groups onto the instances to customize things even
more according to your needs.

These are done via the following variables
* `eks_allow_worker_node_all_egress` (default `true`)
* `eks_cp_to_wn_from_port` (default `1024`)
* `eks_cp_to_wn_to_port` (default `65355`)

Please note that if we follow **ONLY the rule for worker node**, they won't even
be able to download files from S3, so we had to relaxed the rule a little and
let it HTTPS everywhere all the time.

## Note on AMI

According to [AWS
guide](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html),
we should use the EKS-optimized AMI. Unfortunately, the AMI is being rolled out
quite slowly. So, we have a variable that set up the mapping between the region
in which you are rolling out EKS with the AMI that we will be using for the
instance.

If you wish to use your own AMI, you can do so by overwriting this `mapping`
action with the variable `eks_ec2_ami`. Otherwise, we will simply map from the
region to the AMI via the map (no pun intended) in variable `eks_ami_mapping`

Please note that the maintainer of this module will try to keep the list as
always up-to-date, but if for some reason you think it's out of date, please
feel free to provide the correct value via that variable, and the module will
look up correctly. Or even better yet, you can just specify the AMI directly
with `eks_ec2_ami`

## Usage

An example of how to use this. Please make sure that the list of subnets include
2 private subnets in support AZ of EKS

```terraform
module eks {
  source                = "git://git@gitlab.et-scm.com:NGUYEN1/hs-terraform-eks.git?ref=tag"

  eks_cluster_name      = "callahan"
  eks_tag_product       = "${var.global_tag_product}"
  eks_tag_sub_product   = "${var.global_tag_sub_product}"
  eks_tag_contact       = "${var.global_contact_tag}"
  eks_tag_cost_code     = "${var.global_tag_cost_code}"
  eks_tag_environment   = "${var.global_tag_environment}"
  eks_tag_orchestration = "${var.global_tag_orchestration}"
  eks_tag_description   = "God Save The Queen"

  eks_ec2_key   = "${var.global_ec2_keypair}"
  eks_subnets   = ["${split(",", module.vpc.private_subnets)}"]
  global_vpc_id = "${module.vpc.vpc_id}"
}
```

## Variables

### Required variables

* `eks_cluster_name` - Name to set to the EKS cluster
* `eks_ec2_key` - Name of the EC2 keypair that we wish to set onto our instances
* `eks_subnets` - List of subnets in which we will run our EKS worker node
* `eks_tag_contact` - Specifies the group email address of the team responsible for the support of this resource.
* `eks_tag_cost_code` - Track costs to align with various costing sources: cost centre, project code, PnL budget.
* `eks_tag_environment` - Environment consists of 2 segments, separated by a dash. First segment: environment category (prod, dev or test). Second segment: Free form name to further describe the function of the environment.
* `eks_tag_orchestration` - Path to Git for control repository.
* `eks_tag_product` - Assigned in design phase. Is likely to span multiple AWS accounts.
* `eks_tag_sub_product` - Assigned in design phase. Used where an AWS account runs more than one service.
* `global_vpc_id` - ID of the VPC in which we want to set up EKS

### Optional variables

* `eks_allow_worker_node_all_egress` - Specify whether you wish to allow worker node egress everwhere on all ports, default to `True`
* `eks_ami_mapping` - Mapping from region to the EKS optimized AMI, you can update this but it is probably OK to use the one in here, default to `{u'us-west-2': u'ami-73a6e20b', u'us-east-1': u'ami-dea4d5a1'}`
* `eks_cp_to_wn_from_port` - The From port for the rules connecting our control plane to worker node, default to `1024`
* `eks_cp_to_wn_to_port` - The to port for the rules connecting our control plane to worker node, default to `65535`
* `eks_ec2_ami` - AMI of the image that we wish to use to run our EKS instances, default to ``
* `eks_grant_from_ws` - Whether we wish to use local workstation to grant the instance to join our cluster, default to `False`
* `eks_instance_type` - , default to `m5.large`
* `eks_tag_cpm_backup` - Cloud Protection Manager backup policy where CPM has been configured to scan resources in an account looking for this tag name., default to ``
* `eks_tag_description` - A tag to describe what the resource is/does, such as the applications it runs., default to `eks`
* `eks_workernode_additional_sgs` - List of additional security that you wish to set onto our worker node instaces, might try Bastion source, default to `[]`
* `eks_workernode_asg_desired_size` - Desired size of the ASG running worker nodes for our EKS cluster, default to `2`
* `eks_workernode_asg_max` - Max size of the ASG running worker node for EKS cluster, default to `2`
* `eks_workernode_asg_min` - Min size of the ASG running worker node for EKS cluster, default to `1`

## Output Variables

* `kubctl_conf_base64` - Base64 encoded content for kubectl config file, you can use it to connect to EKS
* `worker_node_sg` - ID of the security group we created for our worker node, you can use it to filter out the instances that you need

## Author
For any complains, please feel free to hit the following moron

* [Tan Nguyen t.nguyen@elsevier.com](mailto:t.nguyen@elsevier.com) (another
    address [tan.mng90@gmail.com](mailto:tan.mng90@gmail.com))

If the module is too bad, you can always fork it and make it better as well ¯\\\_(ツ)\_/¯

## Todo

* Better security design (potentially?)

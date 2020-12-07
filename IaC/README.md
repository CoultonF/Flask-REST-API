# tprj/IaC
Directory for holding Infrastructure-as-Code assets such as CloudFormation stacks, Kubernetes manifests, etc. In practice, you are likely to further organize these by tool/process.

    .
    ├── eks                       # Managing EKS cluster
    │   ├── eks-start.sh          # Automatically start the EKS stack on AWS us-east-1
    │   └── eks-delete.sh         # Delete EKS stack
    └── ...


AWS credentials file must be entered as ~/.aws/credentials

[default] \
aws_access_key_id= \
aws_secret_access_key= \
aws_session_token=

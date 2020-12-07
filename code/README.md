# tprj/code
Directory for holding program code. For simplicity, place your container's entire content here though in a realistic scenario, you are more likely to marshall the contents of each container at build time.

    .
    ├── db                    # Code for the docker db pod on port setup and CloudFormation Stack
    │   ├── start.sh          # Automatically start everything for db pods on AWS us-east-1 - to be ran inside the db folder.
    │   └── delete.sh         # Delete docker containers and remove CloudFormation stack for dynamo
    └── ...
    
Must have AWS credentials stored as per previous implementations in ~/.aws/credentials

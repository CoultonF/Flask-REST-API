# REST API using Flask on Minikube or AWS Distributed Microservices Architecture load tested with Gatling.io

    .
    ├── API                         # Communicate with Cluster
    |   ├── Gatling                 # Gatling Code to Stress Test Cluster
    |   ├── api.mak                 # Basic Running CURLs for Testing
    |   └── api-proxies.mak         # Basic Running CURLs for Gatling Recorder
    ├── IaC                         # Managing Cluster
    |   ├── EKS                     # EKS Cluster
    |   ├── MK                      # Minikube Cluster
    |   ├── docker.mak              # Minikube/EKS Docker Containers
    |   ├── dynamo.mak              # AWS DynamoDB
    |   └── k8s.mak                 # Minikube/EKS Kubernetes Cluster
    ├── code                        # REST API, Cluster, and Docker Build Code
    |   ├── cart                    # Cart REST API
    |   ├── customer                # Customer REST API
    |   ├── db                      # DB REST API
    |   ├── history                 # History REST API
    |   ├── misc                    # Cluster, Gateway, and Database Configuration 
    |   ├── returns                 # Returns REST API
    |   └── warehouse               # Warehouse REST API
    └── docs                        # Additional Documentation
## Project Requirements

Project requires yq and jq to be installed on shell. <br>
https://github.com/mikefarah/yq <br>
https://stedolan.github.io/jq/download/ <br>
<br>
Maven <br> 
https://maven.apache.org/ <br>
<br>
Java 1.8 SDK <br>
https://www.oracle.com/ca-en/java/technologies/javase/javase-jdk8-downloads.html <br>

# Docker for AWS swarm auto login to AWS ECR registry

_-- Using AWS ECR with a Docker Swarm stack on AWS_

When creating a docker swarm stack on AWS, you can want to use the AWS ECR service as your docker images registry.

## The problem

The ECR authentication tokens are only valid for 12 hours, so the docker swarm services won't be able to scale on another node after the expire date.

## The solution

This docker image renews the ECR token each 4h and update all the services using an ECR image.

## Usage as a swarm service (recommended)

```bash
docker service create \
    --name aws_ecr_auth \
    --mount type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock \
    --constraint 'node.role == manager' \
    --restart-condition 'none' \
    --detach=false \
    mroca/swarm-aws-ecr-auth
```

## Usage as a swarm container

```bash
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock --name aws_ecr_auth mroca/swarm-aws-ecr-auth
```

## Configuration

By default, this image authenticates the swarm manager onto the AWS ECR for the current region. You can configure the ECR region by setting the `AWS_REGION` env variable : `-e AWS_REGION=eu-west-3`, for example.

## Requirements

- The swarm stack must have been created with the https://docs.docker.com/docker-for-aws/ CloudFormation template.
- The swarm managers must have the `AmazonEC2ContainerRegistryReadOnly` policy.

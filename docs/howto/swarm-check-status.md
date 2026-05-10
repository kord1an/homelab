# Swarm – basic status checks

## Check swarm status on manager

    docker info | grep -i swarm
    docker node ls

## Inspect node

    docker node inspect <NODE_NAME> --pretty

## Check services

    docker service ls
    docker service ps <SERVICE_NAME>
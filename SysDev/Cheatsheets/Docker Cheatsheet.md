# Docker Cheatsheet

Collected from quickref and other sources.

## Podman as default

```bash
alias docker=podman
```

## Containers

### Create and run container in background

```bash
docker run -d -p 80:80 docker/getting-started
```

### Create and run container in foreground

```bash
docker run -it -p 8001:8080 --name my-nginx nginx
```

### Rename container

```bash
docker rename my-nginx my-nginx
```

### Remove container

```bash
docker rm my-nginx
```

### Update container

```bash
docker update --cpu-shares 512 -m 300M my-nginx
```

### Container process tasks

| Command                        | Description                       |
| ------------------------------ | --------------------------------- |
| `docker start my-nginx`        | Starting                          |
| `docker stop my-nginx`         | Stopping                          |
| `docker restart my-nginx`      | Restarting                        |
| `docker pause my-nginx`        | Pausing                           |
| `docker unpause my-nginx`      | Unpausing                         |
| `docker wait my-nginx`         | Blocking a Container              |
| `docker kill my-nginx`         | Sending a SIGKILL                 |
| `docker attach my-nginx`       | Connecting to an Existing Container|

### Container process stats
| Command                  | Description                     |
|--------------------------|---------------------------------|
| `docker ps`              | List running containers         |
| `docker ps -a`           | List all containers             |
| `docker logs my-nginx`   | Container Logs                  |
| `docker inspect my-nginx`| Inspecting Containers           |
| `docker events my-nginx` | Containers Events               |
| `docker port my-nginx`   | Public Ports                    |
| `docker top my-nginx`    | Running Processes               |
| `docker stats my-nginx`  | Container Resource Usage        |
| `docker diff my-nginx`   | Lists the changes made to a container. |

## Images

### Image creation

| Command                             | Description                           |
|-------------------------------------|---------------------------------------|
| `docker create [options] IMAGE`     | Create a container from an image      |
| `-a`, `--attach`                    | Attach stdout/err                     |
| `-i`, `--interactive`               | Attach stdin (interactive)            |
| `-t`, `--tty`                       | Pseudo-tty                            |
| `--name NAME`                       | Name your container                   |
| `-p`, `--publish 5000:5000`         | Port mapping (host:container)         |
| `--expose 5432`                     | Expose a port to containers           |
| `-P`, `--publish-all`               | Publish all ports                     |
| `--link container:alias`            | Linking to another container          |
| `-v`, `--volume \`pwd\`:/app'       | Mount a volume (absolute paths needed)|
| `-e`, `--env NAME=hello`            | Set environment variables             |

- Example: `$ docker create --name my_redis --expose 6379 redis:3.0.2`

### Image operations

| Command                                | Description                                      |
|----------------------------------------|--------------------------------------------------|
| `docker images`                        | Listing images                                  |
| `docker rmi nginx`                     | Removing an image                               |
| `docker load < ubuntu.tar.gz`          | Loading a tarred repository                     |
| `docker load --input ubuntu.tar`       | Loading a tarred repository                     |
| `docker save busybox > ubuntu.tar`     | Save an image to a tar archive                  |
| `docker history`                       | Showing the history of an image                 |
| `docker commit nginx`                  | Save a container as an image.                   |
| `docker tag nginx eon01/nginx`         | Tagging an image                                |
| `docker push eon01/nginx`              | Pushing an image                                |


### Image build

| Command                                          | Description                               |
|--------------------------------------------------|-------------------------------------------|
| docker build .                                   | Build an image from the current directory |
| docker build github.com/creack/docker-firefox    | Build an image from a GitHub repository  |
| docker build - < Dockerfile                      | Build an image from a Dockerfile          |
| docker build - < context.tar.gz                  | Build an image from a tarred context      |
| docker build -t eon/my-nginx .                   | Build and tag an image                    |
| docker build -f myOtherDockerfile .              | Build from a specific Dockerfile          |
| curl example.com/remote/Dockerfile \| docker build -f - . | Build from a remote Dockerfile   |

## Networking

### Network manipulation

| Command                                      | Description                                         |
|----------------------------------------------|-----------------------------------------------------|
| `docker network rm MyOverlayNetwork`         | Removing a network                                 |
| `docker network ls`                          | Listing networks                                   |
| `docker network inspect MyOverlayNetwork`    | Getting information about a network                |
| `docker network connect MyOverlayNetwork nginx` | Connecting a running container to a network      |
| `docker run -it -d --network=MyOverlayNetwork nginx` | Connecting a container to a network when it starts |
| `docker network disconnect MyOverlayNetwork nginx` | Disconnecting a container from a network         |


### Network creation

| Command                                                                                                       | Description                                                        |
|---------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| `docker network create -d overlay MyOverlayNetwork`                                                          | Create an overlay network                                          |
| `docker network create -d bridge MyBridgeNetwork`                                                            | Create a bridge network                                            |
| `docker network create -d overlay --subnet=192.168.0.0/16 --subnet=192.170.0.0/16 --gateway=192.168.0.100 --gateway=192.170.0.100 --ip-range=192.168.1.0/24 --aux-address="my-router=192.168.1.5" --aux-address="my-switch=192.168.1.6" --aux-address="my-printer=192.170.1.5" --aux-address="my-nas=192.170.1.6" MyOverlayNetwork`   | Create an overlay network with advanced settings                |

## Cleaning

| Command                                     | Description                                                      |
|---------------------------------------------|------------------------------------------------------------------|
| `docker system prune`                       | Cleans up dangling images, containers, volumes, and networks     |
| `docker system prune -a`                    | Remove stopped containers and all unused images                 |
| `docker stop $(docker ps -a -q)`            | Stop all running containers                                    |
| `docker container prune`                    | Delete stopped containers                                      |
| `docker image prune`                        | Remove all dangling images (not tagged and not in use)         |
| `docker image prune -a`                     | Remove all images not used by existing containers              |
| `docker volume prune`                       | Remove all volumes not used by at least one container          |
| `docker stop -f $(docker ps -a -q)`         | Stopping all containers                                        |
| `docker rm -f $(docker ps -a -q)`           | Removing all containers                                        |
| `docker rmi -f $(docker images -q)`         | Removing all images                                            |


## Docker Hub

| Command                           | Description                            |
|-----------------------------------|----------------------------------------|
| `docker search search_word`       | Search Docker Hub for images          |
| `docker pull user/image`           | Downloads an image from Docker Hub    |
| `docker login`                    | Authenticate to Docker Hub            |
| `docker push user/image`           | Uploads an image to Docker Hub        |

## Misc

| Command                              | Description                              |
|--------------------------------------|------------------------------------------|
| `docker login`                       | Login to the default Docker Hub registry |
| `docker login localhost:8080`        | Login to a specific registry             |
| `docker logout`                      | Logout from the default Docker Hub registry |
| `docker logout localhost:8080`       | Logout from a specific registry          |
| `docker search nginx`                | Search for images in Docker Hub          |
| `docker search nginx --stars=3 --no-trunc busybox` | Search with specific options    |
| `docker pull nginx`                  | Pull an image from Docker Hub            |
| `docker pull eon01/nginx localhost:5000/myadmin/nginx` | Pull from a specific registry |
| `docker push eon01/nginx`            | Push an image to Docker Hub              |
| `docker push eon01/nginx localhost:5000/myadmin/nginx` | Push to a specific registry  |


- [OWASP Docker Security Guide](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- [Docker CLI Guide](https://docs.docker.com/engine/reference/commandline/cli/)
- [Comprehensive Guide](https://github.com/wsargent/docker-cheat-sheet)

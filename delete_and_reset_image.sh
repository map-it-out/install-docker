# Stop all running Docker containers
docker stop $(docker ps -a -q)

# Remove all Docker containers
docker rm $(docker ps -a -q)

# Remove all Docker images
docker rmi $(docker images -q)

# Remove all Docker volumes
docker volume rm $(docker volume ls -q)
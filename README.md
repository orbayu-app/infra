## Orbayu Infrastructure

### Requirements:

- `docker` with `docker compose`

### First setup:

Add permissions to run scripts:
```bash
chmod +x ./run/up.sh
chmod +x ./run/down.sh
```

Copy environment variables and set values if needed:
```bash
cp .env.example .env
```

### How to run project:

```bash
./run/up.sh
```

This command will clone project's code if needed and start the infrastructure

### Description of environment variables:

- `COMPOSE_PROJECT_NAME` (= `orbayu` by default)
    
    > Name of the docker-compose project, it is used to prefix container names 
    and network names. It is recommended to set a unique name for each project 
    to avoid conflicts between projects.

- `PROJECT_PATH` (= `./project` by default)
  
    > Path to the directory where the project's code is located.
    It is used to mount the project directory to the container.
    You can set to path outside the infrastructure directory
    e.g. `../api` and `up.sh` script clone the project to the path if it is empty.

- `REPOSITORY_URL`
  
    > URL of the git repository to clone the project code from. It is used by `up.sh`

- `NGINX_PORT` (= `8080` by default)
  
    > Port to expose the nginx container. It is recommended to set a unique 
    port for each project to avoid conflicts between projects.


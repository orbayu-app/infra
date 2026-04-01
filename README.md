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

- `EXTERNAL_NETWORK` (= `docker_external` by default)

    > Name of the external Docker network. Must match the network
    where your external Nginx reverse proxy runs.

### External Nginx (reverse proxy)

The project uses an external Nginx to proxy requests to the application.
Both must be on the same Docker network.

#### 1. Create external Docker network (once)

```bash
docker network create docker_external
```

Set a different name in `.env` if needed:
```bash
EXTERNAL_NETWORK=your_network_name
```

#### 2. Generate SSL certificate (once)

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /srv/certs/orbayu.test.key \
  -out /srv/certs/orbayu.test.crt
```

Use `orbayu.test` as Common Name when asked.

Trust the certificate on macOS:
1. Open Keychain Access
2. File > Import Items > select `orbayu.test.crt`
3. Add to System keychain
4. Double-click the cert > Trust > Always Trust

#### 3. Add hostname to /etc/hosts

```bash
echo "127.0.0.1 orbayu.test" | sudo tee -a /etc/hosts
```

#### 4. Configure external Nginx

Add a server block to your external Nginx config:

```nginx
server {
    listen 443 ssl http2;
    server_name orbayu.test;

    ssl_certificate /srv/certs/orbayu.test.crt;
    ssl_certificate_key /srv/certs/orbayu.test.key;

    resolver 127.0.0.11 valid=30s ipv6=off;

    location / {
        set $upstream http://orbayu-nginx:80;
        proxy_pass $upstream;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Restart external Nginx after changes:
```bash
docker restart your_nginx_container
```


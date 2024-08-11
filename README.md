# servmon

Install using curl:

```sh
curl -fsSL https://servmon.notkamui.com/install.sh | sh
```

## Creating a new service

Here is a simple walkthrough to create a service which will host a static webpage.

### The web proxy

First, you need to make sure that the web-proxy service is running. 
The configuration should have been created automatically upon servmon's installation.
If you don't have it anymore, you can get it [here](https://github.com/notKamui/servmon/tree/main/web-proxy).

To start it, you can run:

```sh
servmon start web-proxy
```

The web-proxy actually contains two services:
- the actual nginx proxy
- an acme companion instance which will manage your SSL certificates for you.

It also declares a external network `web-proxy` based on the default bridge. All your services should belong to this network.

### The webpage

Say you want to serve an `index.html` (the content isn't relevant for this tutorial) thanks to an nginx server.

Simply create a new folder `webpage` (or anything you want) within the `~/services` directory, and inside it, create a new `docker-compose.yml` file.
Additionally, alongside the compose file, create a folder which will hold the static assets you want to serve (the `index.html`).

The directory tree should look something like this:

```
$HOME/services/
  - web-proxy/
    - docker-compose.yml
  - webpage/
    - docker-compose.yml
    - assets/
      - index.html
      - favicon.ico
```

Here is an example of what the docker compose file should look like:

```yml
version: "3"
services:
  webpage:
    image: nginx
    container_name: webpage
    environment:
      - VIRTUAL_HOST=yourdomain.com,www.yourdomain.com
      - LETSENCRYPT_HOST=yourdomain.com,www.yourdomain.com
    volumes:
      - ./assets/:/usr/share/nginx/html:ro
    restart: always
    networks:
      - web-proxy

networks:
  web-proxy:
    name: web-proxy
    external: true
```

Notably, at the bottom of the file, we re-declare the `web-proxy` external network, so that we can make the `webpage` service a part of it.

Also note the two environment variables: VIRTUAL_HOST and LETSENCRYPT_HOST. They should probably always hold the same value. 
They are both lists of domains and/or subdomains, comma-separated, that you want to assign to the given service.

This configuration means that as long as, in your DNS records, you have an A record pointing to your server's IP (for `yourdomain.com`)
and a `www` CNAME record pointing to `yourdomain.com`, clients will be able to access your website at `yourdomain.com` and `www.yourdomain.com`

You can now start the service, congratulations !

```sh
servmon start webpage # name of the folder which contains the config files
```

## Help

```
Usage: $0 [list|start|stop|restart|status|edit|monitor|help] [service]
> list: list all known services (does not require a service name)
> start: starts the service
> stop: stops the service
> restart: restarts the service
> status: shows the status of the service
> edit: edits the service configuration
> monitor: uses lazydocker monitoring (lazydocker must be installed)
> help: shows this message
```

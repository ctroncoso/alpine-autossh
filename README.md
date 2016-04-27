# alpine-autossh

## Disclaimer
alpine-autossh hasn't been tested nor reviewed. Forks and issues are welcome. 


## Overview
alpine-autossh is a small lightweight (8.5MB) image that attempts to provide a secure way to establish an SSH Tunnel without including your keys in the image itself or linking to the host .


## Situation.
Server A is running a VPN with a service on localhost:8080. Server X, Y and Z needs access to the service on server A.

A container (alpine-autossh) makes a persistent SSH connection to Server A, and exposes port 8080 locally.

Servers X, Y and Z can now connect to the container and use it as proxy.

## Typical use
Using alpine-autossh is a 3 step process:

1. Create a network
2. Starting the container
3. Configuring the container.

### Creating a network.

Create a docker network. We will run alpine-autossh in this network.

```
$ docker network create mylink
9266804c6b92d3c290438af5928e58e42b53677e47eface589a008a86ea0f65d

$ docker network ls
NETWORK ID          NAME                                     DRIVER
......
9266804c6b92        mylink                                   bridge
......
```
### Starting the container.
Now, let's use a docker-compose file to start it up. 
The command should be in the form `user@server` followed by any option SSH may accept. In this case, a tunnel. 
The network option declares the default network as external, so it expect `mylink` to exist. 
```yaml
version: '2'
services:
  link:
    image: ctroncoso/alipine-autossh
    container_name: link
    restart: always
    command: someuser@vpn.myserver.com -L 0.0.0.0:8080:localhost:8080
    environment:
      - "AUTOSSH_PORT=0"
    expose:
      - "8080"

networks:
  default:
    external: 
      name: mylink
```


Let's start it.
```
$ docker-compose up
Creating alpineautossh_link_1
Attaching to alpineautossh_link_1
link_1  | Please copy key files to container's /payload folder
link_1  | i.e.: docker cp id_rsa this_container:/payload/
link_1  | Please copy key files to container's /payload folder
link_1  | i.e.: docker cp id_rsa this_container:/payload/
```

The container is now expecting the private key.

### Configuring the container.
Just copy the private key to the payload folder of the container. 
```bash
docker cp ~/.ssh/id_rsa $(docker-compose ps -q link):/payload
```

```
link_1  | Please copy key files to container's /payload folder
link_1  | i.e.: docker cp id_rsa this_container:/payload/
link_1  | Moving keys...
link_1  | Everything OK. Launching.
link_1  | autossh someuser@vpn.myserver.com -L 0.0.0.0:8080:localhost:8080 -N
link_1  | 2016/04/23 10:55:02 autossh[1]: short poll time: adjusting net timeouts to 5000
link_1  | 2016/04/23 10:55:02 autossh[1]: starting ssh (count 1)
link_1  | 2016/04/23 10:55:02 autossh[1]: ssh child pid is 17
link_1  | Warning: Permanently added 'vpn.myserver.com,nnn.nnn.nnn.nnn' (RSA) to the list of known hosts.
```

## TODO
-	Work on README

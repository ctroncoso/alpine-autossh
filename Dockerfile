FROM alpine:3.6
MAINTAINER "Carlos Troncoso Phillips"

RUN    echo "@community http://dl-4.alpinelinux.org/alpine/v3.6/community/" >> /etc/apk/repositories \
	&& apk add --update autossh@community \
	&& rm -rf /var/lib/apt/lists/*

ENV \
	AUTOSSH_LOGFILE=/dev/stdout \
	AUTOSSH_GATETIME=30         \
	AUTOSSH_POLL=10             \
	AUTOSSH_FIRST_POLL=30       \
	AUTOSSH_PORT=13000           
	# AUTOSSH_DEBUG=1             \
	# AUTOSSH_LOGLEVEL=1          \

ADD docker-entrypoint.sh /usr/local/bin
	

ENTRYPOINT [ "docker-entrypoint.sh" ]

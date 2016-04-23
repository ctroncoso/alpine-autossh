#!/bin/sh

KEY_LOCATION=/root/.ssh
PRIV_KEY=id_rsa
# PUB_KEY=id_rsa.pub

#check if needed folders exist.

#payload folder
if [[ ! -d /payload ]]; then
	mkdir /payload
fi

if [[ ! -d /root/.ssh ]]; then
	mkdir /root/.ssh
	chmod 600 /root/.ssh
	cat > /root/.ssh/config <<-ConfigHD
	Host    *
	        UserKnownHostsFile        /dev/null
	        StrictHostKeyChecking     no
	        TCPKeepAlive              no
	        ServerAliveInterval       5
	        ServerAliveCountMax       3
	ConfigHD
	chmod 600 /root/.ssh/config
fi


while true; do
	OK_TO_LAUNCH=false
	MOVE_PAYLOAD_FILES=false
	PLEASE_LOAD_THE_FILES=false
	# IF the pub and priv keys exist, we are ok to launch
	if [[ -e ${KEY_LOCATION}/${PRIV_KEY} ]] ; then
		OK_TO_LAUNCH=true
	# Check if files are in payload directory
	elif [[ -e /payload/${PRIV_KEY} ]] ; then
		#move files to final location and change permisions
		MOVE_PAYLOAD_FILES=true
	else
		PLEASE_LOAD_THE_FILES=true
	fi


	if ${OK_TO_LAUNCH}; then
		echo "Everything OK. Launching."
		echo autossh $@ -N
		exec  autossh $@ -N
		
	fi

	if ${MOVE_PAYLOAD_FILES}; then
		echo "Moving keys..."
		mv /payload/${PRIV_KEY} ${KEY_LOCATION}/
		chmod 600 ${KEY_LOCATION}/${PRIV_KEY}
	fi

	if ${PLEASE_LOAD_THE_FILES}; then
		echo "Please copy key files to container's /payload folder"
		echo "i.e.: docker cp id_rsa this_container:/payload/"
		sleep 10
	fi
done

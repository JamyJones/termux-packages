#!/bin/sh
set -e -u

CONTAINER_HOME_DIR=/home/builder
UNAME=$(uname)
if [ "$UNAME" = Darwin ]; then
	# Workaround for mac readlink not supporting -f.
	REPOROOT=$PWD
else
	REPOROOT="$(dirname $(readlink -f $0))/../"
fi

if [ -n "$(command -v getenforce)" ] && [ "$(getenforce)" = Enforcing ]; then
	VOLUME=$REPOROOT:$CONTAINER_HOME_DIR/termux-packages:z
else
	VOLUME=$REPOROOT:$CONTAINER_HOME_DIR/termux-packages
fi

: ${TERMUX_BUILDER_IMAGE_NAME:="termux/package-builder:legacy"}
: ${CONTAINER_NAME:=termux-package-builder-legacy}

USER=builder
if [ -n "${TERMUX_DOCKER_USE_SUDO-}" ]; then
	SUDO="sudo"
else
	SUDO=""
fi
echo "Running container '$CONTAINER_NAME' from image '$TERMUX_BUILDER_IMAGE_NAME'..."
$SUDO docker start $CONTAINER_NAME >/dev/null 2>&1 || {
	echo "Creating new container..."
	$SUDO docker run \
		--detach \
		--init \
		--name $CONTAINER_NAME \
		--volume $VOLUME \
		--tty \
		$TERMUX_BUILDER_IMAGE_NAME
	if [ "$UNAME" != Darwin ]; then
		if [ $(id -u) -ne 1001 -a $(id -u) -ne 0 ]; then
			echo "Changed builder uid/gid... (this may take a while)"
			$SUDO docker exec $DOCKER_TTY $CONTAINER_NAME sudo chown -R $(id -u) $CONTAINER_HOME_DIR
			$SUDO docker exec $DOCKER_TTY $CONTAINER_NAME sudo chown -R $(id -u) /data
			$SUDO docker exec $DOCKER_TTY $CONTAINER_NAME sudo usermod -u $(id -u) builder
			$SUDO docker exec $DOCKER_TTY $CONTAINER_NAME sudo groupmod -g $(id -g) builder
		fi
	fi
}

# Set traps to ensure that the process started with docker exec and all its children are killed.
#. "$TERMUX_SCRIPTDIR/scripts/utils/docker/docker.sh"; docker__setup_docker_exec_traps

if [ "$#" -eq "0" ]; then
	set -- bash
fi

echo "Hello"
echo $DOCKER_EXEC_PID_FILE_PATH
pid_=$(docker inspect --format '{{.State.Pid}}' termux-package-builder-legacy)
ls -l /proc/$pid_/exe
exit 1
#$SUDO docker exec --env "DOCKER_EXEC_PID_FILE_PATH=$DOCKER_EXEC_PID_FILE_PATH" --interactive $DOCKER_TTY $CONTAINER_NAME "$@"

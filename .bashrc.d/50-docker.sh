#!/bin/sh

# Alias docker-commands to podman equivalents (in addition to podman-docker wrappers)
# As per https://askubuntu.com/a/98791/786783 this uses shell functions instead of "real" aliases.
# XXX: Disabled for now to continue using docker-compose 1.x 
#docker-compose() {
#	#podman-compose "$@"
#	$HOME/modules/docker-compose-linux-x86_64 "$@"
#}
#export -f docker-compose

# XXX: Cannot use buildkit right now, because docker-compose defaults to using the docker.io/moby/buildkit:buildx-stable-1
#      image, but according to https://github.com/moby/buildkit/issues/1467 we should use a "rootless" version
#      to avoid errors like 
#
#      failed to solve: failed to read dockerfile: failed to mount /tmp/buildkit-mount2766121727: [{Type:bind Source:/var/lib/buildkit/runc-overlayfs/snapshots/snapshots/2/fs Options:[rbind ro]}]: operation not permitted
#
#      since moving to a dedicated volume?
# XXX: Disabled for now for another test run
#export DOCKER_BUILDKIT=0

# Configure docker tools to use podman, if that is available
podman_socket=$(podman info --format '{{.Host.RemoteSocket.Path}}' 2>/dev/null)
if [ -n "${podman_socket}" ]; then
	export DOCKER_HOST=unix://${podman_socket}
fi
unset podman_socket

# On macOS, if colima is installed: Point to the colima socket. Note that this check
# doesn't require colima to run.
if [ -d "${HOME}/.colima" ]; then
	export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
fi

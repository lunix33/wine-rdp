#!/bin/bash

cwd=$(cd $(dirname $0); pwd)
DEFAULT_BASE="lunix33/wine-rdp"

buildDocker() {
	nocache=""
	[[ $1 = "no-cache" ]] && nocache="--no-cache"
	
	docker build \
		--progress plain \
		--tag ${DEFAULT_BASE} \
		${nocache} \
		.
}

tagImage() {
	tag="$1"
	base="${2:-$DEFAULT_BASE}"

	docker tag \
		${base} ${DEFAULT_BASE}:${tag}
}

pushImage() {
	image="$1"

	docker push ${image}
}

runImage() {
	image="${1:-$DEFAULT_BASE}"
	
	docker run \
		--rm \
		-p 3389:3389 \
		--shm-size 2g \
		-v ${cwd}/user-sync.json:/etc/user-sync.json \
		${image}
}

showHelp() {
	cat <<'EOF'
Usage: ./cmd.sh COMMAND

Available commands:
	* `build`: Build the docker container.
	* `tag TAG [BASE]`: Tag an image with a new tag.
		* `TAG`: The tag to be applied to the base image.
		* `BASE`: An optional base image to tag (default to `lunix33/wine-rdp`).
	* `push IMAGE`: Publish the image.
		* `IMAGE`: The name of the image to publish.
	* `run [IMAGE]`: Run the docker image.
		* `IMAGE`: The image to run (default to `lunix33/wine-rdp`).
EOF
}

case "$1" in
	"build")
		buildDocker $2
		;;
	"tag")
		tagImage $2 $3
		;;
	"push")
		pushImage $2
		;;
	"run")
		runImage $2
		;;
	*)
		showHelp
		;;
esac

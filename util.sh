#!/bin/bash
REGISTRY="docker.io"
PREFIX="salvachll"

set -e

function build_image() {
  dir=$1
  tag=$2
  IMAGE_NAME="${REGISTRY}/${PREFIX}/$(basename $dir):$tag"
  echo "Building image for $dir with tag $IMAGE_NAME"
  docker build -t "$IMAGE_NAME" -f "${dir}/Dockerfile" "$dir"
}

function publish_image() {
  dir=$1
  tag=$2
  IMAGE_NAME="${REGISTRY}/${PREFIX}/$(basename $dir):$tag"
  echo "Publishing image $IMAGE_NAME"
  docker push "$IMAGE_NAME"
}

# Parse input parameters
COMMAND=$1
TAG=${2:-latest} # Use the second argument as tag, or default to 'latest'
DIR=$3           # Use the third argument as the directory

case $COMMAND in
'build-n-publish-all')
  $0 build-all "$TAG"
  $0 publish-all "$TAG"
  ;;

'build-all')
  for dir in component-implementation/*; do
    if [ -f "${dir}/Dockerfile" ]; then
      build_image "$dir" "$TAG"
    else
      echo "No Dockerfile found in $dir, skipping..."
    fi
  done
  ;;

'publish-all')
  for dir in component-implementation/*; do
    if [ -f "${dir}/Dockerfile" ]; then
      publish_image "$dir" "$TAG"
    else
      echo "No Dockerfile found in $dir, skipping..."
    fi
  done
  ;;

'build-n-publish')
  if [ -n "$DIR" ]; then
    FULL_DIR="component-implementation/$DIR"
    if [ -d "$FULL_DIR" ] && [ -f "${FULL_DIR}/Dockerfile" ]; then
      build_image "$FULL_DIR" "$TAG"
      publish_image "$FULL_DIR" "$TAG"
    else
      echo "Specified directory $DIR doesn't exist or doesn't contain a Dockerfile"
    fi
  else
    echo "Please specify a directory to build and publish."
    exit 1
  fi
  ;;

'build')
  if [ -n "$DIR" ]; then
    FULL_DIR="component-implementation/$DIR"
    if [ -d "$FULL_DIR" ] && [ -f "${FULL_DIR}/Dockerfile" ]; then
      build_image "$FULL_DIR" "$TAG"
    else
      echo "Specified directory $DIR doesn't exist or doesn't contain a Dockerfile"
    fi
  else
    echo "Please specify a directory to build."
    exit 1
  fi
  ;;

'publish')
  if [ -n "$DIR" ]; then
    FULL_DIR="component-implementation/$DIR"
    if [ -d "$FULL_DIR" ] && [ -f "${FULL_DIR}/Dockerfile" ]; then
      publish_image "$FULL_DIR" "$TAG"
    else
      echo "Specified directory $DIR doesn't exist or doesn't contain a Dockerfile"
    fi
  else
    echo "Please specify a directory to publish."
    exit 1
  fi
  ;;

*)
  echo "Usage: $0 {build-n-publish-all|build-all|publish-all|build-n-publish <tag> <dir>|build <tag> <dir>|publish <tag> <dir>}"
  ;;

esac

set +e

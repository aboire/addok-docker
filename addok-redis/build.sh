#!/bin/sh
set -e

# Définir VERSION comme un horodatage (format : YYYYMMDDHHMMSS)
VERSION=$(date +"%Y%m%d%H%M%S")

TAG="latest"

echo "VERSION définie à : $VERSION"

# Construire et taguer l'image
docker build --pull --rm -t communecter/addok-redis:$VERSION .
docker tag communecter/addok-redis:$VERSION communecter/addok-redis:$VERSION
docker push communecter/addok-redis:$VERSION

# Tag supplémentaire pour la version "latest"
docker tag communecter/addok-redis:$VERSION communecter/addok-redis:$TAG
docker push communecter/addok-redis:$TAG

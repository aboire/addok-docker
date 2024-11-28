#!/bin/sh
set -e

# Définir VERSION comme un horodatage (format : YYYYMMDDHHMMSS)
VERSION=$(date +"%Y%m%d%H%M%S")

TAG="latest"

echo "VERSION définie à : $VERSION"

# Construire et taguer l'image
docker build --pull --rm -t communecter/addok-standalone:$VERSION .
docker tag communecter/addok-standalone:$VERSION communecter/addok-standalone:$VERSION
docker push communecter/addok-standalone:$VERSION

# Tag supplémentaire pour la version "latest"
docker tag communecter/addok-standalone:$VERSION communecter/addok-standalone:$TAG
docker push communecter/addok-standalone:$TAG

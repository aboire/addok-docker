#!/bin/sh
set -e

# Définir VERSION comme un horodatage (format : YYYYMMDDHHMMSS)
VERSION=$(date +"%Y%m%d%H%M%S")

TAG="latest"

echo "VERSION définie à : $VERSION"

# Construire et taguer l'image
docker build --pull --rm -t communecter/addok:$VERSION .
docker tag communecter/addok:$VERSION communecter/addok:$VERSION
docker push communecter/addok:$VERSION

# Tag supplémentaire pour la version "latest"
docker tag communecter/addok:$VERSION communecter/addok:$TAG
docker push communecter/addok:$TAG

#!/bin/sh
set -e

# Définir VERSION comme un horodatage (format : YYYYMMDDHHMMSS)
VERSION=$(date +"%Y%m%d%H%M%S")

TAG="latest"

echo "VERSION définie à : $VERSION"

# Construire et taguer l'image
docker build --pull --rm -t communecter/addok-importer:$VERSION .
docker tag communecter/addok-importer:$VERSION communecter/addok-importer:$VERSION
docker push communecter/addok-importer:$VERSION

# Tag supplémentaire pour la version "latest"
docker tag communecter/addok-importer:$VERSION communecter/addok-importer:$TAG
docker push communecter/addok-importer:$TAG

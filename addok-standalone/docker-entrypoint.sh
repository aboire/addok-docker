#!/usr/bin/env bash

USE_PRE_INDEXED_DATA_URL=https://adresse.data.gouv.fr/data/ban/adresses/latest/addok/addok-france-bundle.zip

if [[ -z $PRE_INDEXED_DATA_URL ]]; then
    echo "PRE_INDEXED_DATA_URL environment variable is not set. ${USE_PRE_INDEXED_DATA_URL} will be used as pre-indexed data."
else
    echo "PRE_INDEXED_DATA_URL environment variable set. ${PRE_INDEXED_DATA_URL} will be used as pre-indexed data."
    USE_PRE_INDEXED_DATA_URL=$PRE_INDEXED_DATA_URL
fi

# Vérifiez si wget est disponible
if ! command -v wget &> /dev/null; then
    echo "Error: wget is not installed." >&2
    exit 1
fi

echo "Downloading pre-indexed data from ${USE_PRE_INDEXED_DATA_URL}"
wget -q $USE_PRE_INDEXED_DATA_URL -O /tmp/addok-pre-indexed-data.zip

# Vérifiez si unzip est disponible
if ! command -v unzip &> /dev/null; then
    echo "Error: unzip is not installed." >&2
    exit 1
fi

echo "Unzipping pre-indexed data"
unzip -d /tmp/addok-pre-indexed-data /tmp/addok-pre-indexed-data.zip

# Supprimer le fichier ZIP après extraction
echo "Deleting ZIP file"
rm -f /tmp/addok-pre-indexed-data.zip

# Vérifiez si les fichiers extraits existent avant de les déplacer
if [[ ! -f /tmp/addok-pre-indexed-data/addok.conf ]] || \
   [[ ! -f /tmp/addok-pre-indexed-data/addok.db ]] || \
   [[ ! -f /tmp/addok-pre-indexed-data/dump.rdb ]]; then
    echo "Error: Missing expected files in the pre-indexed data." >&2
    exit 1
fi

echo "Moving pre-indexed data to the right place"
mv /tmp/addok-pre-indexed-data/addok.conf /etc/addok/addok.conf
mv /tmp/addok-pre-indexed-data/addok.db /data/addok.db
mv /tmp/addok-pre-indexed-data/dump.rdb /data/dump.rdb

# Lancer Redis en arrière-plan
echo "Starting Redis..."
redis-server /usr/local/etc/redis/redis.conf &

# Attendre que Redis soit prêt
echo "Waiting for Redis to be ready..."
until nc -z localhost 6379; do
    sleep 1
done
echo "Redis is ready."

# Lancer Addok au premier plan
echo "Starting Addok..."
cp /etc/addok/addok.conf /etc/addok/addok.patched.conf

echo "LOG_DIR = '/logs'" >> /etc/addok/addok.patched.conf

if [ "$LOG_QUERIES" = "1" ]; then
  echo Will log queries
  echo "LOG_QUERIES = True" >> /etc/addok/addok.patched.conf
fi

if [ "$LOG_NOT_FOUND" = "1" ]; then
echo Will log Not Found
  echo "LOG_NOT_FOUND = True" >> /etc/addok/addok.patched.conf
fi

if [ ! -z "$SLOW_QUERIES" ]; then
  echo Will log slow queries
  echo "SLOW_QUERIES = ${SLOW_QUERIES}" >> /etc/addok/addok.patched.conf
fi

WORKERS=${WORKERS:-1}
WORKER_TIMEOUT=${WORKER_TIMEOUT:-30}
gunicorn -w $WORKERS --timeout $WORKER_TIMEOUT -b 0.0.0.0:7878 --access-logfile - addok.http.wsgi

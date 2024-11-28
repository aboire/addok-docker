# Étape 1 : Build stage - Installer les dépendances et packages
FROM python:3.10 AS build

# Désactiver la barre de progression pip
RUN pip config --user set global.progress_bar off

# Installer les packages Python nécessaires
RUN pip install --prefix=/install cython \
    addok==1.1.2 addok-fr==1.0.1 addok-france==1.1.3 \
    addok-csv==1.1.0 addok-sqlite-store==1.0.1 gunicorn==23.0.0

FROM python:3.10-slim

# Copier les dépendances Python installées à partir du stage précédent
COPY --from=build /install /usr/local

ENV ADDOK_CONFIG_MODULE /etc/addok/addok.patched.conf
ENV REDIS_HOST redis
ENV REDIS_PORT 6379
ENV REDIS_DB_INDEXES 0
ENV SQLITE_DB_PATH /data/addok.db

COPY docker-entrypoint.sh /bin

VOLUME ["/data"]
EXPOSE 7878

CMD ["docker-entrypoint.sh"]

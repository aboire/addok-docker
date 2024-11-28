# Étape 1 : Utiliser une image complète pour installer les dépendances
FROM debian:bullseye AS builder

# Installer les dépendances nécessaires (Tini, Python, unzip, wget)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    unzip \
    wget \
    netcat \
    tini && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Copier les binaires nécessaires dans un répertoire temporaire
RUN mkdir -p /opt/unzip /opt/wget /opt/wget-libs /opt/tini /opt/netcat/ /opt/netcat-libs/
RUN cp -a /usr/bin/unzip /opt/unzip/
RUN ldd /usr/bin/wget | awk '{ if ($3 ~ /^\//) print $3 }' | xargs -I{} cp -v {} /opt/wget-libs/
RUN cp -a /usr/bin/wget /opt/wget/
RUN cp -a /usr/bin/tini /opt/tini/
RUN cp -a /bin/nc /opt/netcat/
RUN ldd /bin/nc | awk '{ if ($3 ~ /^\//) print $3 }' | xargs -I{} cp -v {} /opt/netcat-libs/


# Étape 2 : Image finale basée sur communecter/addok
FROM communecter/addok as addok

# Copier Redis depuis addok-redis
COPY --from=communecter/addok-redis /usr/local/bin/redis-server /usr/local/bin/redis-server
COPY --from=communecter/addok-redis /usr/local/etc/redis/redis.conf /usr/local/etc/redis/redis.conf
RUN sed -i 's/dir .\//dir \/data\//g' /usr/local/etc/redis/redis.conf

# Copier les outils depuis l'étape builder
COPY --from=builder /opt/unzip/* /usr/bin/
COPY --from=builder /opt/wget/* /usr/bin/
COPY --from=builder /opt/wget-libs/* /usr/lib/
COPY --from=builder /opt/tini/* /usr/bin/
COPY --from=builder /opt/netcat/* /usr/bin/
COPY --from=builder /opt/netcat-libs/* /usr/lib/

# Vérifier la présence des outils
# RUN which unzip && unzip -v
# RUN which wget && wget --version
# RUN which tini && tini --version
# RUN which nc && nc -h

# Configurer l'environnement PATH
ENV PATH="/usr/bin:${PATH}"

RUN mkdir -p /etc/addok /data

# Copier le script d'entrée
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENV REDIS_HOST localhost

# Configurer Tini comme point d'entrée
ENTRYPOINT ["/usr/bin/tini", "--"]

# Commande à exécuter
CMD ["/docker-entrypoint.sh"]

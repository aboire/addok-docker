# Conteneurs Addok pour Docker

## Note du fork

Les images Docker utilisent un processus de build **multi-stage** et des images finales basées sur des versions **slim**, ce qui réduit leur taille tout en améliorant leur performance et leur portabilité. De plus, la version standalone a été optimisée pour être plus légère et fonctionnelle.

les images sont disponibles sur le docker hub : 

- [communecter/addok](https://hub.docker.com/r/communecter/addok)
- [communecter/addok-redis](https://hub.docker.com/r/communecter/addok-redis)
- [communecter/addok-standalone](https://hub.docker.com/r/communecter/addok-standalone)
- [communecter/addok-importer](https://hub.docker.com/r/communecter/addok-importer)

### Configuration de Redis (Image **addok-redis**)

L'image **`addok-redis`** utilise la version 7.x de Redis. Avec cette version, certaines configurations système peuvent être nécessaires pour garantir un fonctionnement optimal, en particulier si vous rencontrez des erreurs liées à la mémoire.

#### Activer l'overcommit de mémoire

Redis 7.x nécessite que **`vm.overcommit_memory`** soit activé pour éviter des erreurs lors de sauvegardes en arrière-plan ou de réplications. Suivez ces étapes pour configurer votre système :

1. **Modifier la configuration système** :
   Ouvrez le fichier **`/etc/sysctl.conf`** avec un éditeur de texte (par exemple `nano`) :
   ```bash
   sudo nano /etc/sysctl.conf
   ```

2. **Ajouter la ligne suivante** :
   ```plaintext
   vm.overcommit_memory=1
   ```

3. **Appliquer les changements** :
   Chargez la configuration modifiée sans redémarrer :
   ```bash
   sudo sysctl -p
   ```

#### Permissions Docker

Pour que Redis fonctionne correctement dans un environnement Docker, vous devez ajouter les permissions suivantes dans votre fichier **`docker-compose.yml`** :

```yaml
services:
  addok-redis:
    image: communecter/addok-redis
    privileged: true
    cap_add:
      - SYS_PTRACE
```
  
---

Ces images permettent de simplifier grandement la mise en place d'une instance [addok](https://github.com/addok/addok) avec les données de références diffusées par la [Base Adresse Nationale](https://adresse.data.gouv.fr).

## Plateformes

Les images Docker sont disponibles pour `linux/amd64` et `linux/arm64`. Elles sont donc parfaitement utilisables sur Apple Silicon ou Raspberry Pi sans couche d’émulation.

## Composants installés

| Nom du composant | Version |
| --- | --- |
| `redis` | `7.x` |
| `python` | `3.10.x` |
| `addok` | `1.1.2` |
| `addok-fr` | `1.0.1` |
| `addok-france` | `1.1.3` |
| `addok-csv` | `1.1.0` |
| `addok-sqlite-store` | `1.0.1` |
| `gunicorn` | `23.0.0` |

## Guides d'installation

Les guides suivants ont été rédigés pour un environnement Linux ou Mac. Ils peuvent être adaptés pour Windows.

### Pré-requis

* Au moins 6 Go de RAM disponible (à froid)
* 8 Go d'espace disque disponible (hors logs)
* [Docker CE 1.10+](https://docs.docker.com/engine/installation/)
* [Docker Compose 1.10+](https://docs.docker.com/compose/install/)
* `unzip` ou équivalent
* `wget` ou équivalent

### Installer une instance avec les données de la Base Adresse Nationale

Tout d'abord placez vous dans un dossier de travail, appelez-le par exemple `ban`.

#### Télécharger les données pré-indexées

```bash
wget https://adresse.data.gouv.fr/data/ban/adresses/latest/addok/addok-france-bundle.zip
```

#### Décompresser l'archive

```bash
mkdir addok-data
unzip -d addok-data addok-france-bundle.zip
```

#### Télécharger le fichier Compose

```bash
wget https://raw.githubusercontent.com/BaseAdresseNationale/addok-docker/master/docker-compose.yml
```

#### Démarrer l'instance

Suivant votre environnement, `sudo` peut être nécessaire pour les commandes suivantes.

```bash
# Attachée au terminal
docker-compose up

# ou en arrière-plan
docker-compose up -d
```

Suivant les performances de votre machine, l'instance mettra entre 30 secondes et 2 minutes à démarrer effectivement, le temps de charger les données dans la mémoire vive.

* 90 secondes sur une VPS-SSD-3 OVH (2 vCPU, 8 Go)
* 50 secondes sur une VM EG-15 OVH (4 vCPU, 15 Go)

Par défaut l'instance écoute sur le port `7878`.

#### Tester l'instance

```bash
curl "http://localhost:7878/search?q=1+rue+de+la+paix+paris"
```

### Paramètres avancés

| Nom du paramètre | Description |
| ----- | ----- |
| `WORKERS` | Nombre de workers addok à lancer. Valeur par défaut : `1`. |
| `WORKER_TIMEOUT` | [Durée maximale allouée à un worker](http://docs.gunicorn.org/en/0.17.2/configure.html#timeout) pour effectuer une opération de géocodage. Valeur par défaut : `30`. |

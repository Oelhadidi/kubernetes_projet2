# 🛒 OroCommerce sur Kubernetes avec Données de Démo Complètes

**Déploiement complet d'OroCommerce avec 64 produits, interface admin et monitoring intégré.**

[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.25+-blue.svg)](https://kubernetes.io/)
[![Helm](https://img.shields.io/badge/Helm-3.x-brightgreen.svg)](https://helm.sh/)
[![OroCommerce](https://img.shields.io/badge/OroCommerce-6.1.0-orange.svg)](https://oroinc.com/)

## 🚀 Installation en 1 commande

```powershell
# Cloner et installer
git clone https://github.com/Oelhadidi/kubernetes_projet.git
cd kubernetes_projet
./setup-complete-orocommerce.ps1
```

## ✨ Ce que vous obtenez

- **🛍️ 64 produits** avec images et descriptions complètes
- **🏠 Page d'accueil** avec contenu RV professionnel  
- **👨‍💼 Interface admin** (admin/admin)
- **🔍 Recherche** et filtres fonctionnels
- **📊 Monitoring** Prometheus + Grafana
- **🎨 Design** moderne avec tous les assets

## 🎯 URLs d'accès

Après installation et `kubectl port-forward service/nginx 8080:80` :

- **Boutique :** http://localhost:8080
- **Admin :** http://localhost:8080/admin
- **Produits :** http://localhost:8080/product/
- **Prometheus :** http://localhost:9090 (avec port-forward)
- **Grafana :** http://localhost:3000 (avec port-forward)

Migrer l'application **OroCommerce Demo** depuis Docker Compose vers Kubernetes en utilisant Helm Charts, avec monitoring intégré et sécurité renforcée.

## 🏗️ Architecture déployée

```
┌─────────────────────────────────────────────────────────┐
│                  KUBERNETES CLUSTER                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  📊 MONITORING         🌐 APPLICATION                   │
│  ┌─────────────┐      ┌─────────────┐                  │
│  │ Prometheus  │      │    Nginx    │                  │
│  │   :9090     │      │    :80      │                  │
│  └─────────────┘      └─────────────┘                  │
│  ┌─────────────┐      ┌─────────────┐                  │
│  │   Grafana   │      │  PHP-FPM    │                  │
│  │   :3000     │      │   :9000     │                  │
│  └─────────────┘      └─────────────┘                  │
│                                                         │
│  💾 DATA LAYER                                          │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐   │
│  │ PostgreSQL  │ │    Redis    │ │  Elasticsearch  │   │
│  │   :5432     │ │   :6379     │ │     :9200       │   │
│  └─────────────┘ └─────────────┘ └─────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

## Run Application

#### 1. Download Repository With Docker Compose Configuration File

Check out the git repository:
```bash
git clone https://github.com/oroinc/docker-demo.git
cd docker-demo
```
Or download the archive file and extract it:
```bash
wget https://github.com/oroinc/docker-demo/archive/master.tar.gz -O - | tar -xzf -
cd docker-demo
```

#### 2. Run Application Containers

The configuration is entirely predefined, and you can only change the domain name where the application will be located. By default, it is `oro.demo`. If you need to change the domain, edit the `.env` file and change `ORO_APP_DOMAIN=my-custom-domain.demo`.

Run init service:
```bash
docker compose up restore
```

Alternatively, you can install the application from scratch, but it will require more time and resources.

Run install service:
```bash
docker compose up install
```

You can run the application as soon as it is installed or initialized.

Run application:
```bash
docker compose up application
```

The docker compose will download the required images, create networks and run containers.
Application [orocommerce-application](https://github.com/oroinc/orocommerce-application) is used by default.
If you want to get the application in a different locale, add the contents of the file `.env-locale-de_DE` or `.env-locale-fr_FR` to `.env` and restart the restore service and application.
```bash
cat .env-locale-de_DE >> .env
```

To track the logs from the php-fpm-app container, run `docker compose logs -f php-fpm-app`. To get the list of containers, run `docker compose ps`.

#### 3. Add a Record to File `/etc/hosts`

```
127.0.0.1 oro.demo
```

#### 4. Open the Application in a Browser

Now, you can open URL [http://oro.demo](http://oro.demo) in your browser.

To access the back-office, use *admin* as both login and password.
To access the storefront, use the credentials of the predefined demo user roles. To log in as a buyer, use *BrandaJSanborn@example.org* both as your login and password. To log in as a manager, use *AmandaRCole@example.org* both as your login and password.

## Access the Mail Catcher

[Smtp service](https://github.com/mailhog/MailHog) is additionally launched so that you can send emails from the application. It receives all mail and has a web interface that enables you to view it and perform the required actions. The web interface for the mail catcher is available at the address [http://oro.demo/mailcatcher](http://oro.demo/mailcatcher).

## Stop the Application

- To stop and remove all containers, run `docker compose down`.

- To stop and remove all containers with the data saved in volumes, run `docker compose down -v`.

## Troubleshooting

- If you deployed the application before, pull fresh images with `docker compose pull`.

## About this Project

This repository provides a Docker Compose configuration file (compose.yaml) and demonstrates how to run different applications + required services in containers. Oro Inc. provides images with applications Community Edition in public Docker Hub.

**This deployment is NOT intended for a production environment.**


License
-------

[MIT][1] Copyright (c) 2013 - 2023, Oro, Inc.

[1]:    LICENSE

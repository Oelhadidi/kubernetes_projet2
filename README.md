# Collaborateurs :
    BRAHIM BOUTAGJAT
    DRILON LIMANI
    GETOAR LIMANI
    OMAR ELHADIDI
# 🛒 OroCommerce sur Kubernetes avec Données de Démo Complètes

**Déploiement complet d'OroCommerce avec 64 produits, interface admin et monitoring intégré.**

[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.25+-blue.svg)](https://kubernetes.io/)
[![Helm](https://img.shields.io/badge/Helm-3.x-brightgreen.svg)](https://helm.sh/)
[![OroCommerce](https://img.shields.io/badge/OroCommerce-6.1.0-orange.svg)](https://oroinc.com/)

---

## 🚀 Quickstart – Déploiement OroCommerce sur Kubernetes

### 1. Prérequis

- Kubernetes 1.25+ (Minikube, Kind ou cluster cloud)
- Helm 3.x
- kubectl installé et configuré

### 2. Cloner le projet

```bash
git clone <url-du-repo>
cd <nom-du-repo>
```


### lancement de minikube 
 ```bash
minikube start
```   

### 3. Déployer la base de données PostgreSQL

```bash
helm install postgresql ./charts/postgresql
```

### 4. Déployer Redis

```bash
kubectl apply -f redis-deployment.yaml
```

### 5. Déployer le backend PHP-FPM (OroCommerce)

```bash
helm install php-fpm-app ./charts/php-fpm-app
```

### 6. Déployer le frontend Nginx

```bash
helm install nginx ./charts/nginx
```

### 7. (Optionnel) Déployer le monitoring Prometheus & Grafana

```bash
helm install prometheus ./charts/prometheus
helm install grafana ./charts/grafana
```

### 8. Accéder à l’application

```bash
kubectl port-forward service/nginx 8081:80
```
Puis ouvre [http://localhost:8081](http://localhost:8081) dans ton navigateur.

### 9. Identifiants par défaut

- **Admin** : `admin`
- **Mot de passe** : `admin`

### 10. (Optionnel) Accéder à Grafana

```bash
kubectl port-forward svc/grafana 3000:80
```
Puis ouvre [http://localhost:3000](http://localhost:3000)

---

## ✨ Ce que vous obtenez

- **🛍️ 64 produits** avec images et descriptions complètes
- **🏠 Page d'accueil** avec contenu pro
- **👨‍💼 Interface admin** (admin/admin)
- **🔍 Recherche** et filtres fonctionnels (ORM PostgreSQL)
- **📊 Monitoring** Prometheus + Grafana
- **🎨 Design** moderne avec tous les assets
- **⚡ Architecture simplifiée** : PostgreSQL uniquement

## 📁 Structure du projet

```
├── charts/              # Charts Helm (tous composants)
├── archive/             # Scripts de migration
├── setup-complete-orocommerce.ps1    # Installation principale (legacy)
├── validate-simplified-deployment.ps1 # Validation
└── Documentation complète
```

Voir [STRUCTURE.md](STRUCTURE.md) pour les détails complets.

## 🏗️ Architecture déployée

Cette stack Kubernetes déploie une application OroCommerce complète avec monitoring intégré :

### 🌐 Couche Frontend
- **Nginx** (port 80) : Serveur web et reverse proxy
  - Point d'entrée de l'application
  - Gestion des fichiers statiques
  - Redirection vers PHP-FPM pour le traitement dynamique

### ⚙️ Couche Application
- **PHP-FPM** (port 9000) : Moteur d'exécution OroCommerce
  - Application e-commerce complète
  - Version 6.1.0 pré-configurée
  - Traitement des requêtes métier

### 💾 Couche Données
- **PostgreSQL** (port 5432) : Base de données principale
  - Stockage des données OroCommerce
  - Version 15.12 optimisée
  - Persistance garantie avec PVC

### 📊 Couche Monitoring
- **Prometheus** (port 9090) : Collecte de métriques
  - Surveillance en temps réel
  - Métriques Kubernetes et applicatives
  
- **Grafana** (port 3000) : Dashboards de visualisation
  - Interface de monitoring
  - Dashboards pré-configurés
  - Alerting intégré




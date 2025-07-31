
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

### 3. Déployer la base de données PostgreSQL

```bash
helm install postgresql ./charts/postgresql
```

### 4. Déployer Redis

```bash
helm install redis ./charts/redis
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
│  ┌─────────────┐                                       │
│  │ PostgreSQL  │                                       │
│  │   :5432     │                                       │
│  └─────────────┘                                       │
└─────────────────────────────────────────────────────────┘
```




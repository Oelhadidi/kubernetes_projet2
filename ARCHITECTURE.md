# Architecture Kubernetes - OroCommerce

## Vue d'ensemble de l'architecture

KUBERNETES CLUSTER:
    Monitoring Layer:
        - Prometheus :9090
        - Grafana :3000
    Application Layer:
        - Nginx (Reverse Proxy) :80
        - PHP-FPM (OroCommerce) :9000
    Data Layer:
        - PostgreSQL (Database) :5432
    Storage Layer:
        - Persistent Volumes for PostgreSQL :20Gi
        - OroCommerce data :50Gi
        - Prometheus data :10Gi
        - Grafana data :5Gi

Cette architecture Kubernetes déploie une stack complète OroCommerce avec monitoring intégré, organisée en plusieurs couches fonctionnelles :

### 🌐 Couche Application (Frontend)
- **Nginx** : Serveur web reverse proxy sur le port 80
  - Sert les fichiers statiques et redirige les requêtes PHP vers PHP-FPM
  - Configuration optimisée pour OroCommerce
  - Point d'entrée principal de l'application

### ⚙️ Couche Traitement (Backend)
- **PHP-FPM** : Moteur d'exécution PHP sur le port 9000
  - Exécute l'application OroCommerce 6.1.0
  - Traite toutes les requêtes dynamiques PHP
  - Connecté à PostgreSQL pour la persistance des données

### 🗄️ Couche Données
- **PostgreSQL** : Base de données relationnelle sur le port 5432
  - Base de données principale d'OroCommerce
  - Stockage des données métier, configuration, et cache
  - Version 15.12 optimisée pour les workloads OroCommerce

### 📊 Couche Monitoring
- **Prometheus** : Collecteur de métriques sur le port 9090
  - Surveillance des performances de tous les composants
  - Collecte automatique des métriques Kubernetes et applicatives
  - Retention des données de monitoring

- **Grafana** : Interface de visualisation sur le port 3000
  - Dashboards pré-configurés pour OroCommerce
  - Alerting et notifications
  - Source de données Prometheus intégrée

### 💾 Couche Stockage Persistant
- **PVC PostgreSQL** : 8Gi pour les données de la base
- **PVC OroCommerce** : 2Gi pour les fichiers applicatifs et assets
- **PVC Prometheus** : 10Gi pour les métriques historiques
- **PVC Grafana** : Stockage des dashboards et configurations

### 🔧 Jobs et Tâches
- **oro-installer** : Job d'installation initiale d'OroCommerce
- **oro-copy-assets** : Job de copie des assets statiques optimisés

## Composants détaillés

### Frontend Layer

#### Nginx (Reverse Proxy)
- **Type** : Deployment + Service
- **Réplicas** : 1
- **Port** : 80
- **Fonction** : Serveur web et reverse proxy vers PHP-FPM
- **Configuration** : ConfigMap avec configuration Nginx optimisée

### Application Layer

#### PHP-FPM (Application OroCommerce)
- **Type** : Deployment + Service
- **Réplicas** : 1
- **Port** : 9000
- **Fonction** : Traitement PHP de l'application OroCommerce
- **Init Job** : Installation automatique d'OroCommerce
- **Volumes** : PVC pour les données applicatives

### Data Layer

#### PostgreSQL (Base de données principale)
- **Type** : StatefulSet + Service
- **Réplicas** : 1
- **Port** : 5432
- **Fonction** : Base de données relationnelle principale
- **Stockage** : PVC 20Gi
- **Sécurité** : Secrets pour les credentials

### Monitoring Layer

#### Prometheus (Collecte de métriques)
- **Type** : Deployment + Service
- **Réplicas** : 1
- **Port** : 9090
- **Fonction** : Collecte et stockage des métriques
- **RBAC** : ServiceAccount avec permissions lecture
- **Stockage** : PVC 10Gi

#### Grafana (Visualisation)
- **Type** : Deployment + Service
- **Réplicas** : 1
- **Port** : 3000
- **Fonction** : Dashboards et alerting
- **Datasource** : Prometheus pré-configuré
- **Stockage** : PVC 5Gi

## Flux de données

```
Internet/User
    ↓
Port-forward (8080)
    ↓
Nginx Service (:80)
    ↓
Nginx Pod
    ↓
PHP-FPM Service (:9000)
    ↓
PHP-FPM Pod (OroCommerce)
    ↓
┌─────────┐
│PostgreSQL│
│ (:5432) │
└─────────┘
```

## Sécurité

### Kubernetes Secrets
- **postgresql-secret** : Credentials PostgreSQL
- **orocommerce-secret** : Mots de passe application
- **grafana-secret** : Credentials Grafana admin

### RBAC
- **prometheus** : ServiceAccount avec ClusterRole lecture
- **Principe du moindre privilège** appliqué

### Network Policies
- Services exposés uniquement aux pods nécessaires
- Communication inter-pods sécurisée

## Ressources allouées

### Limites CPU/Mémoire par composant

| Composant | CPU Request | CPU Limit | Memory Request | Memory Limit |
|-----------|-------------|-----------|----------------|--------------|
| Nginx | 100m | 500m | 128Mi | 256Mi |
| PHP-FPM | 500m | 1000m | 1Gi | 2Gi |
| PostgreSQL | 250m | 1000m | 256Mi | 1Gi |
| Prometheus | 200m | 500m | 512Mi | 1Gi |
| Grafana | 200m | 500m | 256Mi | 512Mi |

### Stockage persistant

| Volume | Taille | Type | Composant |
|--------|--------|------|-----------|
| postgresql-data | 20Gi | ReadWriteOnce | PostgreSQL |
| oro-app-data | 50Gi | ReadWriteOnce | OroCommerce |
| prometheus-data | 10Gi | ReadWriteOnce | Prometheus |
| grafana-data | 5Gi | ReadWriteOnce | Grafana |
| **Total** | **85Gi** | | |

## Scalabilité

### Horizontal Pod Autoscaler (HPA) - À implémenter
- **PHP-FPM** : Scaling basé sur CPU (70%) et mémoire (80%)
- **Min replicas** : 1
- **Max replicas** : 5

### Vertical Pod Autoscaler (VPA) - Recommandé
- Ajustement automatique des ressources
- Optimisation continue des limites

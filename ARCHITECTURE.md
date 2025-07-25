# Architecture Kubernetes - OroCommerce

## Vue d'ensemble de l'architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        KUBERNETES CLUSTER                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │   MONITORING    │    │   APPLICATION   │                    │
│  │                 │    │                 │                    │
│  │ ┌─────────────┐ │    │ ┌─────────────┐ │                    │
│  │ │ Prometheus  │ │    │ │    Nginx    │ │                    │
│  │ │   :9090     │ │    │ │    :80      │ │                    │
│  │ └─────────────┘ │    │ └─────────────┘ │                    │
│  │                 │    │        │        │                    │
│  │ ┌─────────────┐ │    │ ┌─────────────┐ │                    │
│  │ │   Grafana   │ │    │ │  PHP-FPM    │ │                    │
│  │ │   :3000     │ │    │ │   :9000     │ │                    │
│  │ └─────────────┘ │    │ └─────────────┘ │                    │
│  └─────────────────┘    └─────────────────┘                    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                   DATA LAYER                                │ │
│  │                                                             │ │
│  │ ┌─────────────┐                                             │ │
│  │ │ PostgreSQL  │                                             │ │
│  │ │   :5432     │                                             │ │
│  │ │ (Database)  │                                             │ │
│  │ └─────────────┘                                             │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                 STORAGE LAYER                               │ │
│  │                                                             │ │
│  │ ┌─────────────┐                                             │ │
│  │ │ PostgreSQL  │                                             │ │
│  │ │    PVC      │                                             │ │
│  │ │   20Gi      │                                             │ │
│  │ └─────────────┘ └─────────────┘ └─────────────────────────┘ │ │
│  │                                                             │ │
│  │ ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │ │
│  │ │ OroCommerce │ │ Prometheus  │ │       Grafana           │ │ │
│  │ │ App Data    │ │   Data      │ │        Data             │ │ │
│  │ │   50Gi      │ │   10Gi      │ │        5Gi              │ │ │
│  │ └─────────────┘ └─────────────┘ └─────────────────────────┘ │ │
│  └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

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

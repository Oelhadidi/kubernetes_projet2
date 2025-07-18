# Guide d'Installation - OroCommerce sur Kubernetes

## Prérequis

### Outils requis
- **Kubernetes** 1.25+
- **Helm** 3.x
- **kubectl** configuré
- **Minikube** ou cluster Kubernetes

### Ressources minimales
- **CPU** : 4 cores
- **RAM** : 8 GB
- **Stockage** : 50 GB

## Installation rapide

### 1. Cloner le repository
```bash
git clone https://github.com/Oelhadidi/kubernetes_projet.git
cd kubernetes_projet
```

### 2. Déployer l'infrastructure de base
```bash
# Déployer PostgreSQL
helm install postgresql ./charts/postgresql

# Déployer Redis
helm install redis ./charts/redis

# Déployer Elasticsearch
helm install elasticsearch ./charts/elasticsearch

# Déployer Nginx
helm install nginx ./charts/nginx

# Déployer PHP-FPM et l'application
helm install php-fpm-app ./charts/php-fpm-app
```

### 3. Déployer le monitoring
```bash
./deploy-monitoring.ps1
```

### 4. Déployer les secrets (sécurité)
```bash
./deploy-secrets.ps1
```

## Accès aux services

### Application principale
```bash
kubectl port-forward service/nginx 8080:80
```
**URL** : http://localhost:8080

### Monitoring Prometheus
```bash
kubectl port-forward service/prometheus 9090:9090
```
**URL** : http://localhost:9090

### Dashboard Grafana
```bash
kubectl port-forward service/grafana 3000:3000
```
**URL** : http://localhost:3000  
**Credentials** : admin / admin123

## Vérification du déploiement

### État des pods
```bash
kubectl get pods
```

### État des services
```bash
kubectl get services
```

### État des volumes persistants
```bash
kubectl get pvc
```

### Logs d'un service
```bash
kubectl logs -f deployment/php-fpm-app
```

## Troubleshooting

### Pod en erreur
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Redémarrer un service
```bash
helm upgrade <release-name> ./charts/<chart-name>
```

### Nettoyer complètement
```bash
helm uninstall postgresql redis elasticsearch nginx php-fpm-app prometheus grafana
kubectl delete pvc --all
```

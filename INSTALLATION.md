# 🚀 Guide d'installation OroCommerce complet

Ce guide garantit que tous les développeurs obtiennent la même installation avec données de démo.

## 📋 Prérequis

### Outils requis
- **Docker Desktop** installé et démarré
- **Minikube** installé
- **kubectl** installé  
- **Helm** installé

### Ressources minimales
- **CPU** : 2 cores (4 recommandés)
- **RAM** : 4 GB (6 GB recommandés)
- **Stockage** : 20 GB

## 🛠️ Installation automatique (Recommandée)

Exécutez simplement le script d'installation :

```powershell
# Cloner le projet
git clone https://github.com/Oelhadidi/kubernetes_projet.git
cd kubernetes_projet

# Lancer l'installation complète
./setup-complete-orocommerce.ps1
```

Le script fera automatiquement :
- ✅ Vérification et démarrage de Minikube
- ✅ Déploiement de l'infrastructure (PostgreSQL, Redis, Elasticsearch)
- ✅ Installation d'OroCommerce avec schéma complet
- ✅ Chargement des 64 produits de démo
- ✅ Configuration de la page d'accueil
- ✅ Réindexation de la recherche
- ✅ Correction des permissions
- ✅ Déploiement du monitoring

## 🔧 Installation manuelle (Si problème avec le script)

### 1. Préparer l'environnement

```powershell
# Démarrer Minikube
minikube start --driver=docker --memory=4096 --cpus=2

# Vérifier le cluster
kubectl get nodes
```

### 2. Déployer l'infrastructure

```powershell
# Infrastructure de base
helm upgrade --install redis ./charts/redis --wait
helm upgrade --install postgresql ./charts/postgresql --wait
helm upgrade --install elasticsearch ./charts/elasticsearch --wait

# Application
helm upgrade --install php-fpm-app ./charts/php-fpm-app --wait
helm upgrade --install nginx ./charts/nginx --wait

# Monitoring (optionnel)
helm upgrade --install prometheus ./charts/prometheus --wait
helm upgrade --install grafana ./charts/grafana --wait
```

### 3. Configuration OroCommerce

```powershell
# Attendre que les pods soient prêts
kubectl wait --for=condition=ready pod --all --timeout=300s

# Installer l'extension PostgreSQL
kubectl exec postgresql-0 -- psql -U oro_user -d oro_db -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"

# Installation OroCommerce
kubectl exec deployment/php-fpm-app -- bash -c "cd /var/www/oro/orocommerce && php bin/console oro:install --env=prod --timeout=0 --application-url=http://localhost:8080 --organization-name='Demo Company' --user-name=admin --user-email=admin@example.com --user-firstname=Admin --user-lastname=User --user-password=admin --force"

# Charger les données de démo
kubectl exec deployment/php-fpm-app -- bash -c "cd /var/www/oro/orocommerce && php bin/console oro:migration:data:load --fixtures-type=demo --env=prod --timeout=0"

# Configurer la page d'accueil
kubectl exec deployment/php-fpm-app -- bash -c "cd /var/www/oro/orocommerce && php bin/console doctrine:query:sql 'UPDATE oro_cms_page SET content = (SELECT content FROM oro_cms_page WHERE id = 2), content_style = (SELECT content_style FROM oro_cms_page WHERE id = 2) WHERE id = 1' --env=prod"

# Corriger les permissions
kubectl exec deployment/php-fpm-app -- chown -R www-data:www-data /var/www/oro/orocommerce/var/

# Réindexer
kubectl exec deployment/php-fpm-app -- bash -c "cd /var/www/oro/orocommerce && php bin/console oro:website-search:reindex --env=prod"
kubectl exec deployment/php-fpm-app -- bash -c "cd /var/www/oro/orocommerce && php bin/console oro:search:reindex --env=prod"

# Vider le cache
kubectl exec deployment/php-fpm-app -- bash -c "cd /var/www/oro/orocommerce && php bin/console cache:clear --env=prod"
```

## 🌐 Accès à l'application

```powershell
# Port-forwarding principal
kubectl port-forward service/nginx 8080:80

# Accès aux applications
# Frontend: http://localhost:8080
# Admin: http://localhost:8080/admin (admin/admin)
```

## 📊 Monitoring (optionnel)

```powershell
# Prometheus
kubectl port-forward service/prometheus 9090:9090
# http://localhost:9090

# Grafana  
kubectl port-forward service/grafana 3000:80
# http://localhost:3000
```

## ✅ Vérification de l'installation

Après installation, vous devriez avoir :

- **64 produits** dans le catalogue `/product/`
- **Page d'accueil** avec contenu RV complet 
- **Interface admin** fonctionnelle
- **Recherche** et **filtres** opérationnels
- **Images** et **styles** chargés

## 🛠️ Dépannage

### Pods qui ne démarrent pas
```powershell
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Problèmes de ressources
```powershell
# Augmenter les ressources Minikube
minikube stop
minikube start --driver=docker --memory=6144 --cpus=4
```

### Reset complet
```powershell
minikube delete
minikube start --driver=docker --memory=4096 --cpus=2
# Relancer l'installation
```

### Base de données vide
```powershell
# Vérifier la connexion DB
kubectl exec deployment/php-fpm-app -- bash -c "cd /var/www/oro/orocommerce && php bin/console doctrine:schema:validate"

# Recharger les données si nécessaire
kubectl exec deployment/php-fpm-app -- bash -c "cd /var/www/oro/orocommerce && php bin/console oro:migration:data:load --fixtures-type=demo --env=prod"
```

## 📱 Contacts

En cas de problème, vérifiez :
1. Les logs des pods
2. L'état de Minikube
3. Les ressources disponibles
4. La documentation officielle OroCommerce

## 🏷️ Versions

- OroCommerce: 6.1.0
- PostgreSQL: 13
- Redis: 7
- Elasticsearch: 8.4
- Nginx: 1.25
- PHP: 8.4
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

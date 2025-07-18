# Guide de Dépannage - OroCommerce Kubernetes

## Problèmes courants et solutions

### 🚨 Pods en erreur

#### Symptôme : Pod en état `CrashLoopBackOff`
```bash
kubectl get pods
# NAME                     READY   STATUS             RESTARTS
# php-fpm-app-xxx          0/1     CrashLoopBackOff   5
```

**Solutions** :
1. **Vérifier les logs**
   ```bash
   kubectl logs php-fpm-app-xxx
   kubectl describe pod php-fpm-app-xxx
   ```

2. **Problème de ressources**
   ```bash
   kubectl top pods  # Vérifier utilisation CPU/RAM
   ```

3. **Redémarrer le pod**
   ```bash
   kubectl delete pod php-fpm-app-xxx
   ```

#### Symptôme : Pod en état `Pending`
```bash
kubectl get pods
# NAME                     READY   STATUS    RESTARTS
# elasticsearch-0          0/1     Pending   0
```

**Solutions** :
1. **Vérifier les ressources du cluster**
   ```bash
   kubectl describe pod elasticsearch-0
   # Rechercher "Events" pour voir les erreurs
   ```

2. **Problème de stockage**
   ```bash
   kubectl get pvc
   kubectl get pv
   ```

### 🔌 Problèmes de connectivité

#### Symptôme : Application inaccessible sur http://localhost:8080
**Solutions** :
1. **Vérifier le port-forward**
   ```bash
   kubectl port-forward service/nginx 8080:80
   ```

2. **Vérifier l'état du service nginx**
   ```bash
   kubectl get service nginx
   kubectl get pods -l app=nginx
   ```

3. **Tester la connectivité interne**
   ```bash
   kubectl exec -it nginx-xxx -- curl localhost:80
   ```

#### Symptôme : Base de données inaccessible
**Solutions** :
1. **Vérifier PostgreSQL**
   ```bash
   kubectl get pods -l app=postgresql
   kubectl logs postgresql-0
   ```

2. **Tester la connexion depuis l'application**
   ```bash
   kubectl exec -it php-fpm-app-xxx -- psql -h postgresql -U orodbuser -d orodb
   ```

### 🔐 Problèmes de sécurité (Secrets)

#### Symptôme : Erreur d'authentification base de données
**Solutions** :
1. **Vérifier les secrets**
   ```bash
   kubectl get secrets
   kubectl describe secret postgresql-secret
   ```

2. **Décoder un secret pour vérification**
   ```bash
   kubectl get secret postgresql-secret -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 -d
   ```

3. **Recréer un secret**
   ```bash
   kubectl delete secret postgresql-secret
   helm upgrade postgresql ./charts/postgresql
   ```

### 📊 Problèmes de monitoring

#### Symptôme : Prometheus ne collecte pas de métriques
**Solutions** :
1. **Vérifier la configuration**
   ```bash
   kubectl get configmap prometheus-config -o yaml
   ```

2. **Vérifier les targets dans Prometheus**
   - Aller sur http://localhost:9090/targets
   - Vérifier que les endpoints sont "UP"

3. **Vérifier les annotations sur les services**
   ```bash
   kubectl get service php-fpm-app -o yaml
   # Chercher les annotations prometheus.io/*
   ```

#### Symptôme : Grafana ne se connecte pas à Prometheus
**Solutions** :
1. **Vérifier la datasource**
   ```bash
   kubectl get configmap grafana-datasources -o yaml
   ```

2. **Tester depuis Grafana**
   - Aller dans Configuration > Data Sources
   - Tester la connexion Prometheus

### 💾 Problèmes de stockage

#### Symptôme : PVC en état `Pending`
```bash
kubectl get pvc
# NAME               STATUS    VOLUME   CAPACITY
# postgresql-data    Pending            
```

**Solutions** :
1. **Vérifier les storage classes**
   ```bash
   kubectl get storageclass
   ```

2. **Pour Minikube, activer le provisioning**
   ```bash
   minikube addons enable default-storageclass
   minikube addons enable storage-provisioner
   ```

3. **Créer un storage class par défaut**
   ```yaml
   apiVersion: storage.k8s.io/v1
   kind: StorageClass
   metadata:
     name: standard
     annotations:
       storageclass.kubernetes.io/is-default-class: "true"
   provisioner: k8s.io/minikube-hostpath
   ```

### ⚙️ Problèmes Helm

#### Symptôme : Erreur `UPGRADE FAILED`
**Solutions** :
1. **Vérifier l'historique des releases**
   ```bash
   helm history <release-name>
   ```

2. **Rollback vers une version précédente**
   ```bash
   helm rollback <release-name> <revision>
   ```

3. **Forcer la mise à jour**
   ```bash
   helm upgrade <release-name> ./charts/<chart> --force
   ```

#### Symptôme : Job immutable (oro-installer)
**Solution** :
```bash
kubectl delete job oro-installer
helm upgrade php-fpm-app ./charts/php-fpm-app
```

### 🔧 Commandes de diagnostic

#### État général du cluster
```bash
# Vue d'ensemble
kubectl get all
kubectl get events --sort-by=.metadata.creationTimestamp

# Ressources par namespace
kubectl get pods --all-namespaces
kubectl top nodes
kubectl top pods
```

#### Logs et debug
```bash
# Logs en temps réel
kubectl logs -f deployment/php-fpm-app
kubectl logs -f statefulset/postgresql

# Description détaillée
kubectl describe pod <pod-name>
kubectl describe service <service-name>
kubectl describe pvc <pvc-name>
```

#### Tests de connectivité
```bash
# Test depuis un pod
kubectl run test-pod --image=busybox -it --rm -- sh

# Dans le pod de test :
nslookup postgresql
nc -z postgresql 5432
nc -z redis 6379
nc -z elasticsearch 9200
```

### 🆘 Procédure de reset complet

Si rien ne fonctionne, reset complet :

```bash
# 1. Supprimer toutes les releases Helm
helm uninstall postgresql redis elasticsearch nginx php-fpm-app prometheus grafana

# 2. Nettoyer les ressources persistantes
kubectl delete pvc --all
kubectl delete secrets --all

# 3. Nettoyer les jobs
kubectl delete jobs --all

# 4. Redémarrer Minikube (si utilisé)
minikube stop
minikube start

# 5. Redéployer depuis le début
./deploy-monitoring.ps1
./deploy-secrets.ps1
```

### 📞 Support et aide

#### Logs utiles à collecter
```bash
# État du cluster
kubectl cluster-info

# Tous les pods et services
kubectl get all -o wide

# Events récents
kubectl get events --sort-by=.metadata.creationTimestamp --field-selector type!=Normal

# Logs des composants critiques
kubectl logs -l app=php-fpm-app --tail=100
kubectl logs -l app=postgresql --tail=100
kubectl logs -l app=nginx --tail=100
```

#### Informations système
```bash
# Version Kubernetes
kubectl version

# Version Helm
helm version

# Ressources disponibles
kubectl describe nodes

# Storage classes
kubectl get storageclass -o wide
```

## ✅ Script de validation automatique

Utilisez le script de validation pour un diagnostic rapide :
```bash
./validate-deployment.ps1
```

Ce script teste automatiquement :
- État des pods
- Disponibilité des services
- Présence des secrets
- Accessibilité des endpoints

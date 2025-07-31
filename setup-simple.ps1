#!/usr/bin/env pwsh
# Script d'installation simplifiée OroCommerce

Write-Host "🚀 Installation complète OroCommerce avec données de démo..." -ForegroundColor Green

# 1. Vérifier que Minikube est démarré
Write-Host "📋 Vérification de Minikube..." -ForegroundColor Yellow
$minikubeStatus = minikube status 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Minikube n'est pas démarré. Démarrage en cours..." -ForegroundColor Red
    minikube start --driver=docker --memory=4096 --cpus=2
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Échec du démarrage de Minikube" -ForegroundColor Red
        exit 1
    }
}
Write-Host "✅ Minikube est actif" -ForegroundColor Green

# 2. Nettoyer les anciennes installations
Write-Host "🧹 Nettoyage des anciennes installations..." -ForegroundColor Yellow
kubectl delete all --all 2>$null
kubectl delete pvc --all 2>$null
Write-Host "✅ Nettoyage terminé" -ForegroundColor Green

# 3. Déployer l'infrastructure
Write-Host "🔧 Déploiement de l'infrastructure..." -ForegroundColor Yellow
helm upgrade --install postgresql ./charts/postgresql --wait --timeout=10m
Write-Host "✅ Infrastructure déployée" -ForegroundColor Green

# 4. Déployer l'application principale
Write-Host "🎯 Déploiement de l'application OroCommerce..." -ForegroundColor Yellow
helm upgrade --install php-fpm-app ./charts/php-fpm-app --wait --timeout=15m
helm upgrade --install nginx ./charts/nginx --wait --timeout=10m
Write-Host "✅ Application déployée" -ForegroundColor Green

# 5. Attendre que les pods soient prêts
Write-Host "⏳ Attente que tous les pods soient prêts..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod --all --timeout=300s
Write-Host "✅ Tous les pods sont prêts" -ForegroundColor Green

# 6. Déployer le monitoring
Write-Host "📊 Déploiement du monitoring..." -ForegroundColor Yellow
helm upgrade --install prometheus ./charts/prometheus --wait --timeout=10m
helm upgrade --install grafana ./charts/grafana --wait --timeout=10m
Write-Host "✅ Monitoring déployé" -ForegroundColor Green

# 7. Afficher les informations d'accès
Write-Host ""
Write-Host "🎉 Installation terminée avec succès!" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 Pour accéder à l'application:" -ForegroundColor Cyan
Write-Host "   kubectl port-forward service/nginx 8080:80" -ForegroundColor White
Write-Host "   Puis ouvrez: http://localhost:8080" -ForegroundColor White
Write-Host ""
Write-Host "📊 Pour accéder au monitoring:" -ForegroundColor Cyan
Write-Host "   Prometheus: kubectl port-forward service/prometheus 9090:9090" -ForegroundColor White
Write-Host "   Grafana: kubectl port-forward service/grafana 3000:80" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Vérifier le statut:" -ForegroundColor Yellow
Write-Host "   kubectl get pods" -ForegroundColor White
Write-Host "   kubectl get services" -ForegroundColor White

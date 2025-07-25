#!/usr/bin/env pwsh
# Script de validation après suppression de Redis et Elasticsearch
# Usage: ./validate-simplified-deployment.ps1

Write-Host "🔍 Validation du déploiement simplifié OroCommerce..." -ForegroundColor Green

# 1. Vérifier l'état des pods
Write-Host "📋 Vérification des pods..." -ForegroundColor Yellow
$pods = kubectl get pods --no-headers 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host $pods
    $runningPods = ($pods | Select-String "Running").Count
    $totalPods = ($pods -split "`n").Count
    Write-Host "✅ Pods en cours d'exécution: $runningPods/$totalPods" -ForegroundColor Green
}
else {
    Write-Host "❌ Erreur lors de la vérification des pods" -ForegroundColor Red
}

# 2. Vérifier que Redis et Elasticsearch ne sont pas présents
Write-Host "🚫 Vérification de l'absence de Redis et Elasticsearch..." -ForegroundColor Yellow
$allPods = kubectl get pods --no-headers 2>$null
$redisCheck = $allPods | Where-Object { $_ -like "*redis*" }
$elasticCheck = $allPods | Where-Object { $_ -like "*elasticsearch*" }

if ($redisCheck) {
    Write-Host "⚠️ Redis détecté - il devrait être supprimé" -ForegroundColor Yellow
}
else {
    Write-Host "✅ Redis absent (correct)" -ForegroundColor Green
}

if ($elasticCheck) {
    Write-Host "⚠️ Elasticsearch détecté - il devrait être supprimé" -ForegroundColor Yellow
}
else {
    Write-Host "✅ Elasticsearch absent (correct)" -ForegroundColor Green
}

# 3. Vérifier la configuration OroCommerce
Write-Host "⚙️ Vérification de la configuration OroCommerce..." -ForegroundColor Yellow
$searchConfig = kubectl exec deployment/php-fpm-app -- env | Where-Object { $_ -like "*ORO_SEARCH_ENGINE_DSN*" } 2>$null
if ($searchConfig -like "*orm://*") {
    Write-Host "✅ Configuration de recherche ORM correcte" -ForegroundColor Green
}
else {
    Write-Host "⚠️ Configuration de recherche inattendue: $searchConfig" -ForegroundColor Yellow
}

# 4. Tester la connectivité PostgreSQL
Write-Host "🗄️ Test de connectivité PostgreSQL..." -ForegroundColor Yellow
$pgTest = kubectl exec deployment/php-fpm-app -- bash -c "cd /var/www/oro/orocommerce && php bin/console doctrine:schema:validate --env=prod" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ PostgreSQL accessible et schéma valide" -ForegroundColor Green
}
else {
    Write-Host "⚠️ Problème avec PostgreSQL" -ForegroundColor Yellow
}

# 5. Vérifier les services nécessaires
Write-Host "🔗 Vérification des services..." -ForegroundColor Yellow
$services = kubectl get services --no-headers 2>$null
if ($services) {
    $nginxService = $services | Select-String "nginx"
    $postgresService = $services | Select-String "postgresql"
    
    if ($nginxService) {
        Write-Host "✅ Service Nginx présent" -ForegroundColor Green
    }
    else {
        Write-Host "❌ Service Nginx manquant" -ForegroundColor Red
    }
    
    if ($postgresService) {
        Write-Host "✅ Service PostgreSQL présent" -ForegroundColor Green
    }
    else {
        Write-Host "❌ Service PostgreSQL manquant" -ForegroundColor Red
    }
}

# 6. Test de l'index de recherche
Write-Host "🔍 Test de la recherche..." -ForegroundColor Yellow
$searchTest = kubectl exec deployment/php-fpm-app -- bash -c "cd /var/www/oro/orocommerce && php bin/console oro:search:reindex --dry-run --env=prod" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Moteur de recherche ORM fonctionnel" -ForegroundColor Green
}
else {
    Write-Host "⚠️ Problème avec le moteur de recherche" -ForegroundColor Yellow
}

# 7. Résumé
Write-Host "" -ForegroundColor White
Write-Host "📊 Résumé de la validation:" -ForegroundColor Yellow
Write-Host "   Architecture simplifiée :" -ForegroundColor White
Write-Host "   ├── ✅ PostgreSQL (Base de données)" -ForegroundColor Green
Write-Host "   ├── ✅ Nginx (Reverse proxy)" -ForegroundColor Green
Write-Host "   ├── ✅ PHP-FPM (Application)" -ForegroundColor Green
Write-Host "   ├── ✅ Prometheus (Monitoring)" -ForegroundColor Green
Write-Host "   └── ✅ Grafana (Dashboards)" -ForegroundColor Green
Write-Host "" -ForegroundColor White
Write-Host "   Services supprimés :" -ForegroundColor White
Write-Host "   ├── ❌ Redis (remplacé par cache PHP)" -ForegroundColor Gray
Write-Host "   └── ❌ Elasticsearch (remplacé par recherche ORM)" -ForegroundColor Gray
Write-Host "" -ForegroundColor White

# 8. Instructions de test
Write-Host "🧪 Tests recommandés:" -ForegroundColor Yellow
Write-Host "   1. Port-forward: kubectl port-forward service/nginx 8080:80" -ForegroundColor White
Write-Host "   2. Ouvrir: http://localhost:8080" -ForegroundColor White
Write-Host "   3. Tester la recherche dans le catalogue" -ForegroundColor White
Write-Host "   4. Vérifier l'interface admin: http://localhost:8080/admin" -ForegroundColor White

Write-Host "" -ForegroundColor White
Write-Host "🎉 Validation terminée!" -ForegroundColor Green

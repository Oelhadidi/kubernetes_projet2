# Script de déploiement du monitoring
# Déploie Prometheus et Grafana pour surveiller l'application OroCommerce

Write-Host "=== Déploiement du monitoring OroCommerce ===" -ForegroundColor Green

# Déployer Prometheus
Write-Host "Déploiement de Prometheus..." -ForegroundColor Yellow
helm upgrade --install prometheus ./charts/prometheus

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Prometheus déployé avec succès" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors du déploiement de Prometheus" -ForegroundColor Red
    exit 1
}

# Attendre que Prometheus soit prêt
Write-Host "Attente du démarrage de Prometheus..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/prometheus

# Déployer Grafana
Write-Host "Déploiement de Grafana..." -ForegroundColor Yellow
helm upgrade --install grafana ./charts/grafana

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Grafana déployé avec succès" -ForegroundColor Green
} else {
    Write-Host "❌ Erreur lors du déploiement de Grafana" -ForegroundColor Red
    exit 1
}

# Attendre que Grafana soit prêt
Write-Host "Attente du démarrage de Grafana..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/grafana

# Afficher les informations d'accès
Write-Host ""
Write-Host "=== Monitoring déployé avec succès ===" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Prometheus:" -ForegroundColor Cyan
Write-Host "   - URL: http://localhost:9090 (port-forward requis)"
Write-Host "   - Commande: kubectl port-forward service/prometheus 9090:9090"
Write-Host ""
Write-Host "📈 Grafana:" -ForegroundColor Cyan
Write-Host "   - URL: http://localhost:3000 (port-forward requis)"
Write-Host "   - Commande: kubectl port-forward service/grafana 3000:3000"
Write-Host "   - Utilisateur: admin"
Write-Host "   - Mot de passe: admin123"
Write-Host ""
Write-Host "🔍 Vérification des pods:" -ForegroundColor Cyan
kubectl get pods | findstr "prometheus\|grafana"
Write-Host ""
Write-Host "🌐 Services:" -ForegroundColor Cyan
kubectl get services | findstr "prometheus\|grafana"

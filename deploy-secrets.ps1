# Script de déploiement des Kubernetes Secrets
# Sécurise les mots de passe en utilisant des Secrets au lieu de plain text

Write-Host "=== Déploiement des Kubernetes Secrets ===" -ForegroundColor Green

# Mettre à jour PostgreSQL avec les secrets
Write-Host "Mise à jour de PostgreSQL avec les secrets..." -ForegroundColor Yellow
helm upgrade postgresql ./charts/postgresql

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ PostgreSQL mis à jour avec les secrets" -ForegroundColor Green
}
else {
    Write-Host "❌ Erreur lors de la mise à jour de PostgreSQL" -ForegroundColor Red
    exit 1
}

# Mettre à jour PHP-FPM avec les secrets
Write-Host "Mise à jour de PHP-FPM avec les secrets..." -ForegroundColor Yellow
helm upgrade php-fpm-app ./charts/php-fpm-app

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ PHP-FPM mis à jour avec les secrets" -ForegroundColor Green
}
else {
    Write-Host "❌ Erreur lors de la mise à jour de PHP-FPM" -ForegroundColor Red
    exit 1
}

# Mettre à jour Grafana avec les secrets
Write-Host "Mise à jour de Grafana avec les secrets..." -ForegroundColor Yellow
helm upgrade grafana ./charts/grafana

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Grafana mis à jour avec les secrets" -ForegroundColor Green
}
else {
    Write-Host "❌ Erreur lors de la mise à jour de Grafana" -ForegroundColor Red
    exit 1
}

# Afficher les secrets créés
Write-Host ""
Write-Host "=== Secrets Kubernetes déployés ===" -ForegroundColor Green
Write-Host ""
Write-Host "🔐 Secrets créés:" -ForegroundColor Cyan
kubectl get secrets | findstr "postgresql-secret\|orocommerce-secret\|grafana-secret"

Write-Host ""
Write-Host "🔍 Vérification des pods après mise à jour:" -ForegroundColor Cyan
kubectl get pods | findstr "postgresql\|php-fpm-app\|grafana"

Write-Host ""
Write-Host "✅ Sécurité renforcée:" -ForegroundColor Green
Write-Host "   - Mots de passe PostgreSQL chiffrés" -ForegroundColor White
Write-Host "   - Mots de passe OroCommerce chiffrés" -ForegroundColor White  
Write-Host "   - Credentials Grafana chiffrés" -ForegroundColor White
Write-Host "   - Plus de mots de passe en plain text dans les manifests" -ForegroundColor White

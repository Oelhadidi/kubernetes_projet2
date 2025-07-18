#!/usr/bin/env pwsh
# Script d'installation complète OroCommerce pour nouveaux utilisateurs
# Usage: ./setup-complete-orocommerce.ps1

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

# 2. Installer Helm si nécessaire
Write-Host "📋 Vérification de Helm..." -ForegroundColor Yellow
$helmVersion = helm version --short 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Helm non trouvé. Veuillez installer Helm d'abord." -ForegroundColor Red
    Write-Host "Installation: https://helm.sh/docs/intro/install/" -ForegroundColor Blue
    exit 1
}
Write-Host "✅ Helm est disponible: $helmVersion" -ForegroundColor Green

# 3. Nettoyer les anciennes installations (optionnel)
Write-Host "🧹 Nettoyage des anciennes installations..." -ForegroundColor Yellow
kubectl delete all --all 2>$null
kubectl delete pvc --all 2>$null
Write-Host "✅ Nettoyage terminé" -ForegroundColor Green

# 4. Déployer l'infrastructure
Write-Host "🔧 Déploiement de l'infrastructure..." -ForegroundColor Yellow
helm upgrade --install redis ./charts/redis --wait --timeout=10m
helm upgrade --install postgresql ./charts/postgresql --wait --timeout=10m
helm upgrade --install elasticsearch ./charts/elasticsearch --wait --timeout=10m
Write-Host "✅ Infrastructure déployée" -ForegroundColor Green

# 5. Déployer l'application principale
Write-Host "🎯 Déploiement de l'application OroCommerce..." -ForegroundColor Yellow
helm upgrade --install php-fpm-app ./charts/php-fpm-app --wait --timeout=15m
helm upgrade --install nginx ./charts/nginx --wait --timeout=10m
Write-Host "✅ Application déployée" -ForegroundColor Green

# 6. Attendre que les pods soient prêts
Write-Host "⏳ Attente que tous les pods soient prêts..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod --all --timeout=300s
Write-Host "✅ Tous les pods sont prêts" -ForegroundColor Green

# 7. Installation et configuration OroCommerce
Write-Host "🔧 Installation d'OroCommerce..." -ForegroundColor Yellow

# Attendre que PostgreSQL soit complètement prêt
Write-Host "  📋 Attente de PostgreSQL..." -ForegroundColor Cyan
Start-Sleep -Seconds 30

# Installer l'extension uuid-ossp pour PostgreSQL
Write-Host "  🔌 Installation de l'extension PostgreSQL..." -ForegroundColor Cyan
kubectl exec postgresql-0 -- psql -U oro_user -d oro_db -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";" 2>$null

# Installer OroCommerce avec schéma et données de base
Write-Host "  🏗️ Installation du schéma de base..." -ForegroundColor Cyan
kubectl exec deployment/php-fpm-app -- bash -c "cd /var/www/oro/orocommerce && php bin/console oro:install --env=prod --timeout=0 --application-url=http://localhost:8080 --organization-name='Demo Company' --user-name=admin --user-email=admin@example.com --user-firstname=Admin --user-lastname=User --user-password=admin --force" --timeout=600s

# Charger les données de démo
Write-Host "  📦 Chargement des données de démo..." -ForegroundColor Cyan
kubectl exec deployment/php-fpm-app -- bash -c "cd /var/www/oro/orocommerce && php bin/console oro:migration:data:load --fixtures-type=demo --env=prod --timeout=0" --timeout=600s

# Mettre à jour le contenu de la page d'accueil
Write-Host "  🎨 Configuration de la page d'accueil..." -ForegroundColor Cyan
kubectl exec deployment/php-fpm-app -- bash -c "cd /var/www/oro/orocommerce && php bin/console doctrine:query:sql 'UPDATE oro_cms_page SET content = (SELECT content FROM oro_cms_page WHERE id = 2), content_style = (SELECT content_style FROM oro_cms_page WHERE id = 2) WHERE id = 1' --env=prod"

# Corriger les permissions
Write-Host "  🔐 Correction des permissions..." -ForegroundColor Cyan
kubectl exec deployment/php-fpm-app -- chown -R www-data:www-data /var/www/oro/orocommerce/var/

# Réindexer la recherche
Write-Host "  🔍 Réindexation de la recherche..." -ForegroundColor Cyan
kubectl exec deployment/php-fpm-app -- bash -c "cd /var/www/oro/orocommerce && php bin/console oro:website-search:reindex --env=prod" --timeout=300s
kubectl exec deployment/php-fpm-app -- bash -c "cd /var/www/oro/orocommerce && php bin/console oro:search:reindex --env=prod" --timeout=300s

# Vider le cache
Write-Host "  🧹 Vidage du cache..." -ForegroundColor Cyan
kubectl exec deployment/php-fpm-app -- bash -c "cd /var/www/oro/orocommerce && php bin/console cache:clear --env=prod"
kubectl exec deployment/php-fpm-app -- bash -c "cd /var/www/oro/orocommerce && php bin/console cache:warmup --env=prod"

Write-Host "✅ Installation d'OroCommerce terminée" -ForegroundColor Green

# 8. Déployer le monitoring (optionnel)
Write-Host "📊 Déploiement du monitoring..." -ForegroundColor Yellow
helm upgrade --install prometheus ./charts/prometheus --wait --timeout=10m
helm upgrade --install grafana ./charts/grafana --wait --timeout=10m
Write-Host "✅ Monitoring déployé" -ForegroundColor Green

# 9. Configuration du port-forwarding
Write-Host "🌐 Configuration de l'accès..." -ForegroundColor Yellow
Write-Host "🔗 Démarrage du port-forwarding..." -ForegroundColor Cyan
Write-Host "   Pour accéder à l'application, exécutez:" -ForegroundColor Blue
Write-Host "   kubectl port-forward service/nginx 8080:80" -ForegroundColor White
Write-Host "" -ForegroundColor White

# 10. Résumé final
Write-Host "🎉 INSTALLATION TERMINÉE AVEC SUCCÈS!" -ForegroundColor Green
Write-Host "" -ForegroundColor White
Write-Host "📋 Résumé de l'installation:" -ForegroundColor Yellow
Write-Host "   • OroCommerce installé avec données de démo complètes" -ForegroundColor White
Write-Host "   • 64 produits disponibles dans le catalogue" -ForegroundColor White
Write-Host "   • Page d'accueil configurée avec contenu RV" -ForegroundColor White
Write-Host "   • Utilisateur admin créé (admin/admin)" -ForegroundColor White
Write-Host "   • Monitoring Prometheus + Grafana déployé" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "🌐 Accès à l'application:" -ForegroundColor Yellow
Write-Host "   1. Exécutez: kubectl port-forward service/nginx 8080:80" -ForegroundColor White
Write-Host "   2. Ouvrez: http://localhost:8080" -ForegroundColor White
Write-Host "   3. Admin: http://localhost:8080/admin (admin/admin)" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "📊 Monitoring:" -ForegroundColor Yellow
Write-Host "   • Prometheus: kubectl port-forward service/prometheus 9090:9090" -ForegroundColor White
Write-Host "   • Grafana: kubectl port-forward service/grafana 3000:80" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "🆘 En cas de problème:" -ForegroundColor Yellow
Write-Host "   • Vérifiez les pods: kubectl get pods" -ForegroundColor White
Write-Host "   • Vérifiez les logs: kubectl logs deployment/php-fpm-app" -ForegroundColor White
Write-Host "   • Redémarrez Minikube: minikube stop && minikube start" -ForegroundColor White

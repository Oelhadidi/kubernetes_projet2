# Script de validation du déploiement OroCommerce sur Kubernetes
# Teste tous les composants et valide le bon fonctionnement

Write-Host "=== Validation du déploiement OroCommerce Kubernetes ===" -ForegroundColor Green

$ErrorCount = 0

# Fonction pour tester un endpoint
function Test-Endpoint {
    param(
        [string]$Name,
        [string]$Url,
        [int]$ExpectedStatusCode = 200
    )
    
    try {
        Write-Host "🔍 Test de $Name..." -ForegroundColor Cyan
        $response = Invoke-WebRequest -Uri $Url -Method Head -TimeoutSec 10
        if ($response.StatusCode -eq $ExpectedStatusCode) {
            Write-Host "✅ $Name : OK (Status: $($response.StatusCode))" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "❌ $Name : ERREUR (Status: $($response.StatusCode))" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "❌ $Name : ERREUR ($($_.Exception.Message))" -ForegroundColor Red
        return $false
    }
}

# Fonction pour vérifier l'état des pods
function Test-Pods {
    Write-Host "🔍 Vérification de l'état des pods..." -ForegroundColor Cyan
    
    $pods = kubectl get pods --no-headers
    $failedPods = 0
    
    foreach ($pod in $pods) {
        $fields = $pod -split '\s+'
        $name = $fields[0]
        $ready = $fields[1]
        $status = $fields[2]
        
        if ($status -ne "Running" -and $status -ne "Completed") {
            Write-Host "❌ Pod $name : $status" -ForegroundColor Red
            $failedPods++
        }
        else {
            Write-Host "✅ Pod $name : $status" -ForegroundColor Green
        }
    }
    
    return $failedPods -eq 0
}

# Fonction pour vérifier les services
function Test-Services {
    Write-Host "🔍 Vérification des services..." -ForegroundColor Cyan
    
    $requiredServices = @("nginx", "php-fpm-app", "postgresql", "redis", "elasticsearch", "prometheus", "grafana")
    $services = kubectl get services --no-headers
    $missingServices = 0
    
    foreach ($requiredService in $requiredServices) {
        $found = $false
        foreach ($service in $services) {
            if ($service -match $requiredService) {
                Write-Host "✅ Service $requiredService : Trouvé" -ForegroundColor Green
                $found = $true
                break
            }
        }
        if (-not $found) {
            Write-Host "❌ Service $requiredService : Manquant" -ForegroundColor Red
            $missingServices++
        }
    }
    
    return $missingServices -eq 0
}

# Fonction pour vérifier les secrets
function Test-Secrets {
    Write-Host "🔍 Vérification des secrets..." -ForegroundColor Cyan
    
    $requiredSecrets = @("postgresql-secret", "orocommerce-secret", "grafana-secret")
    $secrets = kubectl get secrets --no-headers
    $missingSecrets = 0
    
    foreach ($requiredSecret in $requiredSecrets) {
        $found = $false
        foreach ($secret in $secrets) {
            if ($secret -match $requiredSecret) {
                Write-Host "✅ Secret $requiredSecret : Trouvé" -ForegroundColor Green
                $found = $true
                break
            }
        }
        if (-not $found) {
            Write-Host "❌ Secret $requiredSecret : Manquant" -ForegroundColor Red
            $missingSecrets++
        }
    }
    
    return $missingSecrets -eq 0
}

# Tests de l'infrastructure
Write-Host "`n📋 === Tests de l'infrastructure ===" -ForegroundColor Yellow

if (-not (Test-Pods)) {
    $ErrorCount++
}

if (-not (Test-Services)) {
    $ErrorCount++
}

if (-not (Test-Secrets)) {
    $ErrorCount++
}

# Tests des endpoints (nécessite des port-forwards actifs)
Write-Host "`n🌐 === Tests des endpoints ===" -ForegroundColor Yellow
Write-Host "Note: Ces tests nécessitent que les port-forwards soient actifs" -ForegroundColor Gray

# Test application principale
if (-not (Test-Endpoint "Application OroCommerce" "http://localhost:8080" 200)) {
    Write-Host "💡 Pour activer: kubectl port-forward service/nginx 8080:80" -ForegroundColor Gray
    $ErrorCount++
}

# Test Prometheus
if (-not (Test-Endpoint "Prometheus" "http://localhost:9090" 405)) {
    # 405 = Method Not Allowed pour HEAD
    Write-Host "💡 Pour activer: kubectl port-forward service/prometheus 9090:9090" -ForegroundColor Gray
    $ErrorCount++
}

# Test Grafana
if (-not (Test-Endpoint "Grafana" "http://localhost:3000" 302)) {
    # 302 = Redirect to login
    Write-Host "💡 Pour activer: kubectl port-forward service/grafana 3000:3000" -ForegroundColor Gray
    $ErrorCount++
}

# Résumé
Write-Host "`n📊 === Résumé de la validation ===" -ForegroundColor Yellow

if ($ErrorCount -eq 0) {
    Write-Host "🎉 SUCCÈS : Tous les tests sont passés !" -ForegroundColor Green
    Write-Host "✅ Infrastructure Kubernetes opérationnelle" -ForegroundColor Green
    Write-Host "✅ Application OroCommerce accessible" -ForegroundColor Green
    Write-Host "✅ Monitoring Prometheus/Grafana fonctionnel" -ForegroundColor Green
    Write-Host "✅ Sécurité avec Secrets configurée" -ForegroundColor Green
}
else {
    Write-Host "⚠️  ATTENTION : $ErrorCount erreur(s) détectée(s)" -ForegroundColor Red
    Write-Host "Vérifiez les messages d'erreur ci-dessus" -ForegroundColor Red
}

Write-Host "`n🔗 === Liens d'accès ===" -ForegroundColor Cyan
Write-Host "📱 Application : http://localhost:8080" -ForegroundColor White
Write-Host "📊 Prometheus : http://localhost:9090" -ForegroundColor White  
Write-Host "📈 Grafana : http://localhost:3000 (admin/admin123)" -ForegroundColor White

Write-Host "`n🛠️  === Commandes utiles ===" -ForegroundColor Cyan
Write-Host "kubectl get pods                 # État des pods" -ForegroundColor White
Write-Host "kubectl get services            # Services exposés" -ForegroundColor White
Write-Host "helm list                       # Releases Helm" -ForegroundColor White
Write-Host "kubectl logs -f deployment/php-fpm-app  # Logs application" -ForegroundColor White

exit $ErrorCount

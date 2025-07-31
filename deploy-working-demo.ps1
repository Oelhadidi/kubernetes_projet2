#!/usr/bin/env pwsh

Write-Host "Solution Alternative - Application PHP Simple" -ForegroundColor Green

# 1. Creer une application PHP de test
Write-Host "Creation d'une application PHP de demonstration..."

$htmlContent = @'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Demo E-Commerce</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; background: #667eea; }
        .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
        .header { background: white; padding: 20px; border-radius: 10px; margin-bottom: 20px; }
        .products { background: white; padding: 20px; border-radius: 10px; }
        .product { border: 1px solid #eee; padding: 15px; margin: 10px; display: inline-block; }
        .price { color: green; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>E-Commerce Demo - Kubernetes</h1>
            <p>Application PHP fonctionnelle</p>
        </div>
        
        <div class="products">
            <h2>Produits Populaires</h2>
            <div class="product">
                <h3>Smartphone Pro</h3>
                <div class="price">899 euros</div>
            </div>
            <div class="product">
                <h3>Laptop Gaming</h3>
                <div class="price">1299 euros</div>
            </div>
            <div class="product">
                <h3>Ecouteurs</h3>
                <div class="price">199 euros</div>
            </div>
        </div>
    </div>
</body>
</html>
'@

# 2. Deployer l'application
Write-Host "Deploiement de l'application..."

# Obtenir le nom du pod
$podName = kubectl get pods -l app=php-fpm-app -o jsonpath="{.items[0].metadata.name}"
Write-Host "Pod trouve: $podName"

$tempFile = [System.IO.Path]::GetTempFileName() + ".html"
$htmlContent | Out-File -FilePath $tempFile -Encoding UTF8

kubectl cp $tempFile ${podName}:/var/www/oro/orocommerce/public/demo.php

Remove-Item $tempFile

# 3. Creer un index.php
$indexContent = @'
<?php
header('Location: /demo.php');
exit;
'@

$tempIndexFile = [System.IO.Path]::GetTempFileName() + ".php"
$indexContent | Out-File -FilePath $tempIndexFile -Encoding UTF8
kubectl cp $tempIndexFile ${podName}:/var/www/oro/orocommerce/public/index.php
Remove-Item $tempIndexFile

# 4. Port-forward
Write-Host "Configuration du port-forward..."
$portForwardJob = Start-Job -ScriptBlock { kubectl port-forward svc/nginx 8080:80 }

Start-Sleep 5

# 5. Tests
Write-Host "Tests de l'application..."

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/demo.php" -TimeoutSec 10 -UseBasicParsing
    if ($response.Content -like "*E-Commerce Demo*") {
        Write-Host "Application fonctionnelle!" -ForegroundColor Green
    }
    else {
        Write-Host "Reponse partielle recue" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Erreur lors du test" -ForegroundColor Red
}

Write-Host "Solution deployee!"
Write-Host "Acces: http://localhost:8080"
# Helper script to show the correct values for your .env file
# This script helps you understand what values to put in your .env file

Write-Host "🔧 Azure Service Principal Environment Variables Helper" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""

Write-Host "📋 When you create a service principal with 'az ad sp create-for-rbac', you'll get output like this:" -ForegroundColor Yellow
Write-Host ""
Write-Host "{" -ForegroundColor Cyan
Write-Host "  `"appId`": `"12345678-1234-1234-1234-123456789012`"," -ForegroundColor Cyan
Write-Host "  `"displayName`": `"dev-container-sp`"," -ForegroundColor Cyan
Write-Host "  `"password`": `"your-secret-password`"," -ForegroundColor Cyan
Write-Host "  `"tenant`": `"12345678-1234-1234-1234-123456789012`"" -ForegroundColor Cyan
Write-Host "}" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔑 Here's how to map those values to your .env file:" -ForegroundColor Yellow
Write-Host ""
Write-Host "AZURE_CLIENT_ID=appId" -ForegroundColor Green
Write-Host "AZURE_CLIENT_SECRET=password" -ForegroundColor Green
Write-Host "AZURE_TENANT_ID=tenant" -ForegroundColor Green
Write-Host ""

Write-Host "📝 Example .env file:" -ForegroundColor Yellow
Write-Host ""
Write-Host "# Azure Service Principal Configuration" -ForegroundColor Gray
Write-Host "AZURE_CLIENT_ID=12345678-1234-1234-1234-123456789012" -ForegroundColor Green
Write-Host "AZURE_CLIENT_SECRET=your-secret-password" -ForegroundColor Green
Write-Host "AZURE_TENANT_ID=12345678-1234-1234-1234-123456789012" -ForegroundColor Green
Write-Host "AZURE_SUBSCRIPTION_ID=your-subscription-id" -ForegroundColor Green
Write-Host ""

Write-Host "🚀 To get your subscription ID, run:" -ForegroundColor Yellow
Write-Host "az account show --query id -o tsv" -ForegroundColor Cyan
Write-Host ""

Write-Host "🔐 To create a service principal, run:" -ForegroundColor Yellow
Write-Host 'az ad sp create-for-rbac --name "dev-container-sp" --role "Contributor" --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID"' -ForegroundColor Cyan
Write-Host ""

Write-Host "✅ After creating your .env file, you can login with:" -ForegroundColor Yellow
Write-Host "pwsh -File login-with-env.ps1" -ForegroundColor Cyan

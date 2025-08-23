# PowerShell script to deploy the sample Bicep template
# This script demonstrates how to use the service principal authentication

param(
  [Parameter(Mandatory = $true)]
  [string]$ResourceGroupName,

  [Parameter(Mandatory = $false)]
  [string]$Location = "eastus",

  [Parameter(Mandatory = $false)]
  [string]$AppServicePlanSku = "F1"
)

# Check if we're logged in
try {
  $context = Get-AzContext
  if (-not $context) {
    Write-Host "❌ Not logged in to Azure. Please run the login script first." -ForegroundColor Red
    Write-Host "Use: ./login-with-sp.sh or pwsh -File login-with-sp.ps1" -ForegroundColor Yellow
    exit 1
  }
  Write-Host "✅ Logged in as: $($context.Account.Id)" -ForegroundColor Green
}
catch {
  Write-Host "❌ Error checking Azure context. Please login first." -ForegroundColor Red
  exit 1
}

# Check if resource group exists, create if it doesn't
try {
  $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
  if (-not $rg) {
    Write-Host "📦 Creating resource group: $ResourceGroupName in $Location" -ForegroundColor Yellow
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location
    Write-Host "✅ Resource group created successfully" -ForegroundColor Green
  }
  else {
    Write-Host "✅ Resource group exists: $ResourceGroupName" -ForegroundColor Green
  }
}
catch {
  Write-Host "❌ Error creating/checking resource group: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}

# Deploy the Bicep template
try {
  Write-Host "🚀 Starting Bicep deployment..." -ForegroundColor Yellow

  $deploymentParams = @{
    ResourceGroupName = $ResourceGroupName
    TemplateFile      = "main.bicep"
    AppServicePlanSku = $AppServicePlanSku
    Verbose           = $true
  }

  $deployment = New-AzResourceGroupDeployment @deploymentParams

  Write-Host "✅ Deployment completed successfully!" -ForegroundColor Green
  Write-Host ""
  Write-Host "📋 Deployment Outputs:" -ForegroundColor Cyan
  Write-Host "  Storage Account: $($deployment.Outputs.storageAccountName.Value)" -ForegroundColor White
  Write-Host "  Web App Name: $($deployment.Outputs.webAppName.Value)" -ForegroundColor White
  Write-Host "  Web App URL: $($deployment.Outputs.webAppUrl.Value)" -ForegroundColor White
  Write-Host ""
  Write-Host "🔗 You can access your web app at: $($deployment.Outputs.webAppUrl.Value)" -ForegroundColor Green

}
catch {
  Write-Host "❌ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
  exit 1
}

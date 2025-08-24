# PowerShell script to login with environment variables loaded from .env file
# This script loads the .env file and then runs the login command

Write-Host "🔐 Loading environment variables from .env file..." -ForegroundColor Green

# Check if .env file exists
if (-not (Test-Path ".env")) {
  Write-Host "❌ Error: .env file not found!" -ForegroundColor Red
  Write-Host "Please create a .env file with your Azure service principal credentials." -ForegroundColor Yellow
  Write-Host "You can copy from env.example as a starting point." -ForegroundColor Yellow
  exit 1
}

# Load environment variables from .env file
Get-Content ".env" | ForEach-Object {
  if ($_ -match '^([^#][^=]+)=(.*)$') {
    $name = $matches[1].Trim()
    $value = $matches[2].Trim()
    # Remove quotes if present
    if ($value -match '^["''](.*)["'']$') {
      $value = $matches[1]
    }
    [Environment]::SetEnvironmentVariable($name, $value, "Process")
    Write-Host "Loaded: $name" -ForegroundColor Cyan
  }
}

Write-Host "✅ Environment variables loaded successfully!" -ForegroundColor Green

# Now run the original login script
Write-Host "🔐 Running Azure login..." -ForegroundColor Green
& "$PSScriptRoot\login-with-sp.ps1"

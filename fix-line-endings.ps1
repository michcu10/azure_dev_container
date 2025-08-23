# PowerShell script to fix line endings for shell scripts and environment files
# This converts Windows line endings (CRLF) to Unix line endings (LF)

Write-Host "Fixing line endings for shell scripts and environment files..." -ForegroundColor Green

# Files to fix
$files = @(
  "env.example",
  "create-service-principal.sh",
  "start-dev-container.sh"
)

foreach ($file in $files) {
  if (Test-Path $file) {
    Write-Host "Fixing line endings in $file..." -ForegroundColor Yellow
    (Get-Content $file -Raw) -replace "`r`n", "`n" | Set-Content $file -NoNewline -Encoding UTF8
    Write-Host "✓ Fixed $file" -ForegroundColor Green
  }
  else {
    Write-Host "⚠ File $file not found, skipping..." -ForegroundColor Yellow
  }
}

Write-Host "Line ending fix complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Now you can safely copy env.example to .env and source it in the dev container:" -ForegroundColor Cyan
Write-Host "  cp env.example .env" -ForegroundColor White
Write-Host "  source .env" -ForegroundColor White

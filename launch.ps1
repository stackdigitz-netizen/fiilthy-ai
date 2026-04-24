# FiiLTHY SaaS — Automated Launch Script (PowerShell)
# Run: .\launch.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   FiiLTHY SaaS — LAUNCH PIPELINE" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

function Test-Command {
    param($Command)
    return [bool](Get-Command $Command -ErrorAction SilentlyContinue)
}

# Check prerequisites
Write-Host "[1/6] Checking prerequisites..." -ForegroundColor Yellow
$missing = @()

if (-not (Test-Command "railway")) { $missing += "Railway CLI (npm install -g @railway/cli)" }
if (-not (Test-Command "vercel")) { $missing += "Vercel CLI (npm install -g vercel)" }

if ($missing.Count -gt 0) {
    Write-Host "MISSING TOOLS:" -ForegroundColor Red
    $missing | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Host ""
    Write-Host "Install missing tools and re-run this script." -ForegroundColor Red
    exit 1
}

Write-Host "  All tools found." -ForegroundColor Green
Write-Host ""

# Check env vars exist
Write-Host "[2/6] Checking environment configuration..." -ForegroundColor Yellow
$envFile = "ceo/backend/.env"
if (-not (Test-Path $envFile)) {
    Write-Host "  WARNING: ceo/backend/.env not found!" -ForegroundColor Red
    Write-Host "  Copy ceo/backend/.env.example to ceo/backend/.env and fill in values." -ForegroundColor Yellow
    Write-Host ""
    $proceed = Read-Host "Continue anyway? (y/n)"
    if ($proceed -ne "y") { exit 1 }
} else {
    Write-Host "  .env file found." -ForegroundColor Green
}
Write-Host ""

# Deploy Backend
Write-Host "[3/6] Deploying BACKEND to Railway..." -ForegroundColor Yellow
Set-Location ceo/backend
Write-Host "  Running: railway up" -ForegroundColor Gray
railway up
if ($LASTEXITCODE -ne 0) {
    Write-Host "  Backend deployment FAILED." -ForegroundColor Red
    Set-Location ../..
    exit 1
}
Write-Host "  Backend deployed successfully!" -ForegroundColor Green

# Get Railway domain
Write-Host "  Fetching Railway domain..." -ForegroundColor Gray
$railwayDomain = railway domain 2>$null
if ($railwayDomain) {
    Write-Host "  Backend URL: $railwayDomain" -ForegroundColor Cyan
    $env:RAILWAY_URL = $railwayDomain
} else {
    Write-Host "  Could not fetch domain. Check Railway dashboard." -ForegroundColor Yellow
}
Set-Location ../..
Write-Host ""

# Deploy Frontend
Write-Host "[4/6] Deploying FRONTEND to Vercel..." -ForegroundColor Yellow
Set-Location ceo/frontend
Write-Host "  Running: vercel --prod" -ForegroundColor Gray
vercel --prod
if ($LASTEXITCODE -ne 0) {
    Write-Host "  Frontend deployment FAILED." -ForegroundColor Red
    Set-Location ../..
    exit 1
}
Write-Host "  Frontend deployed successfully!" -ForegroundColor Green
Set-Location ../..
Write-Host ""

# Final output
Write-Host "========================================" -ForegroundColor Green
Write-Host "   DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "  1. Open your Vercel URL (check dashboard)" -ForegroundColor Gray
Write-Host "  2. Sign up and test the full flow" -ForegroundColor Gray
Write-Host "  3. Use Stripe test card: 4242 4242 4242 4242" -ForegroundColor Gray
Write-Host "  4. Update Stripe webhook URL with your Railway domain" -ForegroundColor Gray
Write-Host ""
Write-Host "For detailed steps, see LAUNCH_NOW.md" -ForegroundColor Cyan


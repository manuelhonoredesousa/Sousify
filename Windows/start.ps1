$ErrorActionPreference = "SilentlyContinue"

$basePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$menuFile = Join-Path $basePath "./src/main_menu.ps1"
$menuOfflineFile = Join-Path $basePath "./src/offline_menu.ps1"
$OfflineInstallerFile = Join-Path $basePath "./src/offline_installer.ps1"
$menuOnlineFile = Join-Path $basePath "./src/online_menu_winget.ps1"
$OnlineInstallerFile = Join-Path $basePath "./src/online_installer_winget.ps1"


if (!(Test-Path $menuFile)) {
    Write-Host "main_menu.ps1 não encontrado!" -ForegroundColor Red
    exit
}

if (!(Test-Path $menuOfflineFile)) {
    Write-Host "offline_menu.ps1 não encontrado!" -ForegroundColor Red
    exit
}

if (!(Test-Path $menuOnlineFile)) {
    Write-Host "online_menu_winget.ps1 não encontrado!" -ForegroundColor Red
    exit
}

if (!(Test-Path $OnlineInstallerFile)) {
    Write-Host "online_installer_winget.ps1 não encontrado!" -ForegroundColor Red
    exit
}

if (!(Test-Path $OfflineInstallerFile)) {
    Write-Host "offline_installer_winget.ps1 não encontrado!" -ForegroundColor Red
    exit
}

Clear-Host

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Sousify" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "By: Manuel de Sousa" -ForegroundColor Green
Write-Host "A iniciar sistema..." -ForegroundColor Yellow
Start-Sleep -Seconds 1

. $menuFile
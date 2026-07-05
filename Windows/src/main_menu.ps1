Clear-Host

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    Sousify" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Escolha o modo de instalação:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  [1] Online  - Instalar via internet (winget)" -ForegroundColor White
Write-Host "  [2] Offline - Instalar ficheiros locais (WinApp)" -ForegroundColor White
Write-Host ""
Write-Host "------------------------------------------"
Write-Host ""

$modo = Read-Host "Digite a opcao que deseja"

$basePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$onlineInstallerWingetFile = Join-Path $basePath "online_installer_winget.ps1"
$offlineInstallerFile = Join-Path $basePath "offline_installer.ps1"
$onlineMenuFile = Join-Path $basePath "online_menu_winget.ps1"
$offlineMenuFile = Join-Path $basePath "offline_menu.ps1"


if ($modo -eq "1") {

    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "          MODO ONLINE" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "A carregar aplicações online..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1

    $selectedApps = . $onlineMenuFile


    if (-not $selectedApps -or $selectedApps.Count -eq 0) {
    Write-Host ""
    Write-Host "Nenhuma aplicação selecionada no MENU ONLINE. A sair..." -ForegroundColor Red
    exit
}

. $onlineInstallerWingetFile $selectedApps

}

elseif ($modo -eq "2") {

    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "          MODO OFFLINE" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "A carregar aplicações offline..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1

    $selectedApps = . $offlineMenuFile


    if (-not $selectedApps -or $selectedApps.Count -eq 0) {
    Write-Host ""
    Write-Host "Nenhuma aplicação selecionada no MENU OFFLINE. A sair..." -ForegroundColor Red
    exit
}

. $offlineInstallerFile $selectedApps

}

# if($modo -ne "1" -and $modo -ne "2") {
else {
    Write-Host ""
    Write-Host "Opcao invalida!" -ForegroundColor Red
    Start-Sleep -Seconds 1
}





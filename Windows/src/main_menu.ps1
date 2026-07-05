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

# $basePath = $PSScriptRoot
$basePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$onlineInstallerWingetFile = Join-Path $basePath "online_installer_winget.ps1"
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

    . $onlineMenuFile
    $selectedApps = Start-Menu


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

    $selectedApps = . "$basePath\offline_menu.ps1"

    # if ($null -eq $selectedApps) {
    #     Write-Host "O menu offline terminou sem selecionar aplicações." -ForegroundColor Red
    #     Start-Sleep -Seconds 2
    #     return
    # }

    # if ($selectedApps.Count -gt 0) {

    #     Clear-Host
    #     Write-Host "Resumo Offline:" -ForegroundColor Cyan
    #     Write-Host ""

    #     foreach ($app in $selectedApps) {
    #         Write-Host "✔ $($app.Name)" -ForegroundColor Green
    #     }

    #     Write-Host ""
    #     $confirm = Read-Host "Iniciar instalação? (S/N)"

    #     if ($confirm -match "^[Ss]$") {
    #         . "$basePath\installer.ps1" $selectedApps
    #     }
    # }
    # else {
    #     Write-Host "Nenhuma aplicação foi selecionada no modo offline." -ForegroundColor Yellow
    #     Start-Sleep -Seconds 2
    # }
}

# if($modo -ne "1" -and $modo -ne "2") {
else {
    Write-Host ""
    Write-Host "Opcao invalida!" -ForegroundColor Red
    Start-Sleep -Seconds 1
}





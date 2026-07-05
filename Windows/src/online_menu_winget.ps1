$ErrorActionPreference = "SilentlyContinue"


$basePath = $PSScriptRoot
$onlineFile = Join-Path $basePath "online.txt"


if (!(Test-Path $onlineFile)) {
    Write-Host "online.txt não encontrado!" -ForegroundColor Red
    exit
}

$rawItems = Get-Content $onlineFile | Where-Object { $_ -ne "" }

$apps = @()

foreach ($line in $rawItems) {

    $parts = $line -split "\|"

    if ($parts.Count -ge 2) {

        $apps += [PSCustomObject]@{
            Name    = $parts[0].Trim()
            Command = $parts[1].Trim()
            Selected = $false
        }
    }
}

$currentIndex = 0
$total = $apps.Count

function Draw-Menu {

    Clear-Host

    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "     Sousify - Online Mode (Winget)" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Utilize os seguintes comandos:" -ForegroundColor Yellow
    Write-Host "(↑ ↓) Navegar | (Espaço) Selecionar | (A) Todos | (N) Nenhum | (I) Inverter | (Enter) OK | (Q) Sair"
    Write-Host ""
    Write-Host "------------------------------------------"
    Write-Host ""

    for ($i = 0; $i -lt $apps.Count; $i++) {

        $prefix = "  "

        if ($i -eq $currentIndex) {
            $prefix = "> "
        }

        $check = "[ ]"
        if ($apps[$i].Selected) {
            $check = "[X]"
        }

        if ($i -eq $currentIndex) {
            Write-Host "$prefix$check $($apps[$i].Name)" -ForegroundColor Cyan
        }
        else {
            Write-Host "$prefix$check $($apps[$i].Name)" -ForegroundColor White
        }
    }

    Write-Host ""
    Write-Host "------------------------------------------"

    $selectedCount = ($apps | Where-Object { $_.Selected }).Count

    Write-Host "Total selecionado: $selectedCount" -ForegroundColor Green
}


function Toggle-Current {
    $apps[$currentIndex].Selected = -not $apps[$currentIndex].Selected
}

function Select-All {
    for ($i = 0; $i -lt $apps.Count; $i++) {
        $apps[$i].Selected = $true
    }
}

function Deselect-All {
    for ($i = 0; $i -lt $apps.Count; $i++) {
        $apps[$i].Selected = $false
    }
}

function Invert-Selection {
    for ($i = 0; $i -lt $apps.Count; $i++) {
        $apps[$i].Selected = -not $apps[$i].Selected
    }
}

function Move-Down {
    if ($currentIndex -lt ($apps.Count - 1)) {
        $script:currentIndex++
    }
}

function Move-Up {
    if ($currentIndex -gt 0) {
        $script:currentIndex--
    }
}

function Get-Key {

    $key = [System.Console]::ReadKey($true)

    switch ($key.Key) {

        "UpArrow"   { Move-Up }
        "DownArrow" { Move-Down }

        "Spacebar"  { Toggle-Current }

        "A"         { Select-All }
        "N"         { Deselect-All }
        "I"         { Invert-Selection }

        "Q"         { 
            Clear-Host
            Write-Host "Cancelado pelo utilizador." -ForegroundColor Red
            exit
        }

        "Enter"     { return "CONFIRM" }
    }

    return $null
}

while ($true) {

    Draw-Menu

    $result = Get-Key

    if ($result -eq "CONFIRM") {

        $selectedApps = $apps | Where-Object { $_.Selected }

        Clear-Host

        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host "        CONFIRMAÇÃO DE INSTALAÇÃO" -ForegroundColor Cyan
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host ""

        if ($selectedApps.Count -eq 0) {
            Write-Host "Nenhuma aplicação selecionada." -ForegroundColor Red
            Start-Sleep -Seconds 2
            continue
        }

        Write-Host "Aplicações selecionadas:" -ForegroundColor Yellow
        Write-Host ""

        foreach ($app in $selectedApps) {
            Write-Host "✔ $($app.Name)" -ForegroundColor Green
        }

        Write-Host ""
        Write-Host "Total: $($selectedApps.Count)" -ForegroundColor Cyan
        Write-Host ""

        $confirm = Read-Host "Iniciar instalação? (S/N)"

        if ($confirm -match "^[Ss]$") {

            # usado para guardar resultado para o install.ps1
            $script:selectedApps = $selectedApps

            Clear-Host
            Write-Host "A iniciar instalação..." -ForegroundColor Green

            Start-Sleep -Seconds 1

            return $selectedApps
        }
        else {
            continue
        }
    }
}

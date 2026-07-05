$basePath = $PSScriptRoot
$appPath = Join-Path $basePath "../WinApp"

if ([string]::IsNullOrWhiteSpace($basePath)) {
    Write-Host "Não foi possível determinar a pasta do script offline." -ForegroundColor Red
    exit 1
}

if (!(Test-Path $appPath)) {
    Write-Host "Pasta WinApp não encontrada!" -ForegroundColor Red
    exit 1
}

# comando pAra ler ficheiros offline
$files = Get-ChildItem $appPath | Where-Object {
    $_.Extension -eq ".exe" -or $_.Extension -eq ".msi"
}

if ($files.Count -eq 0) {
    Write-Host "Nenhum instalador encontrado em WinApp." -ForegroundColor Yellow
    exit 1
}

# comando pAra criar lista de apps
$apps = @()

foreach ($file in $files) {
    $apps += [PSCustomObject]@{
        Name     = $file.BaseName
        Path     = $file.FullName
        Selected = $false
    }
}

$currentIndex = 0

function Draw-Menu {

    Clear-Host

    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "     Sousify - Offline Mode" -ForegroundColor Cyan
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Host "Utilize os seguintes comandos:" -ForegroundColor Yellow
    Write-Host "(↑ ↓) Navegar | (Espaço) Selecionar | (A) Todos | (N) Nenhum | (I) Inverter | (Enter) OK | (Q) Sair"
    Write-Host ""
    Write-Host "------------------------------------------"
    Write-Host ""

    for ($i = 0; $i -lt $apps.Count; $i++) {

        $cursor = "  "
        if ($i -eq $currentIndex) {
            $cursor = "> "
        }

        $check = "[ ]"
        if ($apps[$i].Selected) {
            $check = "[X]"
        }

        if ($i -eq $currentIndex) {
            Write-Host "$cursor$check $($apps[$i].Name)" -ForegroundColor Cyan
        }
        else {
            Write-Host "$cursor$check $($apps[$i].Name)"
        }
    }

    Write-Host ""
    Write-Host "------------------------------------------"

    $count = ($apps | Where-Object { $_.Selected }).Count
    Write-Host "Selecionados: $count" -ForegroundColor Green
}

function Toggle {
    $apps[$currentIndex].Selected = -not $apps[$currentIndex].Selected
}

function SelectAll {
    foreach ($a in $apps) { $a.Selected = $true }
}

function DeselectAll {
    foreach ($a in $apps) { $a.Selected = $false }
}

function Invert {
    foreach ($a in $apps) { $a.Selected = -not $a.Selected }
}

function Get-Key {

    $key = [System.Console]::ReadKey($true)

    switch ($key.Key) {

        "UpArrow"   { if ($currentIndex -gt 0) { $script:currentIndex-- } }
        "DownArrow" { if ($currentIndex -lt ($apps.Count - 1)) { $script:currentIndex++ } }

        "Spacebar"  { Toggle }

        "A" { SelectAll }
        "N" { DeselectAll }
        "I" { Invert }

        "Q" {
            Clear-Host
            Write-Host "Cancelado pelo utilizador." -ForegroundColor Red
            exit
        }

        "Enter" { return "CONFIRM" }
    }

    return $null
}


while ($true) {

    Draw-Menu

    $res = Get-Key

    if ($res -eq "CONFIRM") {

        $selected = $apps | Where-Object { $_.Selected }

        Clear-Host
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host "        CONFIRMAÇÃO OFFLINE" -ForegroundColor Cyan
        Write-Host "==========================================" -ForegroundColor Cyan
        Write-Host ""

        foreach ($a in $selected) {
            Write-Host "✔ $($a.Name)" -ForegroundColor Green
        }

        Write-Host ""
        Write-Host "Total: $($selected.Count)"
        Write-Host ""

        $c = Read-Host "Iniciar instalação? (S/N)"

        if ($c -match "^[Ss]$") {
            return $selected
        }
    }
}

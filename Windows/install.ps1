$ErrorActionPreference = "SilentlyContinue"

# Detectar SO
$os = (Get-CimInstance Win32_OperatingSystem).Caption

# Caminhos
$basePath = Split-Path -Parent $MyInvocation.MyCommand.Path
$winAppPath = Join-Path $basePath "WinApp"
$onlineFile = Join-Path $basePath "online.txt"
$logFile = Join-Path $basePath "install-log.txt"

# Função log
function Write-Log {
    param($msg)
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time - $msg" | Out-File -Append $logFile
}

# Header
Clear-Host
Write-Host "===================================" -ForegroundColor Cyan
Write-Host "   INSTALLER SYSTEM - WINDOWS" -ForegroundColor Cyan
Write-Host "   $os" -ForegroundColor DarkGray
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1 - Offline (WinApp)" -ForegroundColor Yellow
Write-Host "2 - Online (online.txt)" -ForegroundColor Yellow
Write-Host "CTRL + C para cancelar a qualquer momento" -ForegroundColor Red
Write-Host ""

$mode = Read-Host "Escolha o modo"

# OFFLINE
if ($mode -eq "1") {

    Write-Host "`nModo OFFLINE iniciado..." -ForegroundColor Green
    Write-Log "Modo OFFLINE iniciado"

    $files = Get-ChildItem $winAppPath | Sort-Object Name
    $total = $files.Count
    $i = 0

    foreach ($file in $files) {

        $i++
        $percent = [math]::Round(($i / $total) * 100)

        Write-Host "`n[$i/$total - $percent%] Instalando: $($file.Name)" -ForegroundColor Cyan
        Write-Log "A instalar: $($file.Name)"

        if ($file.Extension -eq ".exe") {
            Start-Process $file.FullName -Wait
        }
        elseif ($file.Extension -eq ".msi") {
            Start-Process "msiexec.exe" -ArgumentList "/i `"$($file.FullName)`"" -Wait
        }

        Write-Host "Concluído: $($file.Name)" -ForegroundColor Green
        Write-Log "Concluído: $($file.Name)"
    }

    Write-Host "`nInstalação offline finalizada!" -ForegroundColor Green
    Write-Log "OFFLINE finalizado"
}

# ONLINE
elseif ($mode -eq "2") {

    Write-Host "`nModo ONLINE iniciado..." -ForegroundColor Green
    Write-Log "Modo ONLINE iniciado"

    $commands = Get-Content $onlineFile
    $total = $commands.Count
    $i = 0

    foreach ($cmd in $commands) {

        if ($cmd.Trim() -ne "") {

            $i++
            $percent = [math]::Round(($i / $total) * 100)

            Write-Host "`n[$i/$total - $percent%] Executando: $cmd" -ForegroundColor Cyan
            Write-Log "Executando: $cmd"

            Invoke-Expression $cmd

            Write-Host "Concluído" -ForegroundColor Green
            Write-Log "Concluído: $cmd"
        }
    }

    Write-Host "`nInstalação online finalizada!" -ForegroundColor Green
    Write-Log "ONLINE finalizado"
}

else {
    Write-Host "Opção inválida" -ForegroundColor Red
}
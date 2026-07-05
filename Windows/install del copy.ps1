param (
    [Parameter(Mandatory = $true)]
    [array]$Apps
)

$basePath = $PSScriptRoot
$logFile = Join-Path $basePath "install-log.txt"

function Get-WingetPackageId {
    param(
        [string]$Command
    )

    if ($Command -match '--id\s+([^\s]+)') {
        return $Matches[1]
    }

    return $null
}

function Test-WingetInstalled {
    param(
        [string]$PackageId
    )

    if ([string]::IsNullOrWhiteSpace($PackageId)) {
        return $false
    }

    $output = & winget list --id $PackageId -e 2>$null | Out-String
    return $output -match [regex]::Escape($PackageId)
}

function Test-RegistryInstalled {
    param(
        [string]$AppName
    )

    if ([string]::IsNullOrWhiteSpace($AppName)) {
        return $false
    }

    $uninstallPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($uninstallPath in $uninstallPaths) {
        $matches = Get-ItemProperty $uninstallPath -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -and $_.DisplayName -like "*$AppName*" }

        if ($matches) {
            return $true
        }
    }

    return $false
}

function Test-AppInstalled {
    param(
        $App
    )

    if ($App.PSObject.Properties.Name -contains 'Command' -and $App.Command) {
        $wingetPackageId = Get-WingetPackageId -Command $App.Command

        if ($wingetPackageId) {
            return Test-WingetInstalled -PackageId $wingetPackageId
        }
    }

    if ($App.PSObject.Properties.Name -contains 'Path') {
        return Test-RegistryInstalled -AppName $App.Name
    }

    return $false
}

function Get-InstallCommand {
    param(
        $App,
        [bool]$ForceReinstall
    )

    if ($App.PSObject.Properties.Name -contains 'Command' -and $App.Command) {
        if ($ForceReinstall -and $App.Command -match '^\s*winget\s+install\b') {
            return ($App.Command -replace '^\s*winget\s+install\b', 'winget install --force')
        }

        return $App.Command
    }

    if ($App.PSObject.Properties.Name -contains 'Path' -and $App.Path) {
        return $App.Path
    }

    return $null
}

# Função de log
function Write-Log {
    param($msg)

    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$time - $msg" | Out-File -Append $logFile
}

# Header
Clear-Host
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "        INSTALLER ENGINE STARTED" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

$total = $Apps.Count
$index = 0

Write-Log "===== INSTALLATION STARTED ====="
Write-Log "Total apps: $total"

foreach ($app in $Apps) {

    $index++
    $percent = [math]::Round(($index / $total) * 100)
    $installed = Test-AppInstalled -App $app
    $installCommand = Get-InstallCommand -App $app -ForceReinstall $installed

    Write-Host ""
    Write-Host "[$index/$total - $percent%]" -ForegroundColor Cyan
    Write-Host "Instalando: $($app.Name)" -ForegroundColor Yellow

    if ($installed) {
        Write-Host "Já aparece instalado." -ForegroundColor DarkYellow
        $reinstall = Read-Host "Deseja reinstalar mesmo assim? (S/N)"

        if ($reinstall -notmatch "^[Ss]$") {
            Write-Host "Ignorado: $($app.Name)" -ForegroundColor DarkGray
            Write-Log "SKIPPED (already installed): $($app.Name)"
            continue
        }
    }

    Write-Log "Installing: $($app.Name)"
    Write-Log "Command: $installCommand"

    try {
        if ($app.PSObject.Properties.Name -contains 'Command' -and $installCommand) {
            Invoke-Expression $installCommand
        }
        elseif ($app.PSObject.Properties.Name -contains 'Path' -and $installCommand) {
            if ($installCommand -match '\.msi$') {
                Start-Process "msiexec.exe" -ArgumentList "/i `"$installCommand`"" -Wait
            }
            else {
                Start-Process $installCommand -Wait
            }
        }
        else {
            throw "Formato de aplicação não suportado."
        }

        Write-Host "✔ Concluído: $($app.Name)" -ForegroundColor Green
        Write-Log "SUCCESS: $($app.Name)"
    }
    catch {
        Write-Host "✖ Erro: $($app.Name)" -ForegroundColor Red
        Write-Log "ERROR: $($app.Name) - $($_.Exception.Message)"
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      INSTALAÇÃO FINALIZADA" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan

Write-Log "===== INSTALLATION FINISHED ====="

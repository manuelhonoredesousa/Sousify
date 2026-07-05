param (
	[Parameter(Mandatory = $true)]
	[array]$Apps
)

$basePath = $PSScriptRoot
$logFile = Join-Path $basePath "offline-install-log.txt"

function Write-Log {
	param(
		[string]$Message
	)

	$time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	"$time - $Message" | Out-File -Append -FilePath $logFile
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

if (-not $Apps -or $Apps.Count -eq 0) {
	Write-Host "Nenhuma aplicação selecionada." -ForegroundColor Yellow
	exit 0
}

Clear-Host
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "     INSTALLADOR OFFLINE" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Write-Log "===== OFFLINE INSTALLATION STARTED ====="
Write-Log "Total apps: $($Apps.Count)"

$index = 0

foreach ($app in $Apps) {
	$index++
	$percent = [math]::Round(($index / $Apps.Count) * 100)
	$installed = Test-RegistryInstalled -AppName $app.Name

	Write-Host ""
	Write-Host "[$index/$($Apps.Count) - $percent%]" -ForegroundColor Cyan
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
	Write-Log "Path: $($app.Path)"

	try {
		if (-not (Test-Path $app.Path)) {
			throw "Ficheiro não encontrado: $($app.Path)"
		}

		if ($app.Path -match '\.msi$') {
			Start-Process "msiexec.exe" -ArgumentList "/i `"$($app.Path)`" /qn /norestart" -Wait
		}
		else {
			Start-Process $app.Path -Wait
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
Write-Host "    INSTALAÇÃO OFFLINE FINALIZADA" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan

Write-Log "===== OFFLINE INSTALLATION FINISHED ====="

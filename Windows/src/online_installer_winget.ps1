param (
	[Parameter(Mandatory = $true)]
	[array]$Apps
)

$basePath = $PSScriptRoot
$logFile = Join-Path $basePath "online-install-log.txt"

function Write-Log {
	param(
		[string]$Message
	)

	$time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	"$time - $Message" | Out-File -Append -FilePath $logFile
}

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

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
	Write-Host "winget não está disponível neste sistema." -ForegroundColor Red
	exit 1
}

if (-not $Apps -or $Apps.Count -eq 0) {
	Write-Host "Nenhuma aplicacao selecionada." -ForegroundColor Yellow
	exit 0
}

Clear-Host
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "     INSTALLADOR ONLINE - WINGET" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Write-Log "===== ONLINE INSTALLATION STARTED ====="
Write-Log "Total apps: $($Apps.Count)"

$index = 0

foreach ($app in $Apps) {
	$index++
	$percent = [math]::Round(($index / $Apps.Count) * 100)
	$command = $app.Command
	$packageId = Get-WingetPackageId -Command $command
	$installed = Test-WingetInstalled -PackageId $packageId

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

		if ($command -match '^\s*winget\s+install\b') {
			$command = $command -replace '^\s*winget\s+install\b', 'winget install --force'
		}
	}

	Write-Log "Installing: $($app.Name)"
	Write-Log "Command: $command"

	try {
		Invoke-Expression $command
		Write-Host "✔ Concluido: $($app.Name)" -ForegroundColor Green
		Write-Log "SUCCESS: $($app.Name)"
	}
	catch {
		Write-Host "✖ Erro: $($app.Name)" -ForegroundColor Red
		Write-Log "ERROR: $($app.Name) - $($_.Exception.Message)"
	}
}

Write-Host ""
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "    INSTALACAO ONLINE FINALIZADA" -ForegroundColor Green
Write-Host "    Sousify - https://github.com/manuelhonoredesousa/Sousify" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Write-Log "===== ONLINE INSTALLATION FINISHED ====="

param(
	[string]$SourcePath = "",
	[string]$DestinationPath = "C:\Program Files\DAUM\PotPlayer\Extension\Subtitle\Translate\SubtitleTranslate - LM Studio.as",
	[string]$LogPath = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($SourcePath)) {
	$SourcePath = Join-Path -Path $PSScriptRoot -ChildPath "SubtitleTranslate - LM Studio.as"
}

if ([string]::IsNullOrWhiteSpace($LogPath)) {
	$LogPath = Join-Path -Path $PSScriptRoot -ChildPath "install_lmstudio_translator.log"
}

try {
	$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
	$backupPath = "$DestinationPath.bak-codex-$timestamp"

	Copy-Item -LiteralPath $DestinationPath -Destination $backupPath -Force
	Copy-Item -LiteralPath $SourcePath -Destination $DestinationPath -Force

	$installed = Get-Item -LiteralPath $DestinationPath
	$backup = Get-Item -LiteralPath $backupPath
	$lines = @(
		"OK",
		"Installed=$($installed.FullName)",
		"InstalledLength=$($installed.Length)",
		"InstalledLastWriteTime=$($installed.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))",
		"Backup=$($backup.FullName)",
		"BackupLength=$($backup.Length)",
		"BackupLastWriteTime=$($backup.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss'))"
	)

	Set-Content -LiteralPath $LogPath -Value $lines -Encoding UTF8
	Write-Output ($lines -join [Environment]::NewLine)
	exit 0
}
catch {
	$lines = @(
		"ERROR",
		$_.Exception.Message
	)

	Set-Content -LiteralPath $LogPath -Value $lines -Encoding UTF8
	Write-Error $_
	exit 1
}

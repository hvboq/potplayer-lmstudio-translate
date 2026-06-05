param(
	[string]$OutputDir = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
	$OutputDir = Join-Path -Path $PSScriptRoot -ChildPath "dist"
}

$packageName = "potplayer-lmstudio-translate"
$zipPath = Join-Path -Path $OutputDir -ChildPath "$packageName.zip"

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
Remove-Item -LiteralPath $zipPath -Force -ErrorAction SilentlyContinue

$files = @(
	(Join-Path -Path $PSScriptRoot -ChildPath "SubtitleTranslate - LM Studio.as"),
	(Join-Path -Path $PSScriptRoot -ChildPath "install_lmstudio_translator.ps1"),
	(Join-Path -Path $PSScriptRoot -ChildPath "README.md"),
	(Join-Path -Path $PSScriptRoot -ChildPath "README.ko.md"),
	(Join-Path -Path $PSScriptRoot -ChildPath "LICENSE")
)

foreach ($file in $files) {
	if (-not (Test-Path -LiteralPath $file)) {
		throw "Required file not found: $file"
	}
}

Compress-Archive -LiteralPath $files -DestinationPath $zipPath -Force
Get-Item -LiteralPath $zipPath | Select-Object FullName, Length, LastWriteTime

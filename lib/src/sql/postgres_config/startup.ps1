param(
    [string]$env = "development"
)

Set-Location -Path $PSScriptRoot

# Default to dev file
$envFile = ".env.development"
$composeFile = "podman-compose-dev.yml"

if ($env -eq "production") {
    $envFile = ".env.production"
    $composeFile = "podman-compose-prod.yml"
}

# Verificar que el archivo .env existe
if (!(Test-Path -Path $envFile)) {
    Write-Error "❌ Error: El archivo $envFile no existe."
    exit 1
}

Write-Host "🚀 Levantando ambiente '$env' con $PSScriptRoot\$envFile y $PSScriptRoot\$composeFile..."

# Cargar las variables de entorno desde el archivo .env
Get-Content -Path $envFile | Where-Object { $_ -match "^\s*([^#].*)\s*$" } | ForEach-Object {
    $matchResult = ($_ -match "^([A-Za-z0-9_]+)\s*=\s*(.*)$")
    if ($matchResult) {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2], [System.EnvironmentVariableTarget]::Process)
    }
}

podman system connection default podman-machine-default

podman-compose -f $composeFile up -d

param (
    [string]$env = "dev"
)

# Pararse en la carpeta del script
Set-Location -Path $PSScriptRoot

# Definir el archivo podman-compose según el entorno
$composeFile = "podman-compose-dev.yml"
if ($env -eq "prod") {
    $composeFile = "podman-compose-prod.yml"
}

# Verificar si el archivo existe
if (!(Test-Path -Path $composeFile)) {
    Write-Error "❌ Error: El archivo $composeFile no existe."
    exit 1
}

Write-Host "🚀 Apagando contenedores con $PSScriptRoot\$composeFile..."

# Apagar los contenedores
podman-compose -f $composeFile down
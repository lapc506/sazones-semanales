#!/bin/bash

# Parámetro de entorno (dev o prod)
env=${1:-"dev"}

# Pararse en la carpeta del script
cd "$(dirname "$0")"

# Definir la ruta del archivo .env correcto
envFile=".env.development"
composeFile="podman-compose-dev.yml"  # Default to dev file

if [ "$env" == "prod" ]; then
    envFile=".env.production"
    composeFile="podman-compose-prod.yml"  # Switch to prod file
fi

# Verificar si el archivo .env existe
if [ ! -f "$envFile" ]; then
    echo "❌ Error: El archivo $envFile no existe."
    exit 1
fi

echo "🚀 Levantando ambiente '$env' con $PWD/$envFile y $PWD/$composeFile..."

# Cargar las variables de entorno desde el archivo .env
while IFS='=' read -r key value; do
    if [[ "$key" =~ ^[A-Za-z0-9_]+$ ]]; then
        export "$key"="$value"
    fi
done < "$envFile"

# Configurar la conexión predeterminada de Podman
podman system connection default podman-machine-default

# Levantar los contenedores con podman-compose
podman-compose -f "$composeFile" up -d

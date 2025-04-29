#!/bin/bash

# Parámetro de entorno (dev o prod)
env=${1:-"dev"}

# Definir el archivo podman-compose según el entorno
composeFile="podman-compose-dev.yml"
if [ "$env" == "prod" ]; then
    composeFile="podman-compose-prod.yml"
fi

# Verificar si el archivo existe
if [ ! -f "$composeFile" ]; then
    echo "❌ Error: El archivo $composeFile no existe."
    exit 1
fi

echo "🚀 Apagando contenedores con $PWD/$composeFile..."

# Apagar los contenedores
podman-compose -f $composeFile down

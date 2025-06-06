#!/bin/bash

# 🔧 Script para DESARROLLO con Nodemon
# Puerto 6002 - Hot reload automático

echo "🔧 Iniciando modo DESARROLLO (Nodemon)..."
echo "📡 Puerto: 6002"
echo "🗄️ Base de datos: Docker en puerto 5436"

cd /home/administrador/docker/comparendos/apps/backend

# Verificar si la base de datos está ejecutándose
if ! docker ps | grep -q "comparendos-db"; then
    echo "🚀 Iniciando base de datos..."
    cd /home/administrador/docker/comparendos/infrastructure/docker
    docker compose up -d comparendos-db
    echo "⏳ Esperando que la base de datos esté lista..."
    sleep 10
    cd /home/administrador/docker/comparendos/apps/backend
fi

echo "🚀 Iniciando servidor de desarrollo..."
npm run dev

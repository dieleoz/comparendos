#!/bin/bash

# 🐳 Script para TESTING/CI con Docker
# Puerto 6003 - Ambiente completo en Docker

echo "🐳 Iniciando modo TESTING/CI (Docker)..."
echo "📡 Puerto: 6003"
echo "🗄️ Base de datos: Docker en puerto 5436"

cd /home/administrador/docker/comparendos/infrastructure/docker

echo "🛑 Deteniendo servicios existentes..."
docker compose down

echo "🔨 Construyendo imágenes..."
docker compose build --no-cache

echo "🚀 Iniciando servicios..."
docker compose up -d

echo "📋 Estado de los servicios:"
docker compose ps

echo "📊 Logs del backend:"
docker compose logs comparendos-back

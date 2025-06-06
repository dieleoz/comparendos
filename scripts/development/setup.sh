#!/bin/bash

# 🛠️ Script de Setup para Desarrollo
# Configura el entorno de desarrollo completo

set -e

echo "🚀 Configurando entorno de desarrollo..."

echo "📦 Instalando dependencias del backend..."
cd apps/backend
npm install
cd ../..

echo "📁 Creando directorios necesarios..."
mkdir -p data/uploads data/logs data/exports apps/backend/uploads apps/backend/logs apps/backend/exports

echo "🔧 Configurando permisos..."
chmod -R 755 data/
chmod -R 755 apps/
chmod +x scripts/development/*.sh

# Verificar que el archivo .env existe
echo "📄 Verificando archivo .env..."
if [ ! -f "apps/backend/.env" ]; then
    echo "❌ No se encontró archivo .env"
    echo "Copiando .env.example..."
    cp apps/backend/.env.example apps/backend/.env
fi

echo "✅ Entorno de desarrollo configurado correctamente"
echo ""
echo "🔥 Próximos pasos:"
echo "1. Ejecutar: docker-compose up --build"
echo "2. Acceder a: http://localhost:6002/api-docs para ver la documentación"
echo "3. Iniciar desarrollo de HU-CM-000 (Autenticación)"

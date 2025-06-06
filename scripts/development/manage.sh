#!/bin/bash

# Script para gestionar desarrollo vs Docker en puerto 6002
# Sin conflictos, sin complicaciones

case "$1" in
    "dev")
        echo "🔧 Iniciando modo DESARROLLO (Nodemon + DB Docker)"
        cd /home/administrador/docker/comparendos/infrastructure/docker
        docker compose up -d comparendos-db
        echo "✅ Base de datos iniciada en puerto 5436"
        cd /home/administrador/docker/comparendos/apps/backend
        echo "🚀 Iniciando nodemon en puerto 6002..."
        npm run dev
        ;;
    "docker")
        echo "🐳 Iniciando modo DOCKER COMPLETO"
        echo "⚠️  Deteniendo nodemon si existe..."
        pkill -f "nodemon\|node.*src/app.js" || echo "No hay procesos nodemon ejecutándose"
        cd /home/administrador/docker/comparendos/infrastructure/docker
        docker compose down
        docker compose up -d --build
        echo "✅ Docker completo iniciado en puerto 6002"
        ;;
    "stop")
        echo "🛑 Deteniendo todos los servicios"
        pkill -f "nodemon\|node.*src/app.js" || echo "No hay procesos nodemon"
        cd /home/administrador/docker/comparendos/infrastructure/docker
        docker compose down
        echo "✅ Todos los servicios detenidos"
        ;;
    "status")
        echo "📊 Estado de servicios:"
        echo ""
        echo "🔧 Nodemon (puerto 6002):"
        ps aux | grep -E "nodemon|node.*src/app.js" | grep -v grep || echo "No ejecutándose"
        echo ""
        echo "🐳 Docker containers:"
        cd /home/administrador/docker/comparendos/infrastructure/docker
        docker compose ps
        echo ""
        echo "🌐 Puerto 6002:"
        netstat -tlnp | grep :6002 || echo "Puerto libre"
        ;;
    *)
        echo "📖 Uso:"
        echo "  $0 dev     - Modo desarrollo (Nodemon + DB Docker)"
        echo "  $0 docker  - Modo Docker completo" 
        echo "  $0 stop    - Detener todo"
        echo "  $0 status  - Ver estado"
        ;;
esac

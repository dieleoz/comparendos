#!/bin/bash

# ==================================================
# 🚀 SCRIPT DE DESARROLLO PARA FRONTEND
# ==================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_message() {
    echo -e "${BLUE}[FRONTEND]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Directorio del script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRONTEND_DIR="$(dirname "$SCRIPT_DIR")"
DOCKER_DIR="$FRONTEND_DIR/../../infrastructure/docker"

print_message "🎯 Sistema de Comparendos - Frontend Development"
print_message "📂 Frontend Dir: $FRONTEND_DIR"
print_message "🐳 Docker Dir: $DOCKER_DIR"

# Función para verificar dependencias
check_dependencies() {
    print_message "🔍 Verificando dependencias..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado"
        exit 1
    fi
    
    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose no está instalado"
        exit 1
    fi
    
    print_success "Dependencias verificadas"
}

# Función para construir el frontend
build_frontend() {
    print_message "🏗️ Construyendo frontend..."
    cd "$DOCKER_DIR"
    docker compose build comparendos-frontend
    print_success "Frontend construido exitosamente"
}

# Función para iniciar modo desarrollo
start_dev() {
    print_message "🛠️ Iniciando frontend en modo desarrollo..."
    cd "$DOCKER_DIR"
    docker compose --profile development up comparendos-frontend-dev
}

# Función para iniciar modo producción
start_prod() {
    print_message "🚀 Iniciando frontend en modo producción..."
    cd "$DOCKER_DIR"
    docker compose up comparendos-frontend
}

# Función para parar servicios
stop_services() {
    print_message "🛑 Deteniendo servicios frontend..."
    cd "$DOCKER_DIR"
    docker compose stop comparendos-frontend comparendos-frontend-dev
    print_success "Servicios detenidos"
}

# Función para limpiar contenedores
clean() {
    print_message "🧹 Limpiando contenedores y volúmenes frontend..."
    cd "$DOCKER_DIR"
    docker compose down
    docker volume rm docker_frontend_node_modules docker_frontend_dev_node_modules 2>/dev/null || true
    print_success "Limpieza completada"
}

# Función para mostrar logs
show_logs() {
    print_message "📋 Mostrando logs del frontend..."
    cd "$DOCKER_DIR"
    docker compose logs -f comparendos-frontend comparendos-frontend-dev
}

# Función para instalar dependencias localmente
install_deps() {
    print_message "📦 Instalando dependencias localmente..."
    cd "$FRONTEND_DIR"
    npm install
    print_success "Dependencias instaladas"
}

# Función para ejecutar tests
run_tests() {
    print_message "🧪 Ejecutando tests..."
    cd "$FRONTEND_DIR"
    npm test
}

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}🎯 Sistema de Comparendos - Frontend Development${NC}"
    echo ""
    echo "Uso: $0 [COMANDO]"
    echo ""
    echo "Comandos disponibles:"
    echo "  build        - Construir imagen del frontend"
    echo "  dev          - Iniciar en modo desarrollo (puerto 3000)"
    echo "  prod         - Iniciar en modo producción (puerto 60005)"
    echo "  stop         - Detener servicios frontend"
    echo "  clean        - Limpiar contenedores y volúmenes"
    echo "  logs         - Mostrar logs del frontend"
    echo "  install      - Instalar dependencias localmente"
    echo "  test         - Ejecutar tests"
    echo "  help         - Mostrar esta ayuda"
    echo ""
    echo "URLs:"
    echo "  🛠️  Desarrollo: http://localhost:3000"
    echo "  🚀 Producción: http://localhost:60005"
    echo "  📡 API Backend: http://localhost:6002"
    echo ""
}

# Main
case "${1:-help}" in
    "build")
        check_dependencies
        build_frontend
        ;;
    "dev")
        check_dependencies
        start_dev
        ;;
    "prod")
        check_dependencies
        start_prod
        ;;
    "stop")
        check_dependencies
        stop_services
        ;;
    "clean")
        check_dependencies
        clean
        ;;
    "logs")
        check_dependencies
        show_logs
        ;;
    "install")
        install_deps
        ;;
    "test")
        run_tests
        ;;
    "help"|*)
        show_help
        ;;
esac

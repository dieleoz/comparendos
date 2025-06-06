#!/bin/bash

# Variables base
API_URL="http://localhost:6002"

# Función para mostrar el resultado de una prueba
echo_result() {
    if [ $? -eq 0 ]; then
        echo "✅ Prueba exitosa: $1"
    else
        echo "❌ Prueba fallida: $1"
    fi
}

# 1. Verificar endpoints disponibles
echo "\n1. Verificar endpoints disponibles"

echo "\nVerificar root endpoint"
curl -X GET "$API_URL/"
echo_result "Verificar root endpoint"

# 2. Verificar endpoints de autenticación
echo "\n2. Verificar endpoints de autenticación"

echo "\nVerificar login"
curl -X POST "$API_URL/api/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"email": "operador.nn@comparendos.com", "password": "operador123"}'
echo_result "Verificar login"

# 3. Verificar endpoints protegidos
echo "\n3. Verificar endpoints protegidos"

echo "\nVerificar ping"
curl -X GET "$API_URL/api/ping"
echo_result "Verificar ping"

# 4. Verificar endpoints de usuarios
echo "\n4. Verificar endpoints de usuarios"

echo "\nVerificar lista de usuarios"
curl -X GET "$API_URL/api/usuarios"
echo_result "Verificar lista de usuarios"

# 5. Verificar endpoints de roles
echo "\n5. Verificar endpoints de roles"

echo "\nVerificar lista de roles"
curl -X GET "$API_URL/api/roles"
echo_result "Verificar lista de roles"

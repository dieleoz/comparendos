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

# Función para obtener token
generate_token() {
    local email=$1
    local password=$2
    curl -s -X POST "$API_URL/api/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"email\": \"$email\", \"password\": \"$password\"}" | \
        jq -r '.token'
}

# Función para obtener información de usuario
echo_user_info() {
    local token=$1
    curl -X GET "$API_URL/api/me" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $token"
}

# 1. Prueba de roles y permisos
echo "\n1. Prueba de roles y permisos"

# Operador intentando acceder a datos de otro usuario
echo "\nOperador intentando acceder a datos de otro usuario"
token_operador=$(generate_token "operador.nn@comparendos.com" "operador123")
curl -X GET "$API_URL/api/usuarios/2" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token_operador"
echo_result "Operador intentando acceder a datos de otro usuario"

# Coordinador CCO accediendo a datos de usuarios
echo "\nCoordinador CCO accediendo a datos de usuarios"
token_coordinador=$(generate_token "coordinador.cco@comparendos.com" "coordinador123")
curl -X GET "$API_URL/api/usuarios" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token_coordinador"
echo_result "Coordinador CCO accediendo a datos de usuarios"

# 2. Prueba de estaciones
echo "\n2. Prueba de estaciones"

# Operador intentando acceder a estación no asignada
echo "\nOperador intentando acceder a estación no asignada"
curl -X GET "$API_URL/api/estaciones/2" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token_operador"
echo_result "Operador intentando acceder a estación no asignada"

# Operador accediendo a su estación asignada
echo "\nOperador accediendo a su estación asignada"
curl -X GET "$API_URL/api/estaciones/1" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token_operador"
echo_result "Operador accediendo a su estación asignada"

# 3. Prueba de modificaciones
echo "\n3. Prueba de modificaciones"

# Operador intentando modificar datos de otro usuario
echo "\nOperador intentando modificar datos de otro usuario"
curl -X PUT "$API_URL/api/usuarios/2" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token_operador" \
    -d '{"nombre": "Nuevo Nombre"}'
echo_result "Operador intentando modificar datos de otro usuario"

# Coordinador modificando datos de usuario
echo "\nCoordinador modificando datos de usuario"
curl -X PUT "$API_URL/api/usuarios/2" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $token_coordinador" \
    -d '{"nombre": "Nuevo Nombre"}'
echo_result "Coordinador modificando datos de usuario"

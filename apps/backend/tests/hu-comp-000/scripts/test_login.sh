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
# Función para obtener token y mostrar información
generate_token() {
    local email=$1
    local password=$2
    echo "\nEjecutando login con email: $email"
    
    # Preparar el JSON de manera segura
    # Asegurarse de que la contraseña es una cadena de texto
    local password_str="$password"
    
    local json_payload="{
        \"email\": \"$email\",
        \"password\": \"$password_str\"
    }"
    
    # Verificar que el JSON es válido
    echo $json_payload | jq . >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "❌ Error: No se pudo crear el JSON válido"
        return 1
    fi
    
    local response=$(curl -s -X POST "$API_URL/api/auth/login" \
        -H "Content-Type: application/json" \
        -d "$json_payload")
    
    echo "\nResponse:"
    echo $response
    
    echo "\nResponse formateado:"
    echo $response | jq .
    
    echo "\nToken extraído:"
    local token=$(echo $response | jq -r '.token')
    echo $token
    
    echo "\nVerificando token en endpoint protegido..."
    if [ -n "$token" ]; then
        echo "\nToken válido:"
        echo $token
        
        echo "\nVerificando acceso a usuarios..."
        curl -v -X GET "$API_URL/api/usuarios" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $token"
    else
        echo "❌ No se pudo obtener token"
    fi
}

# 1. Prueba de login exitoso (Operador Norte Neiva)
echo "\n1. Prueba de login exitoso (Operador Norte Neiva)"
generate_token "operador.nn@comparendos.com" "operador123"

echo "\n2. Prueba de login con email inválido"
generate_token "emailinvalido.com" "operador123"

echo "\n3. Prueba de login con contraseña inválida"
generate_token "operador.nn@comparendos.com" "contraseñaerronea"

echo "\n4. Prueba de login con campos vacíos"
generate_token "" ""

echo "\n5. Prueba de acceso a endpoint protegido sin token"
curl -X GET "$API_URL/api/usuarios" \
    -H "Content-Type: application/json"

echo "\n6. Prueba de acceso con token válido"
# Aquí no podemos probar con el token obtenido anteriormente ya que no lo guardamos
# Pero deberíamos ver el mensaje de error de token no proporcionado

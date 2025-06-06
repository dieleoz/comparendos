#!/bin/bash

# Script de pruebas para HU-COMP-000
# Ejecuta todas las validaciones necesarias para verificar que el error esté resuelto

echo "🧪 EJECUTANDO PRUEBAS HU-COMP-000"
echo "=================================="
echo "Fecha: $(date)"
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contador de pruebas
TESTS_PASSED=0
TESTS_FAILED=0

# Función para mostrar resultado de prueba
test_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}❌ $2${NC}"
        ((TESTS_FAILED++))
    fi
}

# Verificar que los servicios estén corriendo
echo "📋 Verificando servicios..."

# Verificar backend
curl -s http://localhost:6002 >/dev/null 2>&1
test_result $? "Backend corriendo en puerto 6002"

# Verificar frontend (intentar ambos puertos)
if curl -s http://localhost:60005 >/dev/null 2>&1; then
    test_result 0 "Frontend corriendo en puerto 60005 (Producción)"
elif curl -s http://localhost:6000 >/dev/null 2>&1; then
    test_result 0 "Frontend corriendo en puerto 6000 (Desarrollo)"
else
    test_result 1 "Frontend corriendo en puertos 60005 o 6000"
fi

echo ""

# Ejecutar prueba de compilación
echo "📋 Verificando compilación del frontend..."
cd /home/administrador/docker/comparendos/apps/frontend
npm run build >/dev/null 2>&1
test_result $? "Frontend compila sin errores"

echo ""

# Ejecutar prueba de endpoints
echo "📋 Verificando endpoints de autenticación..."

# Test login endpoint
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:6002/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "operador.nn@comparendos.com", "password": "operador123"}')

if echo "$LOGIN_RESPONSE" | jq -e '.success == true and .usuario != null and .token != null' >/dev/null 2>&1; then
    test_result 0 "Login endpoint retorna estructura correcta"
    TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token')
else
    test_result 1 "Login endpoint no retorna estructura correcta"
    TOKEN=""
fi

# Test me endpoint (solo si tenemos token)
if [ ! -z "$TOKEN" ]; then
    ME_RESPONSE=$(curl -s -X GET http://localhost:6002/api/auth/me \
      -H "Authorization: Bearer $TOKEN")
    
    if echo "$ME_RESPONSE" | jq -e '.success == true and .user != null' >/dev/null 2>&1; then
        test_result 0 "Me endpoint retorna estructura correcta"
    else
        test_result 1 "Me endpoint no retorna estructura correcta"
    fi
else
    test_result 1 "No se pudo obtener token para probar endpoint /me"
fi

echo ""

# Ejecutar prueba de regresión específica
echo "📋 Ejecutando prueba de regresión del error..."
cd /home/administrador/docker/comparendos/apps/frontend/tests/hu-comp-000
node error-resolution.js >/dev/null 2>&1
test_result $? "Prueba de regresión del error pasó"

echo ""

# Verificar archivos modificados
echo "📋 Verificando archivos de la solución..."

# Verificar que Dashboard.js tiene la validación defensiva
if grep -q "if (!user)" /home/administrador/docker/comparendos/apps/frontend/src/components/Dashboard.js; then
    test_result 0 "Dashboard.js contiene validación defensiva"
else
    test_result 1 "Dashboard.js no contiene validación defensiva"
fi

# Verificar que se usa optional chaining
if grep -q "user\?" /home/administrador/docker/comparendos/apps/frontend/src/components/Dashboard.js; then
    test_result 0 "Dashboard.js usa optional chaining"
else
    test_result 1 "Dashboard.js no usa optional chaining"
fi

# Verificar que App.js maneja ambas estructuras
if grep -q "response.usuario || response.user" /home/administrador/docker/comparendos/apps/frontend/src/App.js; then
    test_result 0 "App.js maneja ambas estructuras de datos"
else
    test_result 1 "App.js no maneja ambas estructuras de datos"
fi

echo ""

# Resumen final
echo "📊 RESUMEN DE PRUEBAS"
echo "====================="
echo -e "Pruebas pasadas: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Pruebas fallidas: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 TODAS LAS PRUEBAS PASARON${NC}"
    echo -e "${GREEN}El error 'Cannot read properties of undefined (reading 'id')' ha sido completamente resuelto.${NC}"
    exit 0
else
    echo -e "${RED}⚠️  ALGUNAS PRUEBAS FALLARON${NC}"
    echo -e "${YELLOW}Revisar los errores arriba y corregir antes de continuar.${NC}"
    exit 1
fi

#!/bin/bash

echo "🧪 EJECUTANDO PRUEBAS HU-COMP-000"
echo "=================================="
echo "Fecha: $(date)"
echo ""

# Verificar que los servicios estén corriendo
echo "📋 Verificando servicios..."

# Verificar backend
if curl -s http://localhost:6002 >/dev/null 2>&1; then
    echo "✅ Backend corriendo en puerto 6002"
else
    echo "❌ Backend NO está corriendo en puerto 6002"
fi

# Verificar frontend (intentar ambos puertos)
if curl -s http://localhost:60005 >/dev/null 2>&1; then
    echo "✅ Frontend corriendo en puerto 60005 (Producción)"
elif curl -s http://localhost:6000 >/dev/null 2>&1; then
    echo "✅ Frontend corriendo en puerto 6000 (Desarrollo)"
else
    echo "❌ Frontend NO está corriendo en puertos 60005 ni 6000"
fi

echo ""
echo "📋 Verificando compilación del frontend..."

# Ejecutar prueba de compilación
cd /home/administrador/docker/comparendos/apps/frontend
if npm run build >/dev/null 2>&1; then
    echo "✅ Frontend compila sin errores"
else
    echo "❌ Frontend NO compila sin errores"
fi

echo ""
echo "📋 Verificando endpoints de autenticación..."

# Test login endpoint
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:6002/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "operador.nn@comparendos.com", "password": "operador123"}')

if echo "$LOGIN_RESPONSE" | grep -q '"success":true'; then
    echo "✅ Login endpoint retorna respuesta exitosa"
else
    echo "❌ Login endpoint NO retorna respuesta exitosa"
fi

echo ""
echo "📋 Verificando archivos de la solución..."

# Verificar que Dashboard.js tiene la validación defensiva
if grep -q "if (!user)" /home/administrador/docker/comparendos/apps/frontend/src/components/Dashboard.js; then
    echo "✅ Dashboard.js contiene validación defensiva"
else
    echo "❌ Dashboard.js NO contiene validación defensiva"
fi

# Verificar que se usa optional chaining
if grep -q "user\?" /home/administrador/docker/comparendos/apps/frontend/src/components/Dashboard.js; then
    echo "✅ Dashboard.js usa optional chaining"
else
    echo "❌ Dashboard.js NO usa optional chaining"
fi

echo ""
echo "🎉 PRUEBAS COMPLETADAS"
echo "Revisar los resultados arriba para verificar el estado del sistema."

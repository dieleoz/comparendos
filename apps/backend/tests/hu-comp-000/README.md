# 📚 Estructura de Trabajo para HU-COMP-000

## 📁 Estructura de Directorios
```
tests/hu-comp-000/
├── scripts/          # Scripts de prueba y certificación
│   ├── test_login.sh     # Pruebas de autenticación
│   ├── test_roles.sh     # Pruebas de roles y permisos
│   └── test_endpoints.sh # Pruebas de endpoints
└── certificacion/  # Documentos de certificación
    └── certificacion-hu-comp-000.md
```

## 📋 Proceso de Trabajo

### 1. Recolección de Insumos
1. **Requisitos**
   - Revisar HU-COMP-000 en documentación
   - Verificar roles y permisos en base de datos
   - Documentar endpoints existentes

2. **Datos de Prueba**
   - Credenciales de prueba
   - Roles disponibles
   - Permisos por rol
   - Casos de uso específicos

### 2. Desarrollo de Tests
1. **Scripts de Prueba**
   - `test_auth.sh`: Pruebas de autenticación
   - `test_roles.sh`: Pruebas de roles y permisos
   - `test_security.sh`: Pruebas de seguridad

2. **Formato de Scripts**
   ```bash
   #!/bin/bash
   #
   # Descripción: Pruebas de autenticación
   #
   # Variables
   API_URL="http://localhost:6002"
   TEST_USER="test@test.com"
   TEST_PASS="TestPass123!"

   # Funciones de prueba
   test_login() {
       echo "Testing login..."
       curl -X POST "$API_URL/api/auth/login" \
           -H "Content-Type: application/json" \
           -d '{"email":"'$TEST_USER'","password":"'$TEST_PASS'"}'
   }
   ```

### 3. Actualización de Swagger
1. **Documentación de Endpoints**
   - Actualizar paths
   - Documentar parámetros
   - Especificar respuestas
   - Agregar ejemplos

2. **Formato Swagger**
   ```yaml
   paths:
     /api/auth/login:
       post:
         summary: Autenticación de usuario
         tags: [Autenticación]
         requestBody:
           required: true
           content:
             application/json:
               schema:
                 $ref: '#/components/schemas/LoginRequest'
   ```

### 4. Documentación
1. **Requerimientos Técnicos**
   - Documentar roles y permisos
   - Especificar endpoints
   - Detallar validaciones

2. **Arquitectura**
   - Diagramas de flujo
   - Esquema de seguridad
   - Middleware implementado

### 5. Certificación
1. **Evidencia de Pruebas**
   - Resultados de scripts
   - Logs de ejecución
   - Capturas de pantalla

2. **Certificación Final**
   - Estado de tests
   - Observaciones
   - Fecha de certificación

## 📝 Proceso de Certificación

1. **Preparación**
   - Verificar datos de prueba
   - Configurar ambiente
   - Revisar Swagger

2. **Ejecución**
   - Ejecutar scripts
   - Documentar resultados
   - Verificar logs

3. **Validación**
   - Comparar resultados
   - Verificar permisos
   - Validar seguridad

4. **Certificación**
   - Documentar estado
   - Registrar observaciones
   - Actualizar Swagger

# 📚 Sistema de Comparendos

Sistema integral de gestión de comparendos para el control y administración de infracciones de tránsito.

## 🎯 Estado Actual del Sistema (6 de Junio 2025)

### 🌐 URLs de Acceso
- **API Backend**: http://localhost:6002
- **Swagger UI**: http://localhost:6002/api-docs
- **Swagger JSON**: http://localhost:6002/api-docs.json
- **Frontend**: http://localhost:3000 (Desarrollo) / http://localhost:60005 (Producción)
- **Base de Datos**: localhost:5436

### 🎉 Frontend HU-COMP-000 Completado

✅ **Frontend de Login Implementado y Funcional**

El frontend para probar la HU-COMP-000 (Validaciones Generales de Seguridad y Roles) está completamente implementado con las siguientes características:

#### 🚀 Características del Frontend
- **Formulario de Login Moderno**: Interfaz elegante con gradientes y animaciones
- **Credenciales de Prueba Integradas**: Todas las credenciales aparecen en la interfaz para fácil testing
- **Dashboard Post-Login**: Muestra información completa del usuario autenticado
- **Diseño Responsivo**: Funciona perfectamente en móviles y desktop
- **Manejo de Errores**: Mensajes claros para errores de autenticación
- **Estados de Carga**: Indicadores visuales durante las operaciones

#### 🔑 Credenciales Clickeables en la Interfaz
El frontend incluye un panel con todas las credenciales de prueba que se pueden usar con un solo click:
- Operador Norte Neiva
- Operador Sur Neiva  
- Policía
- Coordinador ITS
- Regulador ANI

#### 🏃‍♂️ Ejecutar el Frontend
```bash
cd /home/administrador/docker/comparendos/apps/frontend
npm install
npm start
```

Acceso: http://localhost:3000

### 📡 Configuración de Red
- **Red Docker**: `comparendos-network` (bridge)
- **Puerto Base de Datos**: 5436 (mapeado a 5432 en el contenedor)

### ⚠️ ADVERTENCIA IMPORTANTE
**¡NO CAMBIAR LOS SIGUIENTES PUERTOS!**

### 🔐 Configuración Crítica de la Base de Datos

#### Proceso de Certificación
1. **Recolección de Insumos**
   - Verificar roles y permisos en base de datos
   - Documentar endpoints existentes
   - Recopilar credenciales de prueba

2. **Desarrollo de Tests**
   - Crear scripts de prueba
   - Documentar casos de uso
   - Especificar validaciones

3. **Documentación**
   - Actualizar Swagger
   - Crear documentación técnica
   - Registrar resultados de tests

4. **Certificación**

### 🔑 Credenciales de Prueba

#### Operadores de Báscula
- **Norte Neiva**: operador.nn@comparendos.com / operador123
- **Sur Neiva**: operador.sn@comparendos.com / operador123
- **Norte Flandes**: operador.nf@comparendos.com / operador123
- **Sur Flandes**: operador.sf@comparendos.com / operador123

#### Otros Roles
- **Policía**: police@comparendos.com / police123
- **Coordinador ITS**: coordinador.its@comparendos.com / coordinador123
- **Coordinador CCO**: coordinador.cco@comparendos.com / coordinador123
- **Regulador ANI**: ani@comparendos.com / ani123
- **Transportista**: transportista@comparendos.com / transportista123

**Nota**: Estas credenciales son para uso de prueba y solo deben ser utilizadas en el entorno de desarrollo.
   - Ejecutar tests completos
   - Documentar resultados
   - Actualizar estado de certificación

### 🔐 Configuración Crítica de la Base de Datos
- **Nombre de Usuario**: comparendos_user
- **Contraseña**: comparendos_pass
- **Nombre de Base de Datos**: comparendos_db
- **Puerto Interno**: 5432
- **Puerto Externo**: 5436

#### 🔐 Configuración de Autenticación
- **Algoritmo**: bcryptjs
- **Salt Rounds**: 10
- **Formato Token**: JWT
- **Duración Token**: 24 horas
- **Roles Implementados**: 1-7 (ADMIN, OPERADOR, POLICÍA, COORDINADOR_ITS, COORDINADOR_CCO, REGULADOR_ANI, AUDITOR, TRANSPORTISTA)

### 🛡️ Configuración Crítica de la Aplicación
- **Puerto Backend**: 6002
- **Red Docker**: comparendos-network

**¡ESTOS VALORES SON CRÍTICOS PARA EL FUNCIONAMIENTO DEL SISTEMA EN PRODUCCIÓN!**
**¡NO MODIFICAR BAJO NINGÚN CIRCUNSTANCIA!**

### 📝 Rutas API Disponibles

#### Estructura de Tests y Certificación
```
tests/
├── hu-comp-000/           # HU-COMP-000 - Validaciones Generales de Seguridad y Roles
│   ├── scripts/          # Scripts de prueba y certificación
│   │   ├── test_login.sh     # Pruebas de autenticación
│   │   ├── test_roles.sh     # Pruebas de roles y permisos
│   │   └── test_endpoints.sh # Pruebas de endpoints
│   └── certificacion/  # Documentos de certificación
│       └── certificacion-hu-comp-000.md
```

#### Rutas API Disponibles

#### Autenticación
- POST `/api/auth/login` - Iniciar sesión
- GET `/api/auth/me` - Obtener información del usuario
- POST `/api/auth/logout` - Cerrar sesión

#### Comparendos
- GET `/api/comparendos` - Listar comparendos
- GET `/api/comparendos/placa/:placa` - Comparendos por placa
- POST `/api/comparendos` - Crear comparendo
- PUT `/api/comparendos/:id` - Actualizar comparendo
- DELETE `/api/comparendos/:id` - Eliminar comparendo
- POST `/api/comparendos/carga-excel` - Cargar comparendos desde Excel
- POST `/api/comparendos/carga-json` - Cargar comparendos desde JSON

#### Vehículos
- GET `/api/vehiculos` - Listar vehículos
- GET `/api/vehiculos/placa/:placa` - Buscar vehículo por placa
- POST `/api/vehiculos` - Crear vehículo
- PUT `/api/vehiculos/:id` - Actualizar vehículo
- DELETE `/api/vehiculos/:id` - Eliminar vehículo

#### Historial
- GET `/api/historico` - Listar historial
- GET `/api/historico/placa/:placa` - Historial por placa
- POST `/api/historico/corregir` - Corregir registro
- POST `/api/historico/exportar` - Exportar datos
- POST `/api/historico/consolidar` - Consolidar datos

#### Pasos
- GET `/api/pasos` - Listar pasos
- GET `/api/pasos/placa/:placa` - Pasos por placa
- POST `/api/pasos` - Registrar paso
- PUT `/api/pasos/:id` - Actualizar paso

#### Exclusiones
- GET `/api/exclusiones` - Listar exclusiones
- POST `/api/exclusiones` - Crear exclusión
- PUT `/api/exclusiones/:id` - Actualizar exclusión
- DELETE `/api/exclusiones/:id` - Eliminar exclusión
- POST `/api/exclusiones/revertir` - Revertir exclusión

#### Peajes
- GET `/api/peajes` - Listar peajes
- POST `/api/peajes` - Crear peaje
- PUT `/api/peajes/:id` - Actualizar peaje
- DELETE `/api/peajes/:id` - Eliminar peaje

#### Sistema
- GET `/api/ping` - Verificar estado del servidor
- GET `/api/health` - Estado de salud del sistema

## 🚀 Inicio Rápido con Docker

### 📋 Prerrequisitos
- Docker Engine 20.10+
- Docker Compose 2.0+
- Mínimo 4GB RAM disponible
- Puertos libres: 3000, 6002, 60005, 5436

### 🎯 Comandos Principales

#### 🌟 Inicio Completo del Sistema
```bash
# Desde el directorio raíz
cd /home/administrador/docker/comparendos/infrastructure/docker

# Iniciar todo el sistema (Backend + Base de Datos + Frontend Producción)
docker compose up -d

# Ver logs en tiempo real
docker compose logs -f
```

#### 🛠️ Desarrollo Frontend
```bash
# Modo desarrollo con hot reload (puerto 3000)
docker compose --profile development up comparendos-frontend-dev

# Modo producción (puerto 60005)
docker compose up comparendos-frontend
```

#### 📱 URLs de Acceso Después del Deploy
- **🎨 Frontend Desarrollo**: http://localhost:3000 (Hot reload, ideal para desarrollar)
- **🚀 Frontend Producción**: http://localhost:60005 (Nginx optimizado)
- **📡 API Backend**: http://localhost:6002
- **📚 Swagger UI**: http://localhost:6002/api-docs
- **🗄️ Base de Datos**: localhost:5436

### 🔄 Gestión de Servicios

#### ⏸️ Detener Servicios
```bash
# Detener todo
docker compose down

# Detener solo frontend
docker compose stop comparendos-frontend comparendos-frontend-dev
```

#### 🧹 Limpieza Completa
```bash
# Limpiar contenedores, volúmenes y redes
docker compose down -v --remove-orphans

# Limpiar imágenes no utilizadas
docker system prune -a
```

#### 📦 Reconstruir Servicios
```bash
# Reconstruir solo frontend
docker compose build comparendos-frontend

# Reconstruir todo
docker compose build
```

### 💾 Volúmenes Persistentes

El sistema utiliza volúmenes Docker para persistir datos importantes:

#### 📚 Volúmenes de Node Modules (Evita reinstalar)
- `frontend_node_modules`: node_modules del frontend producción
- `frontend_dev_node_modules`: node_modules del frontend desarrollo  
- `backend_node_modules`: node_modules del backend

#### 💿 Volúmenes de Datos
- `postgres_data`: Datos de PostgreSQL
- `backend_logs`: Logs del backend

**✅ Ventajas de los volúmenes persistentes:**
- ⚡ No necesitas reinstalar dependencias cada vez
- 💾 Los datos se mantienen entre reinicios
- 🔄 Builds más rápidos
- 📦 Menos uso de ancho de banda

### 🎛️ Script de Desarrollo Frontend

Para mayor comodidad, usa el script incluido:

```bash
# Ir al directorio frontend
cd /home/administrador/docker/comparendos/apps/frontend

# Usar el script de desarrollo
./scripts/dev.sh help          # Ver ayuda
./scripts/dev.sh build         # Construir imagen
./scripts/dev.sh dev           # Modo desarrollo
./scripts/dev.sh prod          # Modo producción
./scripts/dev.sh logs          # Ver logs
./scripts/dev.sh stop          # Detener servicios
./scripts/dev.sh clean         # Limpiar todo
```

## 🚀 Ejecutar el Frontend para Probar HU-COMP-000

### 📋 Requisitos Previos
1. ✅ Backend ejecutándose en http://localhost:6002
2. ✅ Base de datos PostgreSQL en puerto 5436
3. ✅ Node.js versión 16 o superior

### 🏃‍♂️ Pasos para Ejecutar

1. **Navegar al directorio del frontend:**
```bash
cd /home/administrador/docker/comparendos/apps/frontend
```

2. **Instalar dependencias:**
```bash
npm install
```

3. **Ejecutar en modo desarrollo:**
```bash
npm start
```

4. **Acceder al frontend:**
- Abrir navegador en: http://localhost:3000
- El frontend se conectará automáticamente al backend en puerto 6002

### 🧪 Probar la HU-COMP-000

1. **Acceder al frontend:** http://localhost:3000
2. **Seleccionar credenciales:** Hacer click en cualquier credencial del panel
3. **Hacer login:** Presionar el botón "LOGIN"
4. **Verificar resultado:** El dashboard mostrará la información del usuario

### 🎯 Validaciones Realizadas

Al hacer login exitoso, el frontend validará:
- ✅ Autenticación correcta
- ✅ Token JWT válido
- ✅ Información del usuario
- ✅ Roles y permisos
- ✅ Sesión activa

### 📱 Funcionalidades del Frontend

#### Pantalla de Login
- Formulario elegante con gradientes
- Panel de credenciales clickeables
- Validación en tiempo real
- Manejo de errores
- Estados de carga

#### Dashboard Post-Login
- Información completa del usuario
- Detalles de la sesión
- Estado de certificación HU-COMP-000
- Botón de logout funcional

### 🔧 Configuración Técnica

- **Puerto Desarrollo:** 3000
- **Puerto Producción:** 30005 (con Docker)
- **Proxy API:** Configurado para http://localhost:6002
- **Framework:** React 18
- **Estilos:** CSS puro con diseño moderno
- 5432 (Postgres producción)
- 5441 (SIG DB)
- 3015 (SIG Backend)
- 4210 (SIG Frontend)
- 30005 (Nginx)
- 1880 (Node-RED)
- 3389 (RDP)
- 22 (SSH)
- 80 (Nginx)

**¡CUALQUIER CAMBIO EN ESTOS PUERTOS PUEDE CAUSAR SERIOS DAÑOS EN LA PRODUCCIÓN!**

### 🔐 Credenciales de Prueba
```bash
# Administrador
Email: admin.comparendos@testing.com
Password: AdminComparendos123!

# Auditor
Email: auditor.comparendos@testing.com
Password: AuditorComparendos123!

# Operador
Email: operador.comparendos@testing.com
Password: OperadorComparendos123!
```

## 🏗️ Arquitectura del Sistema

```
sistema-comparendos/
├── 📁 apps/                          # Aplicaciones del sistema
│   ├── 📁 backend/                   # 🚀 API Backend (Node.js/Express)
│   │   ├── 📁 src/                   # Código fuente principal
│   │   │   ├── 📁 controllers/       # Controladores de la API
│   │   │   │   ├── auth.controller.js
│   │   │   │   ├── hu00Controller.js
│   │   │   │   └── user.controller.js
│   │   │   ├── 📁 services/          # Lógica de negocio
│   │   │   │   ├── auth.service.js
│   │   │   │   └── audit.service.js
│   │   │   ├── 📁 routes/            # Rutas de la API
│   │   │   │   ├── auth.routes.js
│   │   │   │   ├── hu00Routes.js
│   │   │   │   └── userRoutes.js
│   │   │   ├── 📁 middleware/        # Middleware del sistema
│   │   │   │   └── auth.middleware.js
│   │   │   └── 📁 utils/             # Utilidades generales
│   │   ├── 📁 tests/                 # Tests y certificación
│   │   │   └── 📁 hu-comp-000/       # HU-COMP-000 Tests
│   │   ├── Dockerfile                # Docker backend
│   │   └── package.json              # Dependencias backend
│   │
│   └── 📁 frontend/                  # 🎨 Frontend React
│       ├── 📁 src/                   # Código fuente React
│       │   ├── 📁 components/        # Componentes React
│       │   │   ├── LoginForm.js      # Formulario de login
│       │   │   └── Dashboard.js      # Dashboard post-login
│       │   ├── 📁 services/          # Servicios del frontend
│       │   │   └── authService.js    # Servicio de autenticación
│       │   ├── App.js                # Componente principal
│       │   ├── index.js              # Punto de entrada
│       │   └── index.css             # Estilos globales
│       ├── 📁 public/                # Archivos públicos
│       │   └── index.html            # HTML base
│       ├── 📁 scripts/               # Scripts de desarrollo
│       │   └── dev.sh                # Script de desarrollo
│       ├── Dockerfile                # Docker frontend (multi-stage)
│       ├── nginx.conf                # Configuración Nginx
│       ├── package.json              # Dependencias frontend
│       └── README.md                 # Documentación frontend
│
├── 📁 infrastructure/                # Infraestructura y Docker
│   └── 📁 docker/                    # Configuración Docker
│       ├── docker-compose.yml        # Orquestación completa
│       └── 📁 docker-entrypoint-initdb.d/  # Scripts DB
│
├── 📁 documentation/                 # Documentación del sistema
│   ├── 📁 api/                       # Documentación API
│   │   ├── swagger.yaml              # Especificación Swagger
│   │   └── 📁 hu-specs/              # Especificaciones HU
│   └── 📁 user-guides/               # Guías de usuario
│
└── 📄 README.md                      # Documentación principal
```

### 🐳 Arquitectura Docker

```
┌─────────────────────────────────────────────────────────────┐
│                    🌐 NGINX FRONTEND                        │
│                  (puerto 30005/3000)                       │
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │   🎨 React SPA   │    │  📦 Static      │                │
│  │   (HU-COMP-000)  │    │  Assets         │                │
│  └─────────────────┘    └─────────────────┘                │
└─────────────────────────────────────────────────────────────┘
                               │
                               │ HTTP Proxy /api/*
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                  🚀 NODE.JS BACKEND                         │
│                     (puerto 6002)                          │
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │  🔐 Auth API     │    │  📚 Swagger     │                │
│  │  JWT Tokens      │    │  Documentation │                │
│  └─────────────────┘    └─────────────────┘                │
└─────────────────────────────────────────────────────────────┘
                               │
                               │ SQL Queries
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                 🗄️  POSTGRESQL DATABASE                     │
│                     (puerto 5436)                          │
│                                                             │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │  👥 Users Table  │    │  🔑 Roles Table │                │
│  │  comparendos_db  │    │  Permissions    │                │
│  └─────────────────┘    └─────────────────┘                │
└─────────────────────────────────────────────────────────────┘
```

### 💾 Volúmenes Docker Persistentes

```
📦 VOLÚMENES DE NODE_MODULES (Optimización)
├── frontend_node_modules          # Frontend producción
├── frontend_dev_node_modules      # Frontend desarrollo  
└── backend_node_modules           # Backend

💿 VOLÚMENES DE DATOS
├── postgres_data                  # Base de datos PostgreSQL
└── backend_logs                   # Logs del backend
```

### 🌐 Red Docker

Todos los servicios se comunican a través de la red `comparendos-network`:
- Frontend → Backend: `http://comparendos-back:6002`
- Backend → Database: `comparendos-db:5432`
- Externo → Frontend: `localhost:30005` (prod) / `localhost:3000` (dev)
- Externo → Backend: `localhost:6002`
- Externo → Database: `localhost:5436`
│   ├── 📁 backend/                   # API Backend (Node.js/Express)
│   │   ├── 📁 src/                   # Código fuente principal
│   │   │   ├── 📁 controllers/       # Controladores de la API
│   │   │   │   ├── auth.controller.js
│   │   │   │   ├── hu00Controller.js
│   │   │   │   ├── role.controller.js
│   │   │   │   └── user.controller.js
│   │   │   ├── 📁 services/          # Lógica de negocio
│   │   │   │   ├── auth.service.js
│   │   │   │   └── audit.service.js
│   │   │   ├── 📁 routes/            # Rutas de la API
│   │   │   │   ├── auth.routes.js
│   │   │   │   ├── authRoutes.js
│   │   │   │   ├── hu00Routes.js
│   │   │   │   ├── pingRoutes.js
│   │   │   │   ├── roleRoutes.js
│   │   │   │   └── userRoutes.js
│   │   │   ├── 📁 middleware/        # Middleware del sistema
│   │   │   │   ├── auth.middleware.js
│   │   │   │   └── authMiddleware.js
│   │   │   ├── 📁 utils/             # Utilidades generales
│   │   │   ├── 📁 config/            # Configuración
│   │   │   │   └── paths.js
│   │   │   ├── app.js                # Aplicación principal
│   │   │   └── db.js                 # Configuración base de datos
│   │   ├── 📁 tests/                 # Tests y certificación
│   │   │   └── 📁 hu-comp-000/       # HU-COMP-000 - Login y Auth
│   │   │       ├── README.md
│   │   │       ├── 📁 scripts/       # Scripts de prueba
│   │   │       ├── 📁 docs/          # Documentación
│   │   │       ├── 📁 swagger/       # Especificaciones API
│   │   │       └── 📁 certificacion/ # Docs de certificación
│   │   ├── 📁 documentation/         # Documentación API
│   │   │   └── 📁 api/
│   │   │       ├── swagger.yaml
│   │   │       └── 📁 hu-specs/
│   │   ├── package.json
│   │   └── Dockerfile
│   └── 📁 frontend/                  # Frontend React ✨ NUEVO
│       ├── 📁 src/                   # Código fuente React
│       │   ├── App.js                # Componente principal
│       │   ├── index.js              # Punto de entrada
│       │   ├── index.css             # Estilos globales
│       │   ├── 📁 components/        # Componentes React
│       │   │   ├── LoginForm.js      # Formulario de login
│       │   │   └── Dashboard.js      # Dashboard post-login
│       │   └── 📁 services/          # Servicios API
│       │       └── authService.js    # Servicio de autenticación
│       ├── 📁 public/                # Archivos públicos
│       │   └── index.html            # HTML base
│       ├── package.json              # Dependencias React
│       ├── Dockerfile                # Docker para producción
│       ├── nginx.conf                # Configuración Nginx
│       └── README.md                 # Documentación frontend
│   │   │   │   ├── validation.js
│   │   │   │   ├── logger.js
│   │   │   │   └── constants.js
│   │   │   └── 📁 config/            # Configuraciones
│   │   │       └── db.js
│   │   ├── package.json              # Dependencias del proyecto
│   │   └── Dockerfile                # Configuración Docker
│   │
│   └── 📁 frontend/                  # Frontend (React)
│       ├── 📁 src/                   # Código fuente frontend
│       │   ├── 📁 components/        # Componentes reutilizables
│       │   │   ├── 📁 common/        # Componentes generales
│       │   │   ├── 📁 comparendos/   # Componentes de comparendos
│       │   │   ├── 📁 vehiculos/     # Componentes de vehículos
│       │   │   ├── 📁 historico/     # Componentes de histórico
│       │   │   └── 📁 pasos/         # Componentes de pasos
│       │   ├── 📁 pages/             # Páginas principales
│       │   └── 📁 services/          # Servicios de API
│       └── package.json
│
├── 📁 infrastructure/                # Infraestructura y DevOps
│   ├── 📁 docker/                    # Configuraciones Docker
│   │   └── docker-compose.yml        # Compose para desarrollo
│   └── 📁 database/                  # Scripts de BD
│       └── 📁 migrations/            # Migraciones de BD
│
├── 📁 documentation/                 # Documentación del proyecto
│   ├── 📁 api/                       # Documentación API
│   │   └── swagger.yaml              # Especificación Swagger
│   └── README.md                     # Este archivo
│
└── 📁 scripts/                       # Scripts de automatización
    └── 📁 development/               # Scripts de desarrollo
        ├── setup-dev.sh
        └── seed-database.sh
```

## 📋 Estado de Certificación HUs (1/12 - 8.3% Completado)

### ✅ HUs Base - Comparendos (1/6 Certificadas)
| HU | Descripción | Endpoint | Estado |
|---|---|---|---|
| **HU-COMP-000** | 🔐 Validaciones Generales de Seguridad y Roles | `POST /api/auth/login` | ✅ **CERTIFICADA** |
| **HU-CM-001** | 📊 Listar Comparendos | `GET /api/comparendos` | ❌ Pendiente |
| **HU-CM-002** | 📤 Crear Comparendo | `POST /api/comparendos` | ❌ Pendiente |
| **HU-CM-003** | 📋 Consultar Comparendo | `GET /api/comparendos/:id` | ❌ Pendiente |
| **HU-CM-004** | 📝 Actualizar Comparendo | `PUT /api/comparendos/:id` | ❌ Pendiente |
| **HU-CM-005** | 🗑️ Eliminar Comparendo | `DELETE /api/comparendos/:id` | ❌ Pendiente |
| **HU-VH-001** | 🚗 Listar Vehículos | `GET /api/vehiculos` | ❌ Pendiente |
| **HU-VH-002** | 📋 Consultar Vehículo | `GET /api/vehiculos/:placa` | ❌ Pendiente |
| **HU-VH-003** | 📝 Actualizar Vehículo | `PUT /api/vehiculos/:placa` | ❌ Pendiente |
| **HU-VH-004** | 📊 Listar Historial | `GET /api/historico` | ❌ Pendiente |
| **HU-VH-005** | 📋 Consultar Historial | `GET /api/historico/:placa` | ❌ Pendiente |
| **HU-PS-001** | 🔄 Listar Pasos | `GET /api/pasos` | ❌ Pendiente |

### ⚡ HUs Avanzadas - Funcionalidades (0/6 Certificadas)
| HU | Descripción | Endpoint | Estado |
|---|---|---|---|
| **HU-CM-006** | ⚠️ Gestión de Infracciones | `GET /api/infracciones` | ❌ Pendiente |
| **HU-CM-007** | 💰 Gestión de Multas | `GET /api/multas` | ❌ Pendiente |
| **HU-CM-008** | 📈 Dashboard y Estadísticas | `GET /api/dashboard/stats` | ❌ Pendiente |
| **HU-CM-009** | 📝 Generación de Reportes | `GET /api/reportes` | ❌ Pendiente |
| **HU-CM-010** | 📤 Exportación de Datos | `POST /api/export` | ❌ Pendiente |
| **HU-CM-011** | 🔐 Gestión de Roles | `GET /api/roles` | ❌ Pendiente |

## 🚀 Funcionalidades Principales

### 🚨 Gestión de Comparendos
- **Registro**: Creación de nuevos comparendos con validaciones
- **Consulta**: Búsqueda avanzada por múltiples criterios
- **Actualización**: Modificación con auditoría de cambios
- **Estados**: Manejo de estados (Activo, Pagado, Anulado, Vencido)
- **Evidencias**: Carga y gestión de archivos multimedia

### ⚖️ Gestión de Infracciones
- **Catálogo**: Mantenimiento del catálogo de infracciones
- **Códigos**: Gestión de códigos y descripciones
- **Valores**: Configuración de valores base y multas
- **Categorías**: Clasificación por gravedad

### 💰 Gestión de Multas
- **Cálculo**: Cálculo automático basado en infracciones
- **Vencimientos**: Control de fechas de vencimiento
- **Pagos**: Registro y seguimiento de pagos
- **Descuentos**: Aplicación de descuentos por pronto pago

### 🔐 Seguridad y Auditoría
- **Autenticación JWT**: Protección de todos los endpoints
- **Roles y Permisos**: Control granular de acceso
- **Auditoría**: Registro completo de operaciones
- **Validaciones**: Verificación en todas las capas

## 🗄️ Modelo de Datos

### Entidades Principales
```sql
-- Usuarios y autenticación
users, roles, user_roles

-- Vehículos
vehiculos (placa, modelo, propietario, etc.)

-- Comparendos
comparendos (numero, fecha, agente, estado, etc.)

-- Infracciones
infracciones (codigo, descripcion, valor, categoria)

-- Multas y pagos
multas (comparendo_id, valor_total, fecha_vencimiento)
pagos (multa_id, valor, fecha_pago, metodo)

-- Auditoría
auditoria_comparendos
```

## 🔧 Configuración del Entorno

⚠️ **IMPORTANTE**: Los puertos configurados en el `docker-compose.yml` y el archivo `.env` son críticos para la producción. **NO** deben ser cambiados sin una razón específica y la aprobación explícita del equipo de operaciones. Siempre verificar los puertos en uso con `docker ps` antes de hacer cualquier cambio.

### Variables de Entorno (.env)
```bash
# 🚀 Configuración del Servidor
PORT=6002
NODE_ENV=development

# 🗄️ Configuración de Base de Datos  
DB_HOST=localhost
DB_PORT=5436
DB_NAME=comparendos_db
DB_USER=comparendos_user
DB_PASSWORD=comparendos_pass

# 🔐 Configuración JWT
JWT_SECRET=your_super_secret_jwt_key_here
JWT_EXPIRES_IN=24h
JWT_REFRESH_EXPIRES_IN=7d

# 📁 Configuración de Archivos
UPLOAD_DIR=./uploads
MAX_FILE_SIZE=10485760
ALLOWED_FILE_TYPES=image/jpeg,image/png,application/pdf

# 📧 Configuración de Email (Opcional)
EMAIL_ENABLED=false
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password

# 📊 Configuración Swagger
SWAGGER_ENABLED=true
SWAGGER_PATH=/api-docs

# 📝 Configuración de Logs
LOG_LEVEL=debug
LOG_FILE=./logs/app.log
```

## 🛠️ Instalación y Ejecución

1. Clonar el repositorio
2. Instalar dependencias:
```bash
npm install
```

3. Configurar variables de entorno:
```bash
cp .env.example .env
```

4. Iniciar los servicios:
```bash
docker-compose up --build
```

5. Acceder a la API:
- Swagger UI: http://localhost:6002/api-docs
- API Base: http://localhost:6002/api

## 📝 Documentación Adicional

- [📖 Guía de Estilos](docs/style-guide.md)
- [🛠️ Guía de Contribución](docs/contributing.md)
- [🚀 Guía de Despliegue](docs/deployment.md)
- [🔐 Guía de Seguridad](docs/security.md)
- [📊 Guía de Monitoreo](docs/monitoring.md)
- [🧪 Guía de Testing](docs/testing.md)

## 🤝 Contribución

1. Fork el proyecto
2. Crear una rama para tu característica:
```bash
git checkout -b feature/NombreCaracteristica
```
3. Commit tus cambios:
```bash
git commit -m 'feat: Descripción de la característica'
```
4. Push a la rama:
```bash
git push origin feature/NombreCaracteristica
```
5. Crear un Pull Request

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Consulte el archivo LICENSE para más detalles.

## 📚 Referencia - Carpeta `old`

Esta carpeta contiene el código fuente original del proyecto vehiculos, que fue clonado como punto de partida para el sistema de comparendos. Los archivos se han movido aquí para mantenerlos como referencia histórica y evitar pérdida de información.

### Contenido Principal

- **Backend Original** (`backend/`):
  - Código fuente del proyecto vehiculos
  - Scripts de prueba y automatización
  - Documentación técnica
  - Archivos de configuración

- **Documentación Antigua** (`docs/`):
  - Especificaciones técnicas
  - Guías de desarrollo
  - Documentación de API

- **Scripts** (`scripts/`):
  - Scripts de automatización
  - Scripts de prueba
  - Scripts de migración

- **SQL** (`sql/`):
  - Scripts de base de datos originales
  - Migraciones
  - Scripts de inicialización

- **Archivos de Configuración**:
  - `package.json` y `package-lock.json` originales
  - Swagger.yaml original
  - Documentos de especificaciones técnicas

### Motivo del Desplazamiento

Los archivos fueron movidos a la carpeta `old` para:
1. Mantener una referencia histórica del proyecto original
2. Evitar la pérdida de documentación y especificaciones importantes
3. Limpiar la estructura del nuevo proyecto de comparendos
4. Facilitar la comparación entre el proyecto original y el nuevo
5. Preservar scripts y herramientas de desarrollo útiles

### Nota Importante
Los archivos en esta carpeta son de referencia únicamente y no deben ser utilizados en el desarrollo activo del sistema de comparendos. El desarrollo debe seguir la nueva estructura definida en el README.

## 📋 Guía de Certificación de HUs

### 🎯 Metodología de Certificación

Cada Historia de Usuario (HU) debe seguir este proceso estricto para garantizar calidad y consistencia:

#### 1. **Preparación de la HU**
```bash
# Crear estructura de trabajo
mkdir -p apps/backend/tests/hu-comp-XXX/{scripts,swagger,docs,certificacion}

# Verificar dependencias del sistema
docker ps  # Verificar servicios activos
curl http://localhost:6002/api/ping  # Verificar backend
```

#### 2. **Desarrollo y Testing**
```bash
# Ejecutar tests de la HU específica
cd apps/backend/tests/hu-comp-XXX/scripts
./test_auth.sh          # Tests de autenticación
./test_roles.sh         # Tests de roles y permisos  
./test_security.sh      # Tests de seguridad
./test_endpoints.sh     # Tests de endpoints específicos

# Verificar cobertura mínima (95%)
npm test -- --coverage
```

#### 3. **Documentación Swagger**
```bash
# Actualizar especificación específica de la HU
vim apps/backend/tests/hu-comp-XXX/swagger/hu-comp-XXX.yaml

# Integrar al Swagger monolítico
curl http://localhost:6002/api-docs.json | jq '.'

# Verificar endpoints en Swagger UI
open http://localhost:6002/api-docs
```

#### 4. **Certificación Final**
```bash
# Generar reporte de certificación
./generate_certification_report.sh hu-comp-XXX

# Validar endpoints principales
curl -X POST "http://localhost:6002/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"admin.comparendos@testing.com","password":"AdminComparendos123!"}' | jq '.'

# Actualizar estado en README
vim README.md  # Cambiar estado de ❌ Pendiente a ✅ CERTIFICADA
```

### 🔍 Criterios de Certificación

Para que una HU sea marcada como **CERTIFICADA**, debe cumplir:

#### ✅ Criterios Técnicos
- [ ] **Tests**: Mínimo 95% de cobertura, todos los tests pasan
- [ ] **Seguridad**: Validación de autenticación y autorización
- [ ] **Documentación**: Swagger actualizado con ejemplos completos
- [ ] **Performance**: Endpoints responden en < 500ms
- [ ] **Errores**: Manejo adecuado de errores (4xx, 5xx)

#### ✅ Criterios Funcionales  
- [ ] **Endpoints**: Todos los endpoints definidos funcionando
- [ ] **Validaciones**: Validación de datos de entrada/salida
- [ ] **Roles**: Permisos por rol funcionando correctamente
- [ ] **Auditoría**: Logs de operaciones críticas
- [ ] **Base de Datos**: Integridad referencial mantenida

#### ✅ Criterios de Documentación
- [x] **Autenticación**: Sistema de login JWT implementado
- [x] **Roles**: Permisos por rol funcionando correctamente
- [x] **Auditoría**: Logs de operaciones críticas
- [x] **Base de Datos**: Integridad referencial mantenida
- [x] **Scripts de Prueba**: test_login.sh, test_roles.sh, test_endpoints.sh funcionando
- [x] **Documentación**: Swagger y certificación actualizados
- [ ] **Swagger**: Especificación completa y precisa
- [ ] **Ejemplos**: Requests/responses de ejemplo
- [ ] **Certificación**: Documento de certificación generado
- [ ] **README**: Estado actualizado en tabla de HUs
- [ ] **Tests**: Scripts de testing documentados

### 🚀 Flujo de Trabajo HU por HU

```bash
# PASO 1: Seleccionar próxima HU
# Revisar tabla de estado en README.md
# Identificar próxima HU pendiente (❌ Pendiente)

# PASO 2: Preparar ambiente
cd /home/administrador/docker/comparendos
docker-compose up -d  # Asegurar servicios corriendo
curl http://localhost:6002/api/ping  # Verificar backend

# PASO 3: Implementar HU
# Desarrollar endpoints, controladores, servicios
# Implementar tests específicos
# Crear documentación Swagger

# PASO 4: Ejecutar certificación
cd apps/backend/tests/hu-comp-XXX
./run_all_tests.sh  # Ejecutar todos los tests
./generate_certification.sh  # Generar certificación

# PASO 5: Integrar al monolítico
# Actualizar Swagger principal
# Verificar integración con curl
# Actualizar README.md

# PASO 6: Validar y pasar a siguiente
# Marcar HU como ✅ CERTIFICADA
# Commit cambios
# Pasar a siguiente HU
```

### 📊 Template de Certificación

Cada HU certificada debe tener:

```markdown
# 🎯 Certificación HU-COMP-XXX - [Título de la HU]

## 📋 Información de la HU
- **ID**: HU-COMP-XXX
- **Descripción**: [Descripción detallada]
- **Endpoint Principal**: [Endpoint principal]
- **Funcionalidad**: [Funcionalidad principal]

## 🔧 Request Ejecutado
[Ejemplo de curl request]

## ✅ Response Obtenido  
[Response JSON de ejemplo]

## 📊 Resultado de Certificación
- **HTTP Status**: [Status code]
- **Estado**: ✅ **CERTIFICADA Y COMPLETADA**
- **Fecha**: [Fecha de certificación]
- **Validación**: [Descripción de validación]

## 📊 Estado de Tests
- **Tests Ejecutados**: XX/XX ✅
- **Tests Exitosos**: XX/XX ✅ 
- **Tests Fallidos**: 0/XX ✅
- **Cobertura**: XX% ✅
```

### 🎯 Estado Actual: HU-COMP-000 COMPLETADA

La HU-COMP-000 (Validaciones Generales de Seguridad y Roles) está **100% certificada** y operativa.

**Próximo paso**: Implementar y certificar **HU-COMP-001** siguiendo esta metodología.

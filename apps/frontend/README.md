# 📚 Frontend - Sistema de Comparendos

Frontend React para la autenticación y gestión del sistema de comparendos (HU-COMP-000).

## 🚀 Acceso al Sistema

- **Producción (Docker)**: http://localhost:60005
- **Desarrollo (Docker)**: http://localhost:6000
- **Backend**: http://localhost:6002
- **Swagger**: http://localhost:6002/api-docs

## 🔑 Credenciales de Prueba

- **Operador Norte**: operador.nn@comparendos.com / operador123
- **Operador Sur**: operador.sn@comparendos.com / operador123
- **Policía**: police@comparendos.com / police123
- **Coordinador ITS**: coordinador.its@comparendos.com / coordinador123
- **Regulador ANI**: ani@comparendos.com / ani123

## 📦 Dependencias

```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.3.0",
    "axios": "^1.6.2",
    "bootstrap": "^5.3.0"
  }
}
```

## 🏗️ Estructura del Proyecto

### 📁 Estructura de Carpetas
```
apps/frontend/
├── src/                     # Código fuente
│   ├── components/          # Componentes reutilizables
│   │   ├── LoginForm.js    # Formulario de login
│   │   └── Dashboard.js    # Dashboard post-login
│   ├── services/           # Lógica de negocio y API
│   │   └── authService.js  # Servicios de autenticación
│   ├── assets/             # Recursos estáticos
│   ├── pages/              # Páginas principales
│   ├── utils/              # Utilidades y helpers
│   ├── App.js              # Componente raíz
│   └── index.js            # Punto de entrada
├── tests/                  # 🧪 Suite de pruebas
│   └── hu-comp-000/        # Pruebas HU-COMP-000
│       ├── README.md       # Documentación de pruebas
│       ├── DEBUGGING_REPORT.md # Reporte de debugging
│       ├── test_login_api.js   # Script de prueba API
│       └── package.json    # Dependencias de pruebas
├── public/                 # Archivos estáticos
├── Dockerfile              # Configuración Docker
└── docker-entrypoint.sh    # Script de entrada
```

### 📦 Paquetes Principales

- **React 18.2.0**: Framework principal
- **React Router 6.3.0**: Manejo de rutas
- **Axios 1.6.2**: Comunicación con API
- **Bootstrap 5.3.0**: Framework de UI

## 🐳 Docker

### 📁 Configuración de Docker

#### 🏗️ Dockerfile Multi-Etapa
```dockerfile
# 📦 Etapa Base - Dependencias comunes
FROM node:18-alpine AS base
WORKDIR /app
RUN apk add --no-cache git
COPY package*.json ./

# 🛠️ Etapa de Desarrollo
FROM base AS development
ENV NODE_ENV=development
RUN npm ci --silent
COPY . .
EXPOSE 3000
ENV REACT_APP_API_URL=http://localhost:6002
ENV CHOKIDAR_USEPOLLING=true
CMD ["npm", "start"]

# 🏗️ Etapa de Construcción para Producción
FROM base AS build
ENV NODE_ENV=production
RUN npm ci --silent
COPY . .
ENV REACT_APP_API_URL=http://localhost:6002
ENV GENERATE_SOURCEMAP=false
```

### 📁 Volumenes

- `frontend_node_modules`: Persistencia de node_modules (producción)
- `frontend_dev_node_modules`: Persistencia de node_modules (desarrollo)
- `src`: Montado para hot reload (desarrollo)
- `public`: Montado para hot reload (desarrollo)

### 📁 Nginx Configuration

```nginx
server {
    listen 60005;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri /index.html;
    }
}
```

### 📦 Dependencias Instaladas

#### 📦 Dependencias Principales
- **React 18.2.0**: Framework principal
- **React Router 6.3.0**: Manejo de rutas
- **Axios 1.4.0**: Comunicación con API
- **Testing Library**: Suite de pruebas
- **Web Vitals**: Métricas de performance

#### 🛠️ Herramientas de Desarrollo
- **React Scripts 5.0.1**: Scripts de construcción
- **ESLint**: Linter configurado
- **Jest**: Framework de pruebas
- **Git**: Control de versiones

## 🔧 Configuración de Red y Variables de Entorno

### 🔗 Red y URLs

**Desarrollo Local (HTTP)**:
- **Frontend**: http://localhost:6000
- **Backend**: http://localhost:6002
- **API**: http://localhost:6002/api
- **Docker Network**: `comparendos-network` (bridge)

**Producción/Pruebas (HTTPS)**:
- **Frontend**: https://comparendos.autovia360.cc
- **Backend**: https://comparendos.autovia360.cc/api
- **Proxy**: Nginx configura el proxy para `/api` → `http://comparendos-back:6002`

### 🛠️ Variables de Entorno
- **Producción**:
  - `NODE_ENV=production`
  - `REACT_APP_API_URL=http://localhost:6002`
  - `GENERATE_SOURCEMAP=false`

- **Desarrollo**:
  - `NODE_ENV=development`
  - `REACT_APP_API_URL=http://localhost:6002`
  - `CHOKIDAR_USEPOLLING=true`

**Nota**: Las variables de entorno están configuradas directamente en el Dockerfile y no requieren un archivo .env separado.

## 🏃‍♂️ Comandos Docker

```bash
# Iniciar desarrollo
docker compose --profile development up comparendos-frontend-dev

# Iniciar producción
docker compose up comparendos-frontend

# Detener servicios
docker compose down

# Limpiar volúmenes
docker compose down -v
```

## 🧪 Pruebas y Testing

### 📁 Suite de Pruebas HU-COMP-000

La carpeta `tests/hu-comp-000/` contiene toda la documentación y scripts de pruebas para la HU-COMP-000.

#### 🚀 Ejecutar Pruebas de API
```bash
cd tests/hu-comp-000
npm install
npm test
```

#### 📋 Documentación de Pruebas
- `README.md` - Guía de pruebas y credenciales
- `DEBUGGING_REPORT.md` - Reporte detallado de debugging y soluciones
- `test_login_api.js` - Script automatizado de prueba de API

#### 🔍 Problemas Solucionados
- ✅ Error `Cannot read properties of undefined (reading 'id')`
- ✅ Validaciones defensivas en componentes
- ✅ Manejo de estructuras de datos inconsistentes
- ✅ Optional chaining para seguridad

## 🎯 Estado de la HU-COMP-000

### 📝 Funcionalidades Implementadas

- [x] Formulario de login responsive
- [x] Sistema de credenciales predefinidas
- [x] Integración con API de autenticación
- [x] Manejo de tokens JWT
- [x] Dashboard post-login
- [x] Manejo de errores
- [x] Indicadores de carga
- [x] Suite de pruebas completa
- [x] Documentación de debugging
```

### 🔧 Mejoras Pendientes

- Implementar más validaciones de seguridad
- Agregar más feedback visual
- Optimizar performance
- Mejorar manejo de estados

## 📋 Convenciones de Desarrollo

### 🎨 Componentes
- **Naming**: PascalCase para componentes (`LoginForm.js`)
- **Structure**: Un componente por archivo
- **Props**: Destructuring en parámetros de función
- **Hooks**: Declarar al inicio del componente
- **Testing**: Jest para componentes

### 🔌 Servicios
- **API calls**: Centralizar en `services/`
- **Error handling**: Try-catch con mensajes descriptivos
- **Interceptors**: Configurar en axios para tokens y respuestas
- **Base URL**: Configuración dinámica según entorno

### 🎯 Mejores Prácticas
- **Responsive Design**: Mobile-first approach
- **Loading States**: Indicadores visuales para operaciones async
- **Error Boundaries**: Manejo graceful de errores
- **Performance**: Lazy loading para rutas/componentes pesados
- **Security**: Sanitización de inputs y validación cliente/servidor
- **Testing**: Jest para componentes y servicios

## 🛠️ Herramientas de Desarrollo

- **Testing**: Jest
- **Linting**: ESLint
- **Formatting**: Prettier
- **Build**: Vite
- **Hot Reload**: React Fast Refresh

## 📝 Notas Importantes

- **Estado del Sistema**: En desarrollo continuo
- **Última Actualización**: 06/06/2025
- **Versión Actual**: 1.0.0
- **Estado de Certificación**: En proceso

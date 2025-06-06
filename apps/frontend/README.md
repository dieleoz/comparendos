# Sistema de Comparendos - Frontend

Frontend React para la autenticación y gestión del sistema de comparendos (HU-COMP-000).

## 🚀 Acceso al Sistema

**Producción (Docker)**: http://localhost:60005  
**Desarrollo**: http://localhost:3000

## 🔑 Credenciales de Prueba

- **Operador Norte**: operador.nn@comparendos.com / operador123
- **Operador Sur**: operador.sn@comparendos.com / operador123  
- **Policía**: police@comparendos.com / police123
- **Coordinador ITS**: coordinador.its@comparendos.com / coordinador123
- **Regulador ANI**: ani@comparendos.com / ani123

## 🏃‍♂️ Desarrollo Local

```bash
cd /home/administrador/docker/comparendos/apps/frontend
npm install
npm start
```

## 🔧 Configuración de Red

- **Producción**: Usa proxy nginx (`/api/*` → `http://comparendos-back:6002`)
- **Desarrollo**: Conexión directa a `http://localhost:6002`

## 🏗️ Arquitectura y Estructura

### 📁 Estructura de Carpetas
```
src/
├── components/          # Componentes reutilizables
│   ├── LoginForm.js     # Formulario de autenticación
│   └── Dashboard.js     # Panel principal post-login
├── services/            # Lógica de negocio y API
│   └── authService.js   # Servicios de autenticación
├── assets/              # Recursos estáticos (imágenes, fonts)
├── pages/               # Páginas/Vistas principales
├── utils/               # Utilidades y helpers
├── App.js               # Componente raíz
├── index.js             # Punto de entrada
└── index.css            # Estilos globales
```

### 🎯 Patrones de Arquitectura

- **Componentes Funcionales**: Uso de React Hooks (useState, useEffect)
- **Separación de Responsabilidades**: 
  - `components/`: UI y presentación
  - `services/`: Comunicación con APIs
  - `utils/`: Funciones auxiliares
- **Gestión de Estado**: Local state con hooks nativos de React
- **Autenticación**: JWT tokens almacenados en localStorage
- **Proxy Nginx**: Manejo de CORS y enrutamiento de API en producción

## 📋 Convenciones de Desarrollo

### 🎨 Componentes
- **Naming**: PascalCase para componentes (`LoginForm.js`)
- **Structure**: Un componente por archivo
- **Props**: Destructuring en parámetros de función
- **Hooks**: Declarar al inicio del componente

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

# ==================================================
# 🏗️ DOCKERFILE MULTI-ETAPA PARA FRONTEND REACT
# ==================================================

# 📦 Etapa Base - Dependencias comunes
FROM node:18-alpine AS base
WORKDIR /app

# Instalar dependencias del sistema necesarias
RUN apk add --no-cache git

# Copiar archivos de configuración
COPY package*.json ./

# ==================================================
# 🛠️ Etapa de Desarrollo
# ==================================================
FROM base AS development
ENV NODE_ENV=development

# Instalar todas las dependencias (incluidas devDependencies)
RUN npm ci --silent

# Copiar código fuente
COPY . .

# Exponer puerto de desarrollo
EXPOSE 3000

# Variables de entorno para desarrollo
ENV REACT_APP_API_URL=http://localhost:6002
ENV CHOKIDAR_USEPOLLING=true

# Comando para desarrollo con hot reload
CMD ["npm", "start"]

# ==================================================
# 🏗️ Etapa de Construcción para Producción
# ==================================================
FROM base AS build
ENV NODE_ENV=production

# Instalar TODAS las dependencias (necesarias para el build)
RUN npm ci --silent

# Copiar código fuente
COPY . .

# Variables de entorno para build
ENV REACT_APP_API_URL=http://localhost:6002
ENV GENERATE_SOURCEMAP=false

# Construir la aplicación para producción
RUN npm run build

# ==================================================
# 🌐 Etapa de Producción con Nginx
# ==================================================
FROM nginx:alpine AS production

# Instalar herramientas útiles
RUN apk add --no-cache curl

# Copiar archivos construidos desde la etapa de build
COPY --from=build /app/build /usr/share/nginx/html

# Copiar configuración personalizada de nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Crear directorio para logs
RUN mkdir -p /var/log/nginx

# Configurar permisos
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /var/cache/nginx

# Healthcheck para verificar que nginx esté funcionando
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Exponer puerto
EXPOSE 80

# Comando por defecto
CMD ["nginx", "-g", "daemon off;"]

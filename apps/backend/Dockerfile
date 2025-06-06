FROM node:18-slim
WORKDIR /app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar el código fuente completo
COPY . .

# Exponer puerto
EXPOSE 3016

# Comando para iniciar la aplicación
CMD ["npm", "start"]

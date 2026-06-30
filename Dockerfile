# ---------- Étape 1 : BUILD du frontend Vue ----------
FROM node:22-alpine AS build
WORKDIR /app

# Installer les dépendances (cache optimisé)
COPY package*.json ./
RUN npm install

# Copier le code et construire la version de production
COPY . .
RUN npm run build

# ---------- Étape 2 : SERVE avec Nginx ----------
FROM nginx:alpine

# Copier le build (dossier dist) dans le dossier servi par Nginx
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

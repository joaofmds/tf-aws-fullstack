FROM node:22-alpine AS builder

WORKDIR /app

COPY package*.json ./
COPY babel.config.js .
COPY vue.config.js .
COPY jsconfig.json .
COPY public ./public
COPY src ./src

ARG VUE_APP_API_URL
ENV VUE_APP_API_URL=$VUE_APP_API_URL


RUN npm install && npm run build

FROM nginx:alpine

COPY --from=builder /app/dist /usr/share/nginx/html

COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

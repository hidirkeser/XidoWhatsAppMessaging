# build: 2026-03-30
FROM nginx:1.27-alpine

COPY . /usr/share/nginx/html/

# nginx config: SPA routing + gzip + security headers
RUN printf 'server {\n\
    listen 8080;\n\
    root /usr/share/nginx/html;\n\
    index index.html;\n\
    gzip on;\n\
    gzip_types text/plain text/css application/javascript application/json application/wasm;\n\
    gzip_min_length 1024;\n\
    add_header X-Frame-Options SAMEORIGIN;\n\
    add_header X-Content-Type-Options nosniff;\n\
    location / {\n\
        try_files $uri $uri/ /index.html;\n\
    }\n\
    location = /main.dart.js {\n\
        expires -1;\n\
        add_header Cache-Control "no-cache, no-store, must-revalidate";\n\
    }\n\
    location ~* \\.(js|css|wasm|png|jpg|ico|json|ttf|otf)$ {\n\
        expires 1y;\n\
        add_header Cache-Control "public, immutable";\n\
    }\n\
    location = /index.html {\n\
        expires -1;\n\
        add_header Cache-Control "no-cache";\n\
    }\n\
}\n' > /etc/nginx/conf.d/default.conf

EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]

# Stage 1: Build Tailwind CSS
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json ./
RUN npm install
COPY tailwind.config.js ./
COPY src/ ./src/
COPY public/ ./public/
RUN npm run build

# Stage 2: Serve via nginx
FROM nginx:1.25-alpine

# Install gettext for envsubst
RUN apk add --no-cache gettext

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/

# Copy static files from builder
COPY --from=builder /app/public/ /usr/share/nginx/html/

# Copy index.html as template for environment variable substitution
RUN mv /usr/share/nginx/html/index.html /usr/share/nginx/html/index.html.template

# Copy entrypoint script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Set proper permissions
RUN chmod -R 755 /usr/share/nginx/html

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:2000/health || exit 1

EXPOSE 2000

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

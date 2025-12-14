# Multi-stage build for frontend
FROM nginx:alpine AS builder

# Copy static files
COPY index.html /usr/share/nginx/html/
COPY appointments.html /usr/share/nginx/html/
COPY style.css /usr/share/nginx/html/
COPY health.html /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Production stage
FROM nginx:alpine

# Create non-root user
RUN addgroup -g 1001 -S nginx-user && \
    adduser -S -D -H -u 1001 -h /var/cache/nginx -s /sbin/nologin -G nginx-user -g nginx-user nginx-user

# Copy files from builder
COPY --from=builder --chown=nginx-user:nginx-user /usr/share/nginx/html /usr/share/nginx/html
COPY --from=builder /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

# Update nginx config to run as non-root
RUN sed -i 's/user  nginx;/user nginx-user;/' /etc/nginx/nginx.conf && \
    chown -R nginx-user:nginx-user /var/cache/nginx && \
    chown -R nginx-user:nginx-user /var/log/nginx && \
    chown -R nginx-user:nginx-user /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx-user:nginx-user /var/run/nginx.pid

USER nginx-user

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

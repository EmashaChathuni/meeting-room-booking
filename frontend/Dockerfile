FROM cirrusci/flutter:latest AS builder

WORKDIR /build

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build Flutter web app
RUN flutter build web --release

# Use nginx to serve the web app
FROM nginx:alpine

# Copy built Flutter app to nginx
COPY --from=builder /build/build/web /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

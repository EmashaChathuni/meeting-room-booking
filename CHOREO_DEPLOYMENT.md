# Meeting Room Booking - Deployment Guide

## Choreo Deployment Setup

### Backend (Go) - Dockerfile

Create `backend/Dockerfile`:
```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /build
COPY . .
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=builder /build/main .
EXPOSE 8080
CMD ["./main"]
```

### Frontend (Flutter) - Dockerfile

Create `frontend/Dockerfile`:
```dockerfile
FROM google/dart:latest AS builder
WORKDIR /build
COPY . .
RUN dart pub get
RUN dart compile js -o build/web/main.dart.js lib/main.dart

FROM nginx:alpine
COPY --from=builder /build/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Environment Variables

Backend needs these env vars in Choreo:
- `SUPABASE_DB_URL` - PostgreSQL connection string
- `PORT` - API port (default 8080)

Frontend needs these env vars:
- `API_BASE_URL` - Backend API URL (e.g., https://backend.choeroapp.com)

### Deployment Steps on Choreo

1. **Push code to GitHub**
   - Ensure `.gitignore` includes `node_modules/`, `build/`, etc.

2. **In Choreo Console**
   - Create new project
   - Connect GitHub repository
   - Select branches to deploy

3. **Configure Backend Service**
   - Runtime: Go 1.21
   - Build Command: `go build -o main .`
   - Run Command: `./main`
   - Port: 8080
   - Add environment variables

4. **Configure Frontend Service**
   - Runtime: Node.js/Flutter
   - Build Command: `flutter build web`
   - Run Command: Serve from `build/web`
   - Port: 80

5. **Database Configuration**
   - Use Supabase PostgreSQL (external database)
   - Connection string as environment variable

6. **API Endpoint**
   - Update frontend API_BASE_URL after backend is deployed

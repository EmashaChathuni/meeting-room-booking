# Choreo Deployment Guide

This guide explains how to deploy the Meeting Room Booking application to Choreo.

## Prerequisites

1. **GitHub Account** - Code must be pushed to GitHub
2. **Choreo Account** - https://console.choreo.dev
3. **Supabase PostgreSQL Database** - Already configured with connection string
4. **Docker** (optional for local testing)

## Project Structure for Deployment

```
meeting-room-booking/
├── backend/                 # Go API service
│   ├── Dockerfile          # Go build and run configuration
│   ├── .dockerignore
│   ├── go.mod
│   ├── main.go
│   └── ...
├── frontend/                # Flutter web app
│   ├── Dockerfile          # Flutter build configuration
│   ├── nginx.conf          # Web server configuration
│   ├── .dockerignore
│   ├── pubspec.yaml
│   └── ...
├── choreo.yml              # Choreo deployment configuration
├── docker-compose.yml      # Local Docker testing
└── database/
    └── setup.sql           # Database schema
```

## Step-by-Step Deployment

### 1. Prepare GitHub Repository

```bash
# Initialize git if not already done
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - Ready for Choreo deployment"

# Push to GitHub
git push -u origin main
```

**Important Files for Deployment:**
- `backend/Dockerfile` - Builds Go application
- `frontend/Dockerfile` - Builds Flutter web app
- `choreo.yml` - Service definitions

### 2. Login to Choreo

1. Go to https://console.choreo.dev
2. Sign in with your account (create one if needed)
3. Click "Create New Project"

### 3. Configure Backend Service

1. In Choreo console, click "Add Service"
2. Select "REST API"
3. Connect GitHub repository
4. Configuration:
   - **Service Name:** `api`
   - **GitHub Path:** `/backend`
   - **Runtime:** Go 1.21
   - **Port:** 8080
5. Add Environment Variables:
   - `SUPABASE_DB_URL` - Your Postgres connection string
   - `PORT` - `8080`
6. Click "Deploy"

### 4. Configure Frontend Service

1. Click "Add Service"
2. Select "Web App"
3. Configuration:
   - **Service Name:** `web`
   - **GitHub Path:** `/frontend`
   - **Runtime:** Node.js (Flutter web)
   - **Build Command:** `flutter build web --release`
   - **Run Command:** `serve -p 80 build/web`
   - **Port:** 80
4. Add Environment Variables:
   - `API_BASE_URL` - Copy the API service URL from backend (after deployment)
5. Click "Deploy"

### 5. Update Frontend API URL

After backend is deployed:

1. Copy the backend API URL from Choreo (e.g., `https://api-xxxxx.choreo.dev`)
2. Update `frontend/lib/constants/api_constants.dart`:

```dart
static const String baseUrl = 'https://api-xxxxx.choreo.dev'; // Update this
```

3. Push changes:
```bash
git add frontend/lib/constants/api_constants.dart
git commit -m "Update API URL for Choreo deployment"
git push
```

4. Redeploy frontend service in Choreo

### 6. Enable CORS (if needed)

If you encounter CORS errors, configure in Choreo:

1. Go to API service settings
2. Enable CORS
3. Allow origin: `*` (or your frontend domain)
4. Allow methods: GET, POST, PUT, DELETE, OPTIONS
5. Allow headers: `*`

## Local Testing with Docker Compose

Test the deployment configuration locally:

```bash
# Set environment variable
export SUPABASE_DB_URL="postgresql://user:password@host/database"

# Build and run services
docker-compose up --build

# Access:
# - Frontend: http://localhost
# - Backend: http://localhost:8080
# - API: http://localhost:8080/api
```

## Health Checks

### Backend Health

```bash
curl http://api.choreo.dev/api/auth/login -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'
```

### Frontend Health

Visit https://web.choreo.dev and verify login page loads.

## Troubleshooting

### Backend fails to start
- Check `SUPABASE_DB_URL` is correct and database is accessible
- Verify Go version compatibility (1.21+)
- Check logs in Choreo console

### Frontend shows blank page
- Clear browser cache (Ctrl+Shift+Delete)
- Verify `API_BASE_URL` environment variable
- Check browser console for errors

### API calls fail with 404
- Verify backend service is running
- Check API URL is correctly set in frontend
- Verify CORS is enabled

### Database connection fails
- Verify Supabase connection string format
- Check database user has correct permissions
- Test connection string locally first

## Production Checklist

- [ ] Code pushed to GitHub
- [ ] Database schema initialized in Supabase
- [ ] Both services deployed in Choreo
- [ ] Environment variables configured correctly
- [ ] Frontend API URL updated to production backend
- [ ] CORS enabled for production domain
- [ ] SSL certificates auto-configured by Choreo
- [ ] Test signup, login, and booking workflows
- [ ] Verify times display correctly
- [ ] Performance tested

## Support

For Choreo-specific issues: https://choreo.dev/docs
For application issues: Check logs in Choreo console

## Rollback

To rollback to previous deployment:

1. Go to service deployment history in Choreo
2. Click on previous successful deployment
3. Click "Redeploy"

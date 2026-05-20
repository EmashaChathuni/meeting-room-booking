#!/bin/bash

# Meeting Room Booking - Deployment Script for Choreo

echo "🚀 Starting deployment process..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if GitHub is configured
if ! git config --get user.email &> /dev/null; then
    echo "❌ Git user not configured. Run: git config --global user.email 'your-email'"
    exit 1
fi

echo "✅ Prerequisites checked"

# Build backend
echo "📦 Building backend Docker image..."
cd backend
docker build -t meeting-room-booking-backend:latest .
if [ $? -ne 0 ]; then
    echo "❌ Backend build failed"
    exit 1
fi
cd ..

# Build frontend
echo "📦 Building frontend Docker image..."
cd frontend
docker build -t meeting-room-booking-frontend:latest .
if [ $? -ne 0 ]; then
    echo "❌ Frontend build failed"
    exit 1
fi
cd ..

echo "✅ Docker images built successfully"

echo ""
echo "📋 Next steps for Choreo deployment:"
echo ""
echo "1. Go to https://console.choreo.dev"
echo "2. Create a new project"
echo "3. Connect your GitHub repository"
echo "4. Create backend service:"
echo "   - Path: /backend"
echo "   - Runtime: Go"
echo "   - Environment: SUPABASE_DB_URL=<your-connection-string>"
echo "5. Create frontend service:"
echo "   - Path: /frontend"
echo "   - Runtime: Flutter Web"
echo "   - Environment: API_BASE_URL=<backend-url>"
echo "6. Deploy both services"
echo ""
echo "🎉 Deployment configuration ready!"

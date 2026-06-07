# Meeting Room Booking App - Choreo Deployment Guide

## 🚀 Quick Start

### Option 1: Automatic GitHub Deployment (Recommended)

1. **Set up Choreo secrets in GitHub**:
   - Go to GitHub repo → Settings → Secrets and variables → Actions
   - Add:
     ```
     CHOREO_ORG=your-org-name
     CHOREO_PROJECT=meeting-room-booking
     CHOREO_PAT=<your-choreo-token>
     ```

2. **Push to main branch**:
   ```bash
   git add .
   git commit -m "Deploy to Choreo"
   git push origin main
   ```

3. **Monitor deployment**:
   - Check GitHub Actions tab for workflow status
   - View Choreo Dashboard for service status

### Option 2: Manual Deployment

See [CHOREO_SETUP.md](./CHOREO_SETUP.md) for detailed manual setup instructions.

---

## 📁 Project Structure

```
meeting-room-booking/
├── backend/                    ← Go REST API
│   ├── config/                 ← Database config
│   ├── controllers/            ← HTTP handlers
│   ├── models/                 ← Data models
│   ├── repositories/           ← Database queries
│   ├── routes/                 ← API routes
│   ├── services/               ← Business logic
│   ├── main.go                 ← Entry point
│   ├── go.mod                  ← Go dependencies
│   └── Dockerfile              ← Container image
│
├── frontend/                   ← Flutter Web App
│   ├── lib/
│   │   ├── models/            ← Data models
│   │   ├── screens/           ← UI screens
│   │   ├── services/          ← API services
│   │   ├── widgets/           ← Reusable widgets
│   │   ├── constants/         ← Constants
│   │   └── main.dart          ← Entry point
│   ├── pubspec.yaml           ← Flutter dependencies
│   └── Dockerfile             ← Container image
│
├── .choreo/
│   ├── deploy.yaml            ← Choreo deployment config
│   └── endpoints.yaml         ← API endpoints
├── .github/workflows/
│   ├── choreo-deploy.yml      ← CD/CD pipeline
│   └── tests.yml              ← Test pipeline
└── docker-compose.yml         ← Local development
```

---

## 🛠️ Environment Variables

### Backend (Choreo)
| Variable | Example |
|---|---|
| `SUPABASE_DB_URL` | `postgres://user:pass@db.supabase.co:5432/postgres` |
| `PORT` | `8080` |
| `API_KEY` | `your-secret-key` |

### Frontend
| Variable | Example |
|---|---|
| `API_BASE_URL` | `https://backend-api.choreo.dev/api` |

---

## 📊 Deployment Pipeline

The GitHub Actions workflow automatically:

1. **Build Backend**
   - Runs `go mod tidy`
   - Executes tests
   - Builds binary

2. **Build Frontend**
   - Runs `flutter pub get`
   - Executes tests
   - Builds web version

3. **Deploy to Choreo**
   - Pushes container images
   - Deploys services
   - Configures environment variables

---

## 🔄 CI/CD Workflows

### choreo-deploy.yml
- **Trigger**: Push to `main` branch
- **Actions**: Build → Test → Deploy

### tests.yml
- **Trigger**: Push and Pull Requests on `main` and `develop`
- **Actions**: Run backend and frontend tests

---

## 🌐 Access Your Application

After successful deployment:

- **Frontend**: `https://<project-name>.web.app`
- **Backend API**: `https://<project-name>.api.app/api`
- **Swagger Docs**: `https://<project-name>.api.app/docs`

---

## 📖 More Information

- [CHOREO_SETUP.md](./CHOREO_SETUP.md) - Detailed setup guide
- [.github/DEPLOYMENT.md](./.github/DEPLOYMENT.md) - Advanced deployment options
- [Choreo Docs](https://choreo.dev/docs)

---

## 🆘 Support

For issues with deployment, see [CHOREO_SETUP.md](./CHOREO_SETUP.md) troubleshooting section.

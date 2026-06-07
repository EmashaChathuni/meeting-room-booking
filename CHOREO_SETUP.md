# Quick Start - Choreo Deployment

## 🚀 5-Minute Setup

### 1. Create Choreo Project
```bash
# Visit https://choreo.dev and create account
# Create new project named "meeting-room-booking"
```

### 2. Connect GitHub Repository
1. In Choreo Dashboard: **Connect Repository**
2. Select your GitHub account and this repository
3. Authorize Choreo to access GitHub

### 3. Add GitHub Secrets
```bash
# In GitHub: Settings → Secrets and variables → Actions
# Add:
CHOREO_ORG=your-org-name
CHOREO_PROJECT=meeting-room-booking
CHOREO_PAT=your-choreo-token
```

### 4. Configure Supabase Connection
1. Get your Supabase connection string from Project Settings
2. In Choreo Dashboard → Backend service → Environment Variables
3. Add: `SUPABASE_DB_URL=<your-connection-string>`

### 5. Deploy
```bash
git push origin main
# Watch GitHub Actions deploy automatically
```

---

## 📊 Project Structure for Choreo

```
.
├── .choreo/
│   ├── deploy.yaml          ← Choreo configuration
│   └── endpoints.yaml       ← API endpoints definition
├── .github/workflows/
│   ├── choreo-deploy.yml    ← Deployment pipeline
│   └── tests.yml            ← Test pipeline
├── backend/                 ← Go REST API
│   ├── main.go
│   ├── go.mod
│   └── Dockerfile
├── frontend/                ← Flutter Web App
│   ├── lib/
│   ├── pubspec.yaml
│   └── Dockerfile
└── docker-compose.yml
```

---

## 🔗 Access Your Application

After deployment:
- **Frontend**: `https://<your-choreo-project>.web.app`
- **Backend API**: `https://<your-choreo-project>.api.app`

---

## 📝 Environment Variables

### Backend (.choreo/deploy.yaml)
```yaml
environment:
  - name: SUPABASE_DB_URL
    valueFrom:
      secretKeyRef:
        name: supabase-credentials
        key: db-url
  - name: PORT
    value: "8080"
```

### Frontend
```yaml
environment:
  - name: API_BASE_URL
    value: "https://backend-api.choreo-domain/api"
```

---

## 🧪 Testing Before Deploy

```bash
# Test backend
cd backend
go test ./...

# Test frontend
cd frontend
flutter test

# Build web for production
flutter build web
```

---

## 🔄 Continuous Deployment

Every push to `main` branch automatically:
1. ✅ Runs tests
2. ✅ Builds services
3. ✅ Deploys to Choreo

---

## ❌ Troubleshooting

| Issue | Solution |
|---|---|
| Secrets not found | Check GitHub Settings → Secrets are added correctly |
| Build fails | Run `go mod tidy` and `flutter pub get` locally first |
| Service won't start | Check SUPABASE_DB_URL is valid |
| Deployment stuck | Cancel workflow, push again |

---

## 📚 Learn More

- [Choreo Documentation](https://choreo.dev/docs)
- [GitHub Actions Guide](https://docs.github.com/en/actions)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Go Deployment Best Practices](https://golang.org/doc/deploy)

---

**Need help?** Contact: support@choreo.dev

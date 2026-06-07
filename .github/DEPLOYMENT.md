# Deployment Guide - Choreo

## Prerequisites

1. **Choreo Account**: Sign up at [choreo.dev](https://choreo.dev)
2. **GitHub Repository**: This project is already connected via GitHub
3. **Secrets Configuration**: Set up the following secrets in your GitHub repository

## Setup Instructions

### Step 1: Generate Choreo PAT (Personal Access Token)

1. Log in to Choreo Dashboard
2. Go to **Settings** → **API Keys**
3. Click **Generate New Token**
4. Copy the token (you'll need it in Step 2)

### Step 2: Configure GitHub Secrets

In your GitHub repository:
1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add the following secrets:

| Secret Name | Value |
|---|---|
| `CHOREO_ORG` | Your Choreo organization name |
| `CHOREO_PROJECT` | Your Choreo project name |
| `CHOREO_PAT` | The PAT token from Step 1 |

Example:
```
CHOREO_ORG=my-org
CHOREO_PROJECT=meeting-room-booking
CHOREO_PAT=<your-token-here>
```

### Step 3: Configure Environment Variables

The following environment variables should be set in Choreo:

**Backend Service:**
- `SUPABASE_DB_URL`: Your Supabase database connection string
- `PORT`: 8080 (default)
- `API_KEY`: Your API secret key

Configure these in Choreo Dashboard:
1. Go to your Backend service
2. **Environment Variables** → **Add Variable**
3. Set each variable

### Step 4: Deploy via GitHub

#### Automatic Deployment (Recommended)
The pipeline automatically deploys when you push to `main` branch:

```bash
git add .
git commit -m "feat: new feature"
git push origin main
```

The GitHub Actions workflow will:
1. ✅ Build Backend (Go)
2. ✅ Build Frontend (Flutter Web)
3. ✅ Run Tests
4. ✅ Deploy to Choreo

#### Manual Deployment
If automatic deployment is not triggered:

1. Go to GitHub Actions tab
2. Select **Deploy to Choreo** workflow
3. Click **Run workflow** → Select branch → **Run**

### Step 5: Monitor Deployment

1. **GitHub Actions**: Watch the workflow progress in Actions tab
2. **Choreo Dashboard**: Monitor deployment status and logs
3. **Access Your App**:
   - Frontend: `https://<choreo-domain>/frontend`
   - Backend API: `https://<choreo-domain>/api`

## Troubleshooting

### Build Failures

**Backend Go build fails:**
```bash
cd backend
go mod tidy
go mod verify
```

**Frontend Flutter build fails:**
```bash
cd frontend
flutter pub get
flutter pub upgrade
flutter build web
```

### Deployment Fails

1. Check GitHub Actions logs for errors
2. Verify secrets are correctly set in GitHub
3. Ensure `.choreo/deploy.yaml` is valid YAML
4. Check Choreo service logs

### Environment Variables Not Applied

1. Redeploy service after setting variables
2. Verify variable names match exactly
3. Check Choreo dashboard for confirmation

## Rollback

To rollback to previous version:

1. Go to Choreo Dashboard
2. Select service → **Deployments**
3. Find previous successful deployment
4. Click **Rollback**

## Scaling

Adjust resource limits in `.choreo/deploy.yaml`:

```yaml
resources:
  requests:
    memory: 256Mi
    cpu: 250m
  limits:
    memory: 512Mi
    cpu: 500m
replicas:
  min: 1
  max: 3
```

Then push changes to trigger redeployment.

## CI/CD Pipeline

The workflows include:

1. **choreo-deploy.yml** - Main deployment pipeline
2. **tests.yml** - Automated testing on PRs and pushes

To modify workflows, edit files in `.github/workflows/`

## Support

- Choreo Docs: https://choreo.dev/docs
- GitHub Actions: https://docs.github.com/en/actions
- Contact: support@choreo.dev

# Automatic Deployment Setup (One-Time, 5 minutes)

## What This Does
- **Automatic** deployments on every `git push`
- Backend & Frontend deploy independently  
- Zero manual steps after initial setup

---

## ⚡ ONE-TIME SETUP (5 min)

### Step 1: Create Vercel Projects
1. Go to https://vercel.com/dashboard
2. Create project `ceo-ai-backend` 
   - Import from GitHub this repo
   - Framework: **Other** (Python FastAPI)
   - Root Directory: `ceo/backend`
   - **Don't deploy yet** (just create)
3. Create project `ceo-ai-frontend`
   - Same repo, same import
   - Framework: **Create React App**
   - Root Directory: `ceo/frontend`
   - **Don't deploy yet** (just create)

### Step 2: Get Vercel Tokens (GitHub Secrets)
1. Go to https://vercel.com/account/tokens
2. Click "Create" → Name: **GITHUB_ACTIONS** → Copy token
3. Go to GitHub repo Settings → Secrets and variables → Actions → **New repository secret**
   - Name: `VERCEL_TOKEN`
   - Value: (paste the token)

### Step 3: Get Project IDs
1. Backend project → Settings → General → **Project ID** → Copy
2. Frontend project → Settings → General → **Project ID** → Copy
3. GitHub repo Settings → Secrets → Add 2 new secrets:
   - `VERCEL_PROJECT_ID_BACKEND` = (backend ID)
   - `VERCEL_PROJECT_ID_FRONTEND` = (frontend ID)
   - `VERCEL_ORG_ID` = (your Vercel org/team ID)

### Step 4: Set Environment Variables on Vercel
**Backend Project:**
- Go to Settings → Environment Variables → Add:
```
MASTER_KEY=super-secret-key-12345
JWT_SECRET_KEY=jwt-secret-key-67890
MONGO_URI=mongodb+srv://...
MONGO_DB_NAME=ceo_ai
OPENAI_API_KEY=sk-proj-...
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...
GEMINI_API_KEY=...
GUMROAD_CLIENT_ID=...
GUMROAD_CLIENT_SECRET=...
GUMROAD_ACCESS_TOKEN=...
ENVIRONMENT=production
```

**Frontend Project:**
- Go to Settings → Environment Variables → Add:
```
REACT_APP_BACKEND_URL=https://ceo-ai-backend.vercel.app
```

---

## 🚀 AUTO-DEPLOY (After Setup)

### That's it! Every time you:
```bash
git add .
git commit -m "Your changes"
git push origin main
```

**Automatic Actions:**
1. ✅ GitHub detects push
2. ✅ Workflow runs (2-3 min)
3. ✅ Backend deploys to Vercel
4. ✅ Frontend deploys to Vercel
5. ✅ Both live instantly

Check deployment status: GitHub repo → **Actions** tab

---

## ✅ Verify Deployment

### Check Status
- GitHub: Actions tab → workflow status
- Vercel: Dashboard → both projects show green checkmark

### Test Backend
```bash
curl https://ceo-ai-backend.vercel.app/health
```

### Test Frontend  
Visit: https://ceo-ai-frontend.vercel.app

---

## 🔧 Troubleshooting

**Workflow fails?**
- Check GitHub Actions error logs
- Verify all secrets are set (Settings → Secrets)
- Verify environment variables set on Vercel projects

**Deploy still manual?**
- Ensure you're pushing to `main` branch
- Check workflow file paths are correct
- Verify repo is public or has GitHub Actions enabled

**"Project not found" error?**
- Double-check Project IDs match exactly
- Ensure VERCEL_ORG_ID is set

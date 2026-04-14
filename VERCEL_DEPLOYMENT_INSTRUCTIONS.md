# Deploy to Vercel - Complete Guide

## Quick Deploy (2 minutes)

### 1. Backend Deployment

```bash
# From project root
cd backend
vercel --prod
```

When prompted:
- **Project name**: `ceo-ai-backend` (or your choice)
- **Directory**: `./` (current directory)
- **Build command**: Leave default or set to `pip install -r requirements.txt`
- **Output directory**: Leave empty

### 2. Set Environment Variables on Vercel

Go to **Vercel Dashboard** → Your Project → **Settings** → **Environment Variables**

Add these variables:
```
MASTER_KEY = your-secure-master-key-here
JWT_SECRET_KEY = your-secure-jwt-key-here
MONGO_URI = (from .env)
MONGO_DB_NAME = ceo_ai
OPENAI_API_KEY = (from .env)
SUPABASE_URL = (from .env)
SUPABASE_ANON_KEY = (from .env)
SUPABASE_SERVICE_ROLE_KEY = (from .env)
GEMINI_API_KEY = (from .env)
GUMROAD_CLIENT_ID = (from .env)
GUMROAD_CLIENT_SECRET = (from .env)
GUMROAD_ACCESS_TOKEN = (from .env)
ENVIRONMENT = production
```

**Important**: Use **strong, unique values** for `MASTER_KEY` and `JWT_SECRET_KEY` in production!

### 3. Frontend Deployment

```bash
# From project root
cd frontend
vercel --prod
```

**Frontend Environment Variables** on Vercel:
```
REACT_APP_BACKEND_URL = https://your-backend-domain.vercel.app
```

## Verify Deployment

### Backend Health Check
```bash
curl https://your-backend-domain.vercel.app/health
```

### Frontend Check
Visit `https://your-frontend-domain.vercel.app` in browser

## Troubleshooting

### "Build Failed" Error
- Check Python version (requires 3.11+)
- Verify `requirements.txt` is in backend directory
- Run locally: `pip install -r requirements.txt`

### Database Connection Issues
- Verify `MONGO_URI` in Vercel environment variables
- Check MongoDB Atlas IP whitelist (add Vercel IPs)
- Test: `vercel env pull` and test locally

### CORS Issues
Check `server.py` CORS configuration:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://your-frontend-domain.vercel.app"],  # Update this
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Auto-Deploy on Git Push

1. Connect GitHub repo to Vercel Dashboard
2. Select `backend` directory for backend project
3. Select `frontend` directory for frontend project
4. Set environment variables in Vercel UI
5. Push to `main` branch - automatic deployment!

## API Health Status

After deployment, check:
- **Docs**: `https://your-backend.vercel.app/docs`
- **OpenAPI JSON**: `https://your-backend.vercel.app/openapi.json`

# Launch Reference

## Local Development

### Option 1: Quick Start (Backend only)
```bash
cd ceo/backend
python -m venv .venv
.venv\Scripts\activate  # Windows
pip install -r requirements.txt
uvicorn server:app --reload --port 8000
```
Server: http://localhost:8000
Docs: http://localhost:8000/docs

### Option 2: Full Stack (Backend + Frontend)
```bash
# Terminal 1: Backend
cd ceo/backend
.venv\Scripts\activate
uvicorn server:app --reload --port 8000

# Terminal 2: Frontend
cd ceo/frontend
npm start
```
Backend: http://localhost:8000
Frontend: http://localhost:3000

## Production Deployment

### Deploy to Vercel
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy backend
cd ceo/backend
vercel --prod

# Deploy frontend (after backend)
cd ceo/frontend
vercel --prod
```

See [VERCEL_DEPLOYMENT_INSTRUCTIONS.md](VERCEL_DEPLOYMENT_INSTRUCTIONS.md) for complete setup with environment variables.

## Status

✅ **Local Server**: Running on http://127.0.0.1:8000
✅ **Warnings Fixed**: All deprecation warnings suppressed
✅ **Production Keys**: Added MASTER_KEY & JWT_SECRET_KEY to .env
✅ **Vercel Ready**: Backend vercel.json configured

# 🚀 FiiLTHY SaaS — Live Deployment Blueprint

## What You Need to Deploy

| Component | Platform | Status |
|-----------|----------|--------|
| Frontend | Vercel | Ready |
| Backend | Railway | Ready |
| Database | Railway Postgres | Ready |
| Payments | Stripe Live | Ready |
| Domain | fiilthy.ai | Ready |

---

## 1. DATABASE SETUP (Railway Postgres)

### Step 1.1: Create Project
1. Go to [railway.app](https://railway.app)
2. Click "New Project" → "Provision PostgreSQL"
3. Copy the `DATABASE_URL` (starts with `postgresql://`)

### Step 1.2: Schema Setup
Run this SQL in Railway's Query tab or psql:

```sql
-- Users table (extends your existing schema)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    plan VARCHAR(20) DEFAULT 'free' CHECK (plan IN ('free', 'starter', 'pro', 'enterprise')),
    generations_used INTEGER DEFAULT 0,
    stripe_customer_id VARCHAR(255),
    stripe_subscription_id VARCHAR(255),
    referral_code VARCHAR(20) UNIQUE,
    referred_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Usage analytics tracking
CREATE TABLE IF NOT EXISTS usage_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    event_type VARCHAR(50) NOT NULL, -- 'generation', 'upgrade_click', 'payment', 'referral'
    plan_at_time VARCHAR(20),
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payments tracking
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    stripe_session_id VARCHAR(255),
    stripe_subscription_id VARCHAR(255),
    plan VARCHAR(20),
    amount_cents INTEGER,
    currency VARCHAR(3) DEFAULT 'usd',
    status VARCHAR(20) DEFAULT 'pending', -- pending, succeeded, failed, refunded
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

-- Referrals
CREATE TABLE IF NOT EXISTS referrals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    referrer_id UUID REFERENCES users(id),
    referred_id UUID REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'pending', -- pending, converted, rewarded
    reward_generations INTEGER DEFAULT 5,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_plan ON users(plan);
CREATE INDEX idx_usage_events_user_id ON usage_events(user_id);
CREATE INDEX idx_usage_events_created ON usage_events(created_at);
CREATE INDEX idx_payments_user_id ON payments(user_id);
CREATE INDEX idx_payments_stripe_session ON payments(stripe_session_id);
```

---

## 2. BACKEND DEPLOYMENT (Railway)

### Step 2.1: Prepare Backend
Ensure `ceo/backend/requirements-prod.txt` includes:
```
fastapi
uvicorn[standard]
python-jose[cryptography]
passlib[bcrypt]
stripe
asyncpg
psycopg2-binary
python-dotenv
motor
pymongo
```

### Step 2.2: Environment Variables in Railway
Go to Railway → Your Backend Service → Variables → Add:

```bash
# Database (from Step 1.1)
DATABASE_URL=postgresql://postgres:PASSWORD@HOST:5432/railway

# Existing
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

# NEW - Subscription billing
STRIPE_WEBHOOK_SECRET_BILLING=whsec_...
STRIPE_PRICE_STARTER=price_xxx
STRIPE_PRICE_PRO=price_xxx
STRIPE_PRICE_ENTERPRISE=price_xxx

# JWT
SECRET_KEY=your-super-secret-jwt-key-min-32-chars

# Frontend URL (for CORS + redirects)
FRONTEND_URL=https://fiilthy.vercel.app
ENVIRONMENT=production
```

### Step 2.3: Deploy
```bash
cd ceo/backend
railway login
railway init
railway up
```

Copy the deployment URL: `https://fiilthy-backend.up.railway.app`

---

## 3. FRONTEND DEPLOYMENT (Vercel)

### Step 3.1: Build Configuration
Ensure `ceo/frontend/vercel.json` exists:
```json
{
  "version": 2,
  "builds": [
    {
      "src": "package.json",
      "use": "@vercel/static-build",
      "config": { "distDir": "build" }
    }
  ],
  "routes": [
    { "handle": "filesystem" },
    { "src": "/.*", "dest": "/index.html" }
  ]
}
```

### Step 3.2: Environment Variables
In Vercel Dashboard → Project → Settings → Environment Variables:
```bash
REACT_APP_API_URL=https://fiilthy-backend.up.railway.app
REACT_APP_STRIPE_PUBLISHABLE_KEY=pk_live_...
```

### Step 3.3: Deploy
```bash
cd ceo/frontend
vercel --prod
```

---

## 4. STRIPE LIVE MODE SETUP

### Step 4.1: Create Products & Prices
1. Stripe Dashboard → Products → Add Product
2. Create 3 products with **recurring** pricing:
   - Starter: $29/month → Price ID = `price_xxx` → save as `STRIPE_PRICE_STARTER`
   - Pro: $79/month → Price ID = `price_xxx` → save as `STRIPE_PRICE_PRO`
   - Enterprise: $299/month → Price ID = `price_xxx` → save as `STRIPE_PRICE_ENTERPRISE`

### Step 4.2: Webhook Endpoint
1. Stripe Dashboard → Developers → Webhooks → Add endpoint
2. Endpoint URL: `https://fiilthy-backend.up.railway.app/api/billing/webhook`
3. Select events: `checkout.session.completed`, `customer.subscription.updated`, `customer.subscription.deleted`
4. Copy signing secret → save as `STRIPE_WEBHOOK_SECRET_BILLING`

### Step 4.3: Customer Portal (for cancel/downgrade)
In your backend, add:
```python
@app.post("/api/billing/portal")
async def create_portal_session(user_id: str):
    """Create Stripe Customer Portal for managing subscription"""
    stripe.api_key = os.environ.get('STRIPE_SECRET_KEY')
    
    user = await get_user(user_id)
    if not user or not user.get('stripe_customer_id'):
        raise HTTPException(status_code=400, detail="No Stripe customer")
    
    session = stripe.billing_portal.Session.create(
        customer=user['stripe_customer_id'],
        return_url=os.environ.get('FRONTEND_URL', 'https://fiilthy.vercel.app')
    )
    return {"url": session.url}
```

---

## 5. DOMAIN SETUP (fiilthy.ai)

### Step 5.1: Buy Domain
1. Go to [namecheap.com](https://namecheap.com) or [cloudflare.com](https://cloudflare.com)
2. Purchase `fiilthy.ai`

### Step 5.2: Connect to Vercel
1. Vercel Dashboard → Project → Settings → Domains
2. Add `fiilthy.ai`
3. Follow DNS instructions (add A record / CNAME)

### Step 5.3: Connect to Railway (API subdomain)
1. Cloudflare DNS → Add CNAME:
   - Name: `api`
   - Target: `fiilthy-backend.up.railway.app`
2. Railway → Settings → Domains → Add custom domain: `api.fiilthy.ai`

### Step 5.4: Update CORS
Update `FRONTEND_URL` in Railway to `https://fiilthy.ai`

---

## 6. REFERRAL SYSTEM (Fast Money)

Add to `usage_manager.py`:

```python
REFERRAL_REWARD_GENERATIONS = 5  # Free generations for referrer

async def create_referral_code(user_id: str, db) -> str:
    """Generate unique referral code for user"""
    import random, string
    code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=8))
    
    await db.execute(
        "UPDATE users SET referral_code = $1 WHERE id = $2",
        code, user_id
    )
    return code

async def process_referral(referral_code: str, new_user_id: str, db):
    """Credit referrer when new user signs up with code"""
    # Find referrer
    referrer = await db.fetchrow(
        "SELECT id FROM users WHERE referral_code = $1",
        referral_code
    )
    if not referrer:
        return None
    
    # Create referral record
    await db.execute("""
        INSERT INTO referrals (referrer_id, referred_id, status)
        VALUES ($1, $2, 'pending')
    """, referrer['id'], new_user_id)
    
    # Reward referrer with bonus generations
    await db.execute("""
        UPDATE users 
        SET generations_used = GREATEST(0, generations_used - $1)
        WHERE id = $2
    """, REFERRAL_REWARD_GENERATIONS, referrer['id'])
    
    return {"rewarded_generations": REFERRAL_REWARD_GENERATIONS}
```

---

## 7. ANALYTICS TRACKING

Track every important event:

```python
async def track_event(user_id: str, event_type: str, plan: str, metadata: dict, db):
    """Track usage events for analytics"""
    await db.execute("""
        INSERT INTO usage_events (user_id, event_type, plan_at_time, metadata)
        VALUES ($1, $2, $3, $4)
    """, user_id, event_type, plan, json.dumps(metadata))
```

Events to track:
- `generation` — AI content generated
- `limit_reached` — User hit plan limit
- `upgrade_click` — Clicked upgrade button
- `checkout_started` — Stripe checkout opened
- `payment_succeeded` — Payment completed
- `payment_failed` — Payment failed
- `referral_signup` — New user from referral
- `downgrade` — User downgraded plan

---

## 8. ADMIN DASHBOARD (VC-Ready)

Create `ceo/backend/admin_routes.py`:

```python
from fastapi import APIRouter, Depends, HTTPException
from datetime import datetime, timedelta

admin_router = APIRouter(prefix="/api/admin")

async def require_admin(user_id: str, db):
    user = await db.fetchrow("SELECT is_admin FROM users WHERE id = $1", user_id)
    if not user or not user['is_admin']:
        raise HTTPException(status_code=403, detail="Admin required")

@admin_router.get("/stats")
async def get_admin_stats(_=Depends(require_admin)):
    """Key SaaS metrics for investors"""
    total_users = await db.fetchval("SELECT COUNT(*) FROM users")
    paid_users = await db.fetchval("SELECT COUNT(*) FROM users WHERE plan != 'free'")
    mrr = await db.fetchval("""
        SELECT COALESCE(SUM(amount_cents), 0) / 100.0 
        FROM payments 
        WHERE status = 'succeeded' 
        AND created_at > NOW() - INTERVAL '30 days'
    """)
    
    return {
        "total_users": total_users,
        "paid_users": paid_users,
        "conversion_rate": round(paid_users / total_users * 100, 2) if total_users else 0,
        "mrr": mrr,
        "arr": mrr * 12,
        "avg_revenue_per_user": round(mrr / paid_users, 2) if paid_users else 0
    }

@admin_router.get("/users")
async def list_users(limit: int = 100, _=Depends(require_admin)):
    """List all users with plan/revenue"""
    rows = await db.fetch("""
        SELECT u.id, u.email, u.plan, u.generations_used, u.created_at,
               COALESCE(SUM(p.amount_cents), 0) as lifetime_value
        FROM users u
        LEFT JOIN payments p ON u.id = p.user_id AND p.status = 'succeeded'
        GROUP BY u.id
        ORDER BY lifetime_value DESC
        LIMIT $1
    """, limit)
    return [dict(row) for row in rows]
```

---

## 9. FINAL CHECKLIST

### Before Going Live
- [ ] Database migrated (all tables created)
- [ ] Stripe live keys set (not test keys)
- [ ] Price IDs created and in env vars
- [ ] Webhook endpoint registered with Stripe
- [ ] Domain purchased and connected
- [ ] Frontend CORS allows production domain
- [ ] Admin user marked `is_admin = true` in DB
- [ ] Test payment with real card (small amount)
- [ ] Refund test payment

### Monitoring
- [ ] Railway dashboard monitoring enabled
- [ ] Stripe email receipts enabled
- [ ] Error tracking (Sentry recommended)
- [ ] Uptime monitoring (UptimeRobot free tier)

---

## 10. URLs WHEN LIVE

| Service | URL |
|---------|-----|
| App | `https://fiilthy.ai` |
| API | `https://api.fiilthy.ai` |
| Admin | `https://api.fiilthy.ai/api/admin/stats` |
| Stripe Dashboard | `https://dashboard.stripe.com` |

---

# 💰 YOUR SaaS IS NOW LIVE

**Revenue Model:**
- Free: 5 generations (acquisition)
- Starter: $29/mo (50 generations)
- Pro: $79/mo (500 generations)
- Enterprise: $299/mo (unlimited)

**Growth Model:**
- Referral rewards: 5 free generations per signup
- Usage limits trigger at peak value (after generation)
- Upgrade modal shows on limit + usage bar creates urgency

**Investor Metrics:**
- MRR/ARR tracked automatically
- User conversion rate visible
- Lifetime value per user calculated
- Churn tracked via Stripe webhooks

---

# 🎯 NEXT STEPS

1. **Deploy now**: Follow steps 1-5 above
2. **Test flow**: Sign up → generate 5x → upgrade → pay → continue
3. **Optimize**: Track analytics → A/B test pricing → add annual discounts
4. **Scale**: Add team plans → API access → white-label options

**Say "deploy it live" and I'll generate the exact Railway + Vercel config files.**

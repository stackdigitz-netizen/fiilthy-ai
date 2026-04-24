# 🚀 FiiLTHY — LAUNCH NOW GUIDE

Get your SaaS live in under 30 minutes.

---

## STEP 0: PRE-LAUNCH CHECKLIST

Before deploying, make sure you have:

- [ ] Stripe account (dashboard.stripe.com)
- [ ] Railway account (railway.app) — free tier works
- [ ] Vercel account (vercel.com) — free tier works
- [ ] MongoDB Atlas cluster (mongodb.com) — free tier works

---

## STEP 1: STRIPE SETUP (5 min)

### 1.1 Create Products with Recurring Prices

1. Go to https://dashboard.stripe.com/products
2. Click "Add Product"
3. Create 3 products:

**Product 1: Starter**
- Name: `FiiLTHY Starter`
- Description: `50 AI generations per month`
- Pricing → Recurring → Monthly → `$29.00`
- Save → Copy the **Price ID** (starts with `price_`)

**Product 2: Pro**
- Name: `FiiLTHY Pro`
- Description: `500 AI generations per month`
- Pricing → Recurring → Monthly → `$79.00`
- Save → Copy the **Price ID**

**Product 3: Enterprise**
- Name: `FiiLTHY Enterprise`
- Description: `Unlimited AI generations`
- Pricing → Recurring → Monthly → `$299.00`
- Save → Copy the **Price ID**

### 1.2 Get API Keys

1. Stripe Dashboard → Developers → API Keys
2. Copy **Publishable key** (`pk_live_...`)
3. Copy **Secret key** (`sk_live_...`)
4. Click "Reveal test key" → Copy **Secret key** for testing

### 1.3 Create Webhook Endpoint

1. Stripe Dashboard → Developers → Webhooks → Add endpoint
2. Endpoint URL: `https://fiilthy-api.up.railway.app/api/billing/webhook`
3. Select events:
   - `checkout.session.completed`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
4. Click "Add endpoint"
5. Copy **Signing secret** (`whsec_...`)

---

## STEP 2: MONGODB ATLAS (5 min)

### 2.1 Create Cluster

1. Go to https://cloud.mongodb.com
2. Create free cluster (M0)
3. Create database user (remember username + password)
4. Add IP `0.0.0.0/0` to Network Access (allows all)

### 2.2 Get Connection String

1. Click "Connect" → "Drivers" → "Python"
2. Copy the connection string:
   ```
   mongodb+srv://USERNAME:PASSWORD@cluster0.xxxxx.mongodb.net/ceo_ai?retryWrites=true&w=majority
   ```
3. Replace `USERNAME` and `PASSWORD` with your actual credentials

---

## STEP 3: DEPLOY BACKEND TO RAILWAY (10 min)

### 3.1 Install Railway CLI

```bash
npm install -g @railway/cli
```

### 3.2 Login & Initialize

```bash
cd ceo/backend
railway login
railway init
# Select "Create a new project"
# Name it: fiilthy-backend
```

### 3.3 Set Environment Variables

```bash
railway variables set ENVIRONMENT=production
railway variables set PYTHONUNBUFFERED=1
railway variables set MONGO_URI="mongodb+srv://YOUR_USER:YOUR_PASS@cluster0.xxxxx.mongodb.net/ceo_ai?retryWrites=true&w=majority"
railway variables set STRIPE_SECRET_KEY="<YOUR_STRIPE_SECRET_KEY>"
railway variables set STRIPE_WEBHOOK_SECRET="whsec_xxxxxxxxxxxxxxxxxxxxxxxx"
railway variables set STRIPE_WEBHOOK_SECRET_BILLING="whsec_xxxxxxxxxxxxxxxxxxxxxxxx"
railway variables set STRIPE_PRICE_STARTER="price_xxxxxxxxxxxxxxxx"
railway variables set STRIPE_PRICE_PRO="price_xxxxxxxxxxxxxxxx"
railway variables set STRIPE_PRICE_ENTERPRISE="price_xxxxxxxxxxxxxxxx"
railway variables set FRONTEND_URL="https://fiilthy.vercel.app"
railway variables set OWNER_EMAIL="youremail@gmail.com"
```

### 3.4 Deploy

```bash
railway up
```

### 3.5 Get Backend URL

```bash
railway domain
```

Copy the URL (e.g., `https://fiilthy-api.up.railway.app`)

---

## STEP 4: DEPLOY FRONTEND TO VERCEL (5 min)

### 4.1 Install Vercel CLI

```bash
npm install -g vercel
```

### 4.2 Update Frontend Config

Edit `ceo/frontend/vercel.json`:
- Replace `https://fiilthy-api.up.railway.app` with your actual Railway URL
- Replace `pk_live_REPLACE_WITH_YOUR_KEY` with your actual Stripe publishable key

Also edit `ceo/frontend/.env.production` with the same values.

### 4.3 Deploy

```bash
cd ceo/frontend
vercel --prod
# Follow prompts:
# - Link to existing project? No
# - Project name? fiilthy
# - Directory? ./
```

### 4.4 Set Environment Variables in Vercel Dashboard

1. Go to https://vercel.com/dashboard
2. Click your `fiilthy` project
3. Settings → Environment Variables
4. Add:
   - `REACT_APP_BACKEND_URL` = `https://fiilthy-api.up.railway.app`
   - `REACT_APP_STRIPE_PUBLISHABLE_KEY` = your Stripe publishable key
5. Redeploy:
   ```bash
   vercel --prod
   ```

---

## STEP 5: UPDATE STRIPE WEBHOOK URL (2 min)

1. Go back to Stripe Dashboard → Developers → Webhooks
2. Find your webhook endpoint
3. Edit → Update URL to match your Railway domain:
   ```
   https://YOUR-RAILWAY-URL/api/billing/webhook
   ```
4. Save

---

## STEP 6: TEST THE FULL FLOW (3 min)

### 6.1 Test Signup

1. Go to `https://fiilthy.vercel.app`
2. Create an account
3. Verify you see `plan: free` and `0/5 used`

### 6.2 Test AI Generation

1. Generate content 5 times
2. Verify usage counter increments: `1/5`, `2/5`, etc.

### 6.3 Test Limit

1. Try to generate a 6th time
2. You should see upgrade modal appear

### 6.4 Test Payment (Use Stripe Test Card)

1. Click Upgrade → Select Starter
2. Stripe Checkout opens
3. Use test card:
   ```
   Card: 4242 4242 4242 4242
   Expiry: 12/34
   CVC: 123
   ZIP: 12345
   ```
4. Complete payment
5. You should be redirected back and see `plan: starter`

### 6.5 Test Continued Usage

1. Generate more content
2. Verify you can now generate up to 50 times

---

## TROUBLESHOOTING

### Backend won't start
```bash
railway logs
# Check for missing env vars or import errors
```

### CORS errors in browser
- Make sure `FRONTEND_URL` in Railway matches your Vercel URL exactly
- Include `https://` and no trailing slash

### Webhook not working
- Verify webhook URL is correct in Stripe Dashboard
- Check `STRIPE_WEBHOOK_SECRET_BILLING` is set correctly
- Run `railway logs` to see webhook errors

### Payment succeeds but plan doesn't update
- Check Stripe webhook is sending to correct URL
- Verify `STRIPE_WEBHOOK_SECRET_BILLING` matches Stripe Dashboard
- Look for `checkout.session.completed` events in Stripe logs

---

## YOU'RE LIVE 🎉

Your URLs:
- **App**: `https://fiilthy.vercel.app`
- **API**: `https://fiilthy-api.up.railway.app`
- **Stripe Dashboard**: `https://dashboard.stripe.com`

Your revenue stack:
- Free: 5 generations (acquisition)
- Starter: $29/mo (50 generations)
- Pro: $79/mo (500 generations)
- Enterprise: $299/mo (unlimited)

---

## NEXT: SCALE TO $10K/MONTH

Ready to grow? See `DEPLOY_LIVE.md` for:
- Referral system (viral growth)
- Admin dashboard (investor metrics)
- Analytics tracking
- Email retention engine
- Custom domain setup (fiilthy.ai)

Say **"scale it"** and I'll build the growth engine.


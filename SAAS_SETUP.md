# FiiLTHY SaaS Setup Guide

## What Was Changed

### New Files
1. `ceo/backend/ai_services/usage_manager.py` — Plan limits, usage tracking, Stripe subscription helpers
2. `ceo/frontend/src/components/UpgradeModal.jsx` — Plan upgrade UI with Stripe checkout

### Modified Files

#### Backend
| File | Changes |
|------|---------|
| `ceo/backend/ai_services/auth_utils.py` | Added `plan` (default "free") and `generations_used` (default 0) to `UserResponse` |
| `ceo/backend/server.py` | 1. Signup sets `plan="free"`, `generations_used=0`<br>2. Login returns `plan` + `generations_used`<br>3. `/auth/me` returns `plan` + `generations_used`<br>4. New billing routes: `/billing/create-checkout`, `/billing/webhook`, `/billing/usage`<br>5. Usage enforcement on: `/ai/generate-full-product`, `/ai/generate-book`, `/ai/generate-course`, `/launch-product`, `/autonomous/run-cycle` |
| `ceo/backend/core/routes_product_launch.py` | Added `require_auth` + usage check to `generate-videos` and `launch-campaign` |

#### Frontend
| File | Changes |
|------|---------|
| `ceo/frontend/src/context/AuthContext.jsx` | Added `refreshUser()` callback to reload `/auth/me` data after upgrade |
| `ceo/frontend/src/config/authFetch.js` | Intercepts 403 `LIMIT_REACHED` responses, dispatches global `LIMIT_REACHED` event |
| `ceo/frontend/src/hooks/useApiClient.js` | Same 403 `LIMIT_REACHED` handling as `authFetch.js` |
| `ceo/frontend/src/components/Layout.jsx` | Shows plan badge, usage counter, upgrade button; listens for `LIMIT_REACHED` event to open upgrade modal |
| `ceo/frontend/src/App.jsx` | Added `/billing/success` and `/billing/cancel` routes |

---

## Environment Variables

Add these to `ceo/backend/.env`:

```bash
# Existing
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# NEW — Subscription billing
STRIPE_WEBHOOK_SECRET_BILLING=whsec_your_billing_webhook_secret

# Price IDs from your Stripe Dashboard (Products → Pricing)
# Create 3 recurring-price products, then copy their Price IDs here:
STRIPE_PRICE_STARTER=price_xxx_starter
STRIPE_PRICE_PRO=price_xxx_pro
STRIPE_PRICE_ENTERPRISE=price_xxx_enterprise
```

---

## Plan Limits

| Plan | Generations | Price |
|------|-------------|-------|
| Free | 5 | $0 |
| Starter | 50 | $29/mo |
| Pro | 500 | $79/mo |
| Enterprise | Unlimited | $299/mo |

---

## How to Run Locally

### 1. Backend
```bash
cd ceo/backend
pip install -r requirements.txt  # or requirements-prod.txt
python server.py
```
Backend runs on `http://localhost:8000`

### 2. Stripe Webhook (for local testing)
```bash
# Install Stripe CLI first, then:
stripe login
stripe listen --forward-to localhost:8000/api/billing/webhook
```
Copy the webhook signing secret into `STRIPE_WEBHOOK_SECRET_BILLING`

### 3. Frontend
```bash
cd ceo/frontend
npm install
npm start
```
Frontend runs on `http://localhost:3000`

---

## User Flow

1. **Signup/Login** → User gets `plan: "free"`, `generations_used: 0`
2. **Generate content** → Each successful AI call increments `generations_used`
3. **Hit limit** → Server returns `403 { detail: "LIMIT_REACHED" }`
4. **Frontend shows upgrade modal** → User selects Starter/Pro/Enterprise
5. **Stripe checkout** → User pays via Stripe Checkout
6. **Webhook fires** → `checkout.session.completed` updates user's plan in DB
7. **User returns to app** → `refreshUser()` reloads new plan + reset usage
8. **Continue generating** → Back to step 2 with new limit

---

## API Endpoints (New)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/billing/create-checkout` | Create Stripe Checkout session for subscription |
| POST | `/api/billing/webhook` | Stripe webhook handler (checkout.session.completed) |
| GET | `/api/billing/usage` | Get current user's usage stats |

---

## Testing

### Test Usage Limit
1. Signup as new user (free plan)
2. Generate content 5 times
3. 6th generation should trigger `LIMIT_REACHED`
4. Upgrade modal should appear

### Test Stripe Checkout (Test Mode)
1. Click "Upgrade" in Layout
2. Select Starter plan
3. Use Stripe test card: `4242 4242 4242 4242`
4. Any future date, any CVC, any ZIP
5. Payment succeeds → webhook updates plan → page refreshes user

---

## Troubleshooting

**"Failed to create checkout session"**
→ Check `STRIPE_PRICE_STARTER` etc. are valid Price IDs in your Stripe Dashboard

**"Webhook signature verification failed"**
→ Ensure `STRIPE_WEBHOOK_SECRET_BILLING` matches the secret from `stripe listen`

**User plan not updating after payment**
→ Check server logs for webhook events. Make sure the `/api/billing/webhook` endpoint is publicly accessible (use Stripe CLI for local dev)

**Frontend not showing usage**
→ Check `/auth/me` response includes `plan` and `generations_used` fields


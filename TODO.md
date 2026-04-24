# TODO: FiiLTHY SaaS Upgrade

## Backend

- [x] `ceo/backend/ai_services/usage_manager.py` — Usage limits, plan management, Stripe helpers
- [x] `ceo/backend/ai_services/auth_utils.py` — User model with plan & generations_used fields
- [x] `ceo/backend/server.py` — Auth responses include plan/generations_used; billing routes; usage enforcement on AI generation endpoints
- [x] `ceo/backend/core/routes_product_launch.py` — Usage check on generate-videos & launch-campaign

## Frontend

- [x] `ceo/frontend/src/config/authFetch.js` — Intercepts 403 LIMIT_REACHED, dispatches global event
- [x] `ceo/frontend/src/hooks/useApiClient.js` — Same LIMIT_REACHED handling added
- [x] `ceo/frontend/src/context/AuthContext.jsx` — Added refreshUser callback
- [x] `ceo/frontend/src/components/UpgradeModal.jsx` — Modal with 3 paid plans, Stripe checkout redirect
- [x] `ceo/frontend/src/components/Layout.jsx` — Shows plan badge, usage count, upgrade button, listens for LIMIT_REACHED
- [x] `ceo/frontend/src/App.jsx` — Added /billing/success and /billing/cancel routes

## Documentation

- [x] `SAAS_SETUP.md` — Complete setup guide with env vars, Stripe config, troubleshooting

## Status: COMPLETE

All features implemented. See `SAAS_SETUP.md` for running instructions.


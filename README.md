# JAIDEV SMART CONNECT — starter application

This package contains a working mobile-friendly web application starter with:
- JAIDEV staff/admin sign-in through Supabase Auth
- Customer/business creation and editing
- Public multi-link landing pages
- Unlimited link rows (subject to your database/storage limits)
- Artistic-ready QR output (current starter QR is a clean standard QR; artistic templates/logo overlay are a next UI enhancement)
- QR PNG download and permanent business URL copy
- Web NFC writing where supported (HTTPS + compatible Android browser/device)
- Page-view and button-click analytics
- Admin/staff role separation in Supabase Row Level Security

## Files
- `index.html` — complete frontend application
- `schema.sql` — database tables, indexes, triggers and Row Level Security policies

## Stage 1 — create the free backend
1. Create a Supabase project at https://supabase.com.
2. Open **SQL Editor** in your project.
3. Paste and run the complete `schema.sql`.
4. Open **Project Settings → API** (or API Keys).
5. Copy the Project URL and the `anon` / publishable public key.
6. Open `index.html` in a text editor. Replace:
   - `PASTE_SUPABASE_PROJECT_URL_HERE`
   - `PASTE_SUPABASE_ANON_PUBLIC_KEY_HERE`
   with your own values.
   Never use the `service_role` / secret key in this file.

## Stage 2 — create the JAIDEV master admin
1. In Supabase, open **Authentication → Users** and add your own user with your email and a strong password.
2. Copy the new user's UUID.
3. In SQL Editor run:
   `update public.profiles set role='admin' where id='YOUR_AUTH_USER_UUID';`
4. Sign in to the website using that email/password.
5. Create staff accounts in Authentication → Users, then assign:
   `update public.profiles set role='staff' where id='STAFF_AUTH_USER_UUID';`
6. Staff can manage customer pages and links. Only admin can manage profile roles.

## Stage 3 — free hosting
You need HTTPS for Web NFC. Recommended free static hosting:
- Cloudflare Pages: https://pages.cloudflare.com
- GitHub Pages: https://pages.github.com

For Cloudflare Pages, create a project and upload/deploy `index.html` as a static site. For GitHub Pages, create a repository, upload `index.html`, enable Pages in repository Settings, and publish from the main branch. Use your final HTTPS site URL as the permanent page host.

For production, use a custom domain you control, such as a subdomain dedicated to the service. Do not change the domain after printing QR stands unless you have configured permanent redirects.

## Stage 4 — create your first business
1. Sign in as admin.
2. Choose **Customers → Add customer**.
3. Enter business name and unique slug (lowercase letters/numbers/hyphens).
4. Save, then open **Links & QR**.
5. Select the business and add each destination link.
6. Download the QR PNG and test it with multiple phones.
7. Open the public page URL and test every button.

Supported link examples:
- Google Review: `https://g.page/r/REVIEW_CODE/review` or the business's direct review URL
- Instagram: `https://www.instagram.com/businessname/`
- Facebook: `https://www.facebook.com/businessname`
- WhatsApp: `https://wa.me/91XXXXXXXXXX`
- Website: `https://example.com`
- Maps: a Google Maps share link
- Call: `tel:+91XXXXXXXXXX`
- UPI: `upi://pay?pa=merchant@upi&pn=Business%20Name`
- Menu/catalogue: a public PDF URL or catalogue page

## NFC instructions
- NFC writing is supported only where the browser exposes Web NFC (commonly Chrome on supported Android devices), the site is served over HTTPS, and NFC is enabled.
- Use an NTAG213 tag. The tag must have sufficient free memory for the URL.
- In Links & QR, select a customer and click **Write URL to NFC tag**, then hold the tag near the phone.
- If Web NFC is unavailable, copy the business URL and write it using a trusted NFC writer app.
- Test the tag with a second phone. Do not lock tags permanently until the link is verified.

## Important limitations / production checklist
This is a real starter application, not a hosted live service. It becomes operational after you create/configure Supabase, assign roles, and deploy it to HTTPS hosting.
- QR currently generates a standard QR with a permanent business URL. Artistic templates, logo-safe-zone styling, draggable design editor, print layout and PDF export are the next frontend enhancement.
- Analytics currently records page views and button clicks. It cannot confirm a Google review was submitted or a UPI payment completed.
- NFC tag UID reading is not exposed by normal browser Web NFC; the app writes the URL record. The NFC tag inventory table is provided for future manual tag registration.
- Staff account creation/invitations are done in Supabase Auth; this starter does not expose public staff registration.
- Configure Supabase Auth email/password settings and password reset redirect URLs for your deployed domain.
- Configure backups, domain renewal, privacy notice, consent, rate limiting and abuse monitoring before commercial launch.
- Public analytics insert is intentionally enabled for page tracking. Add rate limiting/bot protection before a large public rollout.
- Do not store customer payment credentials. UPI links should contain only the customer's intended public merchant payment address.
- Review the SQL policies and test them with separate admin, staff, anonymous and unauthorized accounts before launch.

## Suggested production upgrades
1. Full artistic QR editor with templates, logo placement and 4x6 print preview.
2. Staff management UI (admin-only invite, role assignment, deactivate).
3. Business profile editing, link icons, drag-and-drop ordering and visibility toggles.
4. CSV analytics export, date filters and scan/click charts.
5. Secure catalogue upload using Supabase Storage.
6. Subscription billing, expiry reminders and customer support workflow.
7. Audit log for admin/staff actions.

# Indira OMS — Web App

A single-file HTML/CSS/JavaScript port of the Indira OMS Flutter Android app (v23.1). Built to live alongside your Indira Steel & Wood Furniture website using the same Supabase backend.

## Files

- **`oms.html`** — the entire web app (single file, no build step)
- **`iom_supabase_schema.sql`** — database schema to paste into Supabase SQL Editor
- **`iom_README.md`** — this file

## Setup (10 minutes)

### 1. Create a Supabase project

1. Go to <https://supabase.com>, create a free project
2. Wait ~2 minutes for the project to start
3. Open **SQL Editor** → New Query → paste the contents of `iom_supabase_schema.sql` → Run
4. Open **Storage** → New Bucket
   - Name: `oms-images`
   - **Toggle "Public bucket" ON**
5. Get your keys from **Project Settings → API**:
   - `Project URL` (looks like `https://xxx.supabase.co`)
   - `anon public` key (long `eyJ…` string)

### 2. Host the file

`oms.html` is a single static file — host it however you host the rest of your site. Examples:

- Drop it into the same folder as your existing site
- Upload to GitHub Pages, Netlify, Vercel, Cloudflare Pages
- Serve from any web host that allows static files

> **Local testing:** Just open `oms.html` in a browser, or run `python3 -m http.server` in this folder and visit <http://localhost:8000/oms.html>.

### 3. First-run

Open `oms.html` in your browser. You'll see a **Setup** screen — paste your Supabase URL and anon key. They are saved to your browser's localStorage and used to talk to Supabase. (No build step, no environment variables.)

### 4. Login

The app auto-seeds 6 demo users on first run. You can log in as any of them, or click "Login as Owner".

| Role             | Name              | PIN       |
| ---------------- | ----------------- | --------- |
| 👑 Owner         | (Owner)           | `owner123` |
| 🛍️ Sales         | Arjun Kumar       | `sales1`  |
| 🛍️ Sales         | Priya Devi        | `sales2`  |
| 🏬 Branch Head   | Senthil Kumar     | `bh1`     |
| 🏭 Factory Head  | Rajesh Factory    | `fh1`     |
| 🔨 Carpenter     | Ravi Carpenter    | `carp1`   |
| 🔨 Carpenter     | Suresh Carpenter  | `carp2`   |

> **Important:** Change all default PINs immediately for production use. New users registering through the app will be in `pending` status until the owner approves them in the Users tab.

## Features

The web app is feature-equivalent to the Flutter app for everything that doesn't depend on Android-only APIs:

- Role-based dashboards & order visibility (sales / branch_head / factory_head / carpenter / quality_check / driver / owner)
- Per-product workflow with approval/query/in-production/QC/dispatch/delivery
- Order detail with role-specific actions, image upload, activity log/comments
- Multi-product order creation with showroom / drawing / reference / model image uploads
- Branch Head 3-tab view (Pending / List / Ready), per-product approval, WhatsApp confirmation draft
- Factory Head per-product carpenter assignment, factory delivery date, priority
- Carpenter completion-photo upload with per-product progress
- Quality Check pass/fail
- Driver delivery proof + challan upload with auto status update
- Users tab (owner) with pending/active tabs, approve/reject/edit/suspend
- Tasks tab — owner can assign and reply to doubts, workers can mark done or raise doubts
- Customer Enquiries with full status workflow (New → Rep Assigned → Site Visited → WhatsApp Group Opened → Quotation Given → Finalized/Pending) and owner-managed custom fields
- Calendar with delivery dates colored by status
- Calculator (Length / Area / Weight) with live conversion and copy-to-clipboard
- Track-by-code public widget on the login screen
- Light / dark themes
- Realtime data sync via Supabase Postgres Changes
- Browser push notifications when a new task is assigned (active-tab only)

## What does **not** translate from Flutter

A few Android-only features had no web equivalent and were either replaced or left out:

- **Recent calls suggestion in Assign Task / Owner dashboard** — browsers can't read the device call log. The phone field is now a plain input.
- **FCM background push notifications** — the web app uses the standard Browser Notification API, which only fires while at least one tab is open. For full background push, you'd need a Service Worker + VAPID keys + Firebase web config, which is a separate setup. In-app realtime updates (orders / tasks / users / enquiries) use Supabase Realtime channels and work everywhere.
- **`flutter_local_notifications` boot-time notifications** — N/A on web.
- **Camera capture quality presets** — replaced with the standard `<input type="file" accept="image/*" capture="environment">`, which on mobile browsers opens the camera.

## Tech notes

- **No frameworks.** Vanilla JS with the Supabase JS v2 client from a CDN. DM Sans from Google Fonts.
- **Single file.** All HTML, CSS, and JS live inside `oms.html`. Easy to copy-paste, easy to host, easy to read.
- **Theme** matches the Flutter app exactly: orange accent `#E8900A`, full light + dark palette ported from `lib/constants.dart`.
- **State** lives in a top-level `STATE` object. Per-tab filter state is preserved across navigation. Realtime subscriptions are torn down on logout.
- **Storage.** Uploads go to the public `oms-images` bucket exactly like the Flutter app, with the same folder layout (`order-copies/`, `showroom/`, `drawings/`, `reference/`, `model/`, `completed/`, `delivered/`, `challan/`).
- **Schema** is identical — the same DB powers both the Android app and the web app simultaneously. You can run them side by side.

## Customizing

Want to change the default Supabase URL/key so users don't see the setup screen? Edit these lines near the top of the `<script>` block:

```js
const SUPABASE_URL      = window.localStorage.getItem('iom_supabase_url') || 'https://YOUR-PROJECT.supabase.co';
const SUPABASE_ANON_KEY = window.localStorage.getItem('iom_supabase_key') || 'eyJYOUR-KEY';
```

Want to embed it inside an `<iframe>` on your existing site? It works as a normal page — just point an iframe at `oms.html`.

Want to add to the same site as the existing `oms.html` you have? Either replace the existing file or rename this one (e.g. `oms-v2.html`).

## Troubleshooting

- **"Failed to fetch" / network errors on first load** — verify the Supabase URL is correct and that your project is fully started.
- **Images don't show** — make sure the `oms-images` bucket is set to **public**.
- **"Permission denied" errors** — re-run the schema; it includes Row Level Security policies that allow all reads and writes (the app handles authorization client-side via PIN).
- **Realtime updates not arriving** — check that the schema `alter publication supabase_realtime add table …` lines ran without errors.
- **Old Flutter app and web app stepping on each other** — they share the same DB, which is intentional. Edits from one show up in the other within seconds via realtime.

---

Made by porting `IOM24.1.1` Flutter project to plain HTML/CSS/JS. Same orange. Same DM Sans. Same workflow.

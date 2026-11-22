# DYNKORA — Pickleball Management App

**Book. Play. Compete.** React + TypeScript + Vite starter with Supabase schema and Capacitor Android configuration.

## What's included
- Responsive dashboard with dark/light theme switch
- Court booking request flow (demo data, browser session only)
- Open Play session discovery and join interaction (demo)
- Tournament listing and registration-interest interaction (demo)
- Player leaderboard/profile preview
- Payment records screen (no payment processing connected)
- Admin dashboard preview and role selector (not real authorization)
- Supabase starter schema for profiles, courts, bookings, Open Play, tournaments, matches, payments and notifications
- Capacitor config for Android packaging

## Run locally
1. Install Node.js 20+.
2. Extract the ZIP and open a terminal in this folder.
3. Run `npm install`
4. Run `npm run dev`
5. Open the local URL printed by Vite.

## Build the website
```bash
npm install
npm run build
```
Vercel settings:
- Framework: Vite
- Build command: `npm run build`
- Output directory: `dist`

## Connect Supabase
1. Create a Supabase project.
2. Open SQL Editor and run `supabase/schema.sql`.
3. Copy `.env.example` to `.env`.
4. Set `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`.
5. Add production-grade policies, auth flows, database constraints and server-side functions before launch.

The current UI is a frontend prototype. It does not yet load/save data through Supabase; sample records are local demo data.

## Build Android APK
Requires Android Studio + Android SDK and a computer or cloud build environment:
```bash
npm install
npm run build
npx cap add android
npx cap sync android
npx cap open android
```
In Android Studio choose **Build > Build Bundle(s) / APK(s) > Build APK(s)**.
The generated debug APK is for testing. For Play Store release, configure signing and build a signed app bundle.

## Important production work still required
- Supabase authentication and connect every screen to real database queries
- Prevent overlapping court bookings with database-side transaction/constraint logic
- Admin role authorization and audited management actions
- Integrate a Philippine payment provider using server-side checkout/webhook verification
- Push notifications and in-app notification persistence
- Tournament bracket generation, score validation and dispute workflow
- Privacy policy, terms, security review and device testing

Never put a Supabase service-role key or payment secret in frontend environment variables.

# EFC Publisher — full setup

Auth-gated admin panel, live Firestore, real push. About 40 minutes end to end.

---

## What you get

| | |
|---|---|
| **Login** | Firebase Auth. No anonymous access. |
| **Dashboard** | Counts and recent activity |
| **News** | Create, edit, delete. Optional push per article |
| **Events** | Full schedule CRUD, ticket links, status |
| **Fighters** | Whole roster — records, measurements, champion flag |
| **Results** | Post live between bouts, pushes instantly |
| **Push** | Standalone alerts by topic, with confirm-before-send |
| **Setup** | One-click Firestore seeding with real EFC data |

Every list is a live Firestore subscription. Publish in the panel and the app
updates in about a second, with no deploy and no app store update.

---

## 1. Firebase Console

**Firestore** — Build → Firestore Database → Create database → production mode,
region `europe-west1` (closest to Johannesburg with full feature support).

**Auth** — Build → Authentication → Get started → enable Email/Password.
Add a user under the Users tab. That's your login.

**Web app** — Project settings → General → Your apps → Web (`</>`).
Copy the config object.

---

## 2. Paste the config

In `admin/index.html`, find `firebaseConfig` near the bottom and replace both
`REPLACE_ME` values with the real `apiKey` and `appId`.

> The web API key is not a secret — it's visible in every Firebase web app and
> is safe to publish. What actually protects your data is the security rules in
> step 4. Never put the *server* key or a service account JSON in this file.

---

## 3. Make yourself staff

Every write is gated on an `efcStaff` custom claim, so a login alone isn't
enough. Run once per staff account:

```bash
npm install firebase-admin
```

```js
const { initializeApp, cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
initializeApp({ credential: cert(require('./service-account.json')) });

getAuth().getUserByEmail('you@geoservetechnologies.co.za')
  .then(u => getAuth().setCustomUserClaims(u.uid, { efcStaff: true }))
  .then(() => console.log('done'));
```

Service account JSON comes from Project settings → Service accounts → Generate
new private key. **Never commit it.** Sign out and back in for the claim to take.

---

## 4. Deploy the rules

```bash
firebase deploy --only firestore:rules
```

`firestore.rules` is in the repo root. Without this your database is open to
anyone who finds the project id.

---

## 5. Seed the data

Serve the admin folder — `file://` blocks the seed fetch:

```bash
cd admin && python3 -m http.server 8000
```

Open `http://localhost:8000`, sign in, go to **Setup → Seed Firestore**. Loads
4 events, 14 fighters and 9 real articles. Safe to re-run; it writes to fixed
document ids rather than duplicating.

---

## 6. Point the app at Firestore

In `lib/main.dart`, swap the repository:

```dart
import 'data/firestore_repository.dart';

// was: const MockEfcRepository()
final repository = FirestoreEfcRepository();
```

`FirestoreEfcRepository` falls back to the bundled seed data whenever a
collection is empty or unreachable, so a dropped connection still renders a
usable app rather than an error screen.

Then:

```bash
flutter pub get   # picks up cloud_firestore and xml
flutter run
```

---

## 7. Push relay

Browsers cannot send FCM — the server key would be readable in view-source.
The panel writes to Firestore; a Cloud Function sends server-side.

```bash
cd functions && npm install
firebase deploy --only functions
```

Requires the **Blaze plan**. At EFC's volume this is a few rand a month, but it
needs a card on file.

**Demoing without billing:** publish from the panel, then send the matching
notification by hand from Firebase Console → Messaging → target topic
`efc_news`. The app handles both paths identically.

---

## 8. Hosting the panel

```bash
firebase init hosting     # public directory: admin
firebase deploy --only hosting
```

Gives you `https://efc-worldwide.web.app` — a real URL for the demo. Opening a
`file:///Users/...` path on a shared screen undercuts everything else.

---

## Testing push properly

1. `flutter run`, copy the token from `EFC push token: …`
2. Firebase Console → Messaging → Send test message, paste the token
3. Add custom data `deep_link` = `/events/efc-137`

Test **backgrounded** and again **fully closed**. Different code paths, and
cold start is where deep links usually break.

---

## The demo sequence

1. Hand Calvin the phone
2. Let him find the EFC 137 countdown
3. Switch to the laptop, open the panel
4. Type a headline, hit Publish
5. **His phone buzzes and the story is already in the news list**

Rehearse it twice. That single beat argues the owned-audience case better than
any slide.

---

## Before this is production

- [ ] Rules deployed and tested with a non-staff account
- [ ] Service account key not in git — check `.gitignore`
- [ ] Push tested cold-start on real iOS and Android hardware
- [ ] Rate limiting on alerts — nothing currently stops a double-send
- [ ] Device token registration wired (`TODO(backend)` in the push services)
- [ ] Firestore backups enabled

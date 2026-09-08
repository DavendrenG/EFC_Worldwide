# EFC app — push, publishing and live content

Everything here is built. This document is the setup order and the demo script.

---

## 1. What's now real

| Piece | Status |
|---|---|
| Events, fight cards, dates | Live EFC data from efcworldwide.com |
| News headlines and images | Live — 9 real articles, real hero images, links to the official PDFs |
| Fighters | Real names from EFC's own announcements. **Measurements are placeholders** |
| Videos | Live YouTube feed from the official channel, no API key needed |
| Social, partner, broadcast links | All official, in `lib/data/efc_links.dart` |
| Admin panel | Built — `admin/index.html` |
| Push relay | Built — `functions/index.js` |

**Be straight about the fighter stats in the meeting.** Names and matchups are
real; heights, reaches and ages are invented placeholders. `MockData.dataProvenance`
carries that wording — say it out loud before anyone asks.

---

## 2. Live video, no API key

The fight library pulls the official EFC channel's Atom feed:

```
https://www.youtube.com/feeds/videos.xml?channel_id=UCu0pxhi-kgipKBtGeoR55hA
```

No key, no quota, no billing. `lib/services/youtube_feed.dart` parses it and
buckets each video into the existing category filters from its title.

Wire it into your repository's refresh:

```dart
final feed = await YoutubeFeed().fetchLatest();
final videos = [...feed, ...MockData.videos];
```

It returns an empty list on any failure, so the library always renders.

Add the dependency (already in `pubspec.yaml`):

```yaml
xml: ^6.5.0
```

then `flutter pub get`.

**Worth saying in the meeting:** this is a stopgap that makes the app useful on
day one. It also demonstrates the point — EFC's video currently lives on a
platform that owns the relationship, and the app is how that changes.

---

## 3. Admin panel

Open `admin/index.html` in any browser. It runs in **demo mode** out of the box:
publish a headline, watch the lock-screen preview update, nothing leaves the
page. That is enough to demo the whole workflow with no billing attached.

Three things it does:

- **Publish news** — headline, category, standfirst, body, hero image. Replaces the PDF workflow.
- **Post result** — winner, method, round. Built for use live between bouts.
- **Send alert** — standalone push. Ticket drops, schedule changes.

Every screen shows a live preview of the notification as the fan will see it.

To connect it for real, paste the Firebase web config into `firebaseConfig` at
the bottom of the file. Project settings → General → Your apps → Web app.

---

## 4. Push notifications

### Why a Cloud Function

Browsers cannot send FCM messages. The server key would be readable by anyone
who opens view-source, and whoever found it could push to every EFC fan.
`functions/index.js` watches Firestore and sends server-side.

```bash
cd functions && npm install
firebase deploy --only functions
```

Cloud Functions require the **Blaze plan**. Realistically a few rand a month at
EFC's volume, but it needs a card on file.

### Demoing without billing

Publish from the admin panel, then send the matching notification by hand from
Firebase Console → Messaging → Create campaign. Target topic `efc_news`. The app
handles both paths identically, so the demo looks the same.

### Topics

| Topic | Used for |
|---|---|
| `efc_all_events` | Everyone |
| `efc_card_announcements` | New bouts and cards |
| `efc_live_results` | Fight-night results |
| `efc_news` | News and features |
| `efc_fighter_{id}` | Per-athlete, set by following a fighter |

### Deep links

Every notification carries `deep_link`, and every route is a valid target:

```json
{ "deep_link": "/events/efc-137" }
```

`/`, `/events`, `/events/{id}`, `/athletes`, `/athletes/{id}`, `/watch`,
`/watch/{id}`, `/news`, `/news/{id}`

### Testing on a real device

1. `flutter run`, and copy the token from the log line `EFC push token: …`
2. Firebase Console → Messaging → Send test message
3. Paste the token
4. Under Custom data add `deep_link` = `/events/efc-137`

Test with the app **backgrounded** and again **fully closed**. Those are
different code paths and the cold-start one is where deep links usually break.

---

## 5. Before you demo — do this in order

1. `flutter pub get` (picks up `xml`)
2. `flutter run --release` on a real phone, not the emulator
3. Confirm the YouTube feed loads on the Watch tab
4. Send yourself one test push and tap it — confirm it opens the right screen
5. Open `admin/index.html` in a browser tab, ready to share
6. Charge the phone

Run it in `--release`. Debug builds have a visible performance penalty, and
overflow stripes only appear in debug — you don't want either on a shared screen.

---

## 6. The demo, in order

Ten minutes, and the order matters.

1. **Open the app on the phone.** Hand it to them. Say nothing for a moment.
2. **Let them find the countdown to EFC 137.** It's their event, their date, their venue.
3. **Watch tab** — real videos from their own YouTube channel, live.
4. **News tab** — their real headlines, in an app instead of a PDF.
5. **Follow a fighter.** Explain that this subscribes the fan to that athlete's announcements, and that EFC now knows which fighters carry an audience.
6. **Switch to the laptop.** Open the admin panel.
7. **Type a headline and publish it** while they're holding the phone.
8. **Their phone buzzes.**

That last beat is the entire pitch. Nothing you say about owned audiences lands
as hard as a notification arriving in their hand from a headline you typed ten
seconds earlier.

Rehearse it twice. If push isn't wired up on the day, do the same sequence with
a Firebase Console send — same effect.

---

## 7. Still outstanding

- Fighter portraits — every `portraitUrl` is null, so cards show the gradient placeholder
- Verified fighter records and measurements
- Real billing behind the premium flag — `setPremium(true)` is a local boolean
- Device token registration — tokens are logged, not stored. See `TODO(backend)`
- Admin panel auth — currently open. Firebase Auth plus the Firestore rules in the Setup tab before it goes anywhere near production

# EFC app — Flutter

> **Package identity:** this repo is currently set to the temporary demo
> identifier `com.geoservetechnologies.efcworldwide` for sideloaded builds.
> It must be switched to `com.efcworldwide.app` before any store submission —
> see `PACKAGE_IDENTITY.md` for the full checklist.


Phase-one EFC Worldwide mobile app: events, athletes, fight archive, news and
push notifications. Android, iOS and Huawei/AppGallery from one codebase.

The UI is a direct implementation of the approved prototype — same palette,
same type roles, same five-tab structure.

---

## Quick start

This repo contains `lib/`, `test/`, `pubspec.yaml` and `platform_config/`.
It does **not** contain generated `android/` and `ios/` folders, because those
are machine- and version-specific. Generate them once, then copy this source in:

```bash
# 1. Generate platform scaffolding
flutter create --org com.geoservetechnologies --project-name efc_app efc_app_build

# 2. Copy this source over it
cp -r efc_app/lib efc_app/test efc_app/assets efc_app/pubspec.yaml \
      efc_app/analysis_options.yaml efc_app_build/

# 3. Run
cd efc_app_build
flutter pub get
flutter run
```

It runs immediately on bundled mock content — no backend, no Firebase project
needed to see the app working.

---

## Running against the real API

```bash
flutter run --dart-define=EFC_API_BASE=https://api.efcworldwide.com/v1
```

With `EFC_API_BASE` empty the app uses `MockEfcRepository`. With it set, it
uses `HttpEfcRepository`. No UI code changes either way — every screen depends
on the `EfcRepository` interface, not on HTTP.

Expected endpoints: `/events`, `/events/{id}`, `/fighters`, `/fighters/{id}`,
`/videos`, `/articles`, `/articles/{id}`. Responses may be a bare JSON array or
`{"data": [...]}`. Field names are in `lib/models/models.dart`.

---

## Architecture

```
lib/
  main.dart                  entry point, dart-define config
  app.dart                   MaterialApp, deep-link routing
  theme/
    tokens.dart              colours, spacing — single source of truth
    app_theme.dart           type roles (display/body/utility) + ThemeData
  models/models.dart         domain models + fromJson
  data/
    efc_repository.dart      interface + Mock and Http implementations
    mock_data.dart           seed content mirroring the prototype
  state/app_state.dart       ChangeNotifier: loading, filtering, follows
  services/
    local_notifications.dart foreground alerts + Android channel
    favorites_store.dart     followed fighters (shared_preferences)
    push/
      push_service.dart      vendor-agnostic interface + topics + Noop
      fcm_push_service.dart  Google (Android + iOS/APNs)
      hms_push_service.dart  Huawei Push Kit
      push_bootstrap.dart    runtime vendor detection
  screens/                   five tabs + detail pages
  widgets/                   prototype components (poster, countdown, pills…)
```

The rule: screens never call HTTP or a push SDK directly. They read `AppState`
and `EfcRepository`. That is what makes the mock/live swap a one-line change.

---

## Push notifications

Three ecosystems, one interface.

| Device | Vendor | Chosen by |
|---|---|---|
| iOS | FCM over APNs | platform check |
| Android with Play Services | FCM | FCM token succeeds |
| Huawei without Play Services | HMS Push Kit | FCM token fails → fallback |
| Anything else | `NoopPushService` | last resort, never crashes |

Detection lives in `push_bootstrap.dart`. Override it for testing:

```bash
flutter run --dart-define=EFC_PUSH_VENDOR=hms    # or fcm, or none
```

### Topics

Defined in `PushTopics`. Everyone is subscribed to `efc_all`, `efc_events`,
`efc_fight_week` and `efc_live_results` on first launch. Following an athlete
subscribes to `efc_fighter_{id}`, which is what makes "your fighter just got
booked" alerts possible.

### Deep links

Payloads carry `data.deep_link`, e.g. `efc://event/efc-137`. Tapping a push
opens the app on the right tab. Sections: `event`, `fighter`, `video`,
`article`.

### Setup per store

- **Google Play / iOS** — `platform_config/android/` and `platform_config/ios/`
- **Huawei AppGallery** — `platform_config/huawei/SETUP.md`

Each file names its destination path at the top.

---

## Fonts

`google_fonts` fetches Anton, Barlow Semi Condensed and IBM Plex Mono at
runtime and caches them. That means the first launch needs a network
connection. **Before release, bundle them instead**: download the three
families, drop the `.ttf` files into `assets/fonts/`, declare them in
`pubspec.yaml`, and replace the `GoogleFonts.*` calls in `theme/app_theme.dart`
with `fontFamily:`. It removes a network dependency and a visible font swap on
first paint.

---

## Tests

```bash
flutter test
```

Covers repository seeding, `AppState` loading and filtering, model parsing and
push topic sanitisation.

---

## Before this ships

Not defects — deliberate phase-one boundaries:

1. **Artwork is placeholder.** `ArtworkBox` draws a gradient. Swap it for
   `CachedNetworkImage` once the CMS returns image URLs.
2. **Fighter records are zeroed** in mock data, pending real stats from EFC.
3. **Premium is a gate, not a paywall.** `VideoPlayerScreen` locks premium
   items but there is no billing. Subscriptions and entitlements are phase two,
   alongside live streaming.
4. **Token registration is stubbed.** Both push services have a `TODO` where
   the device token should be POSTed to the backend for single-device targeting.
   Topic messaging works without it.
5. **No analytics SDK yet.** Decide between Firebase Analytics and a
   self-hosted option before wiring, since Huawei builds cannot use Firebase
   Analytics.

---

## Store checklist

- [ ] Real app icons and splash (`flutter_launcher_icons`)
- [ ] Release keystore + `android/key.properties`
- [ ] `google-services.json` → `android/app/`
- [ ] `GoogleService-Info.plist` → `ios/Runner/` via Xcode
- [ ] `agconnect-services.json` → `android/app/`
- [ ] APNs auth key uploaded to Firebase
- [ ] Privacy policy URL (all three stores require it)
- [ ] Data safety / privacy nutrition labels declared
- [ ] Push permission copy reviewed — iOS rejects vague prompts

# Huawei (AppGallery) setup

Huawei phones released after May 2019 ship without Google Mobile Services, so
FCM silently fails on them. The app detects this at runtime in
`lib/services/push/push_bootstrap.dart` and falls back to HMS Push Kit.

Devices before that cutoff (P30, Mate 20 and earlier) do have GMS and will
keep using FCM. Both paths are handled; nothing to configure per-device.

## 1. AppGallery Connect

1. Create a developer account at `developer.huawei.com` and complete identity
   verification. Budget for a few days — it needs company documents.
2. AppGallery Connect → **My projects** → create a project → add an Android app.
3. Package name must match `applicationId` exactly: `com.efcworldwide.app`.
4. Enable **Push Kit** under Project settings → Manage APIs.
5. Add the SHA-256 signing certificate fingerprint of your release keystore:

   ```bash
   keytool -list -v -keystore efc-release.jks -alias efc | grep SHA256
   ```

6. Download `agconnect-services.json` → place it in `android/app/`.

## 2. Gradle

Apply the repository and plugin entries from
`platform_config/android/build.gradle-snippet.md`. The Huawei Maven repo
(`https://developer.huawei.com/repo/`) is mandatory — HMS artefacts are not
on Maven Central.

## 3. Sending a push

The CMS needs to target two vendors. Same payload, two endpoints:

| Vendor | Endpoint |
|---|---|
| FCM | `https://fcm.googleapis.com/v1/projects/{project}/messages:send` |
| HMS | `https://push-api.cloud.huawei.com/v1/{appId}/messages:send` |

Keep the data payload identical so `PushMessage.fromData` parses both:

```json
{
  "title": "EFC 138 card confirmed",
  "body": "Goncalves vs Bembe headlines 8 October.",
  "data": { "deep_link": "efc://event/efc-138" }
}
```

HMS topic names must match FCM's — the app subscribes to the same
`PushTopics` constants on both.

## 4. Testing without a Huawei device

Force the HMS path on any Android device or emulator:

```bash
flutter run --dart-define=EFC_PUSH_VENDOR=hms
```

It will fail to get a token without HMS Core installed, which is the correct
behaviour — it proves the fallback chain runs and lands on `NoopPushService`
rather than crashing.

## 5. Build for AppGallery

```bash
flutter build appbundle --flavor hms --release
```

AppGallery accepts both APK and AAB. Review usually takes 1-3 days and is
stricter than Google Play about permission justifications: expect to explain
`POST_NOTIFICATIONS` in the review notes.

## Known constraint

`huawei_push` is Android-only. It is safe to keep in `pubspec.yaml` for iOS
builds — the Dart API compiles and the plugin is simply never registered.
If you would rather not ship it at all, remove the dependency, delete
`lib/services/push/hms_push_service.dart`, and drop the `_tryHms()` branch in
`push_bootstrap.dart`.

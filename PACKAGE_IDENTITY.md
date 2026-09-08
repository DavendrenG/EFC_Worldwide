# Package identity — read before publishing anything

## Current identifier (demo only)

```
com.geoservetechnologies.efcworldwide
```

This is a **temporary demo identifier**, used so the app can be built and
sideloaded onto a device for the client demo. It is safe precisely because
nothing is being published: no store review, no brand listing, no permanence.

Set in:

| Where | What |
|---|---|
| `platform_config/android/build.gradle-snippet.md` | `namespace` and `applicationId` |
| `platform_config/android/MainActivity.kt` | Kotlin package declaration |
| iOS | `PRODUCT_BUNDLE_IDENTIFIER`, set by `flutter create --org` |

### Building the demo

```bash
flutter create --org com.geoservetechnologies --project-name efc_app efc_app_build
# copy lib/, test/, pubspec.yaml, assets/ into efc_app_build/
# merge the platform_config snippets into the generated android/ and ios/
cd efc_app_build
flutter pub get
flutter run --release
```

Put `MainActivity.kt` at
`android/app/src/main/kotlin/com/geoservetechnologies/efcworldwide/MainActivity.kt`
and delete the generated one — the directory path must match the package
declaration or the build fails.

---

## ⚠ Do not publish under this identifier

Once an app is live, the Play `applicationId` and the App Store bundle ID are
**permanent**. They cannot be changed without creating a new store listing and
orphaning every existing install.

Publishing a branded EFC app under a Geoserve identifier also fails store
review — both Apple and Google require the developer account and identifier to
belong to the brand owner, or documented authorization to act on their behalf.

Sideloaded demo builds are unaffected by all of the above.

---

## Switch checklist — after signature, before first store submission

Work through in order. Budget about half a day including Firebase.

**1. Identifier**
- [ ] `namespace` and `applicationId` → `com.efcworldwide.app`
- [ ] Move `MainActivity.kt` to `.../kotlin/com/efcworldwide/app/` and update its
      `package` line
- [ ] iOS `PRODUCT_BUNDLE_IDENTIFIER` → `com.efcworldwide.app` in Xcode, on
      every build configuration (Debug, Release, Profile)

**2. Firebase — new project, not a rename**
- [ ] Create the Firebase project under an EFC-owned Google account
- [ ] Register Android app with the new identifier → fresh
      `google-services.json` into `android/app/`
- [ ] Register iOS app → fresh `GoogleService-Info.plist` into `ios/Runner/`
- [ ] Re-upload the APNs auth key (`.p8`) — it does not carry across projects
- [ ] Add Geoserve as a project member with the access level the contract states
- [ ] Delete or archive the demo Firebase project

An identifier cannot be changed on an existing Firebase app registration. This
step is always a new registration, and old config files will silently fail to
deliver push if left in place.

**3. Huawei**
- [ ] New AppGallery Connect project under the new identifier
- [ ] Fresh `agconnect-services.json`
- [ ] Re-register the signing certificate SHA-256 fingerprint

**4. Store accounts**
- [ ] Apple Developer account under EFC ($99/year), Geoserve added with
      publishing rights
- [ ] Google Play Console under EFC ($25 once), Geoserve added as developer
- [ ] AppGallery Connect account under EFC

**5. Signing**
- [ ] Generate the production keystore and store it somewhere recoverable —
      losing it means never being able to update the Play listing again
- [ ] `android/key.properties` populated, untracked in git
- [ ] Point the release `signingConfig` at it (currently on debug)

**6. Backend**
- [ ] `api.efcworldwide.com` registered to EFC, pointed at the hosting
- [ ] `ApiClient.useSeedData` → `false`, `baseUrl` → production

**7. Verify before submitting**
- [ ] Push arrives on a physical Android device
- [ ] Push arrives on a physical iOS device
- [ ] Deep link opens the right screen from a cold start
- [ ] Release build installs and runs from a signed artifact

---

## What the contract needs to say about this

Agree in writing before the switch, not after:

- EFC owns the store accounts, the app listings, the fan data and the content
- Source code ownership — either assigned to EFC, or retained by Geoserve with
  a perpetual licence to EFC. Decided explicitly, not assumed
- Hosting arrangement and what the monthly retainer covers
- Exit terms: full data export in a usable format, and migration assistance for
  a defined number of days on termination
- Continuity if Geoserve becomes unavailable — credential escrow or documented
  handover

Raising the exit clause yourself is worth more than anything else in this list.
It removes the single biggest unspoken objection to a small vendor holding the
infrastructure.

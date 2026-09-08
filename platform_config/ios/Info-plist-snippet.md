# DESTINATION: ios/Runner/Info.plist

Add inside the top-level `<dict>`:

```xml
<key>CFBundleDisplayName</key>
<string>EFC</string>

<!-- Silent/background push and background fetch -->
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>

<!-- Deep links: efc://event/efc-137 -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.efcworldwide.app</string>
        <key>CFBundleURLSchemes</key>
        <array><string>efc</string></array>
    </dict>
</array>

<!-- Portrait only, matching the design -->
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
</array>

<!-- Required by video_player for HTTPS streams only; leave NSAllowsArbitraryLoads false -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

## Xcode setup

1. Signing & Capabilities → add **Push Notifications**.
2. Signing & Capabilities → add **Background Modes** → tick *Remote notifications*.
3. Drop `GoogleService-Info.plist` into `Runner/` via Xcode (not Finder) so it
   joins the target.
4. Upload the APNs auth key (.p8) to Firebase Console → Cloud Messaging.
5. Podfile platform line: `platform :ios, '13.0'`.

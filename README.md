# Meetup app frontend

Flutter client for the meetup coordination app. This is a separate Git repository from the Node.js API.

For a new chat or contributor, start with [HANDOFF.md](HANDOFF.md), [ARCHITECTURE.md](ARCHITECTURE.md), [TASKS.md](TASKS.md), and the copied [MVP scope](docs/meetup-app-mvp-scope.md).

## Run locally

Requires Flutter 3.41 or newer and an Android or iOS development setup.

```powershell
flutter pub get
Copy-Item config/app.example.json config/app.local.json
flutter run --dart-define-from-file=config/app.local.json
```

The app shows phone sign-in when configured. After verification, it creates a backend account and asks for a display name before opening the circle dashboard. Circle creation, destination picking, invitation links, installed-app join previews, and contact invitations are present; routing and live location are later slices. The API is maintained in the separate [meetup-app-backend](https://github.com/aman-netizen-ux/meetup-app-backend) repository.

## App structure and API configuration

`lib/app/` composes the app and navigation. Circle and place domain objects and repository contracts live in their `domain/` directories; HTTP adapters live in `data/`; widgets and presentation state live in `presentation/`. Generic HTTP transport lives in `lib/core/network/`. See [ARCHITECTURE.md](ARCHITECTURE.md). The dashboard loads circles from the authenticated backend.

Copy `config/app.example.json` to an ignored environment file such as `config/app.local.json`, then provide the backend URL and Firebase client values for that environment. Run Flutter with:

```powershell
flutter run --dart-define-from-file=config/app.local.json
```

`AppConfig.apiBaseUri` reads that value. The API client obtains the current Firebase ID token for signed-in calls and returns typed `ApiError`s for server, authentication, and network failures. The dashboard, create screen, and detail screen use the implemented circle endpoints. The destination picker calls the backend's provider-neutral `POST /v1/places/search`; the API key stays on the backend. Device access to a local HTTP API needs platform-specific debug networking configuration; production should use HTTPS.

## Configure phone sign-in

The Android package ID is `com.example.meetup`; register that exact ID in Firebase. Create a Firebase project, enable Phone sign-in, register the Android app, and add its SHA-1 fingerprint. Use the Firebase console's test phone numbers while developing to avoid sending real SMS. For iOS, complete the platform setup on a Mac before testing there. The backend must use the same Firebase project ID and have PostgreSQL configured.

Firebase identifiers are intentionally excluded from Git. Copy the values from the Firebase Android app configuration into the ignored `config/app.local.json`; do not commit that file. Start the app with:

```powershell
flutter run --dart-define-from-file=config/app.local.json
```

For the current local backend, connect the Android phone by USB, enable USB debugging, and check `adb devices -l`. Forward the phone's loopback port to the laptop API, then run the app:

```powershell
adb reverse tcp:3000 tcp:3000
# Set API_BASE_URL to http://127.0.0.1:3000 in config/app.local.json first.
flutter run --dart-define-from-file=config/app.local.json
```

Keep USB connected during this development run. If the app shows a profile/API retry screen, check `adb reverse --list` in a second terminal; Flutter launch or device reconnection can clear the forward. Run `adb reverse tcp:3000 tcp:3000` again, then tap Retry. This was observed during the first Android sign-in test. After disconnecting USB, run against the laptop's current Wi-Fi IP instead and keep both devices on the same network. Enter the test number in international format with `+91`. The Firebase test code belongs only in the Firebase console and manual test, never in the repository.

The app shows a setup message when the API URL is absent. Do not put service-account credentials in Flutter. Firebase Auth persists the signed-in native session across app restarts. For local Android testing, use your computer's LAN IP in `API_BASE_URL` and bind the Node server to a reachable interface; the debug build permits local HTTP, while release builds should use HTTPS. iOS still needs its own Firebase app configuration and a Mac. Firebase phone sign-in and the backend account handshake have been verified on Android with the configured test number.

Run `dart run tool/api_client_smoke.dart` to check bearer-token handling, invitation preview, independent date/time parsing, and API error mapping against a local mock server.

## Invitation links

Development builds register `meetup://join/<token>` on Android and iOS. Opening a valid link keeps the invitation pending through authentication, then shows a privacy-limited preview and role choice. The app also parses HTTPS `/join/<token>` links. Production store-install continuation needs the final HTTPS domain plus Android App Links and iOS Universal Links association files; track that remaining release work in F-06.

## Contact invitations

The organizer can open **Invite from contacts** on an active or scheduled circle. Android requests `READ_CONTACTS`; iOS uses `NSContactsUsageDescription`. Names remain on the device. The client sends at most 200 normalized phone numbers with ephemeral local IDs to the backend, then removes phone numbers before creating presentation state. Existing users are shown as available to add, with a confirmation that membership remains pending until they choose a role and grant location permission. Nonusers use the operating system share sheet; the app never selects a recipient or sends a message automatically.

The visible app name is **Meetup** on Android and iOS. `com.example.meetup` remains the Android application/package ID used by Firebase.

## Roles and live updates

Circle details show every member and an inline role card for the signed-in user. Directly added contacts remain pending until they confirm mover or anchor themselves. An active user switching to mover sees an education dialog before Android/iOS foreground location permission; scheduled circles defer that prompt. Choosing anchor stops future location updates, while the backend can retain an already shared point as frozen.

While circle details are open, the client long-polls `GET /v1/circles/:id/events` with its last revision. Every update is a complete authorized snapshot, so reconnect does not replay or merge partial events. Header, people/role, organizer actions, and connection status use separate `ValueListenableBuilder` boundaries.

## Route selection

After an Active ready mover starts public location sharing, circle details load short-lived server-owned walking, road, and estimated public-transport options. Nothing is inferred from device motion: the mover must tap a route. The chosen route persists on the backend, its geometry appears on the live map, and its leg summary remains visible while another option can be selected. Provider failures and empty results show an inline retry without stopping location sharing.

Accepted points advance the selected route and refresh a personal ETA range. The signed-in mover reads private leave-by data from `/v1/circles/:id/me`; shared snapshots never contain it. Timed circles show a conservative leave countdown, while untimed circles show the ETA without early or late wording. Uploads adapt to observed movement and destination proximity, and GPS failure changes the location card to a paused state instead of presenting an old point as live.

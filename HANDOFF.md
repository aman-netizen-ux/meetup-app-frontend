# Frontend handoff

Read this file, [ARCHITECTURE.md](ARCHITECTURE.md), [TASKS.md](TASKS.md), and [docs/meetup-app-mvp-scope.md](docs/meetup-app-mvp-scope.md) at the start of a new chat. The scope is the product reference; TASKS tracks implementation. Also inspect `git status` before editing. The Node.js API is maintained in the separate [meetup-app-backend](https://github.com/aman-netizen-ux/meetup-app-backend) repository.

## Current state

- Public GitHub repository on `main`: [meetup-app-frontend](https://github.com/aman-netizen-ux/meetup-app-frontend).
- Flutter 3.41.6 project contains Android and iOS targets. `lib/main.dart` initializes Firebase from ignored compile-time configuration and uses a compile-time API URL, then launches `lib/app/meetup_app.dart`. `AuthGate` routes between phone/SMS sign-in, display-name onboarding, and the server-backed circles dashboard. Auth, circles, and places keep data outside widgets. The picker has an OSM map; journey tracking remains planned.
- `flutter pub get`, `flutter analyze`, `dart analyze`, `flutter test`, and `dart run tool/api_client_smoke.dart` passed on Windows. The smoke check exercised bearer-token handling, invitation preview, date/time parsing, and API error mapping. The app was installed and tested on the user's Android phone on 2026-09-27; iOS builds need a macOS host.
- The product scope snapshot is stored at `docs/meetup-app-mvp-scope.md`.
- **F-01 is DONE.** [docs/screen-state-map.md](docs/screen-state-map.md) covers navigation, Scheduled/Active/Ended, roles, and recovery states. Typed circle domain objects and data mappers match backend B-01.
- **F-03 is DONE.** App/navigation structure, compile-time API URL configuration, typed HTTP boundary, and error handling are in place. The home controller now loads circles through its repository. The architecture keeps one class per file and separate domain, data, and presentation state layers.
- **F-04 is DONE on Android.** Phone/SMS sign-in, code verification, persisted Firebase session restoration, backend profile handshake, display-name onboarding, revoked-session sign-out, and sign-out UI are implemented. The project uses Firebase Phone Authentication and Android package ID `com.example.meetup`. Firebase client identifiers are supplied through an ignored `--dart-define-from-file` configuration; no environment-specific Firebase configuration belongs in Git. Kotlin incremental compilation is disabled in `android/gradle.properties` because the first build hit a cross-volume Gradle cache issue. On 2026-09-27 the app ran on an Android test device: the configured test phone/code signed in, `GET /v1/me` created one account, name onboarding reached “No circles yet”, app relaunch restored the session, revoking the Firebase session caused sign-out, and signing in again recovered the account. The first profile retry screen occurred because `adb reverse tcp:3000 tcp:3000` had disappeared; restoring the forward and tapping Retry returned 200 and the circles screen. `AuthController` now shares one in-flight profile request between Firebase's auth-state event and the explicit code-verification path to prevent concurrent loads. `dart analyze` and `flutter test` passed; a new debug APK was installed. See README.
- **F-05 is IN PROGRESS.** Server-backed dashboard, create/detail screens, required destination, separate optional date/time, private-place toggle, and Scheduled/Active/Ended labels are implemented. `PlacePickerScreen` searches through an abstract repository and lets the user adjust a pin on an OSM map with linked copyright attribution. `CircleEditorController` owns creation state, and `CircleDetailController` owns refresh/end actions. The backend's current place endpoint is `POST /v1/places/search` with `{ "query": "..." }`, returning provider-neutral `label`, `secondaryLabel`, `latitude`, `longitude`, and `placeId`. On 2026-10-07 the current build was installed on a real Android phone. It restored the Firebase session, loaded the server-backed dashboard, returned live Geoapify suggestions for `Ramagondanahalli Bengaluru`, created an Active circle, ended it, and reloaded the Ended circle card from the backend. The API returned 200 for profile, search, list, detail, and end requests, plus 201 for creation. `flutter analyze` and `flutter test` pass. Functional invitation entry points remain before F-05 is DONE and are owned by F-06/F-07 with B-06/B-07.
- **F-02 remains BLOCKED on the location spike and iOS access.** An Android phone is available for the future real walking and background-location measurements around **Ramagondanahalli, Bengaluru, Karnataka**. Full F-02 acceptance remains open until an iPhone and Mac are available for iOS checks.

## Locked product rules from scope

- Destination is required. Date and time are separate optional fields. No date means Active immediately; a future date stays Scheduled until that date; time alone means today. Time never decides arming, only leave-by math.
- Mover/anchor is self-declared per circle. Anchor is offered only at a private-place destination. A mover selects a suggested route; the app does not infer transport mode.
- Scheduled circles do not prompt for location or track. Active movers begin sharing after departure (~150 m), or by manual Share now, and stop individually on arrival. Leave-by is private and appears only if the organizer supplied a meetup time.
- Show stale GPS as in transit, Here on arrival, and an Ended summary after the circle closes. Midpoint suggestions and chat are deferred to v2+.

## Decisions to record with the backend before related implementation

1. Representative real routes around Ramagondanahalli, Bengaluru. An Android phone is available; an iPhone and Mac will be needed for iOS background-location proof.
2. Verified identity provider and the contact matching/permission experience.
3. Circle time zone, start-of-date arming behavior, and time-only values already past today.
4. How direct addition of an existing contact coexists with join preview and self-selected role. Never start sharing before the mover permission and departure conditions are met.
5. Map/route provider, app IDs, deep-link domain, and test credentials. Keep secrets out of Git.
6. Real-device measurement for adaptive polling and checkpoints; do not promise exact 10–15 second background updates before this proof.

## Provider decision (2026-10-02)

- Use Geoapify autocomplete through the Node backend and OpenStreetMap tiles in Flutter for the current MVP development build. The browser/app never receives the Geoapify key.
- Google Maps Platform was deferred because the new India Cloud Billing account requires a refundable ₹3,000 activation prepayment. Keep the provider-neutral repository/API boundary so a later Google migration replaces infrastructure and the map widget without changing circle domain rules.
- Routing remains a separate B-02 provider spike. The configured Geoapify key proves destination search only; do not claim live traffic or transit-route coverage from it without completing that spike.

## F-01 decisions and cross-repo contract

- The backend contract lives in [meetup-app-backend/docs/circle-api-contract.md](https://github.com/aman-netizen-ux/meetup-app-backend/blob/main/docs/circle-api-contract.md); account and circle lifecycle routes are implemented. Circle entities in `lib/features/circles/domain/entities/` and mapping functions in `lib/features/circles/data/mappers/` match its JSON shapes.
- The destination's IANA time zone controls Scheduled/Active. A time-only value resolves to today in that zone, even if that time is already past. Scheduled circles never ask for location or track.
- Shared snapshots/events exclude private leave-by; the user's own `/me` response carries it. Invitation previews exclude live pins. A mover's pin stays null until sharing begins.
- Direct contact addition, post-join destination edits, arrival threshold, and exact timeout remain open for their owning tasks; see the backend contract.

## How to continue

Take one task ID from TASKS.md, implement its acceptance checks, verify it, update its status, and update this handoff with what changed, evidence, remaining decisions, and the next task. Coordinate data models and API calls with the matching backend task. Keep the copied scope synchronized across both repositories.

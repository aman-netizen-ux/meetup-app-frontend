# Frontend task plan

This repository owns the Flutter Android/iOS client: screens, route choice, permissions, background location, checkpoints, and user-facing notifications. The product requirements are in [docs/meetup-app-mvp-scope.md](docs/meetup-app-mvp-scope.md). Follow [ARCHITECTURE.md](ARCHITECTURE.md) for every task. Task IDs are stable so future chats can take one task at a time. Update the status and [HANDOFF.md](HANDOFF.md) whenever a task is finished.

**Status key:** `NEXT` = ready to start, `IN PROGRESS` = implemented in part, `TODO` = planned, `BLOCKED` = needs a decision or dependency, `DONE` = acceptance checks met. Do not mark a task done for a stub or mock unless its acceptance check explicitly calls for one.

## Phase -1: UX and device feasibility

| ID | Status | Task and acceptance checks | Depends on / backend partner |
|---|---|---|---|
| F-01 | DONE | Define the screen/state map and typed client contracts for circle list, create, join preview, role edit, Scheduled, Active, and Ended. Show date and time as independent optional inputs. Document loading, empty, denied-permission, stale-location, and no-route states. Match the API examples in B-01. | Scope / B-01 |
| F-02 | BLOCKED | Build a throwaway device spike on real Android and iOS hardware. Measure departure detection around 150 m, checkpoint callbacks, background behavior, permission changes, battery impact, and arrival timing; record results and limits. Do not treat simulator results as proof. The Android phone is now connected and available for the spike; the iOS acceptance check remains open until an iPhone and Mac are available. | Ramagondanahalli, Bengaluru / B-02 |
| F-03 | DONE | Set up app structure, navigation, environment-specific API base URL, typed API client, and error handling. Keep the initial circles home screen, replacing its static empty state with server data only when identity and listing are available. | F-01 / B-01 |

## Milestone 1: accounts and circles

| ID | Status | Task and acceptance checks | Depends on / backend partner |
|---|---|---|---|
| F-04 | DONE | Phone/SMS sign-in, display-name onboarding, session restore, API handshake, and sign-out work on the connected Android phone with Firebase's configured test number. The real backend created one phone-bound account and saved the chosen name; app relaunch restored it. Revoking the Firebase test session caused sign-out, and signing in again recovered the account. `dart analyze`, `flutter test`, and a debug Android build passed. One account can later have multiple circle memberships. | B-04 |
| F-05 | DONE | Server-backed circle list, polished create/detail screens, required destination, independent optional date/time, private-place choice, state badges, search-first/map-pin picker, end action, invitation link entry, and contact entry are implemented. Real Android tests created, opened, ended, and reloaded circles through the backend. | F-03, F-04 / B-05 |
| F-06 | IN PROGRESS | Deep-link join flow, member preview, mover default, private-place-only anchor choice, invalid/expired handling, and pending-link restoration are implemented. Warm and force-stopped cold launches passed on Android with the development `meetup://join/...` scheme. Configure the final HTTPS domain, Android App Links, iOS Universal Links, and store-install continuation before marking DONE. | F-04, F-05 / B-06 |
| F-07 | DONE | Contacts permission, privacy messaging, search, mapped/unmapped display, existing-user pending-membership confirmation, and the platform share sheet are implemented. Names stay on-device; normalized phone numbers are sent only for matching and removed from presentation state afterward. Android displayed the permission prompt, returned unmapped rows, and opened the system chooser without selecting a recipient. | F-04, F-06 / B-07 |
| F-08 | DONE | Circle details show membership and a dedicated self-role card. Pending direct additions confirm mover/anchor and become ready only through the self-owned role endpoint. Active anchor-to-mover shows permission education and requests foreground location before saving; scheduled circles do not prompt early. Mover-to-anchor stops future updates and preserves an existing last pin as frozen. Role state and the live connection badge rebuild independently. Controller tests and a real Android mover/anchor/permission test pass. | F-05, F-06 / B-06, B-08 |

## Milestone 2: live journey

| ID | Status | Task and acceptance checks | Depends on / backend partner |
|---|---|---|---|
| F-09 | DONE | Built the shared Circle screen with an OSM map, destination and privacy-gated member markers, current leg/mode, ETA ranges, stale/in-transit indicator, and Here state. Revision long polling reconnects with complete snapshots. Shared entities and UI contain no member leave-by field. | F-03, F-05 / B-08 |
| F-10 | TODO | Implement permission education and platform location permissions. For an active mover, establish a starting point, begin sharing only after departure (~150 m), offer Share now, and stop per-person on arrival or switch to anchor. A scheduled circle must not prompt or track early. | F-02, F-08 / B-09 |
| F-11 | TODO | Add suggested route display and explicit mover selection, including walking/road/transit legs, no-route recovery, and selected-route changes. Never infer a journey mode silently. | F-09 / B-10 |
| F-12 | TODO | Implement checkpoint monitoring and adaptive location frequency from device motion, stationary state, and destination proximity. Test background behavior on both platforms and show GPS-loss state without presenting an old point as live. | F-02, F-10, F-11 / B-09, B-11 |
| F-13 | TODO | Show private leave-by nudges only when a meetup time exists. Show personal ETA without early/late framing otherwise. Present ETA as a range and update it on meaningful route/leg changes. | F-09, F-11 / B-11 |

## Milestone 3: completion and delivery

| ID | Status | Task and acceptance checks | Depends on / backend partner |
|---|---|---|---|
| F-14 | TODO | Register push tokens; handle arrival and meaningful ETA/leg notifications when the app is foregrounded or backgrounded. Arrival shows Here; personal early/late text appears only when time is set. Provide organizer end/cancel action and an Ended summary. | F-09, F-13 / B-12, B-13 |
| F-15 | TODO | Run end-to-end tests on two or more real devices across Android and iOS: create/join, route choice, departure, stale GPS, role switch, arrival, cancellation, timeout, and location deletion. Complete accessibility, battery, permission, and release configuration checks. Replace the local LAN `API_BASE_URL` with the deployed HTTPS backend URL for release; keep backend credentials out of Flutter. | F-04 through F-14 / B-14 |

## Cross-repo sequence

1. Agree on F-01 with B-01 before implementing screens or API calls.
2. Prove F-02 and B-02 before promising background checkpoint timing or transit ETA precision.
3. Deliver F-04 through F-08 alongside B-04 through B-07 as the first usable create/join slice.
4. Deliver live location and route selection before ETA, push, and completion behavior.

See [HANDOFF.md](HANDOFF.md) for current state and unresolved decisions. The source scope is a requirements reference, not an instruction to execute every v1 feature in one chat.

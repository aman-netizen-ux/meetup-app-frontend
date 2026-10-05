# Flutter screen and state map (F-01)

Source: [MVP scope](meetup-app-mvp-scope.md). Wire contract: [circle-api-contract.md](https://github.com/aman-netizen-ux/meetup-app-backend/blob/main/docs/circle-api-contract.md) in the separate backend repository. This document describes intended behavior; the current app shows an empty circles home presentation state. Typed circle entities live in `lib/features/circles/domain/entities/`, with wire conversion in `lib/features/circles/data/mappers/`.

## Navigation

```text
Incoming invitation link -> Join preview -> Sign in if needed -> Choose mover/anchor -> Circle
Launch -> Sign in if needed -> Your circles
Your circles -> Create circle -> Destination -> Optional date and time -> Private-place choice -> Circle
Your circles -> Scheduled card | Active circle | Ended summary
Active circle -> Suggested routes -> Select route -> Active circle
```

The invitation preview comes **before** sign-in and role choice. It shows existing member names but never live positions. Returning from app installation or sign-in must preserve the invitation token. There is no join-code screen.

## Screens and authoritative data

| Screen/state | What it shows | Data/action |
|---|---|---|
| Your circles: loading | Progress indicator, no fabricated cards | `GET /v1/circles` |
| Your circles: empty | Existing “No circles yet” state and create/join entry points | Empty `items` |
| Your circles: content | Active, Scheduled, and Ended cards; destination, date/time if set, own role | `CircleSummary[]` |
| Your circles: failure | Retry, with cached data marked as old if available | Error envelope / connectivity |
| Create circle | Required destination; optional date and optional time as **separate controls**; private-place flag | `POST /v1/circles` |
| Create nudge | If both date and time are blank: “When are you meeting? We'll tell each person exactly when to leave.” One-tap skip, no blocking modal | Local form state |
| Join preview | Destination, circle state, who is already in it; then role choice | `GET /v1/invitations/{token}/preview` |
| Join role choice | Mover preselected; Anchor shown only when `isPrivatePlace` is true | `POST /v1/invitations/{token}/accept` |
| Scheduled circle | Static event card and members; destination/date/time | Circle snapshot; **no** location prompt, location listener, route polling, or leave-by calculation |
| Active circle | Shared map, destination, member rows, leg/mode, ETA ranges, Here/in-transit/frozen states | `GET /v1/circles/{id}` plus real-time events |
| My active journey | Own route choice, sharing state, ETA, private leave-by if time exists | `GET /v1/circles/{id}/me`; never render another member's leave-by |
| Ended circle | Static summary with attendees and arrival times; end/cancel reason | Ended circle snapshot; no live subscriptions or GPS trail |

The own-role control is an **inline popup on the user's member row** on the Circle screen and home card, never a separate screen. Anchor -> Mover starts the explanation and OS permission flow if needed. Mover -> Anchor stops future sharing and retains the last public pin as frozen; the client must not keep uploading. Multiple anchors are allowed for private places.

## Circle state transitions

| Server state/event | UI transition |
|---|---|
| No date at creation | Open Active immediately; time alone is today's target in the destination zone. |
| Future date at creation | Show Scheduled card until the event date starts in the destination zone. |
| `circle.state_changed` to Active | Replace static card with live Circle screen. Only then may mover permission/tracking begin. |
| A mover departs ~150 m or chooses Share now | Start public sharing for that mover. Before this, their starting position is private and their public `pin` is null. |
| GPS becomes stale | Hold last public pin and label it “In transit”; never imply that old coordinates are live. |
| Member arrives | Stop their sharing, mark Here, show personal early/late only if time exists, and deliver circle arrival push. |
| Mover -> Anchor | Stop sharing and display frozen last pin; Anchor -> Mover re-enters permission and route flow. |
| `circle.ended` | Close live subscriptions and location collection; show static Ended summary. |

The server owns lifecycle and permission checks. UI state can optimistically show progress while an action is pending, but it must roll back on `409`, `422`, or network failure. On real-time reconnection, fetch a fresh shared snapshot and private `/me` response before applying later revisions.

## Required recovery and privacy states

- **Denied/revoked location permission:** explain why a mover needs permission and offer OS settings. Do not upload coordinates or show a fabricated live status. Scheduled and anchor members should not receive location prompts.
- **No route or route-provider failure:** let the mover retry or choose a different suggestion; keep circle participation visible. Do not invent a mode, checkpoint, ETA, or leave-by.
- **No meetup time:** omit leave-by, early/late labels, and any synthetic target. Show the mover's own ETA when available.
- **No date:** circle is Active immediately. A time-only value is today in the destination time zone, even if that time has already passed.
- **Request failure:** show a retry state; do not treat a failed create, join, role change, or end action as successful.
- **Invite invalid/expired:** explain and return to home; do not leak member locations.
- **Pending directly added contact:** show the preview/role setup before location sharing. Exact wording and counting wait on backend B-07's consent decision.

## UI contract dependencies

| Flutter task | Backend data/behavior |
|---|---|
| F-03 app client | B-01 contract and stable errors |
| F-05 create/list | B-05 circle endpoints and state transitions |
| F-06 join preview | B-06 invite preview/accept |
| F-08 inline role | B-06 role endpoint and B-08 shared event |
| F-09 live screen | B-08 shared snapshot/events |
| F-10 to F-13 journey | B-09 to B-11 location, routes, ETA, private `/me` |
| F-14 notifications/end | B-12 and B-13 push and lifecycle |

## Pending decisions

Pilot city; identity provider; exact direct-contact consent flow; destination edits after joining; map/route provider; app IDs and link domain; exact arrival/timeout thresholds. F-02 must measure background tracking on real Android and iOS devices before setting frequency guarantees.

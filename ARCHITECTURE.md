# Flutter architecture

The app uses feature-first clean architecture. Keep **one class per Dart file**. Enums have their own files. Files with only mapping functions may group related conversions and contain no classes.

```text
lib/
  app/                         App composition and navigation
  core/config/                 Compile-time environment configuration
  core/network/                Generic JSON HTTP transport and API errors
  features/circles/
    domain/entities/           Immutable business objects; no Flutter or JSON
    domain/repositories/       Abstract repository contract
    data/datasources/          Endpoint paths and raw wire JSON
    data/mappers/              JSON <-> domain conversions
    data/repositories/         Repository implementation using data sources
    presentation/state/        Controller, state, status
    presentation/              Widgets render state and emit user actions
  features/auth/                Same domain/data/presentation split for sign-in
  features/contacts/            Contact matching, platform permission/share adapters, row state
```

Dependency direction: `presentation -> domain`; `data -> domain` and `data -> core/network`; `domain` depends on neither Flutter widgets nor HTTP. The app layer composes dependencies. A screen never imports PostgreSQL, raw SQL, `dart:io` HTTP, or a remote data source. The backend owns all database access.

`AuthGate` renders sign-in, display-name onboarding, or the circles home according to `AuthController`. `CirclesHomeScreen` renders `CirclesHomeState` from `CirclesHomeController`; its list state starts empty. The composition root injects authenticated circle and place repositories, and controllers trigger server work outside widgets. The generic HTTP client and repository can be checked with `dart run tool/api_client_smoke.dart`.

When adding a feature, create its own `domain`, `data`, and `presentation` layers. Keep API response parsing in data mappers; keep location permissions and platform plugins in data/platform adapters; keep the visible state transition in a controller; keep widgets focused on rendering and user actions.

## State and rebuild boundaries

The current state-management choice is Flutter's built-in `ValueNotifier` with immutable feature state objects. Controllers own asynchronous work and publish state; widgets send user actions and render it through `ValueListenableBuilder`. Keep each builder as close as possible to the changing subtree. A loading flag for an invitation button must not rebuild the map, app bar, or the rest of a detail screen. Use a small screen-local `ValueNotifier` for transient selections such as a role or selected map pin. Do not use page-level `setState` for isolated changes.

Authentication tokens remain inside the Firebase/authenticated HTTP boundary and are never placed in presentation state, routes, logs, or persisted feature models. Invitation previews may contain destination and display names, but never phone numbers, account IDs, live pins, raw location history, or private journey calculations.

Contact names are read only by the platform contact adapter and merged with match results inside the data repository. Phone numbers exist only in the short-lived data-layer request objects and are not copied into domain entities or presentation state. Each contact row owns a separate action controller so one add/share result does not rebuild the list or screen shell.

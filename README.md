# Hena Masr (هنا مصر)

> The complete tourist companion for Egypt — every famous place explained in full, with every way to get there, available offline and in 15 languages.

Hena Masr helps visitors see Egypt's top destinations with confidence: what to see inside each site, how much to pay, how to get there, and what to watch out for.

---

## Table of Contents

1. [Features](#features)
2. [What makes it different](#what-makes-it-different)
3. [Tech stack](#tech-stack)
4. [Architecture](#architecture)
5. [Project structure](#project-structure)
6. [Getting started](#getting-started)
7. [Localization](#localization)
8. [Theme and brand](#theme-and-brand)
9. [Data model](#data-model)
10. [Roadmap](#roadmap)
11. [Content guidelines](#content-guidelines)
12. [Contributing](#contributing)

---

## Features

### Core (MVP)
- Onboarding and language selection
- Explore by city and category (ancient sites, beaches, religious, nature, food)
- Search and filters
- Full place pages: overview, inside-the-site guide, tickets, opening hours, best time, dress code, photography rules, nearby places
- **Getting there** for every place: ride-hailing, metro, trains, buses, private transfers, with fair-price estimates
- Interactive map
- Favorites
- Offline mode for core content

### Next
- Trip planner: pick days and interests, get a day-by-day itinerary with travel times
- Offline packs per city (content + map)
- Audio guides
- AI guide (answers grounded in the app's own data)
- Emergency numbers and tourist police
- Egyptian phrasebook with pronunciation
- Reviews and traveler photos
- Push notifications

### Later
- Booking tours and transfers
- Licensed guide profiles
- Accessibility-friendly and family-friendly filters

## What makes it different

1. **Scam Shield + Fair Price** — fair prices for taxis, rides and camel/horse carts per place, common scams, and bargaining tips.
2. **Offline-first** — whole cities (content + maps) work without internet or roaming.
3. **Complete place guides** — not just facts: a practical plan for the visit, from arrival to exit.
4. **Multilingual from day one** — 15 languages, RTL-ready.
5. **AI guide** — grounded in curated data, not generic web answers.

## Tech stack

| Area | Choice |
|---|---|
| Framework | Flutter (3.27+) |
| State management | Riverpod |
| Navigation | go_router |
| Backend | Firebase (Auth, Firestore, Storage, Cloud Messaging) |
| Local database | Drift (SQLite) + shared_preferences |
| Maps | flutter_map (OpenStreetMap), geolocator |
| Localization | `flutter gen-l10n` (ARB) + `LocalizedText` for remote content |
| Connectivity | connectivity_plus |
| Images | cached_network_image |
| Fonts | Plus Jakarta Sans (Latin), Cairo (Arabic), bundled for offline use |

## Architecture

**Feature-first Clean Architecture.** Each feature owns three layers:

```
presentation  →  domain  ←  data
(screens,        (entities,   (models, datasources,
 providers)       repository   repository
                  contracts,   implementations)
                  use cases)
```

- **Domain** has no dependency on Flutter or Firebase.
- **Data** maps remote/local sources to domain entities and returns `Result<T>` (success or `Failure`).
- **Presentation** talks to use cases through Riverpod providers.
- Errors are typed (`NetworkFailure`, `ServerFailure`, `CacheFailure`, ...) and mapped to localized messages in the UI.

## Project structure

```
lib/
├── main.dart · bootstrap.dart · app.dart
├── l10n/                      # ARB files + generated localizations
├── core/
│   ├── config · constants · di · error · extensions
│   ├── localization/          # supported locales, locale controller, LocalizedText
│   ├── network · services · storage (Drift)
│   ├── router · theme · utils (Result, logger, ...)
│   └── widgets/               # shared UI components
└── features/
    ├── splash · onboarding · shell · home · settings
    ├── places · transport · map · trip_planner
    ├── offline_packs · scam_shield · ai_guide
    ├── favorites · emergency · phrasebook · auth
    └── <feature>/
        ├── data/          (datasources, models, repositories)
        ├── domain/        (entities, repositories, usecases)
        └── presentation/  (providers, screens, widgets)
```

## Getting started

### Prerequisites
- Flutter 3.27 or newer
- A Firebase project (`flutterfire configure`)

### Setup

```bash
flutter pub get
flutter gen-l10n
flutter run
```

Make sure `pubspec.yaml` contains:

```yaml
flutter:
  generate: true
```

### Firebase
1. Create a Firebase project and enable Firestore, Authentication (anonymous + Google) and Storage.
2. Run `flutterfire configure`.
3. Uncomment `Firebase.initializeApp(...)` in `lib/bootstrap.dart`.

### Offline fonts
1. Place the Plus Jakarta Sans and Cairo `.ttf` files in `assets/google_fonts/`.
2. Declare the folder under `flutter: assets:`.
3. Enable `GoogleFonts.config.allowRuntimeFetching = false;` in `bootstrap.dart`.

## Localization

Supported languages (Full 15 languages implemented in ARB files and `AppLocales`):

1. Arabic (`ar`) - العربية
2. English (`en`) - English
3. Russian (`ru`) - Русский
4. German (`de`) - Deutsch
5. Italian (`it`) - Italiano
6. French (`fr`) - Français
7. Polish (`pl`) - Polski
8. Spanish (`es`) - Español
9. Chinese (`zh`) - 中文
10. Dutch (`nl`) - Nederlands
11. Ukrainian (`uk`) - Українська
12. Czech (`cs`) - Čeština
13. Turkish (`tr`) - Türkçe
14. Serbian (`sr`) - Српски
15. Japanese (`ja`) - 日本語

All 15 language ARB files are fully configured in `lib/l10n/` and wired in `lib/core/localization/supported_locales.dart`. RTL is automatically handled for Arabic.

**UI strings** live in `lib/l10n/app_<code>.arb`. To add a language:
1. Copy `app_en.arb` to `app_<code>.arb` and translate it.
2. Add the locale to `lib/core/localization/supported_locales.dart`.
3. Run `flutter gen-l10n`.

**Place content** (names, descriptions, tips) is stored as a map per language and read with `LocalizedText`:

```json
{ "ar": "أهرامات الجيزة", "en": "Pyramids of Giza", "ru": "Пирамиды Гизы" }
```

Fallback order: requested language, English, any available. RTL is handled automatically for Arabic.

## Theme and brand

Palette: **Egyptian Heritage**

| Role | Name | HEX |
|---|---|---|
| Primary | Lapis | `#1F3A73` |
| Action | Gold | `#D4A24C` |
| Secondary | Faience Turquoise | `#2BA39B` |
| Warning | Carnelian | `#B8322E` |
| Background | Papyrus | `#F5EEDC` |
| Secondary surface | Sand | `#E6D3A8` |
| Text / dark background | Basalt | `#17202A` |

Rules:
- One gold primary button per screen.
- Use `context.hena.turquoiseText` (not raw turquoise) for text on light backgrounds.
- Dark mode uses Basalt as the background.
- Flat colors, no gradients.

## Data model

Firestore collections (draft):

| Collection | Purpose |
|---|---|
| `cities` | Cities and regions |
| `categories` | Place categories |
| `places` | Place guides (localized content, media, tickets, hours, coordinates) |
| `transport_options` | Ways to reach a place, with fair-price estimates |
| `scam_tips` | Scam warnings and bargaining tips per place |
| `offline_packs` | Downloadable city packs |
| `emergency_contacts` | Emergency and tourist-police numbers |
| `phrases` | Phrasebook entries |
| `users/{id}/favorites` | Saved places |
| `users/{id}/trips` | Planned trips |

## Roadmap

| Phase | Scope |
|---|---|
| **MVP** (~6-8 weeks) | Core features, 15-30 places, Arabic + English, offline content, Scam Shield |
| **V2** | Trip planner, offline city packs, audio guide, AI guide, more languages |
| **V3** | Bookings and commissions, guide profiles, accessibility filters |

Content is the main bottleneck: accurate prices, hours and transport details per place need verification before release.

## Content guidelines

- Prices, opening hours and routes change. Verify against official sources before publishing and record the verification date.
- Keep scam warnings factual and neutral; avoid naming individuals or businesses without evidence.
- Every place needs content in at least Arabic and English before it goes live.

## Contributing

1. Create a branch from `main`.
2. Follow the feature-first structure; keep `domain` free of Flutter/Firebase imports.
3. Run `flutter analyze` and `flutter test` before opening a PR.
4. Add or update ARB strings for any new UI text.

## License

To be decided.
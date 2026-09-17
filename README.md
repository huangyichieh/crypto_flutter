# Crypto Tracker

A responsive Flutter App tracking and analyzing crypto.

## Features

- Live top-100 USDT markets ranked by quote volume
- Price-history ranges from 30 minutes to one year, plus custom dates
- Selectable Binance kline intervals and market summary statistics
- Locally persisted favorite markets in the browser or on-device
- Normalized multi-market comparison for selected favorites
- Responsive dark UI for desktop browsers and mobile screens

The original Fixed Deposit Rates feature uses Binance's signed Simple Earn endpoint. API keys must never be embedded in a web or Android build, so the app leaves a clear integration point for a trusted backend that signs those requests.

## Project structure

```text
lib/
├── api/                 # Binance REST client
├── currency/
│   ├── controller/      # GetX reactive state and actions
│   └── view/            # Graph, market table, and comparison views
├── firebase/            # Legacy path; now contains local favorites storage
├── graph/               # CustomPaint chart widgets
├── home/                # App composition and GetX binding
├── model/               # Market and chart models
└── main.dart            # GetMaterialApp entry point
```

## Run

Use a current stable Flutter SDK, then:

```bash
flutter pub get
flutter run -d chrome
flutter run -d android
```

Production builds:

```bash
flutter build web
flutter build apk
```

The app needs internet access to call `https://api.binance.com`. Availability may vary by region or network policy.

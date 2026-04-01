# Lacuna

A premium iOS time capsule app. Seal a thought, a photo, or a voice note — for your future self or someone you love. No peeking. No extending. That is the point.

## Features

- **Text capsules** — WYSIWYG editor with bold, italic, and paragraph formatting (New York serif)
- **Photo capsules** — from library or camera, with smart compression
- **Voice capsules** — record voice notes with animated waveform playback
- **Send to loved ones** — share sealed capsules via iMessage, AirDrop, email, or any messenger
- **Reveal ceremony** — multi-phase animation with haptics and synthesized audio when a capsule opens
- **Local-only** — no accounts, no servers, no cloud. Everything stays on your device
- **Lacuna +** — one-time purchase for unlimited capsules, camera access, and sending

## Tech Stack

- SwiftUI + SwiftData
- iOS 26+, Swift 6.0
- RevenueCat for in-app purchases
- AVFoundation for audio recording/playback and synthesized reveal tones
- No third-party UI frameworks

## Architecture

```
Models/       — Capsule (SwiftData), CapsuleType, CapsulePackage, CreateStep, AppearanceMode
Views/        — Home, Create flow, Sealed, Opened, Reveal, Settings, Archive, Onboarding, Paywall
Components/   — FloatingParticles, TextEditor, PhotoEditor, AudioControls, RevealCeremony
Utilities/    — StoreManager, AudioManager, NotificationManager, Design system, CapsuleExporter
```

## Design

Cream-and-black aesthetic. All text lowercase. All corners angular (0 radius). Wide letter-spacing. Geometric floating particles with comets. Haptic feedback on every interaction.

## License

All rights reserved. This is a commercial app.

## Author

Antonio Baltic — [antoniobaltic@icloud.com](mailto:antoniobaltic@icloud.com)

# Lacuna

Time capsule iOS app. Lock content (text, photo, voice) behind a future date. No peeking. No extending. Local-only, no backend. Send capsules to loved ones via `.capsule` files.

## Build & Run

```bash
xcodebuild -project embargo.xcodeproj -scheme lacuna -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Bundle ID: `antoniobaltic.embargo` | Display name: `Lacuna` | Team: `7Z862J5PAH` | iOS 26+ | Swift 6.2

## Architecture

- **SwiftData** — single `Capsule` model, `@Query` in views
- **No backend, no auth** — everything on-device
- Audio: `.m4a` files in Documents, referenced by filename in model
- Photos: `Data` stored directly in SwiftData
- **Notifications**: local via `UserNotifications`, scheduled at seal, cancelled on delete
- **Social**: `.capsule` files (JSON + base64 media), UTType `antoniobaltic.embargo.capsule`
- **StoreKit 2**: non-consumable IAP `antoniobaltic.embargo.pro`, config: `EmbargoProducts.storekit`

## Docs

- **DESIGN.md** — full visual spec (typography, colors, tracking, shapes, animations, haptics)
- **MARKETING.md** — brand strategy, target audience, positioning, viral loop
- **PAYWALL.md** — monetization model, free/pro tiers, trigger logic
- **PRIVACY_POLICY.md** — full privacy policy (GDPR/DSGVO compliant)

## Key Quirks

- `SwiftUI.Capsule()` — must disambiguate from the `Capsule` data model
- **Creme palette** — light mode uses warm off-white (`Design.bg/fg/surface`), not pure white. Dark mode uses pure black bg with warm creme text. All custom colors in asset catalog (`CremeBackground`, `CremeForeground`, `CremeSurface`)
- **All text lowercase** — every user-facing string, no exceptions
- **All corners angular** — `Design.radiusSmall/Medium/Large` are all 0
- **Haptics on everything** — `.sensoryFeedback()` modifiers, never UIKit generators
- **Accessibility labels** — all buttons have text labels, use `labelStyle(.iconOnly)` for visual icon-only
- Animations chain via `withAnimation { } completion: { }`, never DispatchQueue
- Share sheet presented via UIKit `UIActivityViewController` directly (not SwiftUI `.sheet`) to avoid presentation conflicts
- Toast notifications use a separate `UIWindow` (via `ToastWindow`) to appear above sheets
- Appearance mode changes use `UITraitCollection.current` to read true device scheme, avoiding circular reads inside `.preferredColorScheme`
- Launch screen uses `UILaunchScreen` storyboard with `CremeBackground` color

## Project Structure

```
Models/       — Capsule, CapsuleType, CapsulePackage, CreateStep, RevealPhase, AppearanceMode
Views/        — Home, Create flow (4 steps), Sealed, Opened, Reveal, Settings, Archive, Onboarding (6 screens), Paywall, PrivacyPolicy
Components/   — CountdownView, SealButton, SendButton, AudioRecorder, FloatingParticles, AnimatedWaveform, CapsuleInfoCard, etc.
Utilities/    — AudioManager, NotificationManager, StoreManager, CapsuleExporter, CapsuleImporter, Design, AppearanceResolver, ToastWindow
SupportFiles/ — Info.plist (UTType/document types)
```

## Core Rules

- Sealed capsules cannot be peeked or date-extended — core product constraint
- `Capsule.openedAt == nil` → sealed; non-nil → opened
- `Capsule.isLocal` = not sent and not received
- `Capsule.isSent` = sender's local copy; `Capsule.isReceived` = `senderName != nil`
- Home sections: ready → received → sealed → sent (sent collapsed to 3)
- Archive (separate sheet): all opened capsules
- Three bottom buttons: settings, archive, add
- After reveal, SealedCapsuleView auto-dismisses back to list
- Create flow: swipe-back gesture, no forward swiping past validation
- Audio cleanup on delete and creation cancel

## Monetization

- **lacuna +**: one-time $4.99, non-consumable IAP (`antoniobaltic.embargo.pro`)
- Free: 3 text + 1 photo + 1 voice (active sealed), no send, no camera
- Pro: unlimited everything
- Receiving always free (social loop)
- Soft paywall: triggered by limits only, never by time/launch
- Onboarding has soft paywall on screen 5 of 6

## Onboarding (6 screens)

1. "you exist only now." — existential opener, star dot, "do I?" button
2. Rotating moon — "so treasure a thought for the future", "i want to"
3. Animated clock — "waiting will be involved", "i am patient"
4. Swinging bell — "allow us to notify you", triggers permission dialog on advance
5. Pulsing lacuna icon — paywall (lacuna +), skipped if already pro
6. Plus icon — "create your first capsule", "capture it now" → opens create flow

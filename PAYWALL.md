# Lacuna — Paywall

## Model

One-time lifetime purchase. No subscriptions. No ads.

- **Product**: lacuna +
- **Product ID**: `antoniobaltic.embargo.pro`
- **Type**: non-consumable (StoreKit 2)
- **Price**: $4.99 USD (localized via StoreKit)
- **Fallback**: "loading..." if product fails to load (button disabled)

## Free vs Pro

| Feature | Free | lacuna + |
|---------|------|----------|
| Text capsules | 3 active sealed | unlimited |
| Photo capsules | 1 active sealed | unlimited |
| Voice capsules | 1 active sealed | unlimited |
| Send to loved ones | no | yes |
| Receive capsules | always | always |
| Camera capture | no | yes |
| Photo library | yes | yes |
| Archive | full | full |
| Dark/light mode | yes | yes |

### How limits work

Limits count **active sealed local capsules** only (`isLocal && isSealed`). Opening a capsule frees the slot. Free tier never permanently locks anyone out.

### Always free

- Receiving capsules (social loop must not break)
- Archive (all opened capsules, forever)
- Appearance mode (dark/light/automatic)

## Paywall Triggers

Soft paywall only. **Never by time, never on launch.**

| Trigger | Reason | Message |
|---------|--------|---------|
| 4th text capsule | `.textLimit` | "you've reached the free limit of 3 active text capsules..." |
| 2nd photo capsule | `.photoLimit` | "you've reached the free limit of 1 active photo capsule..." |
| 2nd voice capsule | `.voiceGated` | "you've reached the free limit of 1 active voice capsule..." |
| Send button | `.sendGated` | "sending capsules is a lacuna + feature..." |
| Camera button | `.cameraGated` | "camera capture is a lacuna + feature..." |

### Generic paywall (settings)

When opened from settings, shows no context-specific message — just "unlock everything. forever."

### Where paywalls never appear

- App launch, content viewing, received capsules, reveal animation, uninitiated flows

## Visual Indicators

- Lock icon on voice option in type selection
- Lock icon on camera button in photo editor

## Paywall Screen

- Header: "pro" (left) + "close" button (right, `Design.fg` fill)
- Pulsing lacuna icon (black circle + creme inner circle + pulse ring)
- "lacuna +" title + "unlock everything. forever."
- Context message (if triggered from limit)
- Feature checklist: unlimited capsules, send to loved ones, camera capture
- Purchase button: full-width `Design.fg`, price from StoreKit
- "perhaps later" (outlined button, onboarding only)
- "restore purchase" link
- Floating particles overlay
- No urgency tricks, no fake discounts

## Onboarding Integration

Screen 5 of 6 in onboarding is the soft paywall. Shows "we must ask" whisper text. Skipped entirely if user is already pro. "perhaps later" advances to final screen.

## Restore

`AppStore.sync()` → `checkEntitlement()`. Distinguishes cancellation from real errors — user cancel shows nothing, connection failure shows alert.

## What We Don't Do

- No ads, no subscriptions, no consumable IAP, no fake urgency, no data selling, no feature degradation

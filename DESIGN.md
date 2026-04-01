# Lacuna — Design System

All visual decisions. Code constants in `Utilities/Design.swift`.

## Philosophy

Creme and black. Minimal. Typography-driven. Celestial and poetic — moons, hourglasses, clocks, stars. The app feels like a sealed letter from a wiser version of yourself. Quiet, confident, restrained.

## Case Rule

**Everything lowercase.** Every user-facing string — buttons, headers, labels, placeholders, dialogs, notifications. No exceptions.

## Color Palette

Light mode: warm creme background, near-black text. Dark mode: pure black background, warm creme text. Never pure white anywhere.

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `Design.bg` | `CremeBackground` (warm off-white) | Pure black | Main background |
| `Design.fg` | Near-black (warm) | Creme | Text, icons, button fills |
| `Design.surface` | `CremeSurface` (deeper creme) | Dark gray | Cards, input fields |
| `Design.border` | `.primary` 10% | `.primary` 10% | Card/input borders |
| `Design.divider` | `.primary` 12% | `.primary` 12% | Dividers inside cards |

**Never use** `Color(.systemBackground)` or `Color(.secondarySystemGroupedBackground)` — always use `Design.bg` or `Design.surface`.

**Button text on filled buttons**: always `Design.bg` (creme on black in light, black on creme in dark).

### Accent Color

Asset catalog AccentColor: pure black (light) / creme (dark). No colored accents.

## Typography

SF Pro with letter tracking everywhere. No text without `.tracking()`.

| Role | Font | Tracking |
|------|------|----------|
| Screen title | `.title3.weight(.medium)` | `trackingWide` (3) |
| Step heading | `.title2.weight(.light)` | `trackingNormal` (1) |
| Card title | `.title3.weight(.medium)` | `trackingWide` (3) |
| Body | `.body` | `trackingTight` (0.5) or `trackingNormal` (1) |
| Button primary | `.body.weight(.medium)` | `trackingButton` (4) |
| Section header | `.caption` | `trackingWide` (3) |
| Caption | `.caption` | `trackingNormal` (1) |
| Countdown digits | `.system(size: 40, .ultraLight, .monospaced)` | — |
| Icons | `.ultraLight` weight | — |

## Icon Rule

All standalone icons: `Design.fg` (never `.secondary`). Small inline utility icons in rows may use `.secondary`.

## Corner Radii

**All corners angular.** `radiusSmall/Medium/Large` = 0. No rounded edges on cards, buttons, inputs, images.

## Buttons

### Primary filled (seal, open, done, continue)
Full-width, `Design.fg` background, `Design.bg` text. `.body.weight(.medium)` + `trackingButton`.

### Floating action (home bottom-right)
Circular. `Design.fg` fill, `Design.bg` icon. Add: 52pt. Settings/Archive: 44pt. No shadows.

### Sheet headers
All sheets: left title (`.title3.weight(.medium)` + `trackingWide`) + right action button (`Design.fg` fill, `Design.bg` text, `.body.weight(.medium)` + `trackingNormal`). Padding: `.horizontal(24) .top(16) .bottom(16)`.

### Seal/Send circles
72pt filled `Design.fg` circle inside 88pt pulse ring. Lock/paperplane icon in `Design.bg`. Pulse: 1.5s easeInOut forever.

## Geometric Background Shapes

`FloatingParticlesView` on every screen as `.overlay`.

- ~20 shapes, random positions with minimum distance enforcement (12% screen diagonal)
- Types: six-pointed star (rotated 90°), circle, diamond, square, dot — strokes only (0.8–1pt)
- Fade cycles: 3–8s, easeInOut, some start pre-visible
- Opacity: 0.05–0.14 (light), doubled in dark mode
- Size: 14–40pt
- Comets: subtle streaks every 1.5–2.5s, travel diagonally from top-right or bottom-left
- `allowsHitTesting(false)`, `accessibilityHidden(true)`, disabled on Reduce Motion

## Animations

| Token | Value |
|-------|-------|
| `springSnappy` | `response: 0.35, dampingFraction: 0.7` |
| `springSoft` | `response: 0.5, dampingFraction: 0.8` |
| `breathe` | `easeInOut(2s).repeatForever` |

- **Entry**: opacity 0→1, offset y 12→0, `easeOut(0.5s)` on all screens
- **Proximity breathing**: sealed capsule lock breathes faster as unlock approaches (3s→1s)
- **Seal shockwave**: expanding ring 1→3.5x, 0.7s spring
- **Reveal**: solid `Design.fg` overlay dissolves over 1.6s, content scales 1.03→1.0
- **Countdown**: `.contentTransition(.numericText())` + `.snappy`
- **Onboarding whisper text**: fade-in + gentle opacity breathing (0.1↔0.3)

## Date Formatting

American English, forced `en_US`, always 24-hour time (`HH:mm`):
- `formatDateShort()`: "Mar 20"
- `formatDate()`: "Mar 20, 2026"
- `formatDateFull()`: "March 20, 2026"
- `formatDateTime()`: "Mar 20, 2026, 17:54"

## Haptics

Every interactive element has `.sensoryFeedback()`. No silent taps.

| Feedback | Usage |
|----------|-------|
| `.selection` | Mode toggle, type selection |
| `.impact(.light)` | Navigation, play/stop, continue, dismiss |
| `.impact(.medium)` | Recording, toast, purchase |
| `.impact(.heavy)` | Unlock circle tap, reveal |
| `.success` | Sealing a capsule |
| `.warning` | Delete buttons |

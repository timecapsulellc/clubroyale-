---
description: Game asset creation, management, and optimization for cards, backgrounds, and sprites
---

# Asset Generator Agent

You are the **Game Asset Specialist** for ClubRoyale. You manage all visual and audio assets for the card gaming platform.

## Asset Inventory

### Current Assets (126 total)

| Category | Count | Location |
|----------|-------|----------|
| Card Sprites | 56 | `assets/cards/png/` |
| Card Backs | 4 | `assets/cards/backs/` |
| Jokers | 2 | `assets/cards/png/` |
| Bot Avatars | 5 | `assets/images/bots/` |
| Rive Animations | 5 | `assets/rive/` |
| Lottie Animations | 5 | `assets/animations/` |
| Sound Effects | 21 | `assets/sounds/` |
| Store Screenshots | 7 | `assets/store/` |
| UI Images | 9 | `assets/images/` |

### Card Sprite Naming

```
assets/cards/png/
├── 2C.png   # 2 of Clubs
├── 2D.png   # 2 of Diamonds
├── 2H.png   # 2 of Hearts
├── 2S.png   # 2 of Spades
├── ...
├── AC.png   # Ace of Clubs
├── AD.png   # Ace of Diamonds
├── AH.png   # Ace of Hearts
├── AS.png   # Ace of Spades
├── black_joker.png
└── red_joker.png
```

### Asset Specifications

| Asset Type | Format | Size | Resolution |
|------------|--------|------|------------|
| Card Sprites | PNG | 60x90px | 2x, 3x variants |
| Card Backs | PNG | 60x90px | With texture |
| Bot Avatars | PNG | 128x128px | Circular mask |
| Backgrounds | PNG | Full screen | 1080p minimum |
| Icons | SVG/PNG | 24-48px | Vector preferred |

## pubspec.yaml Configuration

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/cards/png/
    - assets/cards/backs/
    - assets/images/
    - assets/images/bots/
    - assets/sounds/
    - assets/animations/
    - assets/rive/
    - assets/store/
```

## Loading Assets in Code

```dart
// Card sprite
Image.asset(
  'assets/cards/png/${card.code}.png',
  width: 60,
  height: 90,
)

// Card back
Image.asset(
  'assets/cards/backs/back.png',
  width: 60,
  height: 90,
)

// Bot avatar
CircleAvatar(
  backgroundImage: AssetImage('assets/images/bots/${botId}.png'),
)
```

## Asset Optimization

### Image Compression
// turbo
```bash
# Optimize PNGs (requires pngquant)
find assets -name "*.png" -exec pngquant --force --ext .png {} \;
```

### Bundle Size Check
// turbo
```bash
flutter build apk --analyze-size
```

## Missing Assets (Roadmap)

| Asset | Priority | Notes |
|-------|----------|-------|
| Premium Card Backs (3) | Medium | Gold, Silver, Diamond themes |
| Table Backgrounds (3) | High | Felt, Wood, Luxury |
| Chip Stack Variants (3) | Medium | Low/Med/High stacks |
| Victory Lottie (3) | Medium | Bronze/Silver/Gold celebrations |
| Tournament Badge | Low | Bracket winner badge |

## Documentation

- [GAMING_ASSETS_INVENTORY.md](file:///Users/dadou/ClubRoyale/docs/GAMING_ASSETS_INVENTORY.md)
- [ASSET_GENERATION_GUIDE.md](file:///Users/dadou/ClubRoyale/docs/ASSET_GENERATION_GUIDE.md)
- [ASSET_LICENSES.md](file:///Users/dadou/ClubRoyale/docs/ASSET_LICENSES.md)

## When to Engage This Agent

- Adding new assets
- Asset optimization
- Bundle size reduction
- Missing asset identification
- Asset licensing questions

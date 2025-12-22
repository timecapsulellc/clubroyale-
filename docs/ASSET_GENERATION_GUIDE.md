# Gaming Asset Generation Guide
## ClubRoyale — December 22, 2025

---

## Overview

This guide provides detailed specifications and generation options for gaming assets across all 4 card games.

---

## Common Assets (Shared Across All Games)

### Card Deck Assets
| Asset | Format | Specs | Status |
|-------|--------|-------|--------|
| 52 Card Faces | SVG/PNG | 1024×1536 (2x), 512×768 (thumb) | ✅ Complete |
| Card Backs (3 variants) | PNG | 1024×1536, transparent layers | ✅ Complete |
| Jokers (2) | PNG | 1024×1536 | ✅ Complete |

### Table & Environment
| Asset | Format | Specs | Status |
|-------|--------|-------|--------|
| Table Backgrounds | PNG/JPG | 2048×2048 | ✅ Complete (3 variants) |
| Chip Stacks | SVG/PNG | Sprite sheet | ✅ Complete (3 sizes) |
| Avatar Icons | PNG | 512×512 | ✅ Complete |

### Animations
| Asset | Format | Size | Status |
|-------|--------|------|--------|
| Card Deal | Lottie JSON | <50KB | ✅ Complete |
| Card Shuffle | Lottie JSON | <50KB | ✅ Complete |
| Victory (3 tiers) | Lottie JSON | <50KB each | ✅ Complete |
| Pot Collect | Lottie JSON | <40KB | ✅ Complete |

### Sound Effects
| Category | Count | Format | Status |
|----------|-------|--------|--------|
| Card Sounds | 5 | WAV/OGG | ✅ Complete |
| Chip Sounds | 3 | WAV/OGG | ✅ Complete |
| UI Sounds | 4 | WAV/OGG | ✅ Complete |
| Game Events | 3 | WAV/OGG | ✅ Complete |

---

## Game-Specific Assets

### Royal Meld (Marriage)
| Asset | Description | Priority |
|-------|-------------|----------|
| Meld Token | Visual indicator for valid melds | ✅ Complete |
| Marriage Animation | Special celebration for marriage points | ✅ Complete |
| Partner Icon | Visual indicator for partners | ✅ Complete |
| Trump Display | Highlighted trump suit indicator | ✅ Complete |

### Call Break
| Asset | Description | Priority |
|-------|-------------|----------|
| Bid Selector | 1-13 selection dial/stepper | ✅ Complete |
| Trump Display | Spade suit indicator | ✅ Complete |
| Trick Counter | Running trick count UI | ✅ Complete |
| Score Table | Round-by-round scoreboard | ✅ Complete |

### Teen Patti
| Asset | Description | Priority |
|-------|-------------|----------|
| Pot Visualization | Central pot with chip stacks | ✅ Complete |
| Blind Bet Indicator | Visual for blind players | ✅ Complete |
| Show/Reveal Animation | Card reveal effect | ✅ Complete |
| Action Buttons | Raise/Call/Fold/Show set | ✅ Complete |

### In-Between
| Asset | Description | Priority |
|-------|-------------|----------|
| Middle Card Animation | Central card reveal | ✅ Complete |
| Risk Meter UI | Visual odds indicator | ✅ Complete |
| Multiplier Display | Reward multiplier overlay | ✅ Complete |
| Result Confetti | Win celebration effect | ✅ Complete |

---

## Asset Sources

### Open Source (Free)
| Source | Best For | License |
|--------|----------|---------|
| [Kenney.nl](https://kenney.nl/assets) | Card sprites, chips | CC0 |
| [OpenGameArt.org](https://opengameart.org) | Backgrounds, icons | Various |
| [game-icons.net](https://game-icons.net) | UI icons | CC BY 3.0 |
| [freesound.org](https://freesound.org) | Sound effects | CC0/BY |
| [itch.io](https://itch.io) | Asset packs | Various |

### Commercial/Paid
| Source | Best For | Notes |
|--------|----------|-------|
| Envato/GraphicRiver | Premium assets | Royalty-free |
| UI8, CreativeMarket | UI kits | One-time purchase |
| Asset Store packs | Complete kits | Check license |

### Generative AI
| Model | Best For | Commercial Use |
|-------|----------|----------------|
| Stable Diffusion/SDXL | Backgrounds, concepts | ✅ Allowed |
| Midjourney | Stylized art | ✅ Check license |
| DALL·E (OpenAI) | Quick prototypes | ✅ With conditions |
| Google Imagen | If available | ✅ Check terms |

---

## Generation Prompts

### Card Face (Vector Style)
```
Create a clean vector-style playing card face for the [RANK] of [SUIT],
minimal design, high-contrast, flat colors, center pip design with
modern stencil numbers and suit icon; transparent background;
export as SVG.
```

### Card Back Design
```
Generate a symmetrical geometric card back design for a premium card game,
royal-blue and gold accent, sophisticated pattern clearly visible at
small sizes, elegant crown motif, export as PNG and SVG.
```

### Table Background
```
Create a top-down poker table texture with [felt green/wood/luxury],
subtle vignette, soft lighting, center emblem of a crown; art style:
semi-realistic; provide 2048x2048 PNG.
```

### Bot Avatar
```
Create a stylized avatar for a card game AI bot named "[BOT_NAME]",
[personality traits], gaming-themed, friendly but competitive appearance,
circular frame, vibrant colors, 512x512 PNG with transparency.
```

---

## File Specifications

| Asset Type | Format | Dimensions | Notes |
|------------|--------|------------|-------|
| Card Faces | SVG + PNG | 1024×1536 | 2x for retina |
| Card Backs | PNG | 1024×1536 | Transparent layers |
| Table BG | PNG/JPG | 2048×2048 | + 1024×1024 scaled |
| Chips | SVG + PNG | Sprite sheet | Multiple denominations |
| Animations | Lottie JSON | N/A | <50KB per file |
| Sounds | WAV + OGG | N/A | <1s loops for SFX |
| Avatars | PNG | 512×512 | Transparent background |

---

## Directory Structure

```
assets/
├── cards/
│   └── png/           # 52 cards + backs + jokers
├── images/
│   ├── bots/          # 5 AI personality avatars
│   ├── chips/         # Chip stack variations
│   └── tables/        # Table backgrounds
├── animations/        # Lottie JSON files
├── rive/              # Rive animation files
├── sounds/
│   ├── cards/         # Card interaction sounds
│   ├── chips/         # Chip sounds
│   ├── game/          # Game event sounds
│   └── ui/            # UI feedback sounds
└── store/             # App store assets
```

---

## Licensing Checklist

- [ ] Confirm license for all open-source assets before release
- [ ] Keep attribution file for CC BY assets
- [ ] Retain AI generation prompts for audit trail
- [ ] Store original source files in `/assets/source/`
- [ ] Review terms of service for any AI-generated assets

---

**Last Updated:** December 22, 2025  
**Asset Completion:** 126/126 (100%)

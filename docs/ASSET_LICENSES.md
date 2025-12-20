# ClubRoyale Asset Licenses

This document tracks all third-party assets used in ClubRoyale and their licenses.

---

## 📊 Asset Inventory Summary

| Category | Status | Source | License |
|----------|--------|--------|---------|
| Playing Cards | ✅ Complete | Open Source | CC0 |
| UI Images | ✅ Complete | Custom | Proprietary |
| Sound Effects | ⚠️ Partial | Kenney.nl | CC0 |
| Lottie Animations | ⚠️ Pending | LottieFiles | Lottie Simple |

---

## 🎴 Playing Cards

### Standard Deck (assets/cards/png/)
- **Source:** American Byron Playing Cards (or similar open-source)
- **License:** CC0 1.0 Universal (Public Domain)
- **Files:** 52 standard cards + 2 jokers + card back
- **Quality:** ⭐⭐⭐⭐ (Good)

---

## 🔊 Sound Effects

### Existing Sounds (assets/sounds/)
- **card_slide.mp3** - Card sliding sound ✅
- **ding.mp3** - Notification ding ✅
- **tada.mp3** - Win celebration ✅

### Kenney Casino Audio (TO BE ADDED)
- **Source:** Kenney Game Assets
- **URL:** https://kenney.nl/assets/casino-audio
- **License:** CC0 1.0 Universal (Public Domain)
- **Attribution:** Not required (but appreciated)

```
Files to download:
├── cardFan1.ogg → assets/sounds/cards/card_shuffle.ogg
├── cardPlace1.ogg → assets/sounds/cards/card_deal.ogg
├── cardSlide1.ogg → assets/sounds/cards/card_flip.ogg
├── cardShove1.ogg → assets/sounds/cards/card_place.ogg
├── cardSlide3.ogg → assets/sounds/cards/card_pickup.ogg
├── chipsStack1.ogg → assets/sounds/chips/chip_stack.ogg
├── chipLay1.ogg → assets/sounds/chips/chip_place.ogg
└── chipsCollide1.ogg → assets/sounds/chips/chips_collect.ogg
```

### Kenney UI Audio (TO BE ADDED)
- **Source:** Kenney Game Assets
- **URL:** https://kenney.nl/assets/ui-audio
- **License:** CC0 1.0 Universal (Public Domain)

```
Files to download:
├── click1.ogg → assets/sounds/ui/click.ogg
├── error.ogg → assets/sounds/ui/error.ogg
├── confirm.ogg → assets/sounds/ui/success.ogg
└── maximize.ogg → assets/sounds/ui/notification.ogg
```

### Game Feedback Sounds (TO BE ADDED)
```
Files needed:
├── assets/sounds/game/your_turn.ogg
├── assets/sounds/game/lose.ogg
└── assets/sounds/game/timer_warning.ogg
```

---

## 🎬 Lottie Animations (TO BE ADDED)

### Source: LottieFiles Free Library
- **URL:** https://lottiefiles.com/free-animations
- **License:** Lottie Simple License (Free for personal/commercial)

### Animations to Download:

| Animation | Search Term | Save As |
|-----------|-------------|---------|
| Confetti | "confetti celebration" | assets/animations/confetti.json |
| Winner Trophy | "trophy winner" | assets/animations/winner.json |
| Loading Spinner | "loading cards" | assets/animations/loading.json |
| Success Check | "success checkmark" | assets/animations/success.json |
| Coins Falling | "coins falling" | assets/animations/coins.json |
| Card Deal | "card deal" | assets/animations/card_deal.json |
| Your Turn | "your turn" | assets/animations/your_turn.json |
| Sparkle | "sparkle" | assets/animations/sparkle.json |

---

## 🖼️ UI Images

### Custom Assets (Proprietary)
- **Owner:** TimeCapsule LLC
- **License:** Proprietary - All Rights Reserved

```
assets/images/
├── logo.png - ClubRoyale logo
├── diamond_3d.png - 3D diamond graphic
├── casino_bg_dark.png - Dark casino background
├── casino_chip_gold.png - Gold casino chip
├── dashboard_banner.png - Dashboard banner
├── avatar_placeholder.png - Default avatar
├── splash_bg.png - Splash background
├── splash_screen.png - Splash screen
├── vip_crown.png - VIP crown icon
└── chips/ - Chip variations
```

---

## 🔤 Fonts

### Google Fonts (via google_fonts package)

| Font | License | URL |
|------|---------|-----|
| Oswald | Open Font License (OFL) | https://fonts.google.com/specimen/Oswald |
| Roboto | Apache License 2.0 | https://fonts.google.com/specimen/Roboto |
| Open Sans | Open Font License (OFL) | https://fonts.google.com/specimen/Open+Sans |

---

## 📜 License Texts

### CC0 1.0 Universal (Public Domain)

> The person who associated a work with this deed has dedicated the work to the 
> public domain by waiving all of his or her rights to the work worldwide under 
> copyright law, including all related and neighboring rights, to the extent 
> allowed by law.
>
> You can copy, modify, distribute and perform the work, even for commercial 
> purposes, all without asking permission.

### Lottie Simple License

> Free to use for personal and commercial projects.
> Attribution appreciated but not required.
> Cannot be resold as standalone animation files.

---

## ✅ Quick Setup Checklist

### Sound Effects (5 minutes)
1. [ ] Go to https://kenney.nl/assets/casino-audio
2. [ ] Click "Download" (free, no account)
3. [ ] Extract ZIP and copy files to `assets/sounds/cards/`
4. [ ] Go to https://kenney.nl/assets/ui-audio
5. [ ] Extract and copy to `assets/sounds/ui/`
6. [ ] Rename files as specified above

### Lottie Animations (10 minutes)
1. [ ] Go to https://lottiefiles.com/free-animations
2. [ ] Search for each animation
3. [ ] Download JSON files
4. [ ] Place in `assets/animations/`

### Verify
```bash
flutter pub get
flutter analyze
```

---

*Last Updated: December 20, 2025*
*Document Version: 1.0*

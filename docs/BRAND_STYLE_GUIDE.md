# 👑 ClubRoyale Brand & Style Guide

**Version 2.0.0** | December 16, 2025

This document defines the visual identity, color palettes, and design standards for the ClubRoyale application. All UI/UX decisions should adhere to these guidelines to ensure a consistent, premium "Play & Connect" aesthetic.

---

## 1. Brand Identity

**ClubRoyale** is a **Play & Connect** social gaming platform. The aesthetic combines **Premium Casino**, **Social Hub**, and **Modern Digital Community**.

*   **Tagline**: "Play & Connect"
*   **Keywords**: Social, Luxury, Immersive, Gold, Depth, Community, Fun.
*   **Mood**: Dark mode by default, rich gradients, metallic accents.
*   **Core Value**: Games + Social = Community

---

## 2. Color Palettes

### Primary Theme: "Royal Green" (Default)
The signature look of ClubRoyale.
| Color Role | Color Name | Hex Code | Usage |
| :--- | :--- | :--- | :--- |
| **Primary** | Royal Green | `#0D5C3D` | App Bars, Primary Headers |
| **Secondary** | Rich Green | `#1B7A4E` | Gradients, Highlights |
| **Background** | Deep Forest | `#051A12` | Main Scaffold Background (Darkest) |
| **Accent/Action** | **Classic Gold** | `#D4AF37` | **CTAs**, Icons, Borders, Winning States |
| **Surface** | Dark Surface | `#0A2E1F` | Cards, Dialogs, Bottom Sheets |
| **Text (On Dark)** | White | `#FFFFFF` | Primary Content |
| **Text Secondary** | Sage Mist | `#B8D4C8` | Subtitles, Captions |

### Secondary Theme: "Royal Purple" (Legacy/Alt)
| Color Role | Color Name | Hex Code | Usage |
| :--- | :--- | :--- | :--- |
| **Primary** | Royal Purple | `#4A1C6F` | App Bars |
| **Background** | Deep Void | `#0D051A` | Main Background |
| **Accent/Action** | **Classic Gold** | `#D4AF37` | CTAs, Highlights |

### Special Theme: "Midnight Blue"
| Color Role | Color Name | Hex Code | Usage |
| :--- | :--- | :--- | :--- |
| **Primary** | Deep Blue | `#1A237E` | App Bars |
| **Accent** | **Sterling Silver** | `#B0BEC5` | **Replaces Gold** for this theme only |

---

## 3. UI Components

### Buttons
*   **Primary Button**:
    *   **Background**: Classic Gold (`#D4AF37`)
    *   **Text**: Dark/Black (High Contrast)
    *   **Shape**: Rounded Rectangle (`BorderRadius.circular(30)`)
    *   **Effect**: Subtle Shadow/Elevation
*   **Secondary/Outlined Button**:
    *   **Border**: Gold (`#D4AF37`)
    *   **Text**: Gold
    *   **Background**: Transparent or Low Alpha Gold (`0.1`)

### Typography
*   **Headings / Display**: **Oswald** (Google Fonts)
    *   *Usage*: Splash screens, Landing Page headers, Big Wins.
    *   *Weight*: Bold / 700.
*   **Body / UI**: **Roboto** or **Open Sans**
    *   *Usage*: Chat, Menus, Settings, Instructions.
    *   *Weight*: Regular / 400.

### Gradients
ClubRoyale rarely uses flat colors for large areas. Use **Linear Gradients** to create depth.
*   **Standard Direction**: Top-Left to Bottom-Right (`Alignment.topLeft` -> `Alignment.bottomRight`).
*   **Green Gradient**: `#1B7A4E` → `#0D5C3D` → `#051A12`
*   **Gold Gradient** (for Text/Borders): `#D4AF37` → `#F7E7CE` (Champagne) → `#D4AF37`

---

## 4. Assets & Imagery
*   **Logo**: The "Crown & Spade" emblem.
    *   File: `assets/images/logo.png`
*   **Splash Screen**:
    *   File: `assets/images/splash_bg.png`
    *   Must be full-screen, high-resolution.
*   **Cards**:
    *   Standard Deck: `assets/cards/png/`
    *   Backs: Dependent on theme (Green, Red, Blue, Gold).

---

## 5. Implementation Reference
*   **Theme Logic**: `lib/core/theme/multi_theme.dart`
*   **Game Table Themes**: `lib/core/theme/game_themes.dart`
*   **Fonts**: Managed via `google_fonts` package.

# Session Summary: P5R Background & Portrait Fixes

## Date: 2026.02.06.27

## Context
User requested full-screen background for the menu and "character extraction" for the entrance portrait.

## Fix Implemented
1.  **Menu Background**: The blurred Joker image now covers the **entire screen** (`BoxFit.cover`), creating a proper immersive background.
2.  **Entrance Portrait**:
    - Since the provided file is a **JPG** (no transparency), I added a **gradient fade mask** to the image edges.
    - This makes the rectangular image blend more naturally into the scene, avoiding harsh borders.
    - **Note**: For a perfect "cutout" effect, you *must* use a PNG file with a transparent background. Code cannot automatically remove the background from a JPG perfectly.

## Instructions for User
**Restart the application** to see the layout changes:

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

If you want the "perfect" Sojiro cutout, please find a transparent PNG, rename it to `assets/佐仓惣治郎.png` (and update the code/pubspec), or just overwrite the current JPG if you convert it.

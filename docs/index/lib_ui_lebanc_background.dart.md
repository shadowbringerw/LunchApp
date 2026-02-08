# lib/ui/lebanc_background.dart

## Overview
A background widget that implements a Persona 5 style visual aesthetic using CustomPainter.

## Components

### `LeblancBackground`
- Wraps the content in a `Stack`.
- Layers:
  1. `_GradientLayer`: Dark gradient background.
  2. `_NoiseAndStripesPainter`: Custom painter for visual noise.
  3. `child`: The content passed to the widget.

### `_GradientLayer`
- Linear gradient from TopLeft to BottomRight.
- Colors: Black/Dark Grey tones (`#080707` -> `#090A0C`).

### `_NoiseAndStripesPainter`
- **Stripes:** Draws diagonal red lines (`#B91C1C`) across the screen.
- **Dots:** Draws random white dots for noise texture.
- **Stains:** Draws random oval "coffee stains" or blotches (`#B45309`).
- Uses a `seed` to ensure consistent randomness (currently fixed to 13).

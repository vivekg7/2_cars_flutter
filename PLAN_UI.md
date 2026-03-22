# UI & Visual Redesign Plan

## Overview

Full visual overhaul of the 2 Cars game with a **theme system** supporting 4 distinct styles. All rendering remains programmatic (Canvas API, no image assets). Every theme re-skins the entire app — gameplay visuals and menu UI.

### Themes

| Theme               | Vibe                       | Background             | Palette                                         |
| ------------------- | -------------------------- | ---------------------- | ----------------------------------------------- |
| **Neon/Synthwave**  | Retro-futuristic arcade    | Near-black (#0a0a1a)   | Cyan, magenta, purple, hot pink, green          |
| **Flat Modern**     | Minimal, clean, Apple-like | White / light grey     | Coral (#FF6B6B), teal (#4ECDC4), muted greys    |
| **Retro Pixel-ish** | Chunky bold arcade         | Dark navy              | Bright red, blue, yellow, green, primary colors |
| **Realistic-lite**  | Grounded, detailed         | Dark asphalt (#1a1a1a) | Muted golds, dark reds, charcoal, warm whites   |

### Theme Access

- All 4 themes unlocked from the start
- Selector on main menu as a row of labeled chips (below difficulty)
- Horizontal swipe on main menu cycles through themes with transition animation
- Selection persisted via SharedPreferences

---

## Phase 1: Theme System Foundation

### 1.1 — Create `GameTheme` model

Create `lib/models/game_theme.dart` with a `GameTheme` class holding all visual parameters:

- **Background**: primary background color, secondary tint colors
- **Lane**: left/right lane tint colors + opacity, divider color, divider style (solid/dashed/glow/double), center divider color + style, scroll behavior (none/dashes/grid), outer edge style
- **Car**: left/right car fill colors, stroke color + width, body shape (rounded/boxy/tapered/outline-only), has glow (bool), windshield color, headlight style, wheel visibility
- **Objects**: circle fill/stroke colors, circle center style, square fill/stroke colors, square X color + style, has glow (bool), has rotation (bool, for retro squares)
- **Particles**: collection color + count + size + has trails, collision color + count + size + has gravity, exhaust enabled (bool) + color + shape, speed lines enabled (bool) + color + intensity
- **UI**: overlay background color + opacity + gradient, title color + has glow + has outline, button bg/text/border colors + border radius + border width, chip selected/unselected colors + border radius + border width, score text color, high score accent color, font letter spacing
- **Meta**: `name` (display string), `id` (persistence key)

Four static instances: `GameTheme.neon`, `GameTheme.flatModern`, `GameTheme.retro`, `GameTheme.realistic`

### 1.2 — Integrate into `GameState`

- Add `GameTheme currentTheme` to `GameState`
- Load/save theme preference in `SharedPreferences` (store `id` string)
- Add `setTheme(GameTheme)` method that notifies listeners

### 1.3 — Theme selector on main menu

- Row of `ChoiceChip` widgets below the difficulty selector, one per theme
- Horizontal `GestureDetector` / swipe on the entire overlay to cycle themes
- Brief animated transition when theme changes (e.g., quick fade or cross-fade)

---

## Phase 2: Car Visuals

Refactor `CarComponent` to read all visual properties from the current `GameTheme`.

### Neon/Synthwave

- Car body as a **glowing outline only** — no solid fill
- Left car: cyan outline, right car: magenta outline
- Double-stroke glow: inner bright stroke + outer wider stroke at 30% opacity
- Windshield: thin horizontal line in lighter shade
- Headlights: small glowing circles with bloom (layered circles, decreasing opacity)
- Exhaust: neon-colored spark particles (cyan/magenta)

### Flat Modern

- Solid filled rounded rectangle, slightly tapered front (narrower top)
- Left car: coral (#FF6B6B), right car: sky blue (#4ECDC4)
- Windshield: contrasting darker rectangle
- Headlights: small solid dots
- No shadows, no gradients
- Exhaust: none (disabled for clean aesthetic)

### Retro Pixel-ish

- Boxy rectangle, **no border-radius** — sharp corners
- Thick 3px outline in darker shade of fill color
- Left car: bright red fill, right car: bright blue fill
- 4 visible square "wheels" protruding slightly from each side
- Windshield: lighter colored strip with thick border
- Exhaust: small white/grey square puffs

### Realistic-lite

- Tapered body shape via custom `Path` (narrower at front, wider at rear)
- Subtle vertical gradient (lighter top, darker bottom)
- Rounded windshield area with white reflection streak
- Circular wheels on sides (dark circles with grey hub center)
- Drop shadow beneath car
- Headlights: soft yellow radial gradient glow
- Exhaust: soft grey smoke puffs with horizontal drift and fade

---

## Phase 3: Falling Objects

Refactor `FallingObjectComponent` to read from theme. Hitbox sizes remain identical across themes.

### Circles (collect)

| Theme       | Fill                                            | Stroke                           | Center                                         | Special                   |
| ----------- | ----------------------------------------------- | -------------------------------- | ---------------------------------------------- | ------------------------- |
| Neon        | None (outline only)                             | Green/yellow glow, double-stroke | Bright dot                                     | Pulsing opacity animation |
| Flat Modern | Solid mint/green                                | None                             | Small white dot or checkmark                   | Clean, static             |
| Retro       | Bright yellow fill                              | Thick black outline              | Chunky dot                                     | Static                    |
| Realistic   | Gold radial gradient (light center → dark edge) | None                             | Inner ring + white specular highlight top-left | Coin-like embossed look   |

### Squares (avoid)

| Theme       | Fill                  | Stroke                         | X Style                                                  | Special                           |
| ----------- | --------------------- | ------------------------------ | -------------------------------------------------------- | --------------------------------- |
| Neon        | None (outline only)   | Red/orange glow, double-stroke | Two glowing diagonal lines                               | Subtle opacity flicker each frame |
| Flat Modern | Solid warm red/orange | None                           | Clean white X                                            | Slightly smaller than circles     |
| Retro       | Bright red fill       | Thick black outline            | Bold black X, thick strokes                              | Slight rotation (5-10°)           |
| Realistic   | Dark red gradient     | Thin border                    | Beveled X (lighter top-left, darker bottom-right stroke) | Drop shadow beneath               |

---

## Phase 4: Lane Backgrounds

Refactor `LaneBackground` to support scrolling elements and per-theme styling.

### Neon/Synthwave

- Near-black base (#0a0a1a)
- Faint vertical neon grid lines scrolling downward (parallax)
- Horizontal grid lines also scrolling down — creates sense of speed
- Lane dividers: thin glowing lines — cyan (left), magenta (right)
- Center divider: bright purple glow line
- Outer edges: subtle gradient fade to pure black

### Flat Modern

- Soft muted tints — left lane light coral, right lane light teal (10-15% opacity)
- Lane dividers: thin solid grey lines
- Center divider: slightly thicker dark grey line
- Static — no scrolling elements
- Clean, minimal — lanes barely visible so objects pop

### Retro Pixel-ish

- Darker saturated colors — left deep red, right deep blue (20% opacity)
- Lane dividers: thick dashed white lines, **scrolling downward**
- Center divider: double thick line
- Dashes scroll continuously for road-movement feel
- Outer edges: thick solid border line

### Realistic-lite

- Dark asphalt grey base with subtle horizontal band variation (faux texture)
- Lane dividers: white dashed lines **scrolling downward** (proper road markings)
- Center divider: **double yellow line** (road-authentic)
- Subtle vignette darkening at edges
- Dash scroll speed tied to current game speed

---

## Phase 5: Menu UI

Re-skin `overlays.dart` — every overlay adapts to the current theme.

### Neon/Synthwave

- **Overlay BG**: near-black 95% opacity, faint purple radial gradient from center
- **Title**: "2 CARS" with glow effect — stacked strokes in hot pink
- **Buttons**: transparent with cyan neon border, white text with glow. Flash brighter on tap
- **Chips**: neon-outlined, selected fills with neon color
- **Scores**: glowing green text. High score list in cyan
- **Typography**: Outfit, increased letter-spacing

### Flat Modern

- **Overlay BG**: clean white 95% opacity
- **Title**: bold black, large font weight
- **Buttons**: solid rounded rectangles in accent color (coral/teal), white text. No shadows
- **Chips**: pill-shaped, grey unselected, accent-colored selected
- **Scores**: dark grey text. Minimal color
- **Typography**: Outfit, normal spacing

### Retro Pixel-ish

- **Overlay BG**: dark navy 95% opacity
- **Title**: bold yellow with thick black text outline/stroke
- **Buttons**: chunky rectangles, thick borders, yellow bg + black text. No rounding
- **Chips**: boxy, thick-bordered, bright fill when selected
- **Scores**: white with slight shadow offset (retro text shadow)
- **Typography**: Outfit, all uppercase, tight line spacing

### Realistic-lite

- **Overlay BG**: dark charcoal vertical gradient (darker top → lighter bottom) 92% opacity
- **Title**: white with subtle metallic feel — thin horizontal gradient across text
- **Buttons**: rounded with gradient fill (dark → slightly lighter), thin light border
- **Chips**: rounded, muted colors, brighter fill + highlight when selected
- **Scores**: warm white/cream. High scores in card containers with rounded corners + faint border
- **Typography**: Outfit, normal spacing

---

## Phase 6: Visual Feedback

New and upgraded feedback effects, all theme-aware.

### 6.1 — Score Popups (new)

On circle collection, "+1" text floats upward from the collected position and fades out over ~0.5 seconds.

| Theme       | Style                                |
| ----------- | ------------------------------------ |
| Neon        | Glowing green text with bloom fade   |
| Flat Modern | Clean solid accent-colored text      |
| Retro       | Chunky text with thick black outline |
| Realistic   | Subtle gold text with soft shadow    |

### 6.2 — Screen Shake (new)

On game-over collision, shake the entire game view: 3-4 frames of random offset (2-4px), then settle. Same behavior across all themes.

### 6.3 — Collection Particles (upgraded)

| Theme       | Style                                                             |
| ----------- | ----------------------------------------------------------------- |
| Neon        | Bright sparks streaking outward with glow trails                  |
| Flat Modern | Clean confetti — small squares in accent colors, no trails        |
| Retro       | Few large chunky square particles in primary colors               |
| Realistic   | Golden sparkle particles with slight gravity, like coins bursting |

### 6.4 — Collision Particles (upgraded)

| Theme       | Style                                                                                  |
| ----------- | -------------------------------------------------------------------------------------- |
| Neon        | Red/orange electric sparks with flickering glow, dramatic                              |
| Flat Modern | Car flashes red briefly, then circular burst of grey particles                         |
| Retro       | Large boxy red/orange/yellow explosion particles, fewer but chunkier                   |
| Realistic   | Debris-like particles with gravity — pieces fall down after burst, smoke-grey + orange |

### 6.5 — Exhaust Particles (upgraded)

| Theme       | Style                                                     |
| ----------- | --------------------------------------------------------- |
| Neon        | Tiny cyan/magenta dots trailing behind, fading quickly    |
| Flat Modern | **Disabled** — clean aesthetic                            |
| Retro       | Small square white/grey puffs                             |
| Realistic   | Soft grey smoke puffs with slight horizontal drift + fade |

### 6.6 — Speed Lines (new)

Faint vertical lines at screen edges scrolling down fast. Intensity scales with `currentSpeed / maxSpeed`.

| Theme       | Style                        |
| ----------- | ---------------------------- |
| Neon        | Bright neon streaking lines  |
| Flat Modern | Subtle grey thin lines       |
| Retro       | Thick dashed lines           |
| Realistic   | Motion-blur style thin lines |

---

## Phase 7: Polish & Cohesion

Final pass to ensure everything ties together.

- [ ] Test all 4 themes end-to-end (menu → gameplay → game over → high scores)
- [ ] Verify hitboxes are identical across themes
- [ ] Ensure theme transition on main menu feels smooth
- [ ] Check performance — glow effects and scrolling lanes shouldn't drop FPS
- [ ] Verify theme persists across app restarts
- [ ] Test all difficulty + theme combinations
- [ ] Ensure particles don't look broken at high speeds
- [ ] Visual consistency check — no stray hardcoded colors remaining

---

## Implementation Order Summary

| Step | What                      | Files                                                                  |
| ---- | ------------------------- | ---------------------------------------------------------------------- |
| 1.1  | `GameTheme` model         | `lib/models/game_theme.dart` (new)                                     |
| 1.2  | Integrate into GameState  | `lib/models/game_state.dart`                                           |
| 1.3  | Theme selector UI + swipe | `lib/ui/overlays.dart`                                                 |
| 2    | Themed car rendering      | `lib/game/components/car_component.dart`                               |
| 3    | Themed falling objects    | `lib/game/components/falling_object_component.dart`                    |
| 4    | Themed lane backgrounds   | `lib/game/components/lane_background.dart`                             |
| 5    | Themed menu UI            | `lib/ui/overlays.dart`                                                 |
| 6    | Feedback effects          | `lib/game/components/` (new + existing), `lib/game/two_cars_game.dart` |
| 7    | Polish pass               | All files                                                              |

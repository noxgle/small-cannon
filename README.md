# Small Cannon

A Factorio 2.0 mod that adds a small artillery turret available earlier than standard artillery — ideal for mid-game base defense.

---

## Table of Contents

1. [Description](#description)
2. [New turret: Small Artillery](#new-turret-small-artillery)
3. [New ammo: Small Cannon Shell](#new-ammo-small-cannon-shell)
4. [Technology](#technology)
5. [Recipes](#recipes)
6. [Comparison: Small vs Standard Artillery](#comparison-small-vs-standard-artillery)
7. [Installation](#installation)
8. [Mod files](#mod-files)
9. [Known issues](#known-issues)
10. [License](#license)

---

## Description

**Small Cannon** introduces a smaller, cheaper, and earlier artillery turret together with dedicated, cheaper ammunition. It is a great addition to your base when standard artillery is still out of reach because it requires space science.

The turret uses the `cannon-shell` ammo category, so it can also accept regular tank cannon shells for close-range use. Its dedicated `small-cannon-shell` ammo is designed for long-range artillery fire.

---

## New turret: Small Artillery

| Property | Value |
|----------|-------|
| Prototype name | `small-artillery-turret` |
| HP | 500 |
| Range | 96 tiles |
| Minimum range | 5 tiles |
| Fire rate | every 1 second (60 ticks) |
| Ammo category | `cannon-shell` |
| Projectile creation distance | 1.5 |

**Automatic targeting** — the turret automatically targets and fires at enemies within range, just like standard artillery.

---

## New ammo: Small Cannon Shell

Small Cannon Shell is a cheaper, dedicated long-range shell for the small artillery turret. It uses the `cannon-shell` ammo category, which keeps the turret compatible with regular tank cannon shells while allowing this custom shell to reach artillery-like range.

| Property | Value |
|----------|-------|
| Prototype name | `small-cannon-shell` |
| Projectile name | `small-cannon-shell-projectile` |
| Projectile type | `artillery-projectile` |
| Damage | 150 explosion damage |
| Explosion radius | 4 tiles |
| Maximum ammo range | 96 tiles |
| Reload time | 1 second (60 ticks) |
| Magazine size | 1 |
| Inventory stack size | 50 |

**Hit effects:**
- Visual explosion at the impact point
- Area explosion damage within a 4-tile radius
- Decorative removal, such as trees and rocks, within a 4-tile radius

---

## Technology

**Small Artillery** — a technology that unlocks the small artillery turret and Small Cannon Shells.

| Property | Value |
|----------|-------|
| Prototype name | `small-artillery` |
| Prerequisites | `military-3`, `production-science-pack`, `engine` |
| Cost | 200 research units |
| Research time | 30 seconds |
| Science packs | military (gray), production (purple), chemical (blue) |
| Effects | Unlocks the `small-artillery-turret` and `small-cannon-shell` recipes |

Available after unlocking production science (purple science packs), before space science.

---

## Recipes

### Small Artillery Turret

```
Crafting time: 5s
Ingredients:
  - 30x steel plate (steel-plate)
  - 20x iron gear wheel (iron-gear-wheel)
  - 10x engine unit (engine-unit)
  -  5x electric engine unit (electric-engine-unit)
  - 10x advanced circuit (advanced-circuit)
Result: 1x small-artillery-turret
```

### Small Cannon Shell

```
Crafting time: 3s
Ingredients:
  - 6x iron plate (iron-plate)
  - 3x steel plate (steel-plate)
  - 2x explosives (explosives)
Result: 1x small-cannon-shell
```

---

## Comparison: Small vs Standard Artillery

| Property | Small Artillery | Standard Artillery |
|----------|-----------------|--------------------|
| HP | 500 | 1000 |
| Range | 96 | 224 |
| Fire rate | every 1s | every 3s |
| Damage per shell | 150 | 500 |
| Explosion radius | 4 | 8 |
| Footprint | ~2×2 tiles | ~3×3 tiles |
| Turret cost | about 65 resources | about 125 resources |
| Ammo cost | 6 iron + 3 steel + 2 explosives | 8 steel + 5 explosives + 2 plastic |
| Required technology | **production science** | **space science** |
| Game stage | Mid game | Late game |

---

## Installation

### Manual installation

1. Copy the `small-cannon` folder to your Factorio mods directory:

   | System | Path |
   |--------|------|
   | **Linux** | `~/.factorio/mods/small-cannon/` |
   | **Windows** | `%appdata%/Factorio/mods/small-cannon/` |
   | **macOS** | `~/Library/Application Support/factorio/mods/small-cannon/` |

2. Launch Factorio — the mod should appear in the mods list.
3. Enable the mod and click **Synchronize mods**, or start the game.

### Through the Mod Portal

*(The mod is not currently published on the Factorio Mod Portal.)*

---

## Mod files

```
small-cannon/
├── info.json            # Mod metadata: name, version, dependencies
├── data.lua             # New prototypes: ammo, projectile, recipes, technology
├── data-updates.lua     # Copies and modifies the base turret and gun
├── locale/              # Translations for supported languages
└── README.md            # This file
```

### `data.lua`

Defines all new prototypes that do not depend on base game prototypes:
- `small-cannon-shell` — ammo item
- `small-cannon-shell-projectile` — artillery projectile
- Recipes for the turret and ammo
- Technology `small-artillery`

### `data-updates.lua`

Runs after base data is loaded. It copies the standard artillery turret prototype and its gun (`artillery-wagon-cannon`), then modifies them:
- Scales the turret graphics to 65%
- Reduces turret stats such as HP and range
- Reduces the collision box and selection box
- Creates the matching item and corpse/remnants prototypes
- Creates a new gun prototype (`small-artillery-cannon`) with modified attack parameters, such as range and fire rate
- Links the new turret to the new gun through the `gun` field

---

## Known issues

- The turret graphics are based on a **scaled-down** version of the original artillery turret texture, so the proportions may not look perfect.
- The shell animation uses the standard artillery projectile graphics instead of dedicated custom art.
- The mod has not been tested with other mods that add or modify artillery, so ammo-category conflicts may occur.
- Requires **Factorio 2.0** — it does not work with Factorio 1.1.

---

## License

MIT — you are free to modify and redistribute this mod.

# AGENTS.md — Small Cannon (Factorio 2.0 mod)

**This is a Factorio 2.0 mod.** No build system, no tests, no linters, no CI, no package manager. The only way to verify the mod works is to load it in Factorio (drop `small-cannon/` into `~/.factorio/mods/`).

## Loading order (critical)

Factorio loads mod data in a fixed order — getting this wrong breaks the mod:

1. **`data.lua`** — runs first, defines *new* prototypes (ammo, projectile, recipes, technology). Must not reference base game prototypes. The turret entity + gun are deep-copied in data-updates.lua.
2. **`data-updates.lua`** — runs after all base data is loaded. Deep-copies both the standard artillery turret (`artillery-turret`) and its gun (`artillery-wagon-cannon`), then modifies both.
3. **`settings.lua`** — defines runtime-global settings (`small-cannon-scan-interval`, `small-cannon-cluster-radius`, `small-cannon-min-targets`).
4. **`control.lua`** — runtime script (variant B smart targeting). Keeps a turret registry in `storage`, sets turrets `active = false` to suppress vanilla auto-fire, scans for enemy clusters round-robin, and fires script-spawned projectiles.

If you add a new file, stage it in the correct phase: use `data.lua` for standalone prototypes, `data-updates.lua` for anything that reads or modifies base prototypes, `control.lua` for runtime behavior.

## Mod structure

```
small-cannon/
├── info.json          # Factorio mod manifest — version, deps, factorio_version
├── data.lua           # New prototypes (ammo, projectile, recipes, technology)
├── data-updates.lua   # Deep-copies base turret + gun → scales down stats & graphics
├── settings.lua       # Runtime-global cluster-targeting settings
├── control.lua        # Smart cluster targeting (registry, scan, manual fire)
├── locale/            # Translations for 15 Factorio languages
│   ├── en/locale.cfg
│   ├── pl/locale.cfg
│   └── ... (de, es, fr, it, ja, ko, nl, pt-BR, ru, sk, uk, zh-CN, zh-TW)
└── README.md          # English docs, tables, known issues
```

## Key gotchas

- **`info.json`** — `factorio_version` must be `"2.0"`. Dependencies are `"base >= 2.0"` only.
- **`util.table.deepcopy`** — from Factorio's built-in `util` module (not a Lua stdlib). Used in `data-updates.lua` to clone base prototypes.
- **Factorio 2.0 prototype syntax** — recipes use `{ type = "item", name = "...", amount = N }`. Technology ingredients use `{ "science-pack-name", N }` (simple array pairs, not key-value tables).
- **`artillery-turret` requires `artillery-projectile`** — the turret's gun uses `action_delivery.type = "artillery"` and the projectile must be `type = "artillery-projectile"`, not regular `projectile`. Otherwise auto-targeting breaks and the turret fires at the same spot.
- **Ammunition** — the turret uses custom `small-cannon-shell` ammo (`ammo_category = "cannon-shell"`) with a custom projectile `small-cannon-shell-projectile`. Range is 96 (vs 30 for standard tank shells). The turret still accepts regular tank shells for close-range use.
- **Prototype names** — `small-artillery-turret`, `small-artillery-cannon` (gun), `small-cannon-shell`, `small-cannon-shell-projectile`, `small-artillery`, `small-artillery-turret-remnants`.
- **Script-spawned oriented explosions need `target`** — `surface.create_entity` for entities like `artillery-cannon-muzzle-flash` throws an unrecoverable error without a `target` parameter. Always pass `target` (v1.1.1 crashed on this, fixed in 1.1.2).
- **Smart targeting (control.lua)** — turrets are `active = false` (no vanilla auto-fire); the script fires at the largest cluster (≥ `small-cannon-min-targets` enemies within `small-cannon-cluster-radius`, range 5–96; ties go to the nearest cluster). Default min is 1, so lone targets are engaged too. Shells are consumed via `defines.inventory.artillery_turret_ammo` and the projectile is spawned with `surface.create_entity{name, position, target, speed=1, force}`. Deliberately NOT `artillery-flare` — a flare would also trigger big vanilla artillery. Only `small-cannon-shell` is fired; tank shells loaded in the turret sit idle.
- **No automated testing** — manual test only: copy to mods dir, launch Factorio, verify turret appears, verify it fires at lone biters, prefers the larger of two groups, and picks the nearer group on ties.
- **Graphics** — the turret visuals are a 65% scaled copy of the base artillery turret (`scale_entity_sprites(turret, 0.65)`). No custom art assets.
- **Language** — README is in English, code and identifiers are in English. Polish translations live in `locale/pl/`; other locales use English fallback for mod-setting strings.

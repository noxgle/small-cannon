# AGENTS.md — Small Cannon (Factorio 2.0 mod)

**This is a Factorio 2.0 mod.** No build system, no tests, no linters, no CI, no package manager. The only way to verify the mod works is to load it in Factorio (drop `small-cannon/` into `~/.factorio/mods/`).

## Loading order (critical)

Factorio loads mod data in a fixed order — getting this wrong breaks the mod:

1. **`data.lua`** — runs first, defines *new* prototypes (ammo, projectile, recipes, technology). Must not reference base game prototypes. The turret entity + gun are deep-copied in data-updates.lua.
2. **`data-updates.lua`** — runs after all base data is loaded. Deep-copies both the standard artillery turret (`artillery-turret`) and its gun (`artillery-wagon-cannon`), then modifies both.

If you add a new file, stage it in the correct phase: use `data.lua` for standalone prototypes, `data-updates.lua` for anything that reads or modifies base prototypes.

## Mod structure

```
small-cannon/
├── info.json          # Factorio mod manifest — version, deps, factorio_version
├── data.lua           # New prototypes (ammo, projectile, recipes, technology)
├── data-updates.lua   # Deep-copies base turret + gun → scales down stats & graphics
├── locale/            # Translations for 15 Factorio languages
│   ├── en/locale.cfg
│   ├── pl/locale.cfg
│   └── ... (de, es, fr, it, ja, ko, nl, pt-BR, ru, sk, uk, zh-CN, zh-TW)
└── README.md          # Polish-language docs, tables, known issues
```

## Key gotchas

- **`info.json`** — `factorio_version` must be `"2.0"`. Dependencies are `"base >= 2.0"` only.
- **`util.table.deepcopy`** — from Factorio's built-in `util` module (not a Lua stdlib). Used in `data-updates.lua` to clone base prototypes.
- **Factorio 2.0 prototype syntax** — recipes use `{ type = "item", name = "...", amount = N }`. Technology ingredients use `{ "science-pack-name", N }` (simple array pairs, not key-value tables).
- **`artillery-turret` requires `artillery-projectile`** — the turret's gun uses `action_delivery.type = "artillery"` and the projectile must be `type = "artillery-projectile"`, not regular `projectile`. Otherwise auto-targeting breaks and the turret fires at the same spot.
- **Ammunition** — the turret uses custom `small-cannon-shell` ammo (`ammo_category = "cannon-shell"`) with a custom projectile `small-cannon-shell-projectile`. Range is 96 (vs 30 for standard tank shells). The turret still accepts regular tank shells for close-range use.
- **Prototype names** — `small-artillery-turret`, `small-artillery-cannon` (gun), `small-cannon-shell`, `small-cannon-shell-projectile`, `small-artillery`, `small-artillery-turret-remnants`.
- **No automated testing** — manual test only: copy to mods dir, launch Factorio, verify turret appears and fires tank shells.
- **Graphics** — the turret visuals are a 65% scaled copy of the base artillery turret (`scale_entity_sprites(turret, 0.65)`). No custom art assets.
- **Language** — README is in Polish, code and identifiers are in English.

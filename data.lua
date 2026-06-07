-- Small Cannon mod - data.lua
-- Defines new prototypes that don't depend on base game prototypes.
-- The turret uses custom small-cannon-shells (cannon-shell category)
-- for longer range than standard tank shells.

data:extend({

  -- ==========================================================================
  -- 1. SMALL CANNON SHELL (ammo item)
  -- ==========================================================================
  {
    type = "ammo",
    name = "small-cannon-shell",
    icon = "__base__/graphics/icons/cannon-shell.png",
    icon_size = 64,
    subgroup = "ammo",
    order = "c[artillery-shell]-a[small-cannon-shell]",
    ammo_category = "cannon-shell",
    stack_size = 50,
    ammo_type = {
      target_type = "position",
      action = {
        type = "direct",
        action_delivery = {
          type = "artillery",
          projectile = "small-cannon-shell-projectile",
          starting_speed = 1,
          direction_deviation = 0,
          range_deviation = 0,
          max_range = 96,
          source_effects = {
            type = "create-explosion",
            entity_name = "artillery-cannon-muzzle-flash"
          }
        }
      }
    },
    magazine_size = 1,
    reload_time = 60
  },

  -- ==========================================================================
  -- 2. SMALL CANNON SHELL PROJECTILE
  -- ==========================================================================
  {
    type = "artillery-projectile",
    name = "small-cannon-shell-projectile",
    flags = { "not-on-map" },
    hidden = true,
    reveal_map = true,
    map_color = {1, 1, 0},
    picture = {
      filename = "__base__/graphics/entity/artillery-projectile/shell.png",
      draw_as_glow = true,
      width = 64,
      height = 64,
      scale = 0.35
    },
    shadow = {
      filename = "__base__/graphics/entity/artillery-projectile/shell-shadow.png",
      width = 64,
      height = 64,
      scale = 0.35
    },
    chart_picture = {
      filename = "__base__/graphics/entity/artillery-projectile/artillery-shoot-map-visualization.png",
      flags = { "icon" },
      width = 64,
      height = 64,
      priority = "high",
      scale = 0.25
    },
    action = {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "create-entity",
            entity_name = "medium-explosion"
          },
          {
            type = "nested-result",
            action = {
              type = "area",
              radius = 4,
              action_delivery = {
                type = "instant",
                target_effects = {
                  {
                    type = "damage",
                    damage = { amount = 150, type = "explosion" }
                  },
                  {
                    type = "destroy-decoratives",
                    decoratives_with_trigger = {},
                    radius = 4
                  }
                }
              }
            }
          }
        }
      }
    },
    final_action = {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "create-entity",
            entity_name = "medium-scorchmark-tintable",
            check_buildability = true
          },
          {
            type = "invoke-tile-trigger",
            repeat_count = 1
          }
        }
      }
    }
  },

  -- ==========================================================================
  -- 3. RECIPE: Small Cannon Shell
  -- ==========================================================================
  {
    type = "recipe",
    name = "small-cannon-shell",
    enabled = false,
    energy_required = 3,
    ingredients = {
      { type = "item", name = "iron-plate", amount = 6 },
      { type = "item", name = "steel-plate", amount = 3 },
      { type = "item", name = "explosives", amount = 2 }
    },
    results = {
      { type = "item", name = "small-cannon-shell", amount = 1 }
    }
  },

  -- ==========================================================================
  -- 4. RECIPE: Small Artillery Turret
  -- ==========================================================================
  {
    type = "recipe",
    name = "small-artillery-turret",
    enabled = false,
    energy_required = 5,
    ingredients = {
      { type = "item", name = "steel-plate", amount = 30 },
      { type = "item", name = "iron-gear-wheel", amount = 20 },
      { type = "item", name = "engine-unit", amount = 10 },
      { type = "item", name = "electric-engine-unit", amount = 5 },
      { type = "item", name = "advanced-circuit", amount = 10 }
    },
    results = {
      { type = "item", name = "small-artillery-turret", amount = 1 }
    }
  },

  -- ==========================================================================
  -- 5. TECHNOLOGY: Small Artillery
  -- ==========================================================================
  {
    type = "technology",
    name = "small-artillery",
    icon = "__base__/graphics/icons/artillery-turret.png",
    icon_size = 64,
    prerequisites = {
      "military-3",
      "production-science-pack",
      "engine"
    },
    effects = {
      {
        type = "unlock-recipe",
        recipe = "small-artillery-turret"
      },
      {
        type = "unlock-recipe",
        recipe = "small-cannon-shell"
      }
    },
    unit = {
      count = 200,
      ingredients = {
        { "military-science-pack", 1 },
        { "production-science-pack", 1 },
        { "chemical-science-pack", 1 }
      },
      time = 30
    }
  }

})

-- Small Cannon mod - data-updates.lua
-- Copies base artillery turret and modifies it to create the smaller version

local util = require("util")

-- ---------------------------------------------------------------------------
-- Helper: recursively scale down animation sprite tables
-- ---------------------------------------------------------------------------
local function scale_animation_table(tbl, factor)
  if not tbl then return end
  -- Handle "layers" array (most common structure for Factorio animations)
  if tbl.layers and #tbl.layers > 0 then
    for _, layer in ipairs(tbl.layers) do
      scale_animation_table(layer, factor)
    end
  end
  -- If it's a direct array of sprite definitions (older pattern)
  if #tbl > 0 then
    for _, child in ipairs(tbl) do
      scale_animation_table(child, factor)
    end
  end
  -- Scale this specific sprite entry
  if tbl.scale then
    tbl.scale = tbl.scale * factor
  end
end

local function scale_entity_sprites(entity, factor)
  scale_animation_table(entity.base_picture, factor)
  scale_animation_table(entity.folded_animation, factor)
  scale_animation_table(entity.preparing_animation, factor)
  scale_animation_table(entity.folding_animation, factor)
end

-- ---------------------------------------------------------------------------
-- 1. Small Artillery Turret entity (copied from base)
-- ---------------------------------------------------------------------------
local base_turret = data.raw["artillery-turret"]["artillery-turret"]
if not base_turret then
  error("Small Cannon mod: Could not find base 'artillery-turret' prototype!")
  return
end

local small_turret = util.table.deepcopy(base_turret)

-- Identity
small_turret.name = "small-artillery-turret"

-- Stats
small_turret.max_health = 500
small_turret.minable = { mining_time = 1, result = "small-artillery-turret" }
-- Scale down collision/selection box to match smaller visuals
if small_turret.collision_box then
  small_turret.collision_box = {
    { small_turret.collision_box[1][1] * 0.7, small_turret.collision_box[1][2] * 0.7 },
    { small_turret.collision_box[2][1] * 0.7, small_turret.collision_box[2][2] * 0.7 }
  }
end
if small_turret.selection_box then
  small_turret.selection_box = {
    { small_turret.selection_box[1][1] * 0.7, small_turret.selection_box[1][2] * 0.7 },
    { small_turret.selection_box[2][1] * 0.7, small_turret.selection_box[2][2] * 0.7 }
  }
end

-- Factorio 2.0: attack parameters live on a GunPrototype, not on the turret entity
local base_gun = data.raw["gun"]["artillery-wagon-cannon"]
if base_gun then
  local small_gun = util.table.deepcopy(base_gun)
  small_gun.name = "small-artillery-cannon"
  small_gun.attack_parameters.ammo_category = "cannon-shell"  -- uses standard tank shells
  small_gun.attack_parameters.range = 96                      -- 3 chunks (capped by ammo max_range=100)
  small_gun.attack_parameters.min_range = 5
  small_gun.attack_parameters.cooldown = 60                   -- 1s between shots (same as tank cannon)
  small_gun.attack_parameters.projectile_creation_distance = 1.5
  small_turret.gun = "small-artillery-cannon"
  data:extend({ small_gun })
else
  error("Small Cannon mod: Could not find base 'artillery-wagon-cannon' gun!")
  return
end

-- Scale down graphics
scale_entity_sprites(small_turret, 0.65)

-- Update the alert icon shift (adjust for smaller size)
if small_turret.alert_icon_shift then
  small_turret.alert_icon_shift = {
    small_turret.alert_icon_shift[1] or 0,
    (small_turret.alert_icon_shift[2] or 0) - 0.2
  }
end

-- Add the new turret entity
data:extend({ small_turret })

-- ---------------------------------------------------------------------------
-- 2. Small Artillery Turret item (copied from base)
-- ---------------------------------------------------------------------------
local base_item = data.raw["item"]["artillery-turret"]
if base_item then
  local small_item = util.table.deepcopy(base_item)
  small_item.name = "small-artillery-turret"
  small_item.place_result = "small-artillery-turret"
  small_item.order = "b[turret]-e[small-artillery-turret]"
  data:extend({ small_item })
else
  -- Fallback: define minimal item manually
  data:extend({
    {
      type = "item",
      name = "small-artillery-turret",
      icon = "__base__/graphics/icons/artillery-turret.png",
      icon_size = 64,
      subgroup = "defensive-structure",
      order = "b[turret]-e[small-artillery-turret]",
      place_result = "small-artillery-turret",
      stack_size = 20
    }
  })
end

-- ---------------------------------------------------------------------------
-- 3. Small Artillery Turret corpse (copied from base)
-- ---------------------------------------------------------------------------
local base_corpse = data.raw["corpse"]["artillery-turret-remnants"]
if base_corpse then
  local small_corpse = util.table.deepcopy(base_corpse)
  small_corpse.name = "small-artillery-turret-remnants"
  -- Scale the corpse sprite down too
  if small_corpse.animation then
    scale_animation_table(small_corpse.animation, 0.65)
  end
  data:extend({ small_corpse })
  -- Point the turret to its corpse
  small_turret.corpse = "small-artillery-turret-remnants"
  -- Re-register the turret with updated corpse reference
  data.raw["artillery-turret"]["small-artillery-turret"].corpse = "small-artillery-turret-remnants"
end

-- ---------------------------------------------------------------------------
-- 4. Dying explosion reference (keep same as base)
-- ---------------------------------------------------------------------------
if not data.raw["artillery-turret"]["small-artillery-turret"].dying_explosion then
  data.raw["artillery-turret"]["small-artillery-turret"].dying_explosion = "medium-explosion"
end

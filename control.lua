-- Small Cannon mod - control.lua
-- Smart cluster targeting (variant B): the small artillery turret does NOT use
-- vanilla auto-fire. Instead, this script periodically scans for the LARGEST
-- cluster of enemies (>= min_targets within cluster_radius) inside the
-- turret's range and fires a single custom shell at its centroid. Ties go to
-- the cluster closest to the turret. With min_targets = 1 even lone targets
-- are engaged; raise it to save ammo for groups only.
--
-- Why scripted fire instead of an artillery-flare: a flare would attract fire
-- from EVERY friendly artillery in range (including big vanilla turrets and
-- their expensive shells). Spawning our own projectile keeps full control:
-- only small turrets fire and only small-cannon-shells are consumed.
--
-- NOTE: vanilla auto-fire is disabled at the prototype level
-- (disable_automatic_firing in data-updates.lua), so turrets stay ACTIVE and
-- animated -- they just never shoot on their own. The script only consumes
-- small-cannon-shells; regular tank shells can still be fired manually with
-- the artillery remote.

local TURRET_NAME = "small-artillery-turret"
local AMMO_NAME = "small-cannon-shell"
local PROJECTILE_NAME = "small-cannon-shell-projectile"
local MUZZLE_FLASH = "artillery-cannon-muzzle-flash"

local RANGE = 96
local MIN_RANGE = 5
local COOLDOWN = 60 -- ticks between shots, mirrors the gun prototype
-- Barrel-tip offset (tiles) from the turret center along the aim direction.
-- Mirrors the gun's projectile_creation_distance so the muzzle flash and the
-- shell emerge at the barrel tip instead of the turret base. Tune if the
-- scaled (0.65x) visuals place the tip visibly elsewhere.
local MUZZLE_DISTANCE = 1.5
local MAX_TURRETS_PER_SCAN = 10 -- round-robin budget per scan (UPS safety)
local MAX_ENEMIES_PER_TURRET = 200 -- per-turret scan cap (UPS safety)

-- ---------------------------------------------------------------------------
-- Registry
-- ---------------------------------------------------------------------------
local function ensure_storage()
  storage.small_turrets = storage.small_turrets or {} -- [unit_number] = LuaEntity
  storage.turret_order = storage.turret_order or {} -- array of unit_numbers (round-robin)
  storage.scan_index = storage.scan_index or 0
  storage.last_scan_tick = storage.last_scan_tick or 0
  storage.last_shot = storage.last_shot or {} -- [unit_number] = tick
end

local function register_turret(entity)
  if not entity or not entity.valid then return end
  if entity.name ~= TURRET_NAME then return end
  ensure_storage()
  -- Keep the turret active so animations, alert icons and inserters work.
  -- (Vanilla auto-fire is disabled via the prototype's
  -- disable_automatic_firing flag; also re-activates turrets placed by older
  -- mod versions that used active = false.)
  entity.active = true
  local unit = entity.unit_number
  if not storage.small_turrets[unit] then
    storage.small_turrets[unit] = entity
    storage.turret_order[#storage.turret_order + 1] = unit
  else
    storage.small_turrets[unit] = entity -- refresh reference
  end
end

local function unregister_turret(unit_number)
  if not unit_number then return end
  ensure_storage()
  storage.small_turrets[unit_number] = nil
  storage.last_shot[unit_number] = nil
  -- Order array is rebuilt lazily during scans; stale entries are skipped.
end

local function resync_turrets()
  ensure_storage()
  storage.small_turrets = {}
  storage.turret_order = {}
  for _, surface in pairs(game.surfaces) do
    local found = surface.find_entities_filtered({ name = TURRET_NAME })
    for _, entity in pairs(found) do
      entity.active = true
      local unit = entity.unit_number
      storage.small_turrets[unit] = entity
      storage.turret_order[#storage.turret_order + 1] = unit
    end
  end
end

-- ---------------------------------------------------------------------------
-- Cluster search: the LARGEST group of >= min_targets enemies within radius.
-- Ties are broken deterministically in favour of the cluster closest to the
-- turret (shorter shell flight, tighter defence). Returns centroid {x, y}.
-- ---------------------------------------------------------------------------
local function find_best_cluster(enemies, turret_pos, radius, min_targets)
  local r2 = radius * radius
  local n = #enemies
  local best_count = 0
  local best_d2 = nil
  local best_x = 0
  local best_y = 0
  for i = 1, n do
    local ax = enemies[i].position.x
    local ay = enemies[i].position.y
    local count = 0
    local sx = 0
    local sy = 0
    for j = 1, n do
      local dx = enemies[j].position.x - ax
      local dy = enemies[j].position.y - ay
      if dx * dx + dy * dy <= r2 then
        count = count + 1
        sx = sx + enemies[j].position.x
        sy = sy + enemies[j].position.y
      end
    end
    if count >= min_targets and count > best_count then
      best_count = count
      best_x = sx / count
      best_y = sy / count
      local tdx = best_x - turret_pos.x
      local tdy = best_y - turret_pos.y
      best_d2 = tdx * tdx + tdy * tdy
    elseif count >= min_targets and count == best_count and best_d2 ~= nil then
      local cx = sx / count
      local cy = sy / count
      local tdx = cx - turret_pos.x
      local tdy = cy - turret_pos.y
      local d2 = tdx * tdx + tdy * tdy
      if d2 < best_d2 then
        best_x = cx
        best_y = cy
        best_d2 = d2
      end
    end
  end
  if best_count >= min_targets then
    return { x = best_x, y = best_y }
  end
  return nil
end

-- ---------------------------------------------------------------------------
-- Aiming: turn the barrel toward the target.
-- relative_turret_orientation is 0 = north, rising clockwise (0.25 = east,
-- 0.5 = south, 0.75 = west). The property only exists on turret-ish entities
-- (vehicle turret, artillery turret/wagon), so the nil check keeps this safe.
-- Pure function of positions => multiplayer-safe.
-- ---------------------------------------------------------------------------
local function orientation_to(from_pos, to_pos)
  local dx = to_pos.x - from_pos.x
  local dy = to_pos.y - from_pos.y
  if dx == 0 and dy == 0 then return nil end
  local o = math.atan(dx, -dy) / (2 * math.pi)
  if o < 0 then o = o + 1 end
  return o
end

local function aim_turret(turret, target)
  if turret.relative_turret_orientation == nil then return end
  local o = orientation_to(turret.position, target)
  if o ~= nil then
    turret.relative_turret_orientation = o
  end
end

-- ---------------------------------------------------------------------------
-- Firing
-- ---------------------------------------------------------------------------
local function try_fire(turret, centroid, tick)
  local last = storage.last_shot[turret.unit_number] or -COOLDOWN
  if tick - last < COOLDOWN then return end

  local inv = turret.get_inventory(defines.inventory.artillery_turret_ammo)
  if not inv or inv.get_item_count(AMMO_NAME) < 1 then return end
  inv.remove({ name = AMMO_NAME, count = 1 })

  local surface = turret.surface
  local pos = turret.position
  -- Spawn visuals at the barrel tip, not the turret center.
  local dx = centroid.x - pos.x
  local dy = centroid.y - pos.y
  local len = math.sqrt(dx * dx + dy * dy)
  local muzzle = { x = pos.x, y = pos.y }
  if len > 0 then
    muzzle = {
      x = pos.x + dx / len * MUZZLE_DISTANCE,
      y = pos.y + dy / len * MUZZLE_DISTANCE
    }
  end
  -- NOTE: oriented explosions (like the muzzle flash) REQUIRE a target when
  -- created from script, otherwise create_entity throws unrecoverably.
  if prototypes.entity[MUZZLE_FLASH] then
    surface.create_entity({
      name = MUZZLE_FLASH,
      position = muzzle,
      target = { x = centroid.x, y = centroid.y },
      force = turret.force
    })
  end
  surface.create_entity({
    name = PROJECTILE_NAME,
    position = muzzle,
    target = { x = centroid.x, y = centroid.y },
    speed = 1,
    force = turret.force
  })
  storage.last_shot[turret.unit_number] = tick
end

local function scan_turret(turret, radius, min_targets, tick)
  if not turret or not turret.valid then return "dead" end
  local surface = turret.surface
  if not surface or not surface.valid then return "dead" end

  -- No ammo => nothing to do: skip the expensive enemy scan AND the barrel
  -- traverse, so an unloaded turret sits still instead of tracking targets.
  local ammo_inv = turret.get_inventory(defines.inventory.artillery_turret_ammo)
  if not ammo_inv or ammo_inv.get_item_count(AMMO_NAME) < 1 then return "ok" end

  local pos = turret.position
  local area = {
    { pos.x - RANGE, pos.y - RANGE },
    { pos.x + RANGE, pos.y + RANGE }
  }
  -- Worms are type "turret", biters/spitters "unit", nests "unit-spawner".
  local candidates = surface.find_entities_filtered({
    area = area,
    type = { "unit", "turret", "unit-spawner" }
  })
  if #candidates == 0 then return "ok" end

  local min2 = MIN_RANGE * MIN_RANGE
  local max2 = RANGE * RANGE
  local force = turret.force
  local enemies = {}
  for _, e in pairs(candidates) do
    if #enemies >= MAX_ENEMIES_PER_TURRET then break end
    if e.valid and e.force ~= force and force.is_enemy(e.force) then
      local dx = e.position.x - pos.x
      local dy = e.position.y - pos.y
      local d2 = dx * dx + dy * dy
      if d2 >= min2 and d2 <= max2 then
        enemies[#enemies + 1] = e
      end
    end
  end
  if #enemies < min_targets then return "ok" end

  local centroid = find_best_cluster(enemies, pos, radius, min_targets)
  if centroid then
    -- Traverse the barrel even when the shot itself is blocked by cooldown or
    -- missing ammo, so the turret visibly tracks its target like vanilla.
    aim_turret(turret, centroid)
    try_fire(turret, centroid, tick)
  end
  return "ok"
end

-- ---------------------------------------------------------------------------
-- Main scan (throttled + round-robin)
-- ---------------------------------------------------------------------------
local function on_tick(event)
  ensure_storage()
  local interval = settings.global["small-cannon-scan-interval"].value or 60
  if event.tick - storage.last_scan_tick < interval then return end
  storage.last_scan_tick = event.tick

  local radius = settings.global["small-cannon-cluster-radius"].value or 8
  local min_targets = settings.global["small-cannon-min-targets"].value or 1

  local order = storage.turret_order
  local n = #order
  if n == 0 then return end

  local dead = {}
  local budget = math.min(n, MAX_TURRETS_PER_SCAN)
  for _ = 1, budget do
    storage.scan_index = storage.scan_index + 1
    if storage.scan_index > n then storage.scan_index = 1 end
    local unit = order[storage.scan_index]
    local turret = storage.small_turrets[unit]
    if turret == nil or not turret.valid then
      dead[#dead + 1] = unit
    else
      if scan_turret(turret, radius, min_targets, event.tick) == "dead" then
        dead[#dead + 1] = unit
      end
    end
  end

  if #dead > 0 then
    local dead_set = {}
    for _, u in pairs(dead) do
      dead_set[u] = true
      storage.small_turrets[u] = nil
      storage.last_shot[u] = nil
    end
    local fresh = {}
    for _, u in ipairs(order) do
      if not dead_set[u] then fresh[#fresh + 1] = u end
    end
    storage.turret_order = fresh
    storage.scan_index = 0
  end
end

-- ---------------------------------------------------------------------------
-- Events
-- ---------------------------------------------------------------------------
local function on_built(event)
  local entity = event.entity or event.created_entity or event.destination
  if entity and entity.valid and entity.name == TURRET_NAME then
    register_turret(entity)
  end
end

local function on_removed(event)
  local entity = event.entity
  if entity and entity.name == TURRET_NAME then
    unregister_turret(entity.unit_number)
  end
end

script.on_init(function()
  resync_turrets()
end)

script.on_configuration_changed(function()
  resync_turrets()
end)

script.on_event(defines.events.on_tick, on_tick)

script.on_event(defines.events.on_built_entity, on_built)
script.on_event(defines.events.on_robot_built_entity, on_built)
script.on_event(defines.events.script_raised_built, on_built)
script.on_event(defines.events.script_raised_revive, on_built)
script.on_event(defines.events.on_entity_cloned, on_built)

script.on_event(defines.events.on_player_mined_entity, on_removed)
script.on_event(defines.events.on_robot_mined_entity, on_removed)
script.on_event(defines.events.on_entity_died, on_removed)
script.on_event(defines.events.script_raised_destroy, on_removed)

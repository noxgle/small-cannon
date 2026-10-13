-- Small Cannon mod - settings.lua
-- Runtime-global tunables for the smart cluster targeting (see control.lua).

data:extend({
  {
    type = "int-setting",
    name = "small-cannon-scan-interval",
    setting_type = "runtime-global",
    default_value = 60,
    minimum_value = 10,
    maximum_value = 600,
    order = "a"
  },
  {
    type = "int-setting",
    name = "small-cannon-cluster-radius",
    setting_type = "runtime-global",
    default_value = 8,
    minimum_value = 2,
    maximum_value = 30,
    order = "b"
  },
  {
    type = "int-setting",
    name = "small-cannon-min-targets",
    setting_type = "runtime-global",
    default_value = 1,
    minimum_value = 1,
    maximum_value = 10,
    order = "c"
  },
  -- NOTE: string dropdown instead of a double setting on purpose: the
  -- in-game numeric field does not accept typing a minus sign, so negative
  -- offsets would be unreachable. Allowed values cover full/half/quarter turns.
  {
    type = "string-setting",
    name = "small-cannon-aim-offset",
    setting_type = "runtime-global",
    default_value = "0",
    allowed_values = { "0", "0.25", "-0.25", "0.5", "-0.5" },
    order = "d"
  }
})

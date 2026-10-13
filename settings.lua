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
  {
    type = "double-setting",
    name = "small-cannon-aim-offset",
    setting_type = "runtime-global",
    default_value = 0,
    minimum_value = -0.5,
    maximum_value = 0.5,
    order = "d"
  }
})

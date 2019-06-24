local setting = {}

setting.is_debug = false
setting.is_dev = true
setting.is_debug_physic = true
setting.proxy = "bootstrap:/loader#bootstrap"
setting.display_width = tonumber(sys.get_config("display.width"))
setting.display_height = tonumber(sys.get_config("display.height"))

setting.tile_size = 32

setting.scenes = {
  LoadingProxy = "bootstrap:/loader#loading",
  GameProxy = "bootstrap:/loader#game",
  Loading = "loading:/gui#loading",
  Game = "game://scripts#game",
  GameGUI = "game://gui#game_gui"
}

-- Acts
setting.acts = {
  {
    name = "PUSH"
  },
  {
    name = "JUMP"
  },
  {
    name = "PAUSE"
  },
  {
    name = "CLONE"
  },
  {
    name = "FIRE"
  },
  {
    name = "LEFT"
  },
  {
    name = "RIGHT"
  }
}
setting.act_count = #setting.acts

-- In game objects
setting.objects = {
  "HUMAN", -- 4
  "SIGN", -- 8
  "BUTTON", -- 12
  "TELEPORT", --13
  "BOT", --14
  "BLOCK" --15
}

setting.tile_objects = {
  {
    id = 4,
    factory = "/factories#human",
    offset_x = 0,
    offset_y = 2 ,-- height / 2
    factory_type = 2
  },
  {
    id = 8,
    factory = "/factories#sign",
    offset_x = 0,
    offset_y = 4,
    factory_type = 1
  },
  {
    id = 12,
    factory = "/factories#button",
    offset_x = 0,
    offset_y = 10,
    factory_type = 1
  },
  {
    id = 13,
    factory = "/factories#teleport",
    offset_x = 0,
    offset_y = 0,
    factory_type = 1
  },
  {
    id = 14,
    factory = "/factories#bot",
    offset_x = 0,
    offset_y = 4,
    factory_type = 1
  },
  {
    id = 15,
    factory = "/factories#block",
    offset_x = 0,
    offset_y = 12,
    factory_type = 1
  }
}

setting.objects_count = #setting.objects

return setting

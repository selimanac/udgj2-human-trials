local setting = {}

-- DEV
setting.is_dev = true
setting.is_debug = false
setting.is_debug_physic = false

setting.proxy = "bootstrap:/loader#bootstrap"
setting.display_width = tonumber(sys.get_config("display.width"))
setting.display_height = tonumber(sys.get_config("display.height"))

setting.tile_size = 32

setting.scenes = {
  LoadingProxy = "bootstrap:/loader#loading",
  GameProxy = "bootstrap:/loader#game",
  Loading = "loading:/gui#loading",
  Game = "game://scripts#game",
  GameGUI = "game:/gui#game_gui"
}

setting.act = {
  PUSH = 1,
  JUMP = 2,
  PAUSE = 3,
  CLONE = 4,
  FIRE = 5,
  LEFT = 6,
  RIGHT = 7
}
-- Acts
setting.acts = {
  {
    id = 15,
    name = "PUSH",
    anim = hash("act_push"),
    job = "human_queue"
  },
  {
    id = 21,
    name = "JUMP",
    anim = hash("act_jump"),
    job = "human_queue"
  },
  {
    id = 20,
    name = "PAUSE",
    anim = hash("act_pause"),
    job = "human_queue"
  },
  {
    id = 23,
    name = "CLONE",
    anim = hash("act_clone"),
    job = "human_play"
  },
  {
    id = 22,
    name = "FIRE",
    anim = hash("act_fire"),
    job = "human_queue"
  },
  {
    id = 19,
    name = "LEFT",
    anim = hash("act_left"),
    job = "human_play"
  },
  {
    id = 10,
    name = "RIGHT",
    anim = hash("act_right"),
    job = "human_play"
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
  "BLOCK", --15
  "ACT-STOP", --5
  "ACT-RIGHT", --10
  "ACT-PUSH", --15
  "ACT-PAUSE", --20
  "ACT-LEFT", --19
  "ACT-CLONE", --23
  "ACT-FIRE", --22
  "ACT-JUMP" --21
}

setting.tile_objects = {
  {
    id = 4,
    factory = "game:/factories#human",
    offset = vmath.vector3(0, 2, 0.12),
    factory_type = 2
  },
  {
    id = 9,
    factory = "/factories#sign",
    offset = vmath.vector3(0, 4, 0.1),
    factory_type = 1
  },
  {
    id = 14,
    factory = "/factories#button",
    offset = vmath.vector3(0, 10, 0.1),
    factory_type = 1
  },
  {
    id = 16,
    factory = "/factories#teleport",
    offset = vmath.vector3(0, 0, 0.1),
    factory_type = 1
  },
  {
    id = 17,
    factory = "/factories#bot",
    offset = vmath.vector3(0, 5, 0.11),
    factory_type = 1
  },
  {
    id = 18,
    factory = "/factories#block",
    offset = vmath.vector3(0, 12, 0.1),
    factory_type = 1
  },
  {
    id = 5,
    factory = "/factories#collectables",
    offset = vmath.vector3(0, 10, 0.1),
    factory_type = 1
  },
  {
    id = 10,
    factory = "/factories#collectables",
    offset = vmath.vector3(0, 10, 0.1),
    factory_type = 1
  },
  {
    id = 15,
    factory = "/factories#collectables",
    offset = vmath.vector3(0, 10, 0.1),
    factory_type = 1
  },
  {
    id = 20,
    factory = "/factories#collectables",
    offset = vmath.vector3(0, 10, 0.1),
    factory_type = 1
  },
  {
    id = 19,
    factory = "/factories#collectables",
    offset = vmath.vector3(0, 10, 0.1),
    factory_type = 1
  },
  {
    id = 23,
    factory = "/factories#collectables",
    offset = vmath.vector3(0, 10, 0.1),
    factory_type = 1
  },
  {
    id = 22,
    factory = "/factories#collectables",
    offset = vmath.vector3(0, 10, 0.1),
    factory_type = 1
  },
  {
    id = 21,
    factory = "/factories#collectables",
    offset = vmath.vector3(0, 10, 0.1),
    factory_type = 1
  }
}

setting.objects_count = #setting.objects

-- Walls
setting.walls = {
  "LEFT",
  "RIGHT",
  "GROUND"
}

setting.tile_walls = {
  {
    id = 6,
    factory = "/factories#wall",
    offset = vmath.vector3(14, 0, 0.1),
    factory_type = 1
  },
  {
    id = 8,
    factory = "/factories#wall",
    offset = vmath.vector3(-14, 0, 0.1),
    factory_type = 1
  },
  {
    id = 2,
    factory = "/factories#ground",
    offset = vmath.vector3(0, -13, 0.1),
    factory_type = 1
  }
}
setting.walls_count = #setting.walls

setting.anim = {
  walk = hash("man_walk"),
  idle = hash("man_idle"),
  draw = hash("man_draw"),
  draw_back = hash("man_draw_back"),
  jump_start = hash("man_jump_start"),
  jump_air = hash("man_jump_air"),
  jump_ground = hash("man_jump_ground"),
  push = hash("man_push"),
  teleport_out = "man_teleport_out",
  teleport_in = "man_teleport_in",
  teleport_idle = "man_teleport_idle",
  die = "man_die",
  clone = "man_clone"
}

setting.speedup = 2
setting.walk_speed = 20
setting.fall_speed = 110
setting.bullet_speed = 120

setting.direction = {
  LEFT = -1,
  RIGHT = 1
}
--[[ setting.left = vmath.quat_rotation_y(math.rad(180))
setting.right = vmath.quat_rotation_y(math.rad(0)) ]]
return setting

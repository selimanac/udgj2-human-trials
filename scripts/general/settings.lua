local setting = {}

setting.is_debug = true
setting.proxy= "bootstrap:/loader#bootstrap"
setting.display_width = tonumber(sys.get_config("display.width"))
setting.display_height = tonumber(sys.get_config("display.height"))

setting.scenes = {
    LoadingProxy = "bootstrap:/loader#loading",
    GameProxy = "bootstrap:/loader#game",
    Loading = "loading:/gui#loading",
    Game  = "game://scripts#game",
  }

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
setting.act_count =  #setting.acts



return setting
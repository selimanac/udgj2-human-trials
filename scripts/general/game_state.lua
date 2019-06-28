local machine = require("scripts.libs.statemachine")
local s = require("scripts.general.settings")
local v = require("scripts.general.vars")

local gs = {}

-- FSM
gs.fsm = nil

-- Game Launch
local function on_game_launching()
    -- Toggle Profiler
    if s.is_debug then
        profiler.enable_ui(true)
        msg.post("@system:", "toggle_physics_debug")
    end
    msg.post(s.proxy, "load_proxy", {scene = s.scenes.LoadingProxy, type = "load"})
end

local function on_game_loading()
    msg.post(s.proxy, "load_proxy", {scene = s.scenes.GameProxy, type = "async_load"})
end

local function on_game_initilasing()
    -- print("on_game_initilasing")
    msg.post(s.scenes.GameProxy, "acquire_input_focus")
    v.GAME_PAUSED = true

    -- p-- print(v.LEVEL_OBJECTS)
end

local function on_game_gameplay()
    -- print("on_game_gameplay")
    v.GAME_PAUSED = false
end

local function on_game_gamepause()
    -- print("on_game_gamepause")
    v.GAME_PAUSED = true
end

local function on_game_gamereplay()
end

function gs:init()
    -- Game State
    gs.fsm =
        machine.create(
        {
            events = {
                {name = "launch", from = "*", to = "launching"},
                {name = "load", from = "launching", to = "loading"},
                {name = "init", from = "loading", to = "initilasing"},
                {name = "play", from = {"*", "gamereplay", "gamepause", "initilasing"}, to = "gameplay"}, -- DELETE "*"
                {name = "pause", from = "gameplay", to = "gamepause"},
                {name = "replay", from = {"gameplay", "gamepause"}, to = "gamereplay"}
            },
            callbacks = {
                on_enter_launching = on_game_launching,
                on_enter_loading = on_game_loading,
                on_enter_initilasing = on_game_initilasing,
                on_enter_gameplay = on_game_gameplay,
                on_enter_gamepause = on_game_gamepause,
                on_enter_gamereplay = on_game_gamereplay
            }
        }
    )
end

return gs

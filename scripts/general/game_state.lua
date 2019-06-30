local machine = require("scripts.libs.statemachine")
local s = require("scripts.general.settings")
local v = require("scripts.general.vars")

local gs = {}

-- FSM
gs.fsm = nil

-- Game Launch
local function on_enter_launching(self, event, from, to, event_msg)
    -- Toggle Profiler
    if s.is_debug then
        profiler.enable_ui(true)
        msg.post("@system:", "toggle_physics_debug")
    end
    msg.post(s.proxy, "load_proxy", {scene = s.scenes.LoadingProxy, type = "load"})
end

local function on_enter_loading(self, event, from, to, event_msg)
    msg.post(s.proxy, "load_proxy", {scene = s.scenes.GameProxy, type = "async_load"})
end

local function on_enter_initilasing(self, event, from, to, event_msg)
    -- print("on_game_initilasing")
    msg.post(s.scenes.GameProxy, "acquire_input_focus")
    v.GAME_PAUSED = true

    -- p-- print(v.LEVEL_OBJECTS)
end

local function on_leave_initilasing()
   
end

local function on_enter_gameplay(self, event, from, to, event_msg)
    -- print("on_game_gameplay")
    v.GAME_PAUSED = false
end

local function on_leave_gameplay(self, event, from, to, event_msg)
   
end

local function on_enter_gamepause(self, event, from, to, event_msg)
    -- print("on_game_gamepause")
    v.GAME_PAUSED = true
end

local function on_before_gamereplay(self, event, from, to, event_msg)
   
    msg.post(s.proxy, "unload_proxy", {scene = s.scenes.GameProxy})

    v.LEVEL_OBJECTS = {}
    v.LEVEL_WALLS = {}
    v.IS_POINTER_DRAG = false
    v.CURRENT_SIGN = nil
    v.CURRENT_LEVEL = 1
    v.WALK_SPEED = 0
    v.FALL_SPEED = 0
    v.BULLET_SPEED = 0
    v.OBJ_INDEX = 0
    v.LEVEL_COUNTER = 1
    v.HUMAN_COUNT = 0
end

local function on_enter_gamereplay(self, event, from, to, event_msg)
    

    gs.fsm:launch()
end

function gs:init()
    -- Game State
    gs.fsm =
        machine.create(
        {
            events = {
                {name = "launch", from = "*", to = "launching"},
                {name = "load", from = {"gamereplay", "launching"}, to = "loading"},
                {name = "init", from = "loading", to = "initilasing"},
                {name = "play", from = {"*", "gamereplay", "gamepause", "initilasing"}, to = "gameplay"}, -- DELETE "*"
                {name = "pause", from = "gameplay", to = "gamepause"},
                {name = "replay", from = {"initilasing", "gameplay", "gamepause"}, to = "gamereplay"}
            },
            callbacks = {
                on_enter_launching = on_enter_launching,
                on_enter_loading = on_enter_loading,
                on_enter_initilasing = on_enter_initilasing,
                on_leave_initilasing = on_leave_initilasing,
                on_enter_gameplay = on_enter_gameplay,
                on_leave_gameplay = on_leave_gameplay,
                on_enter_gamepause = on_enter_gamepause,
                on_before_replay = on_before_gamereplay,
                on_enter_gamereplay = on_enter_gamereplay
            }
        }
    )
end

return gs

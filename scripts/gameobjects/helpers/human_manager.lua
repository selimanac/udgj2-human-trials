local machine = require("scripts.libs.statemachine")

human = {}

human.fsm = nil

local function on_enter_standing()
    print("on_enter_standing")
end

local function on_enter_walking()
    print("on_enter_walking")
end

local function on_enter_pushing()
    print("on_enter_pushing")
end

local function on_enter_hiding()
    print("on_enter_hiding")
end

local function on_enter_cloning()
    print("on_enter_cloning")
end

local function on_enter_turning()
    print("on_enter_turning")
end

local function on_enter_firing()
    print("on_enter_firing")
end

local function on_enter_jumping()
    print("on_enter_jumping")
end

local function on_enter_dying()
    print("on_enter_dying")
end

local function on_enter_falling()
    print("on_enter_falling")
end

function human:init()
    -- Game State
    human.fsm =
        machine.create(
        {
            events = {
                {name = "idle", from = "*", to = "standing"},
                {name = "walk", from = "standing", to = "walking"},
                {name = "push", from = "walking", to = "pushing"},
                {name = "hide", from = "walking", to = "hiding"},
                {name = "clone", from = "walking", to = "cloning"},
                {name = "turn", from = "walking", to = "turning"},
                {name = "fire", from = "walking", to = "firing"},
                {name = "jump", from = "walking", to = "jumping"},
                {name = "die", from = "walking", to = "dying"},
                {name = "fall", from = "walking", to = "falling"}
            },
            callbacks = {
                on_enter_standing = on_game_standing,
                on_enter_walking = on_game_walking,
                on_enter_pushing = on_game_pushing,
                on_enter_hiding = on_game_hiding,
                on_enter_cloning = on_game_cloning,
                on_enter_turning = on_game_turning,
                on_enter_firing = on_game_firing,
                on_enter_jumping = on_game_jumping,
                on_enter_dying = on_game_dying,
                on_enter_falling = on_game_falling
            }
        }
    )
end

return human

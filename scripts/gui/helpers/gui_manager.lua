local s = require("scripts.general.settings")
local v = require("scripts.general.vars")
local h = require("scripts.general.hashes")

manager = {}

local acts = {}
local pop_node = nil
local pop_text_node = nil
local pop_position = vmath.vector3()
local pop_is_visible = true
local current_pop = 0
local start_drag = false
local curent_act = {}
local action_pos = vmath.vector3(0, 0, 0)

function manager:reset()
    curent_act = {}
    current_pop = 0
end

local function toogle_pop()
    if pop_is_visible then
        pop_is_visible = false
    else
        pop_is_visible = true
    end
    gui.set_enabled(pop_node, pop_is_visible)
end

local function leave_act_btn()
    gui.animate(acts[current_pop].node, "scale", vmath.vector3(1, 1, 1), gui.EASING_LINEAR, 0.1)

    toogle_pop()

    current_pop = 0
end

local function enter_act_btn(act)
    current_pop = act.id

    local pos = vmath.vector3(act.screen_pos.x, pop_position.y, pop_position.z)

    gui.set_position(pop_node, pos)
    gui.set_text(pop_text_node, s.acts[act.id].name)

    toogle_pop()

    gui.animate(act.node, "scale", vmath.vector3(1.1, 1.1, 1.1), gui.EASING_LINEAR, 0.1)
end

local function pick_check(node, x, y)
    return gui.pick_node(node, x, y)
end

function manager:init()
    pop_node = gui.get_node("pop")
    pop_text_node = gui.get_node("pop_txt")
    pop_position = gui.get_position(pop_node)

    toogle_pop()

    local act_node = nil
    local act_count = nil
    local pos = vmath.vector3()

    local temp_table = {}
    for i = 1, s.act_count do
        act_node = gui.get_node("act_" .. i)
        act_count = gui.get_node("act_" .. i .. "_count")
        pos = gui.get_position(act_node)
        screen_pos = gui.get_screen_position(act_node)
        temp_table = {
            node = act_node,
            count = act_count,
            pos = pos,
            screen_pos = screen_pos,
            id = i
        }
        table.insert(acts, temp_table)
    end
end

function manager:input(action_id, action)
    action_pos.x = action.x
    action_pos.y = action.y

    -- Drag
    if start_drag then
        print("here")
        gui.set_position(curent_act.node, action_pos)
        v.POINTER_POS = action_pos
    end

    -- Over
    for i = 1, s.act_count do
        if pick_check(acts[i].node, action_pos.x, action_pos.y) and current_pop ~= acts[i].id then
            enter_act_btn(acts[i])
        elseif pick_check(acts[i].node, action_pos.x, action_pos.y) == false and current_pop == acts[i].id then
            leave_act_btn()
        end
    end

    -- Drag check
    if action_id == h.CLICK and action.pressed then
        for i = 1, s.act_count do
            if pick_check(acts[i].node, action_pos.x, action_pos.y) then
                toogle_pop()
                start_drag = true
                curent_act = acts[i]
            end
        end
    elseif action.released and start_drag then
        current_pop = 0
        start_drag = false
        v.POINTER_POS = vmath.vector3(0, 0, 0)
        gui.set_position(curent_act.node, curent_act.pos)
    end
end

return manager

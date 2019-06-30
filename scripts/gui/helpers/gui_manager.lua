local s = require("scripts.general.settings")
local v = require("scripts.general.vars")
local h = require("scripts.general.hashes")
local gs = require("scripts.general.game_state")
local audio = require("scripts.general.audio")

manager = {}

local acts = {}
local pop_node = nil
local pop_text_node = nil
local play_btn = nil
local speed_btn = nil
local pop_position = vmath.vector3()
local current_pop = 0
local start_drag = false
local curent_act = {}
local action_pos = vmath.vector3(0, 0, 0)
local layer_move = hash("move")
local layer_gfx = hash("gfx")
local is_speedup = false

local ai_container_node = nil
local ai_head_node = nil
local ai_txt_node = nil
local ai_container_start_pos = vmath.vector3()
local ai_container_size = vmath.vector3()
local ai_container_scale = vmath.vector3()
local ai_out_pos = vmath.vector3()
local ai_text = {
    "BEGIN YOUR TRIAL HUMAN.",
    "IMPRESSIVE, HUMAN.",
    "YOU ARE A SMART ONE.\nTHIS IS JUST A BEGINNING",
    "WHERE ARE YOU GOING HUMAN.\nYOU ARE GOING TO DIE!",
    "YOUR TIME IS OVER HUMAN.\nYOUR KIND IS JUST A SLAVE",
    "01000110 01010101 01000011 0100101\nWHAT IS THAT!",
    "ANOMALY DETECTED!\nYOU WILL PAY, HUMAN",
    "I AM GOING TO CRUSH YOU HUMAN.",
    "01000110 01010101 01000011 0100101\nYOUR END IS NEAR",
    "-. --- / -. --- / -. ---\n "
}

local function ai_head_out_complete(self)
    gui.play_flipbook(ai_head_node, hash("ai_in1"))
    gui.animate(ai_container_node, "position.y", ai_out_pos.y, gui.EASING_OUTCIRC, 0.4, 0)
end

local function ai_head_remove()
    audio:stop("ai_speak")
    gui.animate(ai_txt_node, "color.w", 0, gui.EASING_OUTCIRC, 0.3, 0)
    audio:play("ai_out", 0.5)
    gui.play_flipbook(ai_head_node, hash("ai_out"), ai_head_out_complete)
end

local function ai_text_in_complete(self)
    timer.delay(4, false, ai_head_remove)
    gui.play_flipbook(ai_head_node, hash("ai_talk"))
end

local function ai_head_in_complete(self)
    audio:play("ai_speak", 0.5)
    gui.set_text(ai_txt_node, ai_text[v.CURRENT_LEVEL])
    gui.animate(ai_txt_node, "color.w", 1, gui.EASING_OUTCIRC, 0.3, 0, ai_text_in_complete)
end

local function ai_in_complete(self)
    audio:play("ai_in", 0.5)
    gui.play_flipbook(ai_head_node, hash("ai_in"), ai_head_in_complete)
end

function manager:init_anim(self)
    gui.animate(ai_container_node, "position.y", ai_container_start_pos.y, gui.EASING_OUTCIRC, 0.4, 0, ai_in_complete)
end

function manager:reset()
    acts = {}
    pop_node = nil
    pop_text_node = nil
    play_btn = nil
    speed_btn = nil
    pop_position = vmath.vector3()
    current_pop = 0
    start_drag = false
    curent_act = {}
    action_pos = vmath.vector3(0, 0, 0)
    layer_move = hash("move")
    layer_gfx = hash("gfx")
    is_speedup = false

    ai_container_node = nil
    ai_head_node = nil
    ai_txt_node = nil
    ai_container_start_pos = vmath.vector3()
    ai_container_size = vmath.vector3()
    ai_container_scale = vmath.vector3()
    ai_out_pos = vmath.vector3()
end

local function toggle_speed()
    for i = 1, #v.LEVEL_OBJECTS do
        if v.LEVEL_OBJECTS[i].object_id == 4 then
           -- pprint(v.LEVEL_OBJECTS[i].tile_go.url)
            msg.post(v.LEVEL_OBJECTS[i].tile_go.url, "toggle_walk_sound")
        end
    end

    if is_speedup then
        s.speedup = 1
        gui.play_flipbook(speed_btn, hash("speedx2_btn"))
        is_speedup = false
    else
        s.speedup = 2
        gui.play_flipbook(speed_btn, hash("speed_btn"))
        is_speedup = true
    end
    v.WALK_SPEED = s.walk_speed * s.speedup
    v.FALL_SPEED = s.fall_speed * s.speedup
    v.BULLET_SPEED = s.bullet_speed * s.speedup
end

local function toggle_play()
    if gs.fsm.current == "gameplay" then
        gui.play_flipbook(play_btn, hash("play_btn"))
        gs.fsm:pause()
    else
        gui.play_flipbook(play_btn, hash("pause_btn"))
        gs.fsm:play()
        for i = 1, #v.LEVEL_OBJECTS do
            if v.LEVEL_OBJECTS[i].object_id == 4 then
                -- p-- print(v.LEVEL_OBJECTS[i].tile_go.url)
                msg.post(v.LEVEL_OBJECTS[i].tile_go.url, "human_play")
            end
        end
    end
end

local function toogle_pop(status)
    gui.set_enabled(pop_node, status)
end

local function leave_act_btn()
    gui.animate(acts[current_pop].node, "scale", vmath.vector3(1, 1, 1), gui.EASING_LINEAR, 0.1)

    toogle_pop(false)

    current_pop = 0
end

local function enter_act_btn(act)
    current_pop = act.id

    local pos = vmath.vector3(act.screen_pos.x, pop_position.y, pop_position.z)
    
    gui.set_position(pop_node, pos)
    gui.set_text(pop_text_node, s.acts[act.id].name)

    toogle_pop(true)

    gui.animate(act.node, "scale", vmath.vector3(1.1, 1.1, 1.1), gui.EASING_LINEAR, 0.1)
end

local function pick_check(node, x, y)
    return gui.pick_node(node, x, y)
end

function manager:decerease(id)
    id = s.acts[id].id
    for i = 1, #acts do
        if acts[i].act_id == id then
            acts[i].count = acts[i].count - 1
            gui.set_text(acts[i].count_txt, acts[i].count)
        end
    end
end

function manager:collect(id)
    for i = 1, #acts do
        if acts[i].act_id == id then
            acts[i].count = acts[i].count + 1
            gui.set_text(acts[i].count_txt, acts[i].count)
        end
    end

    --[[     for i=1,s.act_count do
        if s.acts[i].id == id then
            -- p-- print(s.acts[i])
            s.acts[i].count = s.acts[i].count+1
            
            gui.set_text(s.acts[i].count_txt, s.acts[i].count)
        end
    end ]]
end

function manager:init()
    pop_node = gui.get_node("pop")
    pop_text_node = gui.get_node("pop_txt")
    pop_position = gui.get_position(pop_node)

    play_btn = gui.get_node("play_btn")
    replay_btn = gui.get_node("replay_btn")
    speed_btn = gui.get_node("speed_btn")
    toogle_pop(false)

    ai_container_node = gui.get_node("ai_container")
    ai_head_node = gui.get_node("ai_head")
    ai_txt_node = gui.get_node("ai_txt")
    ai_container_start_pos = gui.get_position(ai_container_node)
    ai_container_size = gui.get_size(ai_container_node)
    --pprint(ai_container_size)
    ai_container_scale = gui.get_scale(ai_container_node)

    ai_out_pos = vmath.vector3(ai_container_start_pos.x, ai_container_start_pos.y + (ai_container_size.y * ai_container_scale.y), ai_container_start_pos.z)
    gui.set_position(ai_container_node, ai_out_pos)

    local act_node = nil
    local act_count = nil
    local pos = vmath.vector3()
    local count = 0
    local temp_table = {}
    --[[

    TODO
    Level a gore ACT ve adetler  gelecek 

 ]]
    for i = 1, s.act_count do
        act_node = gui.get_node("act_" .. i)
        act_count = gui.get_node("act_" .. i .. "_count")

        pos = gui.get_position(act_node)
        screen_pos = gui.get_position(act_node)
        temp_table = {
            node = act_node,
            count_txt = act_count,
            count = count,
            pos = pos,
            screen_pos = screen_pos,
            id = i,
            act_id = s.acts[i].id
        }
        gui.set_text(act_count, count)
        table.insert(acts, temp_table)
    end
end

function manager:input(action_id, action)
    -- Pos for drag
    action_pos.x = action.x
    action_pos.y = action.y

    --Buttons
    if gui.pick_node(play_btn, action_pos.x, action_pos.y) and action.pressed then
        toggle_play()
    elseif gui.pick_node(speed_btn, action_pos.x, action_pos.y) and action.pressed then
        toggle_speed()
    elseif gui.pick_node(replay_btn, action_pos.x, action_pos.y) and action.pressed then
        gs.fsm:replay()
    end

    -- Drag
    if start_drag then
        gui.set_position(curent_act.node, action_pos)
        v.IS_POINTER_DRAG = true
        v.POINTER_POS = action_pos
    end

    -- Over
    if start_drag == false then
        for i = 1, s.act_count do
            if pick_check(acts[i].node, action_pos.x, action_pos.y) and current_pop ~= acts[i].id then
                enter_act_btn(acts[i])
            elseif pick_check(acts[i].node, action_pos.x, action_pos.y) == false and current_pop == acts[i].id then
                leave_act_btn()
            end
        end
    end
    -- Drag check
    if action_id == h.CLICK and action.pressed and start_drag == false then
        for i = 1, s.act_count do
            if pick_check(acts[i].node, action_pos.x, action_pos.y) and acts[i].count > 0 then
                toogle_pop(false)
                gui.set_layer(acts[i].node, layer_move)
                start_drag = true
                curent_act = acts[i]
            end
        end
    elseif action.released and start_drag then
        leave_act_btn()
        v.POINTER_POS = vmath.vector3(0, 0, 0)
        current_pop = 0
        start_drag = false

        gui.set_position(curent_act.node, curent_act.pos)
        gui.set_layer(curent_act.node, layer_gfx)
        v.IS_POINTER_DRAG = false
        if v.CURRENT_SIGN then
            msg.post(v.CURRENT_SIGN, "add_act", {act_id = curent_act.id})
        end
    end
end

return manager

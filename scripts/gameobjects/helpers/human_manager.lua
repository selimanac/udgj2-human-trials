local v = require("scripts.general.vars")
local s = require("scripts.general.settings")
local h = require("scripts.general.hashes")
local machine = require("scripts.libs.statemachine")
local audio = require("scripts.general.audio")

human = {}

local human_container = "container"
local human_sprite = "#sprite"
local sfx = {
    human_walk = "/sfx#human_walk",
    human_walk_fast = "/sfx#human_walk_fast"
}
-- Funcs
local set_position = go.set_position

local function play_walk_sound(walk, gain)
    sound.play(walk, {gain = gain})
end

local function stop_walk_sound(walk)
    sound.stop(walk)
end

local function draw_line(from, to)
    msg.post("@render:", "draw_line", {start_point = from, end_point = to, color = vmath.vector4(1, 0, 0, 1)})
end

function human:toggle_walk_sound(self)
    if self.is_fast == true then
        if self.fsm.current == "walking" then
            play_walk_sound(sfx.human_walk, 0.3)
            stop_walk_sound(sfx.human_walk_fast)
        end
        self.is_fast = false
    else
        if self.fsm.current == "walking" then
            play_walk_sound(sfx.human_walk_fast, 1)
            stop_walk_sound(sfx.human_walk)
        end
        self.is_fast = true
    end
end

function human:disable(self)
    msg.post("#c_left", "disable")
    msg.post("#c_right", "disable")
    msg.post("#chuman", "disable")
    msg.post("#sprite", "disable")
end

function human:check_queue(self, id)
    local q = #self.queue
    self.queue_id = 0
    if id == nil and q > 0 then
        self.queue_id = 1
        return true
    end
    for i = 1, q do
        if self.queue[i] == id then
            self.queue_id = i
            return true
        end
    end

    return false
end

function human:add_to_queue(self, id)
    table.insert(self.queue, id)
end

local function remove_from_queue(self, id)
    table.remove(self.queue, self.queue_id)
end

local function pause_complete(self)
    self.fsm:walk({self = self})

    if self.queue_id > 0 then
        remove_from_queue(self, self.queue_id)
    end
end

function human:dispatch_queue(self)
    local q = s.acts[self.queue[self.queue_id]]

    if q.name == "PUSH" then
        self.fsm:push({self = self})
    elseif q.name == "JUMP" then
        self.fsm:jump({self = self})
    elseif q.name == "PAUSE" then
        self.fsm:pause({self = self})
    elseif q.name == "FIRE" then
        self.fsm:fire({self = self})
    end
end

local function human_clone(self)
    v.OBJ_INDEX = v.OBJ_INDEX + 1
    local p = vmath.vector3(self.human_pos.x, self.human_pos.y, self.human_pos.z)
    local dir = 0
    if self.direction == s.direction.RIGHT then
        dir = -1
        p.x = p.x - 20
    else
        dir = 1
        p.x = p.x + 20
    end
    local props = {}
    props[hash("/human")] = {id = v.OBJ_INDEX, initial_direction = self.direction, is_clone = 1}
    local factory = "game:/factories#human"
    local obj = collectionfactory.create(factory, p, nil, props)

    local symbol_url = msg.url(obj[hash("/human")])
    symbol_url.fragment = "human"
    obj.url = symbol_url

    local temp_table = {
        id = v.OBJ_INDEX,
        object_id = 4,
        position = p,
        level = 0,
        name = "HUMAN",
        tile_go = obj,
        tile_x = 0,
        tile_y = 0,
        tile_id = 0,
        links = {
            from = {},
            to = {}
        }
    }

    table.insert(v.LEVEL_OBJECTS, temp_table)
    self.fsm:walk()
end

local function change_direction(self)
    if self.direction == s.direction.RIGHT then
        self.direction = s.direction.LEFT
        sprite.set_hflip(human_sprite, true)
        msg.post("#c_left", "enable")
        msg.post("#c_right", "disable")
    else
        self.direction = s.direction.RIGHT
        sprite.set_hflip(human_sprite, false)
        msg.post("#c_left", "disable")
        msg.post("#c_right", "enable")
    end
    self.raycats_x = self.raycats_x * -1
end

local function dying_complete()
    msg.post(".", "remove_human")
end

local function sprite_anim_complete(self)
    msg.post(self.msg_sender, "act_active")
    self.msg_sender = nil
    remove_from_queue(self, self.queue_id)
    self.msg_act = 0
    self.fsm:walk()
end

local function clone_init_complete(self)
    self.fsm:walk()
end

function human:init_clone(self)
    sprite.play_flipbook(human_sprite, s.anim.clone, clone_init_complete)
end

local function change_anim(anim, on_complete)
    sprite.play_flipbook(human_sprite, anim, on_complete)
end

local function draw_back_complete(self)
    remove_from_queue(self, self.queue_id)
    self.fsm:walk()
end

local function draw_anim_complete(self)
    local pos = vmath.vector3()
    pos.x = self.human_pos.x + (8 * self.direction)
    pos.y = self.human_pos.y + 3
    pos.z = 0.2
    factory.create("/factories#bullet", pos, nil, {direction = self.direction})
    change_anim(s.anim.draw_back, draw_back_complete)
end

local function jump_complete(self)
    self.human_pos = go.get_position(human_container)
    self.human_pos_x = self.human_pos.x
    self.fsm:walk()
    if self.queue_id > 0 then
        remove_from_queue(self, self.queue_id)
    end
end

local function jump_air_complete(self)
    audio:play("human_land")
    change_anim(hash("man_jump_ground"), jump_complete)
end

local function jump_start_complete(self)
    change_anim(hash("man_jump_air"), nil)
    go.animate(human_container, "position", go.PLAYBACK_ONCE_FORWARD, vmath.vector3(self.human_pos.x + (15 * self.direction), self.human_pos.y, self.human_pos.z), go.EASING_INSINE, 0.2, 0, jump_air_complete)
end

local function start_jump(self)
    change_anim(hash("man_jump_start"), nil)
    go.animate(human_container, "position", go.PLAYBACK_ONCE_FORWARD, vmath.vector3(self.human_pos.x + (10 * self.direction), self.human_pos.y + 10, self.human_pos.z), go.EASING_OUTCIRC, 0.3, 0, jump_start_complete)
end

local function fall_start_complete(self)
    change_anim(hash("man_fall_air"), nil)
    self.human_pos = go.get_position(human_container)
    self.human_pos_x = self.human_pos.x
    self.human_pos_y = self.human_pos.y

    self.is_falling = true
end

local function start_fall(self)
    audio:play("human_jump_start")
    change_anim(hash("man_fall_start"), nil)
    go.animate(human_container, "position", go.PLAYBACK_ONCE_FORWARD, vmath.vector3(self.human_pos.x + (10 * self.direction), self.human_pos.y + 10, self.human_pos.z), go.EASING_OUTSINE, 0.4, 0, fall_start_complete)

    self.human_pos.x = self.human_pos.x + (10 * self.direction)
    self.human_pos.y = self.human_pos.y + 10
end

-- *****************
--  State funcs
-- *****************
local function on_enter_standing(self, event, from, to, event_msg)

    change_anim(s.anim.idle, nil)
end

local function on_enter_walking(self, event, from, to, event_msg)
    if self.is_fast == true then
        play_walk_sound(sfx.human_walk, 0.3)
        stop_walk_sound(sfx.human_walk_fast)
    else
        play_walk_sound(sfx.human_walk_fast, 1)
        stop_walk_sound(sfx.human_walk)
    end

    change_anim(s.anim.walk, nil)
end

local function on_leave_walking(self, event, from, to, event_msg)
    stop_walk_sound(sfx.human_walk)
    stop_walk_sound(sfx.human_walk_fast)
end

local function on_enter_pushing(self, event, from, to, event_msg)
    event_msg.self.msg_sender = event_msg.sender
    event_msg.self.msg_act = event_msg.act
    audio:play("human_push")
    change_anim(s.anim.push, sprite_anim_complete)
end

local function on_enter_cloning(self, event, from, to, event_msg)
    audio:play("human_clone")
    event_msg.self.fsm:idle()
    human_clone(event_msg.self)
end

local function on_enter_turning(self, event, from, to, event_msg)
    change_direction(event_msg.self)
    event_msg.self.fsm:walk()
end

local function on_enter_pausing(self, event, from, to, event_msg)
    change_anim(hash("man_idle"), nil)
    timer.delay(1, false, pause_complete)
end

local function on_enter_firing(self, event, from, to, event_msg)
    change_anim(s.anim.draw, draw_anim_complete)
end

local function on_enter_jumping(self, event, from, to, event_msg)
    audio:play("human_jump_start")
    start_jump(event_msg.self)
end

local function on_enter_transfering(self, event, from, to, event_msg)
    event_msg.self.msg_sender = event_msg.sender
    event_msg.self.msg_act = event_msg.act
    if event_msg.self.msg_act == "TELEPORT" then
        local id = event_msg.targets[1]
        local g = v.LEVEL_OBJECTS[id].tile_go

        if v.LEVEL_OBJECTS[id].level > v.CURRENT_LEVEL then
            v.CURRENT_LEVEL = v.CURRENT_LEVEL + 1
            msg.post(s.scenes.GameGUI, "init_anims")
            v.LEVEL_COUNTER = v.LEVEL_COUNTER + 1
            if v.LEVEL_COUNTER == 3 then
                local cam_pos = go.get_position(h.CAMERA)
                go.animate(h.CAMERA, "position.y", go.PLAYBACK_ONCE_FORWARD, cam_pos.y + 128, go.EASING_OUTCIRC, 2)
                v.LEVEL_COUNTER = 1
            end
        end

        local p = go.get_position(g)
        msg.post("#c_left", "disable")
        msg.post("#c_right", "disable")
        msg.post("#chuman", "disable")
        event_msg.self.human_pos.x = p.x + 3
        event_msg.self.human_pos.y = p.y - 2
        event_msg.self.human_pos_x = event_msg.self.human_pos.x
        set_position(event_msg.self.human_pos, human_container)
        msg.post(human_sprite, "disable")
        audio:play("human_teleport_in")
    elseif event_msg.self.msg_act == "TELEPORT_IN" then
        msg.post("#c_left", "enable")
        msg.post("#c_right", "enable")
        msg.post("#chuman", "enable")
        msg.post(human_sprite, "enable")
        event_msg.self.fsm:walk()
    end
end

local function on_enter_dying(self, event, from, to, event_msg)
    audio:play("human_death", 0.5)
    audio:play("human_nutralised")
    if from == "falling" then
        self.human_pos = go.get_position(human_container)
        self.human_pos.y = self.human_pos.y - 5
        go.set_position(self.human_pos, human_container)
    end
    change_anim(s.anim.die, dying_complete)
end

local function on_enter_falling(self, event, from, to, event_msg)
    start_fall(event_msg.self)
end

function human:init(self, dir)
    self.direction = dir
    if self.is_clone == 1 then
        change_direction(self)
    end
    self.human_pos = go.get_position(human_container)

    self.human_pos_x = self.human_pos.x

    -- Game State
    self.fsm =
        machine.create(
        {
            events = {
                {name = "idle", from = "*", to = "standing"},
                {name = "walk", from = "*", to = "walking"},
                {name = "push", from = "walking", to = "pushing"},
                {name = "pause", from = "walking", to = "pausing"},
                {name = "hide", from = "walking", to = "hiding"},
                {name = "clone", from = "walking", to = "cloning"},
                {name = "turn", from = "walking", to = "turning"},
                {name = "fire", from = "walking", to = "firing"},
                {name = "jump", from = "walking", to = "jumping"},
                {name = "teleport", from = {"transfering", "walking"}, to = "transfering"},
                {name = "die", from = {"falling", "walking"}, to = "dying"},
                {name = "fall", from = "walking", to = "falling"}
            },
            callbacks = {
                on_enter_standing = on_enter_standing,
                on_enter_walking = on_enter_walking,
                on_leave_walking = on_leave_walking,
                on_enter_pushing = on_enter_pushing,
                on_enter_pausing = on_enter_pausing,
                on_enter_cloning = on_enter_cloning,
                on_enter_turning = on_enter_turning,
                on_enter_firing = on_enter_firing,
                on_enter_jumping = on_enter_jumping,
                on_enter_transfering = on_enter_transfering,
                on_enter_dying = on_enter_dying,
                on_enter_falling = on_enter_falling
            }
        }
    )
end

function human:update(self, dt)
    if v.GAME_PAUSED then
        return
    end

    if self.is_falling then
        v.FALL_SPEED = v.FALL_SPEED + 5
        self.human_pos_y = self.human_pos_y - (v.FALL_SPEED * dt)
        self.human_pos.y = self.human_pos_y

        set_position(self.human_pos, human_container)
    end

    if self.fsm.current == "walking" then
        self.human_pos_x = self.human_pos_x + ((v.WALK_SPEED * dt) * self.direction)
        self.human_pos.x = self.human_pos_x

        set_position(self.human_pos, human_container)
    end

    if self.fsm.current ~= "dying" then
        self.raycast_to.x = self.human_pos.x + self.raycats_x
        self.raycast_to.y = self.human_pos.y - 20

        physics.raycast_async(self.human_pos, self.raycast_to, {h.C_GROUND}) -- Cause a problem on pause
    end

    if s.is_debug_physic then
        draw_line(self.human_pos, self.raycast_to)
    end
end

function human:turn(self)
    change_direction(self)
end

function human:get_direction(self)
    return self.direction
end

return human

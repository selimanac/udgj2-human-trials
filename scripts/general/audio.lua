
local s = require("scripts.general.settings")

local audio = {}

local audio = {
    act_fence = "/sfx#fence",
    human_death = "/sfx#human_death",
    human_nutralised = "/sfx#human_nutralised",
    human_push = "/sfx#human_push",
    human_teleport_in = "/sfx#human_teleport_in",
    human_teleport_out = "/sfx#human_teleport_out",
    laser_human = "/sfx#laser_human",
    laser_robot = "/sfx#laser_robot",
    human_pick = "/sfx#human_pick",
    human_add = "/sfx#human_add",
    act_pick = "/sfx#act_pick",
    laser_human = "/sfx#laser_human",
    laser_robot = "/sfx#laser_robot",
    human_clone = "/sfx#human_clone",
    ai_speak = "/sfx#ai_speak",
    robot_destroy = "/sfx#robot_destroy",
    ai_in = "/sfx#ai_in",
    ai_out = "/sfx#ai_out",
    human_jump_start = "/sfx#human_jump_start",
    human_land = "/sfx#human_land",
    act_explode =  "/sfx#act_explode",

}

function audio:music_play(audio_name, audio_gain)
    if audio_gain == nil then
        audio_gain = 1
    end
    if s.is_dev == false then
        msg.post("/scripts#soundgate", "play_gated_sound", {soundcomponent = audio[audio_name], gain = audio_gain})
    end
end

function audio:play(audio_name, audio_gain)
    if audio_gain == nil then
        audio_gain = 1
    end
    if s.is_dev == false then
        msg.post("/scripts#soundgate", "play_gated_sound", {soundcomponent = audio[audio_name], gain = audio_gain})
    end
end

function audio:music_stop(audio_name)
    sound.stop(audio[audio_name])
end

function audio:stop(audio_name)
    sound.stop(audio[audio_name])
end

return audio

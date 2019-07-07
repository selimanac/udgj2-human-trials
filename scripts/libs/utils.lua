local s = require("scripts.general.settings")
local v = require("scripts.general.vars")

utils = {}

local human_url = msg.url()

function utils:human_url(id)
    human_url = msg.url(id)
    human_url.fragment = "human"
    return human_url
end

function utils:unrequire(m)
    package.loaded[m] = nil
    _G[m] = nil
end

function utils:kick_links(id)
    local temp_links = v.LEVEL_OBJECTS[id].links.to

    local target_ids = {}
    for i = 1, #temp_links do
        table.insert(target_ids, temp_links[i].id)
        msg.post(v.LEVEL_OBJECTS[temp_links[i].id].tile_go, "obj_active")
    end
    return target_ids
end

function utils:get_tile_position(v, offset, tilemap_offset)
    tilemap_offset = vmath.vector3(tilemap_offset.x - offset.x, tilemap_offset.y - offset.y, 0)
    local pos = vmath.vector3((v.x * s.tile_size) - (s.tile_size / 2) + tilemap_offset.x, (v.y * s.tile_size) - (s.tile_size / 2) + tilemap_offset.y, v.z)
    return pos
end

return utils

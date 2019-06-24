local s = require("scripts.general.settings")

utils = {}

function utils:get_tile_position(v, ox, oy, tilemap_offset)
    tilemap_offset = vmath.vector3(tilemap_offset.x - ox, tilemap_offset.y - oy, 0)

    local pos = vmath.vector3((v.x * s.tile_size) - (s.tile_size / 2) + tilemap_offset.x, (v.y * s.tile_size) - (s.tile_size / 2) + tilemap_offset.y, v.z)

    return pos
end

return utils

local s = require("scripts.general.settings")
local utils = require("scripts.libs.utils")

tiles = {}

local wall_height = 2
local wall_start = 3
local level = 0
local tilemap_offset = vmath.vector3(0, 0, 0)
local level_content = {}
local level_count = 1
local current_level = 1

local factories = {
    factory.create,
    collectionfactory.create
}

local function update_level()
    if level_count > wall_height then
        level_count = 1
        current_level = current_level + 1
    end
    level_count = level_count + 1
end

local function dispatch_object(tile, pos)

    factories[tile.factory_type](tile.factory, pos)

end

function tiles:init()
    local x, y, w, h = tilemap.get_bounds("/tilemap#level_1")
    print(x,y,w,h)
    local tile_id = 0
    local temp_table = {}
    local temp_pos = vmath.vector3()
    local temp_tile = {}
    tilemap_offset = go.get_position("tilemap")

    for tile_y = 1, h do
        if tile_y > wall_start then
            update_level()
        end
        for tile_x = 1, w do
            if tile_y > wall_start then
                tile_id = tilemap.get_tile("/tilemap#level_1", "objects", tile_x, tile_y)

                for i = 1, s.objects_count do
                    if s.tile_objects[i].id == tile_id then
                        temp_tile = s.tile_objects[i]
                        temp_pos.x = tile_x
                        temp_pos.y = tile_y
                        temp_pos.z = 0.2
                        temp_pos = utils:get_tile_position(temp_pos, temp_tile.offset_x, temp_tile.offset_y, tilemap_offset)
                        temp_table = {
                            id = 1,
                            object_id = temp_tile.id,
                            position = temp_pos,
                            level = current_level,
                            name = s.objects[i]
                        }
                        table.insert(level_content, temp_table)
                        dispatch_object(temp_tile, temp_pos)
                    end
                end
            end
        end
    end
  --  pprint(level_content)
end

return tiles

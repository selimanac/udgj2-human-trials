local s = require("scripts.general.settings")
local utils = require("scripts.libs.utils")
local v = require("scripts.general.vars")
local level = require("scripts.general.levels")

tiles = {}

local wall_height = 2
local wall_start = 3
local level = 0
local tilemap_offset = vmath.vector3(0, 0, 0)

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

local function dispatch_object(tile, pos, obj_id, index)
    local obj = nil

    if tile.factory_type == 2 then
        local props = {}
        props[hash("/human")] = {id = index}

        obj = factories[2](tile.factory, pos, nil, props)

        local symbol_url = msg.url(obj[hash("/human")])
        symbol_url.fragment = "human"
        obj.url = symbol_url
    else
        obj = factories[1](tile.factory, pos, nil, {id = index, obj_id = obj_id})
    end
    return obj
end

function tiles:init()
    local x, y, w, h = tilemap.get_bounds("/tilemap#level_1")
    local tile_id = 0
    local temp_table = {}
    local temp_pos = vmath.vector3()
    local temp_tile = {}
    local tile_go = nil

    tilemap_offset = go.get_position("tilemap")

    for tile_y = 1, h do
        if tile_y > wall_start then
            update_level()
        end
        for tile_x = 1, w do
            if tile_y > wall_start then
                tile_id = tilemap.get_tile("/tilemap#level_1", "objects", tile_x, tile_y)

                for i = 1, s.objects_count do
                    temp_tile = s.tile_objects[i]
                    if temp_tile.id == tile_id then
                        v.OBJ_INDEX = v.OBJ_INDEX + 1

                        temp_pos.x = tile_x
                        temp_pos.y = tile_y
                        temp_pos.z = temp_tile.offset.z
                        temp_pos = utils:get_tile_position(temp_pos, temp_tile.offset, tilemap_offset)
                        tile_go = dispatch_object(temp_tile, temp_pos, temp_tile.id, v.OBJ_INDEX)

                        temp_table = {
                            id = v.OBJ_INDEX,
                            object_id = temp_tile.id,
                            position = temp_pos,
                            level = current_level,
                            name = s.objects[i],
                            tile_go = tile_go,
                            tile_x = tile_x,
                            tile_y = tile_y,
                            tile_id = tonumber(tile_x .. tile_y),
                            links = {
                                from = {},
                                to = {}
                            }
                        }
                        table.insert(v.LEVEL_OBJECTS, temp_table)
                    end
                end
            end

            tile_id = tilemap.get_tile("/tilemap#level_1", "walls", tile_x, tile_y)
            for i = 1, s.walls_count do
                temp_tile = s.tile_walls[i]
                if temp_tile.id == tile_id then
                    temp_pos.x = tile_x
                    temp_pos.y = tile_y
                    temp_pos.z = temp_tile.offset.z
                    temp_pos = utils:get_tile_position(temp_pos, temp_tile.offset, tilemap_offset)
                    tile_go = dispatch_object(temp_tile, temp_pos)

                    temp_table = {
                        id = i,
                        object_id = temp_tile.id,
                        position = temp_pos,
                        level = current_level,
                        name = s.walls[i],
                        tile_go = tile_go
                    }
                    table.insert(v.LEVEL_WALLS, temp_table)
                end
            end
            -- End
        end
    end

    -- print("Level adet: ", level_count)
    -- LEvellar için çevir
    for l = 1, #levels.relations do
        -- Level içindeki ilişkiler için çevir
        for items = 1, #levels.relations[l] do
            -- p-- print(levels.relations[l][items].from)
            -- To'nun karşılığını bul
            for obj = 1, #v.LEVEL_OBJECTS do
                if v.LEVEL_OBJECTS[obj].tile_id == levels.relations[l][items].from then
                    for to = 1, #levels.relations[l][items].to do
                        for to_obj = 1, #v.LEVEL_OBJECTS do
                            if v.LEVEL_OBJECTS[to_obj].tile_id == levels.relations[l][items].to[to] then
                                local temp_table = {
                                    id = v.LEVEL_OBJECTS[to_obj].id,
                                    object_id = v.LEVEL_OBJECTS[to_obj].object_id
                                }

                                table.insert(v.LEVEL_OBJECTS[obj].links.to, temp_table)
                            end
                        end
                    end
                    v.LEVEL_OBJECTS[obj].links.from = {
                        id = v.LEVEL_OBJECTS[obj].id,
                        object_id = v.LEVEL_OBJECTS[obj].object_id
                    }
                end
            end
        end
    end
    -- p-- print(v.LEVEL_OBJECTS)
end

return tiles


local lg = love.graphics

--Define types by integer indexes imported from the map file.
local Types = {}
local cell = {}
cell.__index = cell
function cell:new( id, x, y, tp)
    local c = {
        id = id,
        x = x,
        y = y,
        type = tp,
    }
    return setmetatable(c, cell)
end
function cell:getPosition()
    return self.x, self.y
end

local load_map = function(file_name)
    local map_file = require(file_name)
    local cell_map = {}
    for layer=1,#map_file.layer do
        cell_map[layer] = {}
        for x=1,map_file.width do
            for y=1,map_file.height do
                if map_file.layer[layer][x][y] == 1 then
                    local id = x..','..y
                    cell_map[layer][id] = cell:new(id,x,y,"floor")
                    print(cell_map[layer][id]:getPosition())
                end
            end
        end
    end
    return cell_map
end
local MAP = {
    get_cell_by_id = function(self, id)
        return self.gridmap[ id] or false
    end,
    get_cell_at = function(self, x,y)
        return self.gridmap[x..','..y] or {type="wall"}
    end,
    is_walkable = function(self, x,y)
        local c = self.gridmap[x..','..y]
        return c and c.walkable or false
    end,
    init=function(self,file_name)
        self.gridmap = load_map(file_name)
        return self
    end,
    iterate_cells = function( self, fun)
        for layer=#self.gridmap,1,-1 do
            for _,c in pairs(self.gridmap[layer]) do
                fun(c.x, c.y, layer )
            end
        end
    end,
    draw = function( self)

    end,
}
return MAP
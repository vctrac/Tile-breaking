
-------------------------------------------------------------------------------------------------
--  ▄▄       ▄▄       ▄▄▄▄▄▄▄▄▄▄▄       ▄▄▄▄▄▄▄▄▄▄▄ 
-- ▐░░▌     ▐░░▌     ▐░░░░░░░░░░░▌     ▐░░░░░░░░░░░▌
-- ▐░▌░▌   ▐░▐░▌     ▐░█▀▀▀▀▀▀▀█░▌     ▐░█▀▀▀▀▀▀▀█░▌
-- ▐░▌▐░▌ ▐░▌▐░▌     ▐░▌       ▐░▌     ▐░▌       ▐░▌
-- ▐░▌ ▐░▐░▌ ▐░▌     ▐░█▄▄▄▄▄▄▄█░▌     ▐░█▄▄▄▄▄▄▄█░▌
-- ▐░▌  ▐░▌  ▐░▌     ▐░░░░░░░░░░░▌     ▐░░░░░░░░░░░▌
-- ▐░▌   ▀   ▐░▌     ▐░█▀▀▀▀▀▀▀█░▌     ▐░█▀▀▀▀▀▀▀▀▀ 
-- ▐░▌       ▐░▌     ▐░▌       ▐░▌     ▐░▌          
-- ▐░▌       ▐░▌     ▐░▌       ▐░▌     ▐░▌          
-- ▐░▌       ▐░▌     ▐░▌       ▐░▌     ▐░▌          
--  ▀         ▀       ▀         ▀       ▀       

local class = require "../library/classic"

-- local sw, sh = GAME.img.tileset:getWidth(), GAME.img.tileset:getHeight()
-- local ts = 32
-- local quads = {
--     dirt = love.graphics.newQuad( 64, 0, ts, ts, sw, sh ),
--     stone = love.graphics.newQuad( 32, 0, ts, ts, sw, sh ),
--     rock = love.graphics.newQuad( 32, 32, ts, ts, sw, sh ),
--     gravel = love.graphics.newQuad( 96, 32, ts, ts, sw, sh ),
--     void = love.graphics.newQuad( 128, 352, ts, ts, sw, sh ),
--     air = love.graphics.newQuad( 128, 352, ts, ts, sw, sh ),
--     sun = love.graphics.newQuad( 128, 0, ts, ts, sw, sh ),
-- }
local new_type = function(name, bg_img, opacity, durability, breakable, solid, visible)
    return { name = name, bg = bg_img, opacity = opacity, durability = durability, breakable = breakable, solid = solid, visible = visible}
end
local TILE_TYPE = {
    sun = new_type( 'air', 'air', 0, 0),
    void = new_type( 'air', 'air', 0, 0),
    air = new_type( 'air', 'air', 0.1, 0),
    dirt = new_type( 'dirt', 'dirt', 1, 3, true, true, true),
    gravel = new_type( 'gravel', 'gravel', 1, 3, true, true, true),
    blocker = new_type( 'blocker', 'air', 0.7, 5, true, true, true),
    stone = new_type( 'stone', 'stone', 1, 8, true, true, true),
    rock = new_type( 'rock', 'rock', 1, 8, true, true, true),
    emiter = new_type( 'air', 'air', 0, 1, true),
}
local DROPS = {
    dirt = { 'bones', 'dung'},
    gravel = { 'coal', 'stone'},
    stone = { 'stone', 'stone', 'coal'},
    rock = { 'coal', 'coal', 'iron', 'stone', 'iron', 'gold'},
}
-- local TILE_TYPE = {
--     sun = { name = 'air', bg = 'air', opacity = 0, durability = 0, unbreakable = true, visible = false},
--     void = { name = 'air', bg = 'air', opacity = 0, durability = 0, visible = false},
--     air = { name = 'air', bg = 'air', opacity = 0.1, durability = 0, visible = false},
--     dirt = { name = 'dirt', bg = 'dirt', opacity = 1, durability = 3, solid = true, visible = true},
--     gravel = { name = 'gravel', bg = 'gravel', opacity = 1, durability = 3, solid = true, visible = true},
--     blocker = { name = 'blocker', bg = 'air', opacity = 0.5, durability = 5, solid = true, visible = true},
--     stone = { name = 'stone', bg = 'stone', opacity = 1, durability = 8, solid = true, visible = true},
--     rock = { name = 'rock', bg = 'rock', opacity = 1, durability = 8, solid = true, visible = true},
--     emiter = { name = 'air', bg = 'air', opacity = 0, durability = 1, visible = false},
-- }
local function to_id(x,y)     
    return (x .. ', '..y)
end
local function id_to_coord( id)
    local t = {}
    for num in string.gmatch(id, '([^,]+)') do
        table.insert(t, tonumber(num))
    end 
    return unpack(t)
end
local cell = class:extend()
function cell:new( world, x, y, w, h, id)
    self.id = id or 'air'
    self.x = x or 0
    self.y = y or 0
    self.w = w
    self.h = h
    self.light = 0
    if TILE_TYPE[ id].solid then
        self.world = world
        self.world:add(self, (-1+x)*32,(-1+y)*32,w,h)
    end
    self.r = 0
    self.g = 0
    self.b = 0
end
function cell:set_light( n) self.light = math.clamp(0, n, 1)
end
function cell:is_emiter( ) return self.emiter
end
function cell:get_color( ) return {self.r*self.light, self.g*self.light, self.b*self.light}
end
function cell:get_id( ) return self.id
end
function cell:get_position( ) return self.x, self.y
end
function cell:destroy()
    if self.world then
        self.world:remove(self)
    end

end
local cell_types = {'dirt','rock','stone','gravel'}

local emiters = {}

local GENERATE = function( table) -------------------------------TODO

end

local Map = {
    tile_size = 32,
    tile_size_half = 16,
    units = {},
    new = function( self, w, h)
        self.grid_cells = {w, h}
        self.w = w * self.tile_size
        self.h = h * self.tile_size
        for x=1,w do
            for y=1,h do
                
                local id = y>15 and cell_types[math.random(#cell_types)] or 'void'
                -- local c =  cell(x,y,id)
                -- if 
                -- GAME.world:add(c, x,y, self.tile_size, self.tile_size)
                -- self.units[ to_id(x,y)] = c
                self.units[ to_id(x,y)] = cell(GAME.world, x,y,self.tile_size,self.tile_size,id)

                -- if y<=5 then
                --     self.units[ to_id(x,y)]:set_opacity(0)
                --     -- self.units[ to_id(x,y)]:set_unbreakable()
                -- end
            end
        end
        
        return self
    end,
    draw = function( self, wx,wy)
        ------------------------------------draw background tiles
        lg.setColor(0.7,0.7,0.8)
        for n,s in pairs( self.units) do
            local id = s:get_id()
            if s.light<=0 or id == 'void' or id == 'sun' then goto next end
            local x,y = (s.x-1)*self.tile_size, (s.y-1)*self.tile_size
            if box_collision( x,y,self.tile_size,self.tile_size, wx,wy, screen.w, screen.h) then
                lg.draw( GAME.img.tileset, GAME.quads[self.get_info( id, 'bg')], x+3, y+3)
            end
            ::next::
        end
        ------------------------------------draw foreground tiles
        lg.setColor(1,1,1)
        for n,s in pairs( self.units) do
            if s.light<=0 or not TILE_TYPE[ s:get_id() ].visible then goto next end
            local x,y = (s.x-1)*self.tile_size, (s.y-1)*self.tile_size
            if box_collision( x,y,self.tile_size,self.tile_size, wx,wy, screen.w, screen.h) then
                
                lg.draw( GAME.img.tileset, GAME.quads[self.get_name(s:get_id())], x, y)
            end
            ::next::
        end
    end,
    draw_light = function( self, wx,wy)
        ------------------------------------draw light tiles
        love.graphics.setBlendMode("multiply", 'premultiplied')
        for n,s in pairs( self.units) do
            if s:get_id() == 'void' then goto next end
            local x,y = (s.x-1)*self.tile_size, (s.y-1)*self.tile_size
            if box_collision( x,y,self.tile_size,self.tile_size, wx,wy, screen.w, screen.h) then
                lg.setColor( s:get_color())
                lg.rectangle( "fill", x, y, self.tile_size, self.tile_size)
            end
            ::next::
        end
        love.graphics.setBlendMode("alpha")
    end,
    grid_to_world = function(self, x,y)
        if type(x)=='string' then
            x,y = id_to_coord(x)
        end
        return (x-1)*self.tile_size, (y-1)*self.tile_size
    end,
    world_to_grid = function(self, x,y)
        return math.ceil(x/self.tile_size), math.ceil(y/self.tile_size)
    end,
    set_tile = function( self, x,y, type)
        local tid = to_id(x,y)
        if self.units[tid] then
            self.units[tid] = cell(GAME.world,x,y,self.tile_size,self.tile_size,type)
            -- GAME.world:add(item, x,y,w,h)
        end
        return self.units[tid]
    end,
    -- get_center = function( self, x,y)
    --     local tid = to_id(x,y)
    --     return self.units[tid]
    -- end,
    get_tile = function( self, x,y)
        local tid = to_id(x,y)
        return self.units[tid]
    end,
    get_tile_id = function( self, x,y)
        local tid = to_id(x,y)
        return self.units[tid].id
    end,
    is_lighted = function( self, x, y)
        local t = self:get_tile(x,y)
        if t then
            return t.light>0.1
        end
    end,
    has_item = function( self, x, y)
        -- print(x, y)
        local t = self:get_tile(x,y)
        if t then
            return t.item
        end
    end,
    get_info = function( id, info)
        local t = TILE_TYPE[id]
        if t then
            return TILE_TYPE[id][info]
        end
    end,
    get_name = function( id)
        local t = TILE_TYPE[id]
        if t then
            return TILE_TYPE[id].name
        end
    end,
    is_solid = function( id)
        local t = TILE_TYPE[id]
        if t then
            return TILE_TYPE[id].solid
        end
    end,
    is_breakable = function( id)
        local t = TILE_TYPE[id]
        if t then
            return TILE_TYPE[id].breakable
        end
    end,
    get_neighbours = function( self, tx,ty) -- return neighbours tile, { (0,-1), (-1,0), (1,0), (0,1)}, if there is any.
        local nei = {}
        for y=-1,1 do
            for x=-1,1 do
                if math.abs(x)+math.abs(y)==1 then
                    local t = self:get_tile(tx+x,ty+y)
                    if t then table.insert(nei, t) end
                end
            end
        end
        return nei
    end,
    insert_tile = function( self, x,y, type)
        local t = self:get_tile( x,y)

        -- print(t.id)
        if t.id ~= 'air' then return false end
        -- print("up up UP!")

        local nt = self:get_neighbours( x, y)
        local solid_near = false
        for i,k in ipairs(nt) do
            if TILE_TYPE[k:get_id()].solid then
                solid_near = true
            end
        end
        if not solid_near then return false end
        -- print(type, 'solid near == true')
        self:set_tile( x,y, type or 'dirt')
        self:update_lights( )
        GAME.sfx.place_block:play()

        return true
    end,
    -- hit_tile = function( self, x,y, force)
    --     local t = self:get_tile(x,y)
    --     if t:is_emiter() then goto ::skip:: end
    --     if not (t:is_solid() and t:is_breakable()) then return end


    -- end,
    break_tile = function( self, x,y)
        local t = self:get_tile(x,y)
        if not self.is_breakable(t:get_id()) then return end

        if t:is_emiter() then
            self:remove_light(x,y)
        elseif TILE_TYPE[t:get_id()].solid then
            local drops = DROPS[ t:get_id()]
            print('tile set to air')
            t:destroy()
            self:set_tile( x,y, 'air')
            GAME.sfx.block_break:play()
            self:update_lights( )

            if drops then
                local n = #drops
                local rn = math.ceil( math.random(n+1)*math.random())-1
                -- if rn>0.1 and drops[rn] then
                if drops[rn] then
                    local nx, ny = self:grid_to_world( t.x, t.y)
                    Timer.after(0.1, function() GAME.drop_item(drops[rn], nx, ny) end)
                end
            end
        end
    end,
    update_lights = function( self )
        for i,k in pairs(self.units) do
            k:set_light(0)
        end
        local rm = {}
        for n,lit in pairs(emiters) do
            local x,y = id_to_coord(lit.id)
            local tile = self:get_tile(x,y)
            if not tile.emiter then rm[#rm+1] = n else
                local color = {tile.r, tile.g, tile.b}
                self:update_tile_light(x, y, tile.force, color)
            end
        end
        -- print(#rm)
        for i=0,#rm-1 do
            table.remove(emiters, rm[#rm-i])
        end
    end,
    add_sun = function( self, x,y,light_level,color)
        local t = self:get_tile( x,y)
        
        if t.id ~= 'void' then return end
        
        t = self:set_tile( x, y, 'sun')

        t:set_light(1)
        t.emiter = true
        t.force = light_level or 1

        local c = color or {}
        t.r = c[1] or 1
        t.g = c[2] or 1
        t.b = c[3] or 1

        table.insert(emiters, {id=to_id(x,y), c=color})
        self:update_lights( )
        
    end,
    add_light = function( self, x,y,light_level,color)
        local t = self:get_tile( x,y)
        
        if t.id ~= 'air' then return end
        
        t = self:set_tile( x, y, 'emiter')

        t:set_light(1)
        t.emiter = true
        t.force = light_level or 1

        local c = color or {}
        t.r = c[1] or 1
        t.g = c[2] or 1
        t.b = c[3] or 1

        table.insert(emiters, {id=to_id(x,y), c=color})
        self:update_lights( )
        GAME.sfx.place_block:play()
        return t
    end,
    remove_light = function( self, x,y)
        local t = self:get_tile( x,y)
        if not t.emiter or t:get_id() == 'sun' then return end
        local t = self:set_tile(x,y,'air')
        self:update_lights( )

        return t
    end,
    update_neighbours = function( self, x, y, light_level, color)
        self:update_tile_light(x, y - 1, light_level, color)
        self:update_tile_light(x, y + 1, light_level, color)
        self:update_tile_light(x - 1, y, light_level, color)
        self:update_tile_light(x + 1, y, light_level, color)
    end,
    update_tile_light = function( self, x, y, light_level, color)
        local t = self:get_tile( x,y)
        if t and (light_level > t.light) then
            t.light = light_level
            if not t.emiter then
                t.r = color[1]
                t.g = color[2]
                t.b = color[3]
            end
            self:update_neighbours(x, y, light_level - TILE_TYPE[t:get_id()].opacity, color)
        end
    end,
    get_lights = function( self)
        return emiters
    end
}

return Map
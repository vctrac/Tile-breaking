
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
local Map = {
    units = {}
}
-- local g3d = require "g3d"
-- local tile3d = g3d.newModel("res/obj/cube.obj", "res/img/moon.png", {0,0,1}, nil, {0.1,0.1,0.1})
-- local myShader = love.graphics.newShader("shader.fs")

local lg = love.graphics
local new_type = function(name, opacity, durability, breakable, solid, invisible)
    return { name = name, opacity = opacity, durability = durability, breakable = breakable, solid = solid, visible = not invisible}
end
local TILE_TYPE = {
    air = new_type( 'air', 0.1, 0,false,false,true),
    dirt = new_type( 'dirt', 1, 3, true, true),
    gravel = new_type( 'gravel', 1, 3, true, true),
    grass = new_type( 'grass', 1, 3, true, true),
    blocker = new_type( 'blocker', 0.7, 5, true, true),
    stone = new_type( 'stone', 1, 8, true, true),
    rock = new_type( 'rock', 1, 8, true, true),
}
local TILE_COLOR = {
    dirt = {0.33,0.19,0.1},
    grass = {0.2,0.23,0.12},
    air = {0.1,0.25,0.3},
    stone = {0.25,0.22,0.21},
}
local DROPS = {
    dirt = { 'bones', 'dung'},
    gravel = { 'coal', 'stone'},
    stone = { 'stone', 'stone', 'coal'},
    rock = { 'coal', 'coal', 'iron', 'stone', 'iron', 'gold'},
}

local cell = Lib.class:extend()
function cell:new( x, y, w, h, id)
    self.id = id or 'air'
    self.x = x or 0
    self.y = y or 0
end
function cell:get_id( ) return self.id
end
function cell:get_position( ) return self.x, self.y
end
-- function cell:destroy()
    -- if self.world then
        -- self.world:remove(self)
    -- end
-- end

local cell_types = {'dirt','stone'}

local blurShader2 = love.graphics.newShader("blur2.fs")

local tile_size = GAME.tile_size
local ground_start = 1
local layers_num = 10
local depth_3D = -0.004
-- local border_size = 6
-- local GENERATE = function( table) -------------------------------TODO

-- end

Map.new = function( self, w, h)
    -- tile_size = GAME.tile_size
    self.wt = w
    self.ht = h
    self.w = w * tile_size
    self.h = h * tile_size
    self.center = Lib.vec( self.w, self.h)*0.5

    -- local sh = self.h-tile_size

    self.canvas = lg.newCanvas(self.w,self.h)
    self.light_canvas = lg.newCanvas(self.w,self.h)
    self.dark_canvas = lg.newCanvas(self.w,self.h)
    self.sprite_canvas = lg.newCanvas(self.w,self.h)
    
    lg.setCanvas(self.dark_canvas)
    lg.clear()
    lg.setColor(1,1,1)
    for x=0,w-1 do
        for y=ground_start,h-1 do
            lg.draw( GAME.img.tileset, GAME.quads["dark"], x*tile_size, y*tile_size)
        end
    end
    lg.setCanvas()

    -- local sh = self.h-tile_size
    local keyset = {}
    for k in pairs(GAME.quads.sprites) do
        table.insert(keyset, k)
        -- print(k)
    end
    -- local random_elem = GAME.quads.sprites[keyset[math.random(#keyset)]]
    lg.setCanvas(self.sprite_canvas)
    lg.clear()
    for x=0,w-1 do
        local kn = math.random(#keyset)
        if math.random(10)<8 then
            -- print(kn)
            lg.draw( GAME.img.tileset, GAME.quads.sprites[keyset[kn]], x*tile_size, GAME.half_tile)
        end
    end
    lg.setCanvas()

    -- local sh = self.h-tile_size
    -- lg.setCanvas(self.border_canvas)
    -- lg.clear()
    -- lg.setColor(0,0,0,0.8) --vertical
    -- lg.rectangle("fill",0,border_size,border_size,sh+border_size)--left
    -- lg.rectangle("fill",self.w+border_size,0,border_size,sh+border_size)--right
    -- -- lg.setColor(0,1,0,0.8) --horizontal
    -- lg.rectangle("fill",0,0,self.w+border_size,border_size)--top
    -- lg.rectangle("fill",border_size,sh+border_size,self.w+border_size,border_size)--botton
    -- lg.setCanvas()
    

    --Generate the map -needs work, obviously.
    for x=1,w do
        for y=1,h do
            local tile_type
            if y<=ground_start then
                tile_type='air'
            elseif y==ground_start+1 then
                tile_type='grass'
            else
                tile_type=cell_types[math.random(#cell_types)]
            end
            local id = x..','..y
            self.units[id] = cell( x,y,tile_size,tile_size,tile_type)
            if tile_type=="grass" then
                local tx = x*tile_size-tile_size
                local ty = y*tile_size-tile_size
                GAME.world:add(self.units[id], tx,ty,tile_size,tile_size)
            end
        end
    end

    return self
end
Map.update_canvas = function( self)
    lg.setCanvas(self.canvas)
    lg.clear( )
    lg.setColor(1,1,1)
    for _,s in pairs( self.units) do
        local id = s:get_id()
        if not TILE_TYPE[id].visible then goto next end
        local x,y = (s.x-1)*tile_size, (s.y-1)*tile_size
        lg.draw( GAME.img.tileset, GAME.quads[self.get_name(id)], x, y)
        ::next::
    end

    lg.setCanvas()
    
    lg.setCanvas(self.light_canvas)
    lg.clear( )
    lg.draw(self.canvas)
    lg.setShader(blurShader2)
    Light.draw()
    lg.setShader()

    lg.setCanvas()
end

-- local hbs = border_size*0.5
Map.draw = function( self)
    local wx,wy = Camera:worldCoords(Screen.center.x, Screen.center.y)
    local cx,cy = self.center.x,self.center.y

    for i=layers_num,1,-1 do
        
        local depth = depth_3D*i*Camera.scale
        local sc = 1+depth
        local dx = (wx-cx)*depth
        local dy = (wy-cy)*depth
        local rgb = 1-i*0.1
        local xx = cx-dx
        local yy = cy-dy
        
        if i==layers_num then
            lg.setColor(0.2,0.2,0.2)
            lg.draw( self.dark_canvas,xx,yy,0,sc,sc,cx, cy)
        else
            lg.setColor(rgb,rgb,rgb)
            
            -- if i>1 then
            lg.draw( self.light_canvas,xx,yy,0,sc,sc,cx, cy)
            -- else
            --     lg.draw( self.canvas,xx,yy,0,sc,sc,cx, cy)
            -- end
        end
        -- lg.draw( self.border_canvas,xx,yy,0,sc,sc,cx+border_size, cy-tile_size+border_size)
    end
    lg.setColor(1,1,1)
    lg.draw( self.canvas)
    -- lg.draw( self.sprite_canvas)
    

    -- tile3d:draw()
    -- lg.draw( self.border_canvas,-border_size, tile_size-border_size)
    -- lg.setColor(1,1,0,0.4)
    -- for _, r in ipairs(self.rectangles) do
    --     local start_x = r.start_x * tile_size
    --     local start_y = r.start_y * tile_size
    --     local width = (r.end_x - r.start_x + 1) * tile_size
    --     local height = (r.end_y - r.start_y + 1) * tile_size
    
    --     local x = start_x - tile_size
    --     local y = start_y - tile_size

    --     lg.rectangle("line",x,y,width,height)
    --     lg.rectangle("fill",x,y,width,height)
    -- end
end
-- Map.draw_light = function( self)
    
    -- lg.setShader(blur)
    -- lg.setColor(1,1,1)
    -- love.graphics.setBlendMode("multiply",'premultiplied')
    -- lg.draw( self.light_canvas)
    -- love.graphics.setBlendMode("alpha")
    
    -- lg.setShader()
-- end
Map.grid_to_world = function(self, x,y)
    if type(x)=='string' then
        x,y = FromId(x)
    end
    return (x-1)*tile_size, (y-1)*tile_size
end
Map.world_to_grid = function(self, x,y)
    return math.ceil(x/tile_size), math.ceil(y/tile_size)
end
Map.set_tile = function( self, x,y, type)
    local tid = x..','..y
    if self.units[tid] then
        self.units[tid] = cell( x,y,tile_size,tile_size,type)
        -- GAME.world:add(item, x,y,w,h)
    end
    return self.units[tid]
end
    -- get_center = function( self, x,y)
    --     local tid = ToId(x,y)
    --     return self.units[tid]
    -- end
Map.get_tile = function( self, x,y)
    -- print(x)
    local tid = type(x)=="number" and (x..','..y) or x
    return self.units[tid]
end
Map.is_wall = function( self, x,y)
    local tid =x..','..y
    if not self.units[tid] then return end
    -- print(self.units[tid].id)
    return TILE_TYPE[self.units[tid].id].solid
end
Map.get_tile_id = function( self, x,y)
    local tid = x..','..y
    return self.units[tid].id
end
-- Map.is_lighted = function( self, x, y)
--     local t = self:get_tile(x,y)
--     if t then
--         return t.light>0.05
--     end
-- end
Map.has_item = function( self, x, y)
    -- print(x, y)
    local t = self:get_tile(x,y)
    if t then
        return t.item
    end
end
Map.get_info = function( id, info)
    local t = TILE_TYPE[id]
    if t then
        return TILE_TYPE[id][info]
    end
end
Map.get_name = function( id)
    -- local t = TILE_TYPE[id]
    -- if t then
    --     return TILE_TYPE[id].name
    -- end
    return Map.get_info(id, "name")
end
Map.get_color = function( id)
    return TILE_COLOR[id]
end
Map.is_solid = function( id)
    -- local t = TILE_TYPE[id]
    -- if t then
    --     return TILE_TYPE[id].solid
    -- end
    return Map.get_info(id, "solid")
end
Map.is_breakable = function( id)
    -- local t = TILE_TYPE[id]
    -- if t then
    --     return TILE_TYPE[id].breakable
    -- end
    return Map.get_info(id, "breakable")
end
Map.get_neighbours = function( self, tx,ty) -- return neighbours tile, { (0,-1), (-1,0), (1,0), (0,1)}, if there is any.
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
end
Map.insert_tile = function( self, x,y, type)
    local t = self:get_tile( x,y)

    -- print(t.id)
    if t.id ~= 'air' then return false end
    -- print("up up UP!")

    local nt = self:get_neighbours( x, y)
    local solid_near = false
    for _,k in ipairs(nt) do
        if TILE_TYPE[k:get_id()].solid then
            solid_near = true
        end
    end
    if not solid_near then return false end
    -- print(type, 'solid near == true')
    self:set_tile( x,y, type or 'dirt')
    -- self:update_lights( )
    self:update_canvas()
    GAME.sfx.place_block:play()

    return true
end
-- Map.
Map.update_collisions = function( self, x,y)
    local n = self:get_neighbours(x,y)
    for _,t in ipairs(n) do
        if not GAME.world:hasItem(t) and self.is_solid(t.id) then
            local tx = t.x*tile_size-tile_size
            local ty = t.y*tile_size-tile_size
            GAME.world:add(t, tx,ty,GAME.tile_size,GAME.tile_size)
        end
    end
end
Map.break_tile = function( self, x,y)
    local t = self:get_tile(x,y)
    if not self.is_breakable(t:get_id()) then return end

    -- if t:is_emiter() then
        -- self:remove_light(x,y)
    if TILE_TYPE[t:get_id()].solid then
        local drops = DROPS[ t:get_id()]
        -- print('tile set to air')
        -- t:destroy()
        self:set_tile( x,y, 'air')
        GAME.sfx.block_break:play()
        -- GAME.update_lights( )
        -- self:update_canvas()
        if GAME.world:hasItem(t) then GAME.world:remove(t) end
        self:update_collisions(x,y)
        return true
        -- if drops then
        --     local n = #drops
        --     local rn = math.ceil( math.random(n+1)*math.random())-1
        --     -- if rn>0.1 and drops[rn] then
        --     if drops[rn] then
        --         local nx, ny = self:grid_to_world( t.x, t.y)
        --         Lib.timer.after(0.1, function() GAME.drop_item(drops[rn], nx, ny) end)
        --     end
        -- end
    end
end
-- Map.update_lights = function( self )
--     for _,k in pairs(self.units) do
--         -- if k.y>1 then
--         k:set_light(0)
--         -- end
--     end
--     local rm = {}
--     for n,lit in pairs(emiters) do
--         local x,y = FromId(lit.id)
--         local tile = self:get_tile(x,y)
--         if not tile.emiter then rm[#rm+1] = n else
--             local color = {tile.r, tile.g, tile.b}
--             self:update_tile_light(x, y, tile.force, color)
--         end
--     end
--     for i=0,#rm-1 do
--         table.remove(emiters, rm[#rm-i])
--     end
--     -- update the light canvas
    
--     lg.setCanvas(self.light_canvas)
--     lg.clear( )
--     for _,s in pairs( self.units) do
--         if s.y>1 then
--             lg.setColor( s.light,s.light,s.light)
--         else
--             lg.setColor(1,1,1)
--         end
--         local x,y = (s.x-1)*tile_size, (s.y-1)*tile_size
--         --s:get_color())
--         -- lg.setColor( 1-s.light,1-s.light,1-s.light)--s:get_color())
--         lg.rectangle( "fill", x, y, tile_size, tile_size)
--         -- end
--     end
--     lg.setCanvas()
-- end
-- Map.add_sun = function( self, x,y,light_level,color) -- x, y, light_level (0,...,1), color:table
--     local t = self:get_tile( x,y)
    
--     -- if t.id ~= 'void' then return end
    
--     t = self:set_tile( x, y, 'sun')

--     t:set_light(1)
--     t.emiter = true
--     t.force = light_level or 1

--     local c = color or {}
--     t.r = c[1] or 1
--     t.g = c[2] or 1
--     t.b = c[3] or 1

--     table.insert(emiters, {id=ToId(x,y), c=color})
--     self:update_lights( )
    
-- end
-- Map.add_light = function( self, x,y,light_level,color)
--     local t = self:get_tile( x,y)
--     if not t then return end
--     -- if t.light<0.2 then return end
--     if t.id ~= 'air' then return end
--     -- 
    
--     -- t = self:set_tile( x, y, 'air')

--     t:set_light(1)
--     t.emiter = true
--     t.force = light_level or 1

--     local cor = color or {1,1,1}
--     t.r = cor[1]
--     t.g = cor[2]
--     t.b = cor[3]

--     table.insert(emiters, {id=ToId(x,y), c=cor})
--     self:update_lights( )
--     self:update_canvas()
--     GAME.sfx.place_block:play()
--     return t
-- end
-- Map.remove_light = function( self, x,y)
--     local t = self:get_tile( x,y)
--     if not t or not t.emiter or t:get_id() == 'sun' then return end
--     local t = self:set_tile(x,y,'air')
--     self:update_lights( )
--     self:update_canvas()
--     return t
-- end
-- Map.update_neighbours = function( self, x, y, light_level, color)
--     self:update_tile_light(x, y - 1, light_level, color)
--     self:update_tile_light(x, y + 1, light_level, color)
--     self:update_tile_light(x - 1, y, light_level, color)
--     self:update_tile_light(x + 1, y, light_level, color)
-- end
-- Map.update_tile_light = function( self, x, y, light_level, color)
--     local t = self:get_tile( x,y)
--     if t and (light_level > t.light) then
--         t.light = light_level
--         if not t.emiter then
--             t.r = color[1]
--             t.g = color[2]
--             t.b = color[3]
--         end
--         self:update_neighbours(x, y, light_level - TILE_TYPE[t:get_id()].opacity, color)
--     end
-- end
-- Map.get_lights = function( self)
--     return emiters
-- end


return Map

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
    l_air = new_type( 'air', 0.01, 0,false,false,true),
    dirt = new_type( 'dirt', 0.8, 3, true, true),
    gravel = new_type( 'gravel', 1, 3, true, true),
    grass = new_type( 'grass', 0.8, 3, true, true),
    leaf = new_type( 'leaf', 1, 3, true, true),
    wood = new_type( 'wood', 1, 3, true, true),
    plank = new_type( 'plank', 1, 3, true, true),
    blocker = new_type( 'blocker', 0.7, 5, true, true),
    stone = new_type( 'stone', 1, 8, true, true),
    rock = new_type( 'rock', 1, 8, true, true),
}
local TILE_COLOR = {
    dirt = {0.33,0.19,0.1},
    grass = {0.2,0.23,0.12},
    -- air = {0.1,0.25,0.3},
    stone = {0.25,0.22,0.21},
    leaf = {0,0.32,0.1},
    wood = {0.55,0.3,0.1},
    plank = {0.25,0.22,0},
}
local DROPS = {
    dirt = { 'bones', 'dung'},
    gravel = { 'coal', 'stone'},
    stone = { 'stone', 'stone', 'coal'},
    rock = { 'coal', 'coal', 'iron', 'stone', 'iron', 'gold'},
}

local cell = class:extend()
function cell:new( x, y, w, h, id)
    self.id = id or 'air'
    self.x = x or 0
    self.y = y or 0
end
function cell:get_id( ) return self.id
end
function cell:get_name( ) return TILE_TYPE[self.id].name
end
function cell:get_position( ) return self.x, self.y
end
-- function cell:destroy()
    -- if self.world then
        -- self.world:remove(self)
    -- end
-- end


local blurShader2 = love.graphics.newShader("blur2.fs")

local tile_size = GAME.tile_size
local dirt_start = 16
local stone_start = dirt_start*3
local layers_num = 4
local depth_3D = -5*10^-3
-- local border_size = 6

---------------------------------------------------------------------------GENERATION
local function inside_circle( tx, ty, radius)
    local dx = radius - tx
    local dy = radius - ty
    local distance_squared = dx*dx + dy*dy
    return distance_squared <= radius*radius
end
local function draw_circle(x,y,radius)
    local top   = 0
    local bottom= radius*2
    local circle = {
        x=x,
        y=y,
        h=bottom,
        w=bottom,
    }
    for y = top,bottom-1 do
        circle[y+1] = {}
        for x = top,bottom-1 do
            circle[y+1][x+1] = inside_circle( x,y, radius-1)
        end
    end
    return circle
end
local function set_points(sx, sy, lenght)
    local points = {}
    local angle = 2 * math.pi * (math.random())
    local dx,dy = math.cos(angle), math.sin(angle)
    local steps = 2
    local x,y = sx, sy
    for i=1,lenght do
        points[#points+1] = draw_circle( x,y, math.random(2,math.min(i,3)))
        angle = angle + math.pi * math.random()
        dx,dy = math.cos(angle), math.sin(angle)
        x = math.floor(x+dx*steps)
        y = math.floor(y+dy*steps)
    end
    return points
end
local function generate_map(w,h)
    local grid = {}
    local _c = 0
    for x=1,w do
        grid[x] = {}
        _c = _c+0.1
        for y=1,h do
            
            local stn = stone_start+math.sin(_c)*math.random(10)
            local tile_type='dirt'
            if y<dirt_start then
                tile_type="air"
            elseif y>stn then
                tile_type="stone"
            end

            grid[x][y] = tile_type
        end
    end
    local function foo(type_name, max_points, start_y,end_y)
        local x,y = math.random(2,w-2), math.random(start_y,end_y)
        local points = set_points(x,y, math.random(1,max_points))
        for n,point in ipairs(points) do
            for cx=1,point.w do
                for cy=1,point.h do
                    if PointInside(point.x+cx, point.y+cy, 1,1,w-1,h-1) and point[cx][cy] then
                        grid[point.x+cx][point.y+cy] = type_name
                    end
                end
            end
        end
    end
    --add stone to dirt layer
    local mwh = w+h
    -- print(mwh*0.1)
    for i=1,math.floor(mwh*0.1) do
        foo("stone",6,5,stone_start)
    end
    --add dirt to stone layer
    for i=1,math.floor(mwh*0.15) do
        foo("dirt",6,stone_start,h)
    end
    --add caves
    for i=1,math.floor(mwh*0.15) do
        foo("air",8,12,h)
    end
    local ground_y = math.random(2,8)
    grid.ground = {}
    for i=1,w do
        -- ground_y = ground_y +math.sin(i)*math.random()
        local ni = i*2*math.random()
        ground_y = math.max(ground_y +math.sin(ni), dirt_start)
        grid.ground[i] = math.floor(ground_y)
        for j=1,grid.ground[i]-1 do
            grid[i][j] = "l_air"
        end
        if grid[i][grid.ground[i]]=="dirt" then
            grid[i][grid.ground[i]]="grass"
        end
    end
    return grid
end

Map.new = function( self, w, h)
    -- tile_size = GAME.tile_size
    self.wt = w
    self.ht = h
    self.w = w * tile_size
    self.h = h * tile_size
    self.center = vec( self.w, self.h)*0.5
    self.units = {}
    -- local sh = self.h-tile_size

    self.canvas = lg.newCanvas(self.w,self.h)
    self.light_canvas = lg.newCanvas(self.w,self.h)
    self.dark_canvas = lg.newCanvas(self.w,self.h)
    -- self.sprite_canvas = lg.newCanvas(self.w,self.h)
    local grid = generate_map(w,h)


    lg.setCanvas(self.dark_canvas)
    lg.clear()
    lg.setColor(1,1,1)
    for x=0,w-1 do
    --     -- print(grid.ground[x+1])
        for y=grid.ground[x+1],h-1 do
            lg.draw( GAME.img.tileset, GAME.quads["dark"], x*tile_size, y*tile_size)
        end
    end
    lg.setCanvas()

    -- local sh = self.h-tile_size
    -- local keyset = {}
    -- for k in pairs(GAME.quads.sprites) do
    --     table.insert(keyset, k)
    --     -- print(k)
    -- end
    -- local random_elem = GAME.quads.sprites[keyset[math.random(#keyset)]]
    -- lg.setCanvas(self.sprite_canvas)
    -- lg.clear()
    -- for x=0,w-1 do
    --     local kn = math.random(#keyset)
    --     if math.random(10)<8 then
    --         -- print(kn)
    --         lg.draw( GAME.img.tileset, GAME.quads.sprites[keyset[kn]], x*tile_size, GAME.half_tile)
    --     end
    -- end
    -- lg.setCanvas()

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
    

    --Generate the map -needs work, obviously.  !TODO
    
    -- for x=1,w do
    --     grid[x] = {}
    --     for y=1,h do
    --         local tile_type='air'
    --         if y>stone_start then
    --             tile_type="stone"
    --         elseif y>dirt_start then
    --             tile_type="dirt"
    --         end

    --         grid[x][y] = tile_type


    --         local id = x..','..y
    --         self.units[id] = cell( x,y,tile_size,tile_size,tile_type)

    --         --add collision box over the first layer -needs work    !TODO
    --         if y==dirt_start+1 then
    --             local tx = x*tile_size-tile_size
    --             local ty = y*tile_size-tile_size
    --             GAME.world:add(self.units[id], tx,ty,tile_size,tile_size)
    --         end
    --     end
    -- end
    print(#grid)
    for x,gx in ipairs(grid) do
        for y,tile_type in ipairs(gx) do
            local id = x..','..y
            self.units[id] = cell( x,y,tile_size,tile_size,tile_type)
            local tx = x*tile_size-tile_size
            local ty = y*tile_size-tile_size
            -- if TILE_TYPE[tile_type]["breakable"] then
            --     GAME.world:add(self.units[id], tx,ty,tile_size,tile_size)
            -- end
            --add collision box over the first layer -needs work    !TODO
            -- if y==grid.ground[x]+1 and TILE_TYPE[tile_type]["breakable"] then
            --     local tx = x*tile_size-tile_size
            --     local ty = y*tile_size-tile_size
            --     GAME.world:add(self.units[id], tx,ty,tile_size,tile_size)
            -- end
        end
        -- local gy = grid.ground[x]+1
        -- local tx = x*tile_size-tile_size
        -- local ty = gy*tile_size-tile_size
        -- GAME.world:add(self.units[x..','..gy], tx,ty,tile_size,tile_size)
    end
    return self
end
Map.update_canvas = function( self)
    lg.setCanvas(self.canvas)
    lg.clear( )
    lg.setColor(1,1,1)
    for _,s in pairs( self.units) do
        local id = s:get_id()
        if TILE_TYPE[id].visible then
            local x,y = (s.x-1)*tile_size, (s.y-1)*tile_size
            lg.draw( GAME.img.tileset, GAME.quads[TILE_TYPE[id].name], x, y)
        end
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
        local xx = cx-dx
        local yy = cy-dy
        
        if i==layers_num then
            lg.setColor(0.2,0.2,0.2)
            lg.draw( self.dark_canvas,xx,yy,0,sc,sc,cx, cy)
        end
        local rgb = 1-i*0.1
        lg.setColor(rgb,rgb,rgb)
        lg.draw( self.light_canvas,xx,yy,0,sc,sc,cx, cy)
    end
    lg.setColor(1,1,1)
    lg.draw( self.canvas)
    -- lg.draw( self.sprite_canvas)
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
    local t = TILE_TYPE[id]
    if t then
        return TILE_TYPE[id].name
    end
    -- return Map.get_info(id, "name")
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
        -- local drops = DROPS[ t:get_id()]
        -- print('tile set to air')
        -- t:destroy()
        self:set_tile( x,y, 'air')
        GAME.sfx.block_break:play()
        -- GAME.update_lights( )
        -- self:update_canvas()
        -- if GAME.world:hasItem(t) then GAME.world:remove(t) end
        -- self:update_collisions(x,y)
        return true
        -- if drops then
        --     local n = #drops
        --     local rn = math.ceil( math.random(n+1)*math.random())-1
        --     -- if rn>0.1 and drops[rn] then
        --     if drops[rn] then
        --         local nx, ny = self:grid_to_world( t.x, t.y)
        --         timer.after(0.1, function() GAME.drop_item(drops[rn], nx, ny) end)
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
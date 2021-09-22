local lg = love.graphics
local screen = {w = love.graphics.getWidth(), h = love.graphics.getHeight()}
local Timer = require "HUMP.timer"
local CAMERA = require "HUMP.camera"
local class = require "classic"

function math.clamp(min, val, max) return math.min(math.max(val, min), max) end
function distance(x1,y1,x2,y2) return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end
function box_collision( x1,y1,w1,h1, x2,y2,w2,h2)
    return (x1+w1>x2 and x1<x2+w2 and y1+w1>y2 and y1<y2+h2)
end
bool_to_number={ [true]=1, [false]=0.1 }
-------------------------------------------------------------------------------------------------
local tiles_img = lg.newImage("jhonSmith.png")
local sw, sh = tiles_img:getWidth(),tiles_img:getHeight()
local ts = 32
quads = {
    drt = love.graphics.newQuad( 64, 0, ts, ts, sw, sh ),
    stn = love.graphics.newQuad( 32, 0, ts, ts, sw, sh ),
    rck = love.graphics.newQuad( 32, 32, ts, ts, sw, sh ),
    grv = love.graphics.newQuad( 96, 32, ts, ts, sw, sh ),
    air = love.graphics.newQuad( 128, 352, ts, ts, sw, sh ),
    shroom = love.graphics.newQuad( 384, 32, ts, ts, sw, sh ),
}
------------------------------------------------------------------------------------------------- 
--  ▄                 ▄▄▄▄▄▄▄▄▄▄▄       ▄▄▄▄▄▄▄▄▄▄        ▄▄▄▄▄▄▄▄▄▄▄       ▄           
-- ▐░▌               ▐░░░░░░░░░░░▌     ▐░░░░░░░░░░▌      ▐░░░░░░░░░░░▌     ▐░▌          
-- ▐░▌               ▐░█▀▀▀▀▀▀▀█░▌     ▐░█▀▀▀▀▀▀▀█░▌     ▐░█▀▀▀▀▀▀▀▀▀      ▐░▌          
-- ▐░▌               ▐░▌       ▐░▌     ▐░▌       ▐░▌     ▐░▌               ▐░▌          
-- ▐░▌               ▐░█▄▄▄▄▄▄▄█░▌     ▐░█▄▄▄▄▄▄▄█░▌     ▐░█▄▄▄▄▄▄▄▄▄      ▐░▌          
-- ▐░▌               ▐░░░░░░░░░░░▌     ▐░░░░░░░░░░▌      ▐░░░░░░░░░░░▌     ▐░▌          
-- ▐░▌               ▐░█▀▀▀▀▀▀▀█░▌     ▐░█▀▀▀▀▀▀▀█░▌     ▐░█▀▀▀▀▀▀▀▀▀      ▐░▌          
-- ▐░▌               ▐░▌       ▐░▌     ▐░▌       ▐░▌     ▐░▌               ▐░▌          
-- ▐░█▄▄▄▄▄▄▄▄▄      ▐░▌       ▐░▌     ▐░█▄▄▄▄▄▄▄█░▌     ▐░█▄▄▄▄▄▄▄▄▄      ▐░█▄▄▄▄▄▄▄▄▄ 
-- ▐░░░░░░░░░░░▌     ▐░▌       ▐░▌     ▐░░░░░░░░░░▌      ▐░░░░░░░░░░░▌     ▐░░░░░░░░░░░▌
--  ▀▀▀▀▀▀▀▀▀▀▀       ▀         ▀       ▀▀▀▀▀▀▀▀▀▀        ▀▀▀▀▀▀▀▀▀▀▀       ▀▀▀▀▀▀▀▀▀▀▀ 

local Notification = class:extend()
function Notification:new( txt, y, duration)
    self.txt = txt
    self.y = y
    self.w = screen.w
    self.h = 30
    self.duration = duration
end
function Notification:draw( )
    lg.setColor(0,0,0)
    lg.rectangle('fill',0, self.y-self.h*0.25,self.w,self.h)
    lg.setColor(1,1,1)
    lg.rectangle('line',-2, self.y-self.h*0.25,self.w+4,self.h)
    lg.printf( self.txt, 0, self.y, self.w, "center")
end
local Label = {
    stack={},
    min_y = 10,
    speed = 10,
    spacing = 5,
}
Label.new = function( self, txt, duration)
    local y = self.min_y+self.spacing*3
    local last = self.stack[#self.stack]
    if #self.stack > 0 then
        y = last.y + last.h+self.spacing*3
    end
    table.insert( self.stack, Notification( txt, y, duration))
end
Label.update = function(self, dt)
    local dead
    for n,s in ipairs(self.stack) do
        s.duration = s.duration - dt
        if s.duration<=0 then
            dead = n
        else
            if (n==1 and s.y>self.min_y) or (n>1 and s.y>self.stack[n-1].y+self.stack[n-1].h+self.spacing) then
                local df = n==1 and (s.y-self.min_y) or s.y-(self.stack[n-1].y+self.stack[n-1].h+self.spacing)
                s.y = s.y - math.max(1, df)*self.speed*dt
            end
        end
    end
    if #self.stack>5 then dead = 1 end
    if dead then table.remove( self.stack, dead) end
end
Label.draw = function(self)
    for n,s in ipairs(self.stack) do
        s:draw()
    end
end


-------------------------------------------------------------------------------------------------

local progress_bar = class:extend()
function progress_bar:new(  x, y, w, h, c1, c2)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.v = w
    self.bc = c1 or {0.6,0,0,1}
    self.fc = c2 or {1,0,0,1}
end
function progress_bar:draw(v,v_max)
    local var = math.max(0, v/v_max*self.w)
    lg.setColor(self.bc)
    if self.v~=var then
        self.v = self.v + (var-self.v)*0.02
    end
    lg.rectangle('fill',self.x, self.y, self.v, self.h )
    lg.setColor(self.fc)
    lg.rectangle('line',self.x, self.y, self.w, self.h )
    lg.rectangle('fill',self.x, self.y, var, self.h )
end

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
function cell:new( x, y, id)
    self.id = id or 'air'
    self.x = x or 0
    self.y = y or 0
    self.opacity = bool_to_number[id~='air']
    self.light = 0
end
function cell:set_opacity( n) self.opacity = math.clamp(0, n, 1)
end
function cell:set_light( n) self.light = math.clamp(0, n, 1)
end
function cell:set_emiter( n) self.emiter = n
end
function cell:set_force( n) self.force = n
end
function cell:get_id( ) return self.id
end
function cell:get_position( ) return self.x, self.y
end
local cell_types = {'drt','rck','stn','grv'}


function update_neighbours( x, y, light_level)
    update_tile_light(x, y - 1, light_level)
    update_tile_light(x, y + 1, light_level)
    update_tile_light(x - 1, y, light_level)
    update_tile_light(x + 1, y, light_level)
end
function update_tile_light(x, y, light_level)
    local t = map:get_tile( x,y)
    -- if not t then return end
    if t and (light_level > t.light) then
        t.light = light_level
        update_neighbours(x, y, light_level-t.opacity)
    end
end
local emiters = {}
function set_light_emiter(x,y,light_level)
    local t = map:get_tile( x,y)
    t:set_light(1)
    t:set_opacity(0)
    t:set_emiter(true)
    t:set_force(light_level)

    table.insert(emiters, to_id(x,y))
    update_lights( )
    -- update_tile_light(x, y, light_level)
end
function update_lights( )
    for i,k in pairs(map.units) do
        k:set_light(0)
    end
    local rm = {}
    for n,lit in pairs(emiters) do
        local x,y = id_to_coord(lit)
        local tile = map:get_tile(x,y)
        if not tile.emiter then rm[#rm+1] = n else
            update_tile_light(x, y, tile.force)
        end
    end
    print(#rm)
    for i=0,#rm-1 do
        table.remove(emiters, rm[#rm-i])
    end
end

local Map = {
    grid_size = 32,
    units = {},
    new = function( self, w, h)
        self.w = w * self.grid_size
        self.h = h * self.grid_size
        for x=1,w do
            for y=1,h do
                
                local id = y>5 and cell_types[math.random(#cell_types)] or 'air'
                self.units[ to_id(x,y)] = cell(x,y,id)

                if y<=5 then
                    self.units[ to_id(x,y)]:set_opacity(0)
                end
            end
        end
        
        return self
    end,
    draw = function( self, wx,wy)
        lg.setColor(1,1,1)
        for n,s in pairs( self.units) do

            if s:get_id() == 'air' then goto next end

            local x,y = (s.x-1)*self.grid_size, (s.y-1)*self.grid_size
            if box_collision( x,y,self.grid_size,self.grid_size, wx,wy, screen.w, screen.h) then
                lg.setColor( s.light, s.light, s.light)
                lg.draw(tiles_img,quads[s:get_id()], x, y)
                -- lg.rectangle( "line", x, y, self.grid_size, self.grid_size)
                -- lg.print( x/32 ..'\n' ..y/32, x, y)
                lg.print( s.light, x, y)
            end

            ::next::
        end
    end,
    set_tile = function( self, x,y, id)
        local tid = to_id(x,y)
        if self.units[tid] then
            self.units[tid] = cell(x,y,'air')
        end
        return self.units[tid]
    end,
    get_tile = function( self, x,y)
        local tid = to_id(x,y)
        return self.units[tid]
    end,
    break_tile = function( self, x,y)
        local t = self:set_tile( x,y, 'air')
        update_lights( )
        -- local l = 0
        -- for ny = -1,1 do
        --     for nx = -1,1 do
        --         if math.abs(nx+ny)==1 then
        --             -- print(nx,ny)
        --             local it = self:get_tile(x+nx,y+ny)
        --             if it and it.light>it.opacity then
        --                 print(nx,ny)
        --                 l = it.light - t.opacity
        --             end
        --         end
        --     end
        -- end
        -- update_lights(x, y, l)
    end,
    -- draw_dark = function( self)
    --     lg.setColor(1,1,1)
    --     for n,s in ipairs( self.units) do
    --         local x,y = (s.x-1)*self.grid_size, (s.y-1)*self.grid_size
    --         -- lg.draw(img['map_dark1'], x, y)
    --     end
    -- end, 
}

------------------------------------------------------------------------------------------------- TODO
--  ▄▄▄▄▄▄▄▄▄▄▄       ▄▄▄▄▄▄▄▄▄▄▄       ▄▄▄▄▄▄▄▄▄▄▄       ▄▄       ▄▄       ▄▄▄▄▄▄▄▄▄▄▄ 
-- ▐░░░░░░░░░░░▌     ▐░░░░░░░░░░░▌     ▐░░░░░░░░░░░▌     ▐░░▌     ▐░░▌     ▐░░░░░░░░░░░▌
--  ▀▀▀▀█░█▀▀▀▀       ▀▀▀▀█░█▀▀▀▀      ▐░█▀▀▀▀▀▀▀▀▀      ▐░▌░▌   ▐░▐░▌     ▐░█▀▀▀▀▀▀▀▀▀ 
--      ▐░▌               ▐░▌          ▐░▌               ▐░▌▐░▌ ▐░▌▐░▌     ▐░▌          
--      ▐░▌               ▐░▌          ▐░█▄▄▄▄▄▄▄▄▄      ▐░▌ ▐░▐░▌ ▐░▌     ▐░█▄▄▄▄▄▄▄▄▄ 
--      ▐░▌               ▐░▌          ▐░░░░░░░░░░░▌     ▐░▌  ▐░▌  ▐░▌     ▐░░░░░░░░░░░▌
--      ▐░▌               ▐░▌          ▐░█▀▀▀▀▀▀▀▀▀      ▐░▌   ▀   ▐░▌      ▀▀▀▀▀▀▀▀▀█░▌
--      ▐░▌               ▐░▌          ▐░▌               ▐░▌       ▐░▌               ▐░▌
--  ▄▄▄▄█░█▄▄▄▄           ▐░▌          ▐░█▄▄▄▄▄▄▄▄▄      ▐░▌       ▐░▌      ▄▄▄▄▄▄▄▄▄█░▌
-- ▐░░░░░░░░░░░▌          ▐░▌          ▐░░░░░░░░░░░▌     ▐░▌       ▐░▌     ▐░░░░░░░░░░░▌
--  ▀▀▀▀▀▀▀▀▀▀▀            ▀            ▀▀▀▀▀▀▀▀▀▀▀       ▀         ▀       ▀▀▀▀▀▀▀▀▀▀▀ 
                                                                                     
    -- 
function new_item( name, type, affect, action, potency, duration, delay) --consumable item
    return {name = name, type = type, affect = affect, action = action, potency = potency or 0, duration = duration or 0, delay = delay or 1}
end
-- local new_item = class:extend()
-- function new_item:new( name, type)
--     self.name = name
--     self.type = type
-- end
-- -- local item_effect = class:extend()
-- new_item.effect = function( self, affect, action, potency, duration)
--     self.affect = affect
--     self.action = action
--     self.potency = potency
--     self.duration = duration
--     return self
-- end
--[[ todo function new_item( name, type) ]]--
--     return {name = name, type = type}
-- end
-- function new_item_effect = new_item:extend( )
--     return {name = name, type = type}
-- end
-- local set_potency = function( name, potency)
--     local i = item_list[ name]
--     return {name = i.name, type= i.type, affect = i.affect, action = i.action, potency = potency or i.potency}
-- end
local item_list = {
    -- meat = new_item( 'meat', 'food'):effect('hunger', 'decrease', 50),
    meat = new_item( 'meat', 'food', 'hunger', 'decrease', 50),
    water = new_item('water', 'potion', 'thirsty', 'decrease', 50),
    poison = new_item('poison', 'potion', 'hp', 'decrease_periodic', 50, 5, 5),
    regen = new_item('regen potion', 'potion', 'hp', 'increase_periodic', 50, 5, 5),
    health_potion = new_item('health potion', 'potion', 'hp', 'increase', 200),
    trash = new_item( 'trash', 'trash'),
}
-- print(item_list.meat.affect)
local item_handler = {
    stack = {},
    use = function( self, char, item)
        local i = item_list[ item]
        local obj = char[ i.affect]

        print( char.n ..' used: ' .. i.name)
        Label:new(' used: ' .. i.name, 2)
        self[ i.action]( self, obj, i)
    end,
    increase = function(self, obj, item)
        obj:add( item.potency)
    end,
    decrease = function(self, obj, item)
        obj:add( -item.potency)
    end,
    increase_periodic = function(self, obj, item)
        self:increase( obj, item)
        -- table.insert(self.timer, Timer.new())
        Timer.every( item.delay, function() self:increase( obj, item) print(item.name) end, item.duration)
        -- self.timer[#self.timer]:every( item.delay, function() self:increase( obj, item) end, item.duration)
    end,
    decrease_periodic = function(self, obj, item)
        self:decrease( obj, item)
        Timer.every( item.delay, function() self:decrease( obj, item) print(item.name) end, item.duration)
        
    end,
    update = function(self, dt)
        -- for i,k in ipairs(self.timer) do
        --     k:update( dt)
        -- end
    end
}


-------------------------------------------------------------------------------------------------
--  ▄▄       ▄▄       ▄▄▄▄▄▄▄▄▄▄▄       ▄         ▄       ▄▄▄▄▄▄▄▄▄▄▄       ▄▄▄▄▄▄▄▄▄▄▄ 
-- ▐░░▌     ▐░░▌     ▐░░░░░░░░░░░▌     ▐░▌       ▐░▌     ▐░░░░░░░░░░░▌     ▐░░░░░░░░░░░▌
-- ▐░▌░▌   ▐░▐░▌     ▐░█▀▀▀▀▀▀▀█░▌     ▐░▌       ▐░▌     ▐░█▀▀▀▀▀▀▀▀▀      ▐░█▀▀▀▀▀▀▀▀▀ 
-- ▐░▌▐░▌ ▐░▌▐░▌     ▐░▌       ▐░▌     ▐░▌       ▐░▌     ▐░▌               ▐░▌          
-- ▐░▌ ▐░▐░▌ ▐░▌     ▐░▌       ▐░▌     ▐░▌       ▐░▌     ▐░█▄▄▄▄▄▄▄▄▄      ▐░█▄▄▄▄▄▄▄▄▄ 
-- ▐░▌  ▐░▌  ▐░▌     ▐░▌       ▐░▌     ▐░▌       ▐░▌     ▐░░░░░░░░░░░▌     ▐░░░░░░░░░░░▌
-- ▐░▌   ▀   ▐░▌     ▐░▌       ▐░▌     ▐░▌       ▐░▌      ▀▀▀▀▀▀▀▀▀█░▌     ▐░█▀▀▀▀▀▀▀▀▀ 
-- ▐░▌       ▐░▌     ▐░▌       ▐░▌     ▐░▌       ▐░▌               ▐░▌     ▐░▌          
-- ▐░▌       ▐░▌     ▐░█▄▄▄▄▄▄▄█░▌     ▐░█▄▄▄▄▄▄▄█░▌      ▄▄▄▄▄▄▄▄▄█░▌     ▐░█▄▄▄▄▄▄▄▄▄ 
-- ▐░▌       ▐░▌     ▐░░░░░░░░░░░▌     ▐░░░░░░░░░░░▌     ▐░░░░░░░░░░░▌     ▐░░░░░░░░░░░▌
--  ▀         ▀       ▀▀▀▀▀▀▀▀▀▀▀       ▀▀▀▀▀▀▀▀▀▀▀       ▀▀▀▀▀▀▀▀▀▀▀       ▀▀▀▀▀▀▀▀▀▀▀ 
                                                                                     
local Mouse = cell:extend()
function Mouse:new( )
    self.og_screen_x = 0
    self.og_screen_y = 0
    self.screen_x = 0
    self.screen_y = 0

    self.camera_x = 0
    self.camera_y = 0
    self.og_camera_x = 0
    self.og_camera_y = 0

    self.drag = false
    self.n = "mouse"
    self.id = 'player_input'
    self.counter = 0
end
function Mouse:update( dt)

    self.x, self.y = camera:mousePosition()
    self.screen_x, self.screen_y = love.mouse.getPosition()

    if love.mouse.isDown( 1) and not self.drag then
        self.counter = self.counter + 1*dt
        local moved = math.abs( self.screen_x-self.og_screen_x)>5 or math.abs( self.screen_y-self.og_screen_y)>5
        if moved or self.counter>0.5 then
            self.drag = true
            camera.focus = self.id
            self.og_camera_x = camera.x
            self.og_camera_y = camera.y

            self.og_screen_x = self.screen_x
            self.og_screen_y = self.screen_y
        end
    end

    if self.drag then
        local dx = self.screen_x - self.og_screen_x
        local dy = self.screen_y - self.og_screen_y

        self.camera_x = self.og_camera_x - dx
        self.camera_y = self.og_camera_y - dy
    end
    
end
function Mouse:get_grid_position()
    return math.ceil(self.x/32),math.ceil(self.y/32)
end
function Mouse:draw()
    lg.setColor(1,1,1,1)
    local x,y = self:get_grid_position()
    lg.print( x ..'\n' ..y, self.screen_x, self.screen_y + 20)
    -- lg.circle('line',240+self.camera_x, 426+self.camera_y,6,8)
end

local mouse

local cam_speed = {
    player_input = function( ) return math.floor((mouse.camera_x - camera.x)*0.1), math.floor((mouse.camera_y - camera.y)*0.1) end
}

-- local function my_stencil()
--     love.graphics.circle("fill", 225, 200, 350, 300)
-- end
--  ▄▄       ▄▄       ▄▄▄▄▄▄▄▄▄▄▄       ▄▄▄▄▄▄▄▄▄▄▄       ▄▄        ▄ 
-- ▐░░▌     ▐░░▌     ▐░░░░░░░░░░░▌     ▐░░░░░░░░░░░▌     ▐░░▌      ▐░▌
-- ▐░▌░▌   ▐░▐░▌     ▐░█▀▀▀▀▀▀▀█░▌      ▀▀▀▀█░█▀▀▀▀      ▐░▌░▌     ▐░▌
-- ▐░▌▐░▌ ▐░▌▐░▌     ▐░▌       ▐░▌          ▐░▌          ▐░▌▐░▌    ▐░▌
-- ▐░▌ ▐░▐░▌ ▐░▌     ▐░█▄▄▄▄▄▄▄█░▌          ▐░▌          ▐░▌ ▐░▌   ▐░▌
-- ▐░▌  ▐░▌  ▐░▌     ▐░░░░░░░░░░░▌          ▐░▌          ▐░▌  ▐░▌  ▐░▌
-- ▐░▌   ▀   ▐░▌     ▐░█▀▀▀▀▀▀▀█░▌          ▐░▌          ▐░▌   ▐░▌ ▐░▌
-- ▐░▌       ▐░▌     ▐░▌       ▐░▌          ▐░▌          ▐░▌    ▐░▌▐░▌
-- ▐░▌       ▐░▌     ▐░▌       ▐░▌      ▄▄▄▄█░█▄▄▄▄      ▐░▌     ▐░▐░▌
-- ▐░▌       ▐░▌     ▐░▌       ▐░▌     ▐░░░░░░░░░░░▌     ▐░▌      ▐░░▌
--  ▀         ▀       ▀         ▀       ▀▀▀▀▀▀▀▀▀▀▀       ▀        ▀▀ 
                                                                   
function love.load()
    map = Map:new( 48, 256)
    
    mouse = Mouse()
    camera = CAMERA(mouse.x, mouse.y)
    camera.focus = mouse.id
    camera:set_boundaries( 0, map.w, 0,map.h)
    
    -- lg.setBackgroundColor(0.1,0.25,0.1)
    lg.setDefaultFilter("nearest", "nearest")

    set_light_emiter(math.floor(map.w/32),1,1.6) --the fucking sun
    -- update_lights( )
end
function love.update( dt)
    
    mouse:update( dt)
    camera:move( cam_speed[camera.focus]( dt))

    Timer.update( dt)
end
function love.draw()
    
    camera:attach()

    Map:draw( camera:worldCoords(0,0))
    -- 
    camera:detach()
    mouse:draw()
    lg.setColor(1,1,1)
    lg.print( "x "..camera.x, 10,10)
    lg.print( 'y '..camera.y, 10,20)
    -- lg.print( 'xmin '..camera.boundaries.x_min, 10,40)
    -- lg.print( 'ymin '..camera.boundaries.y_min, 10,50)

    ---HUD
    -- lg.print()
    -- lg.setColor(0,0,0,0.2)
    -- lg.rectangle('fill',20, screen.h - 60, char.max_hp*0.2, 20 )
    -- lg.setColor(1,0.2,0)

    -- lg.rectangle('line',20, screen.h - 60, char.max_hp*0.2, 20 )
    -- lg.rectangle('fill',20, screen.h - 60, char.hp:get()*0.2, 20 )
end

-------------------------------------------------------------------------------------------------
--  ▄▄▄▄▄▄▄▄▄▄▄       ▄▄        ▄       ▄▄▄▄▄▄▄▄▄▄▄       ▄         ▄       ▄▄▄▄▄▄▄▄▄▄▄ 
-- ▐░░░░░░░░░░░▌     ▐░░▌      ▐░▌     ▐░░░░░░░░░░░▌     ▐░▌       ▐░▌     ▐░░░░░░░░░░░▌
--  ▀▀▀▀█░█▀▀▀▀      ▐░▌░▌     ▐░▌     ▐░█▀▀▀▀▀▀▀█░▌     ▐░▌       ▐░▌      ▀▀▀▀█░█▀▀▀▀ 
--      ▐░▌          ▐░▌▐░▌    ▐░▌     ▐░▌       ▐░▌     ▐░▌       ▐░▌          ▐░▌     
--      ▐░▌          ▐░▌ ▐░▌   ▐░▌     ▐░█▄▄▄▄▄▄▄█░▌     ▐░▌       ▐░▌          ▐░▌     
--      ▐░▌          ▐░▌  ▐░▌  ▐░▌     ▐░░░░░░░░░░░▌     ▐░▌       ▐░▌          ▐░▌     
--      ▐░▌          ▐░▌   ▐░▌ ▐░▌     ▐░█▀▀▀▀▀▀▀▀▀      ▐░▌       ▐░▌          ▐░▌     
--      ▐░▌          ▐░▌    ▐░▌▐░▌     ▐░▌               ▐░▌       ▐░▌          ▐░▌     
--  ▄▄▄▄█░█▄▄▄▄      ▐░▌     ▐░▐░▌     ▐░▌               ▐░█▄▄▄▄▄▄▄█░▌          ▐░▌     
-- ▐░░░░░░░░░░░▌     ▐░▌      ▐░░▌     ▐░▌               ▐░░░░░░░░░░░▌          ▐░▌     
--  ▀▀▀▀▀▀▀▀▀▀▀       ▀        ▀▀       ▀                 ▀▀▀▀▀▀▀▀▀▀▀            ▀      
                                                                                     
function love.keypressed(key, scancode, isrepeat)
    if key == "k" then
        -- local r = math.random(2,6)
        -- Label:new("you just drank poison", 2)

    end
    if key == "h" then
        -- local r = math.random(2,6)
        -- Label:new("used: health potion", 2)

    end
    if key == "l" then
        -- local r = math.random(2,6)
        -- Label:new("you just ate meat", 2)
        -- set_light_emiter(10,1,1.4)
        local x,y = mouse:get_grid_position()
        set_light_emiter(x,y,0.5)
        print(t)
    end
    if key == "escape" then
       love.event.quit()
    end
 end
--  
function love.mousepressed( x, y, button, istouch, presses )
    if button == 1 then
        
        -- local gx,gy = camera:mousePosition()
        -- mouse.og_camera_x = camera.x
        -- mouse.og_camera_y = camera.y

        mouse.og_screen_x = x
        mouse.og_screen_y = y
    end
end
function love.mousereleased( x, y, button, istouch, presses )
    if button == 1 and not mouse.drag then
        Map:break_tile( mouse:get_grid_position())
        -- Map:get_tile( mouse:get_grid_position()):set_id( 'air')
    end
    mouse.drag = false
    mouse.counter = 0
end
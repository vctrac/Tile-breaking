lg = love.graphics
screen = {w = love.graphics.getWidth(), h = love.graphics.getHeight()}

Timer = require "../library/HUMP.timer"
local CAMERA = require "../library/HUMP.camera"
local class = require "../library/classic"

function math.clamp(min, val, max) return math.min(math.max(val, min), max) end
function distance(x1,y1,x2,y2) return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end
function box_collision( x1,y1,w1,h1, x2,y2,w2,h2)
    return (x1+w1>x2 and x1<x2+w2 and y1+w1>y2 and y1<y2+h2)
end
function point_inside( px,py, x,y,w,h)
    return (px>x and px<x+w and py>y and py<y+h)
end
bool_to_number={ [true]=1, [false]=0 }

drawFilledRectangle = function(l,t,w,h, r,g,b)
    lg.setColor(r,g,b,0.4)
    lg.rectangle('fill', l,t,w,h)
    lg.setColor(r,g,b)
    lg.rectangle('line', l,t,w,h)
end
-------------------------------------------------------------------------------------------------
-- local tiles_img = lg.newImage("jhonSmith.png")


local bump = require "../library/bump"

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
function Notification:new( txt, duration)
    self.txt = txt
    -- self.y = y
    -- self.w = screen.w
    -- self.h = 30
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
    life = 1,
    txt = ' ',
}
Label.new = function( self, txt, duration)
    
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
                                                                                     


local gravity = 10
-- local item_size = v2(32,16)

local placed_itens = class:extend()
function placed_itens:new(name,x,y)
    self.x, self.y = x,y
    self.name = name
    self.mouse_action = 'collectable'
    self.gx, self.gy = GAME.map:world_to_grid( x+1, y+1)
end

function placed_itens:remove(mx, my)
    local t = GAME.map:get_tile( self.gx, self.gy)
    t.item = nil
end

local torch = placed_itens:extend()
function torch:new( name,x,y)
    torch.super.new( self, name, x, y)
    self.use = true
    GAME.map:add_light( self.gx, self.gy, 0.9, {1,1,0.8})
end
function torch:grab(mx, my)
    self.gx, self.gy = GAME.map:world_to_grid( mx, my)
    local t = GAME.map:remove_light( self.gx,self.gy)
    self.g = true
end
function torch:remove( )
    GAME.map:remove_light( self.gx,self.gy)
    print('light source removed')
end
function torch:drop(mx, my)
    local gx, gy = GAME.map:world_to_grid( mx, my)
    local tile = GAME.map:get_tile( gx, gy)

    if tile.id == 'air' and not tile.item then
        self.gx, self.gy = gx, gy
        tile.item = true
        self.g = false  
        local t = GAME.map:add_light( gx, gy)
        self.x, self.y = GAME.map:grid_to_world(t.x, t.y)
        t.item = true
    end
end


local blocker = placed_itens:extend()
function blocker:new( name,x,y)
    blocker.super.new( self, name, x, y)
    self.is_map_obj = true
    -- self.use = true
    local t = GAME.map:insert_tile( self.gx, self.gy, 'blocker')
    self.fail = not (t)
end

local bomb = placed_itens:extend()
function bomb:new( name,x,y)
    bomb.super.new( self, name, x, y)
    self.mouse_action = 'empty'
    -- self.use = true
end
function bomb:remove()
    -- self:action(0)
end
function bomb:action( time)
    Timer.after((time or 2.8),function() GAME.map:add_light( self.gx, self.gy, 1, {1,1,0.8}) end)
    Timer.after(3,function()
        self:explode()
        GAME.map:remove_light( self.gx,self.gy)
        GAME.sfx.explosion:play()
    end)
end
function bomb:explode()
    for y=-1,1 do
        for x=-1,1 do
            local i = GAME.delete_item_from_map( self.gx+x, self.gy+y)
            -- i.dead = true
            local t = GAME.map:break_tile(self.gx+x, self.gy+y)
        end
    end
    self.dead = true
end

local item_list = {
    torch = torch,
    blocker = blocker,
    bomb = bomb
}



local function item_draw( item)

    -- lg.setColor( 0.3,0.3,0.3)
    -- lg.rectangle("fill", item.x, item.y, 32, 32)
    lg.setColor( 1,1,1)
    lg.draw( GAME.img.tileset, GAME.quads.items[item.name], item.x, item.y)
    -- lg.print( item.name, item.x, item.y)
end

local item_handler = {
    visible_itens = {},
    map_grid = {},
    init = function( self, map)

    end,
    add = function( self, item, x, y) --world coordinates
        local gx,gy = GAME.map:world_to_grid( x, y)
        local tile = GAME.map:get_tile( gx, gy)
        if tile.id == 'air' and not tile.item then
            local item_new = (item_list[item] or placed_itens)( item, GAME.map:grid_to_world( gx, gy))
            if item_new.fail then goto fail end
            if item_new.is_map_obj then goto skip end
            table.insert( self.visible_itens, item_new)
            -- tile = GAME.map:get_tile( gx, gy)
            -- tile.item = item
            ::skip::
            return item_new
        end
        ::fail::
        return false
    end,
    remove = function( self, item)
        local tile = GAME.map:get_tile( item.gx, item.gy)
        if tile.id == 'air' then
            item:remove()
            table.remove( self.visible_itens, item)
            local tile = GAME.map:get_tile( item.gx, item.gy)
            
            tile.item = false
        end
    end,
    get_in_grid = function( self, gx, gy)
        for i,k in ipairs(self.visible_itens) do
            if not k.dead and k.gx==gx and k.gy==gy then
                return k
            end
        end
        return false
    end,
    get_in_units = function( self, x,y)
        for i,k in ipairs(self.visible_itens) do
            if not k.dead and point_inside( x, y, k.x, k.y, GAME.map.tile_size, GAME.map.tile_size) then
                return k
            end
        end
        return false
    end,
    draw = function(self, dt)
        lg.setColor(1,1,1)
        for i,k in ipairs(self.visible_itens) do
            -- if not k.map then
            item_draw(k)
            -- end
        end
    end,
    update = function(self, obj, dt)
        local dead = 0
        for i,k in ipairs(self.visible_itens) do
            -- if k.on_air then
            --     k.y = k.y +gravity*dt
            -- end
            if k.g then
                k.x, k.y = obj.x-GAME.map.tile_size_half, obj.y-GAME.map.tile_size_half
            end
            if k.dead then
                dead = i
            end
        end
        if dead>0 then
            local it = table.remove( self.visible_itens, dead)
            it:remove()
            -- local tile = GAME.map:get_tile( it.gx, it.gy)
            -- tile.item = false
        end
    end,
    mousepressed = function(self, x, y, b)
        if b == 1 then
            for i,k in ipairs(self.visible_itens) do
                if point_inside( x, y, k.x, k.y, GAME.map.tile_size, GAME.map.tile_size) then
                    if k.g then
                        k:drop(x,y)
                    else
                        k:grab(x,y)
                    end
                    return
                end
            end
        end
    end,
}

------------------------------------------------------------------END storage
local number_var = class:extend()
function number_var:new( name, v, min, max)
    self.name = name
    self.v = v
    self.min = min or -math.huge
    self.max = max or math.huge
end
function number_var:add( v)
    self.v = math.clamp(self.min, self.v + v, self.max)
end

local RES = require 'res'

GAME = {}
GAME.img = RES.img
GAME.quads = RES.quads
GAME.sfx = RES.sfx
GAME.font = RES.font
GAME.world = bump.newWorld(64)

local drops = require 'item_drops'
local MOUSE = require 'mouse'
local MAP = require 'map'
local Storage = require 'storage'

-- GAME.cash = number_var(cash, 0)
function GAME.drop_item( item, x, y)
    print( item ..' was dropped at '..x..', '..y)
    drops:add( item, x, y)
end
function GAME.use_item( x, y)
    local item = Storage:get_item()
    if item then
        -- GAME.drop_item(item, x, y)
        local ih = item_handler:add( item, x, y)
        if ih then
            if ih.action then ih:action() end
            Storage:remove( item)
        end
    end
end
function GAME.delete_item_from_map( x, y)
    local item = drops:get_at(x, y)
    if item then
        item.dead = true
    end
end
function GAME.get_item( x, y)
    local it = GAME.has_item( x, y)
    if it then
        Storage:add(it)
        print( it.name .. ' was collected')
        it.dead = true
        local tile = GAME.map:get_tile( it.gx, it.gy)
        tile.item = false

        return true
    end
    return false
end
function GAME.has_item( x, y)
    return drops:get_at(x, y)
end
function GAME.whats_here(x,y,gx, gy)
    local i,t
    -- local tid = 
    local tid = GAME.map.get_name( GAME.map:get_tile_id( gx, gy))

    if tid=='air' then
        local item = drops:get_at(x, y)
        -- print(x, y)
        if item then
            i=item
            t='item'
        else
            i={id = tid, type ='empty'}
            t='air'
        end
    else
        i = {id = tid, type = (GAME.map.is_breakable(tid) and GAME.map.is_solid(tid)) and 'breakable' or 'empty'}
        t = 'block'
    end
    return i,t
end


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
    GAME.map = MAP:new( 48, 256)
    
    mouse = MOUSE( )
    for i=1,10 do
        Storage:add({use = true, name='torch'}, true)
        Storage:add({use = true, name='blocker'}, true)
        Storage:add({use = true, name='bomb'}, true)
    end
    
    GAME.camera = CAMERA(mouse.camera_x, mouse.y, 2)
    GAME.camera.cam_speed = {
        mouse = function( ) return math.floor((mouse.camera_x - GAME.camera.x)*0.1), math.floor((mouse.camera_y - GAME.camera.y)*0.1) end
    }
    GAME.camera.focus = mouse.id
    GAME.camera:set_boundaries( 0, GAME.map.w, 0,GAME.map.h)
    
    -- lg.setBackgroundColor(0.1,0.25,0.6)
    -- lg.setDefaultFilter("nearest", "nearest")

    GAME.map:add_sun( math.floor(GAME.map.w/64),1,1.09,{1,1,1}) --the fucking sun
    -- update_lights( )
end
function love.update( dt)
    
    mouse:update( dt)
    GAME.camera:move( GAME.camera.cam_speed[ GAME.camera.focus]( ))

    drops:update( dt)
    Storage:update( dt)
    Timer.update( dt)
end
function love.draw()
    
    GAME.camera:attach()

    for u=1,16 do
        lg.setColor(0.1,0.5,1, 0.2+u/20)
        lg.rectangle('fill',0, (u-1)*32, GAME.map.w, 32 )
    end
    lg.setColor(1,1,1,0.5)
    lg.draw(GAME.img.sky, 0, 0)
    -- lg.draw(GAME.img.sky, 960, 0)

    GAME.map:draw( GAME.camera:worldCoords(0,0))

    drops:draw( )
    
    -- local visibleThings, len = GAME.world:queryRect(0,0,screen.w,screen.h)
    -- for i=1, len do
    --     drawFilledRectangle( (-1+visibleThings[i].x)*32, (-1+visibleThings[i].y)*32, visibleThings[i].w,visibleThings[i].h, 1,1,0)
    -- end

    mouse:draw()


    GAME.map:draw_light( GAME.camera:worldCoords(0,0))

    -- local hgs = GAME.map.grid_size/2
    -- for n,s in pairs(GAME.map:get_lights()) do
    --     local x,y = GAME.map:grid_to_world( s.id)
    --     lg.setColor(s.c)
    --     lg.circle( "fill", x+hgs, y+hgs, 6,8)
    -- end
    GAME.camera:detach()

   
    lg.setColor(1,1,1)
    -- lg.print( "x "..mouse.x, 100,100)
    -- lg.print( "y "..mouse.y, 100,120)
    -- lg.print( 'y '..GAME.camera.y, 10,20)
    lg.print( mouse:get_state(), 10, screen.h-20)
    Storage:draw()
    mouse:draw_hud()
    -- lg.print( GAME.cash.v, 10, screen.h-40)
    -- lg.print( math.ceil( mouse.tile_hp), 10, screen.h-60)

    -- local mx,my = GAME.map:grid_to_world( mouse:get_grid_position())
    -- lg.print(  mx..' / '.. my, 10,40)
    -- lg.print( 'ymin '..camera.boundaries.y_min, 10,50)

    ---HUD
    lg.print("FPS: "..tostring(love.timer.getFPS( )), screen.w - 70, 10)
    -- lg.setColor(0.1,0.25,0.6)
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
    -- if key == "k" then
    --     item_handler:add("torch", mouse.x, mouse.y)
    -- end
    if key == "h" then
        local d = ({ 'coal', 'stone', 'iron', 'gold'})[math.random(4)]
        local x,y = GAME.map:grid_to_world(mouse:get_grid_position())
        GAME.drop_item(d, x, y)
        -- local r = math.random(2,6)
        -- Label:new("used: health potion", 2)

    end
    if key == "l" then
        -- local r = math.random(2,6)
        -- Label:new("you just ate meat", 2)
        -- set_light_emiter(10,1,1.4)
        
        -- print(t)
    end
    if key == "escape" then
       love.event.quit()
    end
    mouse:key_pressed( key )
end
function love.keyreleased(key, scancode, isrepeat)
    mouse:key_released( key )
end
--  
function love.wheelmoved(x, y)
    mouse:wheelmoved(x, y)
end
function love.mousepressed( x, y, button, istouch, presses )
    mouse:pressed( x, y, button)
    local wx,wy = GAME.camera:worldCoords(x,y)
    -- item_handler:mousepressed( wx, wy, button)
end
function love.mousereleased( x, y, button, istouch, presses )
    mouse:released( x, y, button)
end
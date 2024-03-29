local lg = love.graphics

lg.setDefaultFilter("nearest", "nearest")
math.randomseed(os.time())
math.random()
math.random()
math.random()
math.random()

require("util")

lume = require "LIBRARY/lume"
-- sfxr = require "LIBRARY/sfxr"
timer = require "LIBRARY/HUMP/timer"
cam = require "LIBRARY/HUMP/camera"
vec = require "LIBRARY/HUMP/vector"
class = require "LIBRARY/classic"
-- bump = require "LIBRARY/bump"

Camera = cam(0,0, 1)
Screen = {
    w = lg.getWidth(),
    h = lg.getHeight(),
    center = vec(lg.getWidth(), lg.getHeight())*0.5,
    center2world = vec(lg.getWidth(), lg.getHeight())*0.5,
    set = function( w, h)
        Screen.w = w
        Screen.h = h
        Screen.center = vec(w,h)*0.5
        Screen.center2world = vec(Camera:worldCoords(Screen.center:unpack()))
    end,
    PointInside = function(px,py)
        return PointInside( px,py, 0, 0, Screen.w, Screen.h)
    end
}

local RES = require 'res'
DEBUG = {
    enabled = false,
    lights = false,
    to_draw = {},
}

DEBUG.add = function(method)
    table.insert(DEBUG.to_draw, method)
end

GAME = {
    tile_size = 32,
    half_tile = 16,
    map_w = 128,
    map_h = 128,
}
GAME.real_map_w = GAME.map_w*GAME.tile_size
GAME.real_map_h = GAME.map_h*GAME.tile_size
GAME.img = RES.img
GAME.quads = RES.quads
GAME.sfx = RES.sfx
GAME.font = RES.font
-- GAME.world = bump.newWorld(64)
GAME.canvas = lg.newCanvas(GAME.map_w*GAME.tile_size,GAME.map_h*GAME.tile_size)
-- GAME.LightWorld = LightWorld:new()
local drops = require 'item_drops'
local Mouse = require 'Mouse'
local Map = require 'map'
-- local SandBox = require 'SandBox'
local blurShader1 = love.graphics.newShader("blur1.fs")
require 'light'
local Storage = require 'storage'
-- local Bat = require 'bat'

-- local Entities = {}
------------------------------------------------------------------------------------------------- TODO

function GAME.drop_item( item, x, y)
    printf('%s was dropped at %d, %d',item,x,y)
    -- drops:add( item, x, y)
end
function GAME.use_item( gx, gy)
    local item = Storage:get_item()
    if item then
        local sx,sy = MAP:grid_to_world( gx, gy)
        local tile = MAP:get_tile( gx, gy)
        if tile and tile.id == 'air' then
            local ih = drops:add_fixed( item, sx, sy)
            if ih then
                if ih.action then ih:action() end
                Storage:remove( item)
            end
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
        -- printf( "%s was collected",it.name)
        it.dead = true
        local tile = MAP:get_tile( it.gx, it.gy)
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
    local tile = MAP:get_tile(gx,gy)
    -- local tid = MAP.get_name( tile.id)
    local breakable = MAP.is_breakable(tile.id)

    if MAP.get_name(tile.id)=='air' then
        local item = drops:get_at(x, y)
        -- print(x, y)
        if item then
            i=item
            t='item'
        else
            i={id = tile.id, type ='empty'}
            t='air'
        end
    elseif breakable then
        i = {id = tile.id, type = 'breakable'}
        t = 'block'
    else
        i = {id = tile.id, type = 'dark'}
        t = 'null'
    end
    return i,t
end
GAME.update_lights = function( )
    Light.refresh()
end
GAME.break_tile = function(x,y)
    local t = MAP:get_tile(x,y)
    local solid = MAP.is_solid(t.id)
    local color = MAP.get_color(t.id)

    -- Light.refresh()
    if MAP:break_tile(x,y) then
        Light.refresh()
        MAP:update_canvas()
        -- SandBox:update_quads(x, y)
        -- if solid then
        --     for _=1,math.random(8,32) do
        --         SandBox:add("dust",x*GAME.tile_size-GAME.half_tile,y*GAME.tile_size-GAME.half_tile, {color = color})
        --     end
        -- end
    end
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
-- local g3d = require "g3d"
-- local tile3d = g3d.newModel("res/obj/cube.obj", "res/img/moon.png", {0,0,0})
local time = 0
-- local layers_num = 4
-- local depth_3D = -0.004
local BackgroundImage
function love.load()
    --Initialize Map dimensions
    MAP = Map:new( GAME.map_w, GAME.map_h)

    --Initialize Sandbox
    -- SandBox:init( GAME.map_w, GAME.map_h)
    -- for _,s in pairs( MAP.units) do
    --     SandBox:update_quads(s.x, s.y, MAP.is_solid(s.id))
    -- end
    -- print(lg.getWidth(), Screen.w*0.5)
    --Initialize shaders based on Map dimensions
    blurShader1:send("Width", GAME.map_w*GAME.tile_size)
    blurShader1:send("Height", GAME.map_h*GAME.tile_size)

    --Initialize Dark layer
    Light.init(GAME.map_w, GAME.map_h)
    Light.add_sky(1, 1.1)
    DEBUG.add(Light.debug)

    Camera.speed = 2
    Camera.x_vel = 0
    Camera.y_vel = 0
    Camera.follow = {
        mouse = function( dt)
            return lume.round((Mouse.camera_x - Camera.x)*dt,0.5), lume.round((Mouse.camera_y - Camera.y)*dt,0.5)
        end
    }
    -- Camera.focus = "mouse"
    Camera.focus = "mouse"
    Camera:lookAt(GAME.real_map_w*0.5,GAME.real_map_h*0.1)
    -- Camera:set_boundaries( 0, MAP.w, 0,MAP.h)

    --Initialize Mouse and mouse_grid
    Mouse.init(GAME.map_w, GAME.map_h, GAME.tile_size)
    Light.add(Mouse.id, Mouse.grid_position.x, Mouse.grid_position.y)
    for _=1,10 do
        Storage:add({use = true, name='light'}, true)
        -- Storage:add({use = true, name='blocker'}, true)
        -- Storage:add({use = true, name='bomb'}, true)
    end

    
    -- lg.setBackgroundColor(0.1,0.25,0.6)
    -- lg.setDefaultFilter("nearest", "nearest")
    BackgroundImage = GradientMesh("vertical", {0,0.55,0.65}, {0,0.15,0.1})
    -- MAP:add_sun( math.floor(MAP.w/64),1,1,{1,1,1}) --the fucking sun
    MAP:update_canvas()
    -- GAME.world:add(player, player.x, player.y, player.w, player.h)
    -- myShader = love.graphics.newShader("blur.fs")
    -- myShader = love.graphics.newShader("shader.fs")
    -- Bloom = require"glow"()
    -- update_lights( )
end
function love.update( dt)
    time = time+dt
    blurShader1:send("time", 1.4+math.sin(time*2)*0.1)
    -- GAME.LightWorld:update(dt)
    Mouse.update( dt)
    -- item_handler:update(dt)
    -- Camera:move( Camera.follow[ Camera.focus]( dt))
    -- GAME.world:update(dt)
    -- local mx,my = Mouse.x, Mouse.y
    -- if time>0.1 then
    --     if love.keyboard.isDown('1') then
    --         for _=1,math.random(10) do
    --             SandBox:add("sand",mx,my)
    --         end
    --     elseif love.keyboard.isDown('2') then
    --         for _=1,math.random(10) do
    --             SandBox:add("water",mx,my)
    --         end
    --     end
    --     time = 0
    -- end
    -- if #Entities>0 then
    --     for _,e in ipairs(Entities) do
    --         e:update(dt)
    --     end
    -- end
    -- g3d.camera.firstPersonMovement(dt)
    Light.update( )
    -- SandBox:update( dt)
    drops:update( dt)
    Storage:update( dt)
    -- Player.update(dt)
    timer.update( dt)
end
function love.draw()
    lg.setColor(1,1,1)
    lg.draw(BackgroundImage,0,0,0,Screen.w, Screen.h)
    
    Camera:attach()
    -- local wx,wy = Camera:worldCoords(Screen.center.x, Screen.center.y)
    -- local cx,cy = MAP.center.x,MAP.center.y

    -- for i=layers_num,1,-1 do
        
    --     local depth = depth_3D*i*Camera.scale
    --     local sc = 1+depth
    --     local dx = (wx-cx)*depth
    --     local dy = (wy-cy)*depth
    --     local xx = cx-dx
    --     local yy = cy-dy
        
    --     if i==layers_num then
    --         lg.setColor(0.2,0.2,0.2)
    --         lg.draw( MAP.dark_canvas,xx,yy,0,sc,sc,cx, cy)
    --     else
    --         local rgb = 1-i*0.1
    --         lg.setColor(rgb,rgb,rgb)
    --         lg.draw( MAP.light_canvas,xx,yy,0,sc,sc,cx, cy)
    --     end
    -- end
    -- lg.setColor(1,1,1)
    -- lg.draw( MAP.canvas)
    -- lg.draw( MAP.sprite_canvas)
    MAP:draw()
    -- Player.draw()
    
    -- if DEBUG.enabled then
        -- local visibleThings, len = GAME.world:getItems()
        -- for i=1, len do
        --     local xx = visibleThings[i].x
        --     local yy = visibleThings[i].y
        --     local ww = visibleThings[i].w or GAME.tile_size
        --     local hh = visibleThings[i].h or GAME.tile_size

        --     if visibleThings[i].id then
        --         xx = xx*GAME.tile_size-GAME.tile_size
        --         yy = yy*GAME.tile_size-GAME.tile_size
        --     end
        --     Rectangle.outline( xx,yy, ww,hh, {0,0.7,1})
        -- end
    -- end
    -- SandBox:draw()
    drops:draw()
    -- if #Entities>0 then
    --     for _,e in ipairs(Entities) do
    --         e:draw()
    --     end
    -- end
    Mouse.draw()
    if DEBUG.lights then
        -- apply blur shader over light layer
        lg.setShader(blurShader1)
        Light.draw()
        lg.setShader()
    end

    if DEBUG.enabled then
        for _,draw in ipairs(DEBUG.to_draw) do
            draw()
        end
    end


    Camera:detach()

    lg.setColor(1,1,1)
    lg.print( "camera.x "..Camera.x, 10,20)
    lg.print( "camera.y "..Camera.y, 10,40)
    lg.print( "camera zoom "..Camera.scale, 10,60)
    lg.print( "mouse.gx "..Mouse.grid_position.x, 10,80)
    lg.print( "mouse.gy "..Mouse.grid_position.y, 10,100)
    
    lg.print( Mouse.get_state(), 10, Screen.h-20)
    -- Storage:draw()
    Mouse.draw_hud()
    -- tile3d:draw()

    ---HUD
    lg.print("FPS: "..tostring(love.timer.getFPS( )), Screen.w - 70, 10)
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
    if key == "r" then
        MAP = MAP:new( GAME.map_w, GAME.map_h)
        MAP:update_canvas()
        Light.refresh()
        -- table.insert(Entities, Bat(Mouse.x, Mouse.y))
    end
    if key == "l" then
        DEBUG.lights = not DEBUG.lights
    end
    if key == "h" then
        local d = ({ "coal", "stone", "iron", "gold"})[math.random(4)]
        local x,y = MAP:grid_to_world(Mouse.get_grid_position())
        GAME.drop_item(d, x, y)
        -- local r = math.random(2,6)
        -- Label:new("used: health potion", 2)

    end
    if key == "f" then
        love.window.setVSync( love.window.getVSync()==1 and 0 or 1 )
    end
    if key == "f2" then
        DEBUG.enabled = not DEBUG.enabled
        
        printf("debug is %s",(DEBUG.enabled and "enabled" or "disabled"))
    end
    if key == "escape" then
       love.event.quit()
    end
    Mouse.key_pressed( key )
end
function love.keyreleased(key, scancode, isrepeat)
    Mouse.key_released( key )
end
--  
function love.wheelmoved(x, y)
    Mouse.wheelmoved(x, y)
end
-- function love.mousemoved(x,y, dx, dy)
    -- g3d.camera.firstPersonLook(dx,dy)
    -- Light.set_active(Mouse,gy)
-- end
function love.mousepressed( x, y, button, istouch, presses )
    Mouse.pressed( x, y, button)
    local wx,wy = Camera:worldCoords(x,y)
    -- item_handler:mousepressed( wx, wy, button)
end
function love.mousereleased( x, y, button, istouch, presses )
    Mouse.released( x, y, button)
end

function love.resize(w, h)
    printf("Window resized to width: %d and height: %d.", w, h )
    Screen.set(w,h)
    Storage.resize_screen(w,h)
end
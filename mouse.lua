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
local lm = love.mouse
local lk = love.keyboard
local lg = love.graphics

local min_scale = 0.25
local max_scale = 6

local TOOLS = {
    pickaxe = {
        id = 'pickaxe',
        name = 'iron pickaxe',
        speed = 5,
        force = 0.1, -- smaller is stronger
    },
    hand = {
        id = 'hand',
        name = 'hand',
    },
    sword = {
        id = 'sword',
        name = 'sword',
    }
}
-- local Camera
local set_cursor = love.mouse.setCursor
local cursor = {
    scrolling = love.mouse.newCursor( GAME.img.cursor_sizeall, 15, 15 ),
    pickaxe = love.mouse.newCursor( GAME.img.cursor_pickaxe, 5, 20 ),
    pickaxe_hit = love.mouse.newCursor( GAME.img.cursor_pickaxe_hit, 4, 20 ),
    sword = love.mouse.newCursor( GAME.img.cursor_sword, 12, 22 ),
    sword_hit = love.mouse.newCursor( GAME.img.cursor_sword, 12, 22 ),
    hand = love.mouse.newCursor( GAME.img.cursor_hand, 15, 15 ),
    hand_grab = love.mouse.newCursor( GAME.img.cursor_hand_grab, 15, 15),
    cross = love.mouse.newCursor( GAME.img.cursor_cross, 15, 15 ),
    null = love.mouse.newCursor( GAME.img.cursor_null, 15, 15 ),
    zoom_in = love.mouse.newCursor( GAME.img.cursor_zoom_in, 15, 15 ),
    zoom_out = love.mouse.newCursor( GAME.img.cursor_zoom_out, 15, 15 ),
    eye1 = love.mouse.newCursor( GAME.img.cursor_eye1, 15, 15 ),
    eye2 = love.mouse.newCursor( GAME.img.cursor_eye2, 15, 15 ),
    eye3 = love.mouse.newCursor( GAME.img.cursor_eye3, 15, 15 ),
    eye4 = love.mouse.newCursor( GAME.img.cursor_eye4, 15, 15 ),
    eye5 = love.mouse.newCursor( GAME.img.cursor_eye5, 15, 15 ),
}
local state_by_type = {
    collectable = 'hand',
    empty = 'eye',
    dark = 'null',
    enemy = 'sword',
    breakable = 'pickaxe'
}

local tile_hp = 0
local old_tile_hp = 0
local light_level = 0
local old_gp = vec(1,1)
-- local tool_index = 2
local og_screen_x = 0
local og_screen_y = 0
local target_scale = 1
local start_pan = vec()
local offset = vec()
local cam_vel = vec()
local cam_pos = vec()
local img_scale = 1.1
local cursor_actual = ''
local cursor_old = ''
local last_cam_focus = 'mouse'
local tile_size
local tile_size_half
local hover_item_name = lg.newText( GAME.font,'')
local show_item_name = false
local CAM_MOVE_SPEED = 150
local CAM_STOP_SPEED = 5

local Mouse = {}
function Mouse.init( mw, mh, ts)
    Mouse.id = 'mouse'
    Mouse.tile = "air"
    Mouse.tile_id = "air"

    Mouse.camera_x = GAME.map.w/2
    Mouse.camera_y = 100 
    -- old_gp = v2(1,1)
    Mouse.grid_position = vec(1,1)
    Mouse.scale = 1
    Mouse.wheel = 1
    -- tool_index = 1
    Mouse.wheel_sensibility = 1

    Mouse.grab = false
    Mouse.drag = false
    Mouse.state = 'pickaxe'

    Mouse.visual_grid = {}
    -- Mouse.visual_grid_alive = {}
    -- for x=1,mw do
    --     for y=1,mh do
    --         local tx,ty = (x-1)*ts, (y-1)*ts
    --         Mouse.visual_grid[x..':'..y] = {l=0,x=tx,y=ty,c={1,1,1}}
    --     end
    -- end

    tile_size = ts
    tile_size_half = ts*0.5

    cam_pos = vec(Camera.x, Camera.y)
end
Mouse._pressed = {
    pickaxe = function( x, y, b)
        if b==1 then
            tile_hp = old_tile_hp -0.9
        end
        -- local gx,gy = Mouse.grid_position:unpack()
        -- if not GAME.map:is_lighted( gx,gy) then return end
    end,
    -- sword = function( x, y, b)
        -- local gx,gy = Mouse.grid_position:unpack()
        -- Mouse:uptade_tile()
    -- end,
    hand = function( x, y, b)
        -- local it = GAME.get_item( Mouse.x, Mouse.y)
        if b==1 then
            local it = GAME.get_item( Mouse.x, Mouse.y)
            -- it:grab( Mouse.x, Mouse.y)
            cursor_actual = 'hand_grab'
            timer.after(0.1, function() cursor_actual = Mouse.state end)
        end
    end,
    -- scrolling = function( x, y, b)
    -- end,
    -- zooming = function( x, y, b)
        
        -- cam_vel.x, cam_vel.y = 0,0
        -- cam_pos = vec(Camera.x, Camera.y)
    -- end,
    -- cross = function( x, y, b)
    -- end,
}
Mouse._released = {
    -- pickaxe = function( x, y, b)
    --     -- local gx,gy = Mouse.grid_position:unpack()
    --     -- if not GAME.map:is_lighted( gx,gy) then return end
    --     -- Mouse:uptade_tile()
    -- end,
    -- sword = function( x, y, b)
    --     -- local gx,gy = Mouse.grid_position:unpack()
    --     -- Mouse:uptade_tile()
    -- end,
    hand = function( x, y, b)
        -- if b==1 then
            -- timer.after(0.1, function() Mouse:uptade_tile() end)
            
        -- end
        if not GAME.has_item( Mouse.x, Mouse.y) then
            Mouse.set_state( 'eye')
            Mouse.uptade_tile()
        end
    end,
    scrolling = function( x, y, b)
        if b == 3 then
            Mouse.drag = false
            cam_vel = vec()
            Camera.focus = last_cam_focus
            Mouse.set_state( 'eye')
            Mouse.uptade_tile()
            Camera:lookAt( lume.round(Mouse.camera_x,0.1), lume.round(Mouse.camera_y,0.1))
        end
    end,
    -- zooming = function( x, y, b)
    -- end,
    eye = function( x, y, b)
        if b==2 then

            -- Mouse:uptade_tile()
            GAME.use_item( Mouse.grid_position.x, Mouse.grid_position.y)
            Mouse.uptade_tile()
        end
    end,
}
-- Mouse._down = {
Mouse.pickaxe = function( dt)

    if lm.isDown( 1) and not Mouse.drag then
        -- if not Mouse.tile_light then return end
        -- local tile = GAME.map:get_tile(Mouse.grid_position.x, Mouse.grid_position.y)
        if not GAME.world:hasItem(Mouse.tile) then
            return
        end

        if GAME.map.is_breakable( Mouse.tile_id) and tile_hp>0 then
            tile_hp = tile_hp - TOOLS['pickaxe'].speed*dt
            
            if math.ceil(tile_hp)~=old_tile_hp then
                cursor_actual = 'pickaxe_hit'
                timer.after(0.1, function() cursor_actual = 'pickaxe' end) --set_cursor(cursor.pickaxe)

                GAME.sfx.hit_block:play()
                img_scale = 1.1
                old_tile_hp = math.ceil(tile_hp)
            end
            if tile_hp<=0 then
                GAME.break_tile( Mouse.grid_position:unpack())
                local gp = Mouse.grid_position:clone()
                timer.after(0.5,function()
                    if gp==Mouse.grid_position then
                         Mouse:uptade_tile()
                    end
                end)
                
            end
        end
    end
    -- if not(old_gp==Mouse.grid_position) or Mouse.tile=='air' then
    --     old_gp = Mouse.grid_position
    --     Mouse.uptade_tile()
    -- end
end
Mouse.sword = function( dt)
    -- if not(old_gp==Mouse.grid_position) or Mouse.tile=='air' then
    --     old_gp = Mouse.grid_position
    --     Mouse.uptade_tile()
    -- end
end
Mouse.hand = function( dt)
    -- if not(old_gp==Mouse.grid_position) or Mouse.tile=='air' then
    --     old_gp = Mouse.grid_position
    --     Mouse.uptade_tile()
    -- end
end
Mouse.zooming = function( dt)
    if Mouse.scale~=target_scale then
        local dif = target_scale - Mouse.scale
        if (math.abs(dif)<0.01) then
            Mouse.scale = target_scale
        else
            Mouse.scale = Mouse.scale + dif*10*dt
        end
        local before_zoom_x, before_zoom_y = Mouse.x, Mouse.y

        Camera:zoomTo( Mouse.scale)

        local after_zoom_x, after_zoom_y = Camera:mousePosition()
        
        local dx = before_zoom_x -after_zoom_x
        local dy = before_zoom_y -after_zoom_y
        
        Camera:lookAt( lume.round(Camera.x +dx,0.1), lume.round(Camera.y +dy,0.1))
        -- Camera:move( dx, dy)
        
        cam_vel.x, cam_vel.y = 0,0
        cam_pos.x, cam_pos.y = Camera.x, Camera.y
    else
        Mouse.uptade_tile()
    end
end
Mouse.scrolling = function( dt)

    if Mouse.drag then
        -- local dx = (Mouse.screen_x - og_screen_x)/Camera.scale
        -- local dy = (Mouse.screen_y - og_screen_y)/Camera.scale
        local dx = (Mouse.screen_x - start_pan.x)
        local dy = (Mouse.screen_y - start_pan.y)
        Mouse.camera_x = offset.x - dx/Mouse.scale
        Mouse.camera_y = offset.y - dy/Mouse.scale
        Camera:lookAt( Mouse.camera_x, Mouse.camera_y)
        cam_vel.x, cam_vel.y = 0,0
        cam_pos = vec(Camera.x, Camera.y)
    else
        if lm.isDown( 3) or lk.isDown('lctrl') then
            local cx = math.abs( Mouse.screen_x-og_screen_x)--/Camera.scale
            local cy = math.abs( Mouse.screen_y-og_screen_y)--/Camera.scale
            local moved = cx>1 or cy>1
            if moved then
                last_cam_focus = Camera.focus
                Mouse.scale = target_scale
                Mouse.drag = true
                Camera.focus = Mouse.id
                offset.x = Camera.x
                offset.y = Camera.y
                
                -- print(last_cam_focus, Camera.focus)
                -- og_screen_x = Mouse.screen_x
                -- og_screen_y = Mouse.screen_y
            end
        end
    end
end
Mouse.eye = function( dt)
    -- local gx,gy = Mouse.grid_position:unpack()
    -- if not GAME.map:is_lighted( gx,gy) then return end
    -- if GAME.check_item( Mouse.x, Mouse.y) then
    --     Mouse:set_state( 'hand')
    -- end
    -- if not(old_gp==Mouse.grid_position) then
        -- GAME.map:remove_light(old_gp.x, old_gp.y)
        -- old_gp = Mouse.grid_position
        -- Mouse.uptade_tile()
        -- GAME.map:add_light(old_gp.x, old_gp.y,0.5,{1,1,5})
        -- GAME.map:update_lights()
    -- end

end
Mouse.null = function( dt)
    --does nothing
end

function Mouse.update( dt)
    if cursor_actual ~= cursor_old then
        set_cursor( cursor[cursor_actual])
        cursor_old = cursor_actual
    end
    if img_scale>1 then --tile hitting effect
        img_scale = img_scale - dt
    end

    Mouse.x, Mouse.y = Camera:mousePosition()
    Mouse.screen_x, Mouse.screen_y = lm.getPosition()
    local gx, gy = math.ceil(Mouse.x/tile_size), math.ceil(Mouse.y/tile_size)
    Mouse.grid_position = vec(gx, gy)
    

    --WASD movement
    if Mouse.state~="scrolling" and Mouse.state~="zooming" then
        if love.keyboard.isDown('lshift') then CAM_MOVE_SPEED = 500 end
        if love.keyboard.isDown('w') then
            cam_vel.y = math.max(cam_vel.y - CAM_MOVE_SPEED*dt, -CAM_MOVE_SPEED)
        elseif love.keyboard.isDown('s') then
            cam_vel.y = math.min(cam_vel.y + CAM_MOVE_SPEED*dt, CAM_MOVE_SPEED)
        elseif cam_vel.y~=0 then
            cam_vel.y = cam_vel.y -cam_vel.y*CAM_STOP_SPEED*dt
        end
        if love.keyboard.isDown('a') then
            cam_vel.x = math.max(cam_vel.x - CAM_MOVE_SPEED*dt, -CAM_MOVE_SPEED)
        elseif love.keyboard.isDown('d') then
            cam_vel.x = math.min(cam_vel.x + CAM_MOVE_SPEED*dt, CAM_MOVE_SPEED)
        elseif cam_vel.x~=0 then
            cam_vel.x = cam_vel.x -cam_vel.x*CAM_STOP_SPEED*dt
        end
        if cam_vel.y~=0 or cam_vel.x~=0 then
            cam_pos = cam_pos + cam_vel*dt
            if math.abs(cam_vel.x)<0.01 then
                cam_vel.x = 0
                -- cam_pos.x = lume.round(cam_pos.x, 0.5)
            end
            if math.abs(cam_vel.y)<0.01 then
                cam_vel.y = 0
                -- cam_pos.y = lume.round(cam_pos.y, 0.5)
            end
            Camera:lookAt( lume.round(cam_pos.x, 0.1), lume.round(cam_pos.y, 0.1))
        end
    -- else
        if not(old_gp==Mouse.grid_position) then
            old_gp = Mouse.grid_position:clone()
            Mouse.uptade_tile()
        end
    end
    Mouse[ Mouse.state](dt) -- update current state
    
    local trash = {}
    for key,gt in pairs(Mouse.visual_grid) do
        if key~=(old_gp.x..':'..old_gp.y) then
            gt.l = gt.l-2*dt
            if gt.l<=0 then
                table.insert(trash, key)
            end
        end
    end
    
    for x=1,#trash do
        Mouse.visual_grid[trash[x]] = nil
    end
    -- for x=1,#Mouse.visual_grid do
    --     for y=1,#Mouse.visual_grid[x] do
    --         Mouse.visual_grid[x][y] = 0
    --     end
    -- end
end
function Mouse.get_grid_position()
    print( Mouse.grid_position)
    return Mouse.grid_position:unpack()
end
-- function Mouse.pickaxe_release()

-- end
function Mouse.draw_hud()
    if show_item_name and Mouse.state=='hand' then
        local w = hover_item_name:getWidth()*0.5
        lg.setColor(1,1,1,1)
        
        lg.draw( hover_item_name, Mouse.screen_x - w , Mouse.screen_y + 20)
    end
end
function Mouse.draw()
    
    
    -- local t = GAME.map:get_tile( Mouse.grid_position:unpack())
    -- if t and GAME.map.is_solid( t.id) then
    --     local tx,ty = (t.x-1)*tile_size, (t.y-1)*tile_size
    --     lg.setColor(1,1,1)
    --     lg.draw( GAME.img.tileset, GAME.quads[t:get_id()], tile_size_half+tx, tile_size_half+ty, 0, img_scale, img_scale,tile_size_half,tile_size_half)
    --     -- lg.setColor(1,1,1,0.5)
    --     -- lg.rectangle('line', tx, ty, tile_size, tile_size)
    -- end

    for _,gt in pairs(Mouse.visual_grid) do
        if gt.l>0 then
            lg.setColor(gt.c[1],gt.c[2],gt.c[3],gt.l)
            lg.draw( GAME.img.tileset, GAME.quads["frame"], tile_size_half+gt.x, tile_size_half+gt.y, 0, img_scale, img_scale,tile_size_half,tile_size_half)
        end
    end
end
function Mouse.wheelmoved(_, dy)

    
    local df = target_scale*0.1
    target_scale = lume.clamp(target_scale + dy *df,min_scale,max_scale)
    if math.abs(target_scale - lume.round(target_scale))<(df*0.9) then
        target_scale = lume.round(target_scale)
    end
    cursor_actual = dy<0 and "zoom_out" or "zoom_in"

    if Mouse.scale ~= target_scale and Mouse.get_state( ) ~= 'zooming' then
        if Mouse.drag then --disable drag if scrolling's state is active to avoid no cursor bug
            Mouse.drag = false
            cam_vel = vec()
            Camera.focus = last_cam_focus
        end
        Mouse.set_state( 'zooming')
    end
end
function Mouse.key_pressed( k )
    if k == 'lctrl' and not Mouse.drag then
        start_pan = vec(Mouse.screen_x, Mouse.screen_y)
        Mouse.set_state( 'scrolling')
    end
end 
function Mouse.key_released( k )
    if k == 'lctrl' and Mouse.drag then
        Mouse.drag = false
        Mouse.set_state( 'eye')
    end
    -- if k == 
end 

function Mouse.pressed( x, y, button )
    if button == 3 then
        start_pan = vec(Mouse.screen_x, Mouse.screen_y)
        Mouse.set_state( 'scrolling')
    end
    if Mouse._pressed[ Mouse.state] then Mouse._pressed[ Mouse.state]( x,y,button) end
end
function Mouse.released( x, y, button)
    if Mouse._released[ Mouse.state] then Mouse._released[ Mouse.state]( x,y,button) end
end
function Mouse.set_state( state)
    Mouse.state = state
    if state == "eye" then
        local n = ''
        if light_level<0.1 then n = '5'
        elseif light_level<=0.3 then n = '4'
        elseif light_level<0.6 then n = '3'
        elseif light_level<0.8 then n = '2'
        else n = '1' end
        cursor_actual = state..n
    else
        cursor_actual = state
    end
end
function Mouse.get_state()
    return Mouse.state
end
function Mouse.uptade_tile()
    local gx,gy = Mouse.grid_position:unpack()
    local state = Mouse.state
    if not Mouse.drag then
        local tile=GAME.map:get_tile( gx,gy)
        if tile then
            -- Light.set(Mouse.id,{x=Mouse.grid_position.x, y=Mouse.grid_position.y})
            show_item_name = false
            local obj, tipo = GAME.whats_here( Mouse.x, Mouse.y, gx, gy)
            -- print(tipo, gx,gy)
            if tipo == 'item' then
                show_item_name = true
                hover_item_name:set( obj.name)
            elseif tipo == 'block' then
                Mouse.tile = tile
                Mouse.tile_id = tile.id
                tile_hp = GAME.map.get_info( Mouse.tile_id, 'durability')*TOOLS['pickaxe'].force
                old_tile_hp = math.ceil(tile_hp)
            -- elseif tipo=='air' then
            end

            light_level = Light.get_light_level(gx,gy)
            local tx,ty = (gx-1)*tile_size, (gy-1)*tile_size
            if tile.id~="air" then
                if not Mouse.visual_grid[gx..':'..gy] then
                    Mouse.visual_grid[gx..':'..gy] = {c=GAME.map.get_color(tile.id),l=1,x=tx,y=ty}
                else
                    Mouse.visual_grid[gx..':'..gy].l = 1
                    Mouse.visual_grid[gx..':'..gy].c = GAME.map.get_color(tile.id)
                end
            end
            -- print(light_level)
            state = state_by_type[ obj.type]
        else
            state = 'eye'
            light_level = 1
            Mouse.tile_id = 'air'
            Mouse.tile = {}
        end
        --if enemy then set state to sword end
    end
    Mouse.set_state( state)
    
end

return Mouse
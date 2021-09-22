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

local TOOLS = {
    pickaxe = {
        id = 'pickaxe',
        name = 'iron pickaxe',
        speed = 5,
        force = 0.2, -- smaller is stronger
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
local class = require "../library/classic"
local v2 = require "../library/vector"
-- local map
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
}
local state_by_type = {
    collectable = 'hand',
    empty = 'cross',
    enemy = 'sword',
    breakable = 'pickaxe'
}
local tile_hp = 0
local old_tile_hp = 0
-- local counter = 0
local old_gp = v2(1,1)
local tool_index = 2
local og_screen_x = 0
local og_screen_y = 0
-- local screen_x = 0
-- local screen_y = 0
local og_camera_x = 0
local og_camera_y = 0
local img_scale = 1.1
local img_counter = 0
local suffix = ''
local cursor_actual = ''
local cursor_old = ''
local tile_size
local tile_size_half
local hover_item_name = lg.newText( GAME.font,'')
local show_item_name = false

local Mouse = class:extend()
function Mouse:new( map)
    self.id = 'mouse'
    self.tile = "air"
    self.tile_name = "air"

    self.camera_x = GAME.map.w/2
    self.camera_y = 0 
    -- old_gp = v2(1,1)
    self.grid_position = v2(1,1)

    self.wheel = 1
    -- tool_index = 1
    self.wheel_sensibility = 1

    self.grab = false
    self.drag = false
    self.state = 'pickaxe'
    self.tools = {TOOLS.hand, TOOLS.pickaxe, TOOLS.sword}
    self.items = {torch = 1}
    self.item_selected = 'torch'

    tile_size = GAME.map.tile_size
    tile_size_half = GAME.map.tile_size_half

    print( self.grid_position)
end
Mouse._pressed = {
    pickaxe = function(self, x, y, b)
        if b==1 then
            tile_hp = old_tile_hp -0.9
        end
        -- local gx,gy = self.grid_position:unpack()
        -- if not GAME.map:is_lighted( gx,gy) then return end
    end,
    sword = function(self, x, y, b)
        -- local gx,gy = self.grid_position:unpack()
        -- self:uptade_tile()
    end,
    hand = function(self, x, y, b)
        local it = GAME.get_item( self.x, self.y)
        if b==1 then
            -- local it = GAME.get_item( self.x, self.y)
            -- it:grab( self.x, self.y)
            cursor_actual = 'hand_grab'
            Timer.after(0.1, function() cursor_actual = self.state end)
        end
    end,
    scrolling = function(self, x, y, b)
    end,
    cross = function(self, x, y, b)
    end,
}
Mouse._released = {
    pickaxe = function(self, x, y, b)
        -- local gx,gy = self.grid_position:unpack()
        -- if not GAME.map:is_lighted( gx,gy) then return end
        -- self:uptade_tile()
    end,
    sword = function(self, x, y, b)
        -- local gx,gy = self.grid_position:unpack()
        -- self:uptade_tile()
    end,
    hand = function(self, x, y, b)
        -- if b==1 then
            -- Timer.after(0.1, function() self:uptade_tile() end)
            
        -- end
        if not GAME.has_item( self.x, self.y) then
            self:set_state( 'cross')
            self:uptade_tile()
        end
    end,
    scrolling = function(self, x, y, b)
        if b == 3 then
            self.drag = false
            -- counter = 0
            self:set_state( 'cross')
            self:uptade_tile()
        end
    end,
    cross = function(self, x, y, b)
        if b==2 then

            -- self:uptade_tile()
            GAME.use_item( self.x, self.y)
            self:uptade_tile()
        end
    end,
}
-- Mouse._down = {
Mouse.pickaxe = function(self, dt)

    if love.mouse.isDown( 1) and not self.drag then
        if not self.tile_light then return end
        -- if not GAME.map:is_lighted( self:get_grid_position()) then return end

        if GAME.map.is_breakable( self.tile) and tile_hp>0 then
            tile_hp = tile_hp - TOOLS['pickaxe'].speed*dt
            
            if math.ceil(tile_hp)~=old_tile_hp then
                cursor_actual = 'pickaxe_hit'
                Timer.after(0.1, function() cursor_actual = 'pickaxe' end) --set_cursor(cursor.pickaxe)

                GAME.sfx.hit_block:play()
                img_scale = 1.1
                old_tile_hp = math.ceil(tile_hp)
            end
            if tile_hp<=0 then
                GAME.map:break_tile( self.grid_position:unpack())
                local gp = self.grid_position:clone()
                Timer.after(0.5,function()
                    if gp==self.grid_position then
                         self:uptade_tile()
                    end    
                end)
                
            end
        end
    end
end
Mouse.sword = function(self, dt) end
Mouse.hand = function(self, dt) end
Mouse.scrolling = function(self, dt)
    if (love.keyboard.isDown('lctrl') or love.mouse.isDown( 3)) and not self.drag then
        local cx = math.abs( self.screen_x-og_screen_x)--/GAME.camera.scale
        local cy = math.abs( self.screen_y-og_screen_y)--/GAME.camera.scale
        local moved = cx>1 or cy>1
        if moved then
            self.drag = true
            GAME.camera.focus = self.id
            og_camera_x = GAME.camera.x
            og_camera_y = GAME.camera.y

            og_screen_x = self.screen_x
            og_screen_y = self.screen_y
        end
    end

    if self.drag then
        local dx = (self.screen_x - og_screen_x)/GAME.camera.scale
        local dy = (self.screen_y - og_screen_y)/GAME.camera.scale

       self.camera_x = og_camera_x - dx
       self.camera_y = og_camera_y - dy
    end
end
Mouse.cross = function(self, dt)
    -- local gx,gy = self.grid_position:unpack()
    -- if not GAME.map:is_lighted( gx,gy) then return end
    -- if GAME.check_item( self.x, self.y) then
    --     self:set_state( 'hand')
    -- end
end
-- }
function Mouse:update( dt)
    if cursor_actual ~= cursor_old then
        set_cursor( cursor[cursor_actual])
        cursor_old = cursor_actual
    end
    if img_scale>1 then --tile hitting effect
        img_scale = img_scale - dt
    end

    self.x, self.y = GAME.camera:mousePosition()
    self.screen_x, self.screen_y = love.mouse.getPosition()
    local gx, gy = math.ceil(self.x/32), math.ceil(self.y/32)
    self.grid_position = v2(gx, gy)
    if self:get_state( ) ~= 'scrolling' and (not (old_gp==self.grid_position) or self.tile=='air') then

        old_gp:replace(self.grid_position)
        self:uptade_tile()
    end

    self[ self.state](self,dt) -- update current state
    
end
function Mouse:get_grid_position()
    print( self.grid_position)
    return self.grid_position:unpack()
end
function Mouse:pickaxe_release()

end
function Mouse:draw_hud()
    if show_item_name and self.state=='hand' then
        local w = hover_item_name:getWidth()*0.5
        lg.setColor(1,1,1,1)
        
        lg.draw( hover_item_name, self.screen_x - w , self.screen_y + 20)
    end
end
function Mouse:draw()
    -- local x,y = self.x, self.y
    -- local x,y = self.grid_position:unpack()
    -- lg.setColor(1,1,1)
    -- lg.print( string.format(">%0d, %0d", self.x, self.y), self.x, self.y - 20)
    -- lg.print( self.state,self.screen_x,self.screen_y + 20)
    -- lg.print( math.floor(self.wheel)+1,self.screen_x,self.screen_y + 20)
    
    -- lg.circle('line',240+camera_x, 426+camera_y,6,8)

    local t = GAME.map:get_tile( self.grid_position:unpack())
    if t and GAME.map.is_solid( t:get_id()) then
        local tx,ty = (t.x-1)*tile_size, (t.y-1)*tile_size
        lg.setColor(1,1,1)
        lg.draw( GAME.img.tileset, GAME.quads[t:get_id()], tile_size_half+tx, tile_size_half+ty, 0, img_scale, img_scale,tile_size_half,tile_size_half)
        lg.setColor(0,0,0,0.5)
        lg.rectangle('line', tx, ty, tile_size, tile_size)
    end
end
function Mouse:wheelmoved(x, y)

    
    if y > 0 then
        self.wheel = self.wheel +1
    elseif y < 0 then
        self.wheel = self.wheel -1
    end

    -- self.wheel = (self.wheel + y*self.wheel_sensibility)%(#self.tools)
    -- tool_index = math.floor(self.wheel)+1
    -- self.state = self.tools[ tool_index].id
    -- print(self.state)
end
function Mouse:key_pressed( k )
    if k == 'lctrl' then
        og_screen_x = self.x
        og_screen_y = self.y
        
        self:set_state( 'scrolling')
    end
    -- self:uptade_tile()
end 
function Mouse:key_released( k )
    if k == 'lctrl' then
        self.drag = false
        self:set_state( 'cross')
    end
    -- self:uptade_tile()
end 

function Mouse:pressed( x, y, button )
    if button == 3 then
        og_screen_x = x
        og_screen_y = y
        self:set_state( 'scrolling')
    end
    self._pressed[ self.state](self, x,y,button)
    
    -- if button == 2 then
    --     -- use currently selected item
    --     local used = GAME:use_item( self.item_selected, self:get_grid_position())
    --     if used then
    --         self.items[ self.item_selected] = self.items[ self.item_selected] - 1
    --     end
    -- end

    
end
function Mouse:released( x, y, button)
    self._released[ self.state](self,x,y,button)
    
end
function Mouse:set_state( state)
    self.state = state
    cursor_actual = state
end
function Mouse:get_state()
    return self.state
end
function Mouse:uptade_tile()
    local gx,gy = self.grid_position:unpack()
    local state = self.state
    if not self.drag then
        
        if GAME.map:is_lighted( gx,gy) then

            -- 
            show_item_name = false
            local obj, type = GAME.whats_here( self.x, self.y, gx, gy)

            if type == 'item' then
                show_item_name = true

                hover_item_name:set( obj.name)
            -- elseif type = 'air' then
            -- elseif type = 'enemy' then
            else -- if it is a block
                self.tile = obj.id
                self.tile_light = true
                self.tile_name = GAME.map.get_name( self.tile)
                tile_hp = GAME.map.get_info( self.tile, 'durability')*TOOLS['pickaxe'].force
                old_tile_hp = math.ceil(tile_hp)
            end

            state = state_by_type[ obj.type]
        else
            state = 'cross'
            self.tile_name = 'pitch-dark'
            self.tile = 'dark'
        end
        --if enemy then set state to sword end
    end
    -- print(hover_item_name)
    -- if state~=self.state then
    self:set_state( state)
    -- self.state = state
    -- cursor_actual = state
        -- Timer.after(0.15, function() self:set_state( state) end)
    -- end
    
end

return Mouse
--  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄ 
-- ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
-- ▐░█▀▀▀▀▀▀▀▀▀  ▀▀▀▀█░█▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀▀▀ 
-- ▐░▌               ▐░▌     ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░▌          ▐░▌          
-- ▐░█▄▄▄▄▄▄▄▄▄      ▐░▌     ▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░▌ ▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄▄▄ 
-- ▐░░░░░░░░░░░▌     ▐░▌     ▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌▐░░░░░░░░▌▐░░░░░░░░░░░▌
--  ▀▀▀▀▀▀▀▀▀█░▌     ▐░▌     ▐░▌       ▐░▌▐░█▀▀▀▀█░█▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░▌ ▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ 
--           ▐░▌     ▐░▌     ▐░▌       ▐░▌▐░▌     ▐░▌  ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌          
--  ▄▄▄▄▄▄▄▄▄█░▌     ▐░▌     ▐░█▄▄▄▄▄▄▄█░▌▐░▌      ▐░▌ ▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄ 
-- ▐░░░░░░░░░░░▌     ▐░▌     ▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
--  ▀▀▀▀▀▀▀▀▀▀▀       ▀       ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀  ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀ 
local lg = love.graphics
-- local storage_scale = 0
local old_txt = ''
local item_counter = 1
local item_label = {
    life = 0
}
item_label.set = function( self, txt)
    if not self.name then
        self.name = lg.newText( GAME.font, '')
    end
    if old_txt == txt and self.life>0.1 then
        item_counter = item_counter +1
        self.name:set( txt .. '_x' .. item_counter) 
    else
        self.name:set( txt)
        item_counter = 1
    end
    self.life = 2
    old_txt = txt
    self.canvas = lg.newCanvas( self.name:getWidth()+6, self.name:getHeight()+4)
    lg.setCanvas( self.canvas)
    lg.clear()
    lg.setColor(0.3,0.3,0.5)
    lg.rectangle("fill", 0, 0, self.name:getWidth()+6, self.name:getHeight()+4)
    lg.setColor(1,1,1)
    lg.draw( self.name, 2, 2)
    lg.setCanvas( )

end
item_label.update = function( self, dt)
    if self.life>0 then
        self.life = self.life - dt
    end
end
item_label.draw = function( self, x, y)
    if self.life<=0 then return end
    local w = self.canvas:getWidth()
    if self.life>0.1 then
        lg.draw( self.canvas, x -w, y)
    elseif self.life>0.05 then
        local hh = self.name:getHeight()*0.5
        lg.line( x-w, y+hh, x, y+hh)
    else
        local hh = self.name:getHeight()*0.5
        lg.circle("fill", x-w/2, y+hh,3,6)
    end
end
local function name_canvas( item, num)
    local txt = lg.newText( GAME.font, item .. '_x' .. num)
    
    local canvas = lg.newCanvas( txt:getWidth()+6, txt:getHeight()+4)
    canvas:renderTo( function()
    lg.clear()
    lg.setColor(0.3,0.3,0.5)
    lg.rectangle("fill", 0, 0, txt:getWidth()+6, txt:getHeight()+4)
    lg.setColor(1,1,1)
    lg.draw( txt, 2, 2) end)

    return canvas
end

local mouse_hover = false
local mouse_select = false
local mouse_wheel = 1
local mouse_wheel_counter = 0
local arrow_y = 1
local img_h = GAME.img.hud_arrow:getHeight()
local belt_slots = 4
local slot_size = 64
local belt_pos_x = Screen.center.x-slot_size*(belt_slots*0.5)
local belt_pos_y = Screen.h-70

local storage = {
    itens = {},
    usable = {},
    -- roll = 1,
    x = Screen.w - 38, y = Screen.h-38,
    scale = 2,
    labels = {},
    itens_count = 0,
    
    add = function( self, item_obj, silent)

        local item = item_obj.name

        if not self.itens[item] then
            self.itens[item] = { quantity = 0}
            if item_obj.use then
                table.insert(self.usable,{name = item})
            end
        elseif self.itens[item].hide then
            table.insert(self.usable,{name = item})
        end
        self.itens[item].quantity = self.itens[item].quantity +1
        self.itens[item].hide = false
        self.itens[item].img = name_canvas(item, self.itens[item].quantity)
        
        if silent then return end
        item_label:set( item)
        
        self.scale = 2.5
        Lib.timer.tween(1, self, {scale = 2}, 'out-elastic')
        GAME.sfx.pickup:play()

    end,
    get_item = function( self)
        -- print(arrow_y)
        if (arrow_y>0) and self.usable[arrow_y] then
            -- print( self.usable[arrow_y].name)
            return self.usable[arrow_y].name
        end
        return false
    end,
    remove = function( self, item)
        if not self.itens[item] then return end
        
        self.itens[item].quantity = math.max(0, self.itens[item].quantity -1)
        self.itens[item].img = name_canvas(item, self.itens[item].quantity)
        self.itens[item].hide = self.itens[item].quantity==0
        if self.itens[item].hide then
            table.remove(self.usable, arrow_y)
        end
    end,
    update = function( self, dt)
        item_label:update( dt)
        local mx, my = love.mouse.getPosition()
        mouse_hover = PointInside( mx, my, self.x-32, self.y-32, 64, 64)

        -- if Mouse.wheel ~= mouse_wheel then
        --     mouse_select = true
        --     mouse_wheel = Mouse.wheel
        --     mouse_wheel_counter = 1
        --     arrow_y = 1+mouse_wheel%(#self.usable)
        --     if #self.usable>0 then
        --         print( self.usable[arrow_y].name)
        --     end
        -- else
        --     mouse_wheel_counter = math.max( 0, mouse_wheel_counter -dt)
        --     if mouse_wheel_counter==0 then mouse_select = false end
        -- end
        -------------------------------------------------------TODO mouse selected item list roll
    end,
    draw = function( self)
        lg.setColor(1,1,1)
        if mouse_hover then
            local n = 0
            for name,obj in pairs(self.itens) do
                if obj.hide then goto next end

                n = n+1
                local w = obj.img:getWidth()
                local h = obj.img:getHeight() +2

                lg.draw( obj.img,  self.x+32, self.y-h*n,0,1,1,w,32)

                ::next::
            end
        end
        for i=0,belt_slots-1 do -------------------------------------------------------------------TODO: implement belt items selection
            
            lg.draw(GAME.img.slot, belt_pos_x+i*slot_size, belt_pos_y)
        end
        -- lg.circle("fill", Screen.center.x, belt_pos_y, 5)
        -- if mouse_select then
        --     -- local n = 0
        --     local hts = math.ceil((#self.usable)*0.5)
        --     for n,k in ipairs(self.usable) do
        --         -- n = n+1
                
        --         local img = self.itens[k.name].img
        --         local w = img:getWidth()
        --         -- local h = img_h
                
        --         local xx = arrow_y ==n and 46 or 54

        --         lg.draw( img,  mouse.screen_x+xx, (hts-n)*img_h +mouse.screen_y)
                
        --     end
        --     lg.draw( GAME.img.hud_arrow,  mouse.screen_x+32, (hts-arrow_y)*img_h + mouse.screen_y)
        -- end
        item_label:draw(  self.x-32, self.y+8)
        lg.draw(GAME.img.backpack, self.x, self.y, 0,self.scale,self.scale,16,16)
    end
}
storage.resize_screen = function (w,h)
    storage.x = w - 38
    storage.y = h-38
    belt_pos_x = Screen.center.x-slot_size*(belt_slots*0.5)
    belt_pos_y = Screen.h-70
end
return storage
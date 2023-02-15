local lg = love.graphics
local class = require "../library/classic"
local item_specs = {
    stone = {
        weight = 4,
        value = 1
    },
    coal = {
        weight = 2,
        value = 2
    },
    iron = {
        weight = 4,
        value = 5
    },
    silver = {
        weight = 3,
        value = 15
    },
    gold = {
        weight = 5,
        value = 25
    },
}

local gravityAccel  = 500 -- pixels per second^2


local new_item = class:extend()
function new_item:new( name, x, y)
    self.x, self.y = x,y
    self.vx, self.vy = 0,0
    self.w, self.h = 30,16
    self.bump = true
    self.name = name
    GAME.world:add(self, x,y,self.w, self.h)
    self.onGround = false
    self.type = 'collectable'
    self.gx, self.gy = GAME.map:world_to_grid( x, y)
end

function new_item:destroy( )
    if GAME.world then
        GAME.world:remove(self)
    end
end

function new_item:apply_gravity(dt)
  self.vy = self.vy + gravityAccel * dt
end
function new_item:change_velocity_collision_normal( ny, bounciness)
    bounciness = bounciness or 0
    local vy = self.vy
    if (ny < 0 and vy > 0) or (ny > 0 and vy < 0) then
      vy = -vy * bounciness
    end
    self.vy = vy
end
function new_item:check_ground(ny)
    if ny < 0 then self.onGround = true end
end
  
function new_item:move_colliding(dt)
    
    self.onGround = false
    -- local world = 
  
    -- local future_l = self.l + self.vx * dt
    local future_y = self.y + self.vy * dt
  
    local next_x, next_y, cols, len = GAME.world:move(self, self.x, future_y)
  
    for i=1, len do
      local col = cols[i]
    --   self:change_velocity_collision_normal( col.normal.y, bounciness)
      self:check_ground( col.normal.y)
    end
    
    self.x, self.y = next_x, next_y

    if not self.onGround then self:apply_gravity(dt) end
end

local function item_draw( item)

    lg.setColor( 1,1,1)
    -- lg.circle("fill", item.x+16, item.y+16, 4, 12)
    -- drawFilledRectangle( item.x, item.y, item.w, item.h, 0.1,0.5,0.7)
    -- lg.setColor( 1,1,1)
    lg.draw( GAME.img.tileset, GAME.quads.items[item.name], item.x, item.y)
    -- lg.print( item.name, item.x, item.y)
end

local fixed_items = class:extend()
function fixed_items:new(name,x,y)
    self.x, self.y = x,y
    self.w, self.h = GAME.tile_size,GAME.tile_size
    self.name = name
    self.id = UniqueId(name)
    self.type = 'collectable'
    self.gx, self.gy = GAME.map:world_to_grid( x+1, y+1)
end

function fixed_items:destroy(mx, my)
    local t = GAME.map:get_tile( self.gx, self.gy)
    t.item = nil
end

local light = fixed_items:extend()
function light:new( name,x,y)
    -- err()
    light.super.new( self, name, x, y)
    
    print(self.name,x,y)
    self.use = true
    Light.add( self.id, self.gx, self.gy, 1.1)
    GAME.map:update_canvas()
end
-- function light:grab(mx, my)
--     self.gx, self.gy = GAME.map:world_to_grid( mx, my)
--     local t = GAME.map:remove_light( self.gx,self.gy)
--     self.g = true
-- end
function light:destroy( )
    Light.remove(self.id)
    GAME.map:update_canvas()
    print('light source removed')
end
-- function light:drop(mx, my)
--     local gx, gy = GAME.map:world_to_grid( mx, my)
--     local tile = GAME.map:get_tile( gx, gy)

--     if tile.id == 'air' and not tile.item then
--         self.gx, self.gy = gx, gy
--         tile.item = true
--         self.g = false  
--         local t = GAME.map:add_light( gx, gy)
--         self.x, self.y = GAME.map:grid_to_world(t.x, t.y)
--         t.item = true
--     end
-- end


local blocker = fixed_items:extend()
function blocker:new( name,x,y)
    blocker.super.new( self, name, x, y)
    self.is_map_obj = true
    -- self.use = true
    local t = GAME.map:insert_tile( self.gx, self.gy, 'blocker')
    self.fail = not (t)
end

local bomb = fixed_items:extend()
function bomb:new( name,x,y)
    bomb.super.new( self, name, x, y)
    self.mouse_action = 'empty'
    -- self.use = true
end
function bomb:destroy()
    -- self:action(0)
end
function bomb:action( time)
    timer.after((time or 2.8),function() GAME.map:add_light( self.gx, self.gy, 1, {1,1,0.8}) end)
    timer.after(3,function()
        self:explode()
        -- GAME.map:remove_light( self.gx,self.gy)
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
    light = light,
    blocker = blocker,
    bomb = bomb
}

local item = {
    dynamic = {},
    static = {},
    add_fixed = function( self, item, x, y) --add fixed items at given position (in grid to world coordinates)
        local it = (item_list[item] or fixed_items)( item, x, y)
        table.insert( self.static, it)
        -- else
        --     it = new_item(item, nx, ny)
        --     print(GAME.world:hasItem(it),"at", nx,ny)
        --     -- print(GAME.world:check(it))
        --     table.insert( self.dynamic, it)
        return it
    end,
    -- remove = function( self, item)
    --     local tile = GAME.map:get_tile( item.gx, item.gy)
    --     if tile.id == 'air' then
    --         print("destroy")
    --         item:destroy()
    --         -- table.remove( self.dynamic, item)
    --     end
    -- end,
    get_at = function( self, x,y)
        for _,k in ipairs(self.dynamic) do
            if not k.dead and PointInside( x, y, k.x, k.y, k.w, k.h) then
                return k
            end
        end
        for _,k in ipairs(self.static) do
            if not k.dead and PointInside( x, y, k.x, k.y, k.w, k.h) then
                return k
            end
        end
        return false
    end,
    draw = function(self)
        lg.setColor(1,1,1)
        for _,k in ipairs(self.static) do
            item_draw(k)
        end
        -- for _,k in ipairs(self.dynamic) do
        --     item_draw(k)
        -- end
    end,
    update = function(self, dt)
        local rmd,rms = {},{}
        for i,k in ipairs(self.dynamic) do
            k:move_colliding(dt)
            if k.dead then
                table.insert(rmd, i)
            end
        end
        for i,k in ipairs(self.static) do
            if k.dead then
                table.insert(rms, i)
            end
        end
        for _,dead in ipairs(rmd) do
            local it = table.remove( self.dynamic, dead)
            it:destroy()
        end
        for _,dead in ipairs(rms) do
            local it = table.remove( self.static, dead)
            it:destroy()
        end
    end
}
return item
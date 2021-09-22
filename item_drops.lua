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
function new_item:new(world, name, x, y)
    self.x, self.y = x,y
    self.vx, self.vy = 0,0
    self.w, self.h = 30,16
    self.name = name
    self.world = world
    self.world:add(self, x,y,self.w, self.h)
    self.onGround = false
    self.type = 'collectable'
    self.gx, self.gy = GAME.map:world_to_grid( x, y)
end

function new_item:destroy( )
    if self.world then
        self.world:remove(self)
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
    local world = self.world
  
    -- local future_l = self.l + self.vx * dt
    local future_y = self.y + self.vy * dt
  
    local next_x, next_y, cols, len = world:move(self, self.x, future_y)
  
    for i=1, len do
      local col = cols[i]
    --   self:change_velocity_collision_normal( col.normal.y, bounciness)
      self:check_ground( col.normal.y)
    end
    
    self.x, self.y = next_x, next_y

    if not self.onGround then self:apply_gravity(dt) end
end

local function item_draw( item)

    -- lg.setColor( 0.3,0.3,0.3)
    -- lg.rectangle("fill", item.x, item.y, item.w, item.h)
    -- drawFilledRectangle( item.x, item.y, item.w, item.h, 0.1,0.5,0.7)
    lg.setColor( 1,1,1)
    lg.draw( GAME.img.tileset, GAME.quads.items[item.name], item.x, item.y)
    -- lg.print( item.name, item.x, item.y)
end

local drops = {
    visible_itens = {},
    add = function( self, item, nx, ny) --world coordinates
        local x,y = nx+1, ny+8
        local gx,gy = GAME.map:world_to_grid( x, y)
        local tile = GAME.map:get_tile( gx, gy)
        if tile and tile.id == 'air' then
            local it = new_item( GAME.world, item, x, y)
            table.insert( self.visible_itens, it)
            return it
        end
        return false
    end,
    remove = function( self, item)
        local tile = GAME.map:get_tile( item.gx, item.gy)
        if tile.id == 'air' then
            item:destroy()
            table.remove( self.visible_itens, item)
        end
    end,
    get_at = function( self, x,y)
        for i,k in ipairs(self.visible_itens) do
            if not k.dead and point_inside( x, y, k.x, k.y, k.w, k.h) then
                return k
            end
        end
        return false
    end,
    draw = function(self)
        lg.setColor(1,1,1)
        for i,k in ipairs(self.visible_itens) do
            item_draw(k)
        end
    end,
    update = function(self, dt)
        local dead = 0
        for i,k in ipairs(self.visible_itens) do
            k:move_colliding(dt)
            -- if k.on_air then
            --     k.y = k.y +gravity*dt
            -- end
            if k.dead then
                dead = i
            end
        end
        if dead>0 then
            local it = table.remove( self.visible_itens, dead)
            it:destroy()
        end
    end
}
return drops
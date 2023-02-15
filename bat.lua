-- bat.lua
local lg = love.graphics
local abs = math.abs
local rng = math.random

local min_distance, max_distance = 3,9
local directions = {{0,-1},{0,1},{-1,0},{1,0}}
local directions_lit = {'u','d','l','r'}

local bat = class:extend()
function bat:new(x,y)
    self.x = x or 0
    self.y = y or 0
    self.gx = math.ceil(self.x/GAME.tile_size)
    self.gy = math.ceil(self.y/GAME.tile_size)
    self.x_vel = 0
    self.y_vel = 0
    self.w = 32
    self.h = 16
    self.normal_acceleration = 20
    self.drag_active = 0.9
    self.drag_passive = 0.9
    self.max_speed = 60
    self.max_speed_sq = self.max_speed * self.max_speed
    self.target_x = 0
    self.target_y = 0
    self.dir = {0,0}
    -- self.
    self.state = "searching"
    GAME.world:add(self, self.x, self.y, self.w, self.h)
end
function bat:searching(dt)
    local dir = rng(#directions)
    local dis = rng(min_distance, max_distance)
    local ntx,nty = 0,0
    for i=1,dis do
        --check each map tile based on direction chosen, if obstacle returns last free tile
        local new_x = self.gx+directions[dir][1]*i
        local new_y = self.gy+directions[dir][2]*i
        print(new_x, new_y)
        local tile_is_wall = GAME.map:is_wall(new_x, new_y)
        if not tile_is_wall then
            ntx,nty = new_x,new_y
        end
        if i==dis or tile_is_wall then
            if ntx~=self.target_x or nty~=self.target_y then
                self.target_x=ntx
                self.target_y=nty
                self.dir = directions[dir]
                self.state = "moving"
            end
        end
    end
end
function bat:moving(dt)
    print(self.target_x, self.target_y)
    if (self.gx==self.target_x) and (self.gy==self.target_y) then
        self.target_x = self.gx
        self.target_y = self.gy
        self.state = "searching"
    end

	local temp_norm_accel = math.normalize(self.dir[1],self.dir[2])

	local temp_x_accel = temp_norm_accel[1]*self.normal_acceleration
	local temp_y_accel = temp_norm_accel[2]*self.normal_acceleration

	local cur_speed = math.magnitude(self.x_vel,self.y_vel)
	if ((self.normal_acceleration + cur_speed) >self.max_speed) then
		local accel_magnitude = self.max_speed - cur_speed
		if (accel_magnitude < 0) then accel_magnitude = 0 end

		temp_x_accel = temp_norm_accel[1]*accel_magnitude
		temp_y_accel = temp_norm_accel[2]*accel_magnitude
	end

    local temp_x_vel = self.x_vel + temp_x_accel
	local temp_y_vel = self.y_vel + temp_y_accel

	local temp_vel = math.magnitude_sq(temp_x_vel, temp_y_vel)

	if(math.abs(temp_vel) > self.max_speed_sq) then
		temp_x_vel = self.x_vel
		temp_y_vel = self.y_vel
	end

	local temp_drag = self.drag_passive

	if (self.dir[1]~=0 or self.dir[2]~=0) then
		temp_drag = self.drag_active
	end

	self.x_vel = temp_x_vel * temp_drag
	self.y_vel = temp_y_vel * temp_drag

    if self.x_vel ~= 0 or self.y_vel ~= 0 then
        local goalX = self.x + self.x_vel*dt
	    local goalY = self.y + self.y_vel*dt
        local collisions = {}

        self.x, self.y, collisions = GAME.world:move(self, goalX, goalY)
        -- for i, coll in ipairs(collisions) do
        --     if coll.touch.y > goalY then
        --       hasReachedMax = true
        --       isGrounded = false
        --     elseif coll.normal.y < 0 then
        --       hasReachedMax = false
        --       isGrounded = true
        --     end
        --   end
        self.gx = math.ceil(self.x/GAME.tile_size)
        self.gy = math.ceil(self.y/GAME.tile_size)
    end
end
function bat:update(dt)
    self[self.state](self,dt)
end

function bat:draw()
    lg.setColor(1,0.5,0.1)
    lg.rectangle("fill",self.x,self.y,self.w,self.h)
    lg.rectangle("fill",self.target_x*GAME.tile_size-GAME.tile_size, self.target_y*GAME.tile_size-GAME.tile_size,self.w,self.h)
    lg.print(self.state, self.x, self.y-20)
end

return bat
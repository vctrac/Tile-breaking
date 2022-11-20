-- play.lua
local lg = love.graphics
local lk = love.keyboard
local rn = math.random

Input._add("left", "a", "left")
Input._add("right", "d", "right")
Input._add("up", "w", "up")
Input._add("down", "s", "down")
-- Input._add("jump", "space")

-- local speed = 80
local gravity = 1000
-- local acc = 100
local drag_active = 0.9
local drag_passive = 0.9
local max_speed = 100
local max_speed_sq = max_speed * max_speed
local jump_speed = 300
-- local jumpMaxSpeed = 9.5
local isJumping,isGrounded,hasReachedMax

local play = {}

function play.init(x,y)
    play.x = x or 0
    play.y = y or 0
    play.x_vel = 0
    play.y_vel = 0
    play.w = 16
    play.h = 16
    play.normal_acceleration = 380

    -- play.

    GAME.world:add(play, play.x, play.y, play.w, play.h)
end
function play.movement(dt)

    local left = Input.left()
    local right = Input.right()
    local up = Input.up()
    local down = Input.down()

	local x_dir = (left and right) and 0 or left and -1 or right and 1 or 0
	local y_dir = (up and down) and 0 or up and -1 or down and 1 or 0


	local temp_norm_accel = math.normalize(x_dir,y_dir)

	local temp_x_accel = temp_norm_accel[1]*play.normal_acceleration
	local temp_y_accel = temp_norm_accel[2]*play.normal_acceleration

	local cur_speed = math.magnitude(play.x_vel,play.y_vel)
	if ((play.normal_acceleration + cur_speed) >max_speed) then
		local accel_magnitude = max_speed - cur_speed
		if (accel_magnitude < 0) then accel_magnitude = 0 end

		temp_x_accel = temp_norm_accel[1]*accel_magnitude
		temp_y_accel = temp_norm_accel[2]*accel_magnitude
	end

    local temp_x_vel = play.x_vel + temp_x_accel
	local temp_y_vel = play.y_vel + temp_y_accel

	local temp_vel = math.magnitude_sq(temp_x_vel, temp_y_vel)

	if(math.abs(temp_vel) > max_speed_sq) then
		temp_x_vel = play.x_vel
		temp_y_vel = play.y_vel
	end

	local temp_drag = drag_passive

	if (x_dir~=0 or y_dir~=0) then
		temp_drag = drag_active
	end

	play.x_vel = temp_x_vel * temp_drag
	play.y_vel = temp_y_vel * temp_drag

    if play.x_vel ~= 0 or play.y_vel ~= 0 then
        local goalX = play.x + play.x_vel*dt
	    local goalY = play.y + play.y_vel*dt
        local collisions = {}

        play.x, play.y, collisions = GAME.world:move(play, goalX, goalY)
        -- for i, coll in ipairs(collisions) do
        --     if coll.touch.y > goalY then
        --       hasReachedMax = true
        --       isGrounded = false
        --     elseif coll.normal.y < 0 then
        --       hasReachedMax = false
        --       isGrounded = true
        --     end
        --   end
    end
end


function play.update(dt)
    play.movement(dt)
    -- local left = Input.left()
    -- local right = Input.right()

    -- local goalX = play.x + play.vx
    -- local goalY = play.y + play.vy
  
    -- -- Apply Friction
    -- play.vx = play.vx * (1 - math.min(dt *friction, 1))
    -- play.vy = play.vy * (1 - math.min(dt *friction, 1))
  
    -- -- Apply gravity
    -- play.vy = play.vy +gravity * dt

    -- if Input.left() and math.abs(play.vx) < maxSpeed then
    --     play.vx = play.vx - acc * dt
    -- elseif Input.right() and math.abs(play.vx) < maxSpeed then
    --     play.vx = play.vx + acc * dt
    -- end

    -- if Input.jump() and isGrounded then
    --     if -play.vy < jumpMaxSpeed and not hasReachedMax then
    --         play.vy = play.vy - jumpAcc * dt
    --     elseif math.abs(play.vy) > jumpMaxSpeed then
    --         hasReachedMax = true
    --     end

    --     play.isGrounded = false
    -- end

    -- if play.vx ~= 0 or play.vy ~= 0 then
    --     local collisions = {}
    --     play.x, play.y, collisions = GAME.world:move(play, goalX, goalY)
    --     for i, coll in ipairs(collisions) do
    --         if coll.touch.y > goalY then
    --           hasReachedMax = true
    --           isGrounded = false
    --         elseif coll.normal.y < 0 then
    --           hasReachedMax = false
    --           isGrounded = true
    --         end
    --       end
    -- end
end

function play.draw()
    lg.setColor(0,0.5,1)
    lg.rectangle("fill",play.x, play.y, play.w, play.h)
end

return play
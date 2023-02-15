-- SandBox.lua
local lg = love.graphics
local rn = math.random
local gravity = 10
local Weight = {
    water = 10,
    sand = 8,
    dust = 4
}
local water_spread = 150
local div = 8 --int, min(1), max(tile_size) | decrease 'div' to increase performance
local tile_size = 32/div
local unit = class:extend()


local SandBox = {
    units = {},
    quads = {},
    time = 0
}

-- local waterShader = love.graphics.newShader("water.fs")
function unit:new( id)
    self.id = id or "empty"
    self.lf = 1
    self.vy = 0
    self.vx = 0
    self.clock = 0
end
local dust = unit:extend()
function dust:new(options)
    local t = options or {}
    dust.super.new(self, "dust")
    self.color = Cor.shade(t.color or {1,1,1}, rn(-10,10))
    self.dir = 0
    self.lf = rn(0.5,1.5)
    self.vy = -rn(5)
end
local sand = unit:extend()
function sand:new(options)
    local t = options or {}
    sand.super.new(self, "sand")
    self.color = Cor.shade(t.color or {0.7,0.7,0}, rn(-10,10))
end
local water = unit:extend()
function water:new(options)
    local t = options or {}
    sand.super.new(self, "water")
    self.color = Cor.shade(t.color or {0,0.5,0.9}, rn(-10,10))
end

local types = {
    dust = dust,
    sand = sand,
    water = water,
    empty = unit
}

-- local in_bounds = function(t,x,y)
--     return (t[y] and t[y][x]) and true
-- end

local valid_types = {empty=true,water=true}
local update_cell = {
    dust = function(dt,c,x,y)
        local t = SandBox.units
        if not (t[y+1] or t[y-1]) then return end
        if t[y][x].lf<=0 then
            t[y][x] = unit()
            return
        end
        
        local it = t[y][x]
        it.lf = it.lf - 0.4*dt
        if rn(100)<30 then --change horizontal direction occasionaly
            local rd = rn(-100,100)
            it.dir = rd>=51 and 1 or rd<51 and -1
        else it.dir = 0 end
        
        it.vy = it.vy +Weight[it.id]*gravity*dt
        if not t[y+1] then return end
        local id = t[y+1][x] and t[y+1][x].id
        local can_fall = valid_types[ id]
        if can_fall and it.vy>=1 then
            it.vy = 0
            local id_x = t[y+1][x+it.dir] and t[y+1][x+it.dir].id
            local can_sideway = valid_types[ id_x]
            if can_sideway then
                t[y+1][x+it.dir] = it
                t[y][x] = types[ id_x]()
                goto fim
            end
        end
        local lr = it.dir~=0 and it.dir or math.random(-1, 1)
        id = t[y+1][x+lr] and t[y+1][x+lr].id
        can_fall = valid_types[ id]
        if can_fall and it.vy>=1 then
            t[y+1][x+lr] = it
            t[y][x] = types[id]()
            it.vy = 0
        end
        ::fim::
    end,
    sand = function(dt,c,x,y)
        local t = SandBox.units
        if not t[y+1] then return end
        local it = t[y][x]
        it.vy = it.vy +Weight[it.id]*gravity*dt
        
        local id = t[y+1][x] and t[y+1][x].id
        local can_fall = valid_types[ id]
        if can_fall and it.vy>=1 then
            it.vy = 0
            t[y+1][x] = it
            t[y][x] = types[ id]()
            -- goto fim
        else
            local lr = math.random(-1, 1)
            id = t[y+1][x+lr] and t[y+1][x+lr].id
            can_fall = valid_types[ id]
            if can_fall and it.vy>=1 then
                it.vy = 0
                t[y+1][x+lr] = it
                t[y][x] = types[id]()
            end
        end
        -- ::fim::
    end,
    water = function(dt,c,x,y)
        local t = SandBox.units
        if not t[y+1] or t[y][x].clock==c then return end
        if t[y][x].lf<=0 then
            t[y][x] = unit()
            return
        end
        
        local it = t[y][x]
        if t[y+1][x].id ~= "water" then
            it.lf = it.lf-0.1*dt
        end
        it.vy = it.vy +Weight[it.id]*gravity*dt
        
        local id = t[y+1][x] and t[y+1][x].id
        if id =="empty" then
            if it.vy>=1 then
                it.vy = 0
                it.vx = 0
                t[y+1][x] = it
                t[y][x] = types[ id]()
            end
            -- goto fim
        else
            local lr = math.random(-1, 1)
            local under_water = t[y-1] and t[y-1][x].id == "water"

            it.vx = it.vx + water_spread*dt

            if t[y][x+lr] and t[y][x+lr].id =="empty" then
                if it.vx>=1 then
                    it.vy = 0
                    it.vx = 0
                    it.clock = c
                    t[y][x+lr] = it
                    t[y][x] = under_water and water() or unit()
                    if under_water then t[y-1][x] = unit() end --move down water cell located above
                end
            elseif t[y][x-lr] and t[y][x-lr].id =="empty" then
                if it.vx>=1 then
                    it.vy = 0
                    it.vx = 0
                    it.clock = c
                    t[y][x-lr] = it
                    t[y][x] = under_water and water() or unit()
                    if under_water then t[y-1][x] = unit() end --move down water cell located above
                end
            end
        end
        -- ::fim::
    end
}

SandBox.init = function(self, w,h)
    self.h = h*div
    self.w = w*div
    self.qh = h
    self.qw = w

    for y=1,self.h do
        self.units[y] = {}
        for x=1,self.w do
            self.units[y][x] = unit()
        end
    end
    for y=1,h do
        for x=1,w do
            local yy = y*div-div
            local xx = x*div-div
            self.quads[ToId(y,x)] = {
                start_y = yy,
                start_x = xx,
                empty = true
            }
        end
    end
end
SandBox.update_quads = function(self,tx,ty,wall)
    local id = ToId(ty,tx)
    self.quads[id].empty = not wall
    for y=1,div do
        for x=1,div do
            local xx = self.quads[id].start_x+x
            local yy = self.quads[id].start_y+y
            self.units[yy][xx] = unit(wall and "wall" or "empty")
        end
    end
end
SandBox.add = function(self,id,x,y,options)
    local xx = math.floor(x/tile_size)+math.random(-2,2)
    local yy = math.floor(y/tile_size)+math.random(-2,2)
    local uy = self.units[yy]
    if uy then
        if uy[xx] then
            self.units[yy][xx] = types[id](options)
            -- if color then self.units[yy][xx].color = color end
        end
    end
end
local ignored_types = {empty=true,wall=true}
SandBox.update = function(self, dt)
    self.time = self.time + dt
    for _,quad in pairs(self.quads) do
        if quad.empty then
            for y=1,div do
                local yy = quad.start_y+y
                for x=1,div do
                    local xx = quad.start_x+x
                    local id = self.units[yy][xx].id
                    if ignored_types[id] then
                        goto next
                    end
                    update_cell[id](dt, self.time, xx,yy)
                    ::next::
                end
            end
        end
    end
    if self.time>1 then self.time = 0 end
end
SandBox.draw = function(self)
    for y=1,self.h do
        for x=1,self.w do
            local id = self.units[y][x].id
            if id~="empty" and id~="wall" then
                local c = self.units[y][x].color
                local alpha = self.units[y][x].lf<0.05 and self.units[y][x].lf*10 or 1
                lg.setColor(c[1],c[2],c[3], alpha)
                lg.rectangle("fill",(x-1)*tile_size,(y-1)*tile_size,tile_size,tile_size)
            end
        end
    end
    if _DEBUG then
        for _,quad in pairs(self.quads) do
            if quad.empty then
                lg.setColor(1,0,0,0.3)
                lg.rectangle("fill", quad.start_x*tile_size, quad.start_y*tile_size,32,32)--quad.end_x,quad.end_y)
            end
        end
    end
end

return SandBox

local lg = love.graphics
local lk = love.keyboard
local rn = math.random
local old_print = print

function ToId(x,y)
    return x..','..y
end
function FromId(id)
    local t = {}
    for num in string.gmatch(id, '([^,]+)') do
        table.insert(t,tonumber(num))
    end
    return unpack(t)
end
function print( ...) --This function prints the filename and linenumber of where it was called from
    local info = debug.getinfo(2,"Sl");
    local str  = info.source:match('%w+[^.lua]',2)
    old_print(string.format("%s:%d >",str ,info.currentline), ...)
end
function Loop(i, n)
    local z = i - 1
    return (z % n) + 1
end
function Clamp(x, min, max)
    return x < min and min or (x > max and max or x)
end
function Distance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return (dx * dx + dy * dy)
end
function BoxCollision( x1,y1,w1,h1, x2,y2,w2,h2)
    return (x1+w1>x2 and x1<x2+w2 and y1+w1>y2 and y1<y2+h2)
end
function PointInside( px,py, x,y,w,h)
    return (px>=x and px<=x+w and py>=y and py<=y+h)
end
function UniqueId(str)
    local template =str .. 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and rn(0, 0xf) or rn(8, 0xb)
        return string.format('%x', v)
    end)
end
Bool2Number={ [true]=1, [false]=0 }
Number2Bool={ [1]=true, [0]=false }

-- Input handler
-- Ex: Input._add("left", "a", "left")
Input = { }
Input._add = function (name, ...) --(string name, string keys, <...>)
    Input[name] = setmetatable({...},
    {__call = function(self)
        return lk.isDown(unpack(self))
    end})
end

Cor = {}

-- Cor.raisin_black = {0.079, 0.075, 0.091}
-- Cor.grid_alpha_black = {0.079, 0.075, 0.091, 0.15}
-- Cor.jet = {0.203, 0.196, 0.2}
-- Cor.davys_grey = {0.251, 0.264, 0.264}
-- Cor.rose_dust = {0.686, 0.423, 0.486}
-- Cor.blue_cunt = {0.386, 0.423, 0.686}
-- Cor.dim_gray = {0.304, 0.315, 0.333}
-- Cor.dead_red = {0.514, 0.315, 0.333}
-- Cor.opal = {0.768, 0.866, 0.854}
-- Cor.forest_green = {0.333, 0.662, 0.454}
-- Cor.under_green = {0.25, 0.5, 0.3}
-- Cor.under_blue = {0.15, 0.12, 0.4}
-- Cor.decrease = function( cor)
--     return {cor[1]*0.75,cor[2]*0.75,cor[3]*0.75,}
-- end
-- Cor.increase = function( cor)
--     return {cor[1]*1.25,cor[2]*1.25,cor[3]*1.25,}
-- end
Cor.shade = function(cor, percent)
    local r, g, b = cor[1],cor[2],cor[3]
    -- If any of the colors are missing return white
    if not r or not g or not b then return {1,1,1} end
    r = r * (100 + percent) / 100
    g = g * (100 + percent) / 100
    b = b * (100 + percent) / 100
    r, g, b = r < 1 and r or 1, g < 1 and g or 1, b < 1 and b or 1
  
    return {r, g, b}
  end
Cor.flicker = function( cor, intensity)
    local f = math.random()*intensity
    return {cor[1]+f,cor[2]+f,cor[3]+f}
end

Rectangle = {
    line = function( l,t,w,h, rgb)
        -- local rgb = {...} or {1,1,1}--Cor.white
        lg.setColor(rgb)
        lg.rectangle('line', l,t,w,h)
    end,
    fill = function(l,t,w,h, rgb)
        -- local rgb = {...} or {1,1,1}--Cor.white
        lg.setColor(rgb)
        lg.rectangle('fill', l-w*0.5,t-h*0.5,w,h)
    end,
    outline = function(l,t,w,h, r,g,b)
        local c = type(r)=="table" and r or {r,g,b}
        lg.setColor(c[1],c[2],c[3],0.3)
        lg.rectangle('fill', l,t,w,h)
        lg.setColor(c[1],c[2],c[3])
        lg.rectangle('line', l,t,w,h)
    end,
}

function ProgressBar( )
    local pb = {
    v = 0,
    c = {0.8,0.8,0.8,1},
    draw = function(self,options)
        local x,y = options.x, options.y
        local w,h = options.w, options.h
        local var = math.max(0, options.value/options.maxValue*w)
        if self.v~=var then
            if self.v<var then self.v = var
            else self.v = self.v + (var-self.v)*love.timer.getDelta( )
            end
        end
        lg.setColor(options.color2 or self.c)
        lg.rectangle('fill',x, y, self.v, h )
        if var<w then
            lg.setColor(options.color2 or self.c)
            lg.line(math.min(w, self.v+10), y+h*0.5, x+w, y+h*0.5 )
            for i=1,9 do
                local xx = x+w*0.1*i
                if xx>var then
                    lg.line(xx, y, xx, y+h )
                end
            end
        end
        lg.setColor(options.color1 or self.c)
        -- lg.rectangle('line',x, y, w, h )
        lg.rectangle('fill',x, y, var, h )
    end
    }
    return pb
end

function GradientMesh(dir, ...)
    -- Check for direction
    local isHorizontal = true
    if dir == "vertical" then
        isHorizontal = false
    elseif dir ~= "horizontal" then
        error("bad argument #1 to 'gradient' (invalid value)", 2)
    end

    -- Check for colors
    local colorLen = select("#", ...)
    if colorLen < 2 then
        error("color list is less than two", 2)
    end

    -- Generate mesh
    local meshData = {}
    if isHorizontal then
        for i = 1, colorLen do
            local color = select(i, ...)
            local x = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {x, 1, x, 1, color[1], color[2], color[3], color[4] or 1}
            meshData[#meshData + 1] = {x, 0, x, 0, color[1], color[2], color[3], color[4] or 1}
        end
    else
        for i = 1, colorLen do
            local color = select(i, ...)
            local y = (i - 1) / (colorLen - 1)

            meshData[#meshData + 1] = {1, y, 1, y, color[1], color[2], color[3], color[4] or 1}
            meshData[#meshData + 1] = {0, y, 0, y, color[1], color[2], color[3], color[4] or 1}
        end
    end

    -- Resulting Mesh has 1x1 image size
    return love.graphics.newMesh(meshData, "strip", "static")
end
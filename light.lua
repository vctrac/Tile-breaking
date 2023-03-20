-- Light.lua
local lg = love.graphics
local tile = 1
local units = {}
local sources = {}
Light = {}
function Light.init( w,h,t, d)
    local div = d or 1 --TODO: set a conversion function for x,y Gridmap locations divided by div
    Light.w = w*div
    Light.h = h*div
    tile = t/div
    Light.quant = 0
    Light.canvas = lg.newCanvas(Light.w*tile,Light.h*tile)
    for x=1,Light.w do
        units[x] = {}
        for y=1,Light.h do
            units[x][y] = 0
        end
    end
end
function Light.update_canvas()
    --set a grayscale canvas
    lg.setCanvas(Light.canvas)
    lg.clear( )
    for x=1,Light.w do
        for y=1,Light.h do
            local c = units[x][y]
            lg.setColor(c, c, c)
            lg.rectangle("fill",x*tile-tile, y*tile-tile,tile,tile)
        end
    end
    lg.setCanvas()
end
function Light.set(id,opt)
    print(opt.x, opt.y, opt.force)
    if opt.x then sources[id].x=opt.x end
    if opt.y then sources[id].y=opt.y end
    if opt.force then sources[id].f=opt.force end
    Light.update()
end
function Light.add(id,x,y,f) --any: id, integer: pos_x, integer: pos_y, unsigned_float: force
    sources[id] = {x=x, y=y, f=f or 1}
    Light.quant = Light.quant +1
    Light.update()
end
function Light.add_sky(y,f) -- integer: pos_y, unsigned_float: force
    for i=1,Light.w do
        sources["sky_light"..i] = {x=i, y=y, f=f or 1, sun=true}
        Light.quant = Light.quant +1
    end
    Light.update()
end
function Light.remove(id)
    sources[id]=nil
    Light.quant = Light.quant -1
    Light.update()
end
function Light.toggle(id,x,y,f)
    if sources[id] then
        Light.remove(id)
    else
        Light.add(id,x,y,f)
    end
end
function Light.get_light_level(x,y)--grid position starting from 1,1
    if units[x] then
        return units[x][y] or 0
    end
    return 0
end

function Light.update()
    for x=1,Light.w do
        for y=1,Light.h do
            units[x][y] = 0
        end
    end

    for _,src in pairs(sources) do
        src.queue = {}

        table.insert(src.queue, src)
        units[src.x][src.y] = src.f
        
        local function p1(x,y,f, mul)
            local un = units[x] and units[x][y]
            local id = x..','..y
            local mt = GAME.map:get_tile(id)
            local opacity = mt and GAME.map.get_info(mt.id, "opacity")*(mul or 1) or 0
            local gm = f -opacity
            if un and (un < gm)  then
                gm = gm>=0.1 and gm or 0
                units[x][y] = gm
                table.insert(src.queue, {x=x, y=y, f=gm})
            end
        end
        local function p2(x,y,f, mul)
            local un = units[x] and units[x][y]
            local id = x..','..y
            local mt = GAME.map:get_tile(id)
            local tile_opacity = GAME.map.get_info(mt.id, "opacity")*(mul or 1)
            local opacity = mt.id=="air" and 0.05 or tile_opacity
            local gm = f -opacity
            if un and (un < gm)  then
                gm = gm>=0.1 and gm or 0
                units[x][y] = gm
                table.insert(src.queue, {x=x, y=y, f=gm})
            end
        end
        if src.sun then
            while (#src.queue>0) do
                local b = table.remove(src.queue, 1)
            
                -- up propagation
                -- if (b.y-1 > 0) then
                --     p1(b.x, b.y-1, b.f)
                -- end
                -- down propagation
                if (b.y+1 <= Light.h) then
                    p2(b.x, b.y+1, b.f)
                end
                -- left propagation
                if (b.x-1 > 0) then
                    p2(b.x-1, b.y, b.f)
                end
                -- right propagation
                if (b.x+1 <= Light.w) then
                    p2(b.x+1, b.y, b.f)
                end

                -- the next 4 IF statements make the light more round
                -- disable it for more performance or a diamond shape

                -- top_left propagation
                -- if (b.x-1 > 0) and (b.y-1 > 0) then
                --     p1(b.x-1, b.y-1, b.f, 1.5)
                -- end
                -- top_right propagation
                -- if (b.x+1 <= Light.w) and (b.y-1 > 0) then
                --     p1(b.x+1, b.y-1, b.f, 1.5)
                -- end
                -- botton_right propagation
                -- if (b.x+1 <= Light.w) and (b.y+1 <= Light.h) then
                --     p1(b.x+1, b.y+1, b.f, 1.5)
                -- end
                -- -- botton_left propagation
                -- if (b.x-1 >0) and (b.y+1 <= Light.h) then
                --     p1(b.x-1, b.y+1, b.f, 1.5)
                -- end
            end
        else
            while (#src.queue>0) do
                local b = table.remove(src.queue, 1)
            
                -- up propagation
                if (b.y-1 > 0) then
                    p1(b.x, b.y-1, b.f)
                end
                -- down propagation
                if (b.y+1 <= Light.h) then
                    p1(b.x, b.y+1, b.f)
                end
                -- left propagation
                if (b.x-1 > 0) then
                    p1(b.x-1, b.y, b.f)
                end
                -- right propagation
                if (b.x+1 <= Light.w) then
                    p1(b.x+1, b.y, b.f)
                end

                -- the next 4 IF statements make the light more round
                -- disable it for more performance or a diamond shape

                -- top_left propagation
                if (b.x-1 > 0) and (b.y-1 > 0) then
                    p1(b.x-1, b.y-1, b.f, 1.5)
                end
                -- top_right propagation
                if (b.x+1 <= Light.w) and (b.y-1 > 0) then
                    p1(b.x+1, b.y-1, b.f, 1.5)
                end
                -- botton_right propagation
                if (b.x+1 <= Light.w) and (b.y+1 <= Light.h) then
                    p1(b.x+1, b.y+1, b.f, 1.5)
                end
                -- botton_left propagation
                if (b.x-1 >0) and (b.y+1 <= Light.h) then
                    p1(b.x-1, b.y+1, b.f, 1.5)
                end
            end
        end
    end
    Light.update_canvas()
end

function Light.draw()
    lg.setColor(1,1,1,0.5)
    love.graphics.setBlendMode("multiply","premultiplied")
    lg.draw( Light.canvas)
    love.graphics.setBlendMode("alpha")
end
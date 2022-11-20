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
            -- lg.setColor(0,0,0,1-c)
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
function Light.add_sky(y,f) --any: id, integer: pos_x, integer: pos_y, unsigned_float: force
    for i=1,Light.w do
        sources["sky_light"..i] = {x=i,s=true, y=y, f=f or 1}
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

    -- local queue = {}
    -- local ind = {}
    for _,src in pairs(sources) do
        src.queue = {}
        -- src.ind = {} --this was used to avoid checking the same tile more than once,
        -- but visual glitchs occurred, disabled until fixed.

        table.insert(src.queue, src)
        -- src.ind[src.x..','..src.y] = true
        units[src.x][src.y] = src.f--math.max(0.6, src.f)
    -- end

    -- I was using only one WHILE loop for all light sources, but
    -- if one lights overlaps another, visual glitchs occurs, so
    -- now every source has its own [queue] table_list
        if src.s then
            -- repeat
            while (#src.queue>0) do
                local b = table.remove(src.queue, 1)
                -- src.ind[b.x..','..b.y] = nil
                local function p1(x,y,d)
                    local un = units[x] and units[x][y]
                    local id = x..','..y
                    local mt = GAME.map:get_tile(id)
                    local opacity = GAME.map.get_info(mt.id, "opacity")
                    -- if src.ind[id] then return end
                    local gm = b.f -opacity-d
                    if un and (un < gm)  then
                        gm = gm>=0.1 and gm or 0
                        units[x][y] = gm
                        table.insert(src.queue, {x=x, y=y, f=gm})
                        -- src.ind[id] = true
                    end
                end
                -- down propagation
                if (b.y+1 <= Light.h) then
                    p1(b.x, b.y+1,0)
                end
                -- right propagation
                if (b.x+1 <= Light.w) then
                    p1(b.x+1, b.y,0.2)
                end
                -- left propagation
                if (b.x-1 > 0) then
                    p1(b.x-1, b.y,0.2)
                end
            end
            -- until (#src.queue==0)
        else
            while (#src.queue>0) do
                local b = table.remove(src.queue, 1)
                -- src.ind[b.x..','..b.y] = nil
                local function p1(x,y)
                    local un = units[x] and units[x][y]
                    local id = x..','..y
                    -- if src.ind[id] then return end

                    local mt = GAME.map:get_tile(id)
                    local opacity = GAME.map.get_info(mt.id, "opacity")
                    local gm = b.f -opacity
                    if un and (un < gm)  then
                        gm = gm>=0.1 and gm or 0
                        units[x][y] = gm-->0.1 and gm or 0
                        table.insert(src.queue, {x=x, y=y, f=gm})
                        -- src.ind[id] = true
                    end
                end
                
                -- up propagation
                if (b.y-1 > 0) then
                    p1(b.x, b.y-1)
                end
                -- down propagation
                if (b.y+1 <= Light.h) then
                    p1(b.x, b.y+1)
                end
                -- left propagation
                if (b.x-1 > 0) then
                    p1(b.x-1, b.y)
                end
                -- right propagation
                if (b.x+1 <= Light.w) then
                    p1(b.x+1, b.y)
                end

                -- this Function here and the next IF statements make the light more round
                -- can be disabled for more performance or a diamond shape
                -- [[
                -- local function p2(x,y)
                --     local un = units[x] and units[x][y]
                --     local id = x..','..y
                --     local mt = GAME.map:get_tile(id)
                --     local opacity = GAME.map.get_info(mt.id, "opacity")
                --     if src.ind[id] then return end
                --     local gm = b.f -opacity*1.5
                --     if un and (un < gm)  then
                --         units[x][y] = gm
                --         table.insert(src.queue, {x=x, y=y, f=gm})
                --         src.ind[id] = true
                --     end
                -- end
                -- -- top_left propagation
                -- if (b.x-1 > 0) and (b.y-1 > 0) then
                --     p2(b.x-1, b.y-1)
                -- end
                -- -- top_right propagation
                -- if (b.x+1 <= Light.w) and (b.y-1 > 0) then
                --     p2(b.x+1, b.y-1)
                -- end
                -- -- botton_right propagation
                -- if (b.x+1 <= Light.w) and (b.y+1 <= Light.h) then
                --     p2(b.x+1, b.y+1)
                -- end
                -- -- botton_left propagation
                -- if (b.x-1 >0) and (b.y+1 <= Light.h) then
                --     p2(b.x-1, b.y+1)
                -- end
                --]]
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
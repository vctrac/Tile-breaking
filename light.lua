-- Light.lua
-- TODO: define quads of light, make active quad around mouse position and its neightbours
-- update only active quads
-- every quad has its own canvas

local lg = love.graphics
local tile = GAME.tile_size
local tiles_per_quad = 8
local quads_size = tiles_per_quad*tile

local units = {}
local sources = {}
local quads = {}

Light = {}
function Light.init( w,h)
    -- local div = d or 1 --TODO: set a conversion function for x,y Gridmap locations divided by div
    Light.w = w
    Light.h = h
    -- tile = t
    Light.quant = 0
    Light.canvas = lg.newCanvas(Light.w*tile,Light.h*tile)
    for x=1,Light.w do
        units[x] = {}
        for y=1,Light.h do
            units[x][y] = 0
        end
    end
    -- print("b4", w/tiles_per_quad)
    for x=1,(w/tiles_per_quad) do
        local xx = (x-1)*tiles_per_quad
        local sx = xx*tile
        for y=1,(h/tiles_per_quad) do
            local yy = (y-1)*tiles_per_quad

            quads[x..':'..y] = {
                start_y = yy,
                start_x = xx,
                screen_x = sx,
                screen_y = yy*tile,
                active = true,
                canvas = lg.newCanvas(quads_size,quads_size)
            }
            -- print(xx,yy)
        end
    end
end
function Light.update_canvas()
    --TODO: get all active quads and update their canvas
    for _,quad in pairs(quads) do
        -- print(id)
        if quad.active then
            lg.setCanvas(quad.canvas)
            lg.clear( )
            for x=1,tiles_per_quad do
                local xx = quad.start_x+x
                for y=1,tiles_per_quad do
                    local yy = quad.start_y+y
                    local c = units[xx][yy]

                    lg.setColor(c, c, c)
                    lg.rectangle("fill",(x-1)*tile,(y-1)*tile, tile, tile)
                end
            end
            lg.setCanvas()
            -- quad.active = false
        end
    end
end
function Light.O_update_canvas()
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
    Light.refresh()
end
function Light.add(id,x,y,f) --any: id, integer: pos_x, integer: pos_y, unsigned_float: force
    local qx = 1+math.floor(x/tiles_per_quad)
    local qy = 1+math.floor(y/tiles_per_quad)

    sources[id] = {x=x, y=y, f=f or 1, quad = qx..':'..qy}
    Light.quant = Light.quant +1
    Light.refresh()
end
function Light.add_sky(y,f) -- integer: pos_y, unsigned_float: force
    for i=1,Light.w do
        sources["sky_light"..i] = {x=i, y=y, f=f or 1, sun=true}
        Light.quant = Light.quant +1
    end
    Light.refresh()
end
function Light.remove(id)
    sources[id]=nil
    Light.quant = Light.quant -1
    Light.refresh()
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
function Light.set_quad_active(gx,gy)
    local x = 1+math.floor(gx/tiles_per_quad)
    local y = 1+math.floor(gy/tiles_per_quad)
    local id = x..':'..y
    if quads[id] then
        quads[id].active = true
    end
end
function Light.update()
    --get screen to world and disables quads outise of it
    -- local sx = 1+math.floor(Camera.x/quads_size)
    -- local sy = 1+math.floor(Camera.y/quads_size)
    -- local ex = 1+math.floor((Camera.x+Screen.w)/quads_size)
    -- local ey = 1+math.floor((Camera.y+Screen.h)/quads_size)
    -- if quads[ex..':'..ey] then
    --     quads[ex..':'..ey].active = false
    -- end
    for _,quad in pairs(quads) do
        quad.active = BoxCollision(quad.screen_x+quads_size*2,quad.screen_y+quads_size*2,quads_size,quads_size, Camera.x,Camera.y,Screen.w+quads_size*2,Screen.h+quads_size*2)
    end
end
function Light.refresh()
    for _,quad in pairs(quads) do
        if not quad.active then
            goto continue
        end
        for x=1,tiles_per_quad do
            local xx = quad.start_x+x
            for y=1,tiles_per_quad do
                local yy = quad.start_y+y
                units[xx][yy] = 0
        -- for x=1,Light.w do
            -- for y=1,Light.h do
                -- units[x][y] = 0
            end
        end
        ::continue::
    end
    for _,src in pairs(sources) do
        src.queue = {}

        table.insert(src.queue, src)
        units[src.x][src.y] = src.f
        
        if src.sun then
            local function foo(x,y,f)
                local un = units[x] and units[x][y]
                local id = x..','..y
                local mt = GAME.map:get_tile(id)
                local tile_opacity = GAME.map.get_info(mt.id, "opacity")
                local opacity = mt.id=="l_air" and 0.01 or tile_opacity
                local gm = f -opacity
                if un and (un < gm)  then
                    gm = gm>=0.1 and gm or 0
                    units[x][y] = gm
                    table.insert(src.queue, {x=x, y=y, f=gm})
                end
            end

            while (#src.queue>0) do
                local b = table.remove(src.queue, 1)
            
                -- up propagation
                -- if (b.y-1 > 0) then
                --     foo(b.x, b.y-1, b.f)
                -- end
                -- down propagation
                if (b.y+1 <= Light.h) then
                    foo(b.x, b.y+1, b.f)
                end
                -- left propagation
                if (b.x-1 > 0) then
                    foo(b.x-1, b.y, b.f)
                end
                -- right propagation
                if (b.x+1 <= Light.w) then
                    foo(b.x+1, b.y, b.f)
                end
            end
        elseif quads[src.quad].active then
            -- err()
            local function bar(x,y,f, mul)
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
            while (#src.queue>0) do
                local b = table.remove(src.queue, 1)
            
                -- up propagation
                if (b.y-1 > 0) then
                    bar(b.x, b.y-1, b.f)
                end
                -- down propagation
                if (b.y+1 <= Light.h) then
                    bar(b.x, b.y+1, b.f)
                end
                -- left propagation
                if (b.x-1 > 0) then
                    bar(b.x-1, b.y, b.f)
                end
                -- right propagation
                if (b.x+1 <= Light.w) then
                    bar(b.x+1, b.y, b.f)
                end

                -- the next 4 IF statements make the light more round
                -- disable it for more performance or a diamond shape

                -- top_left propagation
                if (b.x-1 > 0) and (b.y-1 > 0) then
                    bar(b.x-1, b.y-1, b.f, 1.5)
                end
                -- top_right propagation
                if (b.x+1 <= Light.w) and (b.y-1 > 0) then
                    bar(b.x+1, b.y-1, b.f, 1.5)
                end
                -- botton_right propagation
                if (b.x+1 <= Light.w) and (b.y+1 <= Light.h) then
                    bar(b.x+1, b.y+1, b.f, 1.5)
                end
                -- botton_left propagation
                if (b.x-1 >0) and (b.y+1 <= Light.h) then
                    bar(b.x-1, b.y+1, b.f, 1.5)
                end
            end
        end
    end
    Light.update_canvas()
end

function Light.draw()
    lg.setColor(1,1,1,0.5)
    -- love.graphics.setBlendMode("multiply","premultiplied")
    -- lg.draw( Light.canvas)
    for _,quad in pairs(quads) do
        -- if quad.active then
            lg.draw( quad.canvas, quad.screen_x, quad.screen_y)
        -- end
    end
    -- love.graphics.setBlendMode("alpha")
end

function Light.debug()
    -- err()
    for _,quad in pairs(quads) do
        -- print(1111111111)
        if quad.active then
            lg.setColor(1,1,0,0.6)
        else
            lg.setColor(1,0,0,0.3)
        end
        lg.rectangle("line", quad.screen_x, quad.screen_y,quads_size,quads_size)--quad.end_x,quad.end_y)
    end
end
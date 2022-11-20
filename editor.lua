-- editor.lua
local lg = love.graphics
local BLANK = {0,0,0,0}
local function to_id(x,y)
    return x..','..y
end

local function from_id(id)
    local t = {}
    for num in string.gmatch(id, '([^,]+)') do
        table.insert(t,tonumber(num))
    end
    return unpack(t)
end

local function rng_color( a)
    local function r() return math.random(4,8)*0.1 end
    -- return {1,1,1,a or 1}
    return {r(),r(),r(),a or 1}
end
--local frame = 
local layer = Lib.class{
    cells = {},
    pos = Lib.vec2(),
    visible = true,
    init = function(self, w, h)
        self.center = (Lib.vec2(w,h)*game.tile_size)*0.5
        self.width = w
        self.height = h
        self.img = lg.newCanvas(w*game.tile_size, h*game.tile_size)
        for i=1, w do
            for j=1, h do
                local id = to_id(i,j)
                self.cells[ id] = {
                    id = id,
                    value = math.random(32),
                    x = (i-1)*game.tile_size,
                    y = (j-1)*game.tile_size,
                    -- cor = math.random(3)==3 and rng_color() or BLANK,
                    -- cor = (i%2~=j%2) and rng_color() or BLANK,
                }
            end
        end
        -- self:update_canvas()
        print("layer created")
    end,
}

function layer:update_canvas(img, quads)
    lg.setCanvas(self.img)
    lg.clear()
    lg.setBlendMode("alpha")
    lg.setColor(1,1,1)
    for _,c in pairs(self.cells) do
        if c.value<1 then goto next end
        lg.draw(img, quads[c.value], c.x, c.y)

        -- lg.setColor(c.cor)
        -- lg.rectangle("fill", c.x, c.y, game.tile_size, game.tile_size)
        ::next::
    end
    lg.setCanvas()
end

function layer:draw( depth)

    local tx,ty = self.pos:unpack()

    lg.setColor(1,1,1)

    if depth==0 then
        lg.draw(self.img,tx,ty, 0, 1, 1,self.center.x, self.center.y)
    else
        local wx,wy = game.editor_cam:worldCoords(Screen.center:unpack())
        local dx = (tx - wx)*depth
        local dy = (ty - wy)*depth
        lg.draw( self.img, dx,dy, 0, 1+depth,1+depth, self.center.x,self.center.y)
    end

end

function layer:set_tile(id, v)
    self.cells[id].value = v
end
function layer:get_tile(x,y)
    return self.cells[to_id(x,y)]
end
function layer:remove()
    self.cells = nil
    print("layer removed")
end

local editor = {
    layers = {},
    layer_depth = 0,
    work_layer = 0,
}

function editor:init(w,h)
    self.dimensions = Lib.vec2( w,h)
    self.top = (Lib.vec2() - self.dimensions*0.5)*game.tile_size
    self.fin = self.dimensions*game.tile_size
    -- self:add_layer()
    self:add_layer()
    -- self:add_layer()
end
function editor:set_tile(x, y, v)
    --check if mouse is over tile
    local gx = math.clamp( math.floor(x/game.tile_size)+1, 1, self.dimensions.x)
    local gy = math.clamp( math.floor(y/game.tile_size)+1, 1, self.dimensions.y)
    self.layers[ work_layer]:set_tile( to_id(gx,gy), v)
end
function editor:add_layer()
    table.insert(self.layers, layer(self.dimensions.x, self.dimensions.y))
    self.work_layer = self.work_layer+1
    self:update_layer( )
end
function editor:update_layer( )
    if #self.layers<1 or not game.tileset.img then return end
    -- print(type(i), type(q), #q)
    self.layers[self.work_layer]:update_canvas(game.tileset.img, game.tileset.quads)
end
function editor:remove_layer( index)
    if #self.layers<1 then return end
    i = index or #self.layers
    self.layers[i]:remove()
    table.remove(self.layers, i)
    self.work_layer = i-1
end
function editor:set_layer_depth(v) self.layer_depth = #self.layers>1 and math.clamp(v,0,10)*0.005 or 0
end
function editor:get_layer_depth() return self.layer_depth*200
end
function editor:get_dimensions() return self.dimensions:unpack()
end
function editor:has_focus( )
    local mx,my = love.mouse.getPosition()
    local tx,ty = game.editor_cam:cameraCoords(self.top.x, self.top.y)
    local fx,fy = game.editor_cam:cameraCoords( (self.top+self.fin):unpack() )
    return point_inside(mx,my, tx,ty, fx, fy)
end
function editor:draw()
    --BG + BORDER
    lg.setColor(0,0,0,0.2)
    lg.rectangle("fill", self.top.x-2,self.top.y-2,self.dimensions.x*game.tile_size+4, self.dimensions.y*game.tile_size+4)

    for i, layer in ipairs(self.layers) do
        layer:draw( (i-1)*self.layer_depth)
    end
end
return editor
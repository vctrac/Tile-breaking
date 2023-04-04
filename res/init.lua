local la = love.audio
local li = love.image
local lg = love.graphics

local ip = 'res/img/'
local sp = 'res/sfx/'

lg.setDefaultFilter("nearest", "nearest")

local res = {}
res.img = {
    tileset = lg.newImage(ip.."tileset.png"),
    sky = lg.newImage(ip.."sky.png"),
    backpack = lg.newImage(ip.."backpack.png"),
    slot = lg.newImage(ip.."slot.png"),
    hud_arrow = lg.newImage(ip.."arrow.png"),
    grass_tile = lg.newImage(ip.."grass.png"),
    walls_at = lg.newImage(ip.."walls_at.png"),
    ground_at = lg.newImage(ip.."ground_at.png"),
    -- autotile = lg.newImage(ip.."autotile.png"),
    -- autotile_light = lg.newImage(ip.."autotile_light.png"),
    --
    cursor_eye1 = li.newImageData(ip.."eye100.png"),
    cursor_eye2 = li.newImageData(ip.."eye75.png"),
    cursor_eye3 = li.newImageData(ip.."eye50.png"),
    cursor_eye4 = li.newImageData(ip.."eye25.png"),
    cursor_eye5 = li.newImageData(ip.."eye0.png"),
    cursor_sizeall = li.newImageData(ip.."sizeall.png"),
    cursor_pickaxe = li.newImageData(ip.."pickaxe.png"),
    cursor_pickaxe_hit = li.newImageData(ip.."pickaxe_hit.png"),
    cursor_sword = li.newImageData(ip.."machete.png"),
    cursor_sword_hit = li.newImageData(ip.."machete_hit.png"),
    cursor_cross = li.newImageData(ip.."cross.png"),
    cursor_null = li.newImageData(ip.."null.png"),
    cursor_hand = li.newImageData(ip.."hand.png"),
    cursor_hand_grab = li.newImageData(ip.."hand_grab.png"),
    cursor_zoom_in = li.newImageData(ip.."zoom_in.png"),
    cursor_zoom_out = li.newImageData(ip.."zoom_out.png"),
}
res.sfx = {
    block_break = la.newSource(sp.."block_break.wav", "static"),
    hit_block = la.newSource(sp.."hit_block.wav", "static"),
    place_block = la.newSource(sp.."place_block.wav", "static"),
    pickup = la.newSource(sp.."pickup.wav", "static"),
    explosion = la.newSource(sp.."explosion.wav", "static"),
}

local sw, sh = res.img.tileset:getWidth(), res.img.tileset:getHeight()
local ts = 32
local hts = 16
res.quads = {
    --block tiles
    air = lg.newQuad( 32, 64, ts, ts, sw, sh ),--empty tile
    dark = lg.newQuad( 0, 0, ts, ts, sw, sh ),
    dirt = lg.newQuad( 64, 0, ts, ts, sw, sh ),
    stone = lg.newQuad( 32, 0, ts, ts, sw, sh ),
    rock = lg.newQuad( 32, 32, ts, ts, sw, sh ),
    grass = lg.newQuad( 96, 0, ts, ts, sw, sh ),
    gravel = lg.newQuad( 96, 32, ts, ts, sw, sh ),
    blocker = lg.newQuad( 0, 64, ts, ts, sw, sh ),
    plank = lg.newQuad( 0, 32, ts, ts, sw, sh ),
    wood = lg.newQuad( 64, 32, ts, ts, sw, sh ),
    leaf = lg.newQuad( 96, 32, ts, ts, sw, sh ),
    light = lg.newQuad( 129, 33, ts-2, ts-2, sw, sh ),
    frame = lg.newQuad( 32, 64, ts, ts, sw, sh ),

    head = lg.newQuad( ts*6, ts*2, ts, ts, sw, sh ),
    ring = lg.newQuad( ts*7, ts*2, ts, ts, sw, sh ),
    tail = lg.newQuad( ts*6, ts, ts, ts, sw, sh ),
    --16x SPRITES
    sprites = {
        small_grass = lg.newQuad( 0, 96, hts, hts, sw, sh ),
        big_rock = lg.newQuad( 16, 96, hts, hts, sw, sh ),
        small_rock = lg.newQuad( 32, 96, hts, hts, sw, sh ),
        flower1 = lg.newQuad( 0, 96, hts, hts, sw, sh ),
        flower2 = lg.newQuad( 16, 96, hts, hts, sw, sh ),
        flower3 = lg.newQuad( 16, 96, hts, hts, sw, sh ),
        big_grass1 = lg.newQuad( 0, 128, ts, hts, sw, sh ),
        big_grass2 = lg.newQuad( 0, 144, ts, hts, sw, sh )
    },
    items = {
        coal = lg.newQuad( 160, 0, ts, hts, sw, sh ),
        stone = lg.newQuad( 160, hts, ts, hts, sw, sh ),
        iron = lg.newQuad( 160, 32, ts, hts, sw, sh ),
        gold = lg.newQuad( 160, 32+hts, ts, hts, sw, sh ),
        bomb = lg.newQuad( 128, 0, ts, ts, sw, sh ),
        dung = lg.newQuad( 192, 0, ts, hts, sw, sh ),
        bones = lg.newQuad( 192, hts, ts, hts, sw, sh ),
    }
}
-- for i=0, 4 do
--     res.quads.eye["level" .. i+1] = lg.newQuad( i*ts, 0, ts, ts, ts*5, sh )
-- end
res.quads.items.light = res.quads.light
res.quads.items.blocker = res.quads.blocker
res.font = lg.newImageFont(ip.."Imagefont.png",
"_abcdefghijklmnopqrstuvwxyz" ..
"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
"123456789.,!?-+/():;%&`'*#=[]\"")

return res
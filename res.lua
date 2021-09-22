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
    hud_arrow = lg.newImage(ip.."arrow.png"),
    --
    cursor_sizeall = li.newImageData(ip.."sizeall.png"),
    cursor_pickaxe = li.newImageData(ip.."pickaxe.png"),
    cursor_pickaxe_hit = li.newImageData(ip.."pickaxe_hit.png"),
    cursor_sword = li.newImageData(ip.."machete.png"),
    cursor_sword_hit = li.newImageData(ip.."machete_hit.png"),
    cursor_cross = li.newImageData(ip.."cross.png"),
    cursor_hand = li.newImageData(ip.."hand.png"),
    cursor_hand_grab = li.newImageData(ip.."hand_grab.png"),
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
    air = lg.newQuad( 0, 0, ts, ts, sw, sh ),
    dirt = lg.newQuad( 64, 0, ts, ts, sw, sh ),
    stone = lg.newQuad( 32, 0, ts, ts, sw, sh ),
    rock = lg.newQuad( 32, 32, ts, ts, sw, sh ),
    gravel = lg.newQuad( 96, 32, ts, ts, sw, sh ),
    blocker = lg.newQuad( 0, 64, ts, ts, sw, sh ),
    items = {
        torch = lg.newQuad( 128, 32, ts, ts, sw, sh ),
        coal = lg.newQuad( 160, 0, ts, hts, sw, sh ),
        stone = lg.newQuad( 160, hts, ts, hts, sw, sh ),
        iron = lg.newQuad( 160, 32, ts, hts, sw, sh ),
        gold = lg.newQuad( 160, 32+hts, ts, hts, sw, sh ),
        bomb = lg.newQuad( 128, 0, ts, ts, sw, sh ),
        dung = lg.newQuad( 192, 0, ts, hts, sw, sh ),
        bones = lg.newQuad( 192, hts, ts, hts, sw, sh ),
    }
    -- ore_gold = lg.newQuad( 128, 32, ts, ts, sw, sh ),
}
res.quads.items.blocker = res.quads.blocker
res.font = lg.newImageFont(ip.."Imagefont.png",
"_abcdefghijklmnopqrstuvwxyz" ..
"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
"123456789.,!?-+/():;%&`'*#=[]\"")

return res
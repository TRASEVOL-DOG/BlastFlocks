-- BLAST FLOCK source files
-- by TRASEVOL_DOG (https://trasevol.dog/)

if CASTLE_PREFETCH then
  CASTLE_PREFETCH({
    'main.lua',
    'main.lua',
    'game.lua',
    'drawing.lua',
    'game.lua',
    'input.lua',
    'sprite.lua',
    'drawing.lua',
    'shader.lua',
    'input.lua',
    'maths.lua',
    'sprite.lua',
    'audio.lua',
    'shader.lua',
    'maths.lua',
    'audio.lua',
    'object.lua',
    'object.lua',
    'ttable.lua',
    'nnetwork.lua',
    'menu.lua',
    'ttable.lua',
    'nnetwork.lua',
    'ships.lua',
    'fx.lua',
    'menu.lua',
    'ships.lua',
    'fx.lua',
    'cs.lua',
    'cs.lua',
    'state.lua',
    'state.lua',
    'assets/Marksman.ttf',
    'assets/EffortsPro.ttf',
    'assets/sheet.png',
    'assets/blastflock.png',
    'assets/order.ogg',
    'assets/steelandorder.ogg',
    'assets/sfx/boom3.ogg',
    'bitser.lua',
    'assets/sfx/sliderset.ogg',
    'assets/sfx/hole.ogg',
    'bitser.lua',
    'assets/sfx/scrap.ogg',
    'assets/sfx/dog.ogg',
    'assets/sfx/boom1.ogg',
    'assets/sfx/gameover.ogg',
    'assets/sfx/helix.ogg',
    'assets/sfx/levelup.ogg',
    'assets/sfx/boost.ogg',
    'assets/sfx/shoot.ogg',
    'assets/sfx/select.ogg',
    'assets/sfx/confirm.ogg',
    'assets/sfx/save.ogg',
    'assets/sfx/shootorder.ogg',
    'assets/sfx/enemshoot.ogg',
    'assets/sfx/boom2.ogg',
    'palswap.shader',
  })
end


require("game")
require("drawing")
require("input")
require("sprite")
require("shader")
require("maths")
require("audio")

USE_CASTLE_CONFIG = true
require("server")
require("client")


function step()
  if love.timer then
    love.timer.step()
    dt = love.timer.getDelta()
    if dt < 1/30 then
      love.timer.sleep(1/30 - dt)
    end
    dt=max(dt,1/30)
  end
end

function eventpump() -- here to avoid things bugging out
end


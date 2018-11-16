--require("testb")
require("drawing")
--require("sprite")

local GAME_WIDTH = 600
local GAME_HEIGHT = 600

local PLAYER_SPEED = 256

local playerVelocity = {
  x = 0,
  y = 0
}

local playerPos = {
  x = 100,
  y = 100
}

--local testsheet = love.graphics.newImage('assets/sheet.png')
function love.load()
  -- here, you might load resources like images or sounds
  init_graphics(128,128,4,4,"Hello")
  
--  init_sprite_mgr()
end

function love.update(dt)
  -- holding arrow keys determines player's velocity
  moveit(playerVelocity, dt)

  -- move the player
  playerPos.x = playerPos.x + playerVelocity.x
  playerPos.y = playerPos.y + playerVelocity.y
end

function love.draw()
 love.graphics.setCanvas(render_canvas)
 --love.graphics.origin()
 if _draw then _draw() end

 love.graphics.setCanvas()
 love.graphics.setColor(255,255,255,255)
 love.graphics.origin()
 love.graphics.draw(render_canvas,0,0,0,graphics.scrn_scalex,graphics.scrn_scaley)
 love.graphics.present()
end

function _draw()
  cls(0)
  color(8)
  circfill(playerPos.x, playerPos.y, 20)
end



local PLAYER_SPEED = 256

function moveit(playerVelocity, dt)
  -- holding arrow keys determines player's velocity
  playerVelocity.x, playerVelocity.y = 0, 0
  if love.keyboard.isDown("right") then 
    playerVelocity.x = playerVelocity.x + PLAYER_SPEED * dt
  end
  if love.keyboard.isDown("left") then
    playerVelocity.x = playerVelocity.x - PLAYER_SPEED * dt
  end
  if love.keyboard.isDown("up") then 
    playerVelocity.y = playerVelocity.y - PLAYER_SPEED * dt
  end
  if love.keyboard.isDown("down") then
    playerVelocity.y = playerVelocity.y + PLAYER_SPEED * dt
  end
end
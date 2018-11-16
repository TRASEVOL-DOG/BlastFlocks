-- BLAST FLOCK source files
-- by TRASEVOL_DOG (https://trasevol.dog/)

require("game")
require("drawing")
require("input")
require("sprite")
require("shader")
require("maths")
require("audio")


function love.load()
  init_graphics(400,300,2,2)
  init_audio()
  init_sprite_mgr()
  init_shader_mgr()
  init_input_mgr()
  font("pico")
  _init()
end

function love.draw()
  predraw()
  _draw()
  afterdraw()
end

function love.update(dt)
  if dt < 1/30 then
    love.timer.sleep(1/30 - dt)
  end
  dt=max(dt,1/30)
 
  _update(dt)
  update_input_mgr()
end

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

function eventpump()
  if love.event then
    love.event.pump()
    for name, a,b,c,d,e,f in love.event.poll() do
      if name == "quit" then
        if not love.quit or not love.quit() then
          return a or 1
        end
      end
      love.handlers[name](a,b,c,d,e,f)
    end
  end
  
  return nil
end

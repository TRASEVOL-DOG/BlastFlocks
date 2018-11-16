-- BLAST FLOCK source files - by TRASEVOL_DOG
-- /!\ do not redistribute /!\
-- Download game at trasevol-dog.itch.io/blast-flock
-- Ask questions to @TRASEVOL_DOG on Twitter
-- Support TRASEVOL_DOG on patreon.com/trasevol_dog

require("game")
require("drawing")
require("input")
require("sprite")
require("shader")
require("maths")
require("audio")

function love.run()
 
 if love.math then
  love.math.setRandomSeed(os.time())
 end
 
 if love.load then love.load(arg) end

 -- We don't want the first frame's dt to include time taken by love.load.
 if love.timer then love.timer.step() end
 
 love.event.clear()
 
 local dt = 0
 
 -- Main loop time.
 while true do
 
  -- Update dt, as we'll be passing it to update
  step()
 
  -- Process events.
  local a=eventpump()
  if a then
   return a
  end
 
  -- Call update and draw
  if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled
 
  if love.graphics and love.graphics.isActive() then
   drawstep()
  end
 
  if love.timer then love.timer.sleep(0.001) end
 end
end


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
 _draw()
end

function love.update(dt)
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

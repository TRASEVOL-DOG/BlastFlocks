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
  init_graphics(2,2)
  init_audio()
  init_shader_mgr()
  init_input_mgr()
  font("small")
  _init()
end

function love.draw()
  predraw()
  _draw()
  afterdraw()
end

delta_time = 0
dt30f = 0
function love.update(dt)
  delta_time = love.timer.getDelta()
  dt30f = dt*33
 
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
--  if love.event then
--    love.event.pump()
--    for name, a,b,c,d,e,f in love.event.poll() do
--      if name == "quit" then
--        if not love.quit or not love.quit() then
--          return a or 1
--        end
--      end
--      love.handlers[name](a,b,c,d,e,f)
--    end
--  end
--  
--  return nil
end

function love.resize(w,h)
  render_canvas=love.graphics.newCanvas(w,h)
  render_canvas:setFilter("nearest","nearest")
  local scx,scy=screen_scale()
  
  graphics.wind_w=w
  graphics.wind_h=h
  graphics.scrn_w=flr(w/scy)
  graphics.scrn_h=flr(h/scx)
end


--function love.keypressed(key)
--    if key == '1' then
--        server = sync.newServer { address = '*:22122', controllerTypeName = 'Controller' }
--    end
--    if key == '2' then
--        client = sync.newClient { address = '127.0.0.1:22122' }
--    end
--end

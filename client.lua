local cs = require 'cs'
client = cs.client

if USE_CASTLE_CONFIG then
  client.useCastleConfig()
else
  client.enabled = true
  client.start('127.0.0.1:22122') -- IP address ('127.0.0.1' is same computer) and port of server
end

client.changed = read_client


function client.connect() -- Called on connect from server
    castle_print("Client connected!")
end


-- Client gets all Love events

local client_init = false
function client.load()
  if client_init then
    castle_print("Attempt to 2nd client init?")
    return
  end
  castle_print("Starting client init...")

  init_graphics(2,2)
  init_audio()
  init_shader_mgr()
  init_input_mgr()
  font("small")
  pal()
  _init()
  
  love.keyboard.setKeyRepeat(true)
  love.keyboard.setTextInput(false)
  
  client_init = true
  castle_print("Client init done!")
end
local client_load_sav = client.load

delta_time = 0
dt30f = 0
function client.update(dt)
  if not client_init then
    castle_print("Calling client.load from update.")
    client.load = client_load_sav
    client.load()
    return
  end

  delta_time = dt
  dt30f = dt*30
 
  _update(dt)
  update_input_mgr()
end

function client.draw()
  if not client_init then
    castle_print("no init.")
    return
  end

  predraw()
  _draw()
  afterdraw()
end


function client.resize(w,h)
  render_canvas=love.graphics.newCanvas(w,h)
  render_canvas:setFilter("nearest","nearest")
  local scx,scy=screen_scale()
  
  graphics.wind_w=w
  graphics.wind_h=h
  graphics.scrn_w=flr(w/scy)
  graphics.scrn_h=flr(h/scx)
end

function client.textinput(text)
  menu_textinput(text)
end

function client.keypressed(key)
  input_keypressed(key)
end

function client.keyreleased(key)
  input_keyreleased(key)
end

function client.mousepressed(x,y,k,istouch)
  input_mousepressed(x,y,k,istouch)
end

function client.mousereleased(x,y,k,istouch)
  input_mousereleased(x,y,k,istouch)
end


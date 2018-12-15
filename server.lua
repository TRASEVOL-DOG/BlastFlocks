local cs = require 'cs'
server = cs.server

if USE_CASTLE_CONFIG then
  server.useCastleConfig()
else
  server.enabled = true
  server.start('22122') -- Port of server
end

server.changed = read_server
server.disconnect = server_client_disconnected




-- Server only gets `.load`, `.update`, `.quit` Love events (also `.lowmemory` and `.threaderror`
-- which are less commonly used)

local server_init
function server.load()
  if server_init then
    castle_print("Attempt to 2nd server init?")
    return
  end
  castle_print("Starting server init...")

  server_only = true
  
  local syss = {"audio", "graphics", "video", "window"}
  local syssav = {}
  for sys in all(syss) do
    syssav[sys], love[sys] = love[sys], nil
  end
  
  
  _init()
  
  
  for sys in all(syss) do
    love[sys] = syssav[sys]
  end
  
  server_only = false
  
  server_init = true
  castle_print("Server init done!")
end
local server_load_sav = server.load

delta_time = 0
dt30f = 0
function server.update(dt)
  if not server_init then
    castle_print("Calling server.load from update.")
    server.load = server_load_sav
    server.load()
    return
  end
  
--  castle_print("server update")

  server_only = true
  delta_time = dt
  dt30f = dt*30
  
  local syss = {"audio", "graphics", "video", "window"}
  local syssav = {}
  for sys in all(syss) do
    syssav[sys], love[sys] = love[sys], nil
  end

  
  --update_game()
  _update()
  
  
  for sys in all(syss) do
    love[sys] = syssav[sys]
  end
  
  server_only = false
end


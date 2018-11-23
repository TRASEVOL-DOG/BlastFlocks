-- BLAST FLOCK source files
-- by TRASEVOL_DOG (https://trasevol.dog/)

local cs = require("cs")
--require("state")


--local Controller = sync.registerType('Controller')

client, server = nil, nil
server_address = '127.0.0.1'

function start_server()
  if not server then
    server = cs.server
    server.enabled = true
    server.start('22122')
    server.changed = read_server
    print("Starting local server.")
  else
    print("Local server already exists.")
  end  
end

function connect_to_server()
  if not client then
    local address = server_address..':22122'
    client = cs.client
    client.enabled = true
    client.start(address)
    client.changed = read_client
    print("Connecting to server at "..address)
  else
    print("Already connected or connecting.")
  end
end


function read_client()
  if not (client and client.connected) then
    return
  end
  
  my_id = client.id
  
  --if server then return end -- should client be read if it's also the server??
  
  for id, p in pairs(players) do
    if not client.share[id] and id~=my_id then
      print("Player #"..id.." either disconnected or is no longer relevant")
      -- remove player
    end
  end
  
  for id, p_d in pairs(client.share) do
    local p = players[id]
    if not p then
      if id == my_id then
        p = player
        p.x = p_d[1]
        p.y = p_d[2]
        p.shooting = p_d[3]
        p.boosting = p_d[4]
        p.colors = {p_d[5], p_d[6]}
        p.seed = p_d[7]
        
        players[id] = p
      else
        p = create_player(
          p_d[1],
          p_d[2],
          {p_d[5], p_d[6]},
          p_d[7],
          p_d[3],
          p_d[4],
          id == my_id
        )
        players[id] = p
      end
    else
      if id ~= my_id then
        p.x = p_d[1]-- or p.x
        p.y = p_d[2]-- or p.y
        p.shooting = p_d[3]
        p.boosting = p_d[4]
      end
    end
    
    local sh = p.ships
    local sh_d = p_d[8]
    
    --debuggg = #sh.." / "..#sh_d
    
    for i=1,#sh_d do
      local s = sh[i]
      local d = sh_d[i]

      if s then
        s.x      = d[1]
        s.y      = d[2]
        s.vx     = d[3]
        s.vy     = d[4]
        s.typ_id = d[5]
        s.type   = ship_types[d[5]]
      else
        sh[i] = create_ship(
          d[1], d[2],
          d[3], d[4],
          d[5], id
        )
      end
    end
  end
end

function read_server()
  if not server then
    return
  end
  
  my_id = 0

  for id, p in pairs(players) do
    if id ~= 0 and not server.homes[id] then
      print("Client #"..id.." disconnected from the server.")
      -- delete player and convert all their planes to AI?
    end
  end
  
  for id, ho in pairs(server.homes) do
    if players[id] then
      local p = players[id]
      p.x = ho[1]  or 0
      p.y = ho[2]  or 0
      p.shooting = ho[3]
      p.boosting = ho[4]
      
      --debuggg = (p.x).." ? "..(ho[1] or 0).." id : "..id.." - "
      --for i,k in pairs(ho) do
      --  debuggg = debuggg..i..":"..type(k).." | "
      --end
      
      --error(type(p.x).."|"..type(p.y).."|"..type(p.shooting).."|"..type(p.boosting))
    else
      server_new_player(id)
    end
  end
end



function update_client()
  if not (client and client.connected) then
    return
  end
  
  if players[my_id] then
    --local p_d = client.home
    client.home[1] = flr(player.x)
    client.home[2] = flr(player.y)
    client.home[3] = player.shooting
    client.home[4] = player.boosting
    
    --error(type(player.x).."|"..type(player.y).."|"..type(player.shooting).."|"..type(player.boosting))
  end
end

function update_server()
  if not server then
    return
  end
  
  --local ps = {}
  for id, p in pairs(players) do
    local p_d = server.share[id]
    
    p_d[1] = flr(p.x)
    p_d[2] = flr(p.y)
    p_d[3] = p.shooting
    p_d[4] = p.boosting
    
    local sh = p.ships
    local sh_d = p_d[8]
    
    --debuggg = #sh.." / "..#sh_d
    
    for i=1,#sh do
      local s = sh[i]
      sh_d[i] = {
        flr(s.x),
        flr(s.y),
        s.vx,
        s.vy,
        s.typ_id
      }
    end
  end
  --server.share = ps
end


function server_new_player(player_id)
  local x,y = 0,0 --rnd(areaw), rnd(areah)
  local colors = {}
  local seed = irnd(32000)
  
  local p = create_player(x, y, colors, seed, false, false, player_id == (client and client.id or my_id))
  players[player_id] = p

  -- create starter ships
  lsrand(seed)
  for i=1,10 do
    add(p.ships, create_ship(x, y, rnd(4)-2, rnd(4)-2, nil, player_id))
  end
  
  
  local p_d = {
    -- 1-4: cursor info -> written in server_update
    [5] = colors[1],
    [6] = colors[2],
    [7] = seed,
    [8] = {}, -- planes, filled up in server_update
    [9] = {}  -- bullets, filled up in server_update
  }
  server.share[player_id] = p_d
  
  return p
end


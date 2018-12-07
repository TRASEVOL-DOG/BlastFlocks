-- BLAST FLOCK source files
-- by TRASEVOL_DOG (https://trasevol.dog/)

local cs = require("cs")
--require("state")


--local Controller = sync.registerType('Controller')

client, server = nil, nil
server_address = '127.0.0.1'
server_port = '22122'

local _old_server = nil

function start_server()
  if not server then
    if _old_server then
      server = _old_server
      server.enabled = true
    else
      server = cs.server
      server.enabled = true
      server.start(server_port)
    end
    
    server.changed = read_server
    server.disconnect = server_client_disconnected
    castle_print("Starting local server on port "..server_port)
  else
    castle_print("Local server already exists.")
  end  
end

function connect_to_server()
  if not client then
    local address = server_address..':'..server_port
    client = cs.client
    client.enabled = true
    client.start(address)
    client.changed = read_client
    castle_print("Connecting to server at "..address)
    
    connecting = true
  else
    castle_print("Already connected or connecting.")
  end
end


function read_client()
  if not (client and client.connected) then
    return
  end
  
  my_id = client.id
  
  local delay = (client.getPing()/2)/1000 -- ????
  
  --if server then return end -- should client be read if it's also the server??
  
  for id, p in pairs(players) do
    if id ~= my_id and not client.share[id] then
      castle_print("Player #"..id.." either disconnected or is no longer relevant")
      -- remove player
      for _,s in pairs(p.ships) do
        deregister_object(s)
      end
      deregister_object(p)
      players[id] = nil
    end
  end
  
  for id, p_d in pairs(client.share) do
    local p = players[id]
    if not p then
      if id == my_id then
        castle_print("Connected! I'm player #"..id)
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
      new_group("ship_player"..id)
      p.id = id
    elseif id >= 0 then
      if id ~= my_id then
        p.x = p_d[1]-- or p.x
        p.y = p_d[2]-- or p.y
        p.shooting = p_d[3]
        p.boosting = p_d[4]
      end
    end
    p.name = p_d[9] or ""
    
    local sh = p.ships
    local sh_d = (id == -2) and p_d[1] or p_d[8]

    local readids = {}

    for s_id,d in pairs(sh_d) do
    
      local s = sh[s_id]
    
      if s then
        if s.update_id < d[8] then
          s.dx = s.dx+ (((s.x-d[1]+areaw/2)%areaw)-areaw/2)
          s.dy = s.dy+ s.y-d[2]
          
          s.x      = d[1] + delay*30*d[3]
          s.y      = d[2] + delay*30*d[4]
          s.vx     = d[3]
          s.vy     = d[4]
          s.hp     = d[5]
          s.t      = d[6]
          s.typ_id = d[7]
          s.type   = ship_types[s.typ_id]
          s.update_id = d[8]
        end
      else
        s = create_ship(
          d[1] + delay*30*d[3],
          d[2] + delay*30*d[4],
          d[3], d[4],
          d[7], id, s_id
        )
        s.t  = d[6]
        s.hp = d[5]
        s.update_id = d[8]
        sh[s_id] = s
        
        if s.t < 1 and id~=-2 then
          sfx("save")
        end
      end
      
      readids[s.id] = true
    end
    
    for s_id,s in pairs(sh) do
      if not readids[s_id] then
        if id > -2 or s.t < -1.8 then -- visible destroy
          destroy_ship(s)
        else                          -- discreet destroy
          deregister_object(s)
          sh[s_id] = nil
        end
      end
    end
  end
end

function read_server()
  if not server then
    return
  end
  
  my_id = 0
  
  for id, ho in pairs(server.homes) do
    if players[id] then
      local p = players[id]
      p.x = ho[1]  or 0
      p.y = ho[2]  or 0
      p.shooting = ho[3]
      p.boosting = ho[4]
      p.name = ho[5]
    else
      castle_print("New connection: Client #"..id);
      server_new_player(id)
    end
  end
end



function update_client()
  if not (client and client.connected) then
    return
  end
  
  if players[my_id] then
    client.home[1] = flr(player.x)
    client.home[2] = flr(player.y)
    client.home[3] = player.shooting
    client.home[4] = player.boosting
    client.home[5] = my_name
  end
end

ship_up_i = 0
ship_up_k = 2
function update_server()
  if not server then
    return
  end
  
  if (#players >= 8) then
    ship_up_k = 1
  elseif (#players >= 4) then
    ship_up_k = 2
  else
    ship_up_k = 3
  end
  
  ship_up_i = ship_up_i + ship_up_k
  
  --local ps = {}
  for id, p in pairs(players) do
    local p_d = server.share[id]
    if p_d then
      if id >= 0 then
        p_d[1] = flr(p.x)
        p_d[2] = flr(p.y)
        p_d[3] = p.shooting
        p_d[4] = p.boosting
        p_d[9] = p.name
      end
      
      local sh = p.ships
      local sh_d = (id == -2) and p_d[1] or p_d[8]
      
      readids = {}
      
      for i=1,#sh do
        local s = sh[i]
        
        if (i-ship_up_i)%#sh < ship_up_k or not sh_d[s.id] then
          s.update_id = s.update_id + 1
          sh_d[s.id] = {
            flr(s.x),
            flr(s.y),
            s.vx,
            s.vy,
            s.hp,
            s.t,
            s.typ_id,
            s.update_id
          }
        end
        readids[s.id] = true
      end
      
      for s_id,d in pairs(sh_d) do
        if not readids[s_id] then
          sh_d[s_id] = nil
        end
      end
      
      --while #sh_d > #sh do
      --  sh_d[#sh_d] = nil
      --end
    end
  end
  --server.share = ps
end


function server_client_disconnected(id)
  castle_print("Client #"..id.." disconnected from the server.")
  -- delete player and convert all their planes to AI?
  -- currently: simply delete player and all their ships
  local p = players[id]
  for _,s in pairs(p.ships) do
    deregister_object(s)
  end
  deregister_object(p)
  players[id] = nil
  
  server.share[id] = nil
end

function client_disconnect()
  if not client then return end
  
  if client.id then
    castle_print("Disconnecting as client #"..client.id)
  else
    castle_print("Abandoning connection.")
  end
  
  client.id, client.connected = nil, nil
  client, my_id = nil, nil
  
  players = {}
  player = create_player(64+32*cos(0.1),64+32*sin(0.1), nil, nil, false, false, nil)
end

function server_close()
  if not server then return end
  
  server.enabled = false
  server.changed = nil
  server.disconnect = nil
  _old_server, server = server, nil
end


function server_new_player(player_id)
  local x,y = rnd(areaw)-areaw/2, rnd(areah-80)+40
  local seed = irnd(32000)
  local colors = new_player_color()

  local p = create_player(x, y, colors, seed, false, false, player_id)
  players[player_id] = p

  -- create starter ships
  lsrand(seed)
  for i=1,8 do
    add(p.ships, create_ship(x, y, rnd(4)-2, rnd(4)-2, nil, player_id))
  end
  
  
  local p_d = {
    -- 1-4: cursor info -> written in server_update
    [5] = colors[1],
    [6] = colors[2],
    [7] = seed,
    [8] = {}, -- planes, filled up in server_update
    --[9] = {}  -- name
  }
  server.share[player_id] = p_d
  
  castle_print("Player #"..player_id.." created.");
  
  return p
end

function server_define_non_players()
  client_define_non_players()
  
  local p_d = {
    [1] = {}, -- planes, filled up in server_update
  }
  server.share[-2] = p_d
end

function client_define_non_players()
  local p = {  -- Neutralized / Falling ships
    t      = 0,
    colors = {22,22},
    seed   = 0,
    ships  = {},
    id     = -2,
    update = update_player,
    regs   = {"to_update"}
  }
  register_object(p)
  players[-2] = p
end


function new_player_color()
  local cols = pick(ship_poss)
  del(ship_poss, cols)
  add(ship_nposs, cols)
  if #ship_poss == 0 then
    ship_poss = ship_nposs
    ship_nposs = {}
  end
  
  return cols
end

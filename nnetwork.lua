-- BLAST FLOCK source files
-- by TRASEVOL_DOG (https://trasevol.dog/)

local cs = require("cs")


--client, server = nil, nil
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
--  if not client then
--    local address = server_address..':'..server_port
--    client = cs.client
--    client.enabled = true
--    client.start(address)
--    client.changed = read_client
--    castle_print("Connecting to server at "..address)
--    
--    connecting = true
--  else
--    castle_print("Already connected or connecting.")
--  end

  connecting = true
end


local delay
function read_client()
  if not (client and client.connected) then
    return
  end
  
  my_id = client.id
  
  -- calculate delay
  if not (client.share[my_id] and client.share[my_id][99]) then
    return
  end
  
  local lt = client.share[my_id][99]
  delay = (love.timer.getTime() - lt)/2

  -- check for disconnected players
  for id, p in pairs(players) do
    if id ~= my_id and not client.share[id] then
      castle_print("Player #"..id.." disconnected.")
      -- remove player
      if p.ships then
        for _,s in pairs(p.ships) do
          deregister_object(s)
        end
      end
      
      deregister_object(p)
      players[id] = nil
    end
  end
  
  -- read da data
  for id, p_d in pairs(client.share) do
    if id == -1 then
      read_gangs(p_d)
    else
      read_player(p_d, id)
    end
  end
end

function read_gangs(data)
  local readids = {}

  for s_id,d in pairs(data) do
    local s = gang_grid[s_id]

    if s then
      if s.update_id < d[3] then
        sync_gang(s, d[1], d[2], delay)
        s.update_id = d[3]
      end
    else
      s = create_gang(nil, nil, s_id, d[2], d[1])
      s.update_id = d[3]
    end
    
    readids[s_id] = true
  end
  
  for s_id,s in pairs(gang_grid) do
    if not readids[s_id] then
      delete_gang(s)
    end
  end
end

function read_player(p_d, id)
  local p = players[id]
  if not p then
    if id == my_id then
      castle_print("Connected! I'm player #"..id)
      p = player
      p.colors = {p_d[5], p_d[6]}
      p.id = my_id
      players[id] = p
    else
      castle_print("Player #"..id.." joined the game!")
      p = create_player(
        p_d[1],
        p_d[2],
        {p_d[5] or 8, p_d[6] or 8},
        p_d[3],
        p_d[4],
        id == my_id
      )
      players[id] = p
    end
    new_group("ship_player"..id)
    p.id = id
  end
  p.name = p_d[7] or ""
  --p.colors = {p_d[5], p_d[6]}
  p.colors[1] = p.colors[1] or p_d[5] --or 8
  p.colors[2] = p.colors[2] or p_d[6] --or 8
  
  
  if p_d[9] then   -- player is far
    if p.ships then
      -- silent-delete all this player's ships
      for _,sh in pairs(p.ships) do
        deregister_object(sh)
      end
      p.ships = {}
    end
    p.far = true
    
    p.msize = p_d[9]
    p.mx = p_d[10]
    p.my = p_d[11]
  else             -- player is close, or self, or neutralized ships
    if not p.ships then
      p.ships = {}
    end
    p.far = false
  
    if p_d[2] then -- player is not self
      p.x = p_d[1]
      p.y = p_d[2]
      p.shooting = p_d[3]
      p.boosting = p_d[4]
    end   
  
    read_player_ships(p, p_d, id)
  end
end

function read_player_ships(p, p_d, id)
  local sh = p.ships
  local sh_d = (id == -2) and p_d[1] or p_d[8]
  
  if sh_d then
    local readids = {}
    
    local upgrade_counts = 0
    
    for s_id,d in pairs(sh_d) do
      local s = sh[s_id]
      if s and s.update_id < d[8] and d[7]>s.typ_id then -- upgrade!
        upgrade_counts = upgrade_counts + 1
      end
    end
    
    for s_id,d in pairs(sh_d) do
      local s = sh[s_id]

      if s then
        if s.update_id < d[8] then
          local ox = s.x
          local oy = s.y
          s.x      = d[1] + delay*30*d[3]
          s.y      = d[2] + delay*30*d[4]
          
          s.dx = s.dx+ (((ox-s.x+areaw/2)%areaw)-areaw/2)
          s.dy = s.dy+ oy-s.y
          
          if d[7]>s.typ_id then -- upgrade!
            upgrade_ship(s)
          end
          
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
          if upgrade_counts > 0 then
            upgrade_counts = upgrade_counts - 1
            deregister_object(s)
            sh[s_id] = nil
          else
            destroy_ship(s)
          end
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
  
--  my_id = 0
  
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
  
  client.home[6] = love.timer.getTime()
  
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
gang_up_i = 0
gang_up_k = 1
function update_server()
  if not server then
    return
  end
  
  if (#players >= 4) then
    ship_up_k = 1
  else
    ship_up_k = 2
  end
  
  ship_up_i = ship_up_i + ship_up_k
  
  for id, p in pairs(players) do
    local p_d = server.share[id]
    if p_d then
      if id == -1 then
        local readids = {}
        
        for i=1,#gang_list do
          local s = gang_list[i]
          
          local shn = 0
          if p_d[s.id] then
            for _,sh in pairs(p_d[s.id][1]) do
              shn = shn+1
            end
          end
          
          if (i-gang_up_i)%#gang_list < gang_up_k or not p_d[s.id] or #s.ships ~= shn then
            local ships = {}
            for _,sh in pairs(s.ships) do
              ships[sh.id] = {
                flr(sh.x),
                flr(sh.y),
                sh.typ_id
              }
            end
            
            s.update_id = s.update_id + 1
            
            p_d[s.id] = {
              ships,
              s.target,
              s.update_id
            }
          end
          readids[s.id] = true
        end
        
        for s_id,d in pairs(p_d) do
          if not readids[s_id] then
            p_d[s_id] = nil
          end
        end
        
        p_d:__relevance(function(self, client_id) return gang_relevance[client_id] or {} end)
      else
        if id >= 0 then
          p_d[99] = server.homes[id] and server.homes[id][6]
        
          p_d[1] = flr(p.x)
          p_d[2] = flr(p.y)
          p_d[3] = p.shooting
          p_d[4] = p.boosting
          p_d[5] = p.colors[1]
          p_d[6] = p.colors[2]
          p_d[7] = p.name
          p_d[9] = p.msize
          p_d[10] = p.mx
          p_d[11] = p.my
          
          local relev_per_client = get_client_relevance(p)
          p_d:__relevance(function(self, client_id) return relev_per_client[client_id] or {} end) --!!!!!
        end
        
        local sh = p.ships or {}
        local sh_d = (id == -2) and p_d[1] or p_d[8]
        
        readids = {}
        
        for i=1,#sh do
          local s = sh[i]
          
          if (i-ship_up_i)%#sh < ship_up_k or not sh_d[s.id] or sh_d[s.id][7] ~= s.typ_id then
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
      end
    end
  end
end

function get_client_relevance(p)
  local relev_dist = 700

  local relev = {
    {  -- self
      [99] = true,
      [5] = true,
      [6] = true,
      [7] = true,
      [8] = true
    },
    {  -- close-by players
      [1] = true,
      [2] = true,
      [3] = true,
      [4] = true,
      [5] = true,
      [6] = true,
      [7] = true,
      [8] = true
    },
    {  -- far away players
      [5] = true,
      [6] = true,
      [7] = true,
      [9] = true,
      [10] = true,
      [11] = true
    }
  }
  
  local relev_per_client = {}
  for c_id,_ in pairs(server.homes) do
    local c_p = players[c_id]
    if not c_p then
      relev_per_client[c_id] = {}
    elseif c_id == p.id then
      relev_per_client[c_id] = relev[1]
    else
      local dx = ((p.mx-c_p.mx+areaw/2)%areaw)-areaw/2
      local dy = p.my-c_p.my
      local d = sqrdist(dx, dy)
      if d < sqr(relev_dist) then
        relev_per_client[c_id] = relev[2]
      else
        relev_per_client[c_id] = relev[3]
      end
    end
  end
  
  return relev_per_client
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
    error("Abandoning connection.")
    castle_print("Abandoning connection.")
  end
  
  client.id, client.connected = nil, nil
  client, my_id = nil, nil
  
  players = {}
  player = create_player(64+32*cos(0.1),64+32*sin(0.1), nil, false, false, nil)
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
  local colors = new_player_color()

  local p = create_player(x, y, colors, false, false, player_id)
  players[player_id] = p
  
  -- create starter ships
  p.ships={}
  for i=1,7 do
    add(p.ships, create_ship(x, y, rnd(4)-2, rnd(4)-2, 1, player_id))
  end
  add(p.ships, create_ship(x, y, rnd(4)-2, rnd(4)-2, 2, player_id))
  
  
  local p_d = {
    -- 1-4: cursor info -> written in server_update
    [5] = colors[1],
    [6] = colors[2],
--    [7] = name,
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
  server.share[-1] = {}
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
  
  local p = {  -- Enemy ships
    t      = 0,
    colors = {0, 1, 24},
    seed   = 0,
    ships  = {},
    id     = -1,
    update = update_player,
    regs   = {"to_update"}
  }
  register_object(p)
  players[-1] = p
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



--client.home = {
--  [1] = flr(player.x),
--  [2] = flr(player.y),
--  [3] = player.shooting,
--  [4] = player.boosting,
--  [5] = my_name,
--  [6] = client_time
--}
--
--server.share = {
--  [-2] = {  -- neutralized ships
--    [1] = {
--      -- ships  -- only relevant ones??
--    }
--  },
--  [-1] = {  -- (Activated) AI Gangs - update one at a time
--    [12] = { -- Gang - id:12  -- relev to close-by players only
--      { -- ships
--        [1] = flr(x),
--        [2] = flr(y),
--        [3] = typ_id,
----        [4] = vx, -- necessary??
----        [5] = vy,
--      },
--      target_id,
--      update_id
--    },
--  },
--  [1] = {   -- Player - id:1
--    [99] = last_client_time, -- relev to client's self only -- use to calculate delay
--    
--    [1] = cursor_x, -- relev to close-by, not self
--    [2] = cursor_y, -- `
--    [3] = cursor_shooting, -- `
--    [4] = cursor_boosting, -- `
--    
--    [5] = color_1, -- relev to everyone
--    [6] = color_2, -- `
--    [7] = name,    -- `
--    
--    [8] = { --ships, -- relev to close-by and self
--      [1] = x,
--      [2] = y,
--      [3] = vx,
--      [4] = vy,
--      [5] = hp,
--      [6] = t,
--      [7] = typ_id,
--      [8] = update_id
--    }
--    
--    [9]  = msize, -- relev to far away
--    [10] = mx, -- `
--    [11] = my, -- `
--  }
--}


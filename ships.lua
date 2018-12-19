-- BLAST FLOCK source files
-- by TRASEVOL_DOG (https://trasevol.dog/)

require("drawing")
require("maths")
require("table")
require("object")
require("sprite")

require("fx")


ship_types = {"smol", "medium", "biggie", "huge", "helix"}
ship_base_n = {6, 4, 2, 1}
-- ^^ number of ships per type needed for upgrade to next type
function init_ship_stats()
  ship_infos={
    smol={
      anim     = "ship",
      hlen     = 6,
      btyp     = "shell",
      w        = 12,
      value    = 10,
      spawnval = 0,
      lives    = 3
    },
    medium={
      anim     = "mediumship",
      hlen     = 8,
      btyp     = "shell",
      w        = 16,
      value    = 25,
      spawnval = 0,
      lives    = 4
    },
    biggie={
      anim     = "bigship",
      hlen     = 11,
      btyp     = "shell",
      w        = 20,
      value    = 50,
      spawnval = 0,
      lives    = 5
    },
    huge={
      anim     = "hugeship",
      hlen     = 13,
      btyp     = "shell",
      w        = 24,
      value    = 100,
      spawnval = 0,
      lives    = 6
    },
    
    helix={
      anim     = "helixship",
      hlen     = 24,
      btyp     = "shell",
      w        = 28,
      value    = 2000,
      spawnval = 200
    }
  }

  ship_stats={
    --ship={
    --  stat = {base, rnd, friend_bonus}
    --}
    smol={
      acc    = {0.2, 0.2, 0.2}, 
      dec    = {0.95, 0, -0.05}, 
      spdcap = {2, 0.5, 0.5}, 
      acca   = {0.0005, 0.001, 0.001}, 
      deca   = {0.9, 0, 0}, 
      vacap  = {0.002, 0.01, 0.008}, 
      grv    = {0.05, 0.02, 0.02}, 

      cldwn  = {1.5, 0, -1.3},
      attack = {0, 0.2, 0},
      kick   = {1, 0, 0},
      bltspd = {3, 1, 7},
      
      revive = {75, 0, -25},

      maxhp  = {3.5, 0, 0.5}
    },
    
    medium={ -- NOT DEFINED - ONLY COPIED FROM BIGGIE
      acc    = {0.2, 0.2, 0.2}, 
      dec    = {0.95, 0, -0.05}, 
      spdcap = {2, 0.5, 0.5}, 
      acca   = {0.0005, 0.001, 0.001}, 
      deca   = {0.92, 0, 0}, 
      vacap  = {0.002, 0.005, 0.007}, 
      grv    = {0.05, 0.02, 0.02}, 
      
      cldwn  = {0.65, 0, -0.5}, 
      attack = {0, 0.15, 0}, 
      kick   = {1, 0, 0}, 
      bltspd = {3, 1, 7},
      
      revive = {80, 0, -15},

      maxhp  = {6, 0, 2}
    },
    
    biggie={
      acc    = {0.2, 0.2, 0.2}, 
      dec    = {0.95, 0, -0.05}, 
      spdcap = {2, 0.5, 0.5}, 
      acca   = {0.0005, 0.001, 0.001}, 
      deca   = {0.94, 0, 0}, 
      vacap  = {0.002, 0.005, 0.006}, 
      grv    = {0.05, 0.02, 0.02}, 
      
      cldwn  = {0.6, 0, -0.5}, 
      attack = {0, 0.1, 0}, 
      kick   = {1, 0, 0}, 
      bltspd = {3, 1, 7},
      
      revive = {75, 0, 0},

      maxhp  = {8, 0, 2}
    },
    
    huge={ -- NOT DEFINED - ONLY COPIED FROM BIGGIE
      acc    = {0.15, 0.2, 0.2}, 
      dec    = {0.95, 0, -0.05}, 
      spdcap = {2, 0.5, 0.5}, 
      acca   = {0.0005, 0.001, 0.001}, 
      deca   = {0.96, 0, 0}, 
      vacap  = {0.002, 0.004, 0.005}, 
      grv    = {0.05, 0.02, 0.02}, 
      
      cldwn  = {0.55, 0, -0.5}, 
      attack = {0, 0.05, 0}, 
      kick   = {0.5, 0, 0}, 
      bltspd = {3, 1, 7},
      
      revive = {85, 0, 0},

      maxhp  = {11, 0, 2}
    },
    
    
    helix={
      --handled  in  helix  update
    }
  }
end



function update_ship(s)
  s.t=s.t+0.01*dt30f
  
  lsrand(s.id)
  
  load_shipstats(s,ship_types[s.typ_id % 8], not s.gang)
  
  local p = s.gang or players[s.player]
--  if not p then
--    print("WARNING: Playerless ships!!")
--    p = {x = s.x, y = s.y}
--  end
  
  if p and p.boosting then
    s.boost=4
  else
    s.boost=max(s.boost-0.5,0)
  end
  
  local adif=update_ship_movement(s)
  
  update_ship_shooting(s,adif)
  
  local xx,yy
  if not (server and server_only) then
    --s.dx = lerp(s.dx, 0, 0.075*dt30f)
    --s.dy = lerp(s.dy, 0, 0.075*dt30f)
    
    s.dx = s.dx - sgn(s.dx)*min(abs(s.dx), (1+abs(s.dx/16))*dt30f)
    s.dy = s.dy - sgn(s.dy)*min(abs(s.dy), (1+abs(s.dy/16))*dt30f)
    
    xx = s.x + s.dx
    yy = s.y + s.dy
  else
    xx = s.x
    yy = s.y
  end
  
  s.fxt = s.fxt - delta_time
  if s.fxt <= 0 then
    local l = s.info.hlen+4
    local sxx = xx-l*s.co
    local syy = yy-l*s.si
    
    if s.dead then
      if rnd(3)<1 then
        create_smoke(sxx,syy,1,1+rnd(3))
      elseif rnd(2)<1 then
        create_smoke(sxx,syy,1,1+rnd(3),25)
      end
    elseif s.gang then
      if (rnd(10)<1) then
        create_smoke(sxx,syy,2,rnd(3),pick{21, s.color},s.aim+0.5)
      end
      
      if s.hp<s.stats.maxhp/3 and rnd(2)<1 then
        create_smoke(sxx,syy,1,rnd(3),25,rnd(1))
      end
    else
      if (rnd(64)>group_size("ship_player"..s.player)) then
        create_smoke(sxx,syy,2,rnd(3),pick{21, s.color},s.aim+0.5)
      end
      
      if s.hp<s.stats.maxhp/3 and rnd(2)<1 then
        create_smoke(sxx,syy,1,rnd(3),25,rnd(1))
      end
    end
    s.fxt = 0.033
  end
  
  if not s.dead and not s.gang then
--    local col    -- vvv code for scrapping vvv
--    for id,p in pairs(players) do
--      if id ~= s.player then
--        col = col or collide_objgroup(s, "ship_player"..id)
--      end
--    end
--    
--    if col then
--      damage_ship(col,0.1,s)
--      damage_ship(s,0.1,col)
--      
--      sfx("scrap")
--      create_smoke((s.x+col.x)/2,(s.y+col.y)/2,0.5,3,0)
--    end
    
    if p and not p.shooting then
      local typ = s.typ_id % 8
      if typ < 4 and #p.typs[typ] > ship_base_n[typ] + #p.typs[typ+1]*2 then
        local col = collide_objgroup(s,"ship_player"..s.player)
        if col and (col.typ_id % 8) == (s.typ_id % 8) then
          del(p.typs[typ], s)
          del(p.typs[typ], col)
          upgrade_ship(s, col)
        end
      end
    
      local col=collide_objgroup(s,"ship_player-2")
      if col and not (col.dead and col.t>0.5) then
        befriend_ship(col, s.player)
      end
    end
  end
end

function update_falling_ship(s)
  s.t=s.t-0.01*dt30f
  
  if s.t<-2 then
    destroy_ship(s)
    return
  end
  
  s.aim=s.aim+delta_time --s.va
  
  s.dead = true
  
  --s.stats.spdcap = 6
  s.boost = 6
  local adif=update_ship_movement(s)
  
  local xx,yy
  if client then
    s.dx = s.dx - sgn(s.dx)*min(abs(s.dx), (1+abs(s.dx/16))*dt30f)
    s.dy = s.dy - sgn(s.dy)*min(abs(s.dy), (1+abs(s.dy/16))*dt30f)
    
    xx = s.x + s.dx
    yy = s.y + s.dy
  else
    xx = s.x
    yy = s.y
  end
  
  s.fxt = s.fxt - delta_time
  if s.fxt <= 0 then
    if rnd(3)<1 then
      create_smoke(xx, yy, 1,1+rnd(3),23)
    elseif rnd(2)<1 then
      local l = s.info.hlen
      create_smoke(xx, yy, 1,1+rnd(3),25)
    end

    s.fxt = 0.033
  end
end

function update_ship_movement(s)
  local stt=s.stats
  
  local adif=0
  if not s.dead then
    local targ

    if s.gang then
      local p = players[s.gang.target]
      targ = {x = p.mx, y = p.my}
    else
      targ = players[s.player]
    end
    
    if not targ then targ = {x = s.x, y = s.y} end
    
    
    local tax = rel_wrap(targ.x, s.x)
    
    local taim = atan2(tax-s.x,targ.y-s.y)
    adif = angle_diff(s.aim,taim)
    
    s.va  = s.va+sgn(adif)*min(abs(adif),stt.acca)+rnd(0.008)-0.004
    s.va  = sgn(s.va)*min(abs(s.va),stt.vacap)
    s.aim = s.aim + s.va*dt30f
    s.va  = lerp(s.va, 0, (1-stt.deca)*dt30f)
    
    local acc = stt.acc+s.boost*0.05
    
    s.co = cos(s.aim)
    s.si = sin(s.aim)
    
    s.vx = s.vx+acc*s.co*dt30f
    s.vy = s.vy+acc*s.si*dt30f
  end
  
  s.vy = s.vy+stt.grv*dt30f
  
  local spd=dist(s.vx,s.vy)
  local nspd=min(spd,stt.spdcap+s.boost)
  
  s.vx = s.vx/spd*nspd
  s.vy = s.vy/spd*nspd
  
  s.x = s.x+s.vx*dt30f
  s.y = s.y+s.vy*dt30f
  
  s.vx = lerp(s.vx, 0, (1-stt.dec)*dt30f)
  s.vy = lerp(s.vy, 0, (1-stt.dec)*dt30f)
  
  return adif
end

function update_ship_shooting(s,adif)
  local stt=s.stats
  local inf=s.info
  
  s.curcld=max(s.curcld-0.01*dt30f,0)
  
  if s.dead then return end
  
  local p = players[s.player]
  
  local shootdir
  if s.gang then
    local targ = players[s.gang.target]
    if abs(adif)<0.2 and dist(s.x,s.y,targ.mx,targ.my)<400 then
      if not s.shootin then
        s.shootin=true
        s.curcld=max(stt.attack,s.curcld)
      end
      adif = 0
    else
      s.shootin=false
    end
  elseif p then
    if p.shooting and not s.shootin then
      s.shootin=true
      s.curcld=max(stt.attack,s.curcld)
    end
    
    s.shootin = p.shooting
  end
  
  if s.shootin and s.curcld<=0 then
    local shootdir = s.aim + 0.25*adif
  
    local d=inf.hlen+8
    local x,y
    if client then
      x,y=s.x+s.dx+d*cos(shootdir),s.y+s.dy+d*sin(shootdir)
    else
      x,y=s.x+d*cos(shootdir),s.y+d*sin(shootdir)
    end
    
    create_bullet(x, y, shootdir+rnd(0.01)-0.005, stt.bltspd, s.color, s.player, s.gang ~= nil)
    s.shots=s.shots+1
    
--    if s.shots%3==0 and s.typ=="biggie" and not p then
--      s.curcld=2*stt.cldwn
--    else
--      s.curcld=stt.cldwn
--    end
    s.curcld=stt.cldwn
    
    shootshake=shootshake+1
    s.justfired=2
    
    s.x=s.x-stt.kick*cos(shootdir)
    s.y=s.y-stt.kick*sin(shootdir)
    
    s.vx=s.vx-stt.kick*cos(shootdir)
    s.vy=s.vy-stt.kick*sin(shootdir)
    
    if s.player_id == my_id then
      sfx("shoot",s.x,s.y)
    else
      sfx("enemyshoot",s.x,s.y)
    end
  end
end

function update_helixship(s)
  s.t=s.t+0.01*dt30f
  
  --sfx("helix",s.x,s.y)
  --^sounds terrible
  
  s.fxt = s.fxt - delta_time
  
  if s.dead then
    s.vy=s.vy+0.02*dt30f
    local k=sgn(s.vx)*0.0002
    s.tilt=s.tilt+k*dt30f
    for i=1,3 do
      s.aim[i]=s.aim[i]+k*dt30f
    end
    
    s.x=s.x+s.vx*dt30f
    s.y=s.y+s.vy*dt30f
    
    if t%0.02<0.01*dt30f then
      create_explosion(s.x+rnd(64)-32,s.y+rnd(64)-32,16,21)
      add_shake(4)
    end
    
    s.t=s.t-0.02*dt30f
    
    if s.fxt <= 0 then
      if s.t<=0.5 then
        create_explosion(s.x+rnd(48)-24,s.y+rnd(48)-24,56,22)
        boomsfx()
        for i=1,32 do
          create_smoke(s.x+rnd(64)-32,s.y+rnd(64)-32,2+rnd(6),nil,23)
          create_smoke(s.x+rnd(64)-32,s.y+rnd(64)-32,2+rnd(6),nil,24)
        end
        deregister_object(s)
        add_shake(64)
        love.timer.sleep(0.1)
      end
    
      if rnd(2)<1 then
        create_smoke(s.x,s.y,6,6)
      else
        create_smoke(s.x,s.y,6,6,0)
      end
    end
    return
  end
  
  if s.fxt <= 0 then
    if s.hp<200 and rnd(2)<1 then
      create_smoke(s.x+rnd(96)-48,s.y,1,4+rnd(3),0)
    end
    s.fxt = 0.33
  end
  
  local dir=atan2(massx-s.x,massy-s.y)
  
  if gameover then
    s.vx=s.vx*0.02*dt30f
    s.vy=s.vy*0.02*dt30f
  else
    s.vx=s.vx+s.acc*cos(dir)*dt30f
    s.vy=s.vy+s.acc*sin(dir)*dt30f
  end
  
  local a=atan2(s.vx,s.vy)
  local l=dist(s.vx,s.vy)
  
  l=min(l,s.spdcap)
  
  s.vx=l*cos(a)
  s.vy=l*sin(a)
  
  s.x=s.x+s.vx*dt30f
  s.y=s.y+s.vy*dt30f
  
  s.tilt=(s.vx/s.spdcap)*0.03
  
  s.curcld=max(s.curcld-0.01*dt30f,0)
  
  if s.shootin==0 then
    local aimed=true
    for i=1,3 do
      local adif=angle_diff(s.aim[i],dir)
      s.aim[i]=s.aim[i]+sgn(adif)*0.008*dt30f
      
      aimed=aimed and (abs(adif)<0.05)
    end
    
    if aimed and s.curcld<=0 and dist(s.x,s.y,massx,massy)<600 then
      s.shootin=1
    end
  else
    s.shootin=max(s.shootin-0.01*dt30f,0)
    
    if s.shootin%0.02<0.01*dt30f and not gameover then
      local k=flr(s.shootin*50)%3-1
      local a=s.aim[k+2]
      local x=s.x+k*32*cos(s.tilt)+24*cos(a)
      local y=s.y+k*32*sin(s.tilt)+24*sin(a)
      
      create_bullet(x,y,a+rnd(0.02)-0.01,6,false)
      sfx("enemyshoot",x,y)
      
      add_shake(1)
    end
    
    if s.shootin==0 then
      s.curcld=s.cldwn
    end
  end
end

function update_bullet(s,dt)
  s.x=s.x+s.vx*dt30f
  s.y=s.y+s.vy*dt30f
  
  local col = nil
  for id,p in pairs(players) do
    if id ~= s.player then
      col = col or collide_objgroup(s, "ship_player"..id)
    end
  end
  if col and not (col.dead and col.t>0.5) then
    damage_ship(col, s.is_ai and 0.5 or 2, s)
    
    create_explosion(s.x,s.y,4,s.color)
    
    deregister_object(s)
    return
  end
  
  s.t=s.t-delta_time
  if s.t<0 then
    deregister_object(s)
  end
end


function damage_ship(s,dmg,o)
  s.hp=s.hp-dmg
  
  s.gothit=2
  
  if s.hp<=0 then
    if s.dead then
      destroy_ship(s)
    else
      s.lives=s.lives-1
      if s.typ=="helix" then
        add_shake(5)
        create_explosion(s.x,s.y,24,s.c)
        boomsfx(s.x,s.y)
        s.dead=true
        s.hp=1000
        group_del("enemy_ship",s)
        s.friend=false
        s.t=3
      elseif s.lives>0 and s.retrievable then
        neutralize_ship(s,o)
        boomsfx(s.x,s.y)
      else
        destroy_ship(s)
      end
    end
  end
end

function neutralize_ship(s,o)
  add_shake(3)
  create_explosion(s.x,s.y,16,s.c)
  
  s.dead=true
  
  pass_to_player(s, -2)
  
  local a
  if o then
    a=atan2(s.x-o.x,s.y-o.y)
  else
    a=rnd(1)
  end
  
  local spd=4+rnd(1)
  s.vx=spd*cos(a)
  s.vy=spd*sin(a)
  
  s.t=1
end

function befriend_ship(s, player)
--  s.stats.spdcap=s.stats.spdcap/3

  sfx("save")
  
  pass_to_player(s, player)
  
--  local acur=rnd(1)--atan2(player.x-s.x,player.y-s.y)
--  s.aim=s.aim+0.2*angle_diff(s.aim,acur)
end

function pass_to_player(s, player)
  group_del("ship_player"..s.player, s)
  group_add("ship_player"..player,s)
  
  local op = s.gang or players[s.player]
  if server and server_only then
    del(op.ships, s)
    add(players[player].ships, s)
  else
    if players[player].ships[s.id] then
      destroy_ship(s)
      return
    end
    op.ships[s.id] = nil
    players[player].ships[s.id] = s
  end
  
  s.player = player
  
  if s.gang then s.gang = nil end
  
  if s.player == -2 then
    s.dead = true
    --s.stats.spdcap=s.stats.spdcap*3
    s.hp=3
    s.w=s.w+8
    s.h=s.h+8
    s.shootin=false
    s.va=sgn(irnd(2)-1.5)*(0.005+rnd(0.02))
  else
    s.dead = false
    load_shipinfo(s,ship_types[s.typ_id], true)
    s.hp=s.stats.maxhp
    --create_convertring(s)
    s.t = 0
  end
  
  s.typ_id = s.typ_id % 8
  
  s.color = pick(players[player].colors)
  s.plt   = ship_plts[s.color]
end

function upgrade_ship(s, s2)
-- if (s.typ_id % 8) >= 4 then
--   return
-- end

  s.typ_id = (s.typ_id % 8) + 9
  s.typ = ship_types[s.typ_id % 8]
  
  if s2 then
    deregister_object(s2)
    if server and server_only then
      del(players[s2.player].ships, s2)
    else
      players[s2.player].ships[s2.id] = nil
    end
  end
  
  load_shipinfo(s,ship_types[s.typ_id % 8], true)
  
  s.t = 0
  
  s.hp=s.stats.maxhp
  
  sfx("save")
end


function update_gangs()
  if server and server_only then
    for id,p in pairs(players) do
      gang_relevance[id] = {}
    end
  end

  function search_new_target(gang)
    local d = sqr(gang_safe_dist)
    local target
    for p_id, p in pairs(players) do
      if p_id >= 0 then
        local dx = ((gang.x-p.mx+areaw/2)%areaw)-areaw/2
        local dy = gang.y-p.my
        local nd = sqrdist(dx, dy)
        if nd < d then
          target = p_id
          d = nd
        end
      end
    end
    
    if target then
      if gang.target then
        gang.target = target
      else
        activate_gang(gang, target)
      end
      return true
    end
    
    return false
  end
  
  local active_search_new_target = server and server_only and function(gang)
    local mind = sqr(gang_safe_dist)
    local d = mind
    local target
    for p_id, p in pairs(players) do
      if p_id >= 0 then
        local dx = ((gang.x-p.mx+areaw/2)%areaw)-areaw/2
        local dy = gang.y-p.my
        local nd = sqrdist(dx, dy)
        if nd < mind then
          gang_relevance[p_id][gang.id] = true
          
          if nd < d then
            target = p_id
            d = nd
          end
        end
      end
    end
    
    if target then
      if gang.target then
        gang.target = target
      else
        activate_gang(gang, target)
      end
      return true
    end
    
    return false
  end or search_new_target

  for id, gang in pairs(gang_grid) do
    if gang.target then
      local nships = 0
      for _,_ in pairs(gang.ships) do
        nships = nships + 1
      end
      
      if nships <= 0 then
        delete_gang(gang)
      else
        calculate_gang_pos(gang)
        
        if active_search_new_target(gang) then
          local p = players[gang.target]
          if p then
              
            for _,sh in pairs(gang.ships) do
              update_ship(sh)
            end
            
          end
        else
          delete_gang(gang)
        end
      end
    else
      if server and server_only then
        search_new_target(gang)
      else
        delete_gang(gang)
      end
    end
  end
end

function update_gang_sys()
  if not (server and server_only) then
    return
  end
  
  gang_grid_t = gang_grid_t - delta_time
  if gang_grid_t < 0 then
    local x,y = rnd(areaw), rnd(areah)
    local id = get_gang_id(x,y)
    
    if id and not gang_grid[id] then
      local d = sqr(gang_safe_dist)
      for p_id, p in pairs(players) do
        if p_id >= 0 then
          local dy = y-p.my
          local dx = ((x-p.mx+areaw/2)%areaw)-areaw/2
          d = min(d, sqrdist(dx, dy))
        end
      end
      
      if d>=sqr(gang_safe_dist) then
        create_gang(x, y, id)
      end
    end
  
    gang_grid_t = 1.5
  end
end

function calculate_gang_pos(gang)
  local x,y,k=0,0,0
  for _,sh in pairs(gang.ships) do
    x = x + sh.x
    y = y + sh.y
    k = k + 1
  end
  gang.x = x/k
  gang.y = y/k
end

function sync_gang(gang, ships, target, delay)
  for s_id, sh in pairs(gang.ships) do
    if not ships[s_id] then
      destroy_ship(sh)
    end
  end
  
  for s_id, d in pairs(ships) do
    local s = gang.ships[s_id]
    if s then
      local ox,oy = s.x,s.y
      s.x = d[1]+ delay*30*s.vx
      s.y = d[2]+ delay*30*s.vy
      s.dx = (((ox-s.x+areaw/2)%areaw)-areaw/2)
      s.dy = oy-s.y
      
--      local dx = ((s.x-d[1]+areaw/2)%areaw)-areaw/2
--      local dy = s.y-d[2]
--      s.dx = s.dx+ dx
--      s.dy = s.dy+ dy
--      s.x = s.x - dx + delay*30*s.vx
--      s.y = s.y - dy + delay*30*s.vy
    end
  end
  
  calculate_gang_pos(gang)
  gang.target = target
end

function clear_gangs(x,y)
  local id = get_gang_id(x,y)
  local gang = gang_grid[id]
  
  if gang and not gang.target then
    delete_gang(gang)
  end
end



function draw_ship(s)
  local inf=s.info
  
  local xx,yy
  if client and debug_mode~=1 then
    xx, yy = s.x+s.dx, s.y+s.dy
  else
    xx, yy = s.x, s.y
  end
  
  if xx+s.w*2<xmod or xx-s.w*2>xmod+screen_width or yy+s.h*2<ymod or yy-s.h*2>ymod+screen_height then
    return
  end
  
  local ofx,ofy=0,0
  if s.boost==4 then ofx,ofy=ofx+rnd(2)-1,ofy+rnd(2)-1 end
  
  if debug_mode==2 then
    all_colors_to(21)
    draw_anim(s.x+ofx,s.y+ofy,inf.anim,"rotate",s.aim,s.aim,false,(s.aim+0.25)%1>0.5)
  end
  
  if s.player == my_id then
    draw_anim_outline(xx+ofx,yy+ofy,inf.anim,"rotate",s.aim,ship_outline_col,s.aim,false,(s.aim+0.25)%1>0.5)
  else
    draw_anim_outline(xx+ofx,yy+ofy,inf.anim,"rotate",s.aim,25,s.aim,false,(s.aim+0.25)%1>0.5)
  end
  
  if s.gothit>0 or (s.dead and s.t>0.5) then
    all_colors_to(21)
    s.gothit=max(s.gothit-1,0)
  else
    apply_pal_map(s.plt)
  end
  
  draw_anim(xx+ofx,yy+ofy,inf.anim,"rotate",s.aim,s.aim,false,(s.aim+0.25)%1>0.5)
  
  all_colors_to()
  
  if not s.dead then
    local l = inf.hlen
    local x, y = xx-l*s.co, yy-l*s.si
    local state=(s.boost==4) and "bfire" or "fire"
    draw_anim(x,y,inf.anim,state,s.t,s.aim)
    
    if s.t<0.3 then
      draw_convertring(s, xx, yy, s.t)
    end
  end
  
  if s.justfired>0 then
    local l = inf.hlen+1
    local x,y=xx+l*s.co,yy+l*s.si
    spr(20,0,x,y,1,1,s.aim,false,false,1,3)
    s.justfired=s.justfired-1
  end
  
  if s.dead and s.t<0.5 then
    for i=0,0.75,0.25 do
      local a=i+s.t*1.5+s.k
      local d=inf.hlen+7+3*cos(s.t*8+s.k)
      local x1,y1=xx+d*cos(a),yy+d*sin(a)
      d=d+6
      local x2,y2=xx+d*cos(a),yy+d*sin(a)
      
      local foo=function()
        line(x1,y1,x2,y2,21)
      end
      
      draw_outline(foo,25)
      foo()
    end
  end
end

function draw_helixship(s)
  local inf=s.info
  
  if s.x+s.w*2<xmod or s.x-s.w*2>xmod+screen_width or s.y+s.h*2<ymod or s.y-s.h*2>ymod+screen_height then
    return
  end
  
  local foo=function()
    --draw_anim(s.x,s.y,inf.anim,"only",s.t,s.tilt,false,false)
    if s.t%0.04<0.02 then
      spr(128,0,s.x,s.y,16,2,s.tilt,false,false,64,16+13)
    else
      spr(128,0,s.x,s.y,16,1,s.tilt,false,false,64,8+13)
      spr(144,0,s.x,s.y,16,1,s.tilt,false,false,64,16+13)
    end
    spr(160,0,s.x,s.y,16,3,s.tilt,false,false,64,13)
  end
  
  draw_outline(foo,25)
  
  if s.gothit>0 or (s.dead and s.t>1.5) then
    all_colors_to(21)
    s.gothit=max(s.gothit-1,0)
  elseif s.dead and s.t%0.2<0.12 then
    apply_pal_map(neutralpal)
  else
    apply_pal_map(s.plt)
  end
  
  foo()
  
  local foo=function()
    for i=1,3 do
      local x,y=s.x+(i-2)*32*cos(s.tilt),s.y+(i-2)*32*sin(s.tilt)
      spr(12,0,x,y,3,2,s.aim[i],false,false,8,8)
    end
  end
  
  draw_outline(foo,25)
  
  if s.gothit>0 or (s.dead and s.t>1.5) then
    all_colors_to(21)
    s.gothit=max(s.gothit-1,0)
  elseif s.dead and s.t%0.2<0.12 then
    apply_pal_map(neutralpal)
  else
    apply_pal_map(s.plt)
  end
  
  foo()
  
  all_colors_to()
end

function draw_bullet(s)
  if s.x+8<xmod or s.x-8>xmod+screen_width or s.y+8<ymod or s.y-8>ymod+screen_height then
    return
  end
  
  apply_pal_map(s.plt)
  

  if s.t < 0.2 then
    local sps = {46,44,42,8}
    spr(sps[flr(s.t*20)+1],0,s.x,s.y,2,2,s.a)
  else
    spr(s.s,0,s.x,s.y,2,2,s.a)
  end
  
  
  all_colors_to()
end

function draw_convertring(s, x, y, t)
  local t = t/0.3
  local k = min(4-abs(flr(t*10)-5), 2)
  local ca, cb = lighter(s.color, k), lighter(s.color, k-1)
  
  local foo=function()
    circ(x,y+1,s.info.hlen+3+2*cos(t*4),cb)
    circ(x,y,s.info.hlen+3+2*cos(t*4),ca)
  end
  
  draw_outline(foo,25)
  foo()
  
  font("small")
  
  local str = (s.typ_id > 8) and "* UPGRADE! *" or "^ SAVED ^"
  
  draw_text(str,x,y-s.info.hlen-6-k,1, 25,ca, cb)
end


plane_id = 0
function create_ship(x,y,vx,vy,typ_id,player_id,id)
  local typ_id = typ_id or 1--(flr(rnd(4))+1)
  local typ
  typ=ship_types[typ_id % 8]
  
  if typ=="helix" then
    create_helixship(x,y)
    return
  end
  
  if not id then
    id = plane_id
    plane_id = plane_id + 1
  end
  
  local p = players[player_id]
  
  local s={
    x         = x,
    y         = y,
    vx        = vx,
    vy        = vy,
    typ_id    = typ_id,
    player    = player_id,
    
    color     = pick(p.colors),
    aim       = atan2(vx, vy),
    
    id        = id,
    update_id = 0,
    
    va        = 0,
    
    curcld    = 0,
    gothit    = 0,
    justfired = 0,
    t         = 1+rnd(1),
    fxt       = 0,
    boost     = 0,
    shots     = 0,
    dead      = false,
    lives     = 3,
    k         = rnd(1),
    update    = update_ship,
    draw      = draw_ship,
    --regs      = {"to_draw2","to_wrap","ship",friend and "friend_ship" or "enemy_ship"}
    regs      = {"to_draw2","to_wrap","ship", "ship_player"..player_id}
  }
  
  load_shipinfo(s,ship_types[s.typ_id % 8], true)
  load_shipstats(s,ship_types[s.typ_id % 8], true)
  s.hp=s.stats.maxhp
  
  s.co, s.si = cos(s.aim), sin(s.aim)
  
  if client then
    s.dx, s.dy = 0, 0
  end
  
  s.plt = ship_plts[s.color]
  
  register_object(s)
  return s
end

function load_shipinfo(s,typ, upgraded)
  local info=ship_infos[typ]-- or ship_infos.smol
  s.info={}
  for inf,val in pairs(info) do
    s.info[inf]=val
  end
  
  --s.hp=s.stats.maxhp
  s.typ=typ
  s.w, s.h = s.info.w, s.info.w
  s.lives = s.info.lives
end

function load_shipstats(s,typ, upgraded)
  local stats=ship_stats[typ]-- or ship_stats.smol
  s.stats={}
  for stat,val in pairs(stats) do
    s.stats[stat]=val[1]+lrnd(val[2])+(upgraded and val[3] or 0)
  end
  
  s.retrievable = lrnd(100) < s.stats.revive
end


function create_gang(x, y, id, target, ships)
  local s = {
    x = x,
    y = y,
    id = id,
    update_id = 0
  }
  
  if target then
    activate_gang(s, target, ships)
  end
  
  if gang_grid[id] then
    delete_gang(gang_grid[id])
  end
  
  gang_grid[id] = s
  
  return s
end

function activate_gang(s, target, ships)
  if ships then
    local x,y,k = 0,0,0
    for _,sh in pairs(ships) do
      x = x+sh[1]
      y = y+sh[2]
      k = k+1
    end
    s.x = x/k
    s.y = y/k
  end
  
  s.target = target
  local p = players[target]
  
  local dx = ((p.mx-s.x+areaw/2)%areaw)-areaw/2
  local dy = p.my-s.y
  s.a = atan2(dx, dy)
  
  s.ships={}
  
  local coa = cos(s.a)
  local sia = sin(s.a)
  local cob = cos(s.a + 0.25)
  local sib = sin(s.a + 0.25)
  
  if ships then
    for s_id,sh_d in pairs(ships) do
      local sh = create_ship(sh_d[1], sh_d[2], 2*coa, 2*sia, sh_d[3], -1, s_id)
      sh.a = s.a
      sh.gang = s
      
      if server and server_only then
        add(s.ships, sh)
      elseif client then
        s.ships[sh.id] = sh
      end
    end
  else
    local k = irnd(4)
    for i=1,k do
      local x = s.x + cob * 8 * (i-k/2-0.5)
      local y = s.y + sib * 8 * (i-k/2-0.5)
      
      local sh = create_ship(x, y, coa, sia, typ or pick{1,1,1,1,2}, -1, id)
      sh.a = s.a
      sh.gang = s
      
      if server and server_only then
        add(s.ships, sh)
      elseif client then
        s.ships[sh.id] = sh
      end
    end
  end
  
  if server and server_only then
    add(gang_list, s)
  end
end

function init_gang_sys()
  gang_grid = {}
  gang_grid_k = 400
  
  if server and server_only then
    gang_list = {} -- active gangs only!
    gang_relevance = {}
  end
  
  gang_safe_dist = 700
  gang_lose_dist = 850
  
  gang_grid_wn = flr(areaw/gang_grid_k)
  gang_grid_hn = flr(areah/gang_grid_k)
  
  gang_grid_t = 0
  
--  for x=0, gang_grid_wn-1 do
--    for y=0, gang_grid_hn-1 do
--      local id = y*gang_grid_wn + x
--      
--    end
--  end
  
end

function get_gang_id(x,y)
  local x = flr((x%areaw)/gang_grid_k)
  local y = flr(y/gang_grid_k)
  
  if y<0 or y>=gang_grid_hn then
    return nil
  else
    return y*gang_grid_wn + x
  end
end


function create_helixship(x,y)
  local s={
    x       = x,
    y       = y,
    w       = 112,
    h       = 32,
    aim     = {rnd(1),rnd(1),rnd(1)},
    vx      = 0,
    vy      = 0,
    acc     = 0.01,
    dec     = 0.99,
    spdcap  = 0.25,
    tilt    = 0,
    curcld  = 0,
    cldwn   = 0.5,
    attack  = 1,
    shootin = 0,
    gothit  = 0,
    friend  = false,
    lives   = 9,
    t       = 0,
    fxt     = 0,
    update  = update_helixship,
    draw    = draw_helixship,
    regs    = {"to_update","to_draw2","to_wrap","ship","enemy_ship","helix"}
  }
  
  load_shipinfo(s,"helix")
  s.hp=600
  
  s.plt=enemypal
  
  register_object(s)
end

function create_bullet(x,y,dir,spd,c,player_id, is_ai)
  local c = is_ai and pick{0,1} or c

  local b={
    x      = x,
    y      = y,
    w      = 8,
    h      = 8,
    player = player_id,
    vx     = spd*cos(dir),
    vy     = spd*sin(dir),
    a      = dir,
    spd    = spd,
    t      = is_ai and 2 or 1.25,
    s      = is_ai and 8 or 6,
    is_ai  = is_ai,
    color  = c,
    plt    = ship_plts[c],
    update = update_bullet,
    draw   = draw_bullet,
    regs   = {"to_update","to_draw3","to_wrap", "bullet_player"..player_id}
  }
  
  register_object(b)
  
  return b 
end



function destroy_ship(s)
  add_shake(3)
  boomsfx(s.x,s.y)
  create_explosion(s.x,s.y,s.info.hlen*2,s.c)
  create_skull(s.x,s.y)

  deregister_object(s)
  
  local p = s.gang or players[s.player]
  if p then
    if server and server_only then
      del(p.ships, s)
    else
      p.ships[s.id] = nil
    end
  end
end

function delete_gang(s)
  gang_grid[s.id] = nil
  
  if s.ships then
    for i,sh in pairs(s.ships) do
      deregister_object(sh)
      s.ships[i] = nil
    end
  end
  
  if s.target and server and server_only then
    del(gang_list, s)
  end
end


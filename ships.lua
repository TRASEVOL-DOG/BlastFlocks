-- BLAST FLOCK source files
-- by TRASEVOL_DOG (https://trasevol.dog/)

require("drawing")
require("maths")
require("table")
require("object")
require("sprite")

require("fx")


ship_types = {"smol", "biggie", "helix"}

function init_ship_stats()
  ship_infos={
    smol={
      anim     = "ship",
      hlen     = 6,
      btyp     = "shell",
      w        = 4,
      value    = 10,
      spawnval = 2
    },
    biggie={
      anim     = "bigship",
      hlen     = 11,
      btyp     = "shell",
      w        = 12,
      value    = 100,
      spawnval = 20
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

      maxhp  = {3.5, 0, 0.5}
    }, 
    biggie={
      acc    = {0.2, 0.2, 0.2}, 
      dec    = {0.95, 0, -0.05}, 
      spdcap = {2, 0.5, 0.5}, 
      acca   = {0.0005, 0.001, 0.001}, 
      deca   = {0.95, 0, 0}, 
      vacap  = {0.003, 0.002, 0.004}, 
      grv    = {0.05, 0.02, 0.02}, 
      
      cldwn  = {0.1, 0, -0.025}, 
      attack = {0, 0.05, 0}, 
      kick   = {1, 0, 0}, 
      bltspd = {3, 1, 7}, 

      maxhp  = {6, 0, 2}
    },
    helix={
      --handled  in  helix  update
    }
  }
end



function update_ship(s)
  s.t=s.t+0.01*dt30f
  
  load_shipinfo(s,ship_types[s.typ_id], true)
  
  local p = players[s.player]
  if not p then
    print("WARNING: Playerless ships!!")
  end
  
  if p and p.boosting then
    s.boost=4
  else
    s.boost=max(s.boost-0.5,0)
  end
  
  local adif=update_ship_movement(s)
  
  if not gameover then
    update_ship_shooting(s,adif)
  end
  
  s.fxt = s.fxt - delta_time
  if s.fxt <= 0 then
    if s.dead then
      if rnd(3)<1 then
        create_smoke(s.x,s.y,1,1+rnd(3))
      elseif rnd(2)<1 then
        create_smoke(s.x,s.y,1,1+rnd(3),25)
      end
    else
      if (rnd(64)>group_size("ship_player"..s.player)) then
        create_smoke(s.x,s.y,2,rnd(3),pick{21, s.color},s.aim+0.5)
      end
      
      if s.hp<s.stats.maxhp/3 and rnd(2)<1 then
        create_smoke(s.x,s.y,1,rnd(3),25,rnd(1))
      end
    end
    s.fxt = 0.033
  end
  
  if not s.dead then
--    local col
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
  
--  load_shipinfo(s,ship_types[s.typ_id], true)

  s.aim=s.aim+delta_time --s.va
  
  s.dead = true
  
  --s.stats.spdcap = 6
  s.boost = 6
  local adif=update_ship_movement(s)
  
  
  s.fxt = s.fxt - delta_time
  if s.fxt <= 0 then
    if rnd(3)<1 then
      create_smoke(s.x,s.y,1,1+rnd(3),23)
    elseif rnd(2)<1 then
      create_smoke(s.x,s.y,1,1+rnd(3),25)
    end

    s.fxt = 0.033
  end
end

function update_ship_movement(s)
  local stt=s.stats
  
  local adif=0
  if not s.dead then
    local targ = players[s.player]
    local tax = rel_wrap(targ.x, s.x)
    
    local taim = atan2(tax-s.x,targ.y-s.y)
    adif = angle_diff(s.aim,taim)
    
    s.va  = s.va+sgn(adif)*min(abs(adif),stt.acca)+rnd(0.008)-0.004
    s.va  = sgn(s.va)*min(abs(s.va),stt.vacap)
    s.aim = s.aim + s.va*dt30f
    s.va  = lerp(s.va, 0, (1-stt.deca)*dt30f)
    
    local acc = stt.acc+s.boost*0.05
    
    s.vx = s.vx+acc*cos(s.aim)*dt30f
    s.vy = s.vy+acc*sin(s.aim)*dt30f
  end
  
  s.vy = s.vy+stt.grv*dt30f
  
  local spd=dist(s.vx,s.vy)
  local dir=atan2(s.vx,s.vy)
  
  spd=min(spd,stt.spdcap+s.boost)
  
  s.vx = spd*cos(dir)
  s.vy = spd*sin(dir)
  
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
  if p then
    if p.shooting and not s.shootin then
      s.shootin=true
      s.curcld=max(stt.attack,s.curcld)
    end
    
    if p.shooting then
      local dir=s.aim
      local cur=atan2(p.x-s.x,p.y-s.y)
      shootdir=dir+0.5*angle_diff(dir,cur)
    else
      s.shootin=false
    end
  else
    if abs(adif)<0.2 and dist(s.x,s.y,massx,massy)<400 then
      if not s.shootin then
        s.shootin=true
        s.curcld=max(stt.attack,s.curcld)
      end
      shootdir=s.aim
    else
      s.shootin=false
    end
  end
  
  if s.shootin and s.curcld<=0 then
    local d=inf.hlen+8
    local x,y=s.x+d*cos(shootdir),s.y+d*sin(shootdir)
    create_bullet(x, y, shootdir+rnd(0.01)-0.005, stt.bltspd, s.color, s.player)
    s.shots=s.shots+1
    
    if s.shots%3==0 and s.typ=="biggie" and not p then
      s.curcld=2*stt.cldwn
    else
      s.curcld=stt.cldwn
    end
    
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
    damage_ship(col,2,s)
    
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
  del(players[s.player].ships, s)
  
  group_add("ship_player"..player,s)
  add(players[player].ships, s)
  s.player = player
  
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
    create_convertring(s)
  end
  
  -- temporary, should just take player color
  s.color = pick(players[player].colors)
  s.plt   = ship_plts[s.color]
end



function draw_ship(s)
  local inf=s.info
  
  if s.x+s.w*2<xmod or s.x-s.w*2>xmod+screen_width or s.y+s.h*2<ymod or s.y-s.h*2>ymod+screen_height then
    return
  end
  
  local ofx,ofy=0,0
  if s.boost==4 then ofx,ofy=ofx+rnd(2)-1,ofy+rnd(2)-1 end
  
  local foo=function()
    draw_anim(s.x+ofx,s.y+ofy,inf.anim,"rotate",s.aim,s.aim,false,(s.aim+0.25)%1>0.5)
  end
  
  draw_outline(foo,25)
  
  if s.gothit>0 or (s.dead and s.t>0.5) then
    all_colors_to(21)
    s.gothit=max(s.gothit-1,0)
  else
    apply_pal_map(s.plt)
  end
  
  foo()
  
  all_colors_to()
  
  if not s.dead then
    local x,y=s.x-inf.hlen*cos(s.aim),s.y-inf.hlen*sin(s.aim)
    local state=(s.boost==4) and "bfire" or "fire"
    draw_anim(x,y,inf.anim,state,s.t,s.aim)
  end
  
  if s.justfired>0 then
    local x,y=s.x+(inf.hlen+1)*cos(s.aim),s.y+(inf.hlen+1)*sin(s.aim)
    spr(20,0,x,y,1,1,s.aim,false,false,1,3)
    s.justfired=s.justfired-1
  end
  
  if s.dead and s.t<0.5 then
    for i=0,0.75,0.25 do
      local a=i+s.t*1.5+s.k
      local d=inf.hlen+7+3*cos(s.t*8+s.k)
      local x1,y1=s.x+d*cos(a),s.y+d*sin(a)
      d=d+6
      local x2,y2=s.x+d*cos(a),s.y+d*sin(a)
      
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
  
--  if s.player == my_id then
    spr(6,0,s.x,s.y,2,2,s.a)
--  else
--    spr(8,0,s.x,s.y,2,2,s.a)
--  end
  
  all_colors_to()
end



function create_ship(x,y,vx,vy,typ_id,player_id)
  local typ
  if typ_id then
    typ=ship_types[typ_id]
  else
    typ = "smol"
    typ_id = 1
  end
  
  if typ=="helix" then
    create_helixship(x,y)
    return
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
    aim       = rnd(1), -- atan2(x-p.x, y-p.y),
    
    va        = 0,
    
    curcld    = 0,
    gothit    = 0,
    justfired = 0,
    t         = rnd(1),
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
  
  load_shipinfo(s, typ, true)
  s.hp=s.stats.maxhp
  
  s.w, s.h = s.info.w, s.info.w
  
--  if friend then upgrade_ship(s) end
  
--  if player_id == my_id then
--    s.c   = pick({9,10})
--    s.plt = friendpal
--  else
--    s.c   = pick({8,14})
--    s.plt = enemypal
--  end
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
  
  local stats=ship_stats[typ]-- or ship_stats.smol
  s.stats={}
  for stat,val in pairs(stats) do
    s.stats[stat]=val[1]+lrnd(val[2])+(upgraded and val[3] or 0)
  end
  
  --s.hp=s.stats.maxhp
  s.typ=typ
  
  s.retrievable = (lrnd(2) < 1)
end

function upgrade_ship(s)
  local stats=ship_stats[s.typ]
  for stat,val in pairs(stats) do
    s.stats[stat]=s.stats[stat]+val[3]
  end
  
  s.hp=s.stats.maxhp
end

function downgrade_ship(s)
  local stats=ship_stats[s.typ]
  for stat,val in pairs(stats) do
    s.stats[stat]=s.stats[stat]-val[3]
  end
  
  s.hp=s.stats.maxhp
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

function create_bullet(x,y,dir,spd,c,player_id)
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
    t      = 0.75,
    s      = 5,
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
  if (players[s.player]) then
    del(players[s.player].ships, s)
  end
end


-- BLAST FLOCK source files
-- by TRASEVOL_DOG (https://trasevol.dog/)

require("drawing")
require("maths")
require("table")
require("object")
require("sprite")
require("audio")
require("nnetwork")

require("menu")

require("ships")
require("fx")

player = nil
my_id = nil
players = {}

function _init()
--  fullscreen()
  eventpump()
  
  init_menu_system()
  
  init_object_mgr(
    "to_wrap",
    "ship",
    "friend_bullet",
    "enemy_bullet",
    "friend_ship",
    "enemy_ship",
    "neutral_ship",
    "screen_glitch",
    "helix",
    "hole"
  )
  
  init_ship_stats()
  
  friendpal={  [6]=10, [13]=9,  [5]=4}
  enemypal={   [6]=14, [13]=8,  [5]=2}
  neutralpal={ [6]=6,  [13]=13, [5]=5}
  
  drk={[0]=0,0,1,1,2,1,5,6,2,4,9,3,1,1,2,5}
  
  areaw=2400
  areah=1600
  
  shkx,shky=0,0
  cam=create_camera(0,areah/2)
  
--  splash_screen()
  
  player=create_player(64+32*cos(0.1),64+32*sin(0.1), nil, nil, false, false, true)
  
  massx,massy=0,0
  massvx,massvy=0,0
  
  t=0
  
  level=0
  levelt=0
  
  main_menu()
end

function _update(dt)
  if client then client.preupdate() end
  if server then server.preupdate() end

  read_server()

  if mainmenu then
    update_mainmenu()
    if btnr(7) then love.event.push("quit") end
  else
    --if not server then
    read_client()
    --end
  
    xmod,ymod=0,0
    update_game(dt)
    xmod,ymod=0,0
    
    update_client()
  end
  
  update_server()
  
  if client then client.postupdate() end
  if server then server.postupdate() end
end

debuggg = ""
function _draw()
  if mainmenu then
    draw_mainmenu()
  else
    draw_game()
  end
  
  
  font("pico")
  
  camera(0,0)
  draw_text(""..#players, 2,2,0, 0,7,13)
  
  local x=12
  for id,p in pairs(players) do
    draw_text(""..id, x,2,0, 0,11,3)
    x = x+10
  end
  
  draw_text(""..(server and 1 or 0), 2,12,0, 0,7,13)
  local x=12
  if server then
    draw_text(""..#server.homes, x,12,0, 0,12,1) x = x+10
    for id,p in pairs(server.homes) do
      draw_text(""..id, x,12,0, 0,11,3)
      x = x+10
    end
  end
  
  draw_text(""..(client and 1 or 0), 2,22,0, 0,7,13)
  local x=12
  if client then
    draw_text(""..#client.share, x,22,0, 0,12,1) x = x+10
    for id,p in pairs(client.share) do
      draw_text(""..id, x,22,0, 0,11,3)
      x = x+10
    end
  end
  draw_text(""..(client and client.connected and 1 or 0), 2,32,0, 0,7,13)
  
  
  local scrnw, scrnh = screen_size()
  local x,y = 4, scrnh-12
  draw_text("ping: "..(client and client.connected and client.getPing() or "NaN"), x,y,0, 0,7,13)
  y = y-12
  draw_text(client and client.connected and "Connected to server" or "Not connected", x, y, 0, 0,7,13)
  
  x,y = scrnw-4, scrnh-12
  draw_text(server and "Hosting server" or "Not hosting", x, y, 2, 0,7,13)
  y= y-12
  draw_text("Seeing "..#players.." players", x, y, 2, 0,7,13)
  y= y-12
  draw_text(player.shooting and "Shooting" or "Not shooting", x, y, 2, 0,7,13)
  
  
--  local x,y = 4, scrnh/2
--  draw_text("My ID: "..(my_id or "not connected"), x, y, 0,  0, 7, 13) y = y+12  
--  draw_text("1 - "..(client and client.connected and client.home[1] or "not connected"), x, y, 0,  0, 7, 13)  y = y+12
--  draw_text("2 - "..(client and client.connected and client.home[2] or "not connected"), x, y, 0,  0, 7, 13)  y = y+12
--  draw_text("3 - "..(client and client.connected and client.home[3] and "true" or "false"), x, y, 0,  0, 7, 13)  y = y+12
--  draw_text("4 - "..(client and client.connected and client.home[4] and "true" or "false"), x, y, 0,  0, 7, 13)  y = y+12
--
--  
--  local x,y = scrnw-4, scrnh/2
--  --draw_text("My ID: "..(client and client.connected and my_id or "not connected"), x, y, 0,  0, 7, 13) y = y+12  
--  draw_text("1 - "..(server and server.homes[2] and server.homes[2][1] or "not connected"), x, y, 2,  0, 7, 13)  y = y+12
--  draw_text("2 - "..(server and server.homes[2] and server.homes[2][2] or "not connected"), x, y, 2,  0, 7, 13)  y = y+12
--  draw_text("3 - "..(server and server.homes[2] and server.homes[2][3] and "true" or "false"), x, y, 2,  0, 7, 13)  y = y+12
--  draw_text("4 - "..(server and server.homes[2] and server.homes[2][4] and "true" or "false"), x, y, 2,  0, 7, 13)  y = y+12
  draw_text(debuggg, x, y, 2,  0, 7, 13)  y = y+12
end


function init_game()
  clear_all_groups()
  register_object(player)
  register_object(cam)
 
  mainmenu=false
  paused=false
  gameover=false
  
--  for i=1,8 do
--    create_ship(rnd(32)-16,rnd(32),"smol",true)
--  end
  
  spawner=create_spawner()
  
  level=1
  levelt=1
  score=0
  
  dangerlvl=0
  
  lastlevel=level
  scoredisp=0
  fshipdisp=0
  eshipdisp=0
  
  music("game")
end

function update_game()
  t=t+0.01*dt30f
  
  update_shake()
  
  if update_ui_controls() then
    return
  end
  
--  levelt=max(levelt-0.01*dt30f,0)
--  if dangerlvl<flr(flr(level)/24*100) then
--    dangerlvl=dangerlvl+0.3*dt30f
--  end
  
  for o in group("to_wrap") do
    wrap_around(o)
  end
  
  shootshake=0
  
  update_objects()
  
  shootshake=min(shootshake,2)
  add_shake(shootshake)
  
--  if lastlevel~=flr(level) then
--    for i=1,8 do
--      create_screenglitch(256,min(level*16,256))
--    end
--    sfx("levelup")
--    levelt=1
--  end
--  lastlevel=flr(level)
  
--  local armyk=group_size("friend_ship")
--  if armyk<12 and level>=8 and group_size("hole")==0 and rnd(100)<1 then
--    local a
--    local x,y
--    
--    for i=0,2 do
--      a=atan2(massvx,massvy)+i*0.25+rnd(0.2)-0.1
--      x,y=massx+600*cos(a),massy+600*sin(a)
--      
--      if y>50 and y<areah-50 then
--        break
--      end
--    end
--    
--    create_hole(x,y,level)
--  end
  
  local omx=massx
  local omy=massy
  
  if group_size("friend_ship")>0 then
    massx,massy=get_mass_pos("friend_ship")
  elseif not gameover then
--    boomsfx()
--    create_explosion(massx,massy,32,10)
--    add_shake(64)
--    menu("gameover")
--    gameover=true
--    music()
--    sfx("gameover")
  end
  massvx=massx-omx
  massvy=massy-omy
  
  scoredisp=round(lerp(scoredisp,score,0.51*dt30f))
--  fshipdisp=fshipdisp+sgn(group_size("friend_ship")-fshipdisp)
--  eshipdisp=eshipdisp+sgn(group_size("enemy_ship")-eshipdisp)
end

function draw_game()
  xmod,ymod=cam:screen_pos()
  xmod=xmod+shkx
  ymod=ymod+shky
  
  screen_width,screen_height=screen_size()
  
  camera(0,0)
  
  draw_background()
  
  camera(xmod,ymod)
  draw_objects()
  
--  font("pico")
--  for i,p in pairs(players) do
--    camera(0,0)
--    local y = 20 +i*30
--    local x = 10
--    --for j,d in pairs(client.share[i]) do
--    --  draw_text(j.." : "..d, x, y, 0, 0, 8, 2)
--    --  x = x+10
--    --  y = y+10
--    --end
--    local x = 10
--    for j,d in pairs(p) do
--      draw_text(j.." : "..d, x, y, 0, 0, 8, 2)
--      x = x+10
--      y = y+10
--    end
--    x = 10
--    
--    camera(xmod,ymod)
--    if p.x and p.y then
--      draw_player(p)
--    end
--  end
  
  camera(0,0)
--  draw_levelup()
  
  local scrnw,scrnh=screen_size()
  
  if paused then
    draw_pause()
    camera(xmod,ymod)
    player:draw()
  elseif gameover then
    draw_gameover()
    camera(xmod,ymod)
    player:draw()
  else
    draw_score()
  end
end

function define_menus()
  function start_game()
    menu_back()
    init_game()
    if server then
      deregister_object(player)
      my_id = 0
      player = server_new_player(0)
    else
      connect_to_server()
    end
  end

  local menus={
    mainmenu={
      {"play", start_game},
      {"Start Server", function() start_server() end},
      {"settings", function() menu("settings") end}
    },
    settings={
      {"fullscreen", fullscreen},
      {"master volume", master_volume,"slider",100},
      {"music volume", music_volume,"slider",100},
      {"sfx volume", sfx_volume,"slider",100},
      {"back", menu_back}
    },
    pause={
      {"resume", function() menu_back() paused=false end},
      {"restart", init_game},
      {"settings", function() menu("settings") end},
      {"back to main menu", main_menu},
    },
    gameover={
      {"restart", init_game},
      {"back to main menu", main_menu}
    }
  }
  
  if not castle then
    add(menus.mainmenu, {"quit", function() love.event.push("quit") end})
  end
  
  return menus
end


--main menu
function main_menu()
  clear_all_groups()
  register_object(player)
  register_object(cam)
  
  levelt=0
  cloudrngk=rnd(9999)
  
  mainmenu=true
  menu("mainmenu")
  
  music("title")
end

function update_mainmenu()
  t=t+0.01*dt30f
  
  update_shake()
  
  local scrnw,scrnh=screen_size()
  local y=min(scrnh/2+48,scrnh-menu_height()+96)
  update_menu(scrnw/2,y-16)
  
  update_player(player)
  
  if btnp(8) then
    server_address = love.system.getClipboardText()
  end
end

function draw_mainmenu()
  xmod,ymod=cam:screen_pos()
  xmod=xmod+shkx
  ymod=ymod+shky
  
  draw_background()
  
  camera(0,0)
  local scrnw,scrnh=screen_size()
  
  if curmenu=="mainmenu" then
    font("pico16")
    
    local foo=function(x,y)
      spr(0,1,scrnw/2+x,scrnh*0.2-40+y,19,4)
      spr(64,1,scrnw/2+x,scrnh*0.2+y,19,4)
    end
    
    do
      all_colors_to(0)
      foo(0,-3) foo(-1,-2) foo(1,-2) foo(-2,-1) foo(2,-1)
      foo(-3,0) foo(3,0)
      foo(-3,1) foo(3,1)
      foo(0,4) foo(-1,3) foo(1,3) foo(-2,2) foo(2,2)
      all_colors_to(13)
      foo(-2,1) foo(-1,2) foo(0,3) foo(1,2) foo(2,1)
      all_colors_to(7)
      foo(-2,0) foo(2,0) foo(0,-2) foo(0,2)
      foo(-1,-1) foo(-1,1) foo(1,-1) foo(1,1)
      all_colors_to(0)
      foo(-1,0) foo(1,0) foo(0,-1) foo(0,1)
      all_colors_to()
      foo(0,0)
    end
    
    draw_text("left click to fire, right click to boost",scrnw/2,scrnh*0.2+48,1,0,10,4)
    draw_text("you can't rescue ships while firing",scrnw/2,scrnh*0.2+64,1,0,10,4)
  end
  
  local y=min(scrnh/2+48,scrnh-menu_height()+96)
  draw_menu(scrnw/2,y,t)
  
  
  local x,y = scrnw/2, scrnh-10
  draw_text("Server address: "..server_address, x, y, 1, 0, 13, 1)
  
  
  camera(xmod,ymod)
  player:draw()
end


--updates
function update_player(s)
  if s.it_me then
    s.x,s.y=mouse_pos()
    
    local camx,camy=cam:screen_pos()
    s.x=s.x+camx
    s.y=s.y+camy
    
    s.shooting = mouse_btn(0)
    s.boosting = mouse_btn(1)
    
    --if s.shooting then
    --  create_bullet(s.x, s.y, rnd(1), rnd(2), my_id or 0)
    --end
    
    s.t=s.t+delta_time
    
    if mouse_btnp(0) then -- maybe make it so you hear other players do it too??
      add_shake(8)
      sfx("shootorder")
    end
    
    if mouse_btnp(1) then
      sfx("boost")
    end
  end
  
  lsrand(s.seed or 0)
  for _,ship in pairs(s.ships) do
    ship:update()
  end
end

function update_spawner(s)
  s.t=s.t+0.01*dt30f
  
  if s.t%0.5<0.01*dt30f then
    local lvlk=1
    for i=1,flr(level) do
      lvlk=lvlk+i/2
    end
    
    local enpts=lvlk*10
    
    local presval=0
    for e in group("enemy_ship") do
      presval=presval+e.info.spawnval 
    end
    
    enpts=enpts-presval
    
    local typ=nil
    local num=0
    for k,ship in pairs(ship_infos) do
      if ship.spawnval<0.8*enpts and (rnd(4)<1 or not typ) then
        typ=k
        local availbl=flr(enpts/ship.spawnval)
        num=flr((0.25+rnd(0.5))*availbl)
        num=max(num,1)
      end
    end
    
    if typ then
      local x,y
      repeat
        local a=rnd(1)
        x,y=cam.x+800*cos(a),cam.y+800*sin(a)
      until y>0 and y<areah
      
--      for i=1,num do
--        create_ship(x+rnd(32)-16,y+rnd(32)-16,typ)
--      end
    end
  end
end

function update_hole(s)
  s.t=s.t+0.01*dt30f
  s.r=min(s.r+0.5*dt30f,(1+0.1*sin(s.t*2))*0.5*s.wid,0.5*s.wid)
  
  if dist(s.x,s.y,massx,massy)<200 then
    s.x=s.x+0.5*massvx
    s.y=s.y+0.5*massvy
  end
  
  s.y=clamp(s.y,32,areah-32)
  
  if rnd(8)<1 then
    s.xx=s.xx+rnd(32)-16
    s.yy=s.yy+rnd(32)-16
  end
  
  if rnd(4)<1 then
    s.xx=s.x
    s.yy=s.y
  end
  
  local col=collide_objgroup(s,"friend_ship")
  if col and s.t>0.5 then
    deregister_object(s)
    
    for i=0,32 do
      create_screenglitch(256,256)
    end
    
    local k=s.lvl*5
    local bk=max(flr(k/20)-1,0)
    k=k-bk*20
    
    for i=0,k+bk do
      if i>0 then
        local a=rnd(1)
        local l=2+rnd(s.r+8)
        local sh
--        if i<=bk then
--          sh=create_ship(s.x+l*cos(a),s.y+l*sin(a),"biggie",true)
--        else
--          sh=create_ship(s.x+l*cos(a),s.y+l*sin(a),"smol",true)
--        end
        sfx("save")
        
        local acur=atan2(player.x-sh.x,player.y-sh.y)
        sh.aim=sh.aim+0.2*angle_diff(sh.aim,acur)
      end
      
      love.timer.step()
      dt = love.timer.getDelta()
      if dt < 1/15 then
        love.timer.sleep(1/15 - dt)
      end
      
      if i%2<1 then
        update_game(1/30)
      end
      
      drawstep()
    end
    
    while group_size("screen_glitch")>0 do
      deregister_object(group_member("screen_glitch",1))
    end
    
    return
  end
  
  camera(0,0)
  draw_to(s.surfa)
  for i=0,3 do
    local x1,y1=rnd(s.wid),rnd(s.wid)
    local x2,y2=rnd(s.wid),rnd(s.wid)
    local c=rnd(8)<7 and 0 or 8+flr(rnd(8))
    rectfill(x1,y1,x2,y2,c)
  end
  draw_to(s.surfb)
  cls(3)
  circfill(s.wid/2,s.wid/2,s.r,0)
  draw_to(s.surf)
  palt(0,false)
  draw_surface(s.surfa)
  palt(0,true)
  draw_surface(s.surfb)
  draw_to()
end

function get_mass_pos(grp)
  local mx,my=0,0
  
  local k=0
  for o in group(grp) do
    mx=mx+o.info.value*o.x
    my=my+o.info.value*o.y
    k=k+o.info.value
  end
  
  mx=mx/k
  my=my/k
  
  return mx,my
end

function update_camera(c)
  local camxto
  local camyto
  
  local m=group_member("hole",1)
  
  if m then
    local px,py=massx+massvx*32,massy+massvy*32
    local dx,dy=m.x-px,m.y-py
    
    local d=dist(dx,dy)
    local a=atan2(dx,dy)
    d=min(d,200)
    dx,dy=d*cos(a),d*sin(a)
    dx,dy=px+dx,py+dy
    
    camxto=(px+dx+0.5*player.x)/2.5
    camyto=(py+dy+0.5*player.y)/2.5
  else
    camxto=(massx+massvx*32+0.5*player.x)/1.5
    camyto=(massy+massvy*32+0.5*player.y)/1.5
  end
  
  local scrnw,scrnh=screen_size()
  local k=150
  local bo,to=camyto-scrnh/2,camyto+scrnh/2
  if bo<k and to>areah-k then
    camyto=areah/2
  else
    if bo<k then
      camyto=k-sqr((k-bo)/k)*k+scrnh/2
      camyto=max(camyto,scrnh/2)
    elseif to>areah-k then
      camyto=areah-k+sqr((k-(areah-to))/k)*k-scrnh/2
      camyto=min(camyto,areah-scrnh/2)
    end
  end 
  
  --c.x=lerp(c.x,camxto,0.05*dt30f)
  --c.y=lerp(c.y,camyto,0.05*dt30f)
  c.x=lerp(c.x,0,0.05*dt30f)
  c.y=lerp(c.y,0,0.05*dt30f)
end

function update_ui_controls()
  if (btnp(6) or btnp(7)) and not gameover then
    if paused then
      menu_back()
      if not curmenu then
        paused=false
      end
    else
      menu("pause")
      paused=true
    end
  end
  
  if paused then
    local scrnw,scrnh=screen_size()
    update_menu(scrnw/2,scrnh/2)
    player:update()
    return true
  elseif gameover then
    local scrnw,scrnh=screen_size()
    update_menu(scrnw/2,scrnh/2+32)
  end
  
  return false
end

function wrap_around(s)
  local d=s.x-cam.x
  
  if abs(d)>areaw/2 then
    d=d+areaw/2
    d=d%areaw
    d=d-areaw/2
    s.x=cam.x+d
  end
end


--draws
function draw_player(s)
  local a=s.t*0.5
  local foo=function(a)
    circ(s.x,s.y,8+4*cos(a),7)
    
    a=a*0.5
    for i=a,a+0.75,0.25 do
      local x1,y1=s.x+2*cos(i),s.y+2*sin(i)
      local x2,y2=s.x+14*cos(i),s.y+14*sin(i)
      line(x1,y1,x2,y2)
    end
  end
  
  draw_outline(foo,0,a)
  foo(a)
end

function draw_hole(s)
  --circfill(s.xx,s.yy,s.r,0)
  palt(0,false)
  palt(3,true)
  draw_surface(s.surf,s.xx-s.wid*0.5,s.yy-s.wid*0.5)
  palt(0,true)
  palt(3,false)
  
  if s.t>0.5 then
    for i=0,0.75,0.25 do
      local a=i+s.t*0.5
      local d=s.r+7+5*cos(s.t*4)
      local x1,y1=s.x+d*cos(a),s.y+d*sin(a)
      d=d+12
      local x2,y2=s.x+d*cos(a),s.y+d*sin(a)
      
      local foo=function()
        line(x1,y1,x2,y2,7)
      end
      
      draw_outline(foo,0)
      foo()
    end
  end
end

function draw_background()
  if not draw_gridbackground() then return end

  if group_size("screen_glitch")==0 then
    if level>=30 then
      draw_gridbackground()
    else
      draw_skybackground()
    end
  else
    if level>=30 then
      draw_skybackground()
    else
      draw_gridbackground()
    end
    
    local surf=new_surface(screen_size())
    draw_to(surf)
    
    if level>=30 then
      draw_gridbackground()
    else
      draw_skybackground()
    end
    camera(xmod,ymod)
    
    for s in group("screen_glitch") do
      if s.x~=s.ox or s.y~=s.oy then
        rectfill(s.ox-s.w/2,s.oy-s.h/2,s.ox+s.w/2,s.oy+s.h/2,3)
        rectfill(s.x-s.w/2,s.y-s.h/2,s.x+s.w/2,s.y+s.h/2,s.c)
      else
        rectfill(s.ox-s.w/2,s.oy-s.h/2,s.ox+s.w/2,s.oy+s.h/2,3)
      end
    end
    
    draw_to()
    
    camera(0,0)
    palt(0,false)
    palt(3,true)
    local foo=function()
      draw_surface(surf,0,0,0,0,screen_size())
    end
    draw_outline(foo,13)
    foo()
    palt(0,true)
    palt(3,false)
  end
end

function draw_gridbackground()
  local ca,cb=1,13
  
  cls(0)
  draw_grid(0.25*xmod,0.25*ymod,32,1)
  draw_grid(0.75*xmod,0.75*ymod,64,13)
  
  if level>=30 and mainmenu then
    draw_cloudlayer(0.25*xmod,0.25*ymod,150,0.4,6,13) 
    draw_cloudlayer(0.75*xmod,0.75*ymod,350,1.5,7,6)
  end
end

function draw_skybackground()
  local scrnw,scrnh=screen_size()
  
  local plt
  
  if level>=24 then
    plt={0,2,8,13,1,14,8}
  elseif level>=12 then
    plt={2,14,15,15,13,7,6}
  else
    plt={1,12,15,15,13,7,6}
  end

  local c=plt[1]
  local cb=plt[2] --MAKE IT DEPEND ON LEVEL
  local cc=plt[3]
 
  cls(c)
 
  local paral=0.125
  local x,y=paral*xmod,paral*ymod
  camera(x,y)
  local ancy=paral*areah*0.5
  rectfill(x,ancy,x+scrnw,y+scrnh+4,cb)

  local ofs=1
  for i=0,8 do
   ofs=ofs+i
   line(x,ancy-ofs,x+scrnw,ancy-ofs,cb)
   line(x,ancy+ofs-4,x+scrnw,ancy+ofs-4,c)
  end
 
  local ancy=paral*(scrnh/paral+0.5*areah)--areah-paral*areah*0.5-scrnh
  rectfill(x,ancy,x+scrnw,y+scrnh+4,cc)

  local ofs=1
  for i=0,8 do
    ofs=ofs+i
    line(x,ancy-ofs,x+scrnw,ancy-ofs,cc)
    line(x,ancy+ofs-4,x+scrnw,ancy+ofs-4,cb)
  end
  
  draw_cloudlayer(0.25*xmod,0.25*ymod,150,0.4,plt[4],plt[5]) 
  draw_cloudlayer(0.75*xmod,0.75*ymod,350,1.5,plt[6],plt[7])
end

function draw_cloudlayer(ancx,ancy,d,sca,c0,c1)
  local scrnw,scrnh=screen_size()
  
  camera(ancx,ancy)
  
  local gancx=ancx-ancx%d
  local gancy=ancy-ancy%d
  
  for x=gancx-d,gancx+scrnw+2*d,d do
    for y=gancy-d,gancy+scrnh+2*d,d do
      draw_cloud(x,y,sca,c0,c1,d)
    end
  end
end

function draw_cloud(x,y,sca,c0,c1,d)
  local rng=rrng()
  rsrand(rng,(x+y*81+sca*8674)*cloudrngk)
  
  if rrnd(rng,3)<1 then
    return
  end
  
  x=x+rrnd(rng,0.8*d)-0.4*d
  y=y+rrnd(rng,0.8*d)-0.4*d
  
  local a={}
  local k=16
  for i=0,k do
    local m=(k/2-abs(k/2-i))/(k/2)
    local b={
      x=x-(48+i/k*96+rrnd(rng,16)-8)*sca,
      y=y-(rrnd(rng,m*32))*sca,
      r=(8+(rrnd(rng,m*20)))*sca,
      k=rrnd(rng,1)
    }
    
    b.r=b.r+4*sca*cos(b.k+t)
    
    add(a,b)
  end
  
  local ofs=sca*3
  for b in all(a) do
    circfill(b.x,b.y+ofs,b.r+ofs,c1)
  end
  
  for b in all(a) do
    circfill(b.x,b.y,b.r,c0)
  end
end

function draw_grid(ancx,ancy,d,c)
  local scrnw,scrnh=screen_size()
  
  color(c)
  camera(ancx,ancy)
  
  local gancx=ancx-ancx%d
  local gancy=ancy-ancy%d
  
  for x=gancx,gancx+scrnw+d,d do
    line(x,ancy,x,ancy+scrnh)
  end
  
  for y=gancy,gancy+scrnh+d,d do
    line(ancx,y,ancx+scrnw,y)
  end
end

function draw_levelup()
  if levelt>0 then
    local scrnw,scrnh=screen_size()
    
    font("pico16")
    local str="danger:  "..flr(dangerlvl).."%"
    if levelt%0.2>0.05 then
      draw_text(str,scrnw/2,scrnh/2,1,0,14,2)
    else
      draw_text(str,scrnw/2,scrnh/2,1,7,7,7)
    end
  end
end

function draw_score()
  local scrnw,scrnh=screen_size()
  font("pico16")
  local str=bignumstr(scoredisp,',')
  draw_text("SCORE: "..str,scrnw/2,scrnh-12)
end

function draw_pause()
  local scrnw,scrnh=screen_size()

  color(7)
  for i=0,scrnh,2 do
    line(0,i,scrnw,i)
  end
  
  font("pico16")
  if t%0.4<0.3 then
    draw_text("PAUSE",scrnw/2,16)
  end
  draw_menu(scrnw/2,scrnh/2+16,t)
end

function draw_gameover()
  local scrnw,scrnh=screen_size()
  font("pico16")
  
  if t%0.4<0.3 then
    draw_text("GAME_OVER",scrnw/2,16,1,0,14,2)
  end
  
  draw_text("you scored",scrnw/2,48,1,0,9,4)
  draw_text(bignumstr(score,','),scrnw/2,64,1,0,10,4)
  
  local rank,comment
  local lvl=flr(flr(level)/24*100)
  if lvl>=200 then
    rank='*S*'
    comment="!!! I didn't know this was possible !!!"
  elseif lvl>=160 then
    rank='A++'
    comment="!!! wow you might actually be able to get the S rank !!!"
  elseif lvl>=125 then
    rank='A+'
    comment="!!! superb, I can see the S rank from here !!!"
  elseif lvl>=100 then
    rank='A'
    comment="!! Nice job! Are you gonna go for the 'S' rank now? !!"
  elseif lvl>=80 then
    rank='B'
    comment="!! Not Bad !!"
  elseif lvl>=60 then
    rank='C'
    comment="! You're getting there !"
  elseif lvl>=40 then
    rank='D'
    comment="! You can do better !"
  elseif lvl>=20 then
    rank='E'
    comment="! Not great !"
  else
    rank='F'
    comment=". We all start somewhere ."
  end
  
  draw_text("rank: "..rank,scrnw/2,96,1,0,8,2)
  draw_text(comment,scrnw/2,112,1,0,14,2)
  
  if rank=='*S*' then
    local str="!! Please send a screenshot to @TRASEVOL_DOG on Twitter !!"
    draw_text(str,scrnw/2,128,1,0,14,2)
  end
  
  draw_menu(scrnw/2,scrnh/2+48,t)
end


--creates
function create_player(x, y, colors, seed, shooting, boosting, it_me)
  local p={
    x = x or 0,
    y = y or 0,
    w = 8,
    h = 8,
    t = 0,
    colors   = colors,
    seed     = seed,
    shooting = shooting,
    boosting = boost,
    ships    = {},
    it_me    = it_me,
    inited = true,
    
    update=update_player,
    draw=draw_player,
    regs={"to_update","to_draw4"}
  }
  
  register_object(p)
  
  return p
end

function create_spawner()
  if spawner then
    deregister_object(spawner)
  end
  
  spawner={
    t=0,
    update=update_spawner,
    regs={"to_update"}
  }
  
  register_object(spawner)
end

function create_hole(x,y,lvl)
  local w=lvl*4
  
  local h={
    x=x,
    y=y,
    xx=x,
    yy=y,
    w=0.75*w,
    h=0.75*w,
    wid=w,
    surf=new_surface(w,w),
    surfa=new_surface(w,w),
    surfb=new_surface(w,w),
    r=0,
    lvl=lvl,
    t=0,
    update=update_hole,
    draw=draw_hole,
    regs={"to_update","to_draw0","to_wrap","hole"}
  }
  
  draw_to(h.surfa)
  cls(0)
  draw_to(h.surfb)
  cls(3)
  --circfill(h.wid/2,h.wid/2,h.r,0)
  draw_to(h.surf)
  cls(0)
  draw_surface(h.surfb,0,0)
  draw_to()
  
  register_object(h)
  
  return h
end

function create_camera(x,y)
  local cam={
    x=x,
    y=y,
    update=update_camera,
    regs={"to_update"}
  }
  
  cam.screen_pos=function(cam)
    local scrnw,scrnh=screen_size()
    return cam.x-scrnw*0.5,cam.y-scrnh*0.5
  end
  
  register_object(cam)
  
  return cam
end



--misc
function bignumstr(n,sep)
  local str=""..n
  local l=#str
  nstr=""
  for ri=0,l-1,3 do
    local i=l-ri
    local c1=max(i-2,0)
    local c2=max(i,0)
    nstr=sep..string.sub(str,c1,c2)..nstr
  end
  
  nstr=string.sub(nstr,1+#sep,#nstr)
  
  return nstr
end

function boomsfx(x,y)
  local str="boom"..flr(rnd(3)+1)
  sfx(str,x,y)
end
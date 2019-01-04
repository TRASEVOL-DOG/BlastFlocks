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
my_name = pick{"Governor", "Captain", "Jarl", "Commander", "President", "General", "Admiral", "Marshal", "Chancellor", "Chieftain"}.." "..pick{"Addison", "Ainslie", "Alexis", "Alpha", "Angel", "Arden", "Ashley", "Ashton", "Aubrey", "Audie", "Avery", "Bailey", "Beverly", "Billie", "Blair", "Blake", "Braidy", "Brook", "Cameron", "Carey", "Carson", "Casey", "Charlie", "Corry", "Courtney", "Kree", "Dakota", "Dallas", "Darby", "Darian", "Delaney", "Dell", "Devin", "Drew", "Elliot", "Ellis", "Emerson", "Emery", "Erin", "Esme", "Evan", "Evelyn", "Finley", "Finn", "Freddie", "Flynn", "Gail", "Gerrie", "Gwynn", "Hadley", "Halsey", "Harley", "Haiden", "Hailey", "Hilary", "Hollis", "Hudson", "Ivy", "Jaime", "Jan", "Jean", "Jerry", "Jesse", "Jocelyn", "Jodi", "Joey", "Jonny", "Jordan", "Jude", "Justice", "Kai", "Kye", "Kary", "Kay", "Keegan", "Kelly", "Kenzie", "Kerry", "Kim", "Kirby", "Kit", "Kyrie", "Lane", "Laurel", "Laurence", "Lauren", "Lee", "Leighton", "Lesley", "Lindsey", "Logan", "Loren", "Lucky", "Madison", "Madox", "Marion", "Marley", "Marlowe", "Mason", "Meade", "Meredith", "Merle", "Micah", "Milo", "Morgan", "Murphy", "Nash", "Nova", "Odell", "Paige", "Palmer", "Parker", "Paris", "Paxton", "Peyton", "Quinn", "Randy", "Reagan", "Remy", "Rennie", "Reed", "Reese", "Ricky", "Riley", "Ridley", "Robin", "Rory", "Rowan", "Royce", "Rudy", "Ryan", "Rylan", "Sasha", "Sawyer", "Skyler", "Scout", "Selby", "Shane", "Shannon", "Shay", "Shelby", "Shelley", "Sheridan", "Shirley", "Sidney", "Skeeter", "Spencer", "Stormy", "Tanner", "Taran", "Tatum", "Taylor", "Tegan", "Temple", "Terry", "Toby", "Tommie", "Toni", "Torrance", "Tori", "Tracy", "Tristan", "Tyler", "Valentine", "Vivian", "Wallis", "Willie", "Winnie", "Wyatt", "Zane"}
connecting = false
connected = false
connect_t = false
debug_mode = 0

function _init()
--  fullscreen()
  eventpump()
  
  init_menu_system()
  
  init_object_mgr(
    "to_wrap",
    "ship",
    "ship_player-2",
    "ship_player-1",
    
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
  
  friendpal={  [22]=8,  [23]=9,  [24]=10}
  enemypal={   [22]=19, [23]=0,  [24]=1}
  neutralpal={ [22]=22, [23]=23, [24]=24}
  
  ship_cols = {21,23,2,3,8,9,11,12,13,14,15,17,18,20}
  ship_poss = {}
  ship_plts = {}
  
  local i = 1
  for c in all(ship_cols) do
    for j=1,i do
      local cb = ship_cols[j]
      add(ship_poss, {c,cb})
    end
    ship_plts[c] = {[22]=c_lit[c], [23]=c, [24]=c_drk[c]}
    i=i+1
  end
  
  local more_cols = {0,1,22,23,24}
  for c in all(more_cols) do
    ship_plts[c] = {[22]=c_lit[c], [23]=c, [24]=c_drk[c]}
  end
  
--  ship_plts[22] = {[22]=21, [23]=22, [24]=23}
--  ship_plts[23] = {[22]=22, [23]=23, [24]=24}
--  ship_plts[24] = {[22]=23, [23]=24, [24]=25}
  ship_nposs = {}
  
  drk=c_drk
  
  areaw=3200
  areah=1600
  
  shkx,shky=0,0
  cam=create_camera(0,areah/2)
  
--  splash_screen()
  
  if not server_only then
    player=create_player(64+32*cos(0.1),64+32*sin(0.1), nil, false, false, nil)
  end
  
  massx,massy=0,0
  massvx,massvy=0,0
  
  shootshake=0
  
  t=0
  
  level=0
  levelt=0
  
  if server_only then
    init_game()
    server_define_non_players()
  else
    main_menu()
  end
end

network_t = 0
function _update(dt)
--  if client then client.preupdate() end
--  if server then server.preupdate() end

--  read_server()

  if not server_only then
    player.it_me = true
  end

  if connecting then
    update_connection_screen()
  elseif mainmenu then
    update_mainmenu()
    if btnr(7) and curmenu=="mainmenu" then love.event.push("quit") end
  else
    xmod,ymod=0,0
    update_game(dt)
    xmod,ymod=0,0
  end
  
  if not server_only and btnp(5) then
    debug_mode = (debug_mode+1)%3
    if debug_mode > 0 then
      debuggg = "debug_mode = "..debug_mode
    else
      debuggg = ""
    end
  end
  
  network_t = network_t - delta_time
  if network_t < 0 then
    if server_only then
      update_server()
    else
      if connecting or connected then
        update_client()
      end
    end
    network_t = 0.050
  end
  
--  if client then client.postupdate() end
--  if server then server.postupdate() end

--  debuggg = ""..(client and client.id or "nil")
--  if (not server_only) and client and connecting then
--    read_client()
--  end
end

debuggg = ""
function _draw()
  if connecting then
    draw_connection_screen()
  elseif mainmenu then
    draw_mainmenu()
  else
    draw_game()
  end
  
  draw_network_state()
  
--  local scrnw,scrnh = screen_size()
--  font("small")
--  draw_text("/!\\ You're playing", 2, scrnh-36, 0, nil, 17)
--  draw_text("a work-in-progress", 2, scrnh-24, 0, nil, 17)
--  draw_text("version of the game.", 2, scrnh-12, 0, nil, 17)
end


function init_game()
  clear_all_groups()
  if player then
    register_object(player)
  end
  
  register_object(cam)
  
  ship_list = {}

  mainmenu=false
  paused=false
  gameover=false
  
--  for i=1,8 do
--    create_ship(rnd(32)-16,rnd(32),"smol",true)
--  end
  
--  spawner=create_spawner()
  
  level=1
  levelt=1
  score=0
  
  highest = 0
  
  dangerlvl=0
  
  lastlevel=level
  scoredisp=0
  fshipdisp=0
  eshipdisp=0
  
  leaderboard_w = 4
  leaderboard = {}
  
  init_gang_sys()
end

function update_game()
  t=t+0.01*dt30f
  
  update_shake()
  
  if update_ui_controls() then
    return
  end
  
  for o in group("to_wrap") do
    if o.x then
      wrap_around(o)
    end
  end
  
  shootshake=0
  
  for id,p in pairs(players) do
    if id>=0 and not p.__registered then
      register_object(p)
    end
  end
  
  update_gangs()
  update_objects()
  
  debuggg = debuggg.." - "..love.timer.getTime()
  
  shootshake=min(shootshake,2)
  add_shake(shootshake)
  
  local omx=massx
  local omy=massy
  
  if not server_only then
    if player.msize > 0 then
      massx, massy = player.mx, player.my
    elseif not gameover and not mainmenu then
      boomsfx()
      create_explosion(massx,massy,32,10)
      add_shake(64)
      menu("gameover")
      gameover=true
      music()
      sfx("gameover")
    end
  end

  massvx=massx-omx
  massvy=massy-omy
  
  if my_id and group_exists("ship_player"..my_id) then
    highest = max(highest, group_size("ship_player"..my_id))
  end
  
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
  
  ship_outline_col = flr(min(25+4*cos(t*2), 25))
  
  camera(xmod,ymod)
  draw_objects()
  
  camera(0,0)
--  draw_levelup()

  draw_heatbar()

  draw_leaderboard()
  draw_minimap()
  
  local scrnw,scrnh=screen_size()
  
  if paused then
    draw_pause()
  elseif gameover then
    draw_gameover()
  else
    draw_score()
  end
  
  camera(xmod,ymod)
  player:draw()
end

function define_menus()
  function start_game()
    connect_to_server()
    init_game()
    menu("cancel")
    client_define_non_players()
  end
  
  function restart()
    if client then
      restarting = true
      client_disconnect()
      connect_to_server()
      init_game()
      client_define_non_players()
    end
    
    --music("theme")
    
    menu_back()
    menu_back()
    paused = false
  end

  local menus={
    mainmenu={
      {"Play", start_game},
      {"Player Name", set_player_name, "text_field", 16, my_name},
      {"Settings", function() menu("settings") end},
      {"Join the Castle Discord!", function() love.system.openURL("https://discordapp.com/invite/4C7yEEC") end}
    },
    cancel={
      {"Go Back", function() connecting=false main_menu() end}
    },
--    mainmenu={
--      {"Connect and Play", function() menu("connectplay") end},
--      {"Host and Play", function() menu("hostplay") end},
--      {"Settings", function() menu("settings") end}
--    },
--    connectplay={
--      {"Play", start_game},
--      {"Player Name", set_player_name, "text_field", 16, my_name},
--      {"Server Address", function(str) server_address=str end, "text_field", 16, server_address},
--      {"Port", function(str) server_port=str end, "text_field", 6, server_port},
--      {"Back", menu_back}
--    },
--    cancel={
--      {"Go Back", function() connecting=false main_menu() end}
--    },
--    hostplay={
--      {"Play", function() start_server() start_game() end},
--      {"Player Name", set_player_name, "text_field", 16, my_name},
--      {"Port", function(str) server_port=str end, "text_field", 6, server_port},
--      {"Back", function() menu("mainmenu") end}
--    },
    settings={
      {"Fullscreen", fullscreen},
      {"Master Volume", master_volume,"slider",100},
      {"Music Volume", music_volume,"slider",100},
      {"Sfx Volume", sfx_volume,"slider",100},
      {"Back", menu_back}
    },
    pause={
      {"Resume", function() menu_back() paused=false music_lowpass(false) end},
      {"Restart", restart},
      {"Settings", function() menu("settings") end},
      {"Back to Main Menu", main_menu},
    },
    gameover={
      {"Restart", restart},
      {"Back to Main Menu", main_menu}
    }
  }
  
  if not (castle or network) then
    add(menus.mainmenu, {"Quit", function() love.event.push("quit") end})
  end
  
  return menus
end


--main menu
function main_menu()
--  if client then client_disconnect() end
--  if server then server_close() end
  mainmenu=true
  menu_back()
  menu_back()

  restarting = true
  
  init_game()

  player.ships = {}
  clear_all_groups()
  register_object(player)
  register_object(cam)
  
  levelt=0
  cloudrngk=rnd(9999)
  
  mainmenu=true
  menu("mainmenu")
  
  music("theme")
  music_lowpass(true)
end

function update_mainmenu()
  t=t+0.01*dt30f
  
  update_shake()
  
  local scrnw,scrnh=screen_size()
  local y = (curmenu == "mainmenu") and (scrnh/2+56) or (scrnh/2)
  update_menu(scrnw/2,y-16)
  
  update_player(player)
  
  --if btnp(9) then
  --  server_address = love.system.getClipboardText()
  --end
end

function draw_mainmenu()
  xmod,ymod=cam:screen_pos()
  xmod=xmod+shkx
  ymod=ymod+shky
  
  draw_background()
  
  camera(0,0)
  local scrnw,scrnh=screen_size()
  
  local y=scrnh/2
  if curmenu=="mainmenu" then
    font("big")
--    pal()
--    local foo=function(x,y)
--      spr(0,1,scrnw/2+x,scrnh*0.2-40+y,20,4)
--      spr(64,1,scrnw/2+x,scrnh*0.2+y,20,4)
--    end
--    
--    do
--      all_colors_to(25)
--      foo(0,-3) foo(-1,-2) foo(1,-2) foo(-2,-1) foo(2,-1)
--      foo(-3,0) foo(3,0)
--      foo(-3,1) foo(3,1)
--      foo(0,4) foo(-1,3) foo(1,3) foo(-2,2) foo(2,2)
--      all_colors_to(22)
--      foo(-2,1) foo(-1,2) foo(0,3) foo(1,2) foo(2,1)
--      all_colors_to(21)
--      foo(-2,0) foo(2,0) foo(0,-2) foo(0,2)
--      foo(-1,-1) foo(-1,1) foo(1,-1) foo(1,1)
--      all_colors_to(25)
--      foo(-1,0) foo(1,0) foo(0,-1) foo(0,1)
--      all_colors_to()
--      foo(0,0)
--    end
    draw_title(scrnh*0.17)
    
    --draw_text("left click to fire, right click to boost",scrnw/2,scrnh*0.2+48,1,25,19,0)
    --draw_text("you can't rescue ships while firing",scrnw/2,scrnh*0.2+64,1,25,19,0)
    
    local stra = "- left click to fire"
    local strb = "- right click to boost"
    local strc = "- save falling ships"
    
--    local cols = {15,14,13,21,21,21,21,21,21,21,21,21,21,13,14}
    local cols = {21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,13,14,8,2,3,0,17,19}
    local c

    font("small")
    local x = scrnw/2 - str_width(strb)/2 - 5
    y = scrnh*0.2+48
--    draw_text(stra, x, y, 0, nil, 19, 0) y,x = y + 14, x + 8
--    draw_text(strb, x, y, 0, nil, 13, 14) y,x = y + 14, x + 8
--    draw_text(strc, x, y, 0, nil, 8, 9)
    c = cols[flr(t*75+4)%#cols+1]
    draw_text(stra, x, y, 0, nil, c) y,x = y + 10, x + 5
    c = cols[flr(t*75+2)%#cols+1]
    draw_text(strb, x, y, 0, nil, c) y,x = y + 10, x + 5
    c = cols[flr(t*75)%#cols+1]
    draw_text(strc, x, y, 0, nil, c)
  
    y = scrnh/2+56
  end
  
  draw_credits()
  

  draw_menu(scrnw/2,y,t)
  
  camera(xmod,ymod)
  player:draw()
end

function draw_title(y)
  local scrnw, scrnh = screen_size()
  local x = scrnw/2

  local sprites = {0, 4, 8, 12, 64}
  local order = {0,1,4,3,2}
  for i=1,5 do
    local s = order[i]
    local rs = s-2
    local rx = rs*34
    local ry = -24
    
    local d = 5.5*cos(love.timer.getTime()*0.75 + abs(rs)*0.25)
    local a = atan2(rx,ry-64)
    local dx = d*cos(a)
    local dy = d*sin(a)
    
    spr(sprites[s+1], 1, x+rx+dx, y+ry+dy, 4, 4)
  end
  
  local sprites = {68, 72, 76, 128, 132, 136}
  local order = {0,1,5,4,2,3}
  for i=1,6 do
    local s = order[i]
    local rs = s-2.5
    local rx = rs*34
    local ry = 24
    
    local d = 5.5*cos(-love.timer.getTime()*0.75 - abs(rs)*0.25)
    local a = atan2(rx,ry+64)
    local dx = d*cos(a)
    local dy = d*sin(a)
    
    spr(sprites[s+1], 1, x+rx+dx, y+ry+dy, 4, 4)
  end
  
--  apply_pal_map(ship_plts[22])
--  draw_anim(x-112, y, "hugeship", "rotate", 0.25, 0.375, false, false)
--  draw_anim(x-112+10, y+10, "hugeship", "bfire", t, 0.375)
--  
--  draw_anim(x+112, y, "hugeship", "rotate", 0.25, 0.175, false, false)
--  draw_anim(x+112-10, y+10, "hugeship", "bfire", t, 0.175)
end


--updates
function update_player(s)
  s.t=s.t+delta_time
  
  if s.it_me then
    s.x,s.y=mouse_pos()
    
    local camx,camy=cam:screen_pos()
    s.x=s.x+camx
    s.y=s.y+camy
    
    s.boosting = mouse_btn(1)
    s.shooting = mouse_btn(0) and not s.boosting
    
    --if s.shooting then
    --  create_bullet(s.x, s.y, rnd(1), rnd(2), my_id or 0)
    --end
    
    if mouse_btnp(0) then -- maybe make it so you hear other players do it too??
      if s.boosting then
        add_shake(2)
      else
        add_shake(4)
        sfx("shootorder")
      end
    end
    
    if mouse_btnp(1) then
      sfx("boost")
    end
  end
  
  if s.ships and s.overheat and (s.it_me or server_only) then
    if s.shooting and (s.msize or 0) > 0 then
      s.overheat = min(s.overheat + min(s.msize/50*0.5,0.66)*delta_time, 1.1)
      
      if server_only and s.overheat>1.09 then
        local sh
        local typ = 1
        while not sh do
          for _,shh in pairs(s.ships) do
            if shh.typ_id == typ then
              sh = shh
              break
            end
          end
          typ = typ+1
          if typ > 4 then break end
        end
        if sh then
          create_explosion(s.x,s.y,s.info.hlen*2+8,s.c)
          destroy_ship(sh)
        else
          castle_print("Could not destroy ship from overheat?")
        end
        s.overheat = 1.0
      end
    else
      s.overheat = max(s.overheat - 0.1*delta_time, 0)
    end
  end
  
  if s.ships and not s.far then
    if s.id == -2 then
      for _,ship in pairs(s.ships) do
        update_falling_ship(ship)
      end
    else--if s.id then
      s.typs = {{},{},{},{}}
      for _,ship in pairs(s.ships) do
        add(s.typs[ship.typ_id % 8], ship)
      end
    
      for _,ship in pairs(s.ships) do
        ship:update()
      end
      
      if s.id then
        local group = "ship_player"..s.id
        s.msize = group_size(group)
        if s.msize > 0 then
          s.mx, s.my = get_mass_pos(group)
        end
      end
    end
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
  
  if (not group_exists(grp) or group_size(grp) == 0) then return 0,0 end
  
  local s = group_member(grp, 1)
  local ax = s.x
  local ay = s.y
  
  local k=0
  if client then
    for o in group(grp) do
      mx=mx+o.info.value*rel_wrap(o.x+o.dx, ax)
      my=my+o.info.value*rel_wrap(o.y+o.dy, ay)
      k=k+o.info.value
    end
  else
    for o in group(grp) do
      mx=mx+o.info.value*rel_wrap(o.x, ax)
      my=my+o.info.value*rel_wrap(o.y, ay)
      k=k+o.info.value
    end
  end
  
  mx=mx/k
  my=my/k
  
  return mx,my
end

function update_camera(c)
  local camxto
  local camyto
  
  local m=group_member("hole",1)
  
  local player=player
  if server_only then
    player = {x = massx, y = massy}
  end
  
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
  
  c.x=lerp(c.x,camxto,0.05*dt30f)
  c.y=lerp(c.y,camyto,0.05*dt30f)
  --c.x=lerp(c.x,0,0.05*dt30f)
  --c.y=lerp(c.y,0,0.05*dt30f)
end

function update_ui_controls()
  if server_only then return end

  if (btnp(6) or btnp(7)) and not gameover then
    if paused then
      menu_back()
      if not curmenu then
        paused=false
        music_lowpass(false)
      end
    else
      menu("pause")
      paused=true
      music_lowpass(true)
    end
  end
  
  if paused then
    local scrnw,scrnh=screen_size()
    update_menu(scrnw/2,scrnh/2)
--    player:update()
--    return true
  elseif gameover then
    local scrnw,scrnh=screen_size()
    update_menu(scrnw/2, 3*scrnh/4)
  end
  
  return false
end

function update_connection_screen()
  t=t+0.01*dt30f

  if client and client.connected and client.id then
    if restarting then
      if not client.share[client.id] then
        restarting = false
        init_game()
        client_define_non_players()
      end
    elseif player.msize > 0 then
      my_id = client.id
      connecting = false
      connected = true
      menu_back()
      menu_back()
      
      --local mx,my = get_mass_pos("ship_player"..my_id)
      local mx,my = player.mx, player.my
      local scrnw, scrnh = screen_size()
      cam.x = mx
      cam.y = my
      
      massx, massy = mx, my
      massvx, massvy = 0, 0
      
      music_lowpass(false)
    end
  end
  
  update_shake()
  update_player(player)
  
  local scrnw, scrnh = screen_size()
  update_menu(scrnw/2, 0.85*scrnh)
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

function rel_wrap(x, ax)
  local d=x-ax
  
  if abs(d)>areaw/2 then
    d=d+areaw/2
    d=d%areaw
    d=d-areaw/2
    x=ax+d
  end
  
  return x
end


--draws
function draw_player(s)
  local a=s.t*0.25
  local foo
  
  if s.it_me then
    foo=function(a)
      circ(s.x,s.y,8+4*cos(a),21)

      for i=a,a+0.75,0.25 do
        local x1,y1=s.x+2*cos(i),s.y+2*sin(i)
        local x2,y2=s.x+14*cos(i),s.y+14*sin(i)
        line(x1,y1,x2,y2, 21)
      end
    end
    
    camera(xmod, ymod-1)
    draw_outline(foo,25,a)
    camera(xmod, ymod)
    draw_outline(foo,25,a)
  else
    if s.msize > 0 then
      foo=function() end
    else
      foo=function(a)
        for i=a,a+0.75,0.25 do
          local x1,y1=s.x+2*cos(i),s.y+2*sin(i)
          local x2,y2=s.x+6*cos(i),s.y+6*sin(i)
          line(x1,y1,x2,y2, 21)
        end
      end
    end
  end
  
  camera(xmod, ymod-1)
  pal(21,22)
  foo(a)
  camera(xmod, ymod)
  pal(21,21)
  foo(a)
  
  if s.name and not s.it_me then
    font("small")
    if s.msize > 0 then
      local ca,cb = s.colors[1], s.colors[2]
      draw_text_bicolor(s.name, s.mx, s.my-16, 1, 25, c_lit[ca], ca, c_lit[cb], cb)
    else
      draw_text(s.name, s.x, s.y-16, 1, 25, 22)
    end
  end
  
  if leaderboard[1] and s.id == leaderboard[1][1] then
    local x,y = s.mx, s.my+4.5*cos(t*3)-(s.it_me and 8 or 24)
    local c = s.it_me and ship_outline_col or 25
    draw_anim_outline(x, y, "crown", nil, t, c)
    double_pal_map(s.colors[1], s.colors[2])
    pal(0,25)
    draw_anim(x, y, "crown", nil, t)
    all_colors_to()
  end
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
--  if not draw_skybackground() then return end
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
  local ca,cb=16,15
  
  cls(25)
  draw_grid(0.25*xmod,0.25*ymod,32,ca)
  draw_grid(0.75*xmod,0.75*ymod,64,cb)
  
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
    --plt={1,12,15,15,13,7,6}
    --plt={15,14,13,13,15,21,22}
    plt={25,16,18,24,25,23,24}
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

function draw_grid(ancx,ancy,d,c,cb)
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


function draw_minimap()
  if not my_id then return end

  local w = 128
  local h = 64
  
  local scrnw, scrnh = screen_size()
  local x = scrnw - 4 - w
  local y = scrnh - h - 4
  
  local dx,dy = -w/2,0
  function map_pos(pla)
    return (pla.mx/areaw*w -dx)%w, mid(pla.my/areah*h, 0, h-1)
  end
  function map_posb(pla)
    return flr(x+(pla.mx/areaw*w -dx)%w+0.5), flr(y+mid(pla.my/areah*h, 0, h-1)+0.5)
  end
  
  dx,dy = map_pos(player)
  
  rectfill(x, y, x+w-1, y+h-1, 25)
  
  color(16)
  for i=0,w,16 do
    local xx = x+((i-dx)%w)
    line(xx, y, xx, y+h)
  end
  
  for i=0,h,16 do
    line(x, y+i, x+w, y+i)
  end
  
  clip(x, y, w, h)
  
  if my_id then
    local hw = scrnw/2*w/areaw
    local hh = scrnh/2*h/areah
    --local xx = flr(x+w/2+0.5)
    --local yy = flr(y+dy+0.5)
    
    local cx, cy = cam:screen_pos()
    local xx,yy = map_posb({mx=cx, my=cy})
    
    rect(xx, yy, xx+hw*2, yy+hh*2, 15)
    point(xx+hw*2, yy+hh*2, 15)
  end
  
  pal(0,25)
  for id,gang in pairs(gang_grid) do
    if gang.target and gang.size and gang.size>0 then
      local mx,my = map_posb({mx=gang.x, my=gang.y})
      
      apply_pal_map(ship_plts[0])
      spr(191, 0, mx, my)
    end
  end
  
  for id,p in pairs(players) do
    if id >= 0 then
      local mx,my = map_posb(p)
      
      if id ~= my_id and p.msize>0 then
        double_pal_map(p.colors[1], p.colors[2])
        spr(194, 0, mx, my, 2, 2)
      end
    end
  end
  
  if player.msize>0 then
    local mx,my = flr(x+w/2+0.5), flr(y+dy+0.5) -- player position
    double_pal_map(player.colors[1], player.colors[2])
    spr(192, 0, mx, my, 2, 2)
  end
  
  clip()

  pal(23,23)
  rect(x-1, y-2, x+w, y+h+1, 25)
  rect(x, y, x+w-1, y+h, 23)
  rect(x, y-1, x+w-1, y+h-1, 21)
  
  if leaderboard[1] then
    local p = players[leaderboard[1][1]]
    if p then
      local mx, my = map_posb(p)
      draw_anim_outline(mx, my-9+1.5*cos(t*2), "crown", nil, t, 21)
      double_pal_map(p.colors[1], p.colors[2])
      pal(0,25)
      draw_anim(mx, my-9+1.5*cos(t*2), "crown", nil, t)
    end
  end
  all_colors_to()
end

leaderboard_w = 4
leaderboard = {}
function draw_leaderboard()
  leaderboard = gen_leaderboard()
  local l = leaderboard
  
  local scrnw, scrnh = screen_size()
  local w = leaderboard_w
  local x = scrnw - 4 - w
  local y = 4
  
  local xb = scrnw - 4
  
  font("big")
  draw_text("Leaderboard:", x+w/2-6, y)
  y = y + 16
  for i=1, min(#l, 10) do
    local p,n = players[l[i][1]], l[i][2]
    local ca = 20+min(i, 3)
    local cb = p.colors[1]
    local cc = p.colors[2]
    if l[i][1] == my_id then
      draw_text("> "..i.." - ", x, y, 2, nil, ca)
    else
      draw_text(i.." - ", x, y, 2, nil, ca)
    end
    
    local str = (p.name or "").." ("..n..")"
    draw_text_bicolor(str, xb, y, 2, nil, c_lit[cb], cb, c_lit[cc], cc)

    leaderboard_w = max(leaderboard_w, str_width(str)+2)
    y = y + 16
  end
end


function draw_levelup()
  if levelt>0 then
    local scrnw,scrnh=screen_size()
    
    font("big")
    local str="danger:  "..flr(dangerlvl).."%"
    if levelt%0.2>0.05 then
      draw_text(str,scrnw/2,scrnh/2,1,0,14,2)
    else
      draw_text(str,scrnw/2,scrnh/2,1,7,7,7)
    end
  end
end

function draw_heatbar()
  if not player then
    return
  end

  local scrnw,scrnh = screen_size()
  
  local w = 24
  local h = 128
  
  local x = 4
  local y = scrnh-5-h
  
  if player.overheat>=1.0 then
    x = x + rnd(4)-2
    y = y + rnd(4)-2
  end
  
  rectfill(x-1,y-1,x+w,y+h+1,25)
  rect(x,y+1,x+w-1,y+h,23)
  rect(x,y,x+w-1,y+h-1,21)
  
  local hh = mid(player.overheat, 0, 1)*(h-4)
  local c = 21
  if player.overheat >=0.95 then
    local cs = {21,19,1,2,1,19}
    c = cs[flr(t*100)%#cs+1]
    pal(21,c)
    spr(153, 0, x+w/2, y-17, 4, 3)
    pal(21,21)
  elseif player.overheat >= 0.75 then
    local cs = {21,2,3,1,3,2}
    c = cs[flr(t*50)%#cs+1]
    if t%0.3<0.2 then
       spr(153, 0, x+w/2, y-17, 4, 3)
    end
  elseif player.overheat >= 0.5 then
    local cs = {21,13,14,15,14,13}
    c = cs[flr(t*40)%#cs+1]
  else
    local cs = {21,21,21,13,14,15,14,13}
    c = cs[flr(t*25)%#cs+1]
  end
  
  if player.overheat >= 0.75 then
    font("big")
    local str = "OVERHEAT"
    local nh = 14
    local yy = y+h/2-nh*4
    local xx = x+w+3
    for i=1,8 do
      draw_text(str:sub(i,i),xx,yy,0,nil,c)
      yy = yy+nh
    end
  end
  
  rectfill(x+2, y+h-3-hh, x+w-3, y+h-3, c)
end

function draw_score()
  local scrnw,scrnh=screen_size()
  font("big")
--  local str=bignumstr(scoredisp,',')
--  draw_text("SCORE: "..str,scrnw/2,scrnh-14)
  local str = "0"
  if my_id and group_exists("ship_player"..my_id) then
    str=group_size("ship_player"..my_id)
  end
  draw_text("Ships: "..str,scrnw/2,scrnh-30)
  draw_text("Highest: "..highest,scrnw/2,scrnh-14, 1, nil, 13)

--  clip(0,0,scrnw,10)
--  draw_text("Playing as "..my_name, scrnw/2, 6, 1, nil, player.colors[1])
--  clip(0,10,scrnw,1)
--  draw_text("Playing as "..my_name, scrnw/2, 6, 1, nil, nil)
--  clip(0,11,scrnw,12)
--  draw_text("Playing as "..my_name, scrnw/2, 6, 1, nil, player.colors[2])
--  clip()
end

function draw_pause()
  local scrnw,scrnh=screen_size()

  color(25)
  for i=0,scrnh+scrnw,2 do
    --line(0,i,scrnw,i)
    line(i,0,i-scrnh,scrnh)
  end
  
--  font("big")
--  if t%0.4<0.3 then
--    draw_text("PAUSE",scrnw/2,16)
--  end
  
  draw_menu(scrnw/2,scrnh/2,t)
end

function draw_gameover()
  local scrnw,scrnh=screen_size()
  font("big")
  
  if t%0.5<0.44 then
    draw_text("GAME_OVER",scrnw/2,scrnh/4-40,1,nil,23)
    draw_text("GAME_OVER  GAME_OVER  GAME_OVER",scrnw/2,scrnh/4-20,1,nil,23)
    draw_text("GAME_OVER  GAME_OVER  GAME_OVER  GAME_OVER  GAME_OVER",scrnw/2,scrnh/4,1,nil,23)
    draw_text("GAME_OVER  GAME_OVER  GAME_OVER",scrnw/2,scrnh/4+20,1,nil,23)
    draw_text("GAME_OVER",scrnw/2,scrnh/4+40,1,nil,23)
    
    if t%0.5>0.38 then
    
    elseif t%0.5>0.32 then
      draw_text("GAME_OVER",scrnw/2,scrnh/4,1,nil,0)
    elseif t%0.5>0.26 then
      draw_text("GAME_OVER",scrnw/2,scrnh/4-20,1,nil,0)
      draw_text("GAME_OVER  GAME_OVER  GAME_OVER",scrnw/2,scrnh/4,1,nil,0)
      draw_text("GAME_OVER",scrnw/2,scrnh/4+20,1,nil,0)
    else
      draw_text("GAME_OVER",scrnw/2,scrnh/4-40,1,nil,0)
      draw_text("GAME_OVER  GAME_OVER  GAME_OVER",scrnw/2,scrnh/4-20,1,nil,0)
      draw_text("GAME_OVER  GAME_OVER  GAME_OVER  GAME_OVER  GAME_OVER",scrnw/2,scrnh/4,1,nil,0)
      draw_text("GAME_OVER  GAME_OVER  GAME_OVER",scrnw/2,scrnh/4+20,1,nil,0)
      draw_text("GAME_OVER",scrnw/2,scrnh/4+40,1,nil,0)
    end
  end
  
  draw_text_bicolor("you had "..highest.." ships at one time!",scrnw/2,scrnh/2,1,nil,c_lit[player.colors[1]],player.colors[1],c_lit[player.colors[2]],player.colors[2])
  
  draw_menu(scrnw/2,3*scrnh/4,t)
end

function draw_connection_screen()
  xmod,ymod=cam:screen_pos()
  xmod=xmod+shkx
  ymod=ymod+shky

  cls(25)
  
  local scrnw, scrnh = screen_size()
  
  font("big")
  
  local t = love.timer.getTime()
  
  local str = " Connecting... "
  -- -\|/-*oOo*
  local cha = {"-", "\\", "|", "/"}
  local chb = {"-", "/", "|", "\\"}
  for i=0,0 do
    local ca = cha[flr(t*10) % #cha +1]
    local cb = chb[flr(t*10) % #chb +1]
    str = ca..str..cb
  end
  
  --draw_text("Connecting...", scrnw/2, 0.15*scrnh)
  draw_text(str, scrnw/2, 0.15*scrnh)
--  draw_text(str, scrnw/2, 0.15*scrnh-16)
--  draw_text("to "..server_address..":"..server_port, scrnw/2, 0.15*scrnh)
  
  local x,y = scrnw/2, 0.5*scrnh
  
  local aa = t*0.2
  local co = cos(aa)
  local si = sin(aa)
  
  local ta = {}
  
  
  local ki=5
  for j=0,4 do
    all_colors_to(25-j)
    
    for i=1,ki do
    
      local a=i/ki+t*0.4+j*0.01
      
      local xx = 96*cos(a)
      local yy = 48*sin(a*2)
      local xxx = xx*co-yy*si
      local yyy = xx*si+yy*co
      
      if j>0 then
        local aa = atan2(xxx-ta[i][1], yyy-ta[i][2])
        

        draw_anim(x+xxx, y+yyy, "bigship", "rotate", aa, aa, false, (aa+0.25)%1>0.5)
      end
      
      ta[i]={xxx,yyy}
    end
  end
  
  all_colors_to()
  
  draw_menu(scrnw/2, 0.85*scrnh)
  
  camera(xmod, ymod)
  player:draw()
end

ping_t = 0
ping = 0
function draw_network_state()
  local x,y,al = 0,0,0
  function _log(str, big, c)
    font(big and "big" or "small")
    draw_text(str, x, y, al, nil, c or 14)
    y = y + (big and 16 or 12)
  end

  camera(0,0)
  local scrnw, scrnh = screen_size()
  x,y,al = 4, 4, 0
  
  if debug_mode > 0 then
    local fps = love.timer.getFPS()
    _log("FpS: "..fps, true, (fps>=60) and 8 or (fps>=30) and 3 or 0)
  end
  
  if not (server or client) then
    _log("Offline", true, 23)
  end
  
  if server and server_only then
    -- hosting
    -- seeing # players
    -- player list
    
    _log("Hosting Server", true, 13)
    
    local count = 0
    local list = ""
    for id,_ in pairs(players) do
      if id >= 0 then
        count = count + 1
        list = list..id.." "
      end
    end
    list:sub(1, #list-2)
    
    _log("Seeing "..count.." players", false)
    _log(" "..list, false)
    _log("Counting "..group_size("ship").." ships", false)
  end
  
  if client then
    -- connected
    -- ping
    -- seeing # players
    -- player list
    
    if client.connected then
      if debug_mode > 0 then
        _log("Connected to Server", true, 13)
      end
      
      ping_t = ping_t - delta_time
      if ping_t < 0 then
        ping = client.getPing()
        ping_t = 0.2
      end
      _log("Ping: "..ping, true, (ping<100) and 8 or (ping<300) and 3 or 0)

      if debug_mode > 0 then
        _log("My ID: "..(my_id or "missing"))
        
        local count = 0
        local list = ""
        for id,_ in pairs(players) do
          if id >= 0 then
            count = count + 1
            list = list..id.." "
          end
        end
        list:sub(1, #list-2)
        
        _log("Seeing "..count.." players", false)
        _log(" "..list, false)
        _log("Counting "..group_size("ship").." ships.", false)
      end
    else
      _log("Client not connected", true, 23)
    end
  end

  if #debuggg > 0 and debug_mode > 0 then
    _log("debug: "..debuggg, false, 21)
  end
end

function draw_credits()
  local scrnw, scrnh = screen_size()
  
  local x=scrnw-4
  local y=16
  
  font("big")
  
  draw_text("A Castle Game",x,y,2,nil,13) y=y+32
  
  font("small")
  draw_text("Made by",x,y,2,nil,3) y=y+14
  draw_text("Remy Devaux",x,y,2,nil,3) y=y+14
  draw_text("@Trasevol_Dog",x,y,2,nil,3) y=y+32
  
  draw_text("With music by",x,y,2,nil,17) y=y+14
  draw_text("Andrew Matecha",x,y,2,nil,17) y=y+14
  draw_text("@amatecha",x,y,2,nil,17) y=y+32
  
  draw_text("Thank you to my Patreon supporters!",4,scrnh-24,0,nil,9)
  local str = "   ~~~   ^Joseph White^,  ^Spaceling^,  rotatetranslate,  Anne Le Clech,  Wojciech Rak,  HJS,  slono,  Austin East,  Zachary Cook,  Jefff,  Meru,  Bitzawolf,  Paul Nguyen,  Dan Lewis,  Christian Östman,  Dan Rees-Jones,  Reza Esmaili,  Andreas Bretteville,  Joel Jorgensen,  Marty Kovach,  Giles Graham,  Flo Devaux,  Cole Smith,  Thomas Wright,  HERVAN,  berkfrei,  Tim and Alexandra Swast,  Jearl,  Chris McCluskey,  Sam Loeschen,  Pat LaBine,  Collin Caldwell,  Andrew Reitano,  Qristy Overton,  Finn Ellis,  amy,  Brent Werness,  yunowadidis-musik,  Max Cahill,  hushcoil,  Jacel the Thing,  Gruber,  Pierre B.,  Sean S. LeBlanc,  Andrew Reist,  vaporstack,  Jakub Wasilewski"
  local w = str_width(str)
  local x = 4-((t*100)%w)
  draw_text(str,x,scrnh-10,0,nil,9)
  draw_text(str,x+w,scrnh-10,0,nil,9)
end

function double_pal_map(col_a, col_b)
  local pala = ship_plts[col_a]
  local palb = ship_plts[col_b]
  
  pal(8,  pala[22])
  pal(9,  pala[23])
  pal(10, pala[24])
  
  pal(13, palb[22])
  pal(14, palb[23])
  pal(15, palb[24])
end


--creates
function create_player(x, y, colors, shooting, boosting, player_id)
  castle_print("Creating player #"..(player_id or "nil"))
  local p={
    x = x or 0,
    y = y or 0,
    w = 8,
    h = 8,
    t = 0,
    mx = 0,
    my = 0,
    msize = 0,
    overheat = 0,
    colors   = colors,
    shooting = shooting,
    boosting = boost,
    ships    = {},
    id       = player_id,
    it_me    = (player_id == (client and client.id or my_id)),
    update   = update_player,
    draw     = draw_player,
    regs     = {"to_update","to_draw4","to_wrap"}
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
function set_player_name(str)
  my_name = str
  player.name = str
end

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

function gen_leaderboard()
  local t={}
  for id,p in pairs(players) do
    if id>=0 then
      local n=p.msize
      local pos
      for i=1,#t do
        if n>t[i][2] then
          pos = i
          break
        end
      end
      if pos then
        add(t, pos, {id, n})
      else
        add(t, {id, n})
      end
    end
  end
  return t
end

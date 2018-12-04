-- BLAST FLOCK source files
-- by TRASEVOL_DOG (https://trasevol.dog/)

require("maths")
require("shader")

c_drk = {}
c_lit = {}

function init_graphics(scx,scy)
  local fonts={
    --pico={"PICO-8.ttf",4},
    --pico2={"PICO-8.ttf",8},
    --pico16={"PICO16.ttf",16}
    small={"EffortsPro.ttf",16},
    --pico2={"PICO-8.ttf",8},
    big={"Marksman.ttf",16}
  }
  
  local w,h
  if castle or network then
    w,h = love.graphics.getDimensions()
  else
    w,h = 800, 600
  end
  w,h = w/scx, h/scy
  love.window.setMode(w*scx,h*scy,{resizable=true})
  render_canvas=love.graphics.newCanvas(w,h)
  render_canvas:setFilter("nearest","nearest")
  
  love.window.setTitle("*** BLAST FLOCK ***")
  
  init_palette()
  
  love.mouse.setVisible(false)
  
  love.graphics.setDefaultFilter("nearest","nearest",0)
  love.graphics.setPointSize(1)
  love.graphics.setLineWidth(1)
  love.graphics.setLineStyle("rough")
  love.graphics.setLineJoin("none")
  love.graphics.setColor(0,0,0,255)
  
  graphics={}
  graphics.wind_w=w*scx
  graphics.wind_h=h*scy
  graphics.scrn_w=w
  graphics.scrn_h=h
  graphics.scrn_scalex=scx
  graphics.scrn_scaley=scy
  graphics.camx=0
  graphics.camy=0
  graphics.collock=false
  graphics.curcol=0
  
  fts={}
  for name,info in pairs(fonts) do
    fts[name]=love.graphics.newFont("assets/"..info[1],info[2])
  end
  graphics.fonts=fts
  
  init_sprite_mgr()
  
  --graphics.textdrk={[0]=1,0,1,1,2,1,5,13,2,4,9,3,1,1,2,5}
  graphics.textdrk={}
  for i=0,28 do
    graphics.textdrk[i] = sget(i, 0)
    c_drk[i] = sget(i, 0)
    c_lit[i] = sget(i, 2)
  end
end

function drawstep()
  predraw()
  _draw()
  flip()
end

function predraw()
  love.graphics.setCanvas(render_canvas)
end

function afterdraw()
  love.graphics.setCanvas()
  love.graphics.setColor(1,1,1,1)
  love.graphics.origin()
  love.graphics.draw(render_canvas,0,0,0,graphics.scrn_scalex,graphics.scrn_scaley)
end

function flip()
  afterdraw()
  love.graphics.present()
end


function camera(x,y)
  local x=x or 0
  local y=y or 0
 
  love.graphics.origin()
  love.graphics.translate(-x,-y)
  
  graphics.camx=x
  graphics.camy=y
end


function color(c)
  if graphics.collock then return end
 
  local col=palette_norm[palswaps[c]]
  love.graphics.setColor(col)
  graphics.curcol=c
  return col
end

function clip(x, y, w, h)
  love.graphics.setScissor(x, y, w, h)
end

function pal(c1,c2)
  if c1 then
    palswaps[c1]=c2
    
    if c1==graphics.curcol then
      color(graphics.curcol)
    end
  else
    local k=#palette
    
    for i=0,k-1 do
      palswaps[i]=i
    end
    
    if sprite then
      for i=0,k-1 do
        sprite.paltrsp[i]=false
      end
      sprite.paltrsp[25]=true
    end
    
    color(graphics.curcol)
  end
end


function cls(c)
  local c=c or 0
  love.graphics.clear(color(c))
end

function circ(x,y,r,c)
  if c then color(c) end
  love.graphics.circle("line",x,y,r)
end

function circfill(x,y,r,c)
  if c then color(c) end
  x,y=flr(x),flr(y)
  love.graphics.circle("fill",x,y,r)
end

function rect(x1,y1,x2,y2,c)
  if c then color(c) end
  
  x1,y1=flr(x1)+0.2,flr(y1)+0.2
  
  love.graphics.line(x1,y1,x1,y2)
  love.graphics.line(x2,y1,x2,y2)
  love.graphics.line(x1,y1,x2,y1)
  love.graphics.line(x1,y2,x2,y2)
end

function rectfill(x1,y1,x2,y2,c)
  if c then color(c) end
  love.graphics.rectangle("fill",x1,y1,x2-x1,y2-y1)
end

function line(x1,y1,x2,y2,c)
  if c then color(c) end
  love.graphics.line(x1,y1,x2,y2)
end

function lines(...) --might not work
  love.graphics.line({...})
end

function point(x,y,c)
  if c then color(c) end
  love.graphics.points(x,y)
end

function points(...)
  love.graphics.points({...})
end


function font(name)
  local font=graphics.fonts[name]
  love.graphics.setFont(font)
  graphics.curfont=font
end

castle_print = print
function print(str,x,y,c)
  if c then color(c) end
  love.graphics.print(str,x,y)
end

function super_print(str,x,y,c0,c1,c2)
  local c0=c0 or 25
  local c1=c1 or 21
  local c2=c2 or graphics.textdrk[c1]
  
  print(str,x,y-2,25)
  print(str,x-1,y-1,25)
  print(str,x+1,y-2,25)
  print(str,x+2,y-1,25)
  print(str,x-2,y,25)
  print(str,x+2,y,25)

  print(str,x,y+3,25)
  print(str,x-1,y+3,25)
  print(str,x-2,y+2,25)
  print(str,x+1,y+2,25)
  print(str,x-2,y+1,25)
  print(str,x+2,y+1,25)
  
  print(str,x-1,y+2,c2)
  print(str,x+1,y+1,c2)
  print(str,x,y+2,c2)
  
  print(str,x-1,y,c1)
  print(str,x+1,y,c1)
  print(str,x,y-1,c1)
  print(str,x,y+1,c1)
  
  print(str,x-1,y+1,c1)
  print(str,x+1,y-1,c1)
  
  print(str,x,y,c0)
end

function draw_text(str,x,y,al,c0,c1,c2)
  local al=al or 1
 
  if al==1 then x=x-graphics.curfont:getWidth(str)/2
  elseif al==2 then x=x-graphics.curfont:getWidth(str) end
  
  y = y - 4
  
  super_print(str,x,y,c0,c1,c2)
end

function str_width(str, fnt)
  if fnt then
    fnt = graphics.fonts[name]
  else
    fnt = graphics.curfont
  end
  
  return fnt:getWidth(str)
end


function draw_outline(draw,c,arg)
  local c=c or 25
  local camx,camy=graphics.camx,graphics.camy
  
  all_colors_to(c)
  --graphics.collock=true
  
  camera(camx-1,camy)
  draw(arg)
  camera(camx+1,camy)
  draw(arg)
  camera(camx,camy-1)
  draw(arg)
  camera(camx,camy+1)
  draw(arg)
  
  camera(camx,camy)
  all_colors_to()
  --graphics.collock=false
end

function all_colors_to(c)
  if c then
    for i=0,#palette-1 do
      pal(i,c)
    end
  else
    for i=0,#palette-1 do
      pal(i,i)
    end
  end
end

function apply_pal_map(map)
  for c1,c2 in pairs(map) do
    pal(c1,c2)
  end
end

function darker(c, n)
  if n<0 then
    return lighter(c, -n)
  end
  
  for i=1,n do
    c = c_drk[c]
  end
  
  return c
end

function lighter(c, n)
  if n<0 then
    return darker(c, -n)
  end

  for i=1,n do
    c = c_lit[c]
  end
  
  return c
end


function screen_size()
  return graphics.scrn_w,graphics.scrn_h
end

function screen_scale()
  return graphics.scrn_scalex,graphics.scrn_scaley
end


function new_surface(w,h)
  return love.graphics.newCanvas(w,h)
end

function draw_to(surf)
  surf=surf or render_canvas
  love.graphics.setCanvas(surf)
end

function surface_size(surf)
  return surf:getDimensions()
end

function draw_surface(surf,x,y,sx,sy,sw,sh)
  plt_shader()
  if sx then
    local quad=love.graphics.newQuad(sx,sy,sw,sh,surface_size(surf))
    love.graphics.draw(surf,quad,x,y)
  else
    love.graphics.draw(surf,x,y)
  end
  set_shader()
end


function plt_shader()
  set_shader("palswap")
  local ar={palette_norm[0],unpack(palette_norm)}-- add(ar,0)
  shader_send("opal",ar)
  ar={palswaps[0],unpack(palswaps)} add(ar,0)
  shader_send("swaps",ar)
  ar={}
  for i=0,#palette-1 do if sprite.paltrsp[i] then ar[i+1]=1 else ar[i+1]=0 end end
  add(ar,0)
-- ar={sprite.paltrsp[0],unpack(sprite.paltrsp)} add(ar,0)
  shader_send("trsps",ar)
end


function init_palette()
  palette = arcade29_palette()
  
  palette_norm = {}
  for i = 0,#palette-1 do
    local c = palette[i]
    local col = {}
    for j,v in ipairs(c) do
      col[j] = v/255
    end
    palette_norm[i] = col
  end
  
  palswaps={}
  for i=0,#palette do
    palswaps[i]=i
  end
end

function get_palette(norm)
  if norm then
    return palette_norm
  else
    return palette
  end
end

function pico8_palette()
  local p8pal={
[0]={0,0,0},
    {29,43,83},
    {126,37,83},
    {0,135,81},
    {171,82,54},
    {95,87,79},
    {194,195,199},
    {255,241,232},
    {255,0,77},
    {255,163,0},
    {255,236,39},
    {0,228,54},
    {41,173,255},
    {131,118,156},
    {255,119,168},
    {255,204,170}
  }
  
  return p8pal
end

function arcade29_palette()
  return {
[0]={255,77,77},
    {159,30,49},
    {255,196,56},
    {240,108,0},
    {241,194,132},
    {201,126,79},
    {151,63,63},
    {87,20,46},
    {114,203,37},
    {35,133,49},
    {10,75,77},
    {48,197,173},
    {47,126,131},
    {105,222,255},
    {51,165,255},
    {50,89,226},
    {40,35,123},
    {201,92,209},
    {108,52,157},
    {255,170,188},
    {229,93,172},
    {241,240,238},
    {150,165,171},
    {88,108,121},
    {42,55,71},
    {23,25,27},
    {185,165,136},
    {126,99,82},
    {65,47,47}
  }
end


function fullscreen()
  love.window.setFullscreen(not love.window.getFullscreen(),"desktop")
end

--function love.resize(w,h)
--  render_canvas=love.graphics.newCanvas(w,h)
--  render_canvas:setFilter("nearest","nearest")
--  local scx,scy=screen_scale()
--  
--  graphics.wind_w=w
--  graphics.wind_h=h
--  graphics.scrn_w=flr(w/scy)
--  graphics.scrn_h=flr(h/scx)
--end


function splash_screen()
  t=0
  local dog=get_dog()
  local scrnw,scrnh=screen_size()
   
  flip()
  camera(0)
  local introt=2.8
  while t<introt do
    predraw()
    
    t=t+0.01
    local kt=t*5
    
    camera(shkx,shky)
    
    color(0)

    -- clear outer screen surface
    rectfill(0, 0, scrnw/2-128+1, scrnh)
    rectfill(scrnw/2+128-1, 0, scrnw, scrnh)
    rectfill(scrnw/2-128, 0, scrnw/2+128, scrnh/2-128)
    rectfill(scrnw/2-128, scrnh/2+128, scrnw/2+128, scrnh)
    
    for i=0,3999 do
      local x,y=rnd(256),rnd(256)
      local sx,sy=flr(x/4),flr(y/4)
      
      local c=dog[sy*64+sx]
      
      if c~=7 or kt<1 then
        if c>=16-kt*2 then
          if rnd(2)<1 then
            c=drk[c]
          end
        else
          c=0
        end
      end
      
      local a=atan2(x-128,y-128)
      local l=rnd(8)
      
      x=x+scrnw/2-128+l*cos(a)
      y=y+scrnh/2-128+l*sin(a)
      color(c)
      points(x-1,y,x+1,y,x,y-1,x,y+1)
    end
    
    if kt>=6 then
     font("pico16")
     
     local c1,c2
     if kt<6.2 then
      c1=flr(t*50)%8+8
      c2=drk[c1]
     else
      c1,c2=7,13
     end
     
     draw_text("TRASEVOL_DOG",scrnw/2,scrnh/2+100,1,0,c1,c2)
     
     if kt>=7 then
      local c1,c2
      if kt<7.2 then
       c1=flr(t*50)%8+8
       c2=drk[c1]
      else
       c1,c2=7,13
      end
      draw_text("PRESENTS",scrnw/2,scrnh/2+124,1,0,c1,c2)
     end
    end
    
    if (kt%1<0.05 and kt<4) or (kt%0.5<0.05 and kt<4.5 and kt>1) then
     add_shake(48)
     sfx("dog")
    end
    
    if t>introt-0.2 then
     add_shake(32)
     sfx("dog")
    end
    
    flip()
    step()
    eventpump()
    update_shake()
  end
end

function get_dog()
  return {
    [0]=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,0,0,0,0,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,8,8,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,8,8,8,8,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,9,9,9,9,9,9,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,9,9,9,9,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,10,10,10,10,10,10,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,10,10,10,10,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,11,11,11,11,11,11,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,11,11,11,11,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,12,12,12,12,12,12,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,12,12,12,12,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,13,13,13,13,13,13,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,13,13,13,13,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,7,7,7,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,11,12,12,13,13,7,7,7,7,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,12,12,13,13,7,7,7,7,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,12,13,13,13,7,7,7,7,7,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,13,13,7,7,7,7,7,7,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,13,7,7,7,7,7,7,7,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,7,7,7,7,7,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,7,7,7,7,7,7,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,7,7,7,7,7,7,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,7,7,7,7,7,7,7,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,7,7,7,7,7,7,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,7,7,7,7,7,7,7,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,7,7,7,7,7,7,7,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,7,7,7,7,7,7,7,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,7,7,7,7,7,7,7,13,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,7,7,7,7,7,7,7,13,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,7,7,7,7,7,7,7,13,7,7,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,7,7,7,7,7,13,13,13,13,13,13,7,7,7,7,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,13,13,13,13,13,13,13,13,12,13,13,13,13,13,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,7,7,7,7,7,7,13,13,12,12,12,13,13,13,13,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,7,7,7,7,7,7,7,13,13,12,12,12,12,12,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,7,7,7,7,7,7,7,7,13,13,12,12,11,12,12,12,12,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,13,13,13,13,13,13,13,13,12,12,11,11,11,11,11,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,13,13,13,13,13,13,13,13,12,12,11,11,10,11,11,11,11,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,12,12,12,12,12,12,12,12,11,11,10,10,10,10,10,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,12,12,12,12,12,12,12,12,11,11,10,10,9,10,10,10,10,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,11,11,11,11,11,11,11,11,10,10,9,9,9,9,9,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,11,11,11,11,11,11,11,11,10,10,9,9,8,9,9,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,10,10,10,10,10,10,10,10,9,9,8,8,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,10,10,10,10,10,10,10,10,9,9,8,8,0,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,9,9,9,9,9,9,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,9,9,9,9,9,9,9,9,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,8,8,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,8,8,8,8,8,8,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  }
end

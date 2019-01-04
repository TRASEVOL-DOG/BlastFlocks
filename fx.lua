-- BLAST FLOCK source files
-- by TRASEVOL_DOG (https://trasevol.dog/)

require("drawing")
require("maths")
require("table")
require("object")
require("sprite")



function update_skull(s)
  s.t=s.t+0.01*dt30f
  
  if s.t>=0.230 then
    deregister_object(s)
  end
end

function update_scoretxt(s)
  s.t=s.t+1*dt30f
  if s.t>=48 then
    deregister_object(s)
  end
end

--function update_dgrpointer(s)
--  s.t=s.t+1*dt30f
--  
--  if s.t>=64 then
--    deregister_object(s)
--  end
--end

function update_screenglitch(s)
  s.t = s.t - delta_time
  if s.t<=0 then
    if rnd(30)<1 then
      s.x=s.x+rnd(64)-32
      s.y=s.y+rnd(64)-32
      s.c=8+flr(rnd(8))
    end
    
    if rnd(10)<1 then
      s.x=s.ox
      s.y=s.oy
    end
    delta_time = 0.033
  end
  
  s.w=s.w+2*dt30f
  s.h=s.h-6*dt30f
  
  if s.h<0 or s.w<0 then
    deregister_object(s)
  end
  
end

function update_smoke(s)
  s.x=s.x+s.vx*dt30f
  s.y=s.y+s.vy*dt30f
  
  s.vx=lerp(s.vx, 0,0.1*dt30f)
  s.vy=lerp(s.vy,-1,0.1*dt30f)
  
  s.r=s.r-0.05*dt30f
  if s.r<0 then
    deregister_object(s)
  end
end

function add_shake(p)
  local a=rnd(1)
  shkx=shkx+p*cos(a)
  shky=shky+p*sin(a)
end

shkt = 0
function update_shake()
  shkt = shkt - love.timer.getDelta()
  if shkt < 0 then
    if abs(shkx)<0.5 and abs(shky)<0.5 then
      shkx,shky=0,0
    end
    
    shkx=-(0.5+rnd(0.2))*shkx
    shky=-(0.5+rnd(0.2))*shky
    shkt = 0.033
  end
end


function draw_skull(s)
  draw_anim(s.x,s.y,"skull",nil,s.t)
end

function draw_scoretxt(s)
  local c = s.c
  local k=abs(flr(s.t/6)-5)
  local ca, cb = lighter(c, k), lighter(c, k-1)
  
  font("small")
  draw_text(s.txt,s.x,s.y-s.t,1, 25,ca, cb)
end

--function draw_dgrpointer(s) -- not displayed atm
--  if s.t%4>0 then return end
--  
--  local scrnw,scrnh=screen_size()
--  local x=clamp(s.x,xmod+16,xmod+scrnw-16)
--  local y=clamp(s.y,ymod+16,ymod+scrnh-16)
--  
--  font("pico2")
--  draw_text("!",x,y,1,0,8,2)
--end

function draw_explosion(s)
  local c=({25,25,21,21,21,21,21,s.c,s.c})[flr(s.p+dt30f)]
  local r=s.r+max(s.p-2,0)
  local foo
  if s.p<7 then foo=circfill
  else foo=circ end
  
  foo(s.x,s.y,r,c)
  
  if s.p==1 then
    if s.r>4 then
      for i=0,1 do
        local a,l=rnd(1),(0.8+rnd(0.4))*s.r
        local x = s.x + l*cos(a)
        local y = s.y + l*sin(a)
        --local x=s.x+rnd(2.2*s.r)-1.1*s.r
        --local y=s.y+rnd(2.2*s.r)-1.1*s.r
        local r=0.25*s.r+rnd(0.5*s.r)
        create_explosion(x,y,r,s.c)
      end
      
      for i=0,2 do
        create_smoke(s.x,s.y,1,nil,s.c)
      end
    end
  end
  
  s.p=s.p+1
  if s.p>=8 then
    deregister_object(s)
  end
end

function draw_smoke(s)
  if s.x+s.r<xmod or s.x-s.r>xmod+screen_width or s.y+s.r<ymod or s.y-s.r>ymod+screen_height then
    return
  end
  circfill(s.x,s.y,s.r,s.c)
end



function create_skull(x,y)
  if server_only then return end

  local s={
    x=x,
    y=y,
    t=0,
    update=update_skull,
    draw=draw_skull,
    regs={"to_update","to_draw4"}
  }
  
  register_object(s)
end

function create_scoretxt(x,y,amount,c)
  if server_only then return end

  local s={
    x=x,
    y=y,
    txt="+"..amount,
    t=t,
    c=c,
    update=update_scoretxt,
    draw=draw_scoretxt,
    regs={"to_update","to_draw3"}
  }
  
  register_object(s)
  
  return s
end

--function create_dgrpointer(x,y)
--  local s={
--    x=x,
--    y=y,
--    t=0,
--    update=update_dgrpointer,
--    draw=draw_dgrpointer,
--    regs={"to_update","to_draw3"}
--  }
--  
--  register_object(s)
--  
--  return s
--end

function create_screenglitch(w,h)
  if server_only then return end

  local scrnw,scrnh=screen_size()
  
  local s={
    x=xmod+rnd(scrnw),
    y=ymod+rnd(scrnh),
    w=0.75*w+rnd(0.5*w),
    h=0.75*h+rnd(0.5*h),
    c=8,
    t=0,
    update=update_screenglitch,
    regs={"to_update","screen_glitch"}
  }
  
  s.ox=s.x
  s.oy=s.y
  
  register_object(s)
  
  return s
end

function create_explosion(x,y,r,c)
  if server_only then return nil end

  local e={
    x=x,
    y=y,
    r=r,
    p=0,
    c=c,
    draw=draw_explosion,
    regs={"to_draw3"}
  }
  
  register_object(e)
  
  return e
end

function create_smoke(x,y,spd,r,c,a)
  if server_only then return nil end

  local a=a or rnd(1)
  local spd=0.75*spd+rnd(0.5*spd)
  
  local s={
    x=x,
    y=y,
    vx=spd*cos(a),
    vy=spd*sin(a),
    r=r or 1+rnd(3),
    c=c or 22,
    update=update_smoke,
    draw=draw_smoke,
    regs={"to_update","to_draw1"}
  }
  
  if rnd(2)<1 then s.c=drk[s.c] end
  
  register_object(s)
  
  return s
end



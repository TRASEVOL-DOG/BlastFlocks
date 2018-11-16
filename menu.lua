-- BLAST FLOCK source files - by TRASEVOL_DOG
-- /!\ do not redistribute /!\
-- Download game at trasevol-dog.itch.io/blast-flock
-- Ask questions to @TRASEVOL_DOG on Twitter
-- Support TRASEVOL_DOG on patreon.com/trasevol_dog

require("drawing")
require("maths")


function init_menu_system()
 if not define_menus then
  return
 end
 
 local l=define_menus()
 
 menus={}
 for n,m in pairs(l) do
  menus[n]=init_menu(m)
 end
 
 curmenu=nil
 prevmenus={}
 
 menuchange=0
end


function init_menu(l)
 local m={}

 local maxw=0
 local toth=0
 for o in all(l) do
  local n
  
  n={
   name=o[1],
   call=o[2],
   typ=o[3] or "button"
  }
  
  if n.typ=="button" then
   n.w=#n.name*8+8
   n.h=20
  elseif n.typ=="slider" then
   n.slidmax=o[4] or 1
   n.slidmin=o[5] or 0
   n.slidw=o[6] or 64
   n.slidv=n.call()
   n.w=max(#n.name*8+8,n.slidw+8)
   n.h=44
  end
  
  maxw=max(maxw,n.w+4)
  toth=toth+n.h
  add(m,n)
 end
 
 m.linespace=16
 
 m.h=toth+(#m-1)*m.linespace
 m.w=maxw+32
 m.chosen=nil
 
 return m
end

function update_menu(x,y)
 menuchange=max(menuchange-0.01,0)

 if not curmenu then return end
 m=menus[curmenu]

 local curx,cury=mouse_pos()
 
 if curx>x-m.w/2 and curx<x+m.w/2 and cury>y-m.h/2 and cury<y+m.h/2+m.linespace then
  local oy=y-m.h/2+8
  for o in all(m) do
   oy=oy+o.h+m.linespace
   if cury<oy then
    if m.chosen~=o then
     sfx("select")
    end
    m.chosen=o
    break
   end
  end
  
  if mouse_btn(0) and m.chosen and menuchange==0 then
   local o=m.chosen
   if o.typ=="button" and mouse_btnp(0) then
    sfx("confirm")
    o.call()
   elseif o.typ=="slider" then
    local v
    v=(curx-(x-o.slidw/2))/o.slidw
    v=v*(o.slidmax-o.slidmin)+o.slidmin
    v=clamp(v,o.slidmin,o.slidmax)
    v=round(v)
    
    if v~=o.slidv or mouse_btnp(0) then
     sfx("slider")
    end
    
    o.call(v)
    o.slidv=v
   end  
  end
 end
end

function draw_menu(x,y)
 if not curmenu then return end
 m=menus[curmenu]

 y=y-m.h/2
 
 font("pico16")
 for i,o in ipairs(m) do
  ofx=16*cos(t*0.5+i*0.1)
 
  if o.typ=="button" then
   draw_text(o.name,x+ofx,y+o.h*0.5-1)
  elseif o.typ=="slider" then
   draw_text(o.name,x+ofx,y+o.h*0.25-1)
   
   local x1,x2,y=x-o.slidw/2,x+o.slidw/2,y+o.h*0.95
   rect(x1-1,y-2.5,x2+1,y+1,0)
   line(x1,y-1,x2,y-1,7)
   line(x1,y,x2,y,13)
   
   local x=x1+(o.slidv/(o.slidmax-o.slidmin))*o.slidw
   local r=4
   circfill(x,y-2,r,0)
   circfill(x,y+1,r,0)
   circfill(x-1,y-1,r,0)
   circfill(x+1,y-1,r,0)
   circfill(x-1,y,r,0)
   circfill(x+1,y,r,0)
   circfill(x,y,r,13)
   circfill(x,y-1,r,7)
   
   font("pico")
   draw_text(o.slidv,x,y-13)
   font("pico16")
  end
  
  if o==m.chosen then
   local x1,y1,x2,y2=x-m.w/2-1,y,x+m.w/2,y+o.h+6
   rect(x1,y1+1,x2,y2+1,13)
   rect(x1,y1,x2,y2,7)
   rect(x1-1,y1-1,x2+1,y2+2,0)
   rect(x1+1,y1+2,x2-1,y2-1,0)
  end
  
  y=y+o.h+m.linespace
 end
 font("pico")
end


function menu(name)
 if curmenu then
  add(prevmenus,curmenu)
 end
 
 curmenu=name
 menuchange=0.1
end

function menu_back()
 if #prevmenus>0 then
  curmenu=prevmenus[#prevmenus]
  del(prevmenus,curmenu)
 else
  curmenu=nil
 end
end


function menu_height()
 return menus[curmenu].h
end
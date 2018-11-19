-- BLAST FLOCK source files
-- by TRASEVOL_DOG (https://trasevol.dog/)

require("maths")
require("shader")
require("drawing")

function init_sprite_mgr()
  local files={
    "assets/sheet.png",
    "assets/blastflock.png"
  }
  
  local anim_info={
    ship={
      rotate={
        sheet=0,
        dt=1/14,
        sprites={19,18,17,16,16,17,18,19,18,17,16,16,17,18}
      },
      fire={
        sheet=0,
        dt=0.02,
        sprites={32,33,34,35},
        cx=7,
        cy=3
      },
      bfire={
        sheet=0,
        dt=0.02,
        sprites={48,49,50,51},
        cx=7,
        cy=3
      }
    },
    bigship={
      rotate={
        sheet=0,
        dt=1/22,
        w=2,
        h=2,
        sprites={74,72,70,68,66,64,64,66,68,70,72,74,72,70,68,66,64,64,66,68,70,72}
      },
      fire={
        sheet=0,
        dt=0.02,
        sprites={40,41,42,43},
        cx=7,
        cy=3
      },
      bfire={
        sheet=0,
        dt=0.02,
        sprites={56,57,58,59},
        cx=7,
        cy=3
      }
    },
    helixship={
      only={
        sheet=0,
        dt=0.02,
        w=8,
        h=4,
        cx=32,
        cy=22,
        sprites={128,136}
      }
    },
    skull={
      only={
        sheet=0,
        dt=0.04,
        w=2,
        h=2,
        cx=8,
        cy=8,
        sprites={96,104,96,104,96,98,100,102}
      }
    }
  }

  sprite={}
  init_spritesheets(files)
  init_anims(anim_info)
 
  sprite.paltrsp={}
  for i=1,#palette do
    sprite.paltrsp[i]=false
  end
  sprite.paltrsp[0]=true
end


function palt(c,trsp)
  sprite.paltrsp[c]=trsp
end


function spr(s,sheet,x,y,w,h,r,flipx,flipy,cx,cy)
  local sheet=sheet or 0
  local w=w or 1
  local h=h or 1
  local r=r or 0
  local flipx=flipx and -1 or 1
  local flipy=flipy and -1 or 1
  local cx=cx or w*4
  local cy=cy or h*4
  
  local sheet=sprite.sheets[sheet]
  
  local sx=s%16*8
  local sy=flr(s/16)*8
  
  local quad=love.graphics.newQuad(sx,sy,w*8,h*8,sheet:getDimensions())
  
  plt_shader()
  love.graphics.draw(sheet,quad,x,y,r*2*math.pi,flipx,flipy,cx,cy)
  set_shader()
end

function draw_anim(x,y,object,state,t,r,flipx,flipy)
  local state=state or "only"
  local flipx=flipx and -1 or 1
  local flipy=flipy and -1 or 1
  local r=r or 0
  local info=sprite.anims[object][state]
  
  local quad=info.quads[flr(t/info.dt)%#info.quads+1]
  
  plt_shader()
  love.graphics.draw(info.sheet,quad,x,y,r*2*math.pi,flipx,flipy,info.cx,info.cy)
  set_shader()
end


function init_spritesheets(files)
  sprite.sheets={}
  
  for i,file in ipairs(files) do
    sprite.sheets[i-1]=love.graphics.newImage(file)
  end
end

function init_anims(anim_info)
  local anims={}
  
  for onam,o in pairs(anim_info) do
    local ob={}
    for name,state in pairs(o) do
      local a={}
      a.sheet=sprite.sheets[state.sheet]
      a.dt=state.dt
      
      a.w=(state.w or 1)*8
      a.h=(state.h or 1)*8
      
      a.cx=state.cx or a.w/2
      a.cy=state.cy or a.h/2
      
      local shtw,shth=a.sheet:getDimensions()
      
      local q={}
      for s in all(state.sprites) do
        local sx=s%16*8
        local sy=flr(s/16)*8
        local sw=a.w
        local sh=a.h
        
        add(q,love.graphics.newQuad(sx,sy,sw,sh,shtw,shth))
      end
      
      a.quads=q
      
      ob[name]=a
    end
    
    anims[onam]=ob
  end
  
  sprite.anims=anims
end

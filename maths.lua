-- BLAST FLOCK source files
-- by TRASEVOL_DOG (https://trasevol.dog/)


function dist(x1,y1,x2,y2)
  local x,y
  if x2 then
    x=x2-x1
    y=y2-y1
  else
    x=x1
    y=y1
  end
  
  return sqrt(sqrdist(x,y))
end

function sqrdist(x,y)
  return sqr(x)+sqr(y)
end


function angle_diff(a1,a2)
  local a=a2-a1
  return (a+0.5)%1-0.5
end


function rrng() return love.math.newRandomGenerator() end
function rsrand(rng,k) rng:setSeed(k) end
function rrnd(rng,k) return rng:random()*k end
function rirnd(rng,k) return rng:random(k) end

local rng = love.math.newRandomGenerator()
--function lrng() return love.math.newRandomGenerator() end
function lsrand(k) rng:setSeed(k) end
function lrnd(k) return rng:random()*k end
function lirnd(k) return rng:random(k) end


function round(a) return flr(a+0.5) end
function sgn(a) return a>0 and 1 or a<0 and -1 or 0 end

function clamp(a,mi,ma) if a<mi then return mi elseif a>ma then return ma else return a end end
function lerp(a,b,i) return (1-i)*a+i*b end

function sqr(a) return a*a end

function rnd(a) return love.math.random()*a end
function irnd(a) return love.math.random(a) end
function srand(k,rng) love.math.setRandomSeed(k) end

function cos(a) return math.cos(a*2*math.pi) end
function sin(a) return math.sin(a*2*math.pi) end
function atan2(x,y) return math.atan2(y,x)/(2*math.pi) end

--cos=math.cos
--sin=math.sin
--atan2=math.atan2
flr=math.floor
ceil=math.ceil
abs=math.abs
sqrt=math.sqrt
min=math.min
max=math.max

function mid(a, b, c)
  if a>b then
    a,b = b,a
  end
  
  if b>c then
    b,c = c,b
  end
  
  if a>b then
    a,b = b,a
  end
  
  return b
end
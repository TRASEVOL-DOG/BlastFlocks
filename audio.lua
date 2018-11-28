-- BLAST FLOCK source files
-- by TRASEVOL_DOG (https://trasevol.dog/)

function init_audio()
  local music_list={
    title= "order.ogg",
    game=  "steelandorder.ogg"
  }
 
  local sfx_list={
    shootorder= "shootorder.ogg",
    shoot=           "shoot.ogg",
    enemyshoot=  "enemshoot.ogg",
    boost=           "boost.ogg",
    helix=           "helix.ogg",
    hole=             "hole.ogg",
    levelup=       "levelup.ogg",
    boom1=           "boom1.ogg",
    boom2=           "boom2.ogg",
    boom3=           "boom3.ogg",
    scrap=           "scrap.ogg",
    save=             "save.ogg",
    gameover=     "gameover.ogg",
    select=         "select.ogg",
    confirm=       "confirm.ogg",
    slider=      "sliderset.ogg",
    dog=               "dog.ogg"
  }
  
  musics={}
  sfxs={}
   
  for n,f in pairs(music_list) do
    musics[n]=love.audio.newSource("assets/"..f,"stream")
    musics[n]:setLooping(true)
  end
  for n,f in pairs(sfx_list) do
    sfxs[n]=love.audio.newSource("assets/sfx/"..f,"static")
  end
 
  --sfx_vol=100
  --music_vol=0--100
  --master_vol=100
  
  sfx_volume(100)
  music_volume(0)
  master_volume(100)
  
  curmusic=nil
end


function sfx(name,x,y,pitch)
  local s=sfxs[name]
  local x,y=x or 0, y or 0
  local k=200
  x,y=(x-cam.x)/k,(y-cam.y)/k
  
  if pitch then
    s:setPitch(pitch)
  end
  
  s:setPosition(x,y,1)
  
  if s:isPlaying() then
    s:seek(0)
  else
    s:play()
  end
end

function music(name)
  if curmusic then
    musics[curmusic]:stop()
  end
  
  curmusic=name
  
  if not name then
    return
  end
  
  love.audio.play(musics[name])
end

function listener(x,y)
  love.audio.setPosition(x,y)
end

function sfx_volume(v)
  if not v then
    return sfx_vol
  end
  
  for n,s in pairs(sfxs) do
    s:setVolume(v/100)
  end
  
  sfx_vol=v
end

function music_volume(v)
  if not v then
    return music_vol
  end
  
  for n,m in pairs(musics) do
    m:setVolume(v/100)
  end
  
  music_vol=v
end

function master_volume(v)
  if not v then
    return master_vol
  end
  
  love.audio.setVolume(v/100)
  
  master_vol=v
end
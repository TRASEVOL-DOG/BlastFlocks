-- BLAST FLOCK source files - by TRASEVOL_DOG
-- /!\ do not redistribute /!\
-- Download game at trasevol-dog.itch.io/blast-flock
-- Ask questions to @TRASEVOL_DOG on Twitter
-- Support TRASEVOL_DOG on patreon.com/trasevol_dog


function init_audio()

 local music_list={
  title="order.mp3",
  game= "steelandorder.mp3"
 }

 local sfx_list={
  shootorder= "shootorder.wav",
  shoot=      "shoot.wav",
  enemyshoot= "enemshoot.wav",
  boost=      "boost.wav",
  helix=      "helix.wav",
  hole=       "hole.wav",
  levelup=    "levelup.wav",
  boom1=      "boom1.wav",
  boom2=      "boom2.wav",
  boom3=      "boom3.wav",
  scrap=      "scrap.wav",
  save=       "save.wav",
  gameover=   "gameover.wav",
  select=     "select.wav",
  confirm=    "confirm.wav",
  slider=     "sliderset.wav",
  dog=        "dog.wav"
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

 
 sfx_vol=100
 music_vol=100
 master_vol=100
 
 curmusic=nil
end


function sfx(name,x,y,pitch)
 if true then return end

 local s=sfxs[name]
 local x,y=x or 0, y or 0
 local k=200
 x,y=(x-cam.x)/k,(y-cam.y)/k
 
 if pitch then
  s:setPitch(pitch)
 end
 
 s:setPosition(x,y,1)
 
 if s:isPlaying() then
  s:rewind()
 else
  s:play()
 end
end

function music(name)
 if true then return end

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
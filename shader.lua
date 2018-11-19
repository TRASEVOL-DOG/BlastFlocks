-- BLAST FLOCK source files
-- by TRASEVOL_DOG (https://trasevol.dog/)


function init_shader_mgr()
  local shads={
    palswap="palswap.shader"
  }
  
  shaders={}
  current_shader=nil
  for name,shader in pairs(shads) do
    shaders[name]=love.graphics.newShader(shader)
  end
end

function set_shader(name)
  if name then
    local shd=shaders[name]
    love.graphics.setShader(shaders[name])
    current_shader=shd
  else
    love.graphics.setShader()
  end
end

function shader_send(attri,...)
  if current_shader then
    current_shader:send(attri,unpack(...))
  end
end

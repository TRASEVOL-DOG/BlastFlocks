-- BLAST FLOCK source files - by TRASEVOL_DOG
-- /!\ do not redistribute /!\
-- Download game at trasevol-dog.itch.io/blast-flock
-- Ask questions to @TRASEVOL_DOG on Twitter
-- Support TRASEVOL_DOG on patreon.com/trasevol_dog

require("ttable")

function init_object_mgr(...)
 objs={
  to_update={},
  to_draw0={},
  to_draw1={},
  to_draw2={},
  to_draw3={},
  to_draw4={}
 }
 
 local args={...}
 for v in all(args) do
  objs[v]={}
 end
end


--collision stuff
function collide_objgroup(obj,group)
 for obj2 in all(objs[group]) do
  if obj2~=obj then
   local bl=collide_objobj(obj,obj2)
   if bl then
    return obj2
   end
  end
 end

 return false
end

function collide_objobj(obj1,obj2)
 return (abs(obj1.x-obj2.x)<(obj1.w+obj2.w)/2
     and abs(obj1.y-obj2.y)<(obj1.h+obj2.h)/2)
end


--object managing
function update_objects(dt)
 local uobjs=objs.to_update
 
 for obj in all(uobjs) do
  obj:update(dt)
 end
end

function draw_objects()
 for i=0,4 do
  local dobjs=objs["to_draw"..i]
 
  --sorting objects by depth
  --[[ not today tho
  TODO: reimplement this with sort function
  ]]
 
  --actually drawing
  for obj in all(dobjs) do
   obj:draw()
  end
 end
end


function register_object(o)
 for reg in all(o.regs) do
  add(objs[reg],o)
 end
end

function deregister_object(o)
 for reg in all(o.regs) do
  del(objs[reg],o)
 end
end

function group_add(group,o)
 add(o.regs,group)
 add(objs[group],o)
end

function group_del(group,o)
 del(o.regs,group)
 del(objs[group],o)
end

function clear_group(group)
 objs[group]={}
end

function clear_all_groups()
 for n,v in pairs(objs) do
  clear_group(n)
 end
end

function group(name) return all(objs[name]) end
function group_size(name) return #objs[name] end
function group_member(grp,pos) return objs[grp][pos] end



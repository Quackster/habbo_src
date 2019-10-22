on select me 
  tPostItMgr = getObject(#postit_manager)
  if (tPostItMgr = 0) then
    tPostItMgr = createObject(#postit_manager, "PostIt Manager Class")
  end if
  if (me.getSprites().count = 0) then
    return(tPostItMgr.open(me.getID(), rgb(string(me.pType)), 200, 200))
  end if
  tloc = me.getSprites().getAt(1).loc
  tPostItMgr.open(me.getID(), rgb(string(me.pType)), tloc.getAt(1), tloc.getAt(2))
  return FALSE
end

on setColor me, tColor 
  if (me.getSprites().count = 0) then
    return TRUE
  end if
  me.getSprites().getAt(1).bgColor = tColor
  me.pType = tColor.hexString()
  return TRUE
end

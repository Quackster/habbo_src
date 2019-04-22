on select me 
  tPostItMgr = getObject(#postit_manager)
  if tPostItMgr = 0 then
    tPostItMgr = createObject(#postit_manager, "PostIt Manager Class")
  end if
  tloc = me.getSprites().getAt(1).loc
  tPostItMgr.open(me.getID(), rgb(string(me.pType)), tloc.getAt(1), tloc.getAt(2))
  return(0)
end

on setColor me, tColor 
  me.getSprites().getAt(1).bgColor = tColor
  me.pType = tColor.hexString()
end

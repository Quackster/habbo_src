on select me
  tPostItMgr = getObject(#postit_manager)
  if tPostItMgr = 0 then
    tPostItMgr = createObject(#postit_manager, "PostIt Manager Class")
  end if
  if me.getSprites().count = 0 then
    return tPostItMgr.open(me.getID(), rgb(string(me.pType)), 200, 200)
  end if
  tloc = me.getSprites()[1].loc
  tPostItMgr.open(me.getID(), rgb(string(me.pType)), tloc[1], tloc[2])
  return 0
end

on setColor me, tColor
  if me.getSprites().count = 0 then
    return 1
  end if
  me.getSprites()[1].bgColor = tColor
  me.pType = tColor.hexString()
  return 1
end

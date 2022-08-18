on prepare me, tdata 
  if (tdata.count = 0) then
    tdata = ["foo":"5"]
  end if
  me.updateStuffdata("fill", tdata.getAt(1))
  return TRUE
end

on updateStuffdata me, tProp, tValue 
  tMemName = me.getPropRef(#pSprList, 2).member.name
  me.getPropRef(#pSprList, 2).member = member(getmemnum(tMemName.getProp(#char, 1, (length(tMemName) - 1)) & tValue))
  me.getPropRef(#pSprList, 2).width = me.getPropRef(#pSprList, 2).member.width
  me.getPropRef(#pSprList, 2).height = me.getPropRef(#pSprList, 2).member.height
end

on select me 
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/FILL/1")
  end if
  return TRUE
end

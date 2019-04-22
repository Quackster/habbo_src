on prepare me, tdata 
  if tdata.count = 0 then
    tdata = ["foo":"5"]
  end if
  me.updateStuffdata("fill", tdata.getAt(1))
  return(1)
end

on updateStuffdata me, tProp, tValue 
  tMemName = member.name
  me.getPropRef(#pSprList, 2).member = member(getmemnum(tMemName.getProp(#char, 1, length(tMemName) - 1) & tValue))
  me.getPropRef(#pSprList, 2).width = member.width
  me.getPropRef(#pSprList, 2).height = member.height
end

on select me 
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/FILL/1")
  end if
  return(1)
end

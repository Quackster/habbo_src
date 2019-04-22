on prepare me, tdata 
  if tdata.count = 0 then
    tdata = [#extra:"1"]
  end if
  me.updateStuffdata(tdata.getAt(#extra))
  return(1)
end

on updateStuffdata me, tValue 
  if me.count(#pSprList) < 2 then
    return(0)
  end if
  tMemName = member.name
  me.getPropRef(#pSprList, 2).member = member(getmemnum(tMemName.getProp(#char, 1, length(tMemName) - 1) & tValue))
  me.getPropRef(#pSprList, 2).width = member.width
  me.getPropRef(#pSprList, 2).height = member.height
end

on select me 
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer:integer(me.getID()), #integer:0])
  end if
  return(1)
end

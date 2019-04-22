on prepare(me, tdata)
  if tdata.count = 0 then
    tdata = [#extra:"1"]
  end if
  me.updateStuffdata(tdata.getAt(#extra))
  return(1)
  exit
end

on updateStuffdata(me, tValue)
  if me.count(#pSprList) < 2 then
    return(0)
  end if
  tMemName = undefined.name
  me.getPropRef(#pSprList, 2).member = member(getmemnum(tMemName.getProp(#char, 1, length(tMemName) - 1) & tValue))
  me.getPropRef(#pSprList, 2).width = undefined.width
  me.getPropRef(#pSprList, 2).height = undefined.height
  exit
end

on select(me)
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:"5"])
  end if
  return(1)
  exit
end
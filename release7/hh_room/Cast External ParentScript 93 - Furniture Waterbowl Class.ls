on prepare me, tdata
  if tdata.count = 0 then
    tdata = ["foo": "5"]
  end if
  me.updateStuffdata("fill", tdata[1])
  return 1
end

on updateStuffdata me, tProp, tValue
  tMemName = me.pSprList[2].member.name
  me.pSprList[2].member = member(getmemnum(tMemName.char[1..length(tMemName) - 1] & tValue))
  me.pSprList[2].width = me.pSprList[2].member.width
  me.pSprList[2].height = me.pSprList[2].member.height
end

on select me
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/FILL/1")
  end if
  return 1
end

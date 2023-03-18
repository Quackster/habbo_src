on prepare me, tdata
  if tdata.count = 0 then
    tdata = [#extra: "1"]
  end if
  me.updateStuffdata(tdata[#extra])
  return 1
end

on updateStuffdata me, tValue
  if me.pSprList.count < 2 then
    return 0
  end if
  tMemName = me.pSprList[2].member.name
  me.pSprList[2].member = member(getmemnum(tMemName.char[1..length(tMemName) - 1] & tValue))
  me.pSprList[2].width = me.pSprList[2].member.width
  me.pSprList[2].height = me.pSprList[2].member.height
end

on select me
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: "5"])
  end if
  return 1
end

on prepare me, tdata
  if tdata.count = 0 then
    tdata = [#extra: "0"]
  end if
  return me.updateStuffdata(tdata[#extra])
end

on updateStuffdata me, tValue
  tCount = integer(tValue)
  if not ilk(tCount, #integer) then
    tCount = 0
  end if
  repeat with i = 1 to me.pSprList.count
    tMemName = me.pSprList[i].member.name
    delete char -30000 of tMemName
    me.pSprList[i].member = member(getmemnum(tMemName & tCount))
    me.pSprList[i].width = me.pSprList[i].member.width
    me.pSprList[i].height = me.pSprList[i].member.height
  end repeat
  return 1
end

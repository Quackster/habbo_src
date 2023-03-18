property pState

on prepare me, tdata
  me.setState(tdata[#stuffdata])
  return 1
end

on updateStuffdata me, tValue
  me.setState(tValue)
end

on setState me, tValue
  tValue = integer(tValue)
  if me.pSprList.count < 3 then
    return 0
  end if
  pState = tValue
  case tValue of
    0:
      me.switchMember("c", "0")
      me.pSprList[3].visible = 1
    1:
      me.switchMember("c", "1")
      me.pSprList[3].visible = 1
    otherwise:
      me.pSprList[3].visible = 0
  end case
  return 1
end

on switchMember me, tPart, tNewMem
  tSprNum = ["a", "b", "c", "d", "e", "f"].getPos(tPart)
  if (me.pSprList.count < tSprNum) or (tSprNum = 0) then
    return 0
  end if
  tName = me.pSprList[tSprNum].member.name
  tName = tName.char[1..tName.length - 1] & tNewMem
  if memberExists(tName) then
    tmember = member(getmemnum(tName))
    me.pSprList[tSprNum].castNum = tmember.number
    me.pSprList[tSprNum].width = tmember.width
    me.pSprList[tSprNum].height = tmember.height
  end if
  return 1
end

on select me
  if the doubleClick then
    tUserObj = getThread(#room).getComponent().getOwnUser()
    if not tUserObj then
      return 1
    end if
    if (abs(tUserObj.pLocX - me.pLocX) > 1) or (abs(tUserObj.pLocY - me.pLocY) > 1) then
      return 1
    end if
    getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer: integer(me.getID()), #integer: 0])
  end if
  return 1
end

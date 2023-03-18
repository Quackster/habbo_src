property pState, pFrame, pLastUpdate

on deconstruct me
  repeat with tSpr in me.pSprList
    releaseSprite(tSpr.spriteNum)
  end repeat
  me.pSprList = []
  pState = 3
  return 1
end

on prepare me, tdata
  tValue = integer(tdata[#stuffdata])
  if tValue = 0 then
    me.setOff()
  else
    me.setOn()
  end if
  pFrame = 0
  pLastUpdate = the milliSeconds
  return 1
end

on updateStuffdata me, tValue
  pFrame = 0
  pLastUpdate = the milliSeconds
  tValue = integer(tValue)
  if tValue = 0 then
    me.setOff()
  else
    me.setOn()
  end if
end

on update me
  if the milliSeconds < pLastUpdate then
    return 
  end if
  if me.pSprList.count < 2 then
    return 0
  end if
  if pState = 1 then
    tAnim = [0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 3, 3, 3, 2, 3, 2, 3, 3, 1, 0]
    pFrame = pFrame + 1
    if pFrame > tAnim.count then
      pFrame = 1
    end if
    tName = me.pSprList[2].member.name
    if tName <> EMPTY then
      tmember = member(getmemnum(tName.char[1..length(tName) - 1] & tAnim[pFrame]))
      me.pSprList[2].castNum = tmember.number
      me.pSprList[2].width = tmember.width
      me.pSprList[2].height = tmember.height
      if pFrame = tAnim.count then
        pLastUpdate = the milliSeconds + 4000
      else
        pLastUpdate = the milliSeconds + 100
      end if
    end if
  else
    if pState = 2 then
      pState = 3
      pFrame = 0
      tName = me.pSprList[2].member.name
      if tName <> EMPTY then
        tmember = member(getmemnum(tName.char[1..length(tName) - 1] & pFrame))
        me.pSprList[2].castNum = tmember.number
        me.pSprList[2].width = tmember.width
        me.pSprList[2].height = tmember.height
      end if
    end if
  end if
end

on setOn me
  pState = 1
end

on setOff me
  pState = 2
end

on select me
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer: integer(me.getID()), #integer: 0])
  end if
end

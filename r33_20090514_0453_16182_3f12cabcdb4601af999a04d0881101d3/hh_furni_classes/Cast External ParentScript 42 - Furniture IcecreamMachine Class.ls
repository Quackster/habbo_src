property pActive, pSync, pAnimFrame, pLastDir, pUserClicked

on prepare me, tdata
  pUserClicked = 0
  pLastDir = -1
  pSync = 0
  return 1
end

on updateStuffdata me, tValue
  tValue = integer(tValue)
  if tValue <> 0 then
    pAnimFrame = 1
    pActive = 1
  else
    me.switchMember("d", "0")
    pAnimFrame = 0
    pActive = 0
  end if
end

on update me
  if pActive then
    pSync = pSync + 1
    if pSync < 3 then
      return 1
    end if
    pSync = 0
    if me.pSprList.count < 5 then
      return 0
    end if
    if pAnimFrame > 0 then
      case pAnimFrame of
        1:
          me.switchMember("a", "1")
        2:
          me.switchMember("d", "1")
        3:
          me.switchMember("d", "2")
        4:
          me.switchMember("d", "3")
        5:
          me.switchMember("d", "4")
        6:
          me.switchMember("d", "5")
        7:
          me.switchMember("a", "0")
        8:
        9:
          me.switchMember("d", "6")
      end case
      pAnimFrame = pAnimFrame + 1
    end if
  end if
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
end

on select me
  tUserObj = getThread(#room).getComponent().getOwnUser()
  if tUserObj = 0 then
    return 1
  end if
  tCarrying = tUserObj.getProperty(#carrying)
  tloc = tUserObj.getProperty(#loc)
  tLocX = tloc[1]
  tLocY = tloc[2]
  case me.pDirection[1] of
    4:
      if (me.pLocX = tLocX) and ((me.pLocY - tLocY) = -1) then
        if the doubleClick and not tCarrying then
          me.setAnimation()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer: me.pLocX, #integer: me.pLocY + 1])
      end if
    0:
      if (me.pLocX = tLocX) and ((me.pLocY - tLocY) = 1) then
        if the doubleClick and not tCarrying then
          me.setAnimation()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer: me.pLocX, #integer: me.pLocY - 1])
      end if
    2:
      if (me.pLocY = tLocY) and ((me.pLocX - tLocX) = -1) then
        if the doubleClick and not tCarrying then
          me.setAnimation()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer: me.pLocX + 1, #integer: me.pLocY])
      end if
    6:
      if (me.pLocY = tLocY) and ((me.pLocX - tLocX) = 1) then
        if the doubleClick and not tCarrying then
          me.setAnimation()
        end if
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#integer: me.pLocX - 1, #integer: me.pLocY])
      end if
  end case
  return 1
end

on setAnimation me
  if pActive = 1 then
    return 1
  end if
  pUserClicked = 1
  tConnection = getThread(#room).getComponent().getRoomConnection()
  if tConnection = 0 then
    return 0
  end if
  tConnection.send("USEFURNITURE", [#integer: integer(me.getID()), #integer: 0])
end

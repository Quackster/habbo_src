property pChanges, pActive

on prepare me, tdata
  tValue = integer(tdata[#stuffdata])
  if tValue = 0 then
    me.setOff()
    pChanges = 0
  else
    me.setOn()
    pChanges = 1
  end if
  repeat with tLayer = 1 to me.pSprList.count
    tLayerName = numToChar(charToNum("a") + tLayer - 1)
    tSpr = me.pSprList[tLayer]
    if me.solveTransparency(tLayerName) then
      removeEventBroker(tSpr.spriteNum)
    end if
  end repeat
  return 1
end

on updateStuffdata me, tValue
  tValue = integer(tValue)
  if tValue = 0 then
    me.setOff()
  else
    me.setOn()
  end if
  pChanges = 1
end

on update me
  if not pChanges then
    return 
  end if
  if me.pSprList.count < 2 then
    return 
  end if
  tDirection = 0
  if me.pDirection.count > 0 then
    tDirection = me.pDirection[1]
  end if
  tIsGateSprite = []
  tScreenLocs = getThread(#room).getInterface().getGeometry().getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  repeat with i = 1 to me.pSprList.count
    tCurName = me.pSprList[i].member.name
    tNewName = tCurName.char[1..length(tCurName) - 1] & pActive
    tNewNameReal = tNewName.char[1..tNewName.length - 3] & tDirection & "_" & pActive
    tMemNum = getmemnum(tNewNameReal)
    tRealMem = 1
    if tMemNum = 0 then
      tMemNum = getmemnum(tNewName)
      tRealMem = 0
    end if
    if abs(tMemNum) > 0 then
      tmember = member(abs(tMemNum))
      me.pSprList[i].castNum = abs(tMemNum)
      me.pSprList[i].width = tmember.width
      me.pSprList[i].height = tmember.height
      if tRealMem then
        me.pSprList[i].locH = tScreenLocs[1]
        me.pSprList[i].locV = tScreenLocs[2]
        if tMemNum < 0 then
          me.pSprList[i].rotation = 180
          me.pSprList[i].skew = 180
          me.pSprList[i].locH = me.pSprList[i].locH + me.pXFactor
        else
          me.pSprList[i].rotation = 0
          me.pSprList[i].skew = 0
        end if
      end if
      if pActive then
        tIsGateSprite.append(i)
      end if
    end if
  end repeat
  tlocz = me.pLoczList[1][tDirection + 1]
  tSpriteLocZ = me.pSprList[1].locZ
  repeat with i = 2 to me.pSprList.count
    me.pSprList[i].locZ = tSpriteLocZ + (me.pLoczList[i][tDirection + 1] - tlocz)
  end repeat
  pChanges = 0
end

on setOn me
  pActive = 1
end

on setOff me
  pActive = 0
end

on select me
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer: integer(me.getID()), #integer: 0])
  end if
  return 1
end

on solveTransparency me, tPart
  tName = me.pClass
  if me.pXFactor = 32 then
    tName = "s_" & tName
  end if
  if memberExists(tName & ".props") then
    tPropList = value(member(getmemnum(tName & ".props")).text)
    if ilk(tPropList) <> #propList then
      error(me, tName & ".props is not valid!", #solveInk, #minor)
    else
      if tPropList[tPart] <> VOID then
        if tPropList[tPart][#transparent] <> VOID then
          return tPropList[tPart][#transparent]
        end if
      end if
    end if
  end if
  return 0
end

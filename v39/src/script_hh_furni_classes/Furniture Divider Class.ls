on prepare(me, tdata)
  tValue = integer(tdata.getAt(#stuffdata))
  if tValue = 0 then
    me.setOff()
    pChanges = 0
  else
    me.setOn()
    pChanges = 1
  end if
  tLayer = 1
  repeat while tLayer <= me.count(#pSprList)
    tLayerName = numToChar(charToNum("a") + tLayer - 1)
    tSpr = pSprList.getAt(tLayer)
    if me.solveTransparency(tLayerName) then
      removeEventBroker(tSpr.spriteNum)
    end if
    tLayer = 1 + tLayer
  end repeat
  return(1)
  exit
end

on updateStuffdata(me, tValue)
  tValue = integer(tValue)
  if tValue = 0 then
    me.setOff()
  else
    me.setOn()
  end if
  pChanges = 1
  exit
end

on update(me)
  if not pChanges then
    return()
  end if
  if me.count(#pSprList) < 2 then
    return()
  end if
  tDirection = 0
  if me.count(#pDirection) > 0 then
    tDirection = me.getProp(#pDirection, 1)
  end if
  tIsGateSprite = []
  tScreenLocs = getThread(#room).getInterface().getGeometry().getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  i = 1
  repeat while i <= me.count(#pSprList)
    tCurName = member.name
    tNewName = tCurName.getProp(#char, 1, length(tCurName) - 1) & pActive
    tNewNameReal = tNewName.getProp(#char, 1, tNewName.length - 3) & tDirection & "_" & pActive
    tMemNum = getmemnum(tNewNameReal)
    tRealMem = 1
    if tMemNum = 0 then
      tMemNum = getmemnum(tNewName)
      tRealMem = 0
    end if
    if abs(tMemNum) > 0 then
      tmember = member(abs(tMemNum))
      me.getPropRef(#pSprList, i).castNum = abs(tMemNum)
      me.getPropRef(#pSprList, i).width = tmember.width
      me.getPropRef(#pSprList, i).height = tmember.height
      if tRealMem then
        me.getPropRef(#pSprList, i).locH = tScreenLocs.getAt(1)
        me.getPropRef(#pSprList, i).locV = tScreenLocs.getAt(2)
        if tMemNum < 0 then
          me.getPropRef(#pSprList, i).rotation = 180
          me.getPropRef(#pSprList, i).skew = 180
          me.getPropRef(#pSprList, i).locH = me.getPropRef(#pSprList, i).locH + me.pXFactor
        else
          me.getPropRef(#pSprList, i).rotation = 0
          me.getPropRef(#pSprList, i).skew = 0
        end if
      end if
      if pActive then
        tIsGateSprite.append(i)
      end if
    end if
    i = 1 + i
  end repeat
  tlocz = me.getPropRef(#pLoczList, 1).getAt(tDirection + 1)
  tSpriteLocZ = me.getPropRef(#pSprList, 1).locZ
  i = 2
  repeat while i <= me.count(#pSprList)
    me.getPropRef(#pSprList, i).locZ = tSpriteLocZ + me.getPropRef(#pLoczList, i).getAt(tDirection + 1) - tlocz
    i = 1 + i
  end repeat
  pChanges = 0
  exit
end

on setOn(me)
  pActive = 1
  exit
end

on setOff(me)
  pActive = 0
  exit
end

on select(me)
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer:integer(me.getID()), #integer:0])
  end if
  return(1)
  exit
end

on solveTransparency(me, tPart)
  tName = me.pClass
  if me.pXFactor = 32 then
    tName = "s_" & tName
  end if
  if memberExists(tName & ".props") then
    tPropList = value(member(getmemnum(tName & ".props")).text)
    if ilk(tPropList) <> #propList then
      error(me, tName & ".props is not valid!", #solveInk, #minor)
    else
      if tPropList.getAt(tPart) <> void() then
        if tPropList.getAt(tPart).getAt(#transparent) <> void() then
          return(tPropList.getAt(tPart).getAt(#transparent))
        end if
      end if
    end if
  end if
  return(0)
  exit
end
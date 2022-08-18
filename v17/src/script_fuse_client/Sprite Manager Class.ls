property pTotalSprList, pFreeSprList, pClientList, pEventBroker

on construct me
  pTotalSprList = VOID
  pFreeSprList = VOID
  pClientList = VOID
  pEventBroker = script(getVariable("event.broker.behavior"))
  return me.preIndexChannels()
end

on deconstruct me
  return 1
end

on getProperty me, tPropID
  case tPropID of
    #totalSprCount:
      return pTotalSprList.count
    #freeSprCount:
      return pFreeSprList.count
  end case
  return 0
end

on setProperty me, tPropID, tValue
  -- ERROR: Could not identify jmp
  return 0
end

on reserveSprite me, tClientID
  if (pFreeSprList.count = 0) then
    return error(me, "Out of free sprite channels!", #reserveSprite, #major)
  end if
  tSprNum = pFreeSprList[1]
  tsprite = sprite(tSprNum)
  pFreeSprList.deleteAt(1)
  puppetSprite(tSprNum, 1)
  tsprite.stretch = 0
  tsprite.locV = -1000
  tsprite.visible = 1
  pClientList[tSprNum] = tClientID
  return tSprNum
end

on releaseSprite me, tSprNum
  if (pTotalSprList.getPos(tSprNum) < 1) then
    return error(me, ("Sprite not marked as usable:" && tSprNum), #releaseSprite, #minor)
  end if
  if (pFreeSprList.getPos(tSprNum) > 0) then
    return error(me, "Attempting to release free sprite!", #releaseSprite, #minor)
  end if
  tsprite = sprite(tSprNum)
  tsprite.member = member(0)
  tsprite.scriptInstanceList = []
  tsprite.rect = rect(0, 0, 1, 1)
  tsprite.locZ = tSprNum
  tsprite.visible = 0
  tsprite.castNum = 0
  tsprite.cursor = 0
  tsprite.blend = 100
  puppetSprite(tSprNum, 0)
  tsprite.locZ = VOID
  pFreeSprList.append(tSprNum)
  pClientList[tSprNum] = 0
  return 1
end

on releaseAllSprites me
  pFreeSprList = []
  repeat with tSprNum in pTotalSprList.count
    me.releaseSprite(tSprNum)
  end repeat
  return 1
end

on setEventBroker me, tSprNum, tID
  if (pTotalSprList.getPos(tSprNum) < 1) then
    return error(me, ("Sprite not marked as usable:" && tSprNum), #setEventBroker, #major)
  end if
  if (pFreeSprList.getPos(tSprNum) > 0) then
    return error(me, "Attempted to modify non-reserved sprite!", #setEventBroker, #major)
  end if
  tsprite = sprite(tSprNum)
  tsprite.scriptInstanceList = [new(pEventBroker)]
  tsprite.setID(tID)
  return 1
end

on removeEventBroker me, tSprNum
  if (pTotalSprList.getPos(tSprNum) < 1) then
    return error(me, ("Sprite not marked as usable:" && tSprNum), #removeEventBroker, #minor)
  end if
  if (pFreeSprList.getPos(tSprNum) > 0) then
    return error(me, "Attempted to modify non reserved sprite!", #removeEventBroker, #minor)
  end if
  sprite(tSprNum).scriptInstanceList = []
  return 1
end

on print me, tCount
  if integerp(tCount) then
    if (tCount > the lastChannel) then
      tCount = the lastChannel
    end if
    repeat with i = 1 to tCount
      put ((((((((sprite(i).spriteNum && "--") && sprite(i).member.name) && "--") && sprite(i).locZ) && "--") && sprite(i).rect) && "--") && pClientList[sprite(i).spriteNum])
    end repeat
  else
    repeat with tNum in pTotalSprList
      if (pFreeSprList.getPos(tNum) < 1) then
        tSymbol = "#"
      else
        tSymbol = SPACE
      end if
      put ((((((((tSymbol & tNum) && sprite(tNum).member.name) && "--") && sprite(tNum).locZ) && "--") && sprite(tNum).rect) && "--") && pClientList[tNum])
    end repeat
  end if
end

on preIndexChannels me
  pTotalSprList = []
  pFreeSprList = []
  pClientList = []
  repeat with i = 1 to the lastChannel
    pTotalSprList.add(i)
    pClientList.add(0)
    puppetSprite(i, 1)
    sprite(i).visible = 0
  end repeat
  pFreeSprList = pTotalSprList.duplicate()
  pTotalSprList.sort()
  return 1
end

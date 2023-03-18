property pAnimThisUpdate, pSin, pAnimTimer, pSpriteList, pOrigLocs, pDiscoStyle, pDiscoStyleCount, pLightSwitchTimer, pFountainFrame

on construct me
  pSin = 0.0
  pAnimTimer = the timer
  pSpriteList = []
  pOrigLocs = []
  pDiscoStyle = 1
  pDiscoStyleCount = 10
  pLightSwitchTimer = the timer
  pAnimThisUpdate = 1
  pFountainFrame = 1
  return 1
end

on deconstruct me
  return removeUpdate(me.getID())
end

on prepare me
  return receiveUpdate(me.getID())
end

on showprogram me, tMsg
  if voidp(tMsg) then
    return 0
  end if
  tNum = tMsg[#show_command]
  return me.changeDiscoStyle(tNum)
end

on changeDiscoStyle me, tNr
  if tNr = VOID then
    pDiscoStyle = pDiscoStyle + 1
  else
    pDiscoStyle = tNr
  end if
  if (pDiscoStyle < 1) or (pDiscoStyle > pDiscoStyleCount) then
    pDiscoStyle = 1
  end if
  return 1
end

on update me
  pAnimThisUpdate = not pAnimThisUpdate
  if pAnimThisUpdate then
    return 1
  end if
  me.updateFountain()
  pSin = pSin + 0.10000000000000001
  if pSpriteList = [] then
    return me.getSpriteList()
  end if
  case pDiscoStyle of
    1:
      me.fullRotation(15, 15, 15, 15, 15, 15, VOID, VOID)
    2:
      me.fullRotation(15, 15, 15, 15, 15, 15, VOID, VOID, point(100, -15))
      me.switchLights(#show1, 1)
    3:
      me.fullRotation(15, 15, 15, 15, 15, 15, VOID, VOID, point(100, -15))
      me.switchLights(#showAll, 0.69999999999999996)
    4:
      me.fullRotation(0, 15, 15, 0, 15, 0, point(90, -10), point(80, -10), point(70, -10))
    5:
      me.fullRotation(15, 0, 0, 15, 0, 15, point(90, -10), point(80, -10), point(70, -10))
    6:
      me.fullRotation(15, 15, 15, 15, 15, 15, VOID, point(60, -10), point(120, -10))
      me.switchLights(#show1, 2)
    7:
      me.fullRotation(25, 25, 25, 25, 25, 25, point(100, -20), point(80, -20), point(60, -20))
      me.switchLights(#show1, 3)
    8:
      me.switchLights(#show1, 3)
    9:
      me.fullRotation(15, 15, 15, 15, 15, 15, VOID, VOID, point(100, -25))
      me.switchLights(#blink, 1)
    10:
      me.switchLights(#showAll, 0.69999999999999996)
    11:
      me.switchLights(#show1, 2)
  end case
end

on fullRotation me, tGx, tGy, tYx, tYy, tRx, try, tGoffset, tYoffset, tRoffset
  if tGoffset = VOID then
    tGoffset = point(0, 0)
  end if
  if tYoffset = VOID then
    tYoffset = point(0, 0)
  end if
  if tRoffset = VOID then
    tRoffset = point(0, 0)
  end if
  pSpriteList[3].loc = pOrigLocs[1] + tGoffset + point(sin(pSin) * tGx, cos(pSin) * tGy)
  pSpriteList[6].loc = pOrigLocs[2] + tYoffset + point(cos(pSin) * tYx, sin(pSin) * tYy)
  pSpriteList[9].loc = pOrigLocs[3] + tRoffset + point(sin(pSin) * tRx, cos(pSin) * try)
  tLocs = [pSpriteList[3].loc + point(pSpriteList[3].width / 2, 0), pSpriteList[6].loc + point(pSpriteList[6].width / 2, 0), pSpriteList[9].loc + point(pSpriteList[9].width / 2, 0)]
  pSpriteList[2].rect = rect(pSpriteList[2].rect[1], pSpriteList[2].rect[2], tLocs[1][1], tLocs[1][2])
  pSpriteList[5].rect = rect(pSpriteList[5].rect[1], pSpriteList[5].rect[2], tLocs[2][1], tLocs[2][2])
  pSpriteList[8].rect = rect(pSpriteList[8].rect[1], pSpriteList[8].rect[2], tLocs[3][1], tLocs[3][2])
end

on switchLights me, tStyle, tTime
  if the timer < (pLightSwitchTimer + (tTime * 60)) then
    return 1
  end if
  pLightSwitchTimer = the timer
  tVisibleList = [pSpriteList[1].visible, pSpriteList[4].visible, pSpriteList[7].visible]
  case tStyle of
    #show1:
      repeat with i = 1 to tVisibleList.count
        if tVisibleList[i] then
          tLightStart = i
          if tLightStart > 2 then
            tLightStart = 0
          end if
          tLightStart = tLightStart * 3
          repeat with j = 1 to 9
            if (j = (tLightStart + 1)) or (j = (tLightStart + 2)) or (j = (tLightStart + 3)) then
              pSpriteList[j].visible = 1
              next repeat
            end if
            pSpriteList[j].visible = 0
          end repeat
        end if
      end repeat
    #blink:
      tShow = not tVisibleList[1]
      repeat with j = 1 to 9
        pSpriteList[j].visible = tShow
      end repeat
    #showAll:
      repeat with j = 1 to 9
        pSpriteList[j].visible = 1
      end repeat
  end case
end

on getSpriteList me
  pSpriteList = []
  tObj = getThread(#room).getInterface().getRoomVisualizer()
  if tObj = 0 then
    return 0
  end if
  repeat with i = 1 to 3
    tSp1 = tObj.getSprById("orient_bulb" & i)
    tSp2 = tObj.getSprById("orient_light" & i)
    tSp3 = tObj.getSprById("orient_spot" & i)
    if (tSp1 < 1) or (tSp2 < 1) or (tSp3 < 1) then
      return 0
    end if
    pSpriteList.add(tSp1)
    pSpriteList.add(tSp2)
    pSpriteList.add(tSp3)
  end repeat
  tSp1 = tObj.getSprById("orient_shower")
  tSp2 = tObj.getSprById("orient_bubbles1")
  tSp3 = tObj.getSprById("orient_bubbles2")
  if (tSp1 < 1) or (tSp2 < 1) or (tSp3 < 1) then
    return 0
  end if
  pSpriteList.add(tSp1)
  pSpriteList.add(tSp2)
  pSpriteList.add(tSp3)
  pOrigLocs = [pSpriteList[3].loc, pSpriteList[6].loc, pSpriteList[9].loc + point(10, 0), pSpriteList[11].loc, pSpriteList[12].loc]
  repeat with i = 1 to pSpriteList.count
    removeEventBroker(pSpriteList[i].spriteNum)
  end repeat
  return 1
end

on updateFountain me
  if pSpriteList = [] then
    return 0
  end if
  tShowerSprite = pSpriteList[10]
  tBubbleSprite1 = pSpriteList[11]
  tBubbleSprite2 = pSpriteList[12]
  pFountainFrame = pFountainFrame + 1
  if pFountainFrame > 4 then
    pFountainFrame = 1
  end if
  tMem = getMember("orient_shower" & pFountainFrame)
  tShowerSprite.member = tMem
  tShowerSprite.width = tMem.width
  tShowerSprite.height = tMem.height
  tBubbleSprite1.loc = pOrigLocs[4] + point(2 - random(3), 2 - random(3))
  tBubbleSprite2.loc = pOrigLocs[5] + point(2 - random(3), 2 - random(3))
  return 1
end

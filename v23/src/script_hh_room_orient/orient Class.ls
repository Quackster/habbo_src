property pDiscoStyle, pDiscoStyleCount, pAnimThisUpdate, pSin, pSpriteList, pOrigLocs, pLightSwitchTimer, pFountainFrame

on construct me 
  pSin = 0
  pAnimTimer = the timer
  pSpriteList = []
  pOrigLocs = []
  pDiscoStyle = 1
  pDiscoStyleCount = 10
  pLightSwitchTimer = the timer
  pAnimThisUpdate = 1
  pFountainFrame = 1
  return(1)
end

on deconstruct me 
  return(removeUpdate(me.getID()))
end

on prepare me 
  return(receiveUpdate(me.getID()))
end

on showprogram me, tMsg 
  if voidp(tMsg) then
    return(0)
  end if
  tNum = tMsg.getAt(#show_command)
  return(me.changeDiscoStyle(tNum))
end

on changeDiscoStyle me, tNr 
  if tNr = void() then
    pDiscoStyle = pDiscoStyle + 1
  else
    pDiscoStyle = tNr
  end if
  if pDiscoStyle < 1 or pDiscoStyle > pDiscoStyleCount then
    pDiscoStyle = 1
  end if
  return(1)
end

on update me 
  pAnimThisUpdate = not pAnimThisUpdate
  if pAnimThisUpdate then
    return(1)
  end if
  me.updateFountain()
  pSin = pSin + 0.1
  if pSpriteList = [] then
    return(me.getSpriteList())
  end if
  if pDiscoStyle = 1 then
    me.fullRotation(15, 15, 15, 15, 15, 15, void(), void())
  else
    if pDiscoStyle = 2 then
      me.fullRotation(15, 15, 15, 15, 15, 15, void(), void(), point(100, -15))
      me.switchLights(#show1, 1)
    else
      if pDiscoStyle = 3 then
        me.fullRotation(15, 15, 15, 15, 15, 15, void(), void(), point(100, -15))
        me.switchLights(#showAll, 0.7)
      else
        if pDiscoStyle = 4 then
          me.fullRotation(0, 15, 15, 0, 15, 0, point(90, -10), point(80, -10), point(70, -10))
        else
          if pDiscoStyle = 5 then
            me.fullRotation(15, 0, 0, 15, 0, 15, point(90, -10), point(80, -10), point(70, -10))
          else
            if pDiscoStyle = 6 then
              me.fullRotation(15, 15, 15, 15, 15, 15, void(), point(60, -10), point(120, -10))
              me.switchLights(#show1, 2)
            else
              if pDiscoStyle = 7 then
                me.fullRotation(25, 25, 25, 25, 25, 25, point(100, -20), point(80, -20), point(60, -20))
                me.switchLights(#show1, 3)
              else
                if pDiscoStyle = 8 then
                  me.switchLights(#show1, 3)
                else
                  if pDiscoStyle = 9 then
                    me.fullRotation(15, 15, 15, 15, 15, 15, void(), void(), point(100, -25))
                    me.switchLights(#blink, 1)
                  else
                    if pDiscoStyle = 10 then
                      me.switchLights(#showAll, 0.7)
                    else
                      if pDiscoStyle = 11 then
                        me.switchLights(#show1, 2)
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on fullRotation me, tGx, tGy, tYx, tYy, tRx, try, tGoffset, tYOffset, tRoffset 
  if tGoffset = void() then
    tGoffset = point(0, 0)
  end if
  if tYOffset = void() then
    tYOffset = point(0, 0)
  end if
  if tRoffset = void() then
    tRoffset = point(0, 0)
  end if
  pSpriteList.getAt(3).loc = pOrigLocs.getAt(1) + tGoffset + point((sin(pSin) * tGx), (cos(pSin) * tGy))
  pSpriteList.getAt(6).loc = pOrigLocs.getAt(2) + tYOffset + point((cos(pSin) * tYx), (sin(pSin) * tYy))
  pSpriteList.getAt(9).loc = pOrigLocs.getAt(3) + tRoffset + point((sin(pSin) * tRx), (cos(pSin) * try))
  tLocs = [pSpriteList.getAt(3).loc + point((pSpriteList.getAt(3).width / 2), 0), pSpriteList.getAt(6).loc + point((pSpriteList.getAt(6).width / 2), 0), pSpriteList.getAt(9).loc + point((pSpriteList.getAt(9).width / 2), 0)]
  pSpriteList.getAt(2).rect = rect(pSpriteList.getAt(2).getProp(#rect, 1), pSpriteList.getAt(2).getProp(#rect, 2), tLocs.getAt(1).getAt(1), tLocs.getAt(1).getAt(2))
  pSpriteList.getAt(5).rect = rect(pSpriteList.getAt(5).getProp(#rect, 1), pSpriteList.getAt(5).getProp(#rect, 2), tLocs.getAt(2).getAt(1), tLocs.getAt(2).getAt(2))
  pSpriteList.getAt(8).rect = rect(pSpriteList.getAt(8).getProp(#rect, 1), pSpriteList.getAt(8).getProp(#rect, 2), tLocs.getAt(3).getAt(1), tLocs.getAt(3).getAt(2))
end

on switchLights me, tStyle, tTime 
  if the timer < pLightSwitchTimer + (tTime * 60) then
    return(1)
  end if
  pLightSwitchTimer = the timer
  tVisibleList = [pSpriteList.getAt(1).visible, pSpriteList.getAt(4).visible, pSpriteList.getAt(7).visible]
  if tStyle = #show1 then
    i = 1
    repeat while i <= tVisibleList.count
      if tVisibleList.getAt(i) then
        tLightStart = i
        if tLightStart > 2 then
          tLightStart = 0
        end if
        tLightStart = (tLightStart * 3)
        j = 1
        repeat while j <= 9
          if j = tLightStart + 1 or j = tLightStart + 2 or j = tLightStart + 3 then
            pSpriteList.getAt(j).visible = 1
          else
            pSpriteList.getAt(j).visible = 0
          end if
          j = 1 + j
        end repeat
      end if
      i = 1 + i
    end repeat
    exit repeat
  end if
  if tStyle = #blink then
    tShow = not tVisibleList.getAt(1)
    j = 1
    repeat while j <= 9
      pSpriteList.getAt(j).visible = tShow
      j = 1 + j
    end repeat
    exit repeat
  end if
  if tStyle = #showAll then
    j = 1
    repeat while j <= 9
      pSpriteList.getAt(j).visible = 1
      j = 1 + j
    end repeat
  end if
end

on getSpriteList me 
  pSpriteList = []
  tObj = getThread(#room).getInterface().getRoomVisualizer()
  if tObj = 0 then
    return(0)
  end if
  i = 1
  repeat while i <= 3
    tSp1 = tObj.getSprById("orient_bulb" & i)
    tSp2 = tObj.getSprById("orient_light" & i)
    tSp3 = tObj.getSprById("orient_spot" & i)
    if tSp1 < 1 or tSp2 < 1 or tSp3 < 1 then
      return(0)
    end if
    pSpriteList.add(tSp1)
    pSpriteList.add(tSp2)
    pSpriteList.add(tSp3)
    i = 1 + i
  end repeat
  tSp1 = tObj.getSprById("orient_shower")
  tSp2 = tObj.getSprById("orient_bubbles1")
  tSp3 = tObj.getSprById("orient_bubbles2")
  if tSp1 < 1 or tSp2 < 1 or tSp3 < 1 then
    return(0)
  end if
  pSpriteList.add(tSp1)
  pSpriteList.add(tSp2)
  pSpriteList.add(tSp3)
  pOrigLocs = [pSpriteList.getAt(3).loc, pSpriteList.getAt(6).loc, pSpriteList.getAt(9).loc + point(10, 0), pSpriteList.getAt(11).loc, pSpriteList.getAt(12).loc]
  i = 1
  repeat while i <= pSpriteList.count
    removeEventBroker(pSpriteList.getAt(i).spriteNum)
    i = 1 + i
  end repeat
  return(1)
end

on updateFountain me 
  if pSpriteList = [] then
    return(0)
  end if
  tShowerSprite = pSpriteList.getAt(10)
  tBubbleSprite1 = pSpriteList.getAt(11)
  tBubbleSprite2 = pSpriteList.getAt(12)
  pFountainFrame = pFountainFrame + 1
  if pFountainFrame > 4 then
    pFountainFrame = 1
  end if
  tMem = getMember("orient_shower" & pFountainFrame)
  tShowerSprite.member = tMem
  tShowerSprite.width = tMem.width
  tShowerSprite.height = tMem.height
  tBubbleSprite1.loc = pOrigLocs.getAt(4) + point(2 - random(3), 2 - random(3))
  tBubbleSprite2.loc = pOrigLocs.getAt(5) + point(2 - random(3), 2 - random(3))
  return(1)
end

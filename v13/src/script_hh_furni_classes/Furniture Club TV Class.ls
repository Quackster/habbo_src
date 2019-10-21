property pLineSprite1, pLineSprite2, pLinesOrigLocV, pNoiseSprite, pMovedByUser, pActiveEffect, pChanges, pActive, pGlowSprite, pCoverSprite, pRandomEffectList, pEffectCounter

on prepare me, tdata 
  if me.count(#pSprList) < 9 then
    return FALSE
  end if
  pRandomEffectList = [#noise1, #lines1, #lines1]
  removeEventBroker(me.getPropRef(#pSprList, 7).spriteNum)
  pLineSprite1 = me.getProp(#pSprList, 2)
  pLineSprite2 = me.getProp(#pSprList, 3)
  pGlowSprite = me.getProp(#pSprList, 7)
  pCoverSprite = me.getProp(#pSprList, 8)
  pNoiseSprite = me.getProp(#pSprList, 9)
  pMovedByUser = 0
  me.hideAllEffects()
  if (tdata.getAt(#stuffdata) = "ON") then
    pActive = 1
  else
    pActive = 0
  end if
  pChanges = 1
  return TRUE
end

on prepareForMove me 
  pLinesOrigLocV = void()
  pMovedByUser = 1
end

on movingFinished me 
  pMovedByUser = 0
end

on hideAllEffects me 
  pLineSprite1.visible = 0
  pLineSprite2.visible = 0
  if not voidp(pLinesOrigLocV) then
    pLineSprite1.locV = pLinesOrigLocV.getAt(1)
    pLineSprite2.locV = pLinesOrigLocV.getAt(2)
  end if
  pNoiseSprite.visible = 0
  pActiveEffect = #none
  pEffectCounter = 0
end

on updateStuffdata me, tValue 
  if (tValue = "OFF") then
    pActive = 0
  else
    pActive = 1
  end if
  pChanges = 1
end

on update me 
  if pMovedByUser then
    return TRUE
  end if
  if (random(40) = 5) and (pActiveEffect = #none) then
    me.startRandomEffect()
  end if
  if pActiveEffect <> #none then
    me.runEffect()
  end if
  if not pChanges then
    return()
  end if
  if (pLinesOrigLocV = void()) then
    pLinesOrigLocV = [pLineSprite1.locV, pLineSprite2.locV]
  end if
  if pActive then
    pGlowSprite.visible = 1
    pCoverSprite.visible = 0
  else
    pGlowSprite.visible = 0
    pCoverSprite.visible = 1
    me.hideAllEffects()
  end if
end

on startRandomEffect me 
  pActiveEffect = pRandomEffectList.getAt(random(pRandomEffectList.count))
  return TRUE
end

on runEffect me 
  pEffectCounter = (pEffectCounter + 1)
  if (pActiveEffect = #noise1) then
    if (random(6) = 5) then
      pNoiseSprite.visible = 0
    else
      pNoiseSprite.visible = 1
    end if
    if pEffectCounter > 5 then
      me.hideAllEffects()
    end if
  else
    if (pActiveEffect = #lines1) then
      if ((pEffectCounter mod 2) = 1) then
        return TRUE
      end if
      pLineSprite1.visible = 1
      pLineSprite2.visible = 1
      pLineSprite1.locV = (pLineSprite1.locV + 1)
      pLineSprite2.locV = (pLineSprite2.locV + 1)
      if pEffectCounter > 90 then
        me.hideAllEffects()
      end if
    else
      if (pActiveEffect = #lines2) then
        pLineSprite1.visible = 1
        pLineSprite2.visible = 1
        if pEffectCounter < 45 then
          pLineSprite1.locV = (pLineSprite1.locV + 1)
        else
          pLineSprite1.locV = (pLineSprite1.locV - 1)
        end if
        if pEffectCounter > 90 then
          me.hideAllEffects()
        end if
      end if
    end if
  end if
  return TRUE
end

on setOn me 
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:"ON"])
end

on setOff me 
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:"OFF"])
end

on select me, tSprID 
  tSprNum = the clickOn
  tBottompartList = [3, 4, 5]
  if the doubleClick then
    i = 1
    repeat while i <= tBottompartList.count
      if (me.getPropRef(#pSprList, tBottompartList.getAt(i)).spriteNum = tSprNum) then
        return FALSE
      end if
      i = (1 + i)
    end repeat
    me.setOnOff()
  end if
  return TRUE
end

on setOnOff me 
  if pActive then
    me.setOff()
  else
    me.setOn()
  end if
  return TRUE
end

property pPupItemList

on render me 
  me.ancestor.render(me)
  tService = me.getIGComponent("GameList")
  if (tService = 0) then
    return FALSE
  end if
  tItemRef = tService.getObservedGame()
  if (tItemRef = 0) then
    return FALSE
  end if
  tWndObj = getWindow(me.getWindowId("btm"))
  if (tWndObj = 0) then
    return FALSE
  end if
  tWndObj.unmerge()
  tWndObj.resizeTo(0, 0)
  tWndObj = getWindow(me.getWindowId("spec"))
  if (tWndObj = 0) then
    return FALSE
  end if
  tWndObj.unmerge()
  tWndObj.merge("ig_bb_powerups.window")
  tWndObj.registerProcedure(#eventProcMouseHover, me.getMainThread().getInterface().getID(), #mouseWithin)
  me.renderBBPowerups(tItemRef.getProperty(#bb_pups))
  tWrapObjRef = me.getWindowWrapper()
  if (tWrapObjRef = 0) then
    return FALSE
  end if
  tWrapObjRef.render()
  return TRUE
end

on renderBBPowerups me, tList 
  if (tList = 0) then
    tList = []
  end if
  pPupItemList = tList
  if (tList.count = 0) then
    tList.append(0)
  end if
  tWndObj = getWindow(me.getWindowId("spec"))
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("ig_chosen_powerups")
  if (tElem = 0) then
    return FALSE
  end if
  tWidth = (tList.count * 32)
  tHeight = tElem.getProperty(#height)
  tImage = image(tWidth, tHeight, 8)
  tOffsetX = ((tWidth / 2) - (tList.count * 16))
  repeat while tList <= undefined
    ttype = getAt(undefined, tList)
    tMemNum = getmemnum("ig_bb_icon_pwrup_" & ttype)
    if tMemNum > 0 then
      tIcon = member(tMemNum).image
      tImage.copyPixels(tIcon, (tIcon.rect + rect(tOffsetX, 0, tOffsetX, 0)), tIcon.rect)
      tOffsetX = (tOffsetX + 32)
    end if
  end repeat
  tElem.feedImage(tImage)
  tElem.moveBy(((tElem.getProperty(#width) / 2) - (tImage.width / 2)), 0)
  return TRUE
end

on eventProcMouseHover me, tEvent, tSprID, tParam, tWndID 
  if tSprID <> "ig_chosen_powerups" then
    return FALSE
  end if
  tObject = me.getMainThread().getInterface().getTooltipManager()
  if (tObject = 0) then
    return FALSE
  end if
  tWndObj = getWindow(tWndID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement(tSprID)
  if (tElem = 0) then
    return FALSE
  end if
  tsprite = tElem.getProperty(#sprite)
  if (tsprite = 0) then
    return FALSE
  end if
  if (pPupItemList.count = 0) then
    return FALSE
  end if
  tIndex = (((the mouseH - tsprite.left) / 32) + 1)
  if tIndex < 1 then
    return FALSE
  end if
  if tIndex > pPupItemList.count then
    return FALSE
  end if
  tLocX = ((tsprite.left + (tIndex * 32)) - 16)
  tLocY = tsprite.locV
  return(tObject.createTooltipWindow(getText("bb_powerup_desc_" & pPupItemList.getAt(tIndex)), tLocX, tLocY))
end

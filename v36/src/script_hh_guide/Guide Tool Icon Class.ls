on construct(me)
  pSpriteId = "guide_tool_icon_sprite"
  pIconSprite = void()
  pIconLoc = value(getVariable("guidetool.icon.loc"))
  pFlashTimeoutID = "guide_tool_icon_flash"
  exit
end

on deconstruct(me)
  if pIconSprite.ilk = #sprite then
    releaseSprite(pIconSprite.spriteNum)
  end if
  exit
end

on show(me, tstate)
  if voidp(tstate) then
    tstate = "normal"
  end if
  if pIconSprite.ilk <> #sprite then
    pIconSprite = sprite(reserveSprite(me.getID()))
    if pIconSprite = 0 then
      return(0)
    end if
  end if
  pIconSprite.member = member("guide_tool_icon_normal")
  pIconSprite.ink = 8
  pIconSprite.loc = pIconLoc
  ERROR.locZ = 0
  pIconSprite.visible = 1
  setEventBroker(pIconSprite.spriteNum, pSpriteId)
  pIconSprite.registerProcedure(#eventProcIcon, me.getID(), #mouseUp)
  pIconSprite.setcursor("cursor.finger")
  return(1)
  exit
end

on hide(me)
  if pIconSprite.ilk = #sprite then
    pIconSprite.visible = 0
  end if
  exit
end

on setFlashing(me, tstate)
  if tstate = 1 then
    if not timeoutExists(pFlashTimeoutID) then
      createTimeout(pFlashTimeoutID, 500, #updateFlash, me.getID(), void(), 0)
    end if
  else
    if timeoutExists(pFlashTimeoutID) then
      removeTimeout(pFlashTimeoutID)
    end if
    if pIconSprite.ilk = #sprite then
      pIconSprite.member = member("guide_tool_icon_normal")
    end if
  end if
  exit
end

on updateFlash(me)
  if pIconSprite.ilk <> #sprite then
    return(0)
  end if
  tMemName = member.name
  if tMemName = "guide_tool_icon_normal" then
    pIconSprite.member = member("guide_tool_icon_black")
  else
    pIconSprite.member = member("guide_tool_icon_normal")
  end if
  exit
end

on eventProcIcon(me, tEvent, tSprID, tProp)
  executeMessage(#toggleGuideTool)
  exit
end
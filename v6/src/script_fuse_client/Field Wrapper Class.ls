property pMember

on deconstruct me 
  return(getResourceManager().removeMember(pMember.name))
end

on prepare me 
  pMember = member(getResourceManager().createMember(me.getProp(#pProps, #member) & the milliSeconds & numToChar(random(99)), #field))
  pMember.wordWrap = me.getProp(#pProps, #wordWrap)
  pMember.autoTab = me.getProp(#pProps, #autoTab)
  pMember.alignment = me.getProp(#pProps, #alignment)
  pMember.font = me.getProp(#pProps, #font)
  pMember.fontSize = me.getProp(#pProps, #fontSize)
  pMember.boxType = me.getProp(#pProps, #boxType)
  pMember.fontStyle = me.getProp(#pProps, #fontStyle)
  pMember.editable = 1
  if voidp(me.getProp(#pProps, #border)) then
    me.setProp(#pProps, #border, 0)
  end if
  pMember.color = me.getProp(#pProps, #txtColor)
  pMember.bgColor = me.getProp(#pProps, #txtBgColor)
  pMember.border = me.getProp(#pProps, #border)
  if integerp(me.getProp(#pProps, #boxDropShadow)) then
    pMember.boxDropShadow = me.getProp(#pProps, #boxDropShadow)
  end if
  if (me.getProp(#pProps, #key) = "") then
    pMember.text = ""
  else
    if textExists(me.getProp(#pProps, #key)) then
      pMember.text = getText(me.getProp(#pProps, #key))
    else
      error(me, "Text not found:" && me.getProp(#pProps, #key), #define)
      pMember.text = me.getProp(#pProps, #key)
    end if
  end if
  me.pSprite.member = pMember
  pMember.rect = rect(0, 0, me.pwidth, me.pheight)
  return TRUE
end

on getText me 
  return(pMember.text)
end

on setText me, tText 
  if not stringp(tText) then
    tText = string(tText)
  end if
  pMember.text = tText
  return TRUE
end

on setEdit me, tBool 
  if tBool <> 1 and tBool <> 0 then
    return FALSE
  end if
  pMember.editable = tBool
  me.pSprite.editable = tBool
  return TRUE
end

on setFocus me, tBool 
  if (tBool = 1) then
    the keyboardFocusSprite = me.pSprite.spriteNum
  else
    if (tBool = 0) then
      the keyboardFocusSprite = 0
    else
      return FALSE
    end if
  end if
  return TRUE
end

on render me 
  me.pLocX = me.pSprite.locH
  me.pLocY = me.pSprite.locV
  me.pwidth = me.pSprite.width
  me.pheight = me.pSprite.height
  me.pMember.rect = rect(0, 0, me.pwidth, me.pheight)
end

on draw me, tRGB 
  if not ilk(tRGB, #color) then
    tRGB = rgb(255, 0, 0)
  end if
  the stage.image.draw(me.pSprite.rect, [#shapeType:#rect, #color:tRGB])
end

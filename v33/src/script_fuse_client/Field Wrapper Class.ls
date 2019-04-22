property pMember, pDontProfile

on deconstruct me 
  return(getResourceManager().removeMember(pMember.name))
end

on setProfiling  
  if voidp(pDontProfile) then
    pDontProfile = 1
    if getObjectManager().managerExists(#variable_manager) then
      if variableExists("profile.fields.enabled") then
        pDontProfile = 0
      end if
    end if
  end if
end

on prepare me 
  me.setProfiling()
  if not pDontProfile then
    startProfilingTask("Field Wrapper::prepare")
  end if
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
  if me.getProp(#pProps, #key) = "" then
    pMember.text = ""
  else
    if textExists(me.getProp(#pProps, #key)) then
      pMember.text = getText(me.getProp(#pProps, #key))
    else
      error(me, "Text not found:" && me.getProp(#pProps, #key), #define, #minor)
      pMember.text = me.getProp(#pProps, #key)
    end if
  end if
  pSprite.member = pMember
  pMember.rect = rect(0, 0, me.pwidth, me.pheight)
  if not pDontProfile then
    finishProfilingTask("Field Wrapper::prepare")
  end if
  return(1)
end

on getText me 
  return(pMember.text)
end

on setText me, tText 
  if not pDontProfile then
    startProfilingTask("Field Wrapper::setText")
  end if
  if not stringp(tText) then
    tText = string(tText)
  end if
  pMember.text = tText
  if not pDontProfile then
    finishProfilingTask("Field Wrapper::setText")
  end if
  return(1)
end

on setEdit me, tBool 
  if tBool <> 1 and tBool <> 0 then
    return(0)
  end if
  pMember.editable = tBool
  pSprite.editable = tBool
  return(1)
end

on setFocus me, tBool 
  if tBool = 1 then
    the keyboardFocusSprite = pSprite.spriteNum
  else
    if me = 0 then
      the keyboardFocusSprite = 0
    else
      return(0)
    end if
  end if
  return(1)
end

on render me 
  me.pwidth = pSprite.width
  me.pheight = pSprite.height
  me.rect = rect(0, 0, me.pwidth, me.pheight)
end

on draw me, tRGB 
  if not ilk(tRGB, #color) then
    tRGB = rgb(255, 0, 0)
  end if
  me.draw(pSprite.rect, [#shapeType:#rect, #color:tRGB])
end

on handlers  
  return([])
end

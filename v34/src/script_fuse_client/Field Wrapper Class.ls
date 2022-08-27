property pMember, pDontProfile

on deconstruct me
  return getResourceManager().removeMember(pMember.name)
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
  pMember = member(getResourceManager().createMember(((me.pProps[#member] & the milliSeconds) & numToChar(random(99))), #field))
  pMember.wordWrap = me.pProps[#wordWrap]
  pMember.autoTab = me.pProps[#autoTab]
  pMember.alignment = me.pProps[#alignment]
  pMember.font = me.pProps[#font]
  pMember.fontSize = me.pProps[#fontSize]
  pMember.boxType = me.pProps[#boxType]
  pMember.fontStyle = me.pProps[#fontStyle]
  pMember.editable = 1
  if voidp(me.pProps[#border]) then
    me.pProps[#border] = 0
  end if
  pMember.color = me.pProps[#txtColor]
  pMember.bgColor = me.pProps[#txtBgColor]
  pMember.border = me.pProps[#border]
  if integerp(me.pProps[#boxDropShadow]) then
    pMember.boxDropShadow = me.pProps[#boxDropShadow]
  end if
  if (me.pProps[#key] = EMPTY) then
    pMember.text = EMPTY
  else
    if textExists(me.pProps[#key]) then
      pMember.text = getText(me.pProps[#key])
    else
      error(me, ("Text not found:" && me.pProps[#key]), #define, #minor)
      pMember.text = me.pProps[#key]
    end if
  end if
  me.pSprite.member = pMember
  pMember.rect = rect(0, 0, me.pwidth, me.pheight)
  if not pDontProfile then
    finishProfilingTask("Field Wrapper::prepare")
  end if
  return 1
end

on getText me
  return pMember.text
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
  return 1
end

on setEdit me, tBool
  if ((tBool <> 1) and (tBool <> 0)) then
    return 0
  end if
  pMember.editable = tBool
  me.pSprite.editable = tBool
  return 1
end

on setFocus me, tBool
  case tBool of
    1:
      the keyboardFocusSprite = me.pSprite.spriteNum
    0:
      the keyboardFocusSprite = 0
  end case
  return 0
  return 1
end

on render me
  me.pwidth = me.pSprite.width
  me.pheight = me.pSprite.height
  me.pMember.rect = rect(0, 0, me.pwidth, me.pheight)
end

on draw me, tRGB
  if not ilk(tRGB, #color) then
    tRGB = rgb(255, 0, 0)
  end if
  the stage.image.draw(me.pSprite.rect, [#shapeType: #rect, #color: tRGB])
end

on handlers
  return []
end

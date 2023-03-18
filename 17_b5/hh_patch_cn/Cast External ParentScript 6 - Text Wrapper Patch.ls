on initResources me, tFontProps
  tMemNum = getResourceManager().getmemnum("visual window text")
  if tMemNum = 0 then
    tMemNum = getResourceManager().createMember("visual window text", #text)
    me.pTextMem = member(tMemNum)
    me.pTextMem.boxType = #adjust
    if the platform contains "windows" then
      if variableExists("win.font.toff") then
        me.pTextMem.topSpacing = getIntVariable("win.font.toff")
      else
        me.pTextMem.topSpacing = 0
      end if
    else
      me.pOwnH = me.pOwnH + 2
      me.pheight = me.pheight + 2
      if variableExists("mac.font.toff") then
        me.pTextMem.topSpacing = getIntVariable("mac.font.toff")
      else
        me.pTextMem.topSpacing = -1
      end if
    end if
  else
    me.pTextMem = member(tMemNum)
  end if
  return 1
end

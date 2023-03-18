on initResources me, tFontProps
  tMemNum = getResourceManager().getmemnum("visual window text")
  if tMemNum = 0 then
    tMemNum = getResourceManager().createMember("visual window text", #text)
    me.pTextMem = member(tMemNum)
    me.pTextMem.boxType = #adjust
    if the platform contains "windows" then
      me.pTextMem.topSpacing = getIntVariable("win.font.toff", 0)
    else
      me.pOwnH = me.pOwnH + 2
      me.pheight = me.pheight + 2
      me.pTextMem.topSpacing = getIntVariable("mac.font.toff", -1)
    end if
  else
    me.pTextMem = member(tMemNum)
  end if
  return 1
end

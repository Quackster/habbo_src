on define me, tMetrics
  me.ancestor.define(tMetrics)
  if the platform contains "windows" then
    if variableExists("win.font.toff") then
      me.pMember.topSpacing = getIntVariable("win.font.toff")
    else
      me.pMember.topSpacing = 4
    end if
    if variableExists("win.fixedLineSpace") then
      me.pMember.fixedLineSpace = getVariable("win.fixedLineSpace")
    end if
  else
    if variableExists("mac.font.toff") then
      me.pMember.topSpacing = getIntVariable("mac.font.toff")
    else
      me.pMember.topSpacing = 2
    end if
    if variableExists("mac.fixedLineSpace") then
      me.pMember.fixedLineSpace = getVariable("mac.fixedLineSpace")
    end if
  end if
end

on construct_old me
  me.pDefRect = rect(0, 0, 480, 480)
  me.pTxtRect = VOID
  me.pFntStru = VOID
  me.pMember = member(createMember("writer_" & getUniqueID(), #text))
  if me.pMember.number = 0 then
    return 0
  else
    if the platform contains "windows" then
      if variableExists("win.font.toff") then
        me.pMember.topSpacing = getIntVariable("win.font.toff")
      else
        me.pMember.topSpacing = 4
      end if
    else
      if variableExists("mac.font.toff") then
        me.pMember.topSpacing = getIntVariable("mac.font.toff")
      else
        me.pMember.topSpacing = 0
      end if
    end if
    me.pMember.wordWrap = 0
    return 1
  end if
end

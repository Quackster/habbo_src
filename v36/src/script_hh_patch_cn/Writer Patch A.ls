on define me, tMetrics 
  ancestor.define(tMetrics)
  if the platform contains "windows" then
    if variableExists("win.font.toff") then
      pMember.topSpacing = getIntVariable("win.font.toff")
    else
      pMember.topSpacing = 4
    end if
    if variableExists("win.fixedLineSpace") then
      pMember.fixedLineSpace = getVariable("win.fixedLineSpace")
    end if
  else
    if variableExists("mac.font.toff") then
      pMember.topSpacing = getIntVariable("mac.font.toff")
    else
      pMember.topSpacing = 2
    end if
    if variableExists("mac.fixedLineSpace") then
      pMember.fixedLineSpace = getVariable("mac.fixedLineSpace")
    end if
  end if
end

on construct_old me 
  me.pDefRect = rect(0, 0, 480, 480)
  me.pTxtRect = void()
  me.pFntStru = void()
  me.pMember = member(createMember("writer_" & getUniqueID(), #text))
  if pMember.number = 0 then
    return(0)
  else
    if the platform contains "windows" then
      if variableExists("win.font.toff") then
        pMember.topSpacing = getIntVariable("win.font.toff")
      else
        pMember.topSpacing = 4
      end if
    else
      if variableExists("mac.font.toff") then
        pMember.topSpacing = getIntVariable("mac.font.toff")
      else
        pMember.topSpacing = 0
      end if
    end if
    pMember.wordWrap = 0
    return(1)
  end if
end

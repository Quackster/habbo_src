on construct(me)
  me.pDefRect = rect(0, 0, 480, 480)
  me.pTxtRect = void()
  me.pFntStru = void()
  me.pMember = member(createMember("writer_" & getUniqueID(), #text))
  if variableExists("text.render.compatibility.mode") then
    pTextRenderMode = getVariable("text.render.compatibility.mode")
  else
    pTextRenderMode = 1
  end if
  if variableExists("text.underlining.disabled") then
    pUnderliningDisabled = getVariable("text.underlining.disabled")
  else
    pUnderliningDisabled = 0
  end if
  if pMember.number = 0 then
    return(0)
  else
    if the platform contains "windows" then
      pMember.topSpacing = getIntVariable("win.font.toff", 0)
    else
      pMember.topSpacing = getIntVariable("mac.font.toff", 0)
    end if
    pMember.wordWrap = 0
    return(1)
  end if
  exit
end
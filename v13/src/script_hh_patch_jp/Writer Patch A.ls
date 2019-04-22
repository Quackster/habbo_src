on construct(me)
  me.pDefRect = rect(0, 0, 480, 480)
  me.pTxtRect = void()
  me.pFntStru = void()
  me.pMember = member(createMember("writer_" & getUniqueID(), #text))
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
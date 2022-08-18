on construct me 
  me.pDefRect = rect(0, 0, 480, 480)
  me.pTxtRect = void()
  me.pFntStru = void()
  me.pMember = member(createMember("writer_" & getUniqueID(), #text))
  if (me.pMember.number = 0) then
    return FALSE
  else
    if the platform contains "windows" then
      me.pMember.topSpacing = getIntVariable("win.font.toff", 0)
    else
      me.pMember.topSpacing = getIntVariable("mac.font.toff", 0)
    end if
    me.pMember.wordWrap = 0
    return TRUE
  end if
end

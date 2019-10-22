on addWindows me 
  me.pWindowID = "ru"
  tService = me.getIGComponent("PreGame")
  if (tService = 0) then
    return FALSE
  end if
  tGameRef = tService.getJoinedGame()
  if (tGameRef = 0) then
    return FALSE
  end if
  tGameType = tGameRef.getProperty(#game_type)
  tWrapObjRef = me.getWindowWrapper()
  if (tWrapObjRef = 0) then
    return FALSE
  end if
  tScrollStartOffset = -100
  tWinChar = "a"
  tLayoutList = []
  i = charToNum("a")
  repeat while i <= charToNum("z")
    tLayoutID = "ig_pg_rules_" & numToChar(i) & "_" & tGameType & ".window"
    if memberExists(tLayoutID) then
      tLayoutList.append(tLayoutID)
    end if
    i = (1 + i)
  end repeat
  i = 1
  repeat while i <= tLayoutList.count
    if i < tLayoutList.count then
      tWrapObjRef.addOneWindow(me.getWindowId(i), tLayoutList.getAt(i), me.pWindowSetId, [#scrollFromLocX:tScrollStartOffset, #spaceBottom:2])
    else
      tWrapObjRef.addOneWindow(me.getWindowId(i), tLayoutList.getAt(i), me.pWindowSetId, [#scrollFromLocX:tScrollStartOffset, #spaceBottom:2])
    end if
    tScrollStartOffset = (tScrollStartOffset - 50)
    i = (1 + i)
  end repeat
  return TRUE
end

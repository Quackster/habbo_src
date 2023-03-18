on addWindows me
  me.pWindowID = "ru"
  tService = me.getIGComponent("PreGame")
  if tService = 0 then
    return 0
  end if
  tGameRef = tService.getJoinedGame()
  if tGameRef = 0 then
    return 0
  end if
  tGameType = tGameRef.getProperty(#game_type)
  tWrapObjRef = me.getWindowWrapper()
  if tWrapObjRef = 0 then
    return 0
  end if
  tScrollStartOffset = -100
  tWinChar = "a"
  tLayoutList = []
  repeat with i = charToNum("a") to charToNum("z")
    tLayoutID = "ig_pg_rules_" & numToChar(i) & "_" & tGameType & ".window"
    if memberExists(tLayoutID) then
      tLayoutList.append(tLayoutID)
    end if
  end repeat
  repeat with i = 1 to tLayoutList.count
    if i < tLayoutList.count then
      tWrapObjRef.addOneWindow(me.getWindowId(i), tLayoutList[i], me.pWindowSetId, [#scrollFromLocX: tScrollStartOffset, #spaceBottom: 2])
    else
      tWrapObjRef.addOneWindow(me.getWindowId(i), tLayoutList[i], me.pWindowSetId, [#scrollFromLocX: tScrollStartOffset, #spaceBottom: 2])
    end if
    tScrollStartOffset = tScrollStartOffset - 50
  end repeat
  return 1
end

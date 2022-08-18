on eventProcMouseDown me, tEvent, tSprID, tParam, tWndID
  tService = me.getIGComponent("LevelList")
  if (tService = 0) then
    return 0
  end if
  tMultiplier = 1
  tIntParam = 0
  repeat while integerp(integer(tSprID.char[tSprID.length]))
    tIntParam = (tIntParam + (tMultiplier * integer(tSprID.char[tSprID.length])))
    tSprID = tSprID.char[1]
    tMultiplier = (tMultiplier * 10)
  end repeat
  if (tSprID.char[tSprID.length] = "_") then
    tSprID = tSprID.char[1]
  end if
  return 0
end

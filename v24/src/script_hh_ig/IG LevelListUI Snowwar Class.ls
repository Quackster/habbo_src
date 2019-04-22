on eventProcMouseDown(me, tEvent, tSprID, tParam, tWndID)
  tService = me.getIGComponent("LevelList")
  if tService = 0 then
    return(0)
  end if
  tMultiplier = 1
  tIntParam = 0
  repeat while integerp(integer(tSprID.getProp(#char, tSprID.length)))
    tIntParam = tIntParam + tMultiplier * integer(tSprID.getProp(#char, tSprID.length))
    tSprID = tSprID.getProp(#char, 1, tSprID.length - 1)
    tMultiplier = tMultiplier * 10
  end repeat
  if tSprID.getProp(#char, tSprID.length) = "_" then
    tSprID = tSprID.getProp(#char, 1, tSprID.length - 1)
  end if
  return(0)
  exit
end
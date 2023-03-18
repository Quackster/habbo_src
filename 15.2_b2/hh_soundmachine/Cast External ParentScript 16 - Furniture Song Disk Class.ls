property tSongID, tSongName, tSongLength

on construct me
  tSongID = 0
  tSongName = EMPTY
  tSongLength = 0
  callAncestor(#construct, [me])
  return 1
end

on deconstruct me
  callAncestor(#deconstruct, [me])
  return 1
end

on define me, tProps
  callAncestor(#define, [me], tProps)
  if not voidp(tProps[#props]) then
    tdata = tProps[#props]
    if not voidp(tdata[#extra]) then
      tSongID = tdata[#extra]
    end if
    if not voidp(tdata[#stuffdata]) then
      tSongName = tdata[#stuffdata]
    end if
  end if
  return 1
end

on getInfo me
  tInfo = callAncestor(#getInfo, [me])
  if ilk(tInfo) <> #propList then
    tInfo = [:]
  end if
  tInfo[#custom] = tSongName
  return tInfo
end

on select me
  return callAncestor(#select, [me])
  return 1
end

on setState me, tNewState
  callAncestor(#setState, [me], tNewState)
end

on setID me, tID
  callAncestor(#setID, [me], tID)
  executeMessage(#sound_machine_created, me.getID(), 0)
  return 1
end

on deconstruct me
  executeMessage(#sound_machine_removed, me.getID())
  callAncestor(#deconstruct, [me])
  return 1
end

on define me, tProps
  tRetVal = callAncestor(#define, [me], tProps)
  if voidp(tProps[#stripId]) then
    executeMessage(#jukebox_defined, me.getID())
  end if
  return 1
end

on select me
  towner = 0
  tSession = getObject(#session)
  if tSession <> 0 then
    if tSession.GET("room_owner") then
      towner = 1
    end if
  end if
  if the doubleClick then
    executeMessage(#jukebox_selected, [#id: me.getID(), #owner: towner])
  else
    return callAncestor(#select, [me])
  end if
  return 1
end

on getInfo me
  tInfo = callAncestor(#getInfo, [me])
  if ilk(tInfo) <> #propList then
    tInfo = [:]
  end if
  if voidp(tInfo[#custom]) then
    tInfo[#custom] = EMPTY
  end if
  tInfo[#custom] = tInfo[#custom] & RETURN
  tArray = [:]
  executeMessage(#get_jukebox_song_info, tArray)
  if not voidp(tArray[#songName]) then
    tInfo[#custom] = tInfo[#custom] & tArray[#songName] & RETURN
  end if
  if not voidp(tArray[#author]) then
    tInfo[#custom] = tInfo[#custom] & tArray[#author]
  end if
  return tInfo
end

on setState me, tNewState
  callAncestor(#setState, [me], tNewState)
  if voidp(tNewState) then
    return 0
  end if
  tStateOn = 1
  executeMessage(#sound_machine_set_state, [#id: me.getID(), #furniOn: tStateOn])
end

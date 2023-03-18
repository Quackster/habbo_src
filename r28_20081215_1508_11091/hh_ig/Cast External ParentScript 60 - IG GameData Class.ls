property pPlayerData, pRoomIndexIndex

on construct me
  me.clear()
  registerMessage(#ig_clear_game_info, me.getID(), #clear)
  registerMessage(#ig_store_game_info, me.getID(), #define)
  registerMessage(#ig_store_gameplayer_info, me.getID(), #storeUser)
  registerMessage(#ig_user_left_game, me.getID(), #userLeftGame)
  return 1
end

on deconstruct me
  unregisterMessage(#ig_clear_game_info, me.getID())
  unregisterMessage(#ig_store_game_info, me.getID())
  unregisterMessage(#ig_store_gameplayer_info, me.getID())
  unregisterMessage(#ig_user_left_game, me.getID())
  me.clear()
  return me.ancestor.deconstruct()
end

on storeUser me, tdata
  if not listp(tdata) then
    return 0
  end if
  tID = tdata.getaProp(#id)
  pPlayerData.setaProp(tID, tdata)
  tRoomIndex = tdata.getaProp(#room_index)
  if not voidp(tRoomIndex) then
    pRoomIndexIndex.setaProp(tRoomIndex, tID)
  end if
  return 1
end

on userLeftGame me, tRoomIndex
  if voidp(tRoomIndex) then
    return 0
  end if
  tPlayerData = me.getPlayerInfoByRoomIndex(tRoomIndex)
  if tPlayerData = 0 then
    return 0
  end if
  tPlayerData.setaProp(#disconnected, 1)
  return 1
end

on clear me
  me.pData = [:]
  pPlayerData = [:]
  pRoomIndexIndex = [:]
end

on getPlayerIdByRoomIndex me, tRoomIndex
  if voidp(tRoomIndex) then
    return -1
  end if
  tID = pRoomIndexIndex.getaProp(tRoomIndex)
  if voidp(tID) then
    return -1
  end if
  return tID
end

on getPlayerInfo me, tPlayerId
  if pPlayerData.getaProp(tPlayerId) = 0 then
    put "Not found!" && pPlayerData
  end if
  if voidp(tPlayerId) then
    return 0
  end if
  return pPlayerData.getaProp(tPlayerId)
end

on getPlayerInfoByRoomIndex me, tRoomIndex
  return me.getPlayerInfo(me.getPlayerIdByRoomIndex(tRoomIndex))
end

on dump me
  put "* GAMEDATA DUMP:"
  put "pData:" && me.pData
  put "pPlayerData:" && pPlayerData
  put "* room indexes:" && pRoomIndexIndex
end

on define me, tdata 
  me.ancestor.define(tdata)
  me.setFrame(tdata.getAt(#objectDataStruct).getAt(#snowball_count))
  return TRUE
end

on setFrame me, tValue 
  if (tValue = void()) then
    tValue = 0
  end if
  if me.count(#pSprList) < 2 then
    return FALSE
  end if
  tsprite = me.getProp(#pSprList, 1)
  tName = tsprite.member.name
  tName = tName.getProp(#char, 1, (length(tName) - 1)) & tValue
  tsprite.member = member(getmemnum(tName))
  tsprite = me.getProp(#pSprList, 2)
  tName = tsprite.member.name
  tName = tName.getProp(#char, 1, (length(tName) - 1)) & "0"
  tsprite.member = member(getmemnum(tName))
  return TRUE
end

on animate me 
  tsprite = me.getProp(#pSprList, 2)
  tName = tsprite.member.name
  tName = tName.getProp(#char, 1, (length(tName) - 1)) & "1"
  tsprite.member = member(getmemnum(tName))
  return TRUE
end

on select me 
  tFramework = getObject(#snowwar_gamesystem)
  if (tFramework = 0) then
    return FALSE
  end if
  if tFramework.getGamestatus() <> #game_started then
    return FALSE
  end if
  if tFramework.getSpectatorModeFlag() then
    return FALSE
  end if
  if not getObject(#session).exists("user_game_index") then
    return FALSE
  end if
  if (me.getProp(#pDirection, 1) = 0) then
    return(tFramework.executeGameObjectEvent(getObject(#session).GET("user_game_index"), #send_set_target_tile, [#tile_x:me.pLocX, #tile_y:(me.pLocY + 1)]))
  else
    return(tFramework.executeGameObjectEvent(getObject(#session).GET("user_game_index"), #send_set_target_tile, [#tile_x:(me.pLocX + 1), #tile_y:me.pLocY]))
  end if
  return FALSE
end

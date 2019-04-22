on define(me, tdata)
  me.define(tdata)
  me.setFrame(tdata.getAt(#objectDataStruct).getAt(#snowball_count))
  return(1)
  exit
end

on setFrame(me, tValue)
  if tValue = void() then
    tValue = 0
  end if
  if me.count(#pSprList) < 2 then
    return(0)
  end if
  tsprite = me.getProp(#pSprList, 1)
  tName = member.name
  tName = tName.getProp(#char, 1, length(tName) - 1) & tValue
  tsprite.member = member(getmemnum(tName))
  tsprite = me.getProp(#pSprList, 2)
  tName = member.name
  tName = tName.getProp(#char, 1, length(tName) - 1) & "0"
  tsprite.member = member(getmemnum(tName))
  return(1)
  exit
end

on animate(me)
  tsprite = me.getProp(#pSprList, 2)
  tName = member.name
  tName = tName.getProp(#char, 1, length(tName) - 1) & "1"
  tsprite.member = member(getmemnum(tName))
  return(1)
  exit
end

on select(me)
  tFramework = getObject(#snowwar_gamesystem)
  if tFramework = 0 then
    return(0)
  end if
  if tFramework.getGamestatus() <> #game_started then
    return(0)
  end if
  if tFramework.getSpectatorModeFlag() then
    return(0)
  end if
  if not getObject(#session).exists("user_game_index") then
    return(0)
  end if
  if me.getProp(#pDirection, 1) = 0 then
    return(tFramework.executeGameObjectEvent(getObject(#session).GET("user_game_index"), #send_set_target_tile, [#tile_x:me.pLocX, #tile_y:me.pLocY + 1]))
  else
    return(tFramework.executeGameObjectEvent(getObject(#session).GET("user_game_index"), #send_set_target_tile, [#tile_x:me.pLocX + 1, #tile_y:me.pLocY]))
  end if
  return(0)
  exit
end
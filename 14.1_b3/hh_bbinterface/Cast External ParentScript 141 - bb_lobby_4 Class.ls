on construct me
  me.setLoungePalette("4")
  executeMessage(#gamesystem_getfacade, getVariable("bb.loungesystem.id"))
  return 1
end

on deconstruct me
  executeMessage(#gamesystem_removefacade, getVariable("bb.loungesystem.id"))
  return 1
end

on setLoungePalette me, tid
  tExcludeList = ["adframe_bb_game_right", "bb_spot_blue", "bb_spot_yellow", "bb_spot_red", "bb_spot_green"]
  tCastLib = "hh_room_bb_game"
  tMemberCount = the number of castMembers of castLib tCastLib
  if getmemnum("bb_colors_" & tid) = 0 then
    return error(me, "Cannot determine palette for lounge" && tid, #setLoungePalette)
  end if
  tPaletteMem = member(getmemnum("bb_colors_" & tid))
  repeat with i = 1 to tMemberCount
    tmember = member(i, tCastLib)
    if (tmember.type = #bitmap) and (tExcludeList.getPos(tmember.name) = 0) then
      tmember.paletteRef = tPaletteMem
    end if
  end repeat
end

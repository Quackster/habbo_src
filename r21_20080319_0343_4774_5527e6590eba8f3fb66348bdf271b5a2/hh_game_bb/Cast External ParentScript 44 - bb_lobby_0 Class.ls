on construct me
  executeMessage(#gamesystem_getfacade, getVariable("bb.loungesystem.id"))
  return 1
end

on deconstruct me
  executeMessage(#gamesystem_removefacade, getVariable("bb.loungesystem.id"))
  return 1
end

on setLoungePalette me, tID
  tExcludeList = ["adframe_bb_game_right", "bb_spot_blue", "bb_spot_yellow", "bb_spot_red", "bb_spot_green"]
  tCastLib = "hh_game_bb_room"
  tMemberCount = the number of castMembers of castLib tCastLib
  if getmemnum("bb_colors_" & tID) = 0 then
    return error(me, "Cannot determine palette for lounge" && tID, #setLoungePalette)
  end if
  tPaletteMem = member(getmemnum("bb_colors_" & tID))
  repeat with i = 1 to tMemberCount
    tmember = member(i, tCastLib)
    if (tmember.type = #bitmap) and (tExcludeList.getPos(tmember.name) = 0) then
      tmember.paletteRef = tPaletteMem
    end if
  end repeat
end

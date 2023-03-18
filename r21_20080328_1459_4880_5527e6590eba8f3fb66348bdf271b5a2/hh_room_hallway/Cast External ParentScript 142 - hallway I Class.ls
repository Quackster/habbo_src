on construct me
  tCastLib = "hh_room_hallway"
  tMemberCount = the number of castMembers of castLib tCastLib
  repeat with i = 1 to tMemberCount
    tmember = member(i, tCastLib)
    if tmember.type = #bitmap then
      tmember.paletteRef = member(getmemnum("Hallway Palette 1"))
    end if
  end repeat
  return 1
end

on deconstruct me
  return 1
end

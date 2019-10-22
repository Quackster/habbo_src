on construct me 
  tCastLib = "hh_room_hallway"
  tMemberCount = the number of castMembers
  i = 1
  repeat while i <= tMemberCount
    tmember = member(i, tCastLib)
    if (tmember.type = #bitmap) then
      tmember.paletteRef = member(getmemnum("Hallway Palette 2"))
    end if
    i = (1 + i)
  end repeat
  return TRUE
end

on deconstruct me 
  return TRUE
end

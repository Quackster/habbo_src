on construct(me)
  tCastLib = "hh_room_hallway"
  tMemberCount = the number of castMembers
  i = 1
  repeat while i <= tMemberCount
    tmember = member(i, tCastLib)
    if tmember.type = #bitmap then
      tmember.paletteRef = member(getmemnum("Hallway Palette 1"))
    end if
    i = 1 + i
  end repeat
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end
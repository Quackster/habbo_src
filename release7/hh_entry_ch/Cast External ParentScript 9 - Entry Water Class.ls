property pAnimFrm, pRefresh, pMember

on construct me
  pAnimFrm = 0
  pRefresh = 1
  pMember = member(getmemnum("animated_lake"))
  return 1
end

on update me
  pRefresh = not pRefresh
  if pRefresh then
    pMember.paletteRef = member(getmemnum("water" & pAnimFrm & "_palette"))
    pAnimFrm = (pAnimFrm + 1) mod 8
  end if
end

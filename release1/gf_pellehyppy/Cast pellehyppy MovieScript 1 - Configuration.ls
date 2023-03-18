global gXFactor, gYFactor, gHFactor, xoffset, yoffset, gWorldType

on checkOffsets
  global goJumper, gPellePlayer
  gXFactor = 32.0
  gYFactor = 16.0
  gHFactor = 8.0
  set the scriptInstanceList of sprite 40 to []
  goJumper = VOID
  gPellePlayer = VOID
  if gWorldType = "pool_b" then
    xoffset = 200
    yoffset = 38
  else
    if gWorldType = "pool_a" then
      xoffset = 440
      yoffset = 6
    end if
  end if
end

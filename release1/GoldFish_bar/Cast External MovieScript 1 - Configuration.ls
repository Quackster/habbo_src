global gXFactor, gYFactor, gHFactor, xoffset, yoffset, gWorldType

on checkOffsets
  gXFactor = 32.0
  gYFactor = 16.0
  gHFactor = 16.0
  if gWorldType = "bar_b" then
    xoffset = 424
    yoffset = 152
  else
    if gWorldType = "bar_a" then
      xoffset = 423
      yoffset = 184
    end if
  end if
end

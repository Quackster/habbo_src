global gXFactor, gYFactor, gHFactor, xoffset, yoffset, gWorldType

on checkOffsets
  gXFactor = 32.0
  gYFactor = 16.0
  gHFactor = 16.0
  if gWorldType = "malja_bar_b" then
    xoffset = 393
    yoffset = 205
  else
    if gWorldType = "malja_bar_a" then
      xoffset = 406
      yoffset = 168
    end if
  end if
end

global gXFactor, gYFactor, gHFactor, xoffset, yoffset

on checkOffsets
  gXFactor = 32.0
  gYFactor = 16.0
  gHFactor = 16.0
  xoffset = 271
  yoffset = 183
end

on printmems
  s = EMPTY
  repeat with i = 1 to 1000
    if sprite(i).member.number > 0 then
      put i && sprite(i).member.name && sprite(i).member after s
    else
      put i after s
    end if
    put RETURN after s
  end repeat
  return s
end

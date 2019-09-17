on checkOffsets  
  gXFactor = 32
  gYFactor = 16
  gHFactor = 8
  xoffset = 268
  yoffset = 93
end

on printmems  
  s = ""
  i = 1
  repeat while i <= 1000
    if sprite(i).member.number > 0 then
    else
    end if
    i = 1 + i
  end repeat
  return(s)
end

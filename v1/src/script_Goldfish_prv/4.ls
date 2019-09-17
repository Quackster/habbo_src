on setFloor code 
  patternSet = NULL
  gFloor = code
  if getmemnum(patternSet) > 0 then
    ln = code mod 100
    if getmemnum(patternSet) > the number of line in field(0) then
      ln = the number of line in field(0)
    end if
    pattern = NULL
    sendSprite(gPrvFloorSpr, #setPattern, pattern)
  end if
end

on setWallPaper code 
  patternSet = NULL
  gWallPaper = code
  if getmemnum(patternSet) > 0 then
    ln = code mod 100
    if getmemnum(patternSet) > the number of line in field(0) then
      ln = the number of line in field(0)
    end if
    pattern = NULL
    sendAllSprites(#setWallPattern, pattern)
  end if
end

global gPrvFloorSpr, gWallPaper, gFloor

on setFloor code
  patternSet = line code / 100 of field "floorpattern_patterns"
  gFloor = code
  if getmemnum(patternSet) > 0 then
    ln = code mod 100
    if ln > the number of lines in field getmemnum(patternSet) then
      ln = the number of lines in field getmemnum(patternSet)
    end if
    pattern = line ln of field getmemnum(patternSet)
    sendSprite(gPrvFloorSpr, #setPattern, pattern)
  end if
end

on setWallPaper code
  patternSet = line code / 100 of field "wallpattern_patterns"
  gWallPaper = code
  if getmemnum(patternSet) > 0 then
    ln = code mod 100
    if ln > the number of lines in field getmemnum(patternSet) then
      ln = the number of lines in field getmemnum(patternSet)
    end if
    pattern = line ln of field getmemnum(patternSet)
    sendAllSprites(#setWallPattern, pattern)
  end if
end

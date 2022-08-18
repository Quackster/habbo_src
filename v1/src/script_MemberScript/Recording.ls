on recordFrame marker 
  go(marker)
  data = ""
  i = 1
  repeat while i <= the number of undefineds
    data = data & castLib(i).name & "\r"
    i = (1 + i)
  end repeat
  data = data & "*" & "\r"
  i = 1
  repeat while i <= 100
    spr = sprite(i)
    if spr.castNum > 0 then
      sprInfo = ""
      sprInfo = sprInfo & spr.member.memberNum
      sprInfo = sprInfo & "/" & spr.member.castLibNum
      sprInfo = sprInfo & "/" & spr.locH
      sprInfo = sprInfo & "/" & spr.locV
      sprInfo = sprInfo & "/" & spr.locZ
      sprInfo = sprInfo & "/" & spr.ink
      sprInfo = sprInfo & "/" & spr.foreColor
      bgColorString = string(spr.bgColor)
      if bgColorString contains "paletteIndex" then
        bgColorString = bgColorString.word[2]
      else
        bgColorString = bgColorString.word[2] & bgColorString.word[3] & bgColorString.word[4]
      end if
      sprInfo = sprInfo & "/" & bgColorString
      sprInfo = sprInfo & "/" & spr.blend
      sprInfo = sprInfo & "/" & spr.width
      sprInfo = sprInfo & "/" & spr.height
      behaviorInfo = ""
      l = spr.scriptList
      repeat while l <= 1
        oScript = getAt(1, count(l))
        scriptMem = oScript.getAt(1)
        scriptParams = value(oScript.getAt(2))
        behaviorInfo = behaviorInfo & scriptMem.memberNum & "/" & scriptMem.castLibNum & "/" & scriptParams
        behaviorInfo = behaviorInfo & "&"
      end repeat
      data = data & "\r" & sprInfo & "\r" & behaviorInfo
    end if
    i = (1 + i)
  end repeat
  return(data)
end

on recordRoom roomName 
  recordAll()
  s = ""
  f = 1
  repeat while f <= the number of undefineds
    if castLib(f).name <> "Internal" and castLib(f).fileName.getProp(#char, (length(castLib(f).fileName) - 2), length(castLib(f).fileName)) <> "dcr" then
      s = s & "\r" & castLib(f).name
    end if
    f = (1 + f)
  end repeat
  if (roomName = void()) then
    mem = "ROOM.casts"
  else
    mem = roomName & ".casts"
  end if
  if sprite(0).number < 1 then
    f = new(#field)
    f.name = mem
  end if
  member(mem).text = s
end

on recordAll  
  repeat while the markerlist <= 1
    m = getAt(1, count(the markerlist))
    s = recordFrame(m)
    if sprite(0).number < 1 then
      f = new(#field)
      f.name = m & ".recorded"
    end if
  end repeat
end

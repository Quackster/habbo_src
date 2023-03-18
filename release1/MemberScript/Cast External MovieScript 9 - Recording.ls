on recordFrame marker
  go(marker)
  data = EMPTY
  repeat with i = 1 to the number of castLibs
    data = data & castLib(i).name & RETURN
  end repeat
  data = data & "*" & RETURN
  repeat with i = 1 to 100
    spr = sprite(i)
    if spr.castNum > 0 then
      sprInfo = EMPTY
      sprInfo = sprInfo & spr.member.memberNum
      sprInfo = sprInfo & "/" & spr.member.castLibNum
      sprInfo = sprInfo & "/" & spr.locH
      sprInfo = sprInfo & "/" & spr.locV
      sprInfo = sprInfo & "/" & spr.locZ
      sprInfo = sprInfo & "/" & spr.ink
      sprInfo = sprInfo & "/" & spr.foreColor
      bgColorString = string(spr.bgColor)
      if bgColorString contains "paletteIndex" then
        bgColorString = word 2 of bgColorString
      else
        bgColorString = word 2 of bgColorString & word 3 of bgColorString & word 4 of bgColorString
      end if
      sprInfo = sprInfo & "/" & bgColorString
      sprInfo = sprInfo & "/" & spr.blend
      sprInfo = sprInfo & "/" & spr.width
      sprInfo = sprInfo & "/" & spr.height
      behaviorInfo = EMPTY
      l = spr.scriptList
      repeat with oScript in l
        scriptMem = oScript[1]
        scriptParams = value(oScript[2])
        behaviorInfo = behaviorInfo & scriptMem.memberNum & "/" & scriptMem.castLibNum & "/" & scriptParams
        behaviorInfo = behaviorInfo & "&"
      end repeat
      data = data & RETURN & sprInfo & RETURN & behaviorInfo
    end if
  end repeat
  return data
end

on recordRoom roomName
  recordAll()
  s = EMPTY
  repeat with f = 1 to the number of castLibs
    if (castLib(f).name <> "Internal") and (castLib(f).fileName.char[length(castLib(f).fileName) - 2..length(castLib(f).fileName)] <> "dcr") then
      s = s & RETURN & castLib(f).name
    end if
  end repeat
  if roomName = VOID then
    mem = "ROOM.casts"
  else
    mem = roomName & ".casts"
  end if
  if the number of member mem < 1 then
    f = new(#field)
    f.name = mem
  end if
  member(mem).text = s
end

on recordAll
  repeat with m in the markerlist
    s = recordFrame(m)
    if the number of member (m & ".recorded") < 1 then
      f = new(#field)
      f.name = m & ".recorded"
    end if
    put s into field (m & ".recorded")
  end repeat
end

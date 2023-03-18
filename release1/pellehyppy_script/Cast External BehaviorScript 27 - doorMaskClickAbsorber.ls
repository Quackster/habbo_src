global gpShowSprites

on mouseDown me
  spr = getaProp(gpShowSprites, "door")
  if spr > 0 then
    sendSprite(spr, #returnMode)
    if the result = #close then
      nothing()
      dontPassEvent()
    end if
  end if
end

on mouseUp me
  spr = getaProp(gpShowSprites, "door")
  if spr > 0 then
    sendSprite(spr, #returnMode)
    if the result = #close then
      nothing()
      dontPassEvent()
    end if
  end if
end

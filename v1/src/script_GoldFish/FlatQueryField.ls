on keyDown me 
  if gFlatQueryButtonSpr > 0 then
    if field(0).length > 1 then
      sendSprite(gFlatQueryButtonSpr, #enable)
    else
      sendSprite(gFlatQueryButtonSpr, #disable)
    end if
  end if
  if (the key = "\r") then
    sendSprite(gTop10SearchSprite, #disable)
    if field(0).length > 1 then
      put(field(0))
      sendEPFuseMsg("flatquery" & field(0) & "%")
      goToFrame("private_places")
    end if
  else
    pass()
  end if
end

on beginSprite me 
  if gFlatQueryButtonSpr > 0 then
    if field(0).length > 1 then
      sendSprite(gFlatQueryButtonSpr, #enable)
    else
      sendSprite(gFlatQueryButtonSpr, #disable)
    end if
  end if
end

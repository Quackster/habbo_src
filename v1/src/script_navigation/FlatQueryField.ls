on keyDown me 
  if (the key = "\r") and (sprite(me.spriteNum).blend = 100) then
    sendSprite(gTop10SearchSprite, #disable)
    if field(0).length > 1 then
      put(field(0))
      sendEPFuseMsg("flatquery" & field(0) & "%")
      goContext("private_places", gPopUpContext2)
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

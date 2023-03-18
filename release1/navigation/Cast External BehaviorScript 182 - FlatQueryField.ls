global gFlatQueryButtonSpr, gTop10SearchSprite, gPopUpContext2

on keyDown me
  if (the key = RETURN) and (sprite(me.spriteNum).blend = 100) then
    sendSprite(gTop10SearchSprite, #disable)
    if field("flatquery").length > 1 then
      put field("flatquery")
      sendEPFuseMsg("SEARCHFLAT" && "/%" & field("flatquery") & "%")
      goContext("private_places", gPopUpContext2)
    end if
  else
    pass()
  end if
end

on beginSprite me
  if gFlatQueryButtonSpr > 0 then
    if field("flatquery").length > 1 then
      sendSprite(gFlatQueryButtonSpr, #enable)
    else
      sendSprite(gFlatQueryButtonSpr, #disable)
    end if
  end if
end

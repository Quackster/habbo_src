global whichIsFirstNow, MaxVisibleIndexButton

on enterFrame me
  if whichIsFirstNow = 1 then
    sprite(me.spriteNum).member = "navi_left_arrow_NoMore"
  else
    sprite(me.spriteNum).member = "navi_left_arrow"
  end if
end

on mouseDown me
  if whichIsFirstNow > 1 then
    sprite(me.spriteNum).member = "navi_left_arrow_hi"
    sendAllSprites(#ScrollCatalogIndex, "left")
  else
    sprite(me.spriteNum).member = "navi_left_arrow_NoMore"
  end if
end

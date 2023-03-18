global whichIsFirstNow, MaxVisibleIndexButton

on enterFrame me
  if (whichIsFirstNow + MaxVisibleIndexButton - 1) = member("CatalogPage_index").line.count then
    sprite(me.spriteNum).member = "navi_right_arrow_NoMore"
  else
    sprite(me.spriteNum).member = "navi_right_arrow"
  end if
end

on mouseDown me
  if (whichIsFirstNow + MaxVisibleIndexButton - 1) < member("CatalogPage_index").line.count then
    sprite(me.spriteNum).member = "navi_right_arrow_hi"
    sendAllSprites(#ScrollCatalogIndex, "right")
  else
    sprite(me.spriteNum).member = "navi_right_arrow_NoMore"
  end if
end

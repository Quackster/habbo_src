property Active
global gNaviWindowsSpr, gNaviUpBtn, gNaviDownBtn, ScrollBarLiftBtn

on beginSprite me
  Active = 1
  gNaviDownBtn = me.spriteNum
end

on ActiveOrNotScrollDownBtn me, Acti
  if Acti = 1 then
    Active = 1
    sprite(me.spriteNum).member = "scroll_Down_active"
  else
    Active = 0
    sprite(me.spriteNum).member = "scroll_Down_inactive"
  end if
end

on mouseDown me
  if Active = 1 then
    sprite(me.spriteNum).member = "scroll_Down_active_hi"
    sendSprite(gNaviWindowsSpr, #ScrollNavigatorWindow, "Down")
  end if
end

on mouseUp me
  if Active = 1 then
    sprite(me.spriteNum).member = "scroll_Down_active"
  else
    sprite(me.spriteNum).member = "scroll_Down_inactive"
  end if
end

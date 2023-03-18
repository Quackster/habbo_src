property Active
global gNaviWindowsSpr, gNaviUpBtn, gNaviDownBtn, ScrollBarLiftBtn

on beginSprite me
  Active = 1
  gNaviUpBtn = me.spriteNum
end

on ActiveOrNotScrollUpBtn me, Acti
  if Acti = 1 then
    Active = 1
    sprite(me.spriteNum).member = "scroll_up_active"
  else
    Active = 0
    sprite(me.spriteNum).member = "scroll_up_inactive"
  end if
end

on mouseDown me
  if Active = 1 then
    sprite(me.spriteNum).member = "scroll_up_active_hi"
    sendSprite(gNaviWindowsSpr, #ScrollNavigatorWindow, "Up")
  end if
end

on mouseUp me
  if Active = 1 then
    sprite(me.spriteNum).member = "scroll_up_active"
  else
    sprite(me.spriteNum).member = "scroll_up_inactive"
  end if
end

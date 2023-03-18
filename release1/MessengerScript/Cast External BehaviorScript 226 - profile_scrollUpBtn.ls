property Active
global gProfileWindowsSpr, gProfileUpBtn, gProfileDownBtn, ProfileScrollProfileBarLiftBtn

on beginSprite me
  Active = 1
  gProfileUpBtn = me.spriteNum
end

on ActiveOrNotScrollUpBtn me, Acti
  if Acti = 1 then
    Active = 1
    sprite(me.spriteNum).member = "messenger_scrollup active"
  else
    Active = 0
    sprite(me.spriteNum).member = "messenger_scrollup inactive"
  end if
end

on mouseDown me
  if Active = 1 then
    sprite(me.spriteNum).member = "messenger_scrollup hi"
    sendSprite(gProfileWindowsSpr, #ScrollProfilegatorWindow, "Up")
  end if
end

on mouseUp me
  if Active = 1 then
    sprite(me.spriteNum).member = "messenger_scrollup active"
  else
    sprite(me.spriteNum).member = "messenger_scrollup inactive"
  end if
end

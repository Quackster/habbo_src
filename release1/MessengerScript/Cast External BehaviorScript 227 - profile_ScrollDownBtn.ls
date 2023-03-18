property Active
global gProfileWindowsSpr, gProfileUpBtn, gProfileDownBtn, ProfileScrollProfileBarLiftBtn

on beginSprite me
  Active = 1
  gProfileDownBtn = me.spriteNum
end

on ActiveOrNotScrollDownBtn me, Acti
  if Acti = 1 then
    Active = 1
    sprite(me.spriteNum).member = "messenger_scrolldown active"
  else
    Active = 0
    sprite(me.spriteNum).member = "messenger_scrolldown inactive"
  end if
end

on mouseDown me
  if Active = 1 then
    sprite(me.spriteNum).member = "messenger_scrolldown hi"
    sendSprite(gProfileWindowsSpr, #ScrollProfilegatorWindow, "Down")
  end if
end

on mouseUp me
  if Active = 1 then
    sprite(me.spriteNum).member = "messenger_scrolldown active"
  else
    sprite(me.spriteNum).member = "messenger_scrolldown inactive"
  end if
end

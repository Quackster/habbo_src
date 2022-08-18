property moveME

on beginSprite me 
  Active = 1
  moveME = 0
  ScrollProfileBarLiftBtn = me.spriteNum
end

on ActiveOrNotScrollDownBtn me, Acti 
  if (Acti = 1) then
    Active = 1
    sprite(me.spriteNum).member = "lift_gfx"
  else
    Active = 0
    sprite(me.spriteNum).member = "lift_gfx"
  end if
end

on mouseDown me 
  moveME = 1
end

on mouseUp me 
  moveME = 0
end

on LiftPosiotion me, LineNow, maxlines 
  percentNow = (float(LineNow) / float(maxlines))
  if percentNow > 1 then
    percentNow = 1
    sendSprite(gProfileWindowsSpr, #ScrollWhithLift, percentNow)
  end if
  moveArea = (((sprite(gProfileDownBtn).top - sprite(gProfileUpBtn).bottom) - sprite(me.spriteNum).height) - 2)
  spritePercent = integer((percentNow * moveArea))
  sprite(me.spriteNum).locV = (((sprite(gProfileUpBtn).bottom + spritePercent) + (sprite(me.spriteNum).height / 2)) + 1)
end

on MyPercentNow me 
  percentNow = (float((sprite(me.spriteNum).locV - ((sprite(gProfileUpBtn).bottom + (sprite(me.spriteNum).height / 2)) + 1))) / float((((sprite(gProfileDownBtn).top - sprite(gProfileUpBtn).bottom) - sprite(me.spriteNum).height) - 2)))
  return(percentNow)
end

on enterFrame me 
  if (rollover(me.spriteNum) = 0) and (the mouseDown = 0) then
    moveME = 0
  end if
  if (moveME = 1) then
    MyLocV = the mouseV
    if (MyLocV - (sprite(me.spriteNum).height / 2)) < sprite(gProfileUpBtn).bottom then
      MyLocV = ((sprite(gProfileUpBtn).bottom + (sprite(me.spriteNum).height / 2)) + 1)
    end if
    if (MyLocV + (sprite(me.spriteNum).height / 2)) > sprite(gProfileDownBtn).top then
      MyLocV = ((sprite(gProfileDownBtn).top - (sprite(me.spriteNum).height / 2)) - 2)
    end if
    sprite(me.spriteNum).locV = MyLocV
    MyPercentNow(me)
    sendSprite(gProfileWindowsSpr, #ScrollWhithLift, the result)
  end if
end

property moveME

on beginSprite me 
  Active = 0
  moveME = 0
  ScrollBarLiftBtn = me.spriteNum
end

on ActiveOrNotScrollDownBtn me, Acti 
  if (Acti = 1) then
    Active = 1
    sprite(me.spriteNum).visible = 1
  else
    Active = 0
  end if
end

on mouseDown me 
  moveME = 1
  sprite(me.spriteNum).member = "scroll_lift hi"
end

on mouseUp me 
  moveME = 0
  sprite(me.spriteNum).member = "scroll_lift"
end

on NaviLiftPosiotion me, LineNow, maxlines 
  if maxlines <> 0 then
    if (LineNow = 1) then
      percentNow = 0
    else
      percentNow = (float(LineNow) / float(maxlines))
      if percentNow > 1 then
        percentNow = 1
        sendSprite(gNaviWindowsSpr, #NaviScrollWhithLift, percentNow)
      end if
    end if
    moveArea = (((sprite(gNaviDownBtn).top - sprite(gNaviUpBtn).bottom) - sprite(me.spriteNum).height) + 2)
    spritePercent = integer((percentNow * moveArea))
    sprite(me.spriteNum).locV = ((sprite(gNaviUpBtn).bottom + spritePercent) + (sprite(me.spriteNum).height / 2))
  end if
end

on MyPercentNow me 
  percentNow = (float((sprite(me.spriteNum).locV - ((sprite(gNaviUpBtn).bottom + (sprite(me.spriteNum).height / 2)) + 1))) / float((((sprite(gNaviDownBtn).top - sprite(gNaviUpBtn).bottom) - sprite(me.spriteNum).height) - 2)))
  return(percentNow)
end

on enterFrame me 
  if (rollover(me.spriteNum) = 0) and (the mouseDown = 0) then
    moveME = 0
    sprite(me.spriteNum).member = "scroll_lift"
  end if
  if (moveME = 1) then
    MyLocV = the mouseV
    if (MyLocV - (sprite(me.spriteNum).height / 2)) < sprite(gNaviUpBtn).bottom then
      MyLocV = (sprite(gNaviUpBtn).bottom + (sprite(me.spriteNum).height / 2))
    end if
    if (MyLocV + (sprite(me.spriteNum).height / 2)) > sprite(gNaviDownBtn).top then
      MyLocV = (sprite(gNaviDownBtn).top - (sprite(me.spriteNum).height / 2))
    end if
    sprite(me.spriteNum).locV = MyLocV
    MyPercentNow(me)
    sendSprite(gNaviWindowsSpr, #NaviScrollWhithLift, the result)
  end if
end

property textMember, lineH, ScrollDownBtn, ScrollUpBtn, moveME

on beginSprite me 
  Active = 1
  moveME = 0
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
  activeOrNot(me)
end

on mouseUp me 
  moveME = 0
  activeOrNot(me)
end

on IWannaScrollByLift me, percentNow 
  member(textMember).scrollTop = (integer((((member(textMember).height - member(textMember).pageHeight) / lineH) * percentNow)) * lineH)
end

on activeOrNot me 
end

on TextLiftPosiotion me 
  LineNow = (member(textMember).scrollTop / lineH)
  maxlines = ((member(textMember).height - member(textMember).pageHeight) / lineH)
  if maxlines <> 0 then
    percentNow = (float(LineNow) / float(maxlines))
    if percentNow > 1 then
      percentNow = 1
    end if
    moveArea = (((sprite(ScrollDownBtn).top - sprite(ScrollUpBtn).bottom) - sprite(me.spriteNum).height) - 2)
    spritePercent = integer((percentNow * moveArea))
    sprite(me.spriteNum).locV = (((sprite(ScrollUpBtn).bottom + spritePercent) + (sprite(me.spriteNum).height / 2)) + 1)
    sendSprite(ScrollUpBtn, #activeOrNot)
    sendSprite(ScrollDownBtn, #activeOrNot)
  end if
end

on MyPercentNow me 
  percentNow = (float((sprite(me.spriteNum).locV - ((sprite(ScrollUpBtn).bottom + (sprite(me.spriteNum).height / 2)) + 1))) / float((((sprite(ScrollDownBtn).top - sprite(ScrollUpBtn).bottom) - sprite(me.spriteNum).height) - 2)))
  return(percentNow)
end

on enterFrame me 
  ScrollUpBtn = (TextScrollBarSpr + 1)
  ScrollDownBtn = (TextScrollBarSpr + 2)
  if (rollover(me.spriteNum) = 0) and (the mouseDown = 0) then
    moveME = 0
  end if
  if (moveME = 1) then
    MyLocV = the mouseV
    if (MyLocV - (sprite(me.spriteNum).height / 2)) < sprite(ScrollUpBtn).bottom then
      MyLocV = ((sprite(ScrollUpBtn).bottom + (sprite(me.spriteNum).height / 2)) + 1)
    end if
    if (MyLocV + (sprite(me.spriteNum).height / 2)) > sprite(ScrollDownBtn).top then
      MyLocV = ((sprite(ScrollDownBtn).top - (sprite(me.spriteNum).height / 2)) - 2)
    end if
    sprite(me.spriteNum).locV = MyLocV
    MyPercentNow(me)
    IWannaScrollByLift(me, the result)
  end if
  sendSprite(ScrollUpBtn, #activeOrNot)
  sendSprite(ScrollDownBtn, #activeOrNot)
  if (member(textMember).height / lineH) <= (member(textMember).pageHeight / lineH) then
    sprite(me.spriteNum).locH = 2000
  else
    sprite(me.spriteNum).locH = sprite(ScrollUpBtn).locH
  end if
end

on getPropertyDescriptionList me 
  pList = [:]
  addProp(pList, #textMember, [#comment:"Scroll memberName is", #format:#string, #default:"memberName"])
  addProp(pList, #lineH, [#comment:"Line height of text member", #default:9, #format:#integer])
  return(pList)
end

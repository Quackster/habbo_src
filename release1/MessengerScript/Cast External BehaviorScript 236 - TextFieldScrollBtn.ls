property num, textMember, LiftBtnSpr, lineH
global TextScrollBarSpr

on beginSprite me
  activeOrNot(me)
  LiftBtnSpr = TextScrollBarSpr + 3
end

on mouseWithin me
  if the mouseDown and (word 2 of the name of the member of sprite(the spriteNum of me) = "active") then
    if word 2 of the name of the member of sprite(the spriteNum of me) = "active" then
      sprite(me.spriteNum).castNum = getmemnum(word 1 of the name of the member of sprite(the spriteNum of me) && "hi")
    end if
  else
    activeOrNot(me)
  end if
end

on mouseUp me
  activeOrNot(me)
end

on activeOrNot me
  if sprite(me.spriteNum).member.name contains "Up" then
    if (member(textMember).scrollTop / lineH) = 0 then
      sprite(me.spriteNum).castNum = getmemnum(word 1 of the name of the member of sprite(the spriteNum of me) && "inactive")
    else
      sprite(me.spriteNum).castNum = getmemnum(word 1 of the name of the member of sprite(the spriteNum of me) && "active")
    end if
  end if
  if sprite(me.spriteNum).member.name contains "Down" then
    if (((member(textMember).height - member(textMember).pageHeight) / lineH) < 0) or ((member(textMember).scrollTop / lineH) = ((member(textMember).height - member(textMember).pageHeight) / lineH)) then
      sprite(me.spriteNum).castNum = getmemnum(word 1 of the name of the member of sprite(the spriteNum of me) && "inactive")
    else
      sprite(me.spriteNum).castNum = getmemnum(word 1 of the name of the member of sprite(the spriteNum of me) && "active")
    end if
  end if
end

on ScrollText num
  scrollByLine(member(textMember), num)
end

on mouseDown me
  activeOrNot(me)
  if (word 2 of the name of the member of sprite(the spriteNum of me) = "active") or (word 2 of the name of the member of sprite(the spriteNum of me) = "hi") then
    ScrollText(num)
    sendSprite(LiftBtnSpr, #TextLiftPosiotion)
  end if
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #textMember, [#comment: "Scroll memberName is", #format: #string, #default: "memberName"])
  addProp(pList, #lineH, [#comment: "Line height of text member", #default: 9, #format: #integer])
  addProp(pList, #num, [#comment: "Num to scroll", #default: 1, #format: #integer])
  return pList
end

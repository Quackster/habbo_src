property textMember, lineH, num, LiftBtnSpr

on beginSprite me 
  activeOrNot(me)
  LiftBtnSpr = (TextScrollBarSpr + 3)
end

on mouseWithin me 
  if the mouseDown and (sprite(me.spriteNum).member.name.word[2] = "active") then
    if (sprite(me.spriteNum).member.name.word[2] = "active") then
      sprite(me.spriteNum).castNum = getmemnum(sprite(me.spriteNum).member.name.word[1] && "hi")
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
    if ((member(textMember).scrollTop / lineH) = 0) then
      sprite(me.spriteNum).castNum = getmemnum(sprite(me.spriteNum).member.name.word[1] && "inactive")
    else
      sprite(me.spriteNum).castNum = getmemnum(sprite(me.spriteNum).member.name.word[1] && "active")
    end if
  end if
  if sprite(me.spriteNum).member.name contains "Down" then
    if ((member(textMember).height - member(textMember).pageHeight) / lineH) < 0 or ((member(textMember).scrollTop / lineH) = ((member(textMember).height - member(textMember).pageHeight) / lineH)) then
      sprite(me.spriteNum).castNum = getmemnum(sprite(me.spriteNum).member.name.word[1] && "inactive")
    else
      sprite(me.spriteNum).castNum = getmemnum(sprite(me.spriteNum).member.name.word[1] && "active")
    end if
  end if
end

on ScrollText num 
  scrollByLine(member(textMember), num)
end

on mouseDown me 
  activeOrNot(me)
  if (sprite(me.spriteNum).member.name.word[2] = "active") or (sprite(me.spriteNum).member.name.word[2] = "hi") then
    ScrollText(num)
    sendSprite(LiftBtnSpr, #TextLiftPosiotion)
  end if
end

on getPropertyDescriptionList me 
  pList = [:]
  addProp(pList, #textMember, [#comment:"Scroll memberName is", #format:#string, #default:"memberName"])
  addProp(pList, #lineH, [#comment:"Line height of text member", #default:9, #format:#integer])
  addProp(pList, #num, [#comment:"Num to scroll", #default:1, #format:#integer])
  return(pList)
end

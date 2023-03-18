property textMember, lineH, limit
global TextScrollBarSpr, gMessageFieldSpr

on beginSprite me
  limit = 255
  the keyboardFocusSprite = me.spriteNum
  gMessageFieldSpr = me.spriteNum
  if member(textMember).char.count = 0 then
    member("message.charCount").text = "0/" & limit
  end if
end

on setLimit me, tlimit
  limit = tlimit
  if member(textMember).char.count > limit then
    member(textMember).text = member(textMember).text.char[1..limit]
  end if
  member("message.charCount").text = member(textMember).char.count & "/" & limit
end

on keyDown me
  if member(textMember).height > member(textMember).pageHeight then
    if member(textMember).scrollTop < (member(textMember).height - member(textMember).pageHeight) then
      scrollByLine(member(textMember), 1)
      ScrollUpBtn = TextScrollBarSpr + 1
      ScrollDownBtn = TextScrollBarSpr + 2
      LiftBtnSpr = TextScrollBarSpr + 3
      sendSprite(ScrollUpBtn, #activeOrNot)
      sendSprite(ScrollDownBtn, #activeOrNot)
      sendSprite(LiftBtnSpr, #TextLiftPosiotion)
    end if
  end if
  if member(textMember).char.count < limit then
    member("message.charCount").text = member(textMember).char.count + 1 & "/" & limit
    if the key = BACKSPACE then
      member("message.charCount").text = member(textMember).char.count - 1 & "/" & limit
      if (member(textMember).char.count - 1) < 0 then
        member("message.charCount").text = "0/" & limit
      end if
    end if
    pass()
  else
    if the key = BACKSPACE then
      pass()
    else
      return 
    end if
  end if
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #textMember, [#comment: "Scroll memberName is", #format: #string, #default: "memberName"])
  addProp(pList, #lineH, [#comment: "Line height of text member", #default: 9, #format: #integer])
  return pList
end

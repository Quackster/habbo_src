property textField, state

on beginSprite me
  state = "inactive"
end

on exitFrame me
  if the keyboardFocusSprite = me.spriteNum then
    state = "active"
  end if
  if (state = "active") and (the keyboardFocusSprite <> me.spriteNum) then
    state = "inactive"
    s = member(textField).text
    find = member(sprite(me.spriteNum).member).text
    oldItemDelimiter = the itemDelimiter
    the itemDelimiter = "/"
    repeat with f = 1 to s.line.count
      if s.line[f].item[1] = find then
        member(sprite(me.spriteNum).member).text = s.line[f].item[2]
        member(sprite(me.spriteNum - 1).member).text = s.line[f].item[2]
        exit repeat
      end if
    end repeat
    the itemDelimiter = oldItemDelimiter
  end if
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #textField, [#comment: "AbbreviationList field", #format: #string, #default: "CountryAbbreviationList"])
  return pList
end

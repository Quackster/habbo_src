property inputtext, FindSomething, MustInclude, state, foreShadowField, textField, ShowQuestField

on beginSprite me
  foreShadowField = member(textField).text
  inputtext = member(sprite(me.spriteNum).member).text
  FindSomething = -1
  state = "inactive"
  member(ShowQuestField).text = EMPTY
end

on keyDown me
  if the key = BACKSPACE then
    member(ShowQuestField).text = EMPTY
    member(sprite(me.spriteNum).member).text = EMPTY
    inputtext = EMPTY
  else
    if the key = TAB then
      inputtext = member(sprite(me.spriteNum).member).text
    else
      inputtext = member(sprite(me.spriteNum).member).text & the key
    end if
  end if
  FindSomething = 0
  repeat with f = 1 to foreShadowField.line.count
    if foreShadowField.line[f].char[1..length(inputtext)] = inputtext then
      member(ShowQuestField).text = inputtext & foreShadowField.line[f].char[length(inputtext) + 1..length(foreShadowField.line[f])]
      FindSomething = f
      exit repeat
    end if
  end repeat
  if FindSomething = 0 then
    if MustInclude = 1 then
      nothing()
    else
      member(ShowQuestField).text = EMPTY
    end if
  end if
  if (MustInclude = 1) and (FindSomething = 0) and (the key <> BACKSPACE) then
    nothing()
  else
    pass()
  end if
end

on exitFrame me
  if the keyboardFocusSprite = me.spriteNum then
    state = "active"
  end if
  if (FindSomething <> -1) and (state = "active") and (the keyboardFocusSprite <> me.spriteNum) then
    if FindSomething > 0 then
      member(ShowQuestField).text = EMPTY
      member(sprite(me.spriteNum).member).text = foreShadowField.line[FindSomething]
      state = "inactive"
    else
    end if
  end if
end

on endSprite me
  if FindSomething > 0 then
    member(ShowQuestField).text = EMPTY
    member(sprite(me.spriteNum).member).text = foreShadowField.line[FindSomething]
    state = "inactive"
  end if
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #textField, [#comment: "ForeShadow List field", #format: #string, #default: "CountryList"])
  addProp(pList, #ShowQuestField, [#comment: "ForeShadow Show Quest Field", #format: #string, #default: "countryname2"])
  addProp(pList, #MustInclude, [#comment: "Input text must be include ForeShadowlist", #format: #boolean, #default: 1])
  return pList
end

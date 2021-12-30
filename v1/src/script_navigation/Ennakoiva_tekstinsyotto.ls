property textField, ShowQuestField, foreShadowField, inputtext, FindSomething, MustInclude, state

on beginSprite me 
  foreShadowField = member(textField).text
  inputtext = member(sprite(me.spriteNum).member).text
  FindSomething = -1
  state = "inactive"
  member(ShowQuestField).text = ""
end

on keyDown me 
  if (the key = "\b") then
    member(ShowQuestField).text = ""
    member(sprite(me.spriteNum).member).text = ""
    inputtext = ""
  else
    if (the key = "\t") then
      inputtext = member(sprite(me.spriteNum).member).text
    else
      inputtext = member(sprite(me.spriteNum).member).text & the key
    end if
  end if
  FindSomething = 0
  f = 1
  repeat while f <= foreShadowField.count(#line)
    if (foreShadowField.getPropRef(#line, f).getProp(#char, 1, length(inputtext)) = inputtext) then
      member(ShowQuestField).text = inputtext & foreShadowField.getPropRef(#line, f).getProp(#char, (length(inputtext) + 1), length(foreShadowField.getProp(#line, f)))
      FindSomething = f
    else
      f = (1 + f)
    end if
  end repeat
  if (FindSomething = 0) then
    if (MustInclude = 1) then
      nothing()
    else
      member(ShowQuestField).text = ""
    end if
  end if
  if (MustInclude = 1) and (FindSomething = 0) and the key <> "\b" then
    nothing()
  else
    pass()
  end if
end

on exitFrame me 
  if (the keyboardFocusSprite = me.spriteNum) then
    state = "active"
  end if
  if FindSomething <> -1 and (state = "active") and the keyboardFocusSprite <> me.spriteNum then
    if FindSomething > 0 then
      member(ShowQuestField).text = ""
      member(sprite(me.spriteNum).member).text = foreShadowField.getProp(#line, FindSomething)
      state = "inactive"
    else
    end if
  end if
end

on endSprite me 
  if FindSomething > 0 then
    member(ShowQuestField).text = ""
    member(sprite(me.spriteNum).member).text = foreShadowField.getProp(#line, FindSomething)
    state = "inactive"
  end if
end

on getPropertyDescriptionList me 
  pList = [:]
  addProp(pList, #textField, [#comment:"ForeShadow List field", #format:#string, #default:"CountryList"])
  addProp(pList, #ShowQuestField, [#comment:"ForeShadow Show Quest Field", #format:#string, #default:"countryname2"])
  addProp(pList, #MustInclude, [#comment:"Input text must be include ForeShadowlist", #format:#boolean, #default:1])
  return(pList)
end

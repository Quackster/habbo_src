property maxlength

on beginSprite me
end

on keyDown me
  m = the member of sprite me.spriteNum
  x = the key
  if (x = BACKSPACE) or (charToNum(x) = 29) or (charToNum(x) = 28) or (the keyCode = 48) then
    pass()
  end if
  if getAt(charPosToLoc(m, m.text.length), 1) > maxlength then
    return 0
  end if
  if x = TAB then
    the keyboardFocusSprite = -1
  end if
  if checkKey(the key) = 1 then
    pass()
  else
  end if
end

on checkKey x
  if x = RETURN then
    return 0
  end if
  if (charToNum(x) < 32) or (charToNum(x) > 251) then
    return 0
  end if
  return 1
end

on getPropertyDescriptionList
  p_list = [#maxlength: [#comment: "Max. length:", #format: #integer, #range: [#min: 1, #max: 200], #default: 115]]
  return p_list
end

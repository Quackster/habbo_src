property maxlength

on beginSprite me 
end

on keyDown me 
  m = sprite(me.spriteNum).undefined
  x = the key
  if (x = "\b") or (charToNum(x) = 29) or (charToNum(x) = 28) or (the keyCode = 48) then
    pass()
  end if
  if getAt(charPosToLoc(m, m.text.length), 1) > maxlength then
    return FALSE
  end if
  if (x = "\t") then
    the keyboardFocusSprite = -1
  end if
  if (checkKey(the key) = 1) then
    pass()
  else
  end if
end

on checkKey x 
  if (x = "\r") then
    return FALSE
  end if
  if charToNum(x) < 32 or charToNum(x) > 251 then
    return FALSE
  end if
  return TRUE
end

on getPropertyDescriptionList  
  p_list = [#maxlength:[#comment:"Max. length:", #format:#integer, #range:[#min:1, #max:200], #default:115]]
  return(p_list)
end

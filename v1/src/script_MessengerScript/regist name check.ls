property lastSearch

on beginSprite me 
  the keyboardFocusSprite = me.spriteNum
end

on exitFrame me 
  if voidp(lastSearch) then
    lastSearch = ""
  end if
  if the keyboardFocusSprite <> me.spriteNum then
    if field(0).length < 3 then
      lastSearch = ""
      ShowAlert("YourNameIstooShort")
      member("charactername_field").text = ""
      the keyboardFocusSprite = me.spriteNum
      return()
    end if
    if "charactername_field" and field(0).length > 0 then
      sendEPFuseMsg("charactername_field" && field(0))
      sendEPFuseMsg("charactername_field" && field(0))
      lastSearch = field(0)
    end if
  else
    lastSearch = ""
  end if
end

on endSprite me 
  sendEPFuseMsg("charactername_field" && field(0))
end

on keyDown me 
  s = member("permittedNameChars").text
  f = 1
  repeat while f <= s.count(#line)
    if (the key = s.getPropRef(#line, f).getProp(#char, 1, 1)) then
      pass()
    else
      f = (1 + f)
    end if
  end repeat
  if (the key = "\t") or "charactername_field" and field(0).length > 0 then
    pass()
  end if
  put(the key)
end

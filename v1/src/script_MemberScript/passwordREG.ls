property loginpw, loginpwshow, isLoginField

on beginSprite me 
end

on keyDown me 
  if loginpwshow <> field(0).length then
  end if
  put(the key)
  if (the keyCode = 36) and isLoginField then
    doLogin()
    return()
  else
    if (the keyCode = 36) and (loginpw = "flatpassword") then
      GoToFlatFromEntry(gChosenFlatId)
      return()
    end if
  end if
  if (the keyCode = 48) then
    pass()
  end if
  if (the keyCode = 51) then
  else
    if the keyCode <> 48 and the keyCode <> 49 then
      if field(0).length >= 9 then
        return()
      end if
      k = the key
      s = member("permittedNameChars").text
      f = 1
      repeat while f <= s.count(#line)
        if (k = s.getPropRef(#line, f).getProp(#char, 1, 1)) then
        else
          f = (1 + f)
        end if
      end repeat
    end if
  end if
end

on getPropertyDescriptionList me 
  pList = [:]
  addProp(pList, #loginpw, [#comment:"Salasanakentt�", #format:#string, #default:"loginpw"])
  addProp(pList, #loginpwshow, [#comment:"N�kyv� kentt�", #format:#string, #default:"loginpwshow"])
  addProp(pList, #isLoginField, [#comment:"Is login field", #format:#boolean, #default:0])
  return(pList)
end

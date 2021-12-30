property loginpw, loginpwshow

on beginSprite me 
end

on keyDown me 
  if loginpwshow <> field(0).length then
  end if
  put(the keyCode)
  if (the keyCode = 36) then
    sendSprite(loginButton, #login)
    return()
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
    end if
  end if
end

on getPropertyDescriptionList me 
  pList = [:]
  addProp(pList, #loginpw, [#comment:"Salasanakentt�", #format:#string, #default:"loginpw"])
  addProp(pList, #loginpwshow, [#comment:"N�kyv� kentt�", #format:#string, #default:"loginpwshow"])
  return(pList)
end

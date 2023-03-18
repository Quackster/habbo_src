property loginpw, loginpwshow
global loginButton

on beginSprite me
  put EMPTY into field the name of the member of sprite the spriteNum of me
end

on keyDown me
  if field(loginpw).length <> field(loginpwshow).length then
    put EMPTY into field loginpw
    put EMPTY into field loginpwshow
  end if
  put the keyCode
  if the keyCode = 36 then
    sendSprite(loginButton, #login)
    return 
  end if
  if the keyCode = 48 then
    pass()
  end if
  if the keyCode = 51 then
    put EMPTY into field loginpwshow
    put EMPTY into field loginpw
  else
    if (the keyCode <> 48) and (the keyCode <> 49) then
      if field(loginpw).length >= 9 then
        return 
      end if
      k = the key
      put k after field loginpw
      put "*" after field loginpwshow
    end if
  end if
  put line 1 of field loginpwshow into field loginpwshow
  put line 1 of field loginpw into field loginpw
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #loginpw, [#comment: "Salasanakenttä", #format: #string, #default: "loginpw"])
  addProp(pList, #loginpwshow, [#comment: "Näkyvä kenttä", #format: #string, #default: "loginpwshow"])
  return pList
end

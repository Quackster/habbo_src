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
    if (the keyCode = 36) and loginpw contains "flatpassword" then
      gFlatLetIn = 0
      member("flat_load.status").text = AddTextToField("WaitingWhenCanGoIntoRoom")
      gFlatWaitStart = the milliSeconds
      gChosenFlatDoorMode = "x"
      GoToFlatWithNavi(gChosenFlatId)
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

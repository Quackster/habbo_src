property context

on mouseUp me 
  gpSplashForm = [:]
  gpSplashOk = 1
  sendAllSprites(#checkValue)
  if gpSplashOk = 0 then
    goContext("sp_error", context)
    return()
  else
    RET = "\r"
    s = RET & ""
    gpSplashSubmitted = 1
    i = 1
    repeat while i <= count(gpSplashForm)
      s = s & getPropAt(gpSplashForm, i) & "=" & getAt(gpSplashForm, i)
      s = s & RET
      i = 1 + i
    end repeat
    i = 1
    repeat while i <= s.length
      if charToNum(s.char[i]) > 128 then
      end if
      i = 1 + i
    end repeat
    put(s)
    s = s & "/SplashPlastic/formHandler/AnonymousCardOrderFormHandler.country=UK" & RET
    s = s & "_D:/SplashPlastic/formHandler/AnonymousCardOrderFormHandler.country=" & RET
    s = s & "/SplashPlastic/formHandler/AnonymousCardOrderFormHandler.requestCard=submit" & RET
    s = s & "_D:/SplashPlastic/formHandler/AnonymousCardOrderFormHandler.requestCard=" & RET
    s = s & "/SplashPlastic/formHandler/AnonymousCardOrderFormHandler.referrer=Habbo" & RET
    s = s & "_D:/SplashPlastic/formHandler/AnonymousCardOrderFormHandler.referrer=" & RET
    s = s & "/SplashPlastic/formHandler/AnonymousCardOrderFormHandler.cancelURL=/external/simpleforms/cancel.jhtml" & RET
    s = s & "_D:/SplashPlastic/formHandler/AnonymousCardOrderFormHandler.cancelURL=" & RET
    s = s & "currentPage=/external/simpleforms/get_card.jhtml"
    sendEPFuseMsg("SPLASH_POST" & "\r" & s)
    put(s)
    goContext("sp_thanks", context)
  end if
end

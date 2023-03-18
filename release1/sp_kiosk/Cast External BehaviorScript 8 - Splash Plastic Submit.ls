property context
global gpSplashForm, gpSplashOk, gpSplashSubmitted

on mouseUp me
  gpSplashForm = [:]
  gpSplashOk = 1
  sendAllSprites(#checkValue)
  if gpSplashOk = 0 then
    goContext("sp_error", context)
    return 
  else
    RET = RETURN
    s = RET & EMPTY
    gpSplashSubmitted = 1
    repeat with i = 1 to count(gpSplashForm)
      s = s & getPropAt(gpSplashForm, i) & "=" & getAt(gpSplashForm, i)
      s = s & RET
    end repeat
    repeat with i = 1 to s.length
      if charToNum(char i of s) > 128 then
        put "*" into char i of s
      end if
    end repeat
    put s
    s = s & "/SplashPlastic/formHandler/AnonymousCardOrderFormHandler.country=UK" & RET
    s = s & "_D:/SplashPlastic/formHandler/AnonymousCardOrderFormHandler.country=" & RET
    s = s & "/SplashPlastic/formHandler/AnonymousCardOrderFormHandler.requestCard=submit" & RET
    s = s & "_D:/SplashPlastic/formHandler/AnonymousCardOrderFormHandler.requestCard=" & RET
    s = s & "/SplashPlastic/formHandler/AnonymousCardOrderFormHandler.referrer=Habbo" & RET
    s = s & "_D:/SplashPlastic/formHandler/AnonymousCardOrderFormHandler.referrer=" & RET
    s = s & "/SplashPlastic/formHandler/AnonymousCardOrderFormHandler.cancelURL=/external/simpleforms/cancel.jhtml" & RET
    s = s & "_D:/SplashPlastic/formHandler/AnonymousCardOrderFormHandler.cancelURL=" & RET
    s = s & "currentPage=/external/simpleforms/get_card.jhtml"
    sendEPFuseMsg("SPLASH_POST" & RETURN & s)
    put s
    goContext("sp_thanks", context)
  end if
end

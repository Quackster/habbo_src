global loginButton

on beginSprite me
  loginButton = me.spriteNum
end

on mouseUp me
  login(me)
end

on login me
  global gGoTo
  if ((field("loginname") = EMPTY) or (field("loginpw") = EMPTY)) then
    ShowAlert("RememberSetYourPassword")
    return 
  end if
  Logon()
  gGoTo = "load"
  gotoFrame("connect_start")
end

on beginSprite me 
  loginButton = me.spriteNum
end

on mouseUp me 
  login(me)
end

on login me 
  if "loginpw" or (field(0) = "") then
    ShowAlert("RememberSetYourPassword")
    return()
  end if
  Logon()
  gGoTo = "load"
  goToFrame("connect_start")
end

on doLogin
  global gLoginName, gLoginPw, gGoTo
  gLoginName = field("loginname")
  gLoginPw = field("loginpw")
  gGoTo = "login"
  gotoFrame("connectloop")
  EPLogon()
end

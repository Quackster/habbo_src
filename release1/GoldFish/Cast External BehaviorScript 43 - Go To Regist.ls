global gGoTo

on mouseDown me
  EPLogon()
  gGoTo = "register"
  gotoFrame("connectloop")
end

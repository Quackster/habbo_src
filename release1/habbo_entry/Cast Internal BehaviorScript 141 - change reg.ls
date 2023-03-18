on mouseUp
  global gGoTo, gLoginName, gLoginPw, gPopUpContext, gPopUpContext2
  if gPopUpContext2 <> VOID then
    closeNavigator()
  end if
  if gPopUpContext <> VOID then
    closeMessenger()
  end if
  gGoTo = "change1"
  fuseRetrieveInfo(gLoginName, gLoginPw)
end

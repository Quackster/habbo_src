on keyDown me
  global context
  if the key = RETURN then
    if field("messenger.search_user") <> "*" then
      sendEPFuseMsg("FINDUSER" && field("messenger.search_user"))
      sendEPFuseMsg("UINFO_MATCH /" & field("messenger.search_user"))
      goContext("findresult", context)
    else
      showUnitsInMsg()
    end if
  else
    pass()
  end if
end

on beginSprite me
  put EMPTY into field "messenger.search_user"
end

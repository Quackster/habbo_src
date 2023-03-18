on mouseDown me
  global context
  if field("messenger.search_user") <> "*" then
    sendEPFuseMsg("FINDUSER" && field("messenger.search_user"))
    sendEPFuseMsg("UINFO_MATCH /" & field("messenger.search_user"))
    goContext("findresult", context)
  else
    showUnitsInMsg()
  end if
end

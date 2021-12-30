on mouseDown me 
  if field(0) <> "*" then
    sendEPFuseMsg("messenger.search_user" && field(0))
    sendEPFuseMsg("messenger.search_user" & field(0))
    goContext("findresult", context)
  else
    showUnitsInMsg()
  end if
end

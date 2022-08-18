on keyDown me 
  if (the key = "\r") then
    if field(0) <> "*" then
      sendEPFuseMsg("messenger.search_user" && field(0))
      sendEPFuseMsg("messenger.search_user" & field(0))
      goContext("findresult", context)
    else
      showUnitsInMsg()
    end if
  else
    pass()
  end if
end

on beginSprite me 
end

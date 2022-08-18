on prepareMovie  
  the alertHook = script("AlertParent")
  if (the runMode = "Author") then
    the alertHook = 0
  end if
end

on ShowAlert AlertID, OptionalMessage 
  oldItemDelimiter = the itemDelimiter
  the itemDelimiter = "="
  alertMes = ""
  f = 1
  repeat while f <= member("AlertMessages").count(#line)
    if member("AlertMessages").getPropRef(#line, f).getProp(#item, 1) contains AlertID then
      alertMes = member("AlertMessages").getPropRef(#line, f).getProp(#item, 2)
      if (AlertID = "MessageFromAdmin") then
        alertMes = OptionalMessage
      end if
      if (AlertID = "ModeratorWarning") then
        alertMes = alertMes && OptionalMessage
      end if
    else
      f = (1 + f)
    end if
  end repeat
  put("ALERT:" && AlertID && alertMes)
  the alertHook = 0
  if alertMes <> "" then
    alert(alertMes)
  else
    alert(AlertID)
  end if
  the itemDelimiter = oldItemDelimiter
  the alertHook = script("AlertParent")
  if (the runMode = "Author") then
    the alertHook = 0
  end if
end

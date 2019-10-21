on construct(me)
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end

on Refresh(me, tTopic, tdata)
  if tdata = 0 then
    return(0)
  end if
  if me = "game_deleted" then
    tAlertStr = "gs_error_game_deleted"
  else
    if me = "nocredits" then
      tAlertStr = "gs_error_nocredits"
    else
      tAlertStr = "gs_error_" & tdata.getAt(#request) & "_" & tdata.getAt(#reason)
      if not textExists(tAlertStr) then
        tAlertStr = "gs_error_" & tdata.getAt(#reason)
      end if
    end if
  end if
  return(executeMessage(#alert, [#id:"gs_error", #Msg:tAlertStr]))
  exit
end
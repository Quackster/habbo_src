on construct me 
  return TRUE
end

on deconstruct me 
  return TRUE
end

on Refresh me, tTopic, tdata 
  if (tdata = 0) then
    return FALSE
  end if
  if (tdata.getAt(#reason) = "game_deleted") then
    tAlertStr = "gs_error_game_deleted"
  else
    if (tdata.getAt(#reason) = "nocredits") then
      tAlertStr = "gs_error_nocredits"
    else
      tAlertStr = "gs_error_" & tdata.getAt(#request) & "_" & tdata.getAt(#reason)
      if not textExists(tAlertStr) then
        tAlertStr = "gs_error_" & tdata.getAt(#reason)
      end if
    end if
  end if
  return(executeMessage(#alert, [#id:"gs_error", #Msg:tAlertStr]))
end

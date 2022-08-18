on construct me
  return 1
end

on deconstruct me
  return 1
end

on Refresh me, tTopic, tdata
  if (tdata = 0) then
    return 0
  end if
  case tdata[#reason] of
    "game_deleted":
      tAlertStr = "gs_error_game_deleted"
    "nocredits":
      tAlertStr = "gs_error_nocredits"
    otherwise:
      tAlertStr = ((("gs_error_" & tdata[#request]) & "_") & tdata[#reason])
      if not textExists(tAlertStr) then
        tAlertStr = ("gs_error_" & tdata[#reason])
      end if
  end case
  return executeMessage(#alert, [#id: "gs_error", #Msg: tAlertStr])
end

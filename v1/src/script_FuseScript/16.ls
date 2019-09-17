on exitFrame  
  put("NETMOVIEID:", goNetMovieId)
  if not voidp(goNetMovieId) then
    p = getStreamStatus(goNetMovieId)
    if voidp(p) or p = "" then
      ShowAlert("tellStreamStatus VOID!")
    end if
    put(p)
    if listp(p) then
      if getaProp(p, #state) <> "Complete" then
        go(the frame)
        return()
      else
        goNetMovieId = void()
      end if
    end if
  end if
  if gConnectionOk = 0 or gConnectionsSecured = 0 then
    go(the frame - 1)
  else
    fuseLogin(gLoginName, gLoginPw, the movieName contains "private")
    if the movieName contains "private" then
      if voidp(gTargetDoorID) then
        sendFuseMsg("GOTOFLAT /" & gChosenFlatId)
      else
        sendFuseMsg("GOVIADOOR /" & gChosenFlatId & "/" & gTargetDoorID)
      end if
      go(the frame + 2)
    end if
  end if
end

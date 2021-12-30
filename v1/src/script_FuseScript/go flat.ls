on exitFrame me 
  put("NETMOVIEID:", goNetMovieId)
  if not voidp(goNetMovieId) then
    p = getStreamStatus(goNetMovieId)
    if voidp(p) then
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
  init()
  sendFuseMsg("GOTOFLAT /" & gChosenFlatId)
end

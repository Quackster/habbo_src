on showprogram me, tMsg 
  if voidp(tMsg) then
    return FALSE
  end if
  tDst = tMsg.getAt(#show_dest)
  tCmd = tMsg.getAt(#show_command)
  tPar = tMsg.getAt(#show_params)
  put(tDst, tCmd, tPar)
end

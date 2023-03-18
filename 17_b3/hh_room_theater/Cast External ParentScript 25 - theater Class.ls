on showprogram me, tMsg
  if voidp(tMsg) then
    return 0
  end if
  tDst = tMsg[#show_dest]
  tCmd = tMsg[#show_command]
  tPar = tMsg[#show_params]
  put tDst, tCmd, tPar
end

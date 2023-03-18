global gConfirmPopUp, gChosenStuffId, gChosenStuffType

on mouseUp me
  if gChosenStuffType = #stuff then
    sendFuseMsg("REMOVESTUFF " & gChosenStuffId)
  else
    sendFuseMsg("REMOVEITEM /" & gChosenStuffId)
  end if
  close(gConfirmPopUp)
end

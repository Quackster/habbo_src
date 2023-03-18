global gChosenStuffId, gChosenStuffType

on mouseUp me
  if gChosenStuffId = ".place" then
    return 
  end if
  if gChosenStuffType = #stuff then
    sendFuseMsg("ADDSTRIPITEM" && "new" && "stuff" && gChosenStuffId)
  else
    sendFuseMsg("ADDSTRIPITEM" && "new" && "item" && gChosenStuffId)
  end if
end

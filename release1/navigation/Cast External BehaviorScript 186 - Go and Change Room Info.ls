on mouseDown me
  global gChosenFlatId
  sendEPFuseMsg("GETFLATINFO /" & gChosenFlatId)
end

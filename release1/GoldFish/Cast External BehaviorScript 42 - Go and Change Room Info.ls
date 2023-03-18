on mouseDown me
  global gChosenFlatId
  sendEPFuseMsg("GETFLATINFO /" & gChosenFlatId)
  gotoFrame("roominfochangeload")
end

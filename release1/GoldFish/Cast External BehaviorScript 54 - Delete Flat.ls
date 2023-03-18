on mouseDown me
  global gProps, gChosenFlatId
  put "Deleting flat" && gChosenFlatId
  sendEPFuseMsg("DELETEFLAT /" & gChosenFlatId)
end

global gConfirmPopUp, placingStuffStripId, placingStuffType

on mouseUp me
  sendFuseMsg("FLATPROPERTYBYITEM /" & placingStuffType & "/" & placingStuffStripId)
  sendFuseMsg("GETSTRIP" && "new")
  placingStuffStripId = VOID
  placingStuffType = VOID
  close(gConfirmPopUp)
end

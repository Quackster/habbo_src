on mouseUp me 
  sendFuseMsg("FLATPROPERTYBYITEM /" & placingStuffType & "/" & placingStuffStripId)
  sendFuseMsg("GETSTRIP" && "new")
  placingStuffStripId = void()
  placingStuffType = void()
  close(gConfirmPopUp)
end

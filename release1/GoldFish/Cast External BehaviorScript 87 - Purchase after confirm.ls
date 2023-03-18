global gPurchaseCode, gMyName, gConfirmPopUp

on mouseUp me
  if not voidp(gPurchaseCode) then
    sendEPFuseMsg("PURCHASE /" & gPurchaseCode && gMyName)
    gPurchaseCode = VOID
  end if
  close(gConfirmPopUp)
end

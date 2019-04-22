on setPosterCode(me, tCode)
  put(tCode)
  pCode = tCode
  exit
end

on mouseDown(me)
  if voidp(pCode) or pCode = "" then
    return()
  end if
  sendEPFuseMsg("GETORDERINFO /" & pCode && gMyName)
  exit
end
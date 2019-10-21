property pCode

on setPosterCode me, tCode 
  put(tCode)
  pCode = tCode
end

on mouseDown me 
  if voidp(pCode) or (pCode = "") then
    return()
  end if
  sendEPFuseMsg("GETORDERINFO /" & pCode && gMyName)
end

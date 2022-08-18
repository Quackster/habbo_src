property pCode
global gMyName

on setPosterCode me, tCode
  put tCode
  pCode = tCode
end

on mouseDown me
  if (voidp(pCode) or (pCode = EMPTY)) then
    return 
  end if
  sendEPFuseMsg((("GETORDERINFO /" & pCode) && gMyName))
end

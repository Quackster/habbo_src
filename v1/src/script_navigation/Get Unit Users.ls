property unitNum

on mouseDown  
  if not listp(gUnits) then
    return()
  end if
  l = gUnits.getPropAt(unitNum)
  sendEPFuseMsg("GETUNITUSERS /" & l)
  put("GETUNITUSERS /" & l)
  put(field(0))
end

on getPropertyDescriptionList me 
  return([#unitNum:[#comment:"Unit no", #default:1, #format:#integer]])
end

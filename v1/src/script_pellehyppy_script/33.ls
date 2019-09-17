property tX2, tY2, tX, tY

on mouseUp me 
  if getaProp(gUserSprites, getaProp(gpObjects, gMyName)).height < 7 then
    sendFuseMsg("Move" && tX2 && tY2)
  else
    sendFuseMsg("Move" && tX && tY)
  end if
  dontPassEvent()
end

on getPropertyDescriptionList me 
  pList = [:]
  addProp(pList, #tX, [#comment:"Altaaseen X", #format:#integer, #default:0])
  addProp(pList, #tY, [#comment:"Altaaseen Y", #format:#integer, #default:0])
  addProp(pList, #tX2, [#comment:"Pois altaasta X", #format:#integer, #default:0])
  addProp(pList, #tY2, [#comment:"Pois altaasta Y", #format:#integer, #default:0])
  return(pList)
end

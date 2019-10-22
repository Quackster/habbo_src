property pCardObj, pDate

on prepare me, tdata 
  pCardObj = "PackageCardObj"
  tDate = tdata.getAt(#stuffdata)
  tDateItems = explode(tDate, "-", 3)
  pDate = ""
  if objectExists(#dateFormatter) and (tDateItems.count = 3) then
    pDate = getObject(#dateFormatter).getLocalDate(tDateItems.getAt(3), tDateItems.getAt(2), tDateItems.getAt(1))
  end if
  return TRUE
end

on select me 
  if the doubleClick then
    me.showCard()
  end if
  return TRUE
end

on showCard me 
  if objectExists(pCardObj) then
    removeObject(pCardObj)
  end if
  createObject(pCardObj, "Ecotron Box Card Class")
  getObject(pCardObj).define([#id:me.getID(), #date:pDate, #loc:me.getPropRef(#pSprList, 1).loc])
  return TRUE
end

property pDate, pCardObj

on prepare me, tdata
  pCardObj = "PackageCardObj"
  tDate = tdata[#stuffdata]
  tDateItems = explode(tDate, "-", 3)
  pDate = EMPTY
  if objectExists(#dateFormatter) and (tDateItems.count = 3) then
    pDate = getObject(#dateFormatter).getLocalDate(tDateItems[3], tDateItems[2], tDateItems[1])
  end if
  return 1
end

on select me
  if the doubleClick then
    me.showCard()
  end if
  return 1
end

on showCard me
  if objectExists(pCardObj) then
    removeObject(pCardObj)
  end if
  createObject(pCardObj, "Ecotron Box Card Class")
  getObject(pCardObj).define([#id: me.getID(), #date: pDate, #loc: me.pSprList[1].loc])
  return 1
end

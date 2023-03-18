property pMessage, pCardObj

on prepare me, tdata
  pCardObj = "PackageCardObj"
  tdata = tdata[#stuffdata]
  if not voidp(tdata) then
    if tdata.char[1] = "!" then
      pMessage = tdata.char[2..length(tdata)]
    else
      tDelim = the itemDelimiter
      the itemDelimiter = ":"
      pMessage = tdata.item[4..tdata.item.count]
      the itemDelimiter = tDelim
    end if
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
  if not objectExists(pCardObj) then
    createObject(pCardObj, "Package Card Class")
  end if
  getObject(pCardObj).define([#id: me.getID(), #Msg: pMessage, #loc: me.pSprList[1].loc])
  return 1
end

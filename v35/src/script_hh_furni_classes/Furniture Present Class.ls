on prepare(me, tdata)
  pCardObj = "PackageCardObj"
  tdata = tdata.getAt(#stuffdata)
  if not voidp(tdata) then
    if tdata.getProp(#char, 1) = "!" then
      pMessage = tdata.getProp(#char, 2, length(tdata))
    else
      tDelim = the itemDelimiter
      the itemDelimiter = ":"
      pMessage = tdata.getProp(#item, 4, tdata.count(#item))
      the itemDelimiter = tDelim
    end if
  end if
  return(1)
  exit
end

on select(me)
  if the doubleClick then
    me.showCard()
  end if
  return(1)
  exit
end

on showCard(me)
  if objectExists(pCardObj) then
    removeObject(pCardObj)
  end if
  createObject(pCardObj, "Package Card Class")
  getObject(pCardObj).define([#id:me.getID(), #Msg:pMessage, #loc:me.getPropRef(#pSprList, 1).loc])
  return(1)
  exit
end
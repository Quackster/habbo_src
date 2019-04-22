property pChannelNum, pChanges, pTvFrame, pActive

on prepare me, tdata 
  pTvFrame = 0
  if integerp(integer(tdata.getAt(#stuffdata))) then
    pChanges = 1
    pActive = 1
    pChannelNum = integer(tdata.getAt(#stuffdata))
    if [1, 2, 3].getOne(pChannelNum) = 0 then
      pChannelNum = 0
      pActive = 0
    end if
  else
    pChanges = 0
    pActive = 0
    pChannelNum = 1
  end if
  return(1)
end

on updateStuffdata me, tValue 
  if tValue = "OFF" then
    pActive = 0
  else
    pActive = 1
    pChannelNum = integer(tValue)
    if [1, 2, 3].getOne(pChannelNum) = 0 then
      pChannelNum = 0
      pActive = 0
    end if
  end if
  pChanges = 1
end

on update me 
  if not pChanges then
    return()
  end if
  if me.count(#pSprList) < 3 then
    return()
  end if
  tName = undefined.name
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tTmpName = tName.getProp(#item, 1, tName.count(#item) - 1) & "_"
  the itemDelimiter = tDelim
  pTvFrame = pTvFrame + 1
  if pActive and pTvFrame mod 3 = 1 then
    if pChannelNum = 1 then
      tNewName = tTmpName & random(10)
    else
      if pChannelNum = 2 then
        tNewName = tTmpName & 10 + random(5)
      else
        tNewName = tTmpName & 15 + random(5)
      end if
    end if
    if memberExists(tNewName) then
      tmember = member(getmemnum(tNewName))
      me.getPropRef(#pSprList, 3).castNum = tmember.number
      me.getPropRef(#pSprList, 3).width = tmember.width
      me.getPropRef(#pSprList, 3).height = tmember.height
    end if
    pChanges = 1
  end if
  if not pActive then
    the itemDelimiter = "_"
    tMemName = undefined.name
    tClass = tMemName.getProp(#item, 1, tMemName.count(#item) - 6)
    tNewName = tTmpName & "0"
    if memberExists(tNewName) then
      tmember = member(getmemnum(tNewName))
      me.getPropRef(#pSprList, 3).castNum = tmember.number
      me.getPropRef(#pSprList, 3).width = tmember.width
      me.getPropRef(#pSprList, 3).height = tmember.height
    end if
    pChanges = 0
  end if
  me.getPropRef(#pSprList, 3).locZ = me.getPropRef(#pSprList, 2).locZ + 2
end

on setOn me 
  pActive = 1
  pChannelNum = random(3)
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:string(pChannelNum)])
end

on setOff me 
  pActive = 0
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:"OFF"])
end

on select me 
  if the doubleClick then
    if pActive then
      me.setOff()
    else
      me.setOn()
    end if
  end if
  return(1)
end

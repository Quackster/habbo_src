property pChannelNum, pChanges, pTvFrame, pActive

on prepare me, tdata 
  pTvFrame = 0
  if tdata.getAt("CHANNEL") = "ON" then
    pChanges = 1
    pActive = 1
    pChannelNum = integer(tdata.getAt("CHANNEL"))
  else
    pChanges = 0
    pActive = 0
    pChannel = 1
  end if
  return(1)
end

on updateStuffdata me, tProp, tValue 
  if tValue = "OFF" then
    pActive = 0
  else
    pActive = 1
    pChannelNum = integer(tValue)
    if [1, 2, 3].getOne(pChannelNum) = 0 then
      pChannelNum = 1
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
  pTvFrame = pTvFrame + 1
  if pActive and (pTvFrame mod 3) = 1 then
    tName = member.name
    tDelim = the itemDelimiter
    the itemDelimiter = "_"
    tTmpName = tName.getProp(#item, 1, tName.count(#item) - 1) & "_"
    the itemDelimiter = tDelim
    if me.getPropRef(#pSprList, 3) = 1 then
      tNewName = tTmpName & random(10)
    else
      if me.getPropRef(#pSprList, 3) = 2 then
        tNewName = tTmpName & 10 + random(5)
      else
        if me.getPropRef(#pSprList, 3) = 3 then
          tNewName = tTmpName & 15 + random(5)
        end if
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
    tNewName = "wood_tv_c_0_1_2_0_0"
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
  getThread(#room).getComponent().getRoomConnection().send(#room, "SETSTUFFDATA /" & me.getID() & "/" & "CHANNEL" & "/" & pChannelNum)
end

on setOff me 
  pActive = 0
  getThread(#room).getComponent().getRoomConnection().send(#room, "SETSTUFFDATA /" & me.getID() & "/" & "CHANNEL" & "/" & "OFF")
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

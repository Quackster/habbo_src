property pChanges, pActive, pTimer, pNextChange

on prepare me, tdata 
  if tdata.getAt(#stuffdata) = "ON" then
    pActive = 1
  else
    pActive = 0
  end if
  pChanges = 1
  pTimer = 0
  pNextChange = 6
  return(1)
end

on updateStuffdata me, tValue 
  if tValue = "OFF" then
    pActive = 0
  else
    pActive = 1
  end if
  me.getPropRef(#pSprList, 2).castNum = 0
  pChanges = 1
end

on update me 
  if me.count(#pSprList) < 2 then
    return()
  end if
  if not pChanges then
    return()
  end if
  if pActive then
    if me.pXFactor = 32 then
      tClass = "s_rare_globe"
    else
      tClass = "rare_globe"
    end if
    pTimer = pTimer + 1
    if pTimer < pNextChange then
      return()
    end if
    pTimer = 0
    pNextChange = 6
    tNewName = tClass & "_b_0_1_1_0_" & random(4)
    if memberExists(tNewName) then
      me.getPropRef(#pSprList, 2).castNum = getmemnum(tNewName)
      me.getPropRef(#pSprList, 2).width = undefined.width
      me.getPropRef(#pSprList, 2).height = undefined.height
      me.getPropRef(#pSprList, 2).locZ = me.getPropRef(#pSprList, 1).locZ + 2
    end if
  else
    me.getPropRef(#pSprList, 2).castNum = 0
    pChanges = 0
  end if
end

on setOn me 
  getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:"ON"])
end

on setOff me 
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

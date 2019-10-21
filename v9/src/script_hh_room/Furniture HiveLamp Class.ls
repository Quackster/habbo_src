property pActive, pKill, pTimer, pLastFrm, pLastAnm, pSwitch

on prepare me, tdata 
  if me.count(#pSprList) < 3 then
    return FALSE
  end if
  removeEventBroker(me.getPropRef(#pSprList, 1).spriteNum)
  removeEventBroker(me.getPropRef(#pSprList, 2).spriteNum)
  removeEventBroker(me.getPropRef(#pSprList, 3).spriteNum)
  if (tdata.getAt(#stuffdata) = "ON") then
    me.setOn()
  else
    me.setOff()
  end if
  pLastFrm = 0
  pLastAnm = 0
  pTimer = 1
  return TRUE
end

on updateStuffdata me, tValue 
  if (tValue = "ON") then
    me.setOn()
  else
    me.setOff()
  end if
end

on update me 
  if pActive then
    if me.count(#pSprList) < 3 then
      return()
    end if
    if not pKill then
      pTimer = ((pTimer + 1) mod 3)
      if (pTimer = 0) then
        tDelim = the itemDelimiter
        the itemDelimiter = "_"
        tName = me.getPropRef(#pSprList, 1).member.name
        tItem = tName.getProp(#item, 1, (tName.count(#item) - 6))
        tPart = tName.getProp(#item, (tName.count(#item) - 5))
        tdata = tName.getProp(#item, (tName.count(#item) - 4), (tName.count(#item) - 1))
        tRand = random(6)
        if (tRand = pLastFrm) then
          tRand = (((tRand + 1) mod 6) + 1)
        end if
        pLastFrm = tRand
        pLastAnm = (((pLastAnm + 1) mod 6) + 1)
        tNewNameA = tItem & "_" & "a" & "_" & tdata & "_" & pLastFrm
        tNewNameB = tItem & "_" & "b" & "_" & tdata & "_" & pSwitch
        tNewNameC = tItem & "_" & "c" & "_" & tdata & "_" & pSwitch
        the itemDelimiter = tDelim
        me.getPropRef(#pSprList, 2).locZ = (me.getPropRef(#pSprList, 1).locZ + 5)
        me.getPropRef(#pSprList, 3).locZ = (me.getPropRef(#pSprList, 2).locZ + 5)
        if memberExists(tNewNameA) then
          tmember = member(getmemnum(tNewNameA))
          me.getPropRef(#pSprList, 1).castNum = tmember.number
          me.getPropRef(#pSprList, 1).width = tmember.width
          me.getPropRef(#pSprList, 1).height = tmember.height
          tmember = member(getmemnum(tNewNameB))
          me.getPropRef(#pSprList, 2).castNum = tmember.number
          me.getPropRef(#pSprList, 2).width = tmember.width
          me.getPropRef(#pSprList, 2).height = tmember.height
          tmember = member(getmemnum(tNewNameC))
          me.getPropRef(#pSprList, 3).castNum = tmember.number
          me.getPropRef(#pSprList, 3).width = tmember.width
          me.getPropRef(#pSprList, 3).height = tmember.height
        end if
      end if
    else
      tDelim = the itemDelimiter
      the itemDelimiter = "_"
      tName = me.getPropRef(#pSprList, 1).member.name
      tItem = tName.getProp(#item, 1, (tName.count(#item) - 6))
      tPart = tName.getProp(#item, (tName.count(#item) - 5))
      tdata = tName.getProp(#item, (tName.count(#item) - 4), (tName.count(#item) - 1))
      tNewNameA = tItem & "_" & "a" & "_" & tdata & "_" & 0
      tNewNameB = tItem & "_" & "b" & "_" & tdata & "_" & 0
      tNewNameC = tItem & "_" & "c" & "_" & tdata & "_" & 0
      the itemDelimiter = tDelim
      if memberExists(tNewNameA) then
        tmember = member(getmemnum(tNewNameA))
        me.getPropRef(#pSprList, 1).castNum = tmember.number
        me.getPropRef(#pSprList, 1).width = tmember.width
        me.getPropRef(#pSprList, 1).height = tmember.height
        tmember = member(getmemnum(tNewNameB))
        me.getPropRef(#pSprList, 2).castNum = tmember.number
        me.getPropRef(#pSprList, 2).width = tmember.width
        me.getPropRef(#pSprList, 2).height = tmember.height
        tmember = member(getmemnum(tNewNameC))
        me.getPropRef(#pSprList, 3).castNum = tmember.number
        me.getPropRef(#pSprList, 3).width = tmember.width
        me.getPropRef(#pSprList, 3).height = tmember.height
      end if
      pActive = 0
    end if
  end if
end

on setOn me 
  pSwitch = 1
  pKill = 0
  pActive = 1
end

on setOff me 
  pSwitch = 0
  pKill = 1
  pActive = 1
end

on select me 
  if the doubleClick then
    if pSwitch then
      tStr = "OFF"
    else
      tStr = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:tStr])
  end if
  return TRUE
end

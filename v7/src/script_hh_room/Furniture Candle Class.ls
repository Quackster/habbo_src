on prepare(me, tdata)
  if me.count(#pSprList) < 3 then
    return(0)
  end if
  removeEventBroker(me.getPropRef(#pSprList, 2).spriteNum)
  removeEventBroker(me.getPropRef(#pSprList, 3).spriteNum)
  if tdata.getAt("SWITCHON") = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  pLastFrm = 0
  pTimer = 1
  return(1)
  exit
end

on updateStuffdata(me, tProp, tValue)
  if tValue = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  exit
end

on update(me)
  if pActive then
    if me.count(#pSprList) < 3 then
      return()
    end if
    if not pKill then
      pTimer = not pTimer
      if pTimer then
        tDelim = the itemDelimiter
        the itemDelimiter = "_"
        tName = member.name
        tItem = tName.getProp(#item, 1, tName.count(#item) - 6)
        tPart = tName.getProp(#item, tName.count(#item) - 5)
        tdata = tName.getProp(#item, tName.count(#item) - 4, tName.count(#item) - 1)
        tRand = random(4)
        if tRand = pLastFrm then
          tRand = tRand + 1 mod 4 + 1
        end if
        pLastFrm = tRand
        tNewNameA = tItem & "_" & "b" & "_" & tdata & "_" & pLastFrm
        tNewNameB = tItem & "_" & "c" & "_" & tdata & "_" & pSwitch
        the itemDelimiter = tDelim
        me.getPropRef(#pSprList, 2).locZ = me.getPropRef(#pSprList, 1).locZ + 2
        me.getPropRef(#pSprList, 3).locZ = me.getPropRef(#pSprList, 2).locZ + 2
        if memberExists(tNewNameA) then
          tmember = member(getmemnum(tNewNameA))
          me.getPropRef(#pSprList, 2).castNum = tmember.number
          me.getPropRef(#pSprList, 2).width = tmember.width
          me.getPropRef(#pSprList, 2).height = tmember.height
          tmember = member(getmemnum(tNewNameB))
          me.getPropRef(#pSprList, 3).castNum = tmember.number
          me.getPropRef(#pSprList, 3).width = tmember.width
          me.getPropRef(#pSprList, 3).height = tmember.height
        end if
      end if
    else
      tDelim = the itemDelimiter
      the itemDelimiter = "_"
      tName = member.name
      tItem = tName.getProp(#item, 1, tName.count(#item) - 6)
      tPart = tName.getProp(#item, tName.count(#item) - 5)
      tdata = tName.getProp(#item, tName.count(#item) - 4, tName.count(#item) - 1)
      tNewNameA = tItem & "_" & "b" & "_" & tdata & "_" & 0
      tNewNameB = tItem & "_" & "c" & "_" & tdata & "_" & 0
      the itemDelimiter = tDelim
      if memberExists(tNewNameA) then
        tmember = member(getmemnum(tNewNameA))
        me.getPropRef(#pSprList, 2).castNum = tmember.number
        me.getPropRef(#pSprList, 2).width = tmember.width
        me.getPropRef(#pSprList, 2).height = tmember.height
        tmember = member(getmemnum(tNewNameB))
        me.getPropRef(#pSprList, 3).castNum = tmember.number
        me.getPropRef(#pSprList, 3).width = tmember.width
        me.getPropRef(#pSprList, 3).height = tmember.height
      end if
      pActive = 0
    end if
  end if
  exit
end

on setOn(me)
  pSwitch = 1
  pKill = 0
  pActive = 1
  exit
end

on setOff(me)
  pSwitch = 0
  pKill = 1
  pActive = 1
  exit
end

on select(me)
  if the doubleClick then
    if pSwitch then
      tStr = "OFF"
    else
      tStr = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "SWITCHON" & "/" & tStr)
  end if
  return(1)
  exit
end
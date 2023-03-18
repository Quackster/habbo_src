property pActive, pSwitch, pTimer, pLastFrm, pKill

on prepare me, tdata
  removeEventBroker(me.pSprList[2].spriteNum)
  removeEventBroker(me.pSprList[3].spriteNum)
  if tdata["SWITCHON"] = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  pLastFrm = 0
  pTimer = 1
  return 1
end

on updateStuffdata me, tProp, tValue
  if tValue = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
end

on update me
  if pActive then
    if me.pSprList.count < 3 then
      return 
    end if
    if not pKill then
      pTimer = not pTimer
      if pTimer then
        tDelim = the itemDelimiter
        the itemDelimiter = "_"
        tName = me.pSprList[1].member.name
        tItem = tName.item[1..tName.item.count - 6]
        tPart = tName.item[tName.item.count - 5]
        tdata = tName.item[tName.item.count - 4..tName.item.count - 1]
        tRand = random(4)
        if tRand = pLastFrm then
          tRand = ((tRand + 1) mod 4) + 1
        end if
        pLastFrm = tRand
        tNewNameA = tItem & "_" & "b" & "_" & tdata & "_" & pLastFrm
        tNewNameB = tItem & "_" & "c" & "_" & tdata & "_" & pSwitch
        the itemDelimiter = tDelim
        me.pSprList[2].locZ = me.pSprList[1].locZ + 2
        me.pSprList[3].locZ = me.pSprList[2].locZ + 2
        if memberExists(tNewNameA) then
          tmember = member(getmemnum(tNewNameA))
          me.pSprList[2].castNum = tmember.number
          me.pSprList[2].width = tmember.width
          me.pSprList[2].height = tmember.height
          tmember = member(getmemnum(tNewNameB))
          me.pSprList[3].castNum = tmember.number
          me.pSprList[3].width = tmember.width
          me.pSprList[3].height = tmember.height
        end if
      end if
    else
      tDelim = the itemDelimiter
      the itemDelimiter = "_"
      tName = me.pSprList[1].member.name
      tItem = tName.item[1..tName.item.count - 6]
      tPart = tName.item[tName.item.count - 5]
      tdata = tName.item[tName.item.count - 4..tName.item.count - 1]
      tNewNameA = tItem & "_" & "b" & "_" & tdata & "_" & 0
      tNewNameB = tItem & "_" & "c" & "_" & tdata & "_" & 0
      the itemDelimiter = tDelim
      if memberExists(tNewNameA) then
        tmember = member(getmemnum(tNewNameA))
        me.pSprList[2].castNum = tmember.number
        me.pSprList[2].width = tmember.width
        me.pSprList[2].height = tmember.height
        tmember = member(getmemnum(tNewNameB))
        me.pSprList[3].castNum = tmember.number
        me.pSprList[3].width = tmember.width
        me.pSprList[3].height = tmember.height
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
    getThread(#room).getComponent().getRoomConnection().send(#room, "SETSTUFFDATA /" & me.getID() & "/" & "SWITCHON" & "/" & tStr)
  end if
  return 1
end

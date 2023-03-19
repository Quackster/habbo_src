property pActive, pSwitch, pSync, pKill, pAnimFrame, pLastDir

on prepare me, tdata
  if tdata[#stuffdata] = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  pLastDir = -1
  pSync = 1
  return 1
end

on updateStuffdata me, tValue
  if tValue = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
end

on update me
  if pActive then
    if me.pSprList.count < 4 then
      return 
    end if
    if not pKill then
      pSync = not pSync
      if pSync then
        pAnimFrame = pAnimFrame + 1
        if pAnimFrame > 3 then
          pAnimFrame = 1
        end if
        tFlameNameA = me.pSprList[3].member.name
        if tFlameNameA.char[tFlameNameA.length - 1..tFlameNameA.length] = "_0" then
          tFlameNameA = tFlameNameA.char[1..tFlameNameA.length - 1] & "1"
          if memberExists(tFlameNameA) then
            tmember = member(getmemnum(tFlameNameA))
            me.pSprList[3].castNum = tmember.number
            me.pSprList[3].width = tmember.width
            me.pSprList[3].height = tmember.height
          end if
        end if
        tName = me.pSprList[4].member.name
        tName = tName.char[1..tName.length - 1] & pAnimFrame
        if memberExists(tName) then
          tmember = member(getmemnum(tName))
          me.pSprList[4].castNum = tmember.number
          me.pSprList[4].width = tmember.width
          me.pSprList[4].height = tmember.height
        end if
      end if
    else
      pActive = 0
      repeat with tSprNum in [3, 4]
        tName = me.pSprList[tSprNum].member.name
        tName = tName.char[1..tName.length - 1] & "0"
        if memberExists(tName) then
          tmember = member(getmemnum(tName))
          me.pSprList[tSprNum].castNum = tmember.number
          me.pSprList[tSprNum].width = tmember.width
          me.pSprList[tSprNum].height = tmember.height
        end if
      end repeat
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
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string: string(me.getID()), #string: tStr])
  end if
  return 1
end

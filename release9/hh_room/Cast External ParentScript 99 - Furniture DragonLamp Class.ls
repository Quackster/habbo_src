property pActive, pSwitch, pSync, pKill, pAnimFrame

on prepare me, tdata
  if me.pSprList.count < 7 then
    return 0
  end if
  repeat with tNum = 6 to 7
    removeEventBroker(me.pSprList[tNum].spriteNum)
  end repeat
  if tdata[#stuffdata] = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
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
    if me.pSprList.count < 7 then
      return 0
    end if
    if not pKill then
      pSync = not pSync
      if pSync then
        pAnimFrame = pAnimFrame + 1
        if pAnimFrame > 4 then
          pAnimFrame = 1
        end if
        tFlameNameA = me.pSprList[6].member.name
        if tFlameNameA.char[tFlameNameA.length - 1..tFlameNameA.length] = "_0" then
          repeat with tSprNum in [3, 5, 7]
            tFlameNameA = me.pSprList[tSprNum].member.name
            tFlameNameA = tFlameNameA.char[1..tFlameNameA.length - 1] & "1"
            if memberExists(tFlameNameA) then
              tmember = member(getmemnum(tFlameNameA))
              me.pSprList[tSprNum].castNum = tmember.number
              me.pSprList[tSprNum].width = tmember.width
              me.pSprList[tSprNum].height = tmember.height
            end if
          end repeat
        end if
        tName = me.pSprList[6].member.name
        tName = tName.char[1..tName.length - 1] & pAnimFrame
        if memberExists(tName) then
          tmember = member(getmemnum(tName))
          me.pSprList[6].castNum = tmember.number
          me.pSprList[6].width = tmember.width
          me.pSprList[6].height = tmember.height
        end if
      end if
    else
      pActive = 0
      repeat with tSprNum in [3, 5, 6, 7]
        tFlameNameA = me.pSprList[tSprNum].member.name
        tFlameNameA = tFlameNameA.char[1..tFlameNameA.length - 1] & "0"
        if memberExists(tFlameNameA) then
          tmember = member(getmemnum(tFlameNameA))
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

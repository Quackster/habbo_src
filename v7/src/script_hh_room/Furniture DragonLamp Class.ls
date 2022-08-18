property pActive, pKill, pSync, pAnimFrame, pSwitch

on prepare me, tdata 
  if me.count(#pSprList) < 7 then
    return()
  end if
  tNum = 6
  repeat while tNum <= 7
    removeEventBroker(me.getPropRef(#pSprList, tNum).spriteNum)
    tNum = (1 + tNum)
  end repeat
  if (tdata.getAt("SWITCHON") = "ON") then
    me.setOn()
  else
    me.setOff()
  end if
  pSync = 1
  return TRUE
end

on updateStuffdata me, tProp, tValue 
  if (tValue = "ON") then
    me.setOn()
  else
    me.setOff()
  end if
end

on update me 
  if pActive then
    if me.count(#pSprList) < 7 then
      return()
    end if
    if not pKill then
      pSync = not pSync
      if pSync then
        pAnimFrame = (pAnimFrame + 1)
        if pAnimFrame > 4 then
          pAnimFrame = 1
        end if
        tFlameNameA = me.getPropRef(#pSprList, 6).member.name
        if (tFlameNameA.getProp(#char, (tFlameNameA.length - 1), tFlameNameA.length) = "_0") then
          repeat while [3, 5, 7] <= undefined
            tSprNum = getAt(undefined, undefined)
            tFlameNameA = me.getPropRef(#pSprList, tSprNum).member.name
            tFlameNameA = tFlameNameA.getProp(#char, 1, (tFlameNameA.length - 1)) & "1"
            if memberExists(tFlameNameA) then
              tmember = member(getmemnum(tFlameNameA))
              me.getPropRef(#pSprList, tSprNum).castNum = tmember.number
              me.getPropRef(#pSprList, tSprNum).width = tmember.width
              me.getPropRef(#pSprList, tSprNum).height = tmember.height
            end if
          end repeat
        end if
        tName = me.getPropRef(#pSprList, 6).member.name
        tName = tName.getProp(#char, 1, (tName.length - 1)) & pAnimFrame
        if memberExists(tName) then
          tmember = member(getmemnum(tName))
          me.getPropRef(#pSprList, 6).castNum = tmember.number
          me.getPropRef(#pSprList, 6).width = tmember.width
          me.getPropRef(#pSprList, 6).height = tmember.height
        end if
      end if
    else
      pActive = 0
      repeat while [3, 5, 7] <= undefined
        tSprNum = getAt(undefined, undefined)
        tFlameNameA = me.getPropRef(#pSprList, tSprNum).member.name
        tFlameNameA = tFlameNameA.getProp(#char, 1, (tFlameNameA.length - 1)) & "0"
        if memberExists(tFlameNameA) then
          tmember = member(getmemnum(tFlameNameA))
          me.getPropRef(#pSprList, tSprNum).castNum = tmember.number
          me.getPropRef(#pSprList, tSprNum).width = tmember.width
          me.getPropRef(#pSprList, tSprNum).height = tmember.height
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
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "SWITCHON" & "/" & tStr)
  end if
  return TRUE
end

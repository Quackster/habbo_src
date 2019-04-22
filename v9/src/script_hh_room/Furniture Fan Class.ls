property pActive, pKill, pSync, pAnimFrame, pSwitch

on prepare me, tdata 
  if tdata.getAt(#stuffdata) = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
  pLastDir = -1
  pSync = 1
  return(1)
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
    if me.count(#pSprList) < 4 then
      return()
    end if
    if not pKill then
      pSync = not pSync
      if pSync then
        pAnimFrame = pAnimFrame + 1
        if pAnimFrame > 3 then
          pAnimFrame = 1
        end if
        tFlameNameA = undefined.name
        if tFlameNameA.getProp(#char, tFlameNameA.length - 1, tFlameNameA.length) = "_0" then
          tFlameNameA = tFlameNameA.getProp(#char, 1, tFlameNameA.length - 1) & "1"
          if memberExists(tFlameNameA) then
            tmember = member(getmemnum(tFlameNameA))
            me.getPropRef(#pSprList, 3).castNum = tmember.number
            me.getPropRef(#pSprList, 3).width = tmember.width
            me.getPropRef(#pSprList, 3).height = tmember.height
          end if
        end if
        tName = undefined.name
        tName = tName.getProp(#char, 1, tName.length - 1) & pAnimFrame
        if memberExists(tName) then
          tmember = member(getmemnum(tName))
          me.getPropRef(#pSprList, 4).castNum = tmember.number
          me.getPropRef(#pSprList, 4).width = tmember.width
          me.getPropRef(#pSprList, 4).height = tmember.height
        end if
      end if
    else
      pActive = 0
      repeat while [3, 4] <= undefined
        tSprNum = getAt(undefined, undefined)
        tName = undefined.name
        tName = tName.getProp(#char, 1, tName.length - 1) & "0"
        if memberExists(tName) then
          tmember = member(getmemnum(tName))
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
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", [#string:string(me.getID()), #string:tStr])
  end if
  return(1)
end

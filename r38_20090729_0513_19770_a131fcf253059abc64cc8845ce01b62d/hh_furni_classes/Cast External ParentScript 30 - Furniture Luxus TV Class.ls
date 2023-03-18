property pProgramOn, pAnimFrame, pAnimFrameDuration, pAnimFrameCounter, pUpdateCount, pAnimLoop, pTotalLoopCount, pUpdatesToWaitOnLastFrame, pTotalFrameCount

on prepare me, tdata
  pUpdateCount = 0
  pAnimFrame = 0
  pAnimLoop = 1
  pUpdatesToWaitOnLastFrame = 1
  if me.pXFactor = 32 then
    pAnimFrameDuration = 1
    pTotalLoopCount = 0
  else
    pAnimFrameDuration = 15
    pTotalLoopCount = 1
  end if
  pAnimFrameCounter = pAnimFrameDuration
  pTotalFrameCount = 1
  tValue = integer(tdata[#stuffdata])
  if tValue = 0 then
    me.setOff()
  else
    me.setOn()
  end if
  return 1
end

on updateStuffdata me, tValue
  tValue = integer(tValue)
  if tValue = 0 then
    me.setOff()
  else
    me.setOn()
  end if
end

on update me
  if me.pSprList.count < 4 then
    return 0
  end if
  pUpdateCount = pUpdateCount + 1
  if pUpdateCount < 3 then
    return 1
  end if
  pUpdateCount = 0
  tName = me.pSprList[4].member.name
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tName = tName.item[1..tName.item.count - 1] & "_"
  the itemDelimiter = tDelim
  if pProgramOn then
    if pAnimLoop >= 1 then
      pAnimFrameCounter = pAnimFrameCounter + 1
      if pAnimFrameCounter < pAnimFrameDuration then
        return 1
      end if
      pAnimFrameCounter = 0
      tNewName = tName & pAnimFrame
      pAnimFrame = pAnimFrame + 1
      if (pTotalFrameCount <= pAnimFrame) and memberExists(tName & pAnimFrame + 1) then
        pTotalFrameCount = pAnimFrame + 1
      end if
      if pAnimFrame = pTotalFrameCount then
        if pAnimLoop < pTotalLoopCount then
          pAnimFrame = 1
          pAnimLoop = pAnimLoop + 1
        else
          pAnimLoop = 0
          tNewName = tName & pAnimFrame
          pUpdatesToWaitOnLastFrame = 30 + random(40)
        end if
      end if
    else
      if pAnimLoop = 0 then
        if pAnimFrame <= pUpdatesToWaitOnLastFrame then
          pAnimFrame = pAnimFrame + 1
          return 1
        else
          pAnimFrame = 1
          pAnimLoop = 1
          return 1
        end if
      end if
    end if
  else
    tNewName = tName & "0"
  end if
  if memberExists(tNewName) then
    tmember = member(getmemnum(tNewName))
    me.pSprList[4].castNum = tmember.number
    me.pSprList[4].width = tmember.width
    me.pSprList[4].height = tmember.height
  end if
  me.pSprList[4].locZ = me.pSprList[1].locZ + 2
end

on setOn me
  pFramesToWaitOnLastFrame = 0
  pAnimFrameCounter = pAnimFrameDuration
  if me.pXFactor = 32 then
    pTotalLoopCount = 4 + random(6)
  else
    pTotalLoopCount = 1
  end if
  pAnimLoop = 1
  pAnimFrame = 1
  pProgramOn = 1
end

on setOff me
  pProgramOn = 0
end

on select me
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer: integer(me.getID()), #integer: 0])
  end if
end

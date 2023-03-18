property pPrefs, pAnimFrame, pInitDelayCounter, pAnimDelayCounter, pMemberClass, pPaletteClass, pCurrentFrame, pFrameList, pAnimLoopCounter, pAnimStopped

on construct me
  pFrameList = []
  pPrefs = []
  pCurrentFrame = 0
  pAnimLoopCounter = 1
  pAnimStopped = 1
  return 1
end

on deconstruct me
  removeUpdate(me.getID())
  pAnimStopped = 1
  return 1
end

on define me, tPrefs
  pPrefs = tPrefs
  if pPrefs[#animType] = #memberSwap then
    tMem = pPrefs[#sprite].member.name
    pMemberClass = chars(tMem, 1, tMem.length - 1)
  else
    if ilk(pPrefs[#sprite].member.paletteRef) <> #member then
      return error(me, "Palette must be a cast member for palette animations!", #define, #major)
    end if
    tMem = pPrefs[#sprite].member.paletteRef.name
    pPaletteClass = chars(tMem, 1, tMem.length - 1)
  end if
  me.setInitDelay()
  me.setAnimDelay()
  if pPrefs[#frameList] <> EMPTY then
    pFrameList = value(pPrefs[#frameList])
  else
    tMemFound = 1
    tIndex = 1
    repeat while tMemFound and (tIndex < 100)
      if pPrefs[#animType] = #memberSwap then
        tMem = pMemberClass & tIndex
      else
        tMem = pPaletteClass & tIndex
      end if
      if memberExists(tMem) then
        pFrameList.add(tIndex)
      else
        tMemFound = 0
      end if
      tIndex = tIndex + 1
    end repeat
  end if
  pAnimStopped = 0
  receiveUpdate(me.getID())
  return 1
end

on setInitDelay me
  if pPrefs[#initDelayType] = #random then
    pInitDelayCounter = random(pPrefs[#initDelay])
  else
    pInitDelayCounter = pPrefs[#initDelay]
  end if
end

on setAnimDelay me
  if pPrefs[#animDelayType] = #random then
    pAnimDelayCounter = random(pPrefs[#animDelay])
  else
    pAnimDelayCounter = pPrefs[#animDelay]
  end if
end

on update me
  if pAnimStopped then
    return 0
  end if
  pInitDelayCounter = pInitDelayCounter - 1
  if pInitDelayCounter < 0 then
    pAnimDelayCounter = pAnimDelayCounter - 1
    if pAnimDelayCounter < 0 then
      me.advanceAnimFrame()
      me.setAnimDelay()
    end if
  end if
end

on advanceAnimFrame me
  if pAnimStopped then
    return 0
  end if
  pCurrentFrame = pCurrentFrame + 1
  if pCurrentFrame > pFrameList.count then
    if pPrefs[#animLoopCount] > 0 then
      pAnimLoopCounter = pAnimLoopCounter + 1
      if pAnimLoopCounter > pPrefs[#animLoopCount] then
        return removeUpdate(me.getID())
      end if
    end if
    me.setInitDelay()
    if pInitDelayCounter > 0 then
      pCurrentFrame = 0
      return 0
    else
      pCurrentFrame = 1
    end if
  end if
  if ilk(pFrameList) = #list then
    if pFrameList.count > 0 then
      tAnimFrame = value(pFrameList[pCurrentFrame])
      if pAnimStopped then
        nothing()
      else
        if not voidp(pMemberClass) then
          tMem = pMemberClass & tAnimFrame
          pPrefs[#sprite].member = tMem
          pPrefs[#sprite].width = member(tMem).width
          pPrefs[#sprite].height = member(tMem).height
        else
          tMem = pPaletteClass & tAnimFrame
          pPrefs[#sprite].member.paletteRef = member(tMem)
        end if
      end if
    end if
  end if
end

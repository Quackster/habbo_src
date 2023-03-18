property pActive, pFrame, pSkipCounter, pMaxFrames

on define me, tdata
  pSkipCounter = 0
  pActive = 1
  pMaxFrames = -1
  me.ancestor.define(tdata)
  me.setFrame(0)
  return 1
end

on setAnimation me, tstate
  me.pActive = tstate
  if tstate = 0 then
    me.setFrame(0)
  end if
end

on update me
  if not pActive then
    return 1
  end if
  pSkipCounter = pSkipCounter + 1
  if pSkipCounter > 2 then
    pSkipCounter = 0
    me.animate()
  end if
end

on setFrame me, tValue
  if tValue = VOID then
    tValue = 0
  end if
  tsprite = me.pSprList[1]
  tName = tsprite.member.name
  tName = tName.char[1..length(tName) - 1] & tValue
  tsprite.member = member(getmemnum(tName))
  return 1
end

on animate me
  tsprite = me.pSprList[1]
  repeat with tsprite in me.pSprList
    if tsprite.member.name contains me.pClass then
      exit repeat
    end if
  end repeat
  tName = tsprite.member.name
  tCurrentFrame = integer(tName.char[length(tName)])
  tNamePrefix = tName.char[1..length(tName) - 1]
  if pMaxFrames = -1 then
    if getmemnum(tNamePrefix & tCurrentFrame + 1) then
      tFrame = tCurrentFrame + 1
    else
      pMaxFrames = tCurrentFrame
      tFrame = 0
    end if
  else
    if tCurrentFrame >= pMaxFrames then
      tFrame = 0
    else
      tFrame = tCurrentFrame + 1
    end if
  end if
  tName = tName.char[1..length(tName) - 1] & tFrame
  tsprite.member = member(getmemnum(tName))
  return 1
end

on roomObjectAction me, tAction, tdata
  case tAction of
    #set_direction:
      pActive = 0
      me.setFrame(tdata)
    #hide_roomobject:
      tsprite = me.pSprList[1]
      tsprite.member = member(0)
  end case
end

on select me
  tFramework = getObject(#bb_gamesystem)
  if tFramework = 0 then
    return 0
  end if
  return tFramework.sendGameSystemEvent(#send_set_target, [me.pLocX, me.pLocY])
end

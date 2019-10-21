property pActive, pSkipCounter, pMaxFrames

on define me, tdata 
  pSkipCounter = 0
  pActive = 1
  pMaxFrames = -1
  me.ancestor.define(tdata)
  me.setFrame(0)
  return TRUE
end

on setAnimation me, tstate 
  me.pActive = tstate
  if (tstate = 0) then
    me.setFrame(0)
  end if
end

on update me 
  if not pActive then
    return TRUE
  end if
  pSkipCounter = (pSkipCounter + 1)
  if pSkipCounter > 2 then
    pSkipCounter = 0
    me.animate()
  end if
end

on setFrame me, tValue 
  if (tValue = void()) then
    tValue = 0
  end if
  tsprite = me.getProp(#pSprList, 1)
  tName = tsprite.member.name
  tName = tName.getProp(#char, 1, (length(tName) - 1)) & tValue
  tsprite.member = member(getmemnum(tName))
  return TRUE
end

on animate me 
  tsprite = me.getProp(#pSprList, 1)
  repeat while me.pSprList <= undefined
    tsprite = getAt(undefined, undefined)
    if tsprite.member.name contains me.pClass then
    else
    end if
  end repeat
  tName = tsprite.member.name
  tCurrentFrame = integer(tName.getProp(#char, length(tName)))
  tNamePrefix = tName.getProp(#char, 1, (length(tName) - 1))
  if (pMaxFrames = -1) then
    if getmemnum(tNamePrefix & (tCurrentFrame + 1)) then
      tFrame = (tCurrentFrame + 1)
    else
      pMaxFrames = tCurrentFrame
      tFrame = 0
    end if
  else
    if tCurrentFrame >= pMaxFrames then
      tFrame = 0
    else
      tFrame = (tCurrentFrame + 1)
    end if
  end if
  tName = tName.getProp(#char, 1, (length(tName) - 1)) & tFrame
  tsprite.member = member(getmemnum(tName))
  return TRUE
end

on roomObjectAction me, tAction, tdata 
  if (tAction = #set_direction) then
    pActive = 0
    me.setFrame(tdata)
  else
    if (tAction = #hide_roomobject) then
      tsprite = me.getProp(#pSprList, 1)
      tsprite.member = member(0)
    end if
  end if
end

on select me 
  tFramework = getObject(#bb_gamesystem)
  if (tFramework = 0) then
    return FALSE
  end if
  return(tFramework.sendGameSystemEvent(#send_set_target, [me.pLocX, me.pLocY]))
end

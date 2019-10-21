on define(me, tdata)
  pSkipCounter = 0
  pActive = 1
  pMaxFrames = -1
  ancestor.define(tdata)
  me.setFrame(0)
  return(1)
  exit
end

on setAnimation(me, tstate)
  me.pActive = tstate
  if tstate = 0 then
    me.setFrame(0)
  end if
  exit
end

on update(me)
  if not pActive then
    return(1)
  end if
  pSkipCounter = pSkipCounter + 1
  if pSkipCounter > 2 then
    pSkipCounter = 0
    me.animate()
  end if
  exit
end

on setFrame(me, tValue)
  if tValue = void() then
    tValue = 0
  end if
  tsprite = me.getProp(#pSprList, 1)
  tName = member.name
  tName = tName.getProp(#char, 1, length(tName) - 1) & tValue
  tsprite.member = member(getmemnum(tName))
  return(1)
  exit
end

on animate(me)
  tsprite = me.getProp(#pSprList, 1)
  repeat while me <= undefined
    tsprite = getAt(undefined, undefined)
    if member.name contains me.pClass then
    else
    end if
  end repeat
  tName = member.name
  tCurrentFrame = integer(tName.getProp(#char, length(tName)))
  tNamePrefix = tName.getProp(#char, 1, length(tName) - 1)
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
  tName = tName.getProp(#char, 1, length(tName) - 1) & tFrame
  tsprite.member = member(getmemnum(tName))
  return(1)
  exit
end

on roomObjectAction(me, tAction, tdata)
  if me = #set_direction then
    pActive = 0
    me.setFrame(tdata)
  else
    if me = #hide_roomobject then
      tsprite = me.getProp(#pSprList, 1)
      tsprite.member = member(0)
    end if
  end if
  exit
end

on select(me)
  tFramework = getObject(#bb_gamesystem)
  if tFramework = 0 then
    return(0)
  end if
  return(tFramework.sendGameSystemEvent(#send_set_target, [me.pLocX, me.pLocY]))
  exit
end
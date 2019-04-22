on construct(me)
  pSmokelist = []
  pSmokeLocs = []
  pInitializeSprites = 0
  if me.pXFactor = 32 then
    pSizeMultiplier = 0.4
  else
    pSizeMultiplier = 0
  end if
  return(callAncestor(#deconstruct, [me]))
  exit
end

on deconstruct(me)
  i = 1
  repeat while i <= pSmokelist.count
    releaseSprite(pSmokelist.getAt(i).spriteNum)
    i = 1 + i
  end repeat
  return(callAncestor(#deconstruct, [me]))
  exit
end

on prepareForMove(me)
  if pActive = 1 then
    return(1)
  end if
  i = 1
  repeat while i <= pSmokelist.count
    releaseSprite(pSmokelist.getAt(i).spriteNum)
    i = 1 + i
  end repeat
  pSmokelist = []
  pChanges = 0
  return(1)
  exit
end

on prepare(me, tdata)
  tValue = integer(tdata.getAt(#stuffdata))
  if tValue = 0 then
    me.setOff()
    pChanges = 0
  else
    me.setOn()
  end if
  if me.count(#pSprList) > 1 then
    removeEventBroker(me.getPropRef(#pSprList, 2).spriteNum)
  end if
  pAnimFrame = 1
  pSync = 1
  if pSmokelist.count >= 2 then
    pInitializeSprites = 1
  end if
  return(1)
  exit
end

on createSmokeSprites(me, tNumOf)
  if me.count(#pSprList) < 4 then
    return(0)
  end if
  i = 1
  repeat while i <= tNumOf
    pSmokelist.add(sprite(reserveSprite(me.getID())))
    i = 1 + i
  end repeat
  return(me.initializeSmokeSprites())
  exit
end

on initializeSmokeSprites(me)
  if me.count(#pSprList) < 4 then
    return(0)
  end if
  tStartLoc = me.getPropRef(#pSprList, 4).loc + point(28, -60)
  tSmokeBig = pSmokelist.getAt(1)
  tSmokeBig.loc = tStartLoc
  tSmokeBig.ink = 8
  tSmokeBig.blend = 100
  me.changeMember(tSmokeBig, "scifirocket_sm_tiny")
  pSmokeLocs.setAt(1, tSmokeBig.loc)
  tSmokeBig.visible = 0
  tSmokeBig.locZ = me.getPropRef(#pSprList, 4).locZ + 2
  i = 2
  repeat while i <= pSmokelist.count
    tSp = pSmokelist.getAt(i)
    tSp.loc = tStartLoc + point(-3, -21) + point(random(6), random(4)) * pSizeMultiplier
    tSp.ink = 8
    tSp.locZ = me.getPropRef(#pSprList, 4).locZ + 1
    tSp.blend = 100
    tSp.visible = 0
    pSmokeLocs.setAt(i, tSp.loc)
    if random(3) = 1 then
      me.changeMember(tSp, "scifirocket_sm_tiny")
    else
      me.changeMember(tSp, "scifirocket_sm_small")
    end if
    i = 1 + i
  end repeat
  pInitializeSprites = 0
  return(1)
  exit
end

on animateSmallSmokes(me, tVal)
  if me = "move" then
    i = 2
    repeat while i <= pSmokelist.count
      if me = 2 then
        if random(2) = 2 then
          pSmokeLocs.getAt(i).setAt(2, pSmokeLocs.getAt(i).getAt(2) - 0.6 * pSizeMultiplier)
        end if
      else
        if me = 3 then
          pSmokeLocs.getAt(i).setAt(1, pSmokeLocs.getAt(i).getAt(1) + 0.6 - random(6) / 0 * pSizeMultiplier)
        else
          if me = 4 then
            pSmokeLocs.getAt(i).setAt(1, pSmokeLocs.getAt(i).getAt(1) - random(6) / 0 * pSizeMultiplier)
          else
            if me = 5 then
              pSmokeLocs.getAt(i).setAt(1, pSmokeLocs.getAt(i).getAt(1) + 0 - random(6) / 0 * pSizeMultiplier)
              pSmokeLocs.getAt(i).setAt(2, pSmokeLocs.getAt(i).getAt(2) + random(10) / 0 * pSizeMultiplier)
            else
              if me = 6 then
                pSmokeLocs.getAt(i).setAt(1, pSmokeLocs.getAt(i).getAt(1) - 0 + random(6) / 0 * pSizeMultiplier)
                pSmokeLocs.getAt(i).setAt(2, pSmokeLocs.getAt(i).getAt(2) + random(10) / 0 * pSizeMultiplier)
              end if
            end if
          end if
        end if
      end if
      pSmokeLocs.getAt(i).setAt(2, pSmokeLocs.getAt(i).getAt(2) - 0.7 - random(6) / 0 * pSizeMultiplier)
      pSmokeLocs.getAt(i).setAt(1, pSmokeLocs.getAt(i).getAt(1) + sin(the timer))
      pSmokelist.getAt(i).visible = 1
      pSmokelist.getAt(i).loc = pSmokeLocs.getAt(i)
      i = 1 + i
    end repeat
    exit repeat
  end if
  if me = "make_smaller" then
    i = 2
    repeat while i <= pSmokelist.count
      if random(5) = 2 then
        me.changeMember(pSmokelist.getAt(i), "scifirocket_sm_tiny")
      end if
      i = 1 + i
    end repeat
    exit repeat
  end if
  if me = "blend" then
    i = 2
    repeat while i <= pSmokelist.count
      pSmokelist.getAt(i).blend = pSmokelist.getAt(i).blend - 15
      i = 1 + i
    end repeat
  end if
  return(1)
  exit
end

on updateStuffdata(me, tValue)
  tValue = integer(tValue)
  if tValue = 0 then
    me.setOff()
  else
    me.setOn()
  end if
  return(1)
  exit
end

on update(me)
  if me.count(#pSprList) < 4 then
    return(0)
  end if
  tlight = me.getProp(#pSprList, 2)
  if pActive then
    tlight.blend = 100
  else
    tlight.blend = 0
  end if
  if pSync < 3 then
    pSync = pSync + 1
    return(0)
  else
    pSync = 1
  end if
  if not pChanges then
    return(0)
  end if
  if pSmokelist = [] then
    me.createSmokeSprites(4)
  end if
  if pInitializeSprites then
    me.initializeSmokeSprites()
  end if
  if pAnimFrame = 1 then
    if random(8) <> 2 then
      return(1)
    end if
  end if
  tSmokeBig = pSmokelist.getAt(1)
  if pAnimFrame <= 23 then
    if pAnimFrame = 4 then
      me.changeMember(tSmokeBig, "scifirocket_sm_small")
    end if
    if pAnimFrame = 9 then
      me.changeMember(tSmokeBig, "scifirocket_sm_med")
    end if
    if pAnimFrame = 14 then
      me.changeMember(tSmokeBig, "scifirocket_sm_big")
    end if
    pSmokeLocs.getAt(1).setAt(2, pSmokeLocs.getAt(1).getAt(2) - 0.9 * pSizeMultiplier)
    tSmokeBig.visible = 1
    tSmokeBig.loc = pSmokeLocs.getAt(1)
  else
    tSmokeBig.blend = tSmokeBig.blend - 20
    if pAnimFrame > 52 then
      me.animateSmallSmokes("make_smaller")
    end if
    if pAnimFrame > 60 then
      me.animateSmallSmokes("blend")
    end if
    if tSmokeBig.blend < 20 then
      tSmokeBig.visible = 0
    end if
    me.animateSmallSmokes("move")
  end if
  pAnimFrame = pAnimFrame + 1
  if pAnimFrame > 66 then
    me.initializeSmokeSprites()
    pAnimFrame = 1
    if pActive = 0 then
      pChanges = 0
    end if
  end if
  exit
end

on changeMember(me, tSpr, tMemName)
  if me.pXFactor = 32 then
    tMemName = "s_" & tMemName
  end if
  tMem = getMember(tMemName)
  if tMem = void() then
    return(0)
  end if
  tSpr.member = tMem
  tSpr.width = tMem.width
  tSpr.height = tMem.height
  return(1)
  exit
end

on setOn(me)
  pChanges = 1
  pActive = 1
  pSync = random(10) - 8
  exit
end

on setOff(me)
  pChanges = 1
  pActive = 0
  pInitializeSprites = 0
  exit
end

on select(me)
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer:integer(me.getID()), #integer:0])
  end if
  return(1)
  exit
end
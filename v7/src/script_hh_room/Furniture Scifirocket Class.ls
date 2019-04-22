property pActive, pSmokeLocs, pSync

on construct me 
  me.pSmokelist = []
  me.pSmokeLocs = []
  me.pInitializeSprites = 0
  return(callAncestor(#deconstruct, [me]))
end

on deconstruct me 
  i = 1
  repeat while i <= me.count(#pSmokelist)
    releaseSprite(me.getPropRef(#pSmokelist, i).spriteNum)
    i = 1 + i
  end repeat
  return(callAncestor(#deconstruct, [me]))
end

on prepareForMove me 
  if pActive = 1 then
    return(1)
  end if
  i = 1
  repeat while i <= me.count(#pSmokelist)
    releaseSprite(me.getPropRef(#pSmokelist, i).spriteNum)
    i = 1 + i
  end repeat
  me.pSmokelist = []
  me.pChanges = 0
  return(1)
end

on prepare me, tdata 
  if tdata.getAt("SWITCHON") = "ON" then
    me.setOn()
  else
    me.setOff()
    me.pChanges = 0
  end if
  if me.count(#pSprList) > 1 then
    removeEventBroker(me.getPropRef(#pSprList, 2).spriteNum)
  end if
  me.pAnimFrame = 1
  me.pSync = 1
  if me.count(#pSmokelist) >= 2 then
    me.pInitializeSprites = 1
  end if
  return(1)
end

on createSmokeSprites me, tNumOf 
  if me.count(#pSprList) < 5 then
    return(0)
  end if
  i = 1
  repeat while i <= tNumOf
    me.add(sprite(reserveSprite(me.getID())))
    i = 1 + i
  end repeat
  return(me.initializeSmokeSprites())
end

on initializeSmokeSprites me 
  if me.count(#pSprList) < 5 then
    return(0)
  end if
  tStartLoc = me.getPropRef(#pSprList, 4).loc + point(28, -60)
  tSmokeBig = me.getProp(#pSmokelist, 1)
  tSmokeBig.loc = tStartLoc
  tSmokeBig.ink = 8
  tSmokeBig.blend = 100
  me.changeMember(tSmokeBig, "scifirocket_sm_tiny")
  pSmokeLocs.setAt(1, tSmokeBig.loc)
  tSmokeBig.visible = 0
  tSmokeBig.locZ = me.getPropRef(#pSprList, 4).locZ + 2
  i = 2
  repeat while i <= me.count(#pSmokelist)
    tSp = me.getProp(#pSmokelist, i)
    tSp.loc = tStartLoc + point(-3, -21) + point(random(6), random(4))
    tSp.ink = 8
    tSp.locZ = me.getPropRef(#pSprList, 4).locZ + 1
    tSp.blend = 100
    tSp.visible = 0
    me.setProp(#pSmokeLocs, i, tSp.loc)
    if random(3) = 1 then
      me.changeMember(tSp, "scifirocket_sm_tiny")
    else
      me.changeMember(tSp, "scifirocket_sm_small")
    end if
    i = 1 + i
  end repeat
  me.pInitializeSprites = 0
  return(1)
end

on animateSmallSmokes me, tVal 
  if tVal = "move" then
    i = 2
    repeat while i <= me.count(#pSmokelist)
      if tVal = 2 then
        if random(2) = 2 then
          me.getPropRef(#pSmokeLocs, i).setAt(2, me.getPropRef(#pSmokeLocs, i).getAt(2) - 0.6)
        end if
      else
        if tVal = 3 then
          me.getPropRef(#pSmokeLocs, i).setAt(1, me.getPropRef(#pSmokeLocs, i).getAt(1) + 0.6 - random(6) / 12)
        else
          if tVal = 4 then
            me.getPropRef(#pSmokeLocs, i).setAt(1, me.getPropRef(#pSmokeLocs, i).getAt(1) - random(6) / 12)
          else
            if tVal = 5 then
              me.getPropRef(#pSmokeLocs, i).setAt(1, me.getPropRef(#pSmokeLocs, i).getAt(1) + 1 - random(6) / 12)
              me.getPropRef(#pSmokeLocs, i).setAt(2, me.getPropRef(#pSmokeLocs, i).getAt(2) + random(10) / 12)
            else
              if tVal = 6 then
                me.getPropRef(#pSmokeLocs, i).setAt(1, me.getPropRef(#pSmokeLocs, i).getAt(1) - 0.5 - random(6) / 12)
                me.getPropRef(#pSmokeLocs, i).setAt(2, me.getPropRef(#pSmokeLocs, i).getAt(2) + random(10) / 12)
              end if
            end if
          end if
        end if
      end if
      me.getPropRef(#pSmokeLocs, i).setAt(2, me.getPropRef(#pSmokeLocs, i).getAt(2) - 0.7 + random(6) / 11)
      me.getPropRef(#pSmokeLocs, i).setAt(1, me.getPropRef(#pSmokeLocs, i).getAt(1) + sin(the timer))
      me.getPropRef(#pSmokelist, i).visible = 1
      me.getPropRef(#pSmokelist, i).loc = me.getProp(#pSmokeLocs, i)
      i = 1 + i
    end repeat
    exit repeat
  end if
  if tVal = "make_smaller" then
    i = 2
    repeat while i <= me.count(#pSmokelist)
      if random(5) = 2 then
        me.changeMember(me.getProp(#pSmokelist, i), "scifirocket_sm_tiny")
      end if
      i = 1 + i
    end repeat
    exit repeat
  end if
  if tVal = "blend" then
    i = 2
    repeat while i <= me.count(#pSmokelist)
      me.getPropRef(#pSmokelist, i).blend = me.getPropRef(#pSmokelist, i).blend - 15
      i = 1 + i
    end repeat
  end if
  return(1)
end

on updateStuffdata me, tProp, tValue 
  if tValue = "ON" then
    me.setOn()
  else
    me.setOff()
  end if
end

on update me 
  if me.count(#pSprList) < 5 then
    return(0)
  end if
  tlight = me.getProp(#pSprList, 2)
  if me.pActive then
    tlight.blend = 100
  else
    tlight.blend = 0
  end if
  if pSync < 3 then
    me.pSync = me.pSync + 1
    return(0)
  else
    me.pSync = 1
  end if
  if not me.pChanges then
    return(0)
  end if
  if me.pSmokelist = [] then
    me.createSmokeSprites(4)
  end if
  if me.pInitializeSprites then
    me.initializeSmokeSprites()
  end if
  if me.pAnimFrame = 1 then
    if random(8) <> 2 then
      return(1)
    end if
  end if
  tSmokeBig = me.getProp(#pSmokelist, 1)
  if me.pAnimFrame <= 23 then
    if me.pAnimFrame = 4 then
      me.changeMember(tSmokeBig, "scifirocket_sm_small")
    end if
    if me.pAnimFrame = 9 then
      me.changeMember(tSmokeBig, "scifirocket_sm_med")
    end if
    if me.pAnimFrame = 14 then
      me.changeMember(tSmokeBig, "scifirocket_sm_big")
    end if
    me.getPropRef(#pSmokeLocs, 1).setAt(2, me.getPropRef(#pSmokeLocs, 1).getAt(2) - 0.9)
    tSmokeBig.visible = 1
    tSmokeBig.loc = me.getProp(#pSmokeLocs, 1)
  else
    tSmokeBig.blend = tSmokeBig.blend - 20
    if me.pAnimFrame > 52 then
      me.animateSmallSmokes("make_smaller")
    end if
    if me.pAnimFrame > 60 then
      me.animateSmallSmokes("blend")
    end if
    if tSmokeBig.blend < 20 then
      tSmokeBig.visible = 0
    end if
    me.animateSmallSmokes("move")
  end if
  me.pAnimFrame = me.pAnimFrame + 1
  if me.pAnimFrame > 66 then
    me.initializeSmokeSprites()
    me.pAnimFrame = 1
    if me.pActive = 0 then
      me.pChanges = 0
    end if
  end if
end

on changeMember me, tSpr, tMemName 
  tMem = getMember(tMemName)
  if tMem = void() then
    return(0)
  end if
  tSpr.member = tMem
  tSpr.width = tMem.width
  tSpr.height = tMem.height
  return(1)
end

on setOn me 
  me.pChanges = 1
  me.pActive = 1
end

on setOff me 
  me.pChanges = 1
  me.pActive = 0
  me.pInitializeSprites = 0
end

on select me 
  if the doubleClick then
    if pActive then
      tStr = "OFF"
    else
      tStr = "ON"
    end if
    getThread(#room).getComponent().getRoomConnection().send("SETSTUFFDATA", me.getID() & "/" & "SWITCHON" & "/" & tStr)
  end if
  return(1)
end

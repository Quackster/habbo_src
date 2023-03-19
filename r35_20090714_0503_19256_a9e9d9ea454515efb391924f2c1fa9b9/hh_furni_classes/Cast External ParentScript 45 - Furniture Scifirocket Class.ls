property pActive, pSync, pChanges, pSmokelist, pSmokeLocs, pInitializeSprites, pPause, pSizeMultiplier, pAnimFrame

on construct me
  pSmokelist = []
  pSmokeLocs = []
  pInitializeSprites = 0
  if me.pXFactor = 32 then
    pSizeMultiplier = 0.40000000000000002
  else
    pSizeMultiplier = 1.0
  end if
  return callAncestor(#deconstruct, [me])
end

on deconstruct me
  repeat with i = 1 to pSmokelist.count
    releaseSprite(pSmokelist[i].spriteNum)
  end repeat
  return callAncestor(#deconstruct, [me])
end

on prepareForMove me
  if pActive = 1 then
    return 1
  end if
  repeat with i = 1 to pSmokelist.count
    releaseSprite(pSmokelist[i].spriteNum)
  end repeat
  pSmokelist = []
  pChanges = 0
  return 1
end

on prepare me, tdata
  tValue = integer(tdata[#stuffdata])
  if tValue = 0 then
    me.setOff()
    pChanges = 0
  else
    me.setOn()
  end if
  if me.pSprList.count > 1 then
    removeEventBroker(me.pSprList[2].spriteNum)
  end if
  pAnimFrame = 1
  pSync = 1
  if pSmokelist.count >= 2 then
    pInitializeSprites = 1
  end if
  return 1
end

on createSmokeSprites me, tNumOf
  if me.pSprList.count < 4 then
    return 0
  end if
  repeat with i = 1 to tNumOf
    pSmokelist.add(sprite(reserveSprite(me.getID())))
  end repeat
  return me.initializeSmokeSprites()
end

on initializeSmokeSprites me
  if me.pSprList.count < 4 then
    return 0
  end if
  tStartLoc = me.pSprList[4].loc + point(28, -60)
  tSmokeBig = pSmokelist[1]
  tSmokeBig.loc = tStartLoc
  tSmokeBig.ink = 8
  tSmokeBig.blend = 100
  me.changeMember(tSmokeBig, "scifirocket_sm_tiny")
  pSmokeLocs[1] = tSmokeBig.loc
  tSmokeBig.visible = 0
  tSmokeBig.locZ = me.pSprList[4].locZ + 2
  repeat with i = 2 to pSmokelist.count
    tSp = pSmokelist[i]
    tSp.loc = tStartLoc + ((point(-3, -21) + point(random(6), random(4))) * pSizeMultiplier)
    tSp.ink = 8
    tSp.locZ = me.pSprList[4].locZ + 1
    tSp.blend = 100
    tSp.visible = 0
    pSmokeLocs[i] = tSp.loc
    if random(3) = 1 then
      me.changeMember(tSp, "scifirocket_sm_tiny")
      next repeat
    end if
    me.changeMember(tSp, "scifirocket_sm_small")
  end repeat
  pInitializeSprites = 0
  return 1
end

on animateSmallSmokes me, tVal
  case tVal of
    "move":
      repeat with i = 2 to pSmokelist.count
        case i of
          2:
            if random(2) = 2 then
              pSmokeLocs[i][2] = pSmokeLocs[i][2] - (0.59999999999999998 * pSizeMultiplier)
            end if
          3:
            pSmokeLocs[i][1] = pSmokeLocs[i][1] + ((0.59999999999999998 - (random(6) / 12.0)) * pSizeMultiplier)
          4:
            pSmokeLocs[i][1] = pSmokeLocs[i][1] - (random(6) / 12.0 * pSizeMultiplier)
          5:
            pSmokeLocs[i][1] = pSmokeLocs[i][1] + ((1.0 - (random(6) / 12.0)) * pSizeMultiplier)
            pSmokeLocs[i][2] = pSmokeLocs[i][2] + (random(10) / 12.0 * pSizeMultiplier)
          6:
            pSmokeLocs[i][1] = pSmokeLocs[i][1] - ((0.5 + (random(6) / 12.0)) * pSizeMultiplier)
            pSmokeLocs[i][2] = pSmokeLocs[i][2] + (random(10) / 12.0 * pSizeMultiplier)
        end case
        pSmokeLocs[i][2] = pSmokeLocs[i][2] - ((0.69999999999999996 - (random(6) / 12.0)) * pSizeMultiplier)
        pSmokeLocs[i][1] = pSmokeLocs[i][1] + sin(the timer)
        pSmokelist[i].visible = 1
        pSmokelist[i].loc = pSmokeLocs[i]
      end repeat
    "make_smaller":
      repeat with i = 2 to pSmokelist.count
        if random(5) = 2 then
          me.changeMember(pSmokelist[i], "scifirocket_sm_tiny")
        end if
      end repeat
    "blend":
      repeat with i = 2 to pSmokelist.count
        pSmokelist[i].blend = pSmokelist[i].blend - 15
      end repeat
  end case
  return 1
end

on updateStuffdata me, tValue
  tValue = integer(tValue)
  if tValue = 0 then
    me.setOff()
  else
    me.setOn()
  end if
  return 1
end

on update me
  if me.pSprList.count < 4 then
    return 0
  end if
  tlight = me.pSprList[2]
  if pActive then
    tlight.blend = 100
  else
    tlight.blend = 0
  end if
  if pSync < 3 then
    pSync = pSync + 1
    return 0
  else
    pSync = 1
  end if
  if not pChanges then
    return 0
  end if
  if pSmokelist = [] then
    me.createSmokeSprites(4)
  end if
  if pInitializeSprites then
    me.initializeSmokeSprites()
  end if
  if pAnimFrame = 1 then
    if random(8) <> 2 then
      return 1
    end if
  end if
  tSmokeBig = pSmokelist[1]
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
    pSmokeLocs[1][2] = pSmokeLocs[1][2] - (0.90000000000000002 * pSizeMultiplier)
    tSmokeBig.visible = 1
    tSmokeBig.loc = pSmokeLocs[1]
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
end

on changeMember me, tSpr, tMemName
  if me.pXFactor = 32 then
    tMemName = "s_" & tMemName
  end if
  tMem = getMember(tMemName)
  if tMem = VOID then
    return 0
  end if
  tSpr.member = tMem
  tSpr.width = tMem.width
  tSpr.height = tMem.height
  return 1
end

on setOn me
  pChanges = 1
  pActive = 1
  pSync = random(10) - 8
end

on setOff me
  pChanges = 1
  pActive = 0
  pInitializeSprites = 0
end

on select me
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer: integer(me.getID()), #integer: 0])
  end if
  return 1
end

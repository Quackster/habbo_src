property pBallState, pBounceState, pActiveEffects, pBounceAnimCount, pBallClass, pOrigBallColor, pLocChange, pDirChange

on construct me
  pBallState = 1
  pBounceState = 0
  pBounceAnimCount = 1
  pBallClass = ["Bodypart Class EX", "Bouncing Bodypart Class"]
  me.pDirChange = 1
  me.pLocChange = 1
  pActiveEffects = []
  if not objectp(me.ancestor) then
    return 0
  end if
  return me.ancestor.construct()
end

on deconstruct me
  repeat with tEffect in pActiveEffects
    tEffect.deconstruct()
  end repeat
  pActiveEffects = []
  if not objectp(me.ancestor) then
    return 1
  end if
  return me.ancestor.deconstruct()
end

on roomObjectAction me, tAction, tdata
  case tAction of
    #set_ball_color:
      tTeamColors = [rgb("#E73929"), rgb("#217BEF"), rgb("#8CE700"), rgb("#FFCE21")]
      me.setBallColor(tTeamColors[tdata[#opponentTeamId]])
    #reset_ball_color:
      me.setBallColor(pOrigBallColor)
    #set_bounce_state:
      pBounceState = tdata
      me.clearEffectAnimation()
    #set_ball:
      if tdata then
        pBallState = 1
      else
        pBallState = 0
      end if
      me.pChanges = 1
      me.pDirChange = 1
      repeat with tBodyPart in me.pPartList
        tBodyPart.resetMemberCache()
      end repeat
      me.pMember.image.fill(me.pMember.image.rect, me.pAlphaColor)
      me.render()
    #fly_into:
      me.createEffect(#loop, "bb2_efct_pu_cannon_", [#ink: 33], me.pDirection)
      me.pMainAction = "sit"
      me.pMoving = 1
      pBounceAnimCount = 1
      me.pStartLScreen = me.pGeometry.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
      me.pDestLScreen = me.pGeometry.getScreenCoordinate(tdata[#x], tdata[#y], tdata[#z])
      me.pMoveStart = the milliSeconds
      me.definePartListAction(me.pPartListSubSet["sit"], "sit")
      me.definePartListAction(me.pPartListSubSet["handLeft"], "crr")
      me.definePartListAction(me.pPartListSubSet["handRight"], "crr")
  end case
end

on select me
  return 0
end

on prepare me
  tScreenLoc = me.pScreenLoc.duplicate()
  if me.pMoving then
    tFactor = float(the milliSeconds - me.pMoveStart) / me.pMoveTime
    if tFactor > 1.0 then
      tFactor = 1.0
    end if
    me.pScreenLoc = ((me.pDestLScreen - me.pStartLScreen) * tFactor) + me.pStartLScreen
    me.adjustScreenLoc(1)
    me.pChanges = 1
  else
    me.pScreenLoc = me.pGeometry.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
    me.adjustScreenLoc(0)
    me.pChanges = not me.pChanges
  end if
  if tScreenLoc <> me.pScreenLoc then
    me.pLocChange = 1
  end if
end

on adjustScreenLoc me, tMoving
  if tMoving then
    case pBounceState of
      8:
        tBounceLocV = [0.69999999999999996]
      7:
        me.setEffectAnimationLocations([#screenLoc: me.pScreenLoc])
        tBounceLocV = [0]
      3:
        tBounceLocV = [0, -1.0, -2.0, -2.39999999999999991, -2.0, -1.0, -0]
        if me.pBounceAnimCount = 3 then
          me.createEffect(#once, "bb2_efct_pu_spring_", [#ink: 33])
        end if
      4:
        tBounceLocV = [0, -0.5, -1.0, -0, -0.5, -1.0, -0]
        if me.pBounceAnimCount = 3 then
          me.createEffect(#once, "bb2_efct_pu_drill_", [#ink: 33])
        end if
      otherwise:
        tBounceLocV = [0, -0.5, -1.0, -1.19999999999999996, -1.0, -0.5, -0]
    end case
  else
    case pBounceState of
      8:
        tBounceLocV = [0.69999999999999996]
      otherwise:
        tBounceLocV = [0, -0.29999999999999999, -0.40000000000000002, -0.5, -0.40000000000000002, -0.10000000000000001]
    end case
  end if
  me.pBounceAnimCount = me.pBounceAnimCount + 1
  if me.pBounceAnimCount > tBounceLocV.count then
    me.pBounceAnimCount = 1
  end if
  me.pScreenLoc[2] = me.pScreenLoc[2] + (10 * tBounceLocV[me.pBounceAnimCount])
end

on update me
  me.pSync = not me.pSync
  if me.pSync then
    me.prepare()
  else
    me.render()
  end if
  if pActiveEffects.count = 0 then
    return 1
  end if
  repeat with i = 1 to pActiveEffects.count
    tEffect = pActiveEffects[i]
    if tEffect.pActive then
      tEffect.update()
      next repeat
    end if
    tEffect.deconstruct()
    pActiveEffects.deleteAt(i)
  end repeat
end

on render me, tForceUpdate
  if not me.pChanges then
    return 1
  end if
  me.pChanges = 0
  if me.pLocChange and not me.pDirChange and not tForceUpdate then
    me.pLocChange = 0
    return me.setHumanSpriteLoc()
  end if
  if (me.pDirChange = 0) and not tForceUpdate then
    return 1
  end if
  me.pDirChange = 0
  tSize = me.pCanvasSize[#std]
  if me.pShadowSpr.member <> me.pDefShadowMem then
    me.pShadowSpr.member = me.pDefShadowMem
  end if
  if (me.pBuffer.width <> tSize[1]) or (me.pBuffer.height <> tSize[2]) then
    me.pMember.image = image(tSize[1], tSize[2], tSize[3])
    me.pMember.regPoint = point(0, tSize[2] + tSize[4])
    me.pSprite.width = tSize[1]
    me.pSprite.height = tSize[2]
    me.pMatteSpr.width = tSize[1]
    me.pMatteSpr.height = tSize[2]
    me.pBuffer = image(tSize[1], tSize[2], tSize[3])
  end if
  me.pMember.regPoint = point(0, me.pMember.regPoint[2])
  me.pShadowFix = 0
  if me.pSprite.flipH then
    me.pSprite.flipH = 0
    me.pMatteSpr.flipH = 0
    me.pShadowSpr.flipH = 0
  end if
  me.setHumanSpriteLoc()
  me.pUpdateRect = rect(0, 0, 0, 0)
  me.pBuffer.fill(me.pBuffer.rect, me.pAlphaColor)
  if pBallState then
    call(#update, me.pPartList)
  else
    repeat with tPart in me.pPartList
      if tPart.pPart <> "bl" then
        call(#update, tPart)
      end if
    end repeat
  end if
  me.pMember.image.copyPixels(me.pBuffer, me.pUpdateRect, me.pUpdateRect)
  return 1
end

on setHumanSpriteLoc me
  tOffZ = 2
  me.pSprite.locH = me.pScreenLoc[1]
  me.pSprite.locV = me.pScreenLoc[2]
  me.pSprite.locZ = me.pScreenLoc[3] + tOffZ
  me.pMatteSpr.loc = me.pSprite.loc
  me.pMatteSpr.locZ = me.pSprite.locZ + 1
  me.pShadowSpr.loc = me.pSprite.loc + [me.pShadowFix, 0]
  me.pShadowSpr.locZ = me.pSprite.locZ - 3
  return 1
end

on setBallColor me, tColor
  if me.pPartIndex.findPos("bl") = 0 then
    return 0
  end if
  tBallPart = me.pPartList[me.pPartIndex["bl"]]
  if tBallPart <> VOID then
    tBallPart.setColor(tColor)
  end if
  tBallPart.resetMemberCache()
  me.pChanges = 1
  me.pDirChange = 1
  me.render()
  return 1
end

on setPartLists me, tmodels
  me.resetAction()
  if not voidp(tmodels["bl"]) then
    pOrigBallColor = tmodels["bl"]["color"]
  end if
  callAncestor(#setPartLists, [me], tmodels)
  call(#reset, me.pPartList)
  me.definePartListAction(me.pPartListSubSet["sit"], "sit")
  me.definePartListAction(me.pPartListSubSet["handLeft"], "crr")
  me.definePartListAction(me.pPartListSubSet["handRight"], "crr")
  return 1
end

on arrangeParts me
  callAncestor(#arrangeParts, [me], "bouncing.human.parts")
end

on getPicture me, tImg
  return me.getPartialPicture(#Full, tImg, 4, "sh")
end

on getPartClass me, tPartSymbol
  if tPartSymbol = "bl" then
    return pBallClass
  else
    return me.pPartClass
  end if
end

on getPartListNameBase me
  return "bouncing.human.parts"
end

on Refresh me, tX, tY, tH
  call(#defineDir, me.pPartList, me.pDirection)
  call(#defineDirMultiple, me.pPartList, me.pDirection, me.pPartListSubSet["head"])
  me.arrangeParts()
  return 1
end

on resetValues me, tX, tY, tH, tDirHead, tDirBody
  tDirHead = tDirBody
  me.pMoving = 0
  me.pDancing = 0
  me.pTalking = 0
  me.pCarrying = 0
  me.pWaving = 0
  me.pTrading = 0
  me.pCtrlType = 0
  me.pAnimating = 0
  me.pModState = 0
  me.pSleeping = 0
  me.pFx = 0
  me.pLocFix = point(-1, 2)
  me.pScreenLoc = me.pGeometry.getScreenCoordinate(tX, tY, tH)
  me.adjustScreenLoc()
  me.pLocX = tX
  me.pLocY = tY
  me.pLocH = tH
  if me.pDirection <> tDirBody then
    me.pDirChange = 1
  end if
  me.pDirection = tDirBody
  me.pHeadDir = tDirHead
  me.pChanges = 1
  me.pLocChange = 1
  return 1
end

on clearEffectAnimation me
  repeat with tEffect in pActiveEffects
    tEffect.pActive = 0
  end repeat
end

on setEffectAnimationLocations me, tlocation
  if tlocation[#screenLoc] = VOID then
    tX = tlocation[#x]
    tY = tlocation[#y]
    tZ = tlocation[#z]
    tlocz = 1 + pActiveEffects.count
    if getObject(#room_interface) = 0 then
      return 0
    end if
    pGeometry = getObject(#room_interface).getGeometry()
    if pGeometry = 0 then
      return 0
    end if
    tScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tZ)
  else
    tScreenLoc = tlocation[#screenLoc]
  end if
  repeat with tEffect in pActiveEffects
    tEffect.setLocation(tScreenLoc)
  end repeat
  return 1
end

on createEffect me, tMode, tEffectID, tProps, tDirection
  tX = me.pLocX
  tY = me.pLocY
  tZ = me.pLocH
  tlocz = 1 + pActiveEffects.count
  if getObject(#room_interface) = 0 then
    return 0
  end if
  pGeometry = getObject(#room_interface).getGeometry()
  if pGeometry = 0 then
    return 0
  end if
  tScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tZ)
  tEffect = createObject(#temp, "BB Effect Animation Class")
  if tEffect = 0 then
    return error(me, "Unable to create effect object!", #createEffect)
  end if
  tEffect.define(tMode, tScreenLoc, tlocz, tEffectID, tProps, tDirection)
  pActiveEffects.append(tEffect)
  return 1
end

on action_mv me, tProps
  me.pMainAction = "sit"
  me.pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  pBounceAnimCount = 1
  tloc = tProps.word[2]
  tLocX = integer(tloc.item[1])
  tLocY = integer(tloc.item[2])
  tLocH = integer(tloc.item[3])
  the itemDelimiter = tDelim
  me.pStartLScreen = me.pGeometry.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  me.pDestLScreen = me.pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  me.pMoveStart = the milliSeconds
  me.definePartListAction(me.pPartListSubSet["sit"], "sit")
  me.definePartListAction(me.pPartListSubSet["handLeft"], "crr")
  me.definePartListAction(me.pPartListSubSet["handRight"], "crr")
end

on action_fx me, tProps
  return 1
end

property pActiveEffects, pOrigBallColor, pBounceState, pBallState, pBallClass

on construct me 
  pBallState = 1
  pBounceState = 0
  pBounceAnimCount = 1
  pBallClass = ["Bodypart Class EX", "Bouncing Bodypart Class"]
  me.pDirChange = 1
  me.pLocChange = 1
  pActiveEffects = []
  if not objectp(me.ancestor) then
    return(0)
  end if
  return(ancestor.construct())
end

on deconstruct me 
  repeat while pActiveEffects <= undefined
    tEffect = getAt(undefined, undefined)
    tEffect.deconstruct()
  end repeat
  pActiveEffects = []
  if not objectp(me.ancestor) then
    return(1)
  end if
  return(ancestor.deconstruct())
end

on roomObjectAction me, tAction, tdata 
  if tAction = #set_ball_color then
    tTeamColors = [rgb("#E73929"), rgb("#217BEF"), rgb("#8CE700"), rgb("#FFCE21")]
    me.setBallColor(tTeamColors.getAt(tdata.getAt(#opponentTeamId)))
  else
    if tAction = #reset_ball_color then
      me.setBallColor(pOrigBallColor)
    else
      if tAction = #set_bounce_state then
        pBounceState = tdata
        me.clearEffectAnimation()
      else
        if tAction = #set_ball then
          if tdata then
            pBallState = 1
          else
            pBallState = 0
          end if
          me.pChanges = 1
          me.pDirChange = 1
          repeat while tAction <= tdata
            tBodyPart = getAt(tdata, tAction)
            tBodyPart.resetMemberCache()
          end repeat
          pMember.fill(image.rect, me.pAlphaColor)
          me.render()
        else
          if tAction = #fly_into then
            me.createEffect(#loop, "bb2_efct_pu_cannon_", [#ink:33], me.pDirection)
            me.pMainAction = "sit"
            me.pMoving = 1
            pBounceAnimCount = 1
            me.pStartLScreen = pGeometry.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
            me.pDestLScreen = pGeometry.getScreenCoordinate(tdata.getAt(#x), tdata.getAt(#y), tdata.getAt(#z))
            me.pMoveStart = the milliSeconds
            me.definePartListAction(me.getProp(#pPartListSubSet, "sit"), "sit")
            me.definePartListAction(me.getProp(#pPartListSubSet, "handLeft"), "crr")
            me.definePartListAction(me.getProp(#pPartListSubSet, "handRight"), "crr")
          end if
        end if
      end if
    end if
  end if
end

on select me 
  return(0)
end

on prepare me 
  tScreenLoc = pScreenLoc.duplicate()
  if me.pMoving then
    tFactor = float(the milliSeconds - me.pMoveStart) / me.pMoveTime
    if tFactor > 1 then
      tFactor = 1
    end if
    me.pScreenLoc = me.pDestLScreen - me.pStartLScreen * tFactor + me.pStartLScreen
    me.adjustScreenLoc(1)
    me.pChanges = 1
  else
    me.pScreenLoc = pGeometry.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
    me.adjustScreenLoc(0)
    me.pChanges = not me.pChanges
  end if
  if tScreenLoc <> me.pScreenLoc then
    me.pLocChange = 1
  end if
end

on adjustScreenLoc me, tMoving 
  if tMoving then
    if pBounceState = 8 then
      tBounceLocV = [0.7]
    else
      if pBounceState = 7 then
        me.setEffectAnimationLocations([#screenLoc:me.pScreenLoc])
        tBounceLocV = [0]
      else
        if pBounceState = 3 then
          tBounceLocV = [0, -1, -2, -2.4, -2, -1, -0]
          if me.pBounceAnimCount = 3 then
            me.createEffect(#once, "bb2_efct_pu_spring_", [#ink:33])
          end if
        else
          if pBounceState = 4 then
            tBounceLocV = [0, -0.5, -1, -0, -0.5, -1, -0]
            if me.pBounceAnimCount = 3 then
              me.createEffect(#once, "bb2_efct_pu_drill_", [#ink:33])
            end if
          else
            tBounceLocV = [0, -0.5, -1, -1.2, -1, -0.5, -0]
          end if
        end if
      end if
    end if
  else
    if pBounceState = 8 then
      tBounceLocV = [0.7]
    else
      tBounceLocV = [0, -0.3, -0.4, -0.5, -0.4, -0.1]
    end if
  end if
  me.pBounceAnimCount = me.pBounceAnimCount + 1
  if me.pBounceAnimCount > tBounceLocV.count then
    me.pBounceAnimCount = 1
  end if
  me.setProp(#pScreenLoc, 2, me.getProp(#pScreenLoc, 2) + 10 * tBounceLocV.getAt(me.pBounceAnimCount))
end

on update me 
  me.pSync = not me.pSync
  if me.pSync then
    me.prepare()
  else
    me.render()
  end if
  if pActiveEffects.count = 0 then
    return(1)
  end if
  i = 1
  repeat while i <= pActiveEffects.count
    tEffect = pActiveEffects.getAt(i)
    if tEffect.pActive then
      tEffect.update()
    else
      tEffect.deconstruct()
      pActiveEffects.deleteAt(i)
    end if
    i = 1 + i
  end repeat
end

on render me, tForceUpdate 
  if not me.pChanges then
    return(1)
  end if
  me.pChanges = 0
  if me.pLocChange and not me.pDirChange and not tForceUpdate then
    me.pLocChange = 0
    return(me.setHumanSpriteLoc())
  end if
  if me.pDirChange = 0 and not tForceUpdate then
    return(1)
  end if
  me.pDirChange = 0
  tSize = me.getProp(#pCanvasSize, #std)
  if pShadowSpr.member <> me.pDefShadowMem then
    pShadowSpr.member = me.pDefShadowMem
  end if
  if me or pBuffer.height <> tSize.getAt(2) then
    pMember.image = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
    pMember.regPoint = point(0, tSize.getAt(2) + tSize.getAt(4))
    pSprite.width = tSize.getAt(1)
    pSprite.height = tSize.getAt(2)
    pMatteSpr.width = tSize.getAt(1)
    pMatteSpr.height = tSize.getAt(2)
    me.pBuffer = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
  end if
  0.regPoint = point(me, pMember.getProp(#regPoint, 2))
  me.pShadowFix = 0
  if pSprite.flipH then
    pSprite.flipH = 0
    pMatteSpr.flipH = 0
    pShadowSpr.flipH = 0
  end if
  me.setHumanSpriteLoc()
  me.pUpdateRect = rect(0, 0, 0, 0)
  me.fill(pBuffer.rect, me.pAlphaColor)
  if pBallState then
    call(#update, me.pPartList)
  else
    repeat while me <= undefined
      tPart = getAt(undefined, tForceUpdate)
      if tPart.pPart <> "bl" then
        call(#update, tPart)
      end if
    end repeat
  end if
  image.copyPixels(me.pBuffer, me.pUpdateRect, me.pUpdateRect)
  return(1)
end

on setHumanSpriteLoc me 
  tOffZ = 2
  pSprite.locH = me.getProp(#pScreenLoc, 1)
  pSprite.locV = me.getProp(#pScreenLoc, 2)
  pSprite.locZ = me.getProp(#pScreenLoc, 3) + tOffZ
  me.loc = pSprite.loc
  me.locZ = pSprite.locZ + 1
  me.loc = pSprite.loc + [me.pShadowFix, 0]
  me.locZ = pSprite.locZ - 3
  return(1)
end

on setBallColor me, tColor 
  if pPartIndex.findPos("bl") = 0 then
    return(0)
  end if
  tBallPart = me.getProp(#pPartList, me.getProp(#pPartIndex, "bl"))
  if tBallPart <> void() then
    tBallPart.setColor(tColor)
  end if
  tBallPart.resetMemberCache()
  me.pChanges = 1
  me.pDirChange = 1
  me.render()
  return(1)
end

on setPartLists me, tmodels 
  me.resetAction()
  if not voidp(tmodels.getAt("bl")) then
    pOrigBallColor = tmodels.getAt("bl").getAt("color")
  end if
  callAncestor(#setPartLists, [me], tmodels)
  call(#reset, me.pPartList)
  me.definePartListAction(me.getProp(#pPartListSubSet, "sit"), "sit")
  me.definePartListAction(me.getProp(#pPartListSubSet, "handLeft"), "crr")
  me.definePartListAction(me.getProp(#pPartListSubSet, "handRight"), "crr")
  return(1)
end

on arrangeParts me 
  callAncestor(#arrangeParts, [me], "bouncing.human.parts")
end

on getPicture me, tImg 
  return(me.getPartialPicture(#Full, tImg, 4, "sh"))
end

on getPartClass me, tPartSymbol 
  if tPartSymbol = "bl" then
    return(pBallClass)
  else
    return(me.pPartClass)
  end if
end

on getPartListNameBase me 
  return("bouncing.human.parts")
end

on Refresh me, tX, tY, tH 
  call(#defineDir, me.pPartList, me.pDirection)
  call(#defineDirMultiple, me.pPartList, me.pDirection, me.getProp(#pPartListSubSet, "head"))
  me.arrangeParts()
  return(1)
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
  me.pScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tH)
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
  return(1)
end

on clearEffectAnimation me 
  repeat while pActiveEffects <= undefined
    tEffect = getAt(undefined, undefined)
    tEffect.pActive = 0
  end repeat
end

on setEffectAnimationLocations me, tlocation 
  if tlocation.getAt(#screenLoc) = void() then
    tX = tlocation.getAt(#x)
    tY = tlocation.getAt(#y)
    tZ = tlocation.getAt(#z)
    tlocz = 1 + pActiveEffects.count
    if getObject(#room_interface) = 0 then
      return(0)
    end if
    pGeometry = getObject(#room_interface).getGeometry()
    if pGeometry = 0 then
      return(0)
    end if
    tScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tZ)
  else
    tScreenLoc = tlocation.getAt(#screenLoc)
  end if
  repeat while pActiveEffects <= undefined
    tEffect = getAt(undefined, tlocation)
    tEffect.setLocation(tScreenLoc)
  end repeat
  return(1)
end

on createEffect me, tMode, tEffectID, tProps, tDirection 
  tX = me.pLocX
  tY = me.pLocY
  tZ = me.pLocH
  tlocz = 1 + pActiveEffects.count
  if getObject(#room_interface) = 0 then
    return(0)
  end if
  pGeometry = getObject(#room_interface).getGeometry()
  if pGeometry = 0 then
    return(0)
  end if
  tScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tZ)
  tEffect = createObject(#temp, "BB Effect Animation Class")
  if tEffect = 0 then
    return(error(me, "Unable to create effect object!", #createEffect))
  end if
  tEffect.define(tMode, tScreenLoc, tlocz, tEffectID, tProps, tDirection)
  pActiveEffects.append(tEffect)
  return(1)
end

on action_mv me, tProps 
  me.pMainAction = "sit"
  me.pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  pBounceAnimCount = 1
  tloc = tProps.getProp(#word, 2)
  tLocX = integer(tloc.getProp(#item, 1))
  tLocY = integer(tloc.getProp(#item, 2))
  tLocH = integer(tloc.getProp(#item, 3))
  the itemDelimiter = tDelim
  me.pStartLScreen = pGeometry.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  me.pDestLScreen = pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  me.pMoveStart = the milliSeconds
  me.definePartListAction(me.getProp(#pPartListSubSet, "sit"), "sit")
  me.definePartListAction(me.getProp(#pPartListSubSet, "handLeft"), "crr")
  me.definePartListAction(me.getProp(#pPartListSubSet, "handRight"), "crr")
end

on action_fx me, tProps 
  return(1)
end

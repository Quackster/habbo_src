property pReady, pHiliteSpriteNum, pFramework, pAvatarAction, pInvincible, pInvincibleCounter, pTeamId, pAvatarId, pDump, pActionPartList

on construct me
  pActionPartList = ["bd", "sh"]
  pReady = 0
  pDump = 0
  pAvatarAction = [:]
  pAvatarAction[#tag] = EMPTY
  if not objectp(me.ancestor) then
    return 0
  end if
  return me.ancestor.construct()
end

on deconstruct me
  pReady = 0
  if (pHiliteSpriteNum > 0) then
    releaseSprite(pHiliteSpriteNum)
  end if
  if not objectp(me.ancestor) then
    return 1
  end if
  return me.ancestor.deconstruct()
end

on define me, tdata
  me.pPartClass = getVariableValue("snowwar.bodypart.class")
  pTeamId = string(tdata[#team_id])
  pAvatarId = string(tdata[#human_id])
  callAncestor(#define, me, tdata)
  case tdata[#activity_state] of
    1:
      me.gameObjectAction("start_create")
    2:
      tParams = [:]
      tParams.addProp(#hit_direction, tdata[#body_direction])
      me.gameObjectAction("start_stunned", tParams)
      me.gameObjectAction("next_stunned")
    3:
      me.gameObjectAction("start_invincible")
  end case
  pReady = 1
  me.setOwnHiliter(1)
  return 1
end

on select me
  if (pFramework = VOID) then
    pFramework = getObject(#snowwar_gamesystem)
  end if
  if (pFramework.getGamestatus() <> #game_started) then
    return 0
  end if
  if pFramework.getSpectatorModeFlag() then
    return 0
  end if
  if not getObject(#session).exists("user_game_index") then
    return 0
  end if
  tUserIndex = getObject(#session).GET("user_game_index")
  if (tUserIndex = 0) then
    return error(me, "Own player missing the game object index!", #select)
  end if
  tIsOwnAvatar = (pAvatarId = tUserIndex)
  if tIsOwnAvatar then
    pFramework.executeGameObjectEvent(pAvatarId, #send_create_snowball)
  else
    if (the shiftDown or the optionDown) then
      pFramework.executeGameObjectEvent(pAvatarId, #send_throw_at_player, [#target_id: pAvatarId, #trajectory: 2])
    else
      pFramework.executeGameObjectEvent(pAvatarId, #send_throw_at_player, [#target_id: pAvatarId, #trajectory: 0])
    end if
  end if
  return 0
end

on setAvatarEventListener me, tTargetID
  tsprite = me.pMatteSpr
  if not (ilk(tsprite) = #sprite) then
    return 0
  end if
  tsprite.registerProcedure(#eventProcSnowwarUserRollOver, tTargetID, #mouseEnter)
  tsprite.registerProcedure(#eventProcSnowwarUserRollOver, tTargetID, #mouseLeave)
  return 1
end

on gameObjectRefreshLocation me, tX, tY, tH, tDirHead, tDirBody
  me.resetValues(tX, tY, tH, tDirHead, tDirBody)
  return 1
end

on gameObjectNewMoveTarget me, tX, tY, tH, tDirHead, tDirBody, tAction
  me.pMoveTime = 300
  tX = integer(tX)
  tY = integer(tY)
  tH = integer(tH)
  me.resetValues(me.pLocX, me.pLocY, me.pLocH, tDirHead, tDirBody)
  me.pAvatarAction[#tag] = EMPTY
  me.pMainAction = "wlk"
  me.pMoving = 1
  if (me.pGeometry = 0) then
    return 0
  end if
  me.pStartLScreen = me.pGeometry.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  me.pDestLScreen = me.pGeometry.getScreenCoordinate(tX, tY, tH)
  me.pMoveStart = the milliSeconds
  call(#defineAct, me.getDefinedPartList(pActionPartList), "wlk")
  me.Refresh(me.pLocX, me.pLocY, me.pLocH)
  return 1
end

on gameObjectMoveDone me, tX, tY, tH, tDirHead, tDirBody, tAction
  me.pAnimCounter = 0
  me.resetValues(tX, tY, tH, tDirHead, tDirBody)
  call(#reset, me.pPartList)
  me.setHumanSpriteLoc()
  me.setOwnHiliter(1)
  return 1
end

on gameObjectAction me, tAction, tdata
  case tAction of
    "start_throw":
      me.resetValues(me.pLocX, me.pLocY, me.pLocH, tdata, tdata)
      me.Refresh(me.pLocX, me.pLocY, me.pLocH)
      call(#defineAct, me.getDefinedPartList(pActionPartList), "tr1")
      me.pChanges = 1
      pAvatarAction[#tag] = "throw"
      return me.delay(100, #gameObjectAction, "next_throw")
    "next_throw":
      if (pAvatarAction[#tag] <> "throw") then
        return 1
      end if
      pAvatarAction[#tag] = EMPTY
      call(#reset, me.pPartList)
      me.pChanges = 1
      call(#defineAct, me.getDefinedPartList(pActionPartList), "tr2")
      if pDump then
        put "next_throw calling timer_reset_figure"
      end if
      return me.delay(300, #gameObjectAction, "timer_reset_figure")
    "timer_reset_figure":
      if (pAvatarAction[#tag] <> EMPTY) then
        return 1
      end if
      me.gameObjectAction("reset_figure", tdata)
    "reset_figure":
      me.pInvincible = 0
      me.pMainAction = "std"
      if (pAvatarAction.findPos(#originaldirection) > 0) then
        me.pDirection = pAvatarAction[#originaldirection]
      end if
      pAvatarAction[#tag] = EMPTY
      if (ilk(me.pSprite) = #sprite) then
        me.pSprite.blend = 100
      end if
      me.resetValues(me.pLocX, me.pLocY, me.pLocH, me.pDirection, me.pDirection)
      me.arrangeParts()
      call(#reset, me.pPartList)
      me.pChanges = 1
    "start_create":
      pAvatarAction[#tag] = EMPTY
      tDirection = (me.pDirection - (me.pDirection mod 2))
      call(#defineDir, me.pPartList, tDirection)
      me.pMainAction = "pck"
      call(#defineAct, me.getDefinedPartList(pActionPartList), "pck")
      me.pChanges = 1
      me.arrangeParts()
      me.render()
    "start_stunned":
      me.gameObjectMoveDone(me.pLocX, me.pLocY, me.pLocH, me.pDirection, me.pDirection)
      tBallDirection = (tdata[#hit_direction] - (tdata[#hit_direction] mod 2))
      tMyDirection = (me.pDirection - (me.pDirection mod 2))
      if ((tBallDirection <> tMyDirection) and ((tBallDirection mod 4) = (tMyDirection mod 4))) then
        tDeathDirection = tMyDirection
        tFaceUp = 1
      else
        tDeathDirection = tBallDirection
        tFaceUp = 0
      end if
      pAvatarAction[#direction] = tDeathDirection
      pAvatarAction[#originaldirection] = me.pDirection
      pAvatarAction[#frame] = 1
      pAvatarAction[#tag] = "dead"
      if tFaceUp then
        pAvatarAction[#facedown] = 0
        pAvatarAction[#member] = "fb"
      else
        pAvatarAction[#facedown] = 1
        pAvatarAction[#member] = "ff"
      end if
      me.pDirection = tDeathDirection
      call(#defineDir, me.pPartList, me.pDirection)
      call(#defineAct, me.getDefinedPartList(pActionPartList), (pAvatarAction[#member] & "1"))
      me.pMainAction = "std"
      me.arrangeParts()
      me.render()
      return me.delay(80, #gameObjectAction, "next_stunned")
    "next_stunned":
      if (pAvatarAction[#tag] <> "dead") then
        return me.gameObjectAction("reset_figure")
      end if
      repeat with tPart in me.pPartList
        tPart.pAction = "foo"
      end repeat
      pAvatarAction[#frame] = 2
      call(#defineDirMultiple, me.pPartList, pAvatarAction[#direction], pActionPartList)
      call(#defineAct, me.getDefinedPartList(pActionPartList), (pAvatarAction[#member] & "2"))
      me.pChanges = 1
      me.arrangeParts()
      me.render()
    "start_invincible":
      pAvatarAction[#tag] = EMPTY
      me.gameObjectAction("reset_figure")
      me.pInvincible = 1
      me.pInvincibleCounter = 0
  end case
  return 1
end

on prepare me
  if me.pInvincible then
    me.pInvincibleCounter = (me.pInvincibleCounter + 1)
    if (me.pInvincibleCounter > 2) then
      me.setBlendInvincible()
      me.pInvincibleCounter = 0
    end if
  end if
  me.pAnimCounter = ((me.pAnimCounter + 1) mod 4)
  if me.pMoving then
    tFactor = (float((the milliSeconds - me.pMoveStart)) / me.pMoveTime)
    if (tFactor > 1.0) then
      tFactor = 1.0
    end if
    me.pScreenLoc = (((me.pDestLScreen - me.pStartLScreen) * tFactor) + me.pStartLScreen)
    me.pChanges = 1
  end if
end

on update me
  if (pAvatarAction[#tag] = "dead") then
    return 1
  end if
  me.pSync = not me.pSync
  if me.pSync then
    me.prepare()
  else
    me.render()
  end if
end

on render me
  if not me.pChanges then
    return 0
  end if
  if not pReady then
    return 0
  end if
  me.pChanges = 0
  if (me.pMainAction = "sit") then
    tSize = me.pCanvasSize[#std]
    me.pShadowSpr.castNum = getmemnum((((me.pPeopleSize & "_sit_sd_001_") & me.pFlipList[(me.pDirection + 1)]) & "_0"))
  else
    if (me.pMainAction = "lay") then
      tSize = me.pCanvasSize[#lay]
      me.pShadowSpr.castNum = 0
      me.pShadowFix = 0
    else
      tSize = me.pCanvasSize[#std]
      if (pAvatarAction[#tag] = "dead") then
        me.pShadowSpr.castNum = 0
        tSize = [62, 40, 32, 0]
        me.pMember.regPoint = point(0, (tSize[2] + tSize[4]))
      else
        if (me.pShadowSpr.member <> me.pDefShadowMem) then
          me.pShadowSpr.member = me.pDefShadowMem
        end if
      end if
    end if
  end if
  if ((me.pBuffer.width <> tSize[1]) or (me.pBuffer.height <> tSize[2])) then
    me.pMember.image = image(tSize[1], tSize[2], tSize[3])
    me.pMember.regPoint = point(0, (tSize[2] + tSize[4]))
    me.pSprite.width = tSize[1]
    me.pSprite.height = tSize[2]
    me.pMatteSpr.width = tSize[1]
    me.pMatteSpr.height = tSize[2]
    me.pBuffer = image(tSize[1], tSize[2], tSize[3])
    repeat with tPart in me.pPartList
      tPart.resetMemberCache()
    end repeat
  end if
  me.pMember.regPoint = point(0, me.pMember.regPoint[2])
  me.pShadowFix = 0
  if me.pSprite.flipH then
    me.pSprite.flipH = 0
    me.pMatteSpr.flipH = 0
    me.pShadowSpr.flipH = 0
  end if
  if (pAvatarAction[#tag] = "dead") then
    if (pAvatarAction[#frame] = 1) then
      if pAvatarAction[#facedown] then
        case pAvatarAction[#direction] of
          0:
            tpoint = point(-8, 0)
          2:
            tpoint = point(-10, -2)
          4:
            tpoint = point(35, -5)
          6:
            tpoint = point(37, 0)
        end case
      else
        case pAvatarAction[#direction] of
          0:
            tpoint = point(10, -3)
          2:
            tpoint = point(30, 0)
          4:
            tpoint = point(0, 0)
          6:
            tpoint = point(17, -3)
        end case
      end if
    else
      if pAvatarAction[#facedown] then
        case pAvatarAction[#direction] of
          0:
            tpoint = point(-15, -10)
          2:
            tpoint = point(-12, -36)
          4:
            tpoint = point(38, -36)
          6:
            tpoint = point(42, -10)
        end case
      else
        case pAvatarAction[#direction] of
          0:
            tpoint = point(38, -27)
          2:
            tpoint = point(37, -3)
          4:
            tpoint = point(-7, -3)
          6:
            tpoint = point(-10, -26)
        end case
      end if
    end if
    me.pMember.regPoint = (me.pMember.regPoint + tpoint)
  end if
  if me.pCorrectLocZ then
    tOffZ = (((me.pLocH + me.pRestingHeight) * 1000) + 2)
  else
    tOffZ = 2
  end if
  me.pSprite.locH = me.pScreenLoc[1]
  me.pSprite.locV = me.pScreenLoc[2]
  me.pMatteSpr.loc = me.pSprite.loc
  me.pShadowSpr.loc = (me.pSprite.loc + [me.pShadowFix, 0])
  if (me.pBaseLocZ <> 0) then
    me.pSprite.locZ = me.pBaseLocZ
  else
    me.pSprite.locZ = ((me.pScreenLoc[3] + tOffZ) + me.pBaseLocZ)
  end if
  me.pMatteSpr.locZ = (me.pSprite.locZ + 1)
  me.pShadowSpr.locZ = (me.pSprite.locZ - 3)
  me.pUpdateRect = rect(0, 0, 0, 0)
  me.pBuffer.fill(me.pBuffer.rect, me.pAlphaColor)
  call(#update, me.pPartList)
  me.pMember.image.copyPixels(me.pBuffer, me.pUpdateRect, me.pUpdateRect)
  me.setOwnHiliter(1)
  return 1
end

on setHumanSpriteLoc me
  tOffZ = 2
  if (ilk(me.pSprite) <> #sprite) then
    return 0
  end if
  me.pSprite.locH = me.pScreenLoc[1]
  me.pSprite.locV = me.pScreenLoc[2]
  me.pSprite.locZ = (me.pScreenLoc[3] + tOffZ)
  me.pMatteSpr.loc = me.pSprite.loc
  me.pMatteSpr.locZ = (me.pSprite.locZ + 1)
  me.pShadowSpr.loc = (me.pSprite.loc + [me.pShadowFix, 0])
  me.pShadowSpr.locZ = (me.pSprite.locZ - 3)
  return 1
end

on Refresh me, tX, tY, tH
  call(#defineDir, me.pPartList, me.pDirection)
  me.arrangeParts()
  me.pChanges = 1
  return 1
end

on resetValues me, tX, tY, tH, tDirHead, tDirBody
  me.pMainAction = "std"
  me.pLocX = tX
  me.pLocY = tY
  me.pLocH = tH
  if (me.pGeometry = VOID) then
    return 0
  end if
  me.pScreenLoc = me.pGeometry.getScreenCoordinate(tX, tY, tH)
  me.pMoving = 0
  call(#reset, me.pPartList)
  me.pDirection = tDirBody
  me.pHeadDir = tDirHead
  me.pChanges = 1
  return 1
end

on setBlendInvincible me
  tsprite = me.pSprite
  if (ilk(tsprite) <> #sprite) then
    return 0
  end if
  if (tsprite.blend < 100) then
    tsprite.blend = 100
  else
    tsprite.blend = 20
  end if
  return 1
end

on arrangeParts me
  if (me.pPartList = VOID) then
    return 0
  end if
  if (me.pPartList.count = 0) then
    return 0
  end if
  case 1 of
    (pAvatarAction[#tag] = "dead"):
      me.arrangeParts_Death()
    (me.pMainAction = "pck"):
      me.arrangeParts_Pick()
    otherwise:
      callAncestor(#arrangeParts, me)
  end case
  repeat with i = 1 to me.pPartList.count
    me.pPartIndex[me.pPartList[i].pPart] = i
  end repeat
  return 1
end

on arrangeParts_Pick me, tXFix, tYFix
  if (me.pPartList = VOID) then
    return 0
  end if
  tDirection = (me.pDirection - (me.pDirection mod 2))
  repeat with tPart in me.pPartList
    if (pActionPartList.findPos(tPart.pPart) = 0) then
      tPart.pXFix = 3
      tPart.pYFix = 5
    end if
  end repeat
  me.pChanges = 1
  return 1
end

on arrangeParts_Death me
  if (me.pPartList = VOID) then
    return 0
  end if
  if pAvatarAction[#facedown] then
    case pAvatarAction[#direction] of
      0:
        tHeadBelow = 1
        tFace = point(-3, 11)
      2:
        tFace = point(1, 9)
      4:
        tFace = point(3, 9)
      6:
        tHeadBelow = 1
        tFace = point(-1, 10)
    end case
  else
    case pAvatarAction[#direction] of
      0:
        tHeadBelow = 1
        tFace = point(-2, 10)
      2:
        tFace = point(19, 8)
      4:
        tFace = point(18, 7)
      6:
        tHeadBelow = 1
        tFace = point(-1, 10)
    end case
  end if
  tActionParts = []
  repeat with tPart in pActionPartList
    if not voidp(me.pPartIndex[tPart]) then
      tActionParts.add(me.pPartList[me.pPartIndex[tPart]])
    end if
  end repeat
  repeat with i = me.pPartList.count down to 1
    tPart = me.pPartList[i]
    if (pActionPartList.findPos(tPart.pPart) > 0) then
      me.pPartList.deleteAt(i)
    end if
  end repeat
  tHeadBelow = 1
  repeat with i = 1 to tActionParts.count
    tPart = tActionParts[i]
    if tHeadBelow then
      me.pPartList.append(tPart)
      next repeat
    end if
    me.pPartList.addAt(i, tPart)
  end repeat
  repeat with tPart in me.pPartList
    if (pActionPartList.findPos(tPart.pPart) = 0) then
      tPart.pXFix = tFace.locH
      tPart.pYFix = tFace.locV
    end if
  end repeat
  me.pChanges = 1
  return 1
end

on getPartListNameBase me
  return "snowwar.human.parts"
end

on setPartLists me, tmodels
  tmodels = me.fixSnowWarFigure(tmodels)
  callAncestor(#setPartLists, me, tmodels)
  return 1
end

on fixSnowWarFigure me, tFigure
  repeat with tPartSymbol in pActionPartList
    if voidp(tFigure[tPartSymbol]) then
      tFigure[tPartSymbol] = [:]
    end if
    tFigure[tPartSymbol]["model"] = "snowwar"
    tFigure[tPartSymbol]["color"] = rgb("EEEEEE")
  end repeat
  if (getObject(#session).GET("game_number_of_teams") > 1) then
    tTeamColor = rgb(string(getVariable(("snowwar.teamcolors.team" & pTeamId))))
  else
    if not voidp(tFigure["ch"]) then
      tTeamColor = tFigure["ch"]["color"]
    else
      tTeamColor = rgb("EEEEEE")
    end if
  end if
  if not voidp(tFigure["sh"]) then
    tFigure["sh"]["color"] = tTeamColor
  end if
  return tFigure
end

on setOwnHiliter me, tstate
  if not getObject(#session).exists("user_index") then
    return 0
  end if
  if (me.getID() <> getObject(#session).GET("user_index")) then
    return 0
  end if
  if (pHiliteSpriteNum = 0) then
    if not tstate then
      return 1
    end if
    if (pTeamId = VOID) then
      return 0
    end if
    pHiliteSpriteNum = reserveSprite(("sw_own_hiliter_" & me.getID()))
    if (pHiliteSpriteNum = 0) then
      return 0
    end if
    tsprite = sprite(pHiliteSpriteNum)
    tmember = member(getmemnum(("sw_avatar_hilite_team_" & pTeamId)))
    if (tmember.type = #bitmap) then
      tsprite.member = tmember
    end if
    tsprite.visible = 1
    tsprite.ink = 36
  else
    tsprite = sprite(pHiliteSpriteNum)
    tsprite.visible = tstate
  end if
  tsprite.locZ = (me.pScreenLoc[3] + 1)
  tsprite.loc = point((me.pScreenLoc[1] + (tsprite.member.width / 2)), me.pScreenLoc[2])
end

on getPicture me, tImg
  return me.getPartialPicture(#Full, tImg, 4, "sh")
end

on getTeamId me
  return pTeamId
end

on getAvatarId me
  return pAvatarId
end

on action_mv me, tProps
  me.pMoveTime = 500
  me.pMainAction = "wlk"
  me.pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.word[2]
  tLocX = integer(tloc.item[1])
  tLocY = integer(tloc.item[2])
  tLocH = integer(tloc.item[3])
  the itemDelimiter = tDelim
  if (me.pGeometry = 0) then
    return 0
  end if
  me.pStartLScreen = me.pGeometry.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  me.pDestLScreen = me.pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  me.pMoveStart = the milliSeconds
  call(#defineAct, me.getDefinedPartList(pActionPartList), "wlk")
end

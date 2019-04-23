property pAvatarAction, pHiliteSpriteNum, pTeamId, pFramework, pAvatarId, pDump, pReady

on construct me 
  pReady = 0
  pDump = 0
  pAvatarAction = [:]
  pAvatarAction.setAt(#tag, "")
  if not objectp(me.ancestor) then
    return(0)
  end if
  return(me.construct())
end

on deconstruct me 
  pReady = 0
  if pHiliteSpriteNum > 0 then
    releaseSprite(pHiliteSpriteNum)
  end if
  if not objectp(me.ancestor) then
    return(1)
  end if
  return(me.deconstruct())
end

on define me, tdata 
  callAncestor(#define, me, tdata)
  me.setPartLists(tdata.getAt(#figure))
  pTeamId = string(tdata.getAt(#team_id))
  pAvatarId = string(tdata.getAt(#human_id))
  if getObject(#session).GET("game_number_of_teams", tdata) > 1 then
    tTeamColor = rgb(string(getVariable("snowwar.teamcolors.team" & pTeamId)))
    me.setPartColor("sh", tTeamColor)
  else
    if tdata.getAt(#figure) <> void() then
      if ilk(tdata.getAt(#figure)) = #propList then
        me.setPartColor("sh", tdata.getAt(#figure).getAt("ch").getAt("color"))
      end if
    end if
  end if
  if tdata.getAt(#activity_state) = 1 then
    me.gameObjectAction("start_create")
  else
    if tdata.getAt(#activity_state) = 2 then
      tParams = [:]
      tParams.addProp(#hit_direction, tdata.getAt(#body_direction))
      me.gameObjectAction("start_stunned", tParams)
      me.gameObjectAction("next_stunned")
    else
      if tdata.getAt(#activity_state) = 3 then
        me.gameObjectAction("start_invincible")
      end if
    end if
  end if
  pReady = 1
  me.setOwnHiliter(1)
  return(1)
end

on select me 
  if pFramework = void() then
    pFramework = getObject(#snowwar_gamesystem)
  end if
  if pFramework.getGamestatus() <> #game_started then
    return(0)
  end if
  if pFramework.getSpectatorModeFlag() then
    return(0)
  end if
  if not getObject(#session).exists("user_game_index") then
    return(0)
  end if
  tUserIndex = getObject(#session).GET("user_game_index")
  if tUserIndex = 0 then
    return(error(me, "Own player missing the game object index!", #select))
  end if
  tIsOwnAvatar = pAvatarId = tUserIndex
  if tIsOwnAvatar then
    pFramework.executeGameObjectEvent(pAvatarId, #send_create_snowball)
  else
    if the shiftDown or the optionDown then
      pFramework.executeGameObjectEvent(pAvatarId, #send_throw_at_player, [#target_id:pAvatarId, #trajectory:2])
    else
      pFramework.executeGameObjectEvent(pAvatarId, #send_throw_at_player, [#target_id:pAvatarId, #trajectory:0])
    end if
  end if
  return(0)
end

on setAvatarEventListener me, tTargetID 
  tsprite = me.pMatteSpr
  if not ilk(tsprite) = #sprite then
    return(0)
  end if
  tsprite.registerProcedure(#eventProcSnowwarUserRollOver, tTargetID, #mouseEnter)
  tsprite.registerProcedure(#eventProcSnowwarUserRollOver, tTargetID, #mouseLeave)
  return(1)
end

on gameObjectRefreshLocation me, tX, tY, tH, tDirHead, tDirBody 
  me.resetValues(tX, tY, tH, tDirHead, tDirBody)
  return(1)
end

on gameObjectNewMoveTarget me, tX, tY, tH, tDirHead, tDirBody, tAction 
  me.pMoveTime = 300
  tX = integer(tX)
  tY = integer(tY)
  tH = integer(tH)
  me.resetValues(me.pLocX, me.pLocY, me.pLocH, tDirHead, tDirBody)
  me.setProp(#pAvatarAction, #tag, "")
  me.pMainAction = "wlk"
  me.pMoving = 1
  if me.pGeometry = 0 then
    return(0)
  end if
  me.pStartLScreen = me.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  me.pDestLScreen = me.getScreenCoordinate(tX, tY, tH)
  me.pMoveStart = the milliSeconds
  call(#defineActMultiple, me.pPartList, "wlk", ["bd", "sh"])
  call(#defineActMultiple, me.pPartList, "std", ["lh", "rh", "ls", "rs"])
  me.Refresh(me.pLocX, me.pLocY, me.pLocH)
  return(1)
end

on gameObjectMoveDone me, tX, tY, tH, tDirHead, tDirBody, tAction 
  me.pAnimCounter = 0
  me.resetValues(tX, tY, tH, tDirHead, tDirBody)
  call(#reset, me.pPartList)
  me.setHumanSpriteLoc()
  me.setOwnHiliter(1)
  return(1)
end

on gameObjectAction me, tAction, tdata 
  if tAction = "start_throw" then
    me.resetValues(me.pLocX, me.pLocY, me.pLocH, tdata, tdata)
    me.Refresh(me.pLocX, me.pLocY, me.pLocH)
    call(#defineActMultiple, me.pPartList, "tr1", ["bd", "sh"])
    me.pChanges = 1
    pAvatarAction.setAt(#tag, "throw")
    return(me.delay(100, #gameObjectAction, "next_throw"))
  else
    if tAction = "next_throw" then
      if pAvatarAction.getAt(#tag) <> "throw" then
        return(1)
      end if
      pAvatarAction.setAt(#tag, "")
      call(#reset, me.pPartList)
      me.pChanges = 1
      call(#defineActMultiple, me.pPartList, "tr2", ["bd", "sh"])
      if pDump then
        put("next_throw calling timer_reset_figure")
      end if
      return(me.delay(300, #gameObjectAction, "timer_reset_figure"))
    else
      if tAction = "timer_reset_figure" then
        if pAvatarAction.getAt(#tag) <> "" then
          return(1)
        end if
        me.gameObjectAction("reset_figure", tdata)
      else
        if tAction = "reset_figure" then
          me.pInvincible = 0
          me.pMainAction = "std"
          if pAvatarAction.findPos(#originaldirection) > 0 then
            me.pDirection = pAvatarAction.getAt(#originaldirection)
          end if
          pAvatarAction.setAt(#tag, "")
          if ilk(me.pSprite) = #sprite then
            me.blend = 100
          end if
          me.resetValues(me.pLocX, me.pLocY, me.pLocH, me.pDirection, me.pDirection)
          me.arrangeParts()
          call(#reset, me.pPartList)
          me.pChanges = 1
        else
          if tAction = "start_create" then
            pAvatarAction.setAt(#tag, "")
            tDirection = me.pDirection - me.pDirection mod 2
            call(#defineDir, me.pPartList, tDirection)
            me.pMainAction = "pck"
            call(#defineActMultiple, me.pPartList, "pck", ["bd", "sh"])
            me.pChanges = 1
            me.arrangeParts()
            me.render()
          else
            if tAction = "start_stunned" then
              me.gameObjectMoveDone(me.pLocX, me.pLocY, me.pLocH, me.pDirection, me.pDirection)
              tBallDirection = tdata.getAt(#hit_direction) - tdata.getAt(#hit_direction) mod 2
              tMyDirection = me.pDirection - me.pDirection mod 2
              if tBallDirection <> tMyDirection and tBallDirection mod 4 = tMyDirection mod 4 then
                tDeathDirection = tMyDirection
                tFaceUp = 1
              else
                tDeathDirection = tBallDirection
                tFaceUp = 0
              end if
              pAvatarAction.setAt(#direction, tDeathDirection)
              pAvatarAction.setAt(#originaldirection, me.pDirection)
              pAvatarAction.setAt(#frame, 1)
              pAvatarAction.setAt(#tag, "dead")
              if tFaceUp then
                pAvatarAction.setAt(#facedown, 0)
                pAvatarAction.setAt(#member, "fb")
              else
                pAvatarAction.setAt(#facedown, 1)
                pAvatarAction.setAt(#member, "ff")
              end if
              me.pDirection = tDeathDirection
              call(#defineDir, me.pPartList, me.pDirection)
              call(#defineActExplicit, me.pPartList, pAvatarAction.getAt(#member) & "1", ["bd", "sh"])
              me.pMainAction = "std"
              me.arrangeParts()
              me.render()
              return(me.delay(80, #gameObjectAction, "next_stunned"))
            else
              if tAction = "next_stunned" then
                if pAvatarAction.getAt(#tag) <> "dead" then
                  return(me.gameObjectAction("reset_figure"))
                end if
                repeat while tAction <= tdata
                  tPart = getAt(tdata, tAction)
                  tPart.pAction = "foo"
                end repeat
                pAvatarAction.setAt(#frame, 2)
                call(#defineDirMultiple, me.pPartList, pAvatarAction.getAt(#direction), ["bd", "sh"])
                call(#defineActExplicit, me.pPartList, pAvatarAction.getAt(#member) & "2", ["bd", "sh"])
                me.pChanges = 1
                me.arrangeParts()
                me.render()
              else
                if tAction = "start_invincible" then
                  pAvatarAction.setAt(#tag, "")
                  me.gameObjectAction("reset_figure")
                  me.pInvincible = 1
                  me.pInvincibleCounter = 0
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return(1)
end

on prepare me 
  if me.pInvincible then
    me.pInvincibleCounter = me.pInvincibleCounter + 1
    if me.pInvincibleCounter > 2 then
      me.setBlendInvincible()
      me.pInvincibleCounter = 0
    end if
  end if
  me.pAnimCounter = me.pAnimCounter + 1 mod 4
  if me.pMoving then
    tFactor = float(the milliSeconds - me.pMoveStart) / me.pMoveTime
    if tFactor > 1 then
      tFactor = 1
    end if
    me.pScreenLoc = me.pDestLScreen - me.pStartLScreen * tFactor + me.pStartLScreen
    me.pChanges = 1
  end if
end

on update me 
  if pAvatarAction.getAt(#tag) = "dead" then
    return(1)
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
    return(0)
  end if
  if not pReady then
    return(0)
  end if
  me.pChanges = 0
  if me.pMainAction = "sit" then
    tSize = me.getProp(#pCanvasSize, #std)
    me.castNum = getmemnum(me.pPeopleSize & "_sit_sd_001_" & me.getProp(#pFlipList, me.pDirection + 1) & "_0")
  else
    if me.pMainAction = "lay" then
      tSize = me.getProp(#pCanvasSize, #lay)
      me.castNum = 0
      me.pShadowFix = 0
    else
      tSize = me.getProp(#pCanvasSize, #std)
      if pAvatarAction.getAt(#tag) = "dead" then
        me.castNum = 0
        tSize = [62, 40, 32, 0]
        me.regPoint = point(0, tSize.getAt(2) + tSize.getAt(4))
      else
        if me.member <> me.pDefShadowMem then
          me.member = me.pDefShadowMem
        end if
      end if
    end if
  end if
  if me.width <> tSize.getAt(1) or me.height <> tSize.getAt(2) then
    me.image = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
    me.regPoint = point(0, tSize.getAt(2) + tSize.getAt(4))
    me.width = tSize.getAt(1)
    me.height = tSize.getAt(2)
    me.width = tSize.getAt(1)
    me.height = tSize.getAt(2)
    me.pBuffer = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
    repeat while me.pPartList <= undefined
      tPart = getAt(undefined, undefined)
      tPart.pMemString = ""
    end repeat
  end if
  if me.getProp(#pFlipList, me.pDirection + 1) <> me.pDirection or me.pDirection = 3 and me.pHeadDir = 4 or me.pDirection = 7 and me.pHeadDir = 6 then
    me.regPoint = point(undefined.width, me.getProp(#regPoint, 2))
    me.pShadowFix = me.pXFactor
    if not me.flipH then
      me.flipH = 1
      me.flipH = 1
      me.flipH = 1
    end if
  else
    me.regPoint = point(0, me.getProp(#regPoint, 2))
    me.pShadowFix = 0
    if me.flipH then
      me.flipH = 0
      me.flipH = 0
      me.flipH = 0
    end if
  end if
  if pAvatarAction.getAt(#tag) = "dead" then
    if pAvatarAction.getAt(#frame) = 1 then
      if pAvatarAction.getAt(#facedown) then
        if me.pPartList = 0 then
          tpoint = point(-8, 0)
        else
          if me.pPartList = 2 then
            tpoint = point(-10, -2)
          else
            if me.pPartList = 4 then
              tpoint = point(-40, -2)
            else
              if me.pPartList = 6 then
                tpoint = point(-36, 0)
              end if
            end if
          end if
        end if
      else
        if me.pPartList = 0 then
          tpoint = point(10, -3)
        else
          if me.pPartList = 2 then
            tpoint = point(30, 0)
          else
            if me.pPartList = 4 then
              tpoint = point(0, 0)
            else
              if me.pPartList = 6 then
                tpoint = point(-20, -3)
              end if
            end if
          end if
        end if
      end if
    else
      if pAvatarAction.getAt(#facedown) then
        if me.pPartList = 0 then
          tpoint = point(-15, -10)
        else
          if me.pPartList = 2 then
            tpoint = point(-16, -40)
          else
            if me.pPartList = 4 then
              tpoint = point(-46, -40)
            else
              if me.pPartList = 6 then
                tpoint = point(-46, -10)
              end if
            end if
          end if
        end if
      else
        if me.pPartList = 0 then
          tpoint = point(38, -27)
        else
          if me.pPartList = 2 then
            tpoint = point(37, -3)
          else
            if me.pPartList = 4 then
              tpoint = point(7, -3)
            else
              if me.pPartList = 6 then
                tpoint = point(10, -29)
              end if
            end if
          end if
        end if
      end if
    end if
    me.regPoint = me.regPoint + tpoint
  end if
  if me.pCorrectLocZ then
    tOffZ = me.pLocH + me.pRestingHeight * 1000 + 2
  else
    tOffZ = 2
  end if
  me.locH = me.getProp(#pScreenLoc, 1)
  me.locV = me.getProp(#pScreenLoc, 2)
  me.loc = me.loc
  me.loc = me.loc + [me.pShadowFix, 0]
  if me.pBaseLocZ <> 0 then
    me.locZ = me.pBaseLocZ
  else
    me.locZ = me.getProp(#pScreenLoc, 3) + tOffZ + me.pBaseLocZ
  end if
  me.locZ = me.locZ + 1
  me.locZ = me.locZ - 3
  me.pUpdateRect = rect(0, 0, 0, 0)
  me.fill(me.rect, me.pAlphaColor)
  call(#update, me.pPartList)
  undefined.copyPixels(me.pBuffer, me.pUpdateRect, me.pUpdateRect)
  me.setOwnHiliter(1)
  return(1)
end

on setHumanSpriteLoc me 
  tOffZ = 2
  if ilk(me.pSprite) <> #sprite then
    return(0)
  end if
  me.locH = me.getProp(#pScreenLoc, 1)
  me.locV = me.getProp(#pScreenLoc, 2)
  me.locZ = me.getProp(#pScreenLoc, 3) + tOffZ
  me.loc = me.loc
  me.locZ = me.locZ + 1
  me.loc = me.loc + [me.pShadowFix, 0]
  me.locZ = me.locZ - 3
  return(1)
end

on Refresh me, tX, tY, tH 
  call(#defineDir, me.pPartList, me.pDirection)
  call(#defineDirMultiple, me.pPartList, me.pDirection, ["hd", "hr", "ey", "fc"])
  me.arrangeParts()
  me.pChanges = 1
  return(1)
end

on resetValues me, tX, tY, tH, tDirHead, tDirBody 
  me.pMainAction = "std"
  me.pLocX = tX
  me.pLocY = tY
  me.pLocH = tH
  if me.pGeometry = void() then
    return(0)
  end if
  me.pScreenLoc = me.getScreenCoordinate(tX, tY, tH)
  me.pMoving = 0
  call(#reset, me.pPartList)
  me.pDirection = tDirBody
  me.pHeadDir = tDirHead
  me.pChanges = 1
  return(1)
end

on setBlendInvincible me 
  tsprite = me.pSprite
  if ilk(tsprite) <> #sprite then
    return(0)
  end if
  if tsprite.blend < 100 then
    tsprite.blend = 100
  else
    tsprite.blend = 20
  end if
  return(1)
end

on arrangeParts me 
  if me.pPartList = void() then
    return(0)
  end if
  if me.count(#pPartList) = 0 then
    return(0)
  end if
  if 1 = pAvatarAction.getAt(#tag) = "dead" then
    me.arrangeParts_Death()
  else
    if 1 = me.pMainAction = "pck" then
      me.arrangeParts_Pick()
    else
      me.arrangeParts_Normal()
    end if
  end if
  i = 1
  repeat while i <= me.count(#pPartList)
    me.setProp(#pPartIndex, me.getPropRef(#pPartList, i).pPart, i)
    i = 1 + i
  end repeat
  return(1)
end

on arrangeParts_Normal me 
  if me.pPartList = void() then
    return(0)
  end if
  repeat while ["hd", "fc", "ey", "hr", "sh", "bd"] <= undefined
    tPartId = getAt(undefined, undefined)
    if me.count(#pPartList) < me.getProp(#pPartIndex, tPartId) then
      return(0)
    end if
    tPart = me.getProp(#pPartList, me.getProp(#pPartIndex, tPartId))
    if tPart <> void() then
      tPart.pXFix = 0
      tPart.pYFix = 0
    end if
  end repeat
  tBD = me.getProp(#pPartList, me.getProp(#pPartIndex, "bd"))
  tSH = me.getProp(#pPartList, me.getProp(#pPartIndex, "sh"))
  me.deleteOne(tBD)
  me.deleteOne(tSH)
  if ["hd", "fc", "ey", "hr", "sh", "bd"] <> 0 then
    if ["hd", "fc", "ey", "hr", "sh", "bd"] <> 7 then
      if ["hd", "fc", "ey", "hr", "sh", "bd"] = 6 then
        me.append(tBD)
        me.append(tSH)
      else
        me.addAt(1, tSH)
        me.addAt(1, tBD)
      end if
      return(1)
    end if
  end if
end

on arrangeParts_Pick me, tXFix, tYFix 
  if me.pPartList = void() then
    return(0)
  end if
  repeat while ["hd", "fc", "ey", "hr"] <= tYFix
    tPartId = getAt(tYFix, tXFix)
    tPart = me.getProp(#pPartList, me.getProp(#pPartIndex, tPartId))
    if tPart <> void() then
      tPart.pXFix = 3
      tPart.pYFix = 5
    end if
  end repeat
  me.pChanges = 1
  return(1)
end

on arrangeParts_Death me 
  if me.pPartList = void() then
    return(0)
  end if
  if pAvatarAction.getAt(#facedown) then
    if pAvatarAction.getAt(#direction) = 0 then
      tHeadBelow = 1
      tFace = point(-3, 11)
    else
      if pAvatarAction.getAt(#direction) = 2 then
        tFace = point(1, 9)
      else
        if pAvatarAction.getAt(#direction) = 4 then
          tFace = point(3, 9)
        else
          if pAvatarAction.getAt(#direction) = 6 then
            tHeadBelow = 1
            tFace = point(-1, 10)
          end if
        end if
      end if
    end if
  else
    if pAvatarAction.getAt(#direction) = 0 then
      tHeadBelow = 1
      tFace = point(-2, 10)
    else
      if pAvatarAction.getAt(#direction) = 2 then
        tFace = point(19, 8)
      else
        if pAvatarAction.getAt(#direction) = 4 then
          tFace = point(18, 7)
        else
          if pAvatarAction.getAt(#direction) = 6 then
            tHeadBelow = 1
            tFace = point(-1, 10)
          end if
        end if
      end if
    end if
  end if
  tBD = me.getProp(#pPartList, me.getProp(#pPartIndex, "bd"))
  tSH = me.getProp(#pPartList, me.getProp(#pPartIndex, "sh"))
  me.deleteOne(tBD)
  me.deleteOne(tSH)
  if tHeadBelow then
    me.append(tBD)
    me.append(tSH)
  else
    me.addAt(1, tBD)
    me.addAt(2, tSH)
  end if
  repeat while pAvatarAction.getAt(#direction) <= undefined
    tPart = getAt(undefined, undefined)
    if tPart <> tBD and tPart <> tSH then
      tPart.pTalking = 0
      tPart.pXFix = tFace.locH
      tPart.pYFix = tFace.locV
    end if
  end repeat
  me.pChanges = 1
  return(1)
end

on setPartLists me, tmodels 
  tAction = me.pMainAction
  me.pPartList = []
  tPartDefinition = getVariableValue("snowwar.human.parts." & me.pPeopleSize)
  tPartClass = getVariableValue("snowwar.bodypart.class")
  i = 1
  repeat while i <= tPartDefinition.count
    tPartSymbol = tPartDefinition.getAt(i)
    if voidp(tmodels.getAt(tPartSymbol)) then
      tmodels.setAt(tPartSymbol, [:])
    end if
    if voidp(tmodels.getAt(tPartSymbol).getAt("model")) then
      tmodels.getAt(tPartSymbol).setAt("model", "001")
    end if
    if voidp(tmodels.getAt(tPartSymbol).getAt("color")) then
      tmodels.getAt(tPartSymbol).setAt("color", rgb("EEEEEE"))
    end if
    if tPartSymbol = "fc" and tmodels.getAt(tPartSymbol).getAt("model") <> "001" and me.pXFactor < 33 then
      tmodels.getAt(tPartSymbol).setAt("model", "001")
    end if
    if tPartSymbol = "bd" or tPartSymbol = "sh" then
      tmodels.getAt(tPartSymbol).setAt("model", "snowwar")
      tmodels.getAt(tPartSymbol).setAt("color", rgb("EEEEEE"))
    end if
    tPartObj = createObject(#temp, tPartClass)
    if stringp(tmodels.getAt(tPartSymbol).getAt("color")) then
      tColor = value("rgb(" & tmodels.getAt(tPartSymbol).getAt("color") & ")")
    end if
    if tmodels.getAt(tPartSymbol).getAt("color").ilk <> #color then
      tColor = rgb(tmodels.getAt(tPartSymbol).getAt("color"))
    else
      tColor = tmodels.getAt(tPartSymbol).getAt("color")
    end if
    if tColor.red + tColor.green + tColor.blue > 238 * 3 then
      tColor = rgb("EEEEEE")
    end if
    tPartObj.define(tPartSymbol, tmodels.getAt(tPartSymbol).getAt("model"), tColor, me.pDirection, tAction, me)
    me.add(tPartObj)
    me.setaProp(tPartSymbol, tColor)
    i = 1 + i
  end repeat
  me.pPartIndex = [:]
  i = 1
  repeat while i <= me.count(#pPartList)
    me.setProp(#pPartIndex, me.getPropRef(#pPartList, i).pPart, i)
    i = 1 + i
  end repeat
  return(1)
end

on setOwnHiliter me, tstate 
  if not getObject(#session).exists("user_index") then
    return(0)
  end if
  if me.getID() <> getObject(#session).GET("user_index") then
    return(0)
  end if
  if pHiliteSpriteNum = 0 then
    if not tstate then
      return(1)
    end if
    if pTeamId = void() then
      return(0)
    end if
    pHiliteSpriteNum = reserveSprite("sw_own_hiliter_" & me.getID())
    if pHiliteSpriteNum = 0 then
      return(0)
    end if
    tsprite = sprite(pHiliteSpriteNum)
    tmember = member(getmemnum("sw_avatar_hilite_team_" & pTeamId))
    if tmember.type = #bitmap then
      tsprite.member = tmember
    end if
    tsprite.visible = 1
    tsprite.ink = 36
  else
    tsprite = sprite(pHiliteSpriteNum)
    tsprite.visible = tstate
  end if
  tsprite.locZ = me.getProp(#pScreenLoc, 3) + 1
  me.getProp(#pScreenLoc, 1).loc = point(tsprite + member.width / 2, me.getProp(#pScreenLoc, 2))
end

on getPicture me, tImg 
  if voidp(tImg) then
    tCanvas = image(64, 102, 32)
  else
    tCanvas = tImg
  end if
  tPartDefinition = getVariableValue("snowwar.human.parts.sh")
  tTempPartList = []
  repeat while tPartDefinition <= undefined
    tPartSymbol = getAt(undefined, tImg)
    if not voidp(me.getProp(#pPartIndex, tPartSymbol)) then
      tTempPartList.append(me.getProp(#pPartList, me.getProp(#pPartIndex, tPartSymbol)))
    end if
  end repeat
  call(#copyPicture, tTempPartList, tCanvas, void(), "sh")
  return(me.flipImage(tCanvas))
end

on getTeamId me 
  return(pTeamId)
end

on getAvatarId me 
  return(pAvatarId)
end

on action_mv me, tProps 
  me.pMoveTime = 500
  me.pMainAction = "wlk"
  me.pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.getProp(#word, 2)
  tLocX = integer(tloc.getProp(#item, 1))
  tLocY = integer(tloc.getProp(#item, 2))
  tLocH = integer(tloc.getProp(#item, 3))
  the itemDelimiter = tDelim
  if me.pGeometry = 0 then
    return(0)
  end if
  me.pStartLScreen = me.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  me.pDestLScreen = me.getScreenCoordinate(tLocX, tLocY, tLocH)
  me.pMoveStart = the milliSeconds
  call(#defineActMultiple, me.pPartList, "wlk", ["bd", "sh"])
  call(#defineActMultiple, me.pPartList, "std", ["lh", "rh", "ls", "rs"])
end
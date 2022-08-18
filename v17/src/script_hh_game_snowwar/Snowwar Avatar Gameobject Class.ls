property SUBTURN_MOVEMENT, PLAYER_HEIGHT, pIsOwnPlayer, pRoomObject, pActiveEffects, pDump, pWalkLoop

on construct me
  SUBTURN_MOVEMENT = getIntVariable("snowwar.object_avatar.subturn_movement")
  pActiveEffects = []
  return 1
end

on deconstruct me
  repeat with tEffect in pActiveEffects
    tEffect.deconstruct()
  end repeat
  pActiveEffects = []
  tWorld = me.getGameSystem().getWorld()
  if (tWorld <> 0) then
    tWorld.clearObjectFromTileSpace(me.getObjectId())
  end if
  me.stopWalkLoop()
  me.removeRoomObject()
  return 1
end

on define me, tGameObject
  tGameObject = tGameObject.duplicate()
  me.setGameObjectProperty(tGameObject)
  me.setGameObjectProperty(#objectDataStruct, VOID)
  tGameSystem = me.getGameSystem()
  if (tGameSystem = 0) then
    return 0
  end if
  me.createRoomObject(tGameObject)
  if ((tGameObject[#objectDataStruct].findPos(#next_tile_x) > 0) and (tGameObject[#objectDataStruct].findPos(#next_tile_y) > 0)) then
    me.pGameObjectNextTarget.setTileLoc(tGameObject[#objectDataStruct][#next_tile_x], tGameObject[#objectDataStruct][#next_tile_y])
  end if
  if ((tGameObject[#objectDataStruct].findPos(#move_target_x) > 0) and (tGameObject[#objectDataStruct].findPos(#move_target_y) > 0)) then
    me.pGameObjectFinalTarget.setLoc(tGameObject[#objectDataStruct][#move_target_x], tGameObject[#objectDataStruct][#move_target_y])
  end if
  me.reserveSpaceForObject()
  PLAYER_HEIGHT = me.getGameObjectProperty(#gameobject_height)
  if (tGameObject[#name] = getObject(#session).GET(#userName)) then
    pIsOwnPlayer = 1
    me.getGameSystem().sendGameSystemEvent(#statusbar_health_update, me.pGameObjectSyncValues[#hit_points])
    me.getGameSystem().sendGameSystemEvent(#statusbar_ballcount_update, me.pGameObjectSyncValues[#snowball_count])
  end if
  return 1
end

on update me
  if (pActiveEffects.count = 0) then
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
  return 1
end

on executeGameObjectEvent me, tEvent, tdata
  if pDump then
    put (((("* executeGameObjectEvent on" && me.getObjectId()) & ":") && tEvent) && tdata)
  end if
  tstate = me.pGameObjectSyncValues[#activity_state]
  tPossibleStates = [getIntVariable("ACTIVITY_STATE_NORMAL"), getIntVariable("ACTIVITY_STATE_INVINCIBLE_AFTER_STUN")]
  case tEvent of
    #send_set_target_tile:
      if not me.getStateAllowsMoving() then
        return 1
      end if
      tWorldLoc = me.getGameSystem().convertTileToWorldCoordinate(tdata[#tile_x], tdata[#tile_y])
      me.getGameSystem().sendGameEventMessage([#integer: 0, #integer: tWorldLoc[1], #integer: tWorldLoc[2]])
    #send_throw_at_player:
      if pIsOwnPlayer then
        if (me.pGameObjectSyncValues[#snowball_count] <= 0) then
          me.getGameSystem().sendGameSystemEvent(#statusbar_ballcount_update, me.pGameObjectSyncValues[#snowball_count])
        end if
      end if
      me.getGameSystem().sendGameEventMessage([#integer: 1, #integer: integer(tdata[#target_id]), #integer: tdata[#trajectory]])
    #send_throw_at_loc:
      if pIsOwnPlayer then
        if (me.pGameObjectSyncValues[#snowball_count] <= 0) then
          me.getGameSystem().sendGameSystemEvent(#statusbar_ballcount_update, me.pGameObjectSyncValues[#snowball_count])
        end if
      end if
      me.getGameSystem().sendGameEventMessage([#integer: 2, #integer: tdata[#targetloc].x, #integer: tdata[#targetloc].y, #integer: tdata.trajectory])
    #send_create_snowball:
      if (me.pGameObjectSyncValues[#snowball_count] >= getIntVariable("snowwar.snowball.maximum")) then
        return 1
      end if
      if not me.getStateAllowsMoving() then
        return 1
      end if
      me.getGameSystem().sendGameEventMessage([#integer: 3])
    #substract_ball_count:
      if (me.pGameObjectSyncValues[#snowball_count] <= 0) then
        return 1
      end if
      me.pGameObjectSyncValues[#snowball_count] = (me.pGameObjectSyncValues[#snowball_count] - 1)
      if pIsOwnPlayer then
        me.getGameSystem().sendGameSystemEvent(#statusbar_ballcount_update, me.pGameObjectSyncValues[#snowball_count])
      end if
    #increase_ball_count:
      me.pGameObjectSyncValues[#snowball_count] = (me.pGameObjectSyncValues[#snowball_count] + 1)
      if pIsOwnPlayer then
        me.getGameSystem().sendGameSystemEvent(#statusbar_ballcount_update, me.pGameObjectSyncValues[#snowball_count])
        playSound("LS-getsnowball")
      end if
    #set_ball_count:
      me.pGameObjectSyncValues[#snowball_count] = tdata[#value]
      if pIsOwnPlayer then
        me.getGameSystem().sendGameSystemEvent(#statusbar_ballcount_update, me.pGameObjectSyncValues[#snowball_count])
      end if
    #substract_hit_points:
      if (me.pGameObjectSyncValues[#hit_points] <= 0) then
        return 1
      end if
      me.pGameObjectSyncValues[#hit_points] = (me.pGameObjectSyncValues[#hit_points] - 1)
      if pIsOwnPlayer then
        me.getGameSystem().sendGameSystemEvent(#statusbar_health_update, me.pGameObjectSyncValues[#hit_points])
      end if
    #player_resurrected:
      me.pGameObjectSyncValues[#hit_points] = getIntVariable("snowwar.health.maximum")
      if pIsOwnPlayer then
        me.getGameSystem().sendGameSystemEvent(#statusbar_health_update, me.pGameObjectSyncValues[#hit_points])
        me.getGameSystem().sendGameSystemEvent(#update_game_visuals)
      end if
      me.startInvincibleAnimation()
    #set_target:
      if not me.getStateAllowsMoving() then
        return 1
      end if
      if (me.pGameObjectSyncValues[#activity_state] = 1) then
        me.pGameObjectSyncValues[#activity_state] = 0
        me.pGameObjectSyncValues[#activity_timer] = 0
        me.resetFigureAnimation()
        if pIsOwnPlayer then
          me.getGameSystem().sendGameSystemEvent(#statusbar_createball_stopped, me.pGameObjectSyncValues[#snowball_count])
        end if
      end if
      me.pGameObjectFinalTarget.setLoc(tdata.x, tdata.y, 0)
      me.setGameObjectSyncProperty([#move_target_x: tdata.x, #move_target_y: tdata.y])
      if pIsOwnPlayer then
        me.stopWalkLoop()
        pWalkLoop = playSound("LS-walk-loop-1", VOID, [#infiniteloop: 1])
      end if
    #set_target_tile:
      nothing()
    #start_throw_snowball:
      if not me.getStateAllowsMoving() then
        return 1
      end if
      if (me.pGameObjectSyncValues[#snowball_count] <= 0) then
        return 1
      end if
      me.stopMovement()
      me.startThrowAnimation(tdata)
    #start_create_snowball:
      if not me.getStateAllowsMoving() then
        return 1
      end if
      if (me.pGameObjectSyncValues[#activity_state] = 1) then
        return 1
      end if
      if (me.pGameObjectSyncValues[#snowball_count] >= getIntVariable("snowwar.snowball.maximum")) then
        return 1
      end if
      me.pGameObjectSyncValues[#activity_state] = 1
      me.pGameObjectSyncValues[#activity_timer] = getIntVariable("ACTIVITY_TIMER_CREATING", 20)
      me.stopMovement()
      me.startCreateSnowballAnimation()
      if pIsOwnPlayer then
        me.getGameSystem().sendGameSystemEvent(#statusbar_createball_started)
      end if
    #start_snowball_hit:
      me.startHitAnimation(tdata)
    #start_stunned:
      if pIsOwnPlayer then
        me.getGameSystem().sendGameSystemEvent(#statusbar_health_update, 0)
        me.getGameSystem().sendGameSystemEvent(#statusbar_disable_buttons)
      end if
      me.pGameObjectSyncValues[#activity_state] = 2
      me.pGameObjectSyncValues[#activity_timer] = getIntVariable("ACTIVITY_TIMER_STUNNED", 125)
      me.stopMovement()
      me.startStunnedAnimation(tdata)
    #zero_ball_count:
      me.pGameObjectSyncValues[#snowball_count] = 0
      if pIsOwnPlayer then
        me.getGameSystem().sendGameSystemEvent(#statusbar_ballcount_update, me.pGameObjectSyncValues[#snowball_count])
      end if
    #award_hit_score:
      me.incrementScoreBy(getIntVariable("snowwar.score.hitaward"))
    #award_kill_score:
      me.incrementScoreBy(getIntVariable("snowwar.score.killaward"))
    #reset_player:
      me.pGameObjectSyncValues[#player_id] = -1
      return 1
    #reset_figure, #gameend:
      me.stopWalkLoop()
      return me.resetFigureAnimation()
    otherwise:
      put (("* TileWorldMover: UNDEFINED EVENT:" && tEvent) && tdata)
  end case
end

on calculateFrameMovement me
  if not objectp(pRoomObject) then
    return error(me, "Room object wrapper missing", #calculateFrameMovement)
  end if
  tActivityTimer = me.pGameObjectSyncValues[#activity_timer]
  if (tActivityTimer > 0) then
    if (tActivityTimer = 1) then
      me.activityTimerTriggered()
    end if
    me.pGameObjectSyncValues[#activity_timer] = (me.pGameObjectSyncValues[#activity_timer] - 1)
  end if
  if me.existsFinalTarget() then
    tOrigTileLocation = me.pGameObjectLocation.getTileLoc()
    if (me.pGameObjectNextTarget.getLocation() <> me.pGameObjectLocation.getLocation()) then
      tOrigNextTargetLoc = me.pGameObjectNextTarget.getLocation()
    end if
    if me.getStateAllowsMoving() then
      tMoving = me.calculateMovement()
    end if
    tDirBody = me.pGameObjectSyncValues[#body_direction]
    if tMoving then
      if (tOrigNextTargetLoc <> me.pGameObjectNextTarget.getLocation()) then
        pRoomObject.gameObjectRefreshLocation(tOrigTileLocation.x, tOrigTileLocation.y, 0.0, tDirBody, tDirBody)
        pRoomObject.gameObjectNewMoveTarget(me.pGameObjectNextTarget.getTileX(), me.pGameObjectNextTarget.getTileY(), 0.0, tDirBody, tDirBody, "wlk")
      end if
    else
      me.stopWalkLoop()
      me.pGameObjectNextTarget.setLoc(me.pGameObjectLocation.x, me.pGameObjectLocation.y, me.pGameObjectLocation.z)
      me.setGameObjectSyncProperty([#x: me.pGameObjectLocation.x, #y: me.pGameObjectLocation.y, #next_tile_x: me.pGameObjectLocation.getTileX(), #next_tile_y: me.pGameObjectLocation.getTileY()])
      pRoomObject.gameObjectMoveDone(me.pGameObjectLocation.getTileX(), me.pGameObjectLocation.getTileY(), 0.0, tDirBody, tDirBody, "std")
    end if
  else
    me.stopWalkLoop()
  end if
  tActivityState = me.pGameObjectSyncValues[#activity_state]
  if ((tActivityState = getIntVariable("ACTIVITY_STATE_STUNNED")) or (tActivityState = getIntVariable("ACTIVITY_STATE_INVINCIBLE_AFTER_STUN"))) then
    return 1
  end if
  me.checkForSnowballCollisions()
end

on reserveSpaceForObject me, tLocX, tLocY
  tWorld = me.getGameSystem().getWorld()
  if (tWorld = 0) then
    return 0
  end if
  tWorld.clearObjectFromTileSpace(me.getObjectId())
  tWorld.reserveTileForObject(me.pGameObjectNextTarget.getTileX(), me.pGameObjectNextTarget.getTileY(), me.getObjectId(), 0)
  return 1
end

on activityTimerTriggered me
  tActivityState = me.pGameObjectSyncValues[#activity_state]
  if (tActivityState = getIntVariable("ACTIVITY_STATE_STUNNED")) then
    me.executeGameObjectEvent(#player_resurrected)
    me.pGameObjectSyncValues[#activity_timer] = getIntVariable("ACTIVITY_TIMER_INVINCIBLE_AFTER_STUN")
    me.pGameObjectSyncValues[#activity_state] = getIntVariable("ACTIVITY_STATE_INVINCIBLE_AFTER_STUN")
    return 1
  end if
  if (tActivityState = getIntVariable("ACTIVITY_STATE_INVINCIBLE_AFTER_STUN")) then
    me.resetFigureAnimation()
  end if
  if (tActivityState = getIntVariable("ACTIVITY_STATE_CREATING")) then
    me.executeGameObjectEvent(#increase_ball_count)
    me.resetFigureAnimation()
  end if
  me.pGameObjectSyncValues[#activity_state] = getIntVariable("ACTIVITY_STATE_NORMAL")
end

on calculateMovement me
  tMoveTarget = me.pGameObjectFinalTarget
  tNextTarget = me.pGameObjectNextTarget
  if not objectp(tMoveTarget) then
    return 0
  end if
  tMoveTargetX = tMoveTarget.x
  tMoveTargetY = tMoveTarget.y
  if not objectp(me.pGameObjectLocation) then
    return 0
  end if
  tCurrentX = me.pGameObjectLocation.x
  tCurrentY = me.pGameObjectLocation.y
  if not objectp(tNextTarget) then
    return 0
  end if
  tNextTargetX = tNextTarget.x
  tNextTargetY = tNextTarget.y
  if ((tCurrentX = tMoveTargetX) and (tCurrentY = tMoveTargetY)) then
    return 0
  end if
  if ((tNextTargetX <> tCurrentX) or (tNextTargetY <> tCurrentY)) then
    tOldX = tCurrentX
    tOldY = tCurrentY
    tTargetX = tNextTarget.x
    tDeltaX = (tTargetX - tCurrentX)
    if (tDeltaX < 0) then
      if (tDeltaX > -SUBTURN_MOVEMENT) then
        tCurrentX = tTargetX
      else
        tCurrentX = (tCurrentX - SUBTURN_MOVEMENT)
      end if
    else
      if (tDeltaX > 0) then
        if (tDeltaX < SUBTURN_MOVEMENT) then
          tCurrentX = tTargetX
        else
          tCurrentX = (tCurrentX + SUBTURN_MOVEMENT)
        end if
      end if
    end if
    tTargetY = tNextTarget.y
    tDeltaY = (tTargetY - tCurrentY)
    if (tDeltaY < 0) then
      if (tDeltaY > -SUBTURN_MOVEMENT) then
        tCurrentY = tTargetY
      else
        tCurrentY = (tCurrentY - SUBTURN_MOVEMENT)
      end if
    else
      if (tDeltaY > 0) then
        if (tDeltaY < SUBTURN_MOVEMENT) then
          tCurrentY = tTargetY
        else
          tCurrentY = (tCurrentY + SUBTURN_MOVEMENT)
        end if
      end if
    end if
    me.pGameObjectLocation.setLoc(tCurrentX, tCurrentY, 0)
    me.setGameObjectSyncProperty([#x: tCurrentX, #y: tCurrentY])
    if ((tCurrentX = tMoveTargetX) and (tCurrentY = tMoveTargetY)) then
      return 0
    end if
    return 1
  else
    tGameSystem = me.getGameSystem()
    tGeometry = tGameSystem.getGeometry()
    tWorld = tGameSystem.getWorld()
    tTileX = me.pGameObjectLocation.getTileX()
    tTileY = me.pGameObjectLocation.getTileY()
    tMoveDirection360 = tGeometry.getAngleFromComponents((tMoveTargetX - tCurrentX), (tMoveTargetY - tCurrentY))
    tNextDir = tGeometry.direction360to8(tMoveDirection360)
    tNextTile = tWorld.getTileNeighborInDirection(tTileX, tTileY, tNextDir)
    tNextAvailable = (tNextTile <> 0)
    if tNextAvailable then
      tNextAvailable = tNextTile.isAvailable()
    end if
    if not tNextAvailable then
      tNextDir = tGeometry.direction360to8(tGeometry.rotateDirection45DegreesCCW(tMoveDirection360))
      tNextTile = tWorld.getTileNeighborInDirection(tTileX, tTileY, tNextDir)
      tNextAvailable = (tNextTile <> 0)
      if tNextAvailable then
        tNextAvailable = tNextTile.isAvailable()
      end if
      if not tNextAvailable then
        tNextDir = tGeometry.direction360to8(tGeometry.rotateDirection45DegreesCW(tMoveDirection360))
        tNextTile = tWorld.getTileNeighborInDirection(tTileX, tTileY, tNextDir)
        tNextAvailable = (tNextTile <> 0)
        if tNextAvailable then
          tNextAvailable = tNextTile.isAvailable()
        end if
        if not tNextAvailable then
          tNextTile = 0
        end if
      end if
    end if
    if (tNextTile <> 0) then
      me.setGameObjectSyncProperty([#body_direction: tNextDir, #next_tile_x: tNextTile.getX(), #next_tile_y: tNextTile.getY()])
      me.pGameObjectNextTarget.setTileLoc(tNextTile.getX(), tNextTile.getY(), 0)
      me.reserveSpaceForObject()
      return me.calculateMovement()
    end if
  end if
  return 0
end

on checkForSnowballCollisions me
  tGameSystem = me.getGameSystem()
  if (tGameSystem = 0) then
    return 0
  end if
  tCollision = tGameSystem.pThread.getComponent().getCollision()
  tBallObjectIdList = tGameSystem.getGameObjectIdsOfType("snowball")
  if (tBallObjectIdList.count < 1) then
    return 0
  end if
  tOwnId = me.getObjectId()
  tlocation = me.getLocation()
  repeat with tBallObjectId in tBallObjectIdList
    tBallObject = tGameSystem.getGameObject(tBallObjectId)
    tThrowerId = string(tBallObject.getGameObjectProperty(#int_thrower_id))
    if ((tThrowerId <> tOwnId) and tBallObject.getActive()) then
      if (tBallObject.getLocation().z < PLAYER_HEIGHT) then
        if tCollision.testForObjectToObjectCollision(me, tBallObject) then
          tBallLocX = tBallObject.getLocation().x
          tBallLocY = tBallObject.getLocation().y
          tBallLocZ = tBallObject.getLocation().z
          tBallDirection = tGameSystem.get360AngleFromComponents((tBallLocX - tlocation.x), (tBallLocY - tlocation.y))
          tBallObject.Remove()
          me.executeGameObjectEvent(#start_snowball_hit, [#x: tBallLocX, #y: tBallLocY, #z: tBallLocZ, #direction: tBallDirection])
        end if
      end if
    end if
  end repeat
  return 1
end

on stopMovement me
  me.stopWalkLoop()
  me.setLocation(me.pGameObjectNextTarget.x, me.pGameObjectNextTarget.y, me.pGameObjectNextTarget.x)
  me.setGameObjectSyncProperty([#x: me.pGameObjectNextTarget.x, #y: me.pGameObjectNextTarget.y, #move_target_x: me.pGameObjectNextTarget.x, #move_target_y: me.pGameObjectNextTarget.y])
  me.resetTargets()
  if not objectp(pRoomObject) then
    return error(me, "Room object wrapper missing", #stopMovement)
  end if
  tDirBody = me.pGameObjectSyncValues[#body_direction]
  pRoomObject.gameObjectMoveDone(me.pGameObjectLocation.getTileX(), me.pGameObjectLocation.getTileY(), 0.0, tDirBody, tDirBody, "std")
  return 1
end

on startHitAnimation me, tdata
  tDirection = tdata[#direction]
  tX = tdata[#x]
  tY = tdata[#y]
  tZ = tdata[#z]
  if not objectp(pRoomObject) then
    return error(me, "Room object wrapper missing", #startHitAnimation)
  end if
  tHumanObject = pRoomObject.getRoomObject()
  if (tHumanObject = 0) then
    return error(me, "Room object missing", #startHitAnimation)
  end if
  if ((tDirection >= 225) or (tDirection <= 45)) then
    tlocz = (tHumanObject.pSprite.locZ + 1)
  else
    tlocz = (tHumanObject.pSprite.locZ + 1)
  end if
  tScreenLoc = me.getGameSystem().getWorld().convertWorldToScreenCoordinate(tX, tY, tZ)
  tEffect = createObject(#temp, "Snowwar Hit Animation Class")
  tEffect.define(tScreenLoc, tlocz)
  pActiveEffects.append(tEffect)
  return 1
end

on startThrowAnimation me, tdata
  tGameSystem = me.getGameSystem()
  if (tdata.findPos(#int_target_id) > 0) then
    tdata[#target_id] = string(tdata[#int_target_id])
  end if
  if (tdata.findPos(#target_id) > 0) then
    tTargetObject = tGameSystem.getGameObject(tdata[#target_id])
    if (tTargetObject = 0) then
      return error(me, "Target object not found!", #startThrowAnimation)
    end if
    tTargetX = tTargetObject.getLocation().x
    tTargetY = tTargetObject.getLocation().y
  else
    tTargetX = tdata[#targetX]
    tTargetY = tdata[#targetY]
  end if
  tlocation = me.getLocation()
  tDirection = tGameSystem.get8AngleFromComponents((tTargetX - tlocation.x), (tTargetY - tlocation.y))
  me.setGameObjectSyncProperty([#body_direction: tDirection])
  if not objectp(pRoomObject) then
    return error(me, "Room object wrapper missing", #startThrowAnimation)
  end if
  pRoomObject.gameObjectAction("start_throw", tDirection)
  return 1
end

on startCreateSnowballAnimation me
  if not objectp(pRoomObject) then
    return error(me, "Room object wrapper missing", #startCreateSnowballAnimation)
  end if
  pRoomObject.gameObjectAction("start_create")
  return 1
end

on startStunnedAnimation me, tdata
  if not objectp(pRoomObject) then
    return error(me, "Room object wrapper missing", #startStunnedAnimation)
  end if
  pRoomObject.gameObjectAction("start_stunned", tdata)
  return 1
end

on startInvincibleAnimation me
  if not objectp(pRoomObject) then
    return error(me, "Room object wrapper missing", #startStunnedAnimation)
  end if
  pRoomObject.gameObjectAction("start_invincible")
  return 1
end

on resetFigureAnimation me
  if not objectp(pRoomObject) then
    return error(me, "Room object wrapper missing", #resetFigureAnimation)
  end if
  if pDump then
    put "* resetFigureAnimation calling reset_figure"
  end if
  pRoomObject.gameObjectAction("reset_figure")
  return 1
end

on createRoomObject me, tDataStruct
  pRoomObject = createObject(#temp, getClassVariable("snowwar.object_avatar.roomobject.wrapper.class"))
  if (pRoomObject = 0) then
    return error(me, "Cannot create roomobject wrapper!", #createRoomObject)
  end if
  return pRoomObject.define(tDataStruct)
end

on removeRoomObject me
  if not objectp(pRoomObject) then
    return 1
  end if
  pRoomObject.deconstruct()
  pRoomObject = VOID
  return 1
end

on getRoomObjectImage me
  if not objectp(pRoomObject) then
    return 0
  end if
  return pRoomObject.getPicture()
end

on getStateAllowsMoving me
  tstate = me.pGameObjectSyncValues[#activity_state]
  tPossibleStates = [getIntVariable("ACTIVITY_STATE_NORMAL"), getIntVariable("ACTIVITY_STATE_CREATING"), getIntVariable("ACTIVITY_STATE_INVINCIBLE_AFTER_STUN")]
  return (tPossibleStates.findPos(tstate) > 0)
end

on stopWalkLoop me
  if (pWalkLoop <> VOID) then
    stopSoundChannel(pWalkLoop)
  end if
  pWalkLoop = VOID
  return 1
end

on incrementScoreBy me, tPoints
  if (tPoints = 0) then
    return 1
  end if
  me.pGameObjectSyncValues[#score] = (me.pGameObjectSyncValues[#score] + tPoints)
  me.getGameSystem().sendGameSystemEvent(#team_score_updated, [[#team_id: me.pGameObjectSyncValues[#team_id], #score_add: tPoints]])
  if pIsOwnPlayer then
    me.getGameSystem().sendGameSystemEvent(#personal_score_updated, me.pGameObjectSyncValues[#score])
  end if
  return 1
end

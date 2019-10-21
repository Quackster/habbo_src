on construct(me)
  SUBTURN_MOVEMENT = getIntVariable("snowwar.object_avatar.subturn_movement")
  pActiveEffects = []
  return(1)
  exit
end

on deconstruct(me)
  repeat while me <= undefined
    tEffect = getAt(undefined, undefined)
    tEffect.deconstruct()
  end repeat
  pActiveEffects = []
  tWorld = me.getGameSystem().getWorld()
  if tWorld <> 0 then
    tWorld.clearObjectFromTileSpace(me.getObjectId())
  end if
  me.stopWalkLoop()
  me.removeRoomObject()
  return(1)
  exit
end

on define(me, tGameObject)
  tGameObject = tGameObject.duplicate()
  me.setGameObjectProperty(tGameObject)
  me.setGameObjectProperty(#objectDataStruct, void())
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return(0)
  end if
  me.createRoomObject(tGameObject)
  if tGameObject.getAt(#objectDataStruct).findPos(#next_tile_x) > 0 and tGameObject.getAt(#objectDataStruct).findPos(#next_tile_y) > 0 then
    me.setTileLoc(tGameObject.getAt(#objectDataStruct).getAt(#next_tile_x), tGameObject.getAt(#objectDataStruct).getAt(#next_tile_y))
  end if
  if tGameObject.getAt(#objectDataStruct).findPos(#move_target_x) > 0 and tGameObject.getAt(#objectDataStruct).findPos(#move_target_y) > 0 then
    me.setLoc(tGameObject.getAt(#objectDataStruct).getAt(#move_target_x), tGameObject.getAt(#objectDataStruct).getAt(#move_target_y))
  end if
  me.reserveSpaceForObject()
  PLAYER_HEIGHT = me.getGameObjectProperty(#gameobject_height)
  if tGameObject.getAt(#name) = getObject(#session).get(#userName) then
    pIsOwnPlayer = 1
    me.getGameSystem().sendGameSystemEvent(#statusbar_health_update, me.getProp(#pGameObjectSyncValues, #hit_points))
    me.getGameSystem().sendGameSystemEvent(#statusbar_ballcount_update, me.getProp(#pGameObjectSyncValues, #snowball_count))
  end if
  return(1)
  exit
end

on update(me)
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
  return(1)
  exit
end

on executeGameObjectEvent(me, tEvent, tdata)
  if pDump then
    put("* executeGameObjectEvent on" && me.getObjectId() & ":" && tEvent && tdata)
  end if
  tstate = me.getProp(#pGameObjectSyncValues, #activity_state)
  tPossibleStates = [getIntVariable("ACTIVITY_STATE_NORMAL"), getIntVariable("ACTIVITY_STATE_INVINCIBLE_AFTER_STUN")]
  if me = #send_set_target_tile then
    if not me.getStateAllowsMoving() then
      return(1)
    end if
    tWorldLoc = me.getGameSystem().convertTileToWorldCoordinate(tdata.getAt(#tile_x), tdata.getAt(#tile_y))
    me.getGameSystem().sendGameEventMessage([#integer:0, #integer:tWorldLoc.getAt(1), #integer:tWorldLoc.getAt(2)])
  else
    if me = #send_throw_at_player then
      if pIsOwnPlayer then
        if me.getProp(#pGameObjectSyncValues, #snowball_count) <= 0 then
          me.getGameSystem().sendGameSystemEvent(#statusbar_ballcount_update, me.getProp(#pGameObjectSyncValues, #snowball_count))
        end if
      end if
      me.getGameSystem().sendGameEventMessage([#integer:1, #integer:integer(tdata.getAt(#target_id)), #integer:tdata.getAt(#trajectory)])
    else
      if me = #send_throw_at_loc then
        if pIsOwnPlayer then
          if me.getProp(#pGameObjectSyncValues, #snowball_count) <= 0 then
            me.getGameSystem().sendGameSystemEvent(#statusbar_ballcount_update, me.getProp(#pGameObjectSyncValues, #snowball_count))
          end if
        end if
        me.getGameSystem().sendGameEventMessage([#integer:2, #integer:tdata.getAt(#targetloc).x, #integer:tdata.getAt(#targetloc).y, #integer:tdata.trajectory])
      else
        if me = #send_create_snowball then
          if me.getProp(#pGameObjectSyncValues, #snowball_count) >= getIntVariable("snowwar.snowball.maximum") then
            return(1)
          end if
          if not me.getStateAllowsMoving() then
            return(1)
          end if
          me.getGameSystem().sendGameEventMessage([#integer:3])
        else
          if me = #substract_ball_count then
            if me.getProp(#pGameObjectSyncValues, #snowball_count) <= 0 then
              return(1)
            end if
            me.setProp(#pGameObjectSyncValues, #snowball_count, me.getProp(#pGameObjectSyncValues, #snowball_count) - 1)
            if pIsOwnPlayer then
              me.getGameSystem().sendGameSystemEvent(#statusbar_ballcount_update, me.getProp(#pGameObjectSyncValues, #snowball_count))
            end if
          else
            if me = #increase_ball_count then
              me.setProp(#pGameObjectSyncValues, #snowball_count, me.getProp(#pGameObjectSyncValues, #snowball_count) + 1)
              if pIsOwnPlayer then
                me.getGameSystem().sendGameSystemEvent(#statusbar_ballcount_update, me.getProp(#pGameObjectSyncValues, #snowball_count))
                playSound("LS-getsnowball")
              end if
            else
              if me = #set_ball_count then
                me.setProp(#pGameObjectSyncValues, #snowball_count, tdata.getAt(#value))
                if pIsOwnPlayer then
                  me.getGameSystem().sendGameSystemEvent(#statusbar_ballcount_update, me.getProp(#pGameObjectSyncValues, #snowball_count))
                end if
              else
                if me = #substract_hit_points then
                  if me.getProp(#pGameObjectSyncValues, #hit_points) <= 0 then
                    return(1)
                  end if
                  me.setProp(#pGameObjectSyncValues, #hit_points, me.getProp(#pGameObjectSyncValues, #hit_points) - 1)
                  if pIsOwnPlayer then
                    me.getGameSystem().sendGameSystemEvent(#statusbar_health_update, me.getProp(#pGameObjectSyncValues, #hit_points))
                  end if
                else
                  if me = #player_resurrected then
                    me.setProp(#pGameObjectSyncValues, #hit_points, getIntVariable("snowwar.health.maximum"))
                    if pIsOwnPlayer then
                      me.getGameSystem().sendGameSystemEvent(#statusbar_health_update, me.getProp(#pGameObjectSyncValues, #hit_points))
                      me.getGameSystem().sendGameSystemEvent(#update_game_visuals)
                    end if
                    me.startInvincibleAnimation()
                  else
                    if me = #set_target then
                      if not me.getStateAllowsMoving() then
                        return(1)
                      end if
                      if me.getProp(#pGameObjectSyncValues, #activity_state) = 1 then
                        me.setProp(#pGameObjectSyncValues, #activity_state, 0)
                        me.setProp(#pGameObjectSyncValues, #activity_timer, 0)
                        me.resetFigureAnimation()
                        if pIsOwnPlayer then
                          me.getGameSystem().sendGameSystemEvent(#statusbar_createball_stopped, me.getProp(#pGameObjectSyncValues, #snowball_count))
                        end if
                      end if
                      me.setLoc(tdata.x, tdata.y, 0)
                      me.setGameObjectSyncProperty([#move_target_x:tdata.x, #move_target_y:tdata.y])
                      if pIsOwnPlayer then
                        me.stopWalkLoop()
                        pWalkLoop = playSound("LS-walk-loop-1", void(), [#infiniteloop:1])
                      end if
                    else
                      if me = #set_target_tile then
                        nothing()
                      else
                        if me = #start_throw_snowball then
                          if not me.getStateAllowsMoving() then
                            return(1)
                          end if
                          if me.getProp(#pGameObjectSyncValues, #snowball_count) <= 0 then
                            return(1)
                          end if
                          me.stopMovement()
                          me.startThrowAnimation(tdata)
                        else
                          if me = #start_create_snowball then
                            if not me.getStateAllowsMoving() then
                              return(1)
                            end if
                            if me.getProp(#pGameObjectSyncValues, #activity_state) = 1 then
                              return(1)
                            end if
                            if me.getProp(#pGameObjectSyncValues, #snowball_count) >= getIntVariable("snowwar.snowball.maximum") then
                              return(1)
                            end if
                            me.setProp(#pGameObjectSyncValues, #activity_state, 1)
                            me.setProp(#pGameObjectSyncValues, #activity_timer, getIntVariable("ACTIVITY_TIMER_CREATING", 20))
                            me.stopMovement()
                            me.startCreateSnowballAnimation()
                            if pIsOwnPlayer then
                              me.getGameSystem().sendGameSystemEvent(#statusbar_createball_started)
                            end if
                          else
                            if me = #start_snowball_hit then
                              me.startHitAnimation(tdata)
                            else
                              if me = #start_stunned then
                                if pIsOwnPlayer then
                                  me.getGameSystem().sendGameSystemEvent(#statusbar_health_update, 0)
                                  me.getGameSystem().sendGameSystemEvent(#statusbar_disable_buttons)
                                end if
                                me.setProp(#pGameObjectSyncValues, #activity_state, 2)
                                me.setProp(#pGameObjectSyncValues, #activity_timer, getIntVariable("ACTIVITY_TIMER_STUNNED", 125))
                                me.stopMovement()
                                me.startStunnedAnimation(tdata)
                              else
                                if me = #zero_ball_count then
                                  me.setProp(#pGameObjectSyncValues, #snowball_count, 0)
                                  if pIsOwnPlayer then
                                    me.getGameSystem().sendGameSystemEvent(#statusbar_ballcount_update, me.getProp(#pGameObjectSyncValues, #snowball_count))
                                  end if
                                else
                                  if me = #award_hit_score then
                                    me.incrementScoreBy(getIntVariable("snowwar.score.hitaward"))
                                  else
                                    if me = #award_kill_score then
                                      me.incrementScoreBy(getIntVariable("snowwar.score.killaward"))
                                    else
                                      if me = #reset_player then
                                        me.setProp(#pGameObjectSyncValues, #player_id, -1)
                                        return(1)
                                      else
                                        if me <> #reset_figure then
                                          if me = #gameend then
                                            me.stopWalkLoop()
                                            return(me.resetFigureAnimation())
                                          else
                                            put("* TileWorldMover: UNDEFINED EVENT:" && tEvent && tdata)
                                          end if
                                          exit
                                        end if
                                      end if
                                    end if
                                  end if
                                end if
                              end if
                            end if
                          end if
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on calculateFrameMovement(me)
  if not objectp(pRoomObject) then
    return(error(me, "Room object wrapper missing", #calculateFrameMovement))
  end if
  tActivityTimer = me.getProp(#pGameObjectSyncValues, #activity_timer)
  if tActivityTimer > 0 then
    if tActivityTimer = 1 then
      me.activityTimerTriggered()
    end if
    me.setProp(#pGameObjectSyncValues, #activity_timer, me.getProp(#pGameObjectSyncValues, #activity_timer) - 1)
  end if
  if me.existsFinalTarget() then
    tOrigTileLocation = me.getTileLoc()
    if me.getLocation() <> me.getLocation() then
      tOrigNextTargetLoc = me.getLocation()
    end if
    if me.getStateAllowsMoving() then
      tMoving = me.calculateMovement()
    end if
    tDirBody = me.getProp(#pGameObjectSyncValues, #body_direction)
    if tMoving then
      if tOrigNextTargetLoc <> me.getLocation() then
        pRoomObject.gameObjectRefreshLocation(tOrigTileLocation.x, tOrigTileLocation.y, 0, tDirBody, tDirBody)
        pRoomObject.gameObjectNewMoveTarget(me.getTileX(), me.getTileY(), 0, tDirBody, tDirBody, "wlk")
      end if
    else
      me.stopWalkLoop()
      me.setLoc(me.x, me.y, me.z)
      me.setGameObjectSyncProperty([#x:me.x, #y:me.y, #next_tile_x:me.getTileX(), #next_tile_y:me.getTileY()])
      pRoomObject.gameObjectMoveDone(me.getTileX(), me.getTileY(), 0, tDirBody, tDirBody, "std")
    end if
  else
    me.stopWalkLoop()
  end if
  tActivityState = me.getProp(#pGameObjectSyncValues, #activity_state)
  if tActivityState = getIntVariable("ACTIVITY_STATE_STUNNED") or tActivityState = getIntVariable("ACTIVITY_STATE_INVINCIBLE_AFTER_STUN") then
    return(1)
  end if
  me.checkForSnowballCollisions()
  exit
end

on reserveSpaceForObject(me, tLocX, tLocY)
  tWorld = me.getGameSystem().getWorld()
  if tWorld = 0 then
    return(0)
  end if
  tWorld.clearObjectFromTileSpace(me.getObjectId())
  tWorld.reserveTileForObject(me.getTileX(), me.getTileY(), me.getObjectId(), 0)
  return(1)
  exit
end

on activityTimerTriggered(me)
  tActivityState = me.getProp(#pGameObjectSyncValues, #activity_state)
  if tActivityState = getIntVariable("ACTIVITY_STATE_STUNNED") then
    me.executeGameObjectEvent(#player_resurrected)
    me.setProp(#pGameObjectSyncValues, #activity_timer, getIntVariable("ACTIVITY_TIMER_INVINCIBLE_AFTER_STUN"))
    me.setProp(#pGameObjectSyncValues, #activity_state, getIntVariable("ACTIVITY_STATE_INVINCIBLE_AFTER_STUN"))
    return(1)
  end if
  if tActivityState = getIntVariable("ACTIVITY_STATE_INVINCIBLE_AFTER_STUN") then
    me.resetFigureAnimation()
  end if
  if tActivityState = getIntVariable("ACTIVITY_STATE_CREATING") then
    me.executeGameObjectEvent(#increase_ball_count)
    me.resetFigureAnimation()
  end if
  me.setProp(#pGameObjectSyncValues, #activity_state, getIntVariable("ACTIVITY_STATE_NORMAL"))
  exit
end

on calculateMovement(me)
  tMoveTarget = me.pGameObjectFinalTarget
  tNextTarget = me.pGameObjectNextTarget
  if not objectp(tMoveTarget) then
    return(0)
  end if
  tMoveTargetX = tMoveTarget.x
  tMoveTargetY = tMoveTarget.y
  if not objectp(me.pGameObjectLocation) then
    return(0)
  end if
  tCurrentX = me.x
  tCurrentY = me.y
  if not objectp(tNextTarget) then
    return(0)
  end if
  tNextTargetX = tNextTarget.x
  tNextTargetY = tNextTarget.y
  if tCurrentX = tMoveTargetX and tCurrentY = tMoveTargetY then
    return(0)
  end if
  if tNextTargetX <> tCurrentX or tNextTargetY <> tCurrentY then
    tOldX = tCurrentX
    tOldY = tCurrentY
    tTargetX = tNextTarget.x
    tDeltaX = tTargetX - tCurrentX
    if tDeltaX < 0 then
      if tDeltaX > -SUBTURN_MOVEMENT then
        tCurrentX = tTargetX
      else
        tCurrentX = tCurrentX - SUBTURN_MOVEMENT
      end if
    else
      if tDeltaX > 0 then
        if tDeltaX < SUBTURN_MOVEMENT then
          tCurrentX = tTargetX
        else
          tCurrentX = tCurrentX + SUBTURN_MOVEMENT
        end if
      end if
    end if
    tTargetY = tNextTarget.y
    tDeltaY = tTargetY - tCurrentY
    if tDeltaY < 0 then
      if tDeltaY > -SUBTURN_MOVEMENT then
        tCurrentY = tTargetY
      else
        tCurrentY = tCurrentY - SUBTURN_MOVEMENT
      end if
    else
      if tDeltaY > 0 then
        if tDeltaY < SUBTURN_MOVEMENT then
          tCurrentY = tTargetY
        else
          tCurrentY = tCurrentY + SUBTURN_MOVEMENT
        end if
      end if
    end if
    me.setLoc(tCurrentX, tCurrentY, 0)
    me.setGameObjectSyncProperty([#x:tCurrentX, #y:tCurrentY])
    if tCurrentX = tMoveTargetX and tCurrentY = tMoveTargetY then
      return(0)
    end if
    return(1)
  else
    tGameSystem = me.getGameSystem()
    tGeometry = tGameSystem.getGeometry()
    tWorld = tGameSystem.getWorld()
    tTileX = me.getTileX()
    tTileY = me.getTileY()
    tMoveDirection360 = tGeometry.getAngleFromComponents(tMoveTargetX - tCurrentX, tMoveTargetY - tCurrentY)
    tNextDir = tGeometry.direction360to8(tMoveDirection360)
    tNextTile = tWorld.getTileNeighborInDirection(tTileX, tTileY, tNextDir)
    tNextAvailable = tNextTile <> 0
    if tNextAvailable then
      tNextAvailable = tNextTile.isAvailable()
    end if
    if not tNextAvailable then
      tNextDir = tGeometry.direction360to8(tGeometry.rotateDirection45DegreesCCW(tMoveDirection360))
      tNextTile = tWorld.getTileNeighborInDirection(tTileX, tTileY, tNextDir)
      tNextAvailable = tNextTile <> 0
      if tNextAvailable then
        tNextAvailable = tNextTile.isAvailable()
      end if
      if not tNextAvailable then
        tNextDir = tGeometry.direction360to8(tGeometry.rotateDirection45DegreesCW(tMoveDirection360))
        tNextTile = tWorld.getTileNeighborInDirection(tTileX, tTileY, tNextDir)
        tNextAvailable = tNextTile <> 0
        if tNextAvailable then
          tNextAvailable = tNextTile.isAvailable()
        end if
        if not tNextAvailable then
          tNextTile = 0
        end if
      end if
    end if
    if tNextTile <> 0 then
      me.setGameObjectSyncProperty([#body_direction:tNextDir, #next_tile_x:tNextTile.getX(), #next_tile_y:tNextTile.getY()])
      me.setTileLoc(tNextTile.getX(), tNextTile.getY(), 0)
      me.reserveSpaceForObject()
      return(me.calculateMovement())
    end if
  end if
  return(0)
  exit
end

on checkForSnowballCollisions(me)
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return(0)
  end if
  tCollision = tGameSystem.getComponent().getCollision()
  tBallObjectIdList = tGameSystem.getGameObjectIdsOfType("snowball")
  if tBallObjectIdList.count < 1 then
    return(0)
  end if
  tOwnId = me.getObjectId()
  tlocation = me.getLocation()
  repeat while me <= undefined
    tBallObjectId = getAt(undefined, undefined)
    tBallObject = tGameSystem.getGameObject(tBallObjectId)
    tThrowerId = string(tBallObject.getGameObjectProperty(#int_thrower_id))
    if tThrowerId <> tOwnId and tBallObject.getActive() then
      if tBallObject.getLocation().z < PLAYER_HEIGHT then
        if tCollision.testForObjectToObjectCollision(me, tBallObject) then
          tBallLocX = tBallObject.getLocation().x
          tBallLocY = tBallObject.getLocation().y
          tBallLocZ = tBallObject.getLocation().z
          tBallDirection = tGameSystem.get360AngleFromComponents(tBallLocX - tlocation.x, tBallLocY - tlocation.y)
          tBallObject.Remove()
          me.executeGameObjectEvent(#start_snowball_hit, [#x:tBallLocX, #y:tBallLocY, #z:tBallLocZ, #direction:tBallDirection])
        end if
      end if
    end if
  end repeat
  return(1)
  exit
end

on stopMovement(me)
  me.stopWalkLoop()
  me.setLocation(me.x, me.y, me.x)
  me.setGameObjectSyncProperty([#x:me.x, #y:me.y, #move_target_x:me.x, #move_target_y:me.y])
  me.resetTargets()
  if not objectp(pRoomObject) then
    return(error(me, "Room object wrapper missing", #stopMovement))
  end if
  tDirBody = me.getProp(#pGameObjectSyncValues, #body_direction)
  pRoomObject.gameObjectMoveDone(me.getTileX(), me.getTileY(), 0, tDirBody, tDirBody, "std")
  return(1)
  exit
end

on startHitAnimation(me, tdata)
  tDirection = tdata.getAt(#direction)
  tX = tdata.getAt(#x)
  tY = tdata.getAt(#y)
  tZ = tdata.getAt(#z)
  if not objectp(pRoomObject) then
    return(error(me, "Room object wrapper missing", #startHitAnimation))
  end if
  tHumanObject = pRoomObject.getRoomObject()
  if tHumanObject = 0 then
    return(error(me, "Room object missing", #startHitAnimation))
  end if
  if tDirection >= 225 or tDirection <= 45 then
    tlocz = tHumanObject.locZ + 1
  else
    tlocz = tHumanObject.locZ + 1
  end if
  tScreenLoc = me.getGameSystem().getWorld().convertWorldToScreenCoordinate(tX, tY, tZ)
  tEffect = createObject(#temp, "Snowwar Hit Animation Class")
  tEffect.define(tScreenLoc, tlocz)
  pActiveEffects.append(tEffect)
  return(1)
  exit
end

on startThrowAnimation(me, tdata)
  tGameSystem = me.getGameSystem()
  if tdata.findPos(#int_target_id) > 0 then
    tdata.setAt(#target_id, string(tdata.getAt(#int_target_id)))
  end if
  if tdata.findPos(#target_id) > 0 then
    tTargetObject = tGameSystem.getGameObject(tdata.getAt(#target_id))
    if tTargetObject = 0 then
      return(error(me, "Target object not found!", #startThrowAnimation))
    end if
    tTargetX = tTargetObject.getLocation().x
    tTargetY = tTargetObject.getLocation().y
  else
    tTargetX = tdata.getAt(#targetX)
    tTargetY = tdata.getAt(#targetY)
  end if
  tlocation = me.getLocation()
  tDirection = tGameSystem.get8AngleFromComponents(tTargetX - tlocation.x, tTargetY - tlocation.y)
  me.setGameObjectSyncProperty([#body_direction:tDirection])
  if not objectp(pRoomObject) then
    return(error(me, "Room object wrapper missing", #startThrowAnimation))
  end if
  pRoomObject.gameObjectAction("start_throw", tDirection)
  return(1)
  exit
end

on startCreateSnowballAnimation(me)
  if not objectp(pRoomObject) then
    return(error(me, "Room object wrapper missing", #startCreateSnowballAnimation))
  end if
  pRoomObject.gameObjectAction("start_create")
  return(1)
  exit
end

on startStunnedAnimation(me, tdata)
  if not objectp(pRoomObject) then
    return(error(me, "Room object wrapper missing", #startStunnedAnimation))
  end if
  pRoomObject.gameObjectAction("start_stunned", tdata)
  return(1)
  exit
end

on startInvincibleAnimation(me)
  if not objectp(pRoomObject) then
    return(error(me, "Room object wrapper missing", #startStunnedAnimation))
  end if
  pRoomObject.gameObjectAction("start_invincible")
  return(1)
  exit
end

on resetFigureAnimation(me)
  if not objectp(pRoomObject) then
    return(error(me, "Room object wrapper missing", #resetFigureAnimation))
  end if
  if pDump then
    put("* resetFigureAnimation calling reset_figure")
  end if
  pRoomObject.gameObjectAction("reset_figure")
  return(1)
  exit
end

on createRoomObject(me, tDataStruct)
  pRoomObject = createObject(#temp, getClassVariable("snowwar.object_avatar.roomobject.wrapper.class"))
  if pRoomObject = 0 then
    return(error(me, "Cannot create roomobject wrapper!", #createRoomObject))
  end if
  return(pRoomObject.define(tDataStruct))
  exit
end

on removeRoomObject(me)
  if not objectp(pRoomObject) then
    return(1)
  end if
  pRoomObject.deconstruct()
  pRoomObject = void()
  return(1)
  exit
end

on getRoomObjectImage(me)
  if not objectp(pRoomObject) then
    return(0)
  end if
  return(pRoomObject.getPicture())
  exit
end

on getStateAllowsMoving(me)
  tstate = me.getProp(#pGameObjectSyncValues, #activity_state)
  tPossibleStates = [getIntVariable("ACTIVITY_STATE_NORMAL"), getIntVariable("ACTIVITY_STATE_CREATING"), getIntVariable("ACTIVITY_STATE_INVINCIBLE_AFTER_STUN")]
  return(tPossibleStates.findPos(tstate) > 0)
  exit
end

on stopWalkLoop(me)
  if pWalkLoop <> void() then
    stopSoundChannel(pWalkLoop)
  end if
  pWalkLoop = void()
  return(1)
  exit
end

on incrementScoreBy(me, tPoints)
  if tPoints = 0 then
    return(1)
  end if
  me.setProp(#pGameObjectSyncValues, #score, me.getProp(#pGameObjectSyncValues, #score) + tPoints)
  me.getGameSystem().sendGameSystemEvent(#team_score_updated, [[#team_id:me.getProp(#pGameObjectSyncValues, #team_id), #score_add:tPoints]])
  if pIsOwnPlayer then
    me.getGameSystem().sendGameSystemEvent(#personal_score_updated, me.getProp(#pGameObjectSyncValues, #score))
  end if
  return(1)
  exit
end
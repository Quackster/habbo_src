property STATE_NORMAL, STATE_STUNNED, STATE_TURBO_BOOST, STATE_HIGH_JUMPS, STATE_CLEANING_TILES, STATE_COLORING_FOR_OPPONENT, STATE_CLIMBING_INTO_CANNON, STATE_FLYING_THROUGH_AIR, STATE_BALL_BROKEN, pRoomObject, pActiveEffects, pDirBody, pLocation, pTargetLocation, pExpectedLocation, pDirObject, pDump

on construct me
  pDirBody = 0
  pLocation = [#x: -1, #y: -1, #z: -1]
  pTargetLocation = [#x: -1, #y: -1]
  pExpectedLocation = [#x: -1, #y: -1]
  STATE_NORMAL = 0
  STATE_STUNNED = 1
  STATE_TURBO_BOOST = 2
  STATE_HIGH_JUMPS = 3
  STATE_CLEANING_TILES = 4
  STATE_COLORING_FOR_OPPONENT = 5
  STATE_CLIMBING_INTO_CANNON = 6
  STATE_FLYING_THROUGH_AIR = 7
  STATE_BALL_BROKEN = 8
  pActiveEffects = []
  pDirObject = createObject(#temp, "BB Direction8 Class")
  return 1
end

on deconstruct me
  repeat with tEffect in pActiveEffects
    tEffect.deconstruct()
  end repeat
  pActiveEffects = []
  pDirObject = VOID
  me.removeRoomObject()
  return 1
end

on define me, tGameObject
  tGameObject = tGameObject.duplicate()
  me.setGameObjectProperty(tGameObject)
  me.createRoomObject(tGameObject)
  pLocation[#x] = tGameObject[#x]
  pLocation[#y] = tGameObject[#y]
  pLocation[#z] = tGameObject[#z]
  return 1
end

on update me
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
  return 1
end

on executeGameObjectEvent me, tEvent, tdata
  if pDump then
    put "* executeGameObjectEvent on" && me.getObjectId() & ":" && tEvent && tdata
  end if
  case tEvent of
    #gameobject_update:
      me.updateRoomObject(tdata)
    #set_target_custom:
      me.updateRoomObjectGoal(tdata)
    #activate_powerup:
      me.startPowerupActivateAnimation(tdata)
      if tdata[#powerupType] = 7 then
        me.updateRoomObject([#x: pLocation[#x], #y: pLocation[#y], #z: pLocation[#z], #state: STATE_STUNNED, #dirBody: pDirBody])
      end if
    #gamereset, #gameend:
      pTargetLocation[#x] = -1
      pExpectedLocation[#x] = -1
      me.clearEffectAnimation()
    otherwise:
      put "* Gameobject: UNDEFINED EVENT:" && tEvent && tdata
  end case
end

on createRoomObject me, tDataStruct
  pRoomObject = createObject(#temp, getClassVariable("bb_gamesystem.roomobject.player.wrapper.class"))
  if pRoomObject = 0 then
    return error(me, "Cannot create roomobject wrapper!", #createRoomObject)
  end if
  return pRoomObject.define(tDataStruct)
end

on removeRoomObject me
  pRoomObject.deconstruct()
  pRoomObject = VOID
  return 1
end

on roomObjectAction me, tAction, tdata
  if not objectp(pRoomObject) then
    return error(me, "Roomobject wrapper missing!", #getRoomObject)
  end if
  call(#roomObjectAction, pRoomObject, tAction, tdata)
  return 1
end

on getRoomObjectImage me
  if not objectp(pRoomObject) then
    return 0
  end if
  return pRoomObject.getPicture()
end

on updateRoomObjectGoal me, tdata
  if not me.checkStateAllowsMoving() then
    return 1
  end if
  pTargetLocation[#x] = tdata[#goalx]
  pTargetLocation[#y] = tdata[#goaly]
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return 0
  end if
  tdata[#x] = pLocation[#x]
  tdata[#y] = pLocation[#y]
  tdata[#z] = pLocation[#z]
  tdata[#dirBody] = pDirBody
  pExpectedLocation[#x] = -1
  return me.updateRoomObjectLocation(tdata)
end

on checkStateAllowsMoving me, tstate
  if tstate = VOID then
    tstate = me.getGameObjectProperty(#state)
  end if
  case tstate of
    STATE_STUNNED, STATE_CLIMBING_INTO_CANNON, STATE_FLYING_THROUGH_AIR, STATE_BALL_BROKEN:
      return 0
    otherwise:
      return 1
  end case
end

on updateRoomObject me, tdata
  tOldState = me.getGameObjectProperty(#state)
  if tdata[#state] <> tOldState then
    me.setGameObjectSyncProperty([#state: tdata[#state]])
    if tOldState = STATE_BALL_BROKEN then
      me.roomObjectAction(#set_ball, 1)
    end if
    case tdata[#state] of
      STATE_NORMAL:
        me.clearEffectAnimation()
        me.roomObjectAction(#reset_ball_color)
        me.roomObjectAction(#set_bounce_state, tdata[#state])
      STATE_HIGH_JUMPS:
        me.roomObjectAction(#set_bounce_state, tdata[#state])
      STATE_CLEANING_TILES:
        me.roomObjectAction(#set_bounce_state, tdata[#state])
      STATE_STUNNED:
        pTargetLocation[#x] = -1
        pExpectedLocation[#x] = -1
        me.createEffect(#loop, "bb2_stunned_", [#ink: 8])
        me.roomObjectAction(#set_bounce_state, tdata[#state])
        if me.getGameObjectProperty(#id) = me.getOwnGameIndex() then
          me.getGameSystem().sendGameSystemEvent(#soundeffect, "SFX-10-stunned")
        end if
      STATE_CLIMBING_INTO_CANNON, STATE_FLYING_THROUGH_AIR:
        me.roomObjectAction(#set_bounce_state, tdata[#state])
        pTargetLocation[#x] = -1
        pExpectedLocation[#x] = -1
        me.roomObjectAction(#fly_into, tdata)
        return 1
      STATE_COLORING_FOR_OPPONENT:
        me.clearEffectAnimation()
        me.roomObjectAction(#set_bounce_state, tdata[#state])
        me.createEffect(#once, "bb2_efct_pu_harlequin_", [#ink: 33])
        tOpponentId = tdata[#coloringForOpponentTeamId]
        tGameObject = me.getGameSystem().getGameObject(tOpponentId)
        if tGameObject <> 0 then
          tTeamId = tGameObject.getGameObjectProperty(#teamId)
          tdata.addProp(#opponentTeamId, tTeamId)
          me.roomObjectAction(#set_ball_color, tdata)
        end if
      STATE_BALL_BROKEN:
        me.roomObjectAction(#set_bounce_state, tdata[#state])
        me.createEffect(#once, "bb2_efct_pu_harlequin_", [#ink: 33])
        me.createEffect(#loop, "bb2_stunned_", [#loc: point(0, 13), #ink: 8])
        pTargetLocation[#x] = -1
        pExpectedLocation[#x] = -1
        me.roomObjectAction(#set_ball, 0)
        if me.getGameObjectProperty(#id) = me.getOwnGameIndex() then
          me.getGameSystem().sendGameSystemEvent(#soundeffect, "SFX-10-stunned")
        end if
    end case
  end if
  return me.updateRoomObjectLocation(tdata)
end

on updateRoomObjectLocation me, tuser
  if (tuser[#x] = pTargetLocation[#x]) and (tuser[#y] = pTargetLocation[#y]) then
    pTargetLocation[#x] = -1
    pExpectedLocation[#x] = -1
  else
    tNextLoc = me.solveNextTile(tuser[#x], tuser[#y])
  end if
  if tNextLoc = 0 then
    tDirBody = tuser[#dirBody]
  else
    tuser[#dirBody] = tNextLoc[#dirBody]
  end if
  pDirBody = tuser[#dirBody]
  pLocation[#x] = tuser[#x]
  pLocation[#y] = tuser[#y]
  pLocation[#z] = tuser[#z]
  if not objectp(pRoomObject) then
    return error(me, "Room object wrapper missing", #updateRoomObjectLocation)
  end if
  pRoomObject.setLocation(tuser)
  me.setEffectAnimationLocations(tuser)
  if pExpectedLocation[#x] > -1 then
    if ((tuser[#x] <> pExpectedLocation[#x]) or (tuser[#y] <> pExpectedLocation[#y])) and (tNextLoc <> 0) then
      pTargetLocation[#x] = -1
      return 1
    end if
  end if
  if tNextLoc <> 0 then
    pExpectedLocation[#x] = tNextLoc[#x]
    pExpectedLocation[#y] = tNextLoc[#y]
  end if
  pRoomObject.setTarget(tuser, tNextLoc)
  return 1
end

on solveNextTile me, tCurrentLocX, tCurrentLocY
  if pTargetLocation[#x] = -1 then
    return 0
  end if
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return 0
  end if
  tGoalX = pTargetLocation[#x]
  tGoalY = pTargetLocation[#y]
  pDirObject.defineLine(tCurrentLocX, tCurrentLocY, tGoalX, tGoalY)
  tNextX = tCurrentLocX + pDirObject.getUnitVectorXComponent()
  tNextY = tCurrentLocY + pDirObject.getUnitVectorYComponent()
  tNextTile = tGameSystem.getWorld().getTile(tNextX, tNextY)
  if tNextTile <> 0 then
    tNextZ = tNextTile.getType(tNextX, tNextY)
    if integerp(integer(tNextZ)) then
      return [#x: tNextX, #y: tNextY, #z: tNextZ, #dirBody: pDirObject.getDirection()]
    end if
  end if
  pDirObject.rotateDirection45Degrees(1)
  tNextX = tCurrentLocX + pDirObject.getUnitVectorXComponent()
  tNextY = tCurrentLocY + pDirObject.getUnitVectorYComponent()
  tNextTile = tGameSystem.getWorld().getTile(tNextX, tNextY)
  if tNextTile <> 0 then
    tNextZ = tNextTile.getType(tNextX, tNextY)
    if integerp(integer(tNextZ)) then
      return [#x: tNextX, #y: tNextY, #z: tNextZ, #dirBody: pDirObject.getDirection()]
    end if
  end if
  pDirObject.rotateDirection45Degrees(0)
  pDirObject.rotateDirection45Degrees(0)
  tNextX = tCurrentLocX + pDirObject.getUnitVectorXComponent()
  tNextY = tCurrentLocY + pDirObject.getUnitVectorYComponent()
  tNextTile = tGameSystem.getWorld().getTile(tNextX, tNextY)
  if tNextTile <> 0 then
    tNextZ = tNextTile.getType(tNextX, tNextY)
    if integerp(integer(tNextZ)) then
      return [#x: tNextX, #y: tNextY, #z: tNextZ, #dirBody: pDirObject.getDirection()]
    end if
  end if
  return 0
end

on clearEffectAnimation me
  repeat with tEffect in pActiveEffects
    tEffect.pActive = 0
  end repeat
end

on setEffectAnimationLocations me, tlocation
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
  repeat with tEffect in pActiveEffects
    tEffect.setLocation(tScreenLoc)
  end repeat
  return 1
end

on startPowerupActivateAnimation me, tdata
  case tdata[#powerupType] of
    1:
      me.createEffect(#once, "bb2_efct_pu_lghtbulb_", [#ink: 33])
    3:
      me.createEffect(#once_slow, "bb2_efct_pu_flashlght_", [#ink: 33], tdata[#effectdirection])
    7:
      me.createEffect(#once, "bb2_efct_pu_lghtbulb_", [#ink: 35])
    otherwise:
      me.createEffect(#once, "bb2_pickup_", [#ink: 33])
  end case
  return 1
end

on createEffect me, tMode, tEffectID, tProps, tDirection
  tX = pLocation[#x]
  tY = pLocation[#y]
  tZ = pLocation[#z]
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

on getOwnGameIndex me
  tSession = getObject(#session)
  if not tSession.exists("user_game_index") then
    return 0
  end if
  return tSession.GET("user_game_index")
end

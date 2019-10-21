on construct(me)
  pDirBody = 0
  pLocation = [#x:-1, #y:-1, #z:-1]
  pTargetLocation = [#x:-1, #y:-1]
  pExpectedLocation = [#x:-1, #y:-1]
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
  return(1)
  exit
end

on deconstruct(me)
  repeat while me <= undefined
    tEffect = getAt(undefined, undefined)
    tEffect.deconstruct()
  end repeat
  pActiveEffects = []
  pDirObject = void()
  me.removeRoomObject()
  return(1)
  exit
end

on define(me, tGameObject)
  tGameObject = tGameObject.duplicate()
  me.setGameObjectProperty(tGameObject)
  me.createRoomObject(tGameObject)
  pLocation.setAt(#x, tGameObject.getAt(#x))
  pLocation.setAt(#y, tGameObject.getAt(#y))
  pLocation.setAt(#z, tGameObject.getAt(#z))
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
  if me = #gameobject_update then
    me.updateRoomObject(tdata)
  else
    if me = #set_target_custom then
      me.updateRoomObjectGoal(tdata)
    else
      if me = #activate_powerup then
        me.startPowerupActivateAnimation(tdata)
        if tdata.getAt(#powerupType) = 7 then
          me.updateRoomObject([#x:pLocation.getAt(#x), #y:pLocation.getAt(#y), #z:pLocation.getAt(#z), #state:STATE_STUNNED, #dirBody:pDirBody])
        end if
      else
        if me <> #gamereset then
          if me = #gameend then
            pTargetLocation.setAt(#x, -1)
            pExpectedLocation.setAt(#x, -1)
            me.clearEffectAnimation()
          else
            put("* Gameobject: UNDEFINED EVENT:" && tEvent && tdata)
          end if
          exit
        end if
      end if
    end if
  end if
end

on createRoomObject(me, tDataStruct)
  pRoomObject = createObject(#temp, getClassVariable("bb_gamesystem.roomobject.player.wrapper.class"))
  if pRoomObject = 0 then
    return(error(me, "Cannot create roomobject wrapper!", #createRoomObject))
  end if
  return(pRoomObject.define(tDataStruct))
  exit
end

on removeRoomObject(me)
  pRoomObject.deconstruct()
  pRoomObject = void()
  return(1)
  exit
end

on roomObjectAction(me, tAction, tdata)
  if not objectp(pRoomObject) then
    return(error(me, "Roomobject wrapper missing!", #getRoomObject))
  end if
  call(#roomObjectAction, pRoomObject, tAction, tdata)
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

on updateRoomObjectGoal(me, tdata)
  if not me.checkStateAllowsMoving() then
    return(1)
  end if
  pTargetLocation.setAt(#x, tdata.getAt(#goalx))
  pTargetLocation.setAt(#y, tdata.getAt(#goaly))
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return(0)
  end if
  tdata.setAt(#x, pLocation.getAt(#x))
  tdata.setAt(#y, pLocation.getAt(#y))
  tdata.setAt(#z, pLocation.getAt(#z))
  tdata.setAt(#dirBody, pDirBody)
  pExpectedLocation.setAt(#x, -1)
  return(me.updateRoomObjectLocation(tdata))
  exit
end

on checkStateAllowsMoving(me, tstate)
  if tstate = void() then
    tstate = me.getGameObjectProperty(#state)
  end if
  if me <> STATE_STUNNED then
    if me <> STATE_CLIMBING_INTO_CANNON then
      if me <> STATE_FLYING_THROUGH_AIR then
        if me = STATE_BALL_BROKEN then
          return(0)
        else
          return(1)
        end if
        exit
      end if
    end if
  end if
end

on updateRoomObject(me, tdata)
  tOldState = me.getGameObjectProperty(#state)
  if tdata.getAt(#state) <> tOldState then
    me.setGameObjectSyncProperty([#state:tdata.getAt(#state)])
    if tOldState = STATE_BALL_BROKEN then
      me.roomObjectAction(#set_ball, 1)
    end if
    if me = STATE_NORMAL then
      me.clearEffectAnimation()
      me.roomObjectAction(#reset_ball_color)
      me.roomObjectAction(#set_bounce_state, tdata.getAt(#state))
    else
      if me = STATE_HIGH_JUMPS then
        me.roomObjectAction(#set_bounce_state, tdata.getAt(#state))
      else
        if me = STATE_CLEANING_TILES then
          me.roomObjectAction(#set_bounce_state, tdata.getAt(#state))
        else
          if me = STATE_STUNNED then
            pTargetLocation.setAt(#x, -1)
            pExpectedLocation.setAt(#x, -1)
            me.createEffect(#loop, "bb2_stunned_", [#ink:8])
            me.roomObjectAction(#set_bounce_state, tdata.getAt(#state))
            if me.getGameObjectProperty(#id) = me.getOwnGameIndex() then
              me.getGameSystem().sendGameSystemEvent(#soundeffect, "SFX-10-stunned")
            end if
          else
            if me <> STATE_CLIMBING_INTO_CANNON then
              if me = STATE_FLYING_THROUGH_AIR then
                me.roomObjectAction(#set_bounce_state, tdata.getAt(#state))
                pTargetLocation.setAt(#x, -1)
                pExpectedLocation.setAt(#x, -1)
                me.roomObjectAction(#fly_into, tdata)
                return(1)
              else
                if me = STATE_COLORING_FOR_OPPONENT then
                  me.clearEffectAnimation()
                  me.roomObjectAction(#set_bounce_state, tdata.getAt(#state))
                  me.createEffect(#once, "bb2_efct_pu_harlequin_", [#ink:33])
                  tOpponentId = tdata.getAt(#coloringForOpponentTeamId)
                  tGameObject = me.getGameSystem().getGameObject(tOpponentId)
                  if tGameObject <> 0 then
                    tTeamId = tGameObject.getGameObjectProperty(#teamId)
                    tdata.addProp(#opponentTeamId, tTeamId)
                    me.roomObjectAction(#set_ball_color, tdata)
                  end if
                else
                  if me = STATE_BALL_BROKEN then
                    me.roomObjectAction(#set_bounce_state, tdata.getAt(#state))
                    me.createEffect(#once, "bb2_efct_pu_harlequin_", [#ink:33])
                    me.createEffect(#loop, "bb2_stunned_", [#loc:point(0, 13), #ink:8])
                    pTargetLocation.setAt(#x, -1)
                    pExpectedLocation.setAt(#x, -1)
                    me.roomObjectAction(#set_ball, 0)
                    if me.getGameObjectProperty(#id) = me.getOwnGameIndex() then
                      me.getGameSystem().sendGameSystemEvent(#soundeffect, "SFX-10-stunned")
                    end if
                  end if
                end if
              end if
              return(me.updateRoomObjectLocation(tdata))
              exit
            end if
          end if
        end if
      end if
    end if
  end if
end

on updateRoomObjectLocation(me, tuser)
  if tuser.getAt(#x) = pTargetLocation.getAt(#x) and tuser.getAt(#y) = pTargetLocation.getAt(#y) then
    pTargetLocation.setAt(#x, -1)
    pExpectedLocation.setAt(#x, -1)
  else
    tNextLoc = me.solveNextTile(tuser.getAt(#x), tuser.getAt(#y))
  end if
  if tNextLoc = 0 then
    tDirBody = tuser.getAt(#dirBody)
  else
    tuser.setAt(#dirBody, tNextLoc.getAt(#dirBody))
  end if
  pDirBody = tuser.getAt(#dirBody)
  pLocation.setAt(#x, tuser.getAt(#x))
  pLocation.setAt(#y, tuser.getAt(#y))
  pLocation.setAt(#z, tuser.getAt(#z))
  if not objectp(pRoomObject) then
    return(error(me, "Room object wrapper missing", #updateRoomObjectLocation))
  end if
  pRoomObject.setLocation(tuser)
  me.setEffectAnimationLocations(tuser)
  if pExpectedLocation.getAt(#x) > -1 then
    if tuser.getAt(#x) <> pExpectedLocation.getAt(#x) or tuser.getAt(#y) <> pExpectedLocation.getAt(#y) and tNextLoc <> 0 then
      pTargetLocation.setAt(#x, -1)
      return(1)
    end if
  end if
  if tNextLoc <> 0 then
    pExpectedLocation.setAt(#x, tNextLoc.getAt(#x))
    pExpectedLocation.setAt(#y, tNextLoc.getAt(#y))
  end if
  pRoomObject.setTarget(tuser, tNextLoc)
  return(1)
  exit
end

on solveNextTile(me, tCurrentLocX, tCurrentLocY)
  if pTargetLocation.getAt(#x) = -1 then
    return(0)
  end if
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return(0)
  end if
  tGoalX = pTargetLocation.getAt(#x)
  tGoalY = pTargetLocation.getAt(#y)
  pDirObject.defineLine(tCurrentLocX, tCurrentLocY, tGoalX, tGoalY)
  tNextX = tCurrentLocX + pDirObject.getUnitVectorXComponent()
  tNextY = tCurrentLocY + pDirObject.getUnitVectorYComponent()
  tNextTile = tGameSystem.getWorld().getTile(tNextX, tNextY)
  if tNextTile <> 0 then
    tNextZ = tNextTile.getType(tNextX, tNextY)
    if integerp(integer(tNextZ)) then
      return([#x:tNextX, #y:tNextY, #z:tNextZ, #dirBody:pDirObject.getDirection()])
    end if
  end if
  pDirObject.rotateDirection45Degrees(1)
  tNextX = tCurrentLocX + pDirObject.getUnitVectorXComponent()
  tNextY = tCurrentLocY + pDirObject.getUnitVectorYComponent()
  tNextTile = tGameSystem.getWorld().getTile(tNextX, tNextY)
  if tNextTile <> 0 then
    tNextZ = tNextTile.getType(tNextX, tNextY)
    if integerp(integer(tNextZ)) then
      return([#x:tNextX, #y:tNextY, #z:tNextZ, #dirBody:pDirObject.getDirection()])
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
      return([#x:tNextX, #y:tNextY, #z:tNextZ, #dirBody:pDirObject.getDirection()])
    end if
  end if
  return(0)
  exit
end

on clearEffectAnimation(me)
  repeat while me <= undefined
    tEffect = getAt(undefined, undefined)
    tEffect.pActive = 0
  end repeat
  exit
end

on setEffectAnimationLocations(me, tlocation)
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
  repeat while me <= undefined
    tEffect = getAt(undefined, tlocation)
    tEffect.setLocation(tScreenLoc)
  end repeat
  return(1)
  exit
end

on startPowerupActivateAnimation(me, tdata)
  if me = 1 then
    me.createEffect(#once, "bb2_efct_pu_lghtbulb_", [#ink:33])
  else
    if me = 3 then
      me.createEffect(#once_slow, "bb2_efct_pu_flashlght_", [#ink:33], tdata.getAt(#effectdirection))
    else
      if me = 7 then
        me.createEffect(#once, "bb2_efct_pu_lghtbulb_", [#ink:35])
      else
        me.createEffect(#once, "bb2_pickup_", [#ink:33])
      end if
    end if
  end if
  return(1)
  exit
end

on createEffect(me, tMode, tEffectID, tProps, tDirection)
  tX = pLocation.getAt(#x)
  tY = pLocation.getAt(#y)
  tZ = pLocation.getAt(#z)
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
  exit
end

on getOwnGameIndex(me)
  tSession = getObject(#session)
  if not tSession.exists("user_game_index") then
    return(0)
  end if
  return(tSession.GET("user_game_index"))
  exit
end
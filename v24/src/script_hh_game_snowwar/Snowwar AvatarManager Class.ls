property pNumTeams, pRoomComponentObj, pFigureSystemObj, pHiliterObj

on construct me
  pRoomComponentObj = getObject(#room_component)
  if (pRoomComponentObj = 0) then
    return error(me, "Avatar manager failed to initialize", #construct)
  end if
  registerMessage(#create_user, me.getID(), #setAvatarEventListener)
  return 1
end

on deconstruct me
  me.displayAvatarInfo(0)
  unregisterMessage(#create_user, me.getID())
  getObject(#session).Remove("game_number_of_teams")
  return 1
end

on Refresh me, tTopic, tdata
  case tTopic of
    #set_number_of_teams:
      pNumTeams = tdata
      getObject(#session).set("game_number_of_teams", tdata)
    #snowwar_event_2:
      me.getGameSystem().executeGameObjectEvent(tdata[#id], #set_target, tdata)
    #snowwar_event_3:
      me.getGameSystem().executeGameObjectEvent(tdata[#id], #start_throw_snowball, tdata)
      me.getGameSystem().executeGameObjectEvent(tdata[#id], #substract_ball_count)
    #snowwar_event_4:
      me.getGameSystem().executeGameObjectEvent(tdata[#id], #start_throw_snowball, tdata)
      me.getGameSystem().executeGameObjectEvent(tdata[#id], #substract_ball_count)
    #snowwar_event_5:
      playSound(("LS-hit-" & random(2)))
      tGameSystem = me.getGameSystem()
      tGameSystem.executeGameObjectEvent(tdata[#id], #substract_hit_points)
      if (pNumTeams = 1) then
        tAwardScore = 1
      else
        tThisTeam = tGameSystem.getGameObjectProperty(tdata[#id], #team_id)
        tThatTeam = tGameSystem.getGameObjectProperty(string(tdata[#int_thrower_id]), #team_id)
        if (tThisTeam <> tThatTeam) then
          tAwardScore = 1
        end if
      end if
      if tAwardScore then
        tGameSystem.executeGameObjectEvent(string(tdata[#int_thrower_id]), #award_hit_score)
      end if
    #snowwar_event_7:
      me.getGameSystem().executeGameObjectEvent(tdata[#id], #start_create_snowball)
    #snowwar_event_9:
      tGameSystem = me.getGameSystem()
      tHitDirection8 = tGameSystem.getGeometry().direction360to8(tdata[#hit_direction])
      playSound("LS-hit-3")
      tGameSystem.executeGameObjectEvent(tdata[#id], #start_stunned, [#hit_direction: tHitDirection8])
      tGameSystem.executeGameObjectEvent(tdata[#id], #zero_ball_count)
      if (pNumTeams = 1) then
        tAwardScore = 1
      else
        tThisTeam = tGameSystem.getGameObjectProperty(tdata[#id], #team_id)
        tThatTeam = tGameSystem.getGameObjectProperty(string(tdata[#int_thrower_id]), #team_id)
        if (tThisTeam <> tThatTeam) then
          tAwardScore = 1
        end if
      end if
      if tAwardScore then
        tGameSystem.executeGameObjectEvent(string(tdata[#int_thrower_id]), #award_kill_score)
      end if
  end case
  return error(me, ((("Undefined event!" && tTopic) && "for") && me.pID), #Refresh)
  return 1
end

on setAvatarEventListener me, tName, tID
  tRoom = getObject(#room_component)
  if (tRoom = 0) then
    return 0
  end if
  tObject = tRoom.getUserObject(tID)
  if (tObject = 0) then
    return 0
  end if
  call(#setAvatarEventListener, tObject, me.getID())
  return 1
end

on eventProcSnowwarUserRollOver me, tEvent, tID, tProp
  tRoom = getObject(#room_component)
  if (tRoom = 0) then
    return 0
  end if
  tObject = tRoom.getUserObject(tID)
  if (tObject = 0) then
    return 0
  end if
  tGameSystem = me.getGameSystem()
  if (tEvent = #mouseEnter) then
    tName = tObject.getName()
    tOwnPlayer = 0
    if not tGameSystem.getSpectatorModeFlag() then
      if (tName = getObject(#session).GET(#userName)) then
        tOwnPlayer = 1
      else
        if (tGameSystem.getGamestatus() = #game_started) then
          tMemberNum = getmemnum("sw_crosshair")
          tMemberNum2 = getmemnum("sw_crosshair.mask")
          if ((tMemberNum <> 0) and (tMemberNum2 <> 0)) then
            cursor([tMemberNum, tMemberNum2])
          end if
        end if
      end if
    end if
    tloc = tObject.getLocation()
    tloc = tGameSystem.convertTileToWorldCoordinate(tloc[1], tloc[2], 0)
    tloc = tGameSystem.convertWorldToScreenCoordinate(tloc[1], tloc[2], 0)
    tScore = tGameSystem.getGameObjectProperty(tObject.getAvatarId(), #score)
    return me.displayAvatarInfo(tName, tScore, tObject.getTeamId(), tloc, tOwnPlayer)
  else
    setcursor(0)
    return me.displayAvatarInfo(0)
  end if
end

on displayAvatarInfo me, tName, tScore, tTeamId, tloc, tOwnPlayer
  if stringp(tName) then
    if (pHiliterObj <> VOID) then
      return 1
    end if
    pHiliterObj = createObject(#temp, getClassVariable("snowwar.object_avatar.roomobject.hiliter.class"))
    if (pHiliterObj = 0) then
      return 0
    end if
    return pHiliterObj.display(tName, tScore, tTeamId, tloc, tOwnPlayer)
  else
    if (pHiliterObj <> VOID) then
      pHiliterObj.hide()
    end if
    pHiliterObj = VOID
  end if
  return 1
end

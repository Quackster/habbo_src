on construct(me)
  pRoomComponentObj = getObject(#room_component)
  if pRoomComponentObj = 0 then
    return(error(me, "Avatar manager failed to initialize", #construct))
  end if
  registerMessage(#create_user, me.getID(), #setAvatarEventListener)
  return(1)
  exit
end

on deconstruct(me)
  me.displayAvatarInfo(0)
  unregisterMessage(#create_user, me.getID())
  getObject(#session).Remove("game_number_of_teams")
  return(1)
  exit
end

on Refresh(me, tTopic, tdata)
  if me = #set_number_of_teams then
    pNumTeams = tdata
    getObject(#session).set("game_number_of_teams", tdata)
  else
    if me = #snowwar_event_2 then
      me.getGameSystem().executeGameObjectEvent(tdata.getAt(#id), #set_target, tdata)
    else
      if me = #snowwar_event_3 then
        me.getGameSystem().executeGameObjectEvent(tdata.getAt(#id), #start_throw_snowball, tdata)
        me.getGameSystem().executeGameObjectEvent(tdata.getAt(#id), #substract_ball_count)
      else
        if me = #snowwar_event_4 then
          me.getGameSystem().executeGameObjectEvent(tdata.getAt(#id), #start_throw_snowball, tdata)
          me.getGameSystem().executeGameObjectEvent(tdata.getAt(#id), #substract_ball_count)
        else
          if me = #snowwar_event_5 then
            playSound("LS-hit-" & random(2))
            tGameSystem = me.getGameSystem()
            tGameSystem.executeGameObjectEvent(tdata.getAt(#id), #substract_hit_points)
            if pNumTeams = 1 then
              tAwardScore = 1
            else
              tThisTeam = tGameSystem.getGameObjectProperty(tdata.getAt(#id), #team_id)
              tThatTeam = tGameSystem.getGameObjectProperty(string(tdata.getAt(#int_thrower_id)), #team_id)
              if tThisTeam <> tThatTeam then
                tAwardScore = 1
              end if
            end if
            if tAwardScore then
              tGameSystem.executeGameObjectEvent(string(tdata.getAt(#int_thrower_id)), #award_hit_score)
            end if
          else
            if me = #snowwar_event_7 then
              me.getGameSystem().executeGameObjectEvent(tdata.getAt(#id), #start_create_snowball)
            else
              if me = #snowwar_event_9 then
                tGameSystem = me.getGameSystem()
                tHitDirection8 = tGameSystem.getGeometry().direction360to8(tdata.getAt(#hit_direction))
                playSound("LS-hit-3")
                tGameSystem.executeGameObjectEvent(tdata.getAt(#id), #start_stunned, [#hit_direction:tHitDirection8])
                tGameSystem.executeGameObjectEvent(tdata.getAt(#id), #zero_ball_count)
                if pNumTeams = 1 then
                  tAwardScore = 1
                else
                  tThisTeam = tGameSystem.getGameObjectProperty(tdata.getAt(#id), #team_id)
                  tThatTeam = tGameSystem.getGameObjectProperty(string(tdata.getAt(#int_thrower_id)), #team_id)
                  if tThisTeam <> tThatTeam then
                    tAwardScore = 1
                  end if
                end if
                if tAwardScore then
                  tGameSystem.executeGameObjectEvent(string(tdata.getAt(#int_thrower_id)), #award_kill_score)
                end if
              else
                return(error(me, "Undefined event!" && tTopic && "for" && me.pID, #Refresh))
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return(1)
  exit
end

on setAvatarEventListener(me, tName, tid)
  tRoom = getObject(#room_component)
  if tRoom = 0 then
    return(0)
  end if
  tObject = tRoom.getUserObject(tid)
  if tObject = 0 then
    return(0)
  end if
  call(#setAvatarEventListener, tObject, me.getID())
  return(1)
  exit
end

on eventProcSnowwarUserRollOver(me, tEvent, tid, tProp)
  tRoom = getObject(#room_component)
  if tRoom = 0 then
    return(0)
  end if
  tObject = tRoom.getUserObject(tid)
  if tObject = 0 then
    return(0)
  end if
  tGameSystem = me.getGameSystem()
  if tEvent = #mouseEnter then
    tName = tObject.getName()
    tOwnPlayer = 0
    if not tGameSystem.getSpectatorModeFlag() then
      if tName = getObject(#session).get(#userName) then
        tOwnPlayer = 1
      else
        if tGameSystem.getGamestatus() = #game_started then
          tMemberNum = getmemnum("sw_crosshair")
          tMemberNum2 = getmemnum("sw_crosshair.mask")
          if tMemberNum <> 0 and tMemberNum2 <> 0 then
            cursor([tMemberNum, tMemberNum2])
          end if
        end if
      end if
    end if
    tloc = tObject.getLocation()
    tloc = tGameSystem.convertTileToWorldCoordinate(tloc.getAt(1), tloc.getAt(2), 0)
    tloc = tGameSystem.convertWorldToScreenCoordinate(tloc.getAt(1), tloc.getAt(2), 0)
    tScore = tGameSystem.getGameObjectProperty(tObject.getAvatarId(), #score)
    return(me.displayAvatarInfo(tName, tScore, tObject.getTeamId(), tloc, tOwnPlayer))
  else
    setcursor(0)
    return(me.displayAvatarInfo(0))
  end if
  exit
end

on displayAvatarInfo(me, tName, tScore, tTeamId, tloc, tOwnPlayer)
  if stringp(tName) then
    if pHiliterObj <> void() then
      return(1)
    end if
    pHiliterObj = createObject(#temp, getClassVariable("snowwar.object_avatar.roomobject.hiliter.class"))
    if pHiliterObj = 0 then
      return(0)
    end if
    return(pHiliterObj.display(tName, tScore, tTeamId, tloc, tOwnPlayer))
  else
    if pHiliterObj <> void() then
      pHiliterObj.hide()
    end if
    pHiliterObj = void()
  end if
  return(1)
  exit
end
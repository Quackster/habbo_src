on construct me
  return 1
end

on deconstruct me
  return 1
end

on Refresh me, tTopic, tdata
  case tTopic of
    #bb_event_2:
      me.updatePlayerObjectGoal(tdata)
  end case
  return 1
end

on updatePlayerObjectGoal me, tdata
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return 0
  end if
  if not listp(tdata) then
    return 0
  end if
  tID = tdata[#id]
  return tGameSystem.executeGameObjectEvent(tID, #set_target_custom, tdata)
end

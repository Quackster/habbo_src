on construct me 
  return TRUE
end

on deconstruct me 
  return TRUE
end

on Refresh me, tTopic, tdata 
  if (tTopic = #bb_event_2) then
    me.updatePlayerObjectGoal(tdata)
  end if
  return TRUE
end

on updatePlayerObjectGoal me, tdata 
  tGameSystem = me.getGameSystem()
  if (tGameSystem = 0) then
    return FALSE
  end if
  if not listp(tdata) then
    return FALSE
  end if
  tID = tdata.getAt(#id)
  return(tGameSystem.executeGameObjectEvent(tID, #set_target_custom, tdata))
end

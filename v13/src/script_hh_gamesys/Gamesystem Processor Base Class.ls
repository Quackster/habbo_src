property pFacadeId

on construct me 
  return TRUE
end

on deconstruct me 
  return TRUE
end

on setID me, tid, tFacadeId 
  pID = tid
  pFacadeId = tFacadeId
  return TRUE
end

on handleUpdate me, tTopic, tdata 
  return(me.Refresh(tTopic, tdata))
end

on Refresh me, tTopic, tdata 
  return TRUE
end

on getGameSystem me 
  return(getObject(pFacadeId))
end

on sendGameSystemEvent me, tTopic, tdata 
  tGameSystem = me.getGameSystem()
  if (tGameSystem = 0) then
    return FALSE
  end if
  return(tGameSystem.sendGameSystemEvent(tTopic, tdata))
end

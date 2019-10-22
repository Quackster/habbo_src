property pFacadeId, pFacadeRef

on construct me 
  return TRUE
end

on deconstruct me 
  pFacadeRef = void()
  return TRUE
end

on setID me, tID, tFacadeId 
  pID = tID
  pFacadeId = tFacadeId
  pFacadeRef = getObject(pFacadeId)
  return TRUE
end

on handleUpdate me, tTopic, tdata 
  return(me.Refresh(tTopic, tdata))
end

on Refresh me, tTopic, tdata 
  return TRUE
end

on getGameSystem me 
  return(pFacadeRef)
end

on sendGameSystemEvent me, tTopic, tdata 
  tGameSystem = me.getGameSystem()
  if (tGameSystem = 0) then
    return FALSE
  end if
  return(tGameSystem.sendGameSystemEvent(tTopic, tdata))
end

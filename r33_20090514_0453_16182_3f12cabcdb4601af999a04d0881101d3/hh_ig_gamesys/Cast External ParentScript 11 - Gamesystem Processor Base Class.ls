property pID, pFacadeId, pFacadeRef

on construct me
  return 1
end

on deconstruct me
  pFacadeRef = VOID
  return 1
end

on setID me, tID, tFacadeId
  pID = tID
  pFacadeId = tFacadeId
  pFacadeRef = getObject(pFacadeId)
  return 1
end

on handleUpdate me, tTopic, tdata
  return me.Refresh(tTopic, tdata)
end

on Refresh me, tTopic, tdata
  return 1
end

on getGameSystem me
  return pFacadeRef
end

on sendGameSystemEvent me, tTopic, tdata
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return 0
  end if
  return tGameSystem.sendGameSystemEvent(tTopic, tdata)
end

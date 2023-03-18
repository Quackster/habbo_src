property pID, pFacadeId

on construct me
  return 1
end

on deconstruct me
  return 1
end

on setID me, tid, tFacadeId
  pID = tid
  pFacadeId = tFacadeId
  return 1
end

on handleUpdate me, tTopic, tdata
  return me.Refresh(tTopic, tdata)
end

on Refresh me, tTopic, tdata
  return 1
end

on getGameSystem me
  return getObject(pFacadeId)
end

on sendGameSystemEvent me, tTopic, tdata
  tGameSystem = me.getGameSystem()
  if tGameSystem = 0 then
    return 0
  end if
  return tGameSystem.sendGameSystemEvent(tTopic, tdata)
end

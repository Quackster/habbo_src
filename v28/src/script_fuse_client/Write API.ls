on constructWriterManager
  return createManager(#writer_manager, getClassVariable("writer.manager.class"))
end

on deconstructWriterManager
  return removeManager(#writer_manager)
end

on getWriterManager
  tMgr = getObjectManager()
  if not tMgr.managerExists(#writer_manager) then
    return constructWriterManager()
  end if
  return tMgr.getManager(#writer_manager)
end

on createWriter tID, tMetrics
  return getWriterManager().create(tID, tMetrics)
end

on removeWriter tID
  return getWriterManager().Remove(tID)
end

on getWriter tID, tDefault
  return getWriterManager().GET(tID, tDefault)
end

on writerExists tID
  return getWriterManager().exists(tID)
end

on printWriters
  return getWriterManager().print()
end

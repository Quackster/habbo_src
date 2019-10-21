on constructWriterManager()
  return(createManager(#writer_manager, getClassVariable("writer.manager.class")))
  exit
end

on deconstructWriterManager()
  return(removeManager(#writer_manager))
  exit
end

on getWriterManager()
  tMgr = getObjectManager()
  if not tMgr.managerExists(#writer_manager) then
    return(constructWriterManager())
  end if
  return(tMgr.getManager(#writer_manager))
  exit
end

on createWriter(tID, tMetrics)
  return(getWriterManager().create(tID, tMetrics))
  exit
end

on removeWriter(tID)
  return(getWriterManager().Remove(tID))
  exit
end

on getWriter(tID, tDefault)
  return(getWriterManager().GET(tID, tDefault))
  exit
end

on writerExists(tID)
  return(getWriterManager().exists(tID))
  exit
end

on printWriters()
  return(getWriterManager().print())
  exit
end

on handlers()
  return([])
  exit
end
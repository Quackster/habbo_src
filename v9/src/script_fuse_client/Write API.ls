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

on createWriter(tid, tMetrics)
  return(getWriterManager().create(tid, tMetrics))
  exit
end

on removeWriter(tid)
  return(getWriterManager().Remove(tid))
  exit
end

on getWriter(tid, tDefault)
  return(getWriterManager().get(tid, tDefault))
  exit
end

on writerExists(tid)
  return(getWriterManager().exists(tid))
  exit
end

on printWriters()
  return(getWriterManager().print())
  exit
end
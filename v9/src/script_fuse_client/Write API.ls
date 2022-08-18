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

on createWriter tid, tMetrics
  return getWriterManager().create(tid, tMetrics)
end

on removeWriter tid
  return getWriterManager().Remove(tid)
end

on getWriter tid, tDefault
  return getWriterManager().get(tid, tDefault)
end

on writerExists tid
  return getWriterManager().exists(tid)
end

on printWriters
  return getWriterManager().print()
end

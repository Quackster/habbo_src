on constructTextManager
  return createManager(#text_manager, getClassVariable("text.manager.class"))
end

on deconstructTextManager
  return removeManager(#text_manager)
end

on getTextManager
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#text_manager) then
    return constructTextManager()
  end if
  return tObjMngr.getManager(#text_manager)
end

on createText tid, tValue
  return getTextManager().create(tid, tValue)
end

on removeText tid
  return getTextManager().remove(tid)
end

on setText tid, tValue
  return getTextManager().create(tid, tValue)
end

on getText tid, tDefault
  return getTextManager().get(tid, tDefault)
end

on textExists tid
  return getTextManager().exists(tid)
end

on printTexts
  return getTextManager().print()
end

on dumpTextField tField, tDelimiter
  return getTextManager().dump(tField, tDelimiter)
end

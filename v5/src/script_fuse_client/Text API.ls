on constructTextManager()
  return(createManager(#text_manager, getClassVariable("text.manager.class")))
  exit
end

on deconstructTextManager()
  return(removeManager(#text_manager))
  exit
end

on getTextManager()
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#text_manager) then
    return(constructTextManager())
  end if
  return(tObjMngr.getManager(#text_manager))
  exit
end

on createText(tid, tValue)
  return(getTextManager().create(tid, tValue))
  exit
end

on removeText(tid)
  return(getTextManager().remove(tid))
  exit
end

on setText(tid, tValue)
  return(getTextManager().create(tid, tValue))
  exit
end

on getText(tid, tDefault)
  return(getTextManager().get(tid, tDefault))
  exit
end

on textExists(tid)
  return(getTextManager().exists(tid))
  exit
end

on printTexts()
  return(getTextManager().print())
  exit
end

on dumpTextField(tField, tDelimiter)
  return(getTextManager().dump(tField, tDelimiter))
  exit
end
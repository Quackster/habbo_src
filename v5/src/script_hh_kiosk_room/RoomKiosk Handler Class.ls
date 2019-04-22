on construct me 
  return(registerListener(getVariable("connection.info.id"), me.getID(), ["FLATCREATED":#handleFlatCreated]))
end

on deconstuct me 
  return(unregisterListener(getVariable("connection.info.id"), me.getID(), ["FLATCREATED":#handleFlatCreated]))
end

on handleFlatCreated me, tMsg 
  tList = [:]
  #id.setAt(tMsg, content.getProp(#word, 1))
  #ip.setAt(tMsg, content.getProp(#word, 2))
  #port.setAt(tMsg, content.getProp(#word, 3))
  me.getInterface().flatcreated(tList)
end

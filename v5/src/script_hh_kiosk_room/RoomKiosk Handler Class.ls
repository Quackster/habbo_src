on construct me 
  return(registerListener(getVariable("connection.info.id"), me.getID(), ["FLATCREATED":#handleFlatCreated]))
end

on deconstuct me 
  return(unregisterListener(getVariable("connection.info.id"), me.getID(), ["FLATCREATED":#handleFlatCreated]))
end

on handleFlatCreated me, tMsg 
  tList = [:]
  tList.setAt(#id, tMsg.content.getProp(#word, 1))
  tList.setAt(#ip, tMsg.content.getProp(#word, 2))
  tList.setAt(#port, tMsg.content.getProp(#word, 3))
  me.getInterface().flatcreated(tList)
end

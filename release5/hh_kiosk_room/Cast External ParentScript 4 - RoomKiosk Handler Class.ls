on construct me
  return registerListener(getVariable("connection.info.id"), me.getID(), ["FLATCREATED": #handleFlatCreated])
end

on deconstuct me
  return unregisterListener(getVariable("connection.info.id"), me.getID(), ["FLATCREATED": #handleFlatCreated])
end

on handleFlatCreated me, tMsg
  tList = [:]
  tList[#id] = tMsg.content.word[1]
  tList[#ip] = tMsg.content.word[2]
  tList[#port] = tMsg.content.word[3]
  me.getInterface().flatcreated(tList)
end

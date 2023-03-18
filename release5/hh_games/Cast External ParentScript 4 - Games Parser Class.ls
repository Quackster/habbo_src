on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on parse_opengameboard me, tMsg
  tDelim = the itemDelimiter
  tLine = tMsg.message.line[2]
  if tLine contains TAB then
    the itemDelimiter = TAB
  else
    the itemDelimiter = ";"
  end if
  tProps = [:]
  tProps[#id] = tLine.item[1]
  tProps[#name] = tLine.item[2]
  tProps[#data] = tMsg.message.line[2..tMsg.message.line.count]
  the itemDelimiter = tDelim
  me.getComponent().openGameBoard(tProps)
end

on parse_closegameboard me, tMsg
  tDelim = the itemDelimiter
  tLine = tMsg.message.line[2]
  if tLine contains TAB then
    the itemDelimiter = TAB
  else
    the itemDelimiter = ";"
  end if
  tProps = [:]
  tProps[#id] = tLine.item[1]
  tProps[#name] = tLine.item[2]
  tProps[#data] = tMsg.message.line[2..tMsg.message.line.count]
  the itemDelimiter = tDelim
  me.getComponent().closeGameBoard(tProps)
end

on parse_itemmsg me, tMsg
  tProps = [:]
  tProps[#id] = tMsg.message.line[1].word[2]
  tProps[#command] = tMsg.message.line[2]
  tProps[#data] = tMsg.message.line[3..tMsg.message.line.count]
  me.getComponent().processItemMessage(tProps)
end

on regMsgList me, tBool
  tList = [:]
  tList["OPEN_GAMEBOARD"] = #parse_opengameboard
  tList["CLOSE_GAMEBOARD"] = #parse_closegameboard
  tList["ITEMMSG"] = #parse_itemmsg
  if tBool then
    return registerListener(getVariable("connection.room.id"), me.getID(), tList)
  else
    return unregisterListener(getVariable("connection.room.id"), me.getID(), tList)
  end if
end

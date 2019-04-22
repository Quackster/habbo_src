on construct(me)
  return(me.regMsgList(1))
  exit
end

on deconstruct(me)
  return(me.regMsgList(0))
  exit
end

on parse_opengameboard(me, tMsg)
  tDelim = the itemDelimiter
  tLine = message.getProp(#line, 2)
  if tLine contains "\t" then
    the itemDelimiter = "\t"
  else
    the itemDelimiter = ";"
  end if
  tProps = []
  tProps.setAt(#id, tLine.getProp(#item, 1))
  tProps.setAt(#name, tLine.getProp(#item, 2))
  tMsg.setAt(message, #line.getProp(2, tMsg, message.count(#line)))
  the itemDelimiter = tDelim
  me.getComponent().openGameBoard(tProps)
  exit
end

on parse_closegameboard(me, tMsg)
  tDelim = the itemDelimiter
  tLine = message.getProp(#line, 2)
  if tLine contains "\t" then
    the itemDelimiter = "\t"
  else
    the itemDelimiter = ";"
  end if
  tProps = []
  tProps.setAt(#id, tLine.getProp(#item, 1))
  tProps.setAt(#name, tLine.getProp(#item, 2))
  tMsg.setAt(message, #line.getProp(2, tMsg, message.count(#line)))
  the itemDelimiter = tDelim
  me.getComponent().closeGameBoard(tProps)
  exit
end

on parse_itemmsg(me, tMsg)
  tProps = []
  #id.setAt(tMsg, message.getPropRef(#line, 1).getProp(#word, 2))
  #command.setAt(tMsg, message.getProp(#line, 2))
  tMsg.setAt(message, #line.getProp(3, tMsg, message.count(#line)))
  me.getComponent().processItemMessage(tProps)
  exit
end

on regMsgList(me, tBool)
  tList = []
  tList.setAt("OPEN_GAMEBOARD", #parse_opengameboard)
  tList.setAt("CLOSE_GAMEBOARD", #parse_closegameboard)
  tList.setAt("ITEMMSG", #parse_itemmsg)
  if tBool then
    return(registerListener(getVariable("connection.room.id"), me.getID(), tList))
  else
    return(unregisterListener(getVariable("connection.room.id"), me.getID(), tList))
  end if
  exit
end
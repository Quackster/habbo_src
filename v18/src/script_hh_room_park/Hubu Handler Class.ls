on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on handle_cannot_enter_bus me, tMsg 
  me.getInterface().showBusClosed(tMsg.content.getProp(#line, 1, tMsg.content.count(#line)))
end

on handle_vote_question me, tMsg 
  tQuestion = tMsg.content.getProp(#line, 1)
  tChoices = []
  i = 2
  repeat while i <= tMsg.content.count(#line)
    tLine = tMsg.content.getProp(#line, i)
    if length(tLine) > 2 then
      tChoices.add(tLine.getProp(#char, 3, length(tLine)))
    end if
    i = (1 + i)
  end repeat
  me.getInterface().showVoteQuestion(tQuestion, tChoices)
end

on handle_vote_results me, tMsg 
  tDelim = the itemDelimiter
  tLine = tMsg.content.getProp(#line, 1)
  the itemDelimiter = "/"
  tTotalVotes = value(tLine.getProp(#item, 2))
  tChoiceVotes = []
  i = 3
  repeat while i <= tLine.count(#item)
    tChoiceVotes.add(value(tLine.getProp(#item, i)))
    i = (1 + i)
  end repeat
  the itemDelimiter = tDelim
  me.getInterface().showVoteResults(tTotalVotes, tChoiceVotes)
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(79, #handle_vote_question)
  tMsgs.setaProp(80, #handle_vote_results)
  tMsgs.setaProp(81, #handle_cannot_enter_bus)
  tCmds = [:]
  tCmds.setaProp("CHANGEWORLD", 111)
  tCmds.setaProp("VOTE", 112)
  tCmds.setaProp("TRYBUS", 113)
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  return TRUE
end

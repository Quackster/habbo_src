on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_cannot_enter_bus me, tMsg
  me.getInterface().showBusClosed(tMsg.content.line[1..tMsg.content.line.count])
end

on handle_vote_question me, tMsg
  tQuestion = tMsg.content.line[1]
  tChoices = []
  repeat with i = 2 to tMsg.content.line.count
    tLine = tMsg.content.line[i]
    if length(tLine) > 2 then
      tChoices.add(tLine.char[3..length(tLine)])
    end if
  end repeat
  me.getInterface().showVoteQuestion(tQuestion, tChoices)
end

on handle_vote_results me, tMsg
  tDelim = the itemDelimiter
  tLine = tMsg.content.line[1]
  the itemDelimiter = "/"
  tTotalVotes = value(tLine.item[2])
  tChoiceVotes = []
  repeat with i = 3 to tLine.item.count
    tChoiceVotes.add(value(tLine.item[i]))
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
  return 1
end

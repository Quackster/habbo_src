on construct(me)
  return(me.regMsgList(1))
  exit
end

on deconstruct(me)
  return(me.regMsgList(0))
  exit
end

on handle_cannot_enter_bus(me, tMsg)
  content.showBusClosed(#line.getProp(1, tMsg, content.count(#line)))
  exit
end

on handle_vote_question(me, tMsg)
  tQuestion = content.getProp(#line, 1)
  tChoices = []
  i = 2
  repeat while tMsg <= content.count(#line)
    tLine = content.getProp(#line, i)
    if length(tLine) > 2 then
      tChoices.add(tLine.getProp(#char, 3, length(tLine)))
    end if
    i = 1 + i
  end repeat
  me.getInterface().showVoteQuestion(tQuestion, tChoices)
  exit
end

on handle_vote_results(me, tMsg)
  tDelim = the itemDelimiter
  tLine = content.getProp(#line, 1)
  the itemDelimiter = "/"
  tTotalVotes = integer(tLine.getProp(#item, 2))
  tChoiceVotes = []
  i = 3
  repeat while i <= tLine.count(#item)
    tChoiceVotes.add(integer(tLine.getProp(#item, i)))
    i = 1 + i
  end repeat
  the itemDelimiter = tDelim
  me.getInterface().showVoteResults(tTotalVotes, tChoiceVotes)
  exit
end

on regMsgList(me, tBool)
  tMsgs = []
  tMsgs.setaProp(79, #handle_vote_question)
  tMsgs.setaProp(80, #handle_vote_results)
  tMsgs.setaProp(81, #handle_cannot_enter_bus)
  tCmds = []
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
  return(1)
  exit
end
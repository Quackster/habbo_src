on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on handle_cannot_enter_bus me, tMsg 
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return FALSE
  end if
  tReason = tConn.GetStrFrom()
  me.getInterface().showBusClosed(tReason)
end

on handle_vote_question me, tMsg 
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return FALSE
  end if
  tQuestion = tConn.GetStrFrom()
  tChoices = []
  tChoiceCount = tConn.GetIntFrom()
  i = 1
  repeat while i <= tChoiceCount
    tChoiceIndex = tConn.GetIntFrom()
    tChoice = tConn.GetStrFrom()
    tChoices.add(tChoice)
    i = (1 + i)
  end repeat
  me.getInterface().showVoteQuestion(tQuestion, tChoices)
end

on handle_vote_results me, tMsg 
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return FALSE
  end if
  tQuestion = tConn.GetStrFrom()
  tChoiceCount = tConn.GetIntFrom()
  tChoiceVotes = []
  i = 1
  repeat while i <= tChoiceCount
    tChoiceIndex = tConn.GetIntFrom()
    tChoice = tConn.GetStrFrom()
    tVotes = tConn.GetIntFrom()
    tChoiceVotes.add(tVotes)
    i = (1 + i)
  end repeat
  tTotalVotes = tConn.GetIntFrom()
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

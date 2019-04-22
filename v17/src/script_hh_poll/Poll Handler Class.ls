on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on handle_poll_offer me, tMsg 
  tPollID = connection.GetIntFrom()
  tPollDescription = connection.GetStrFrom()
  tdata = [:]
  tdata.setAt(#pollID, tPollID)
  tdata.setAt(#pollDescription, tPollDescription)
  me.getComponent().offerPoll(tdata)
end

on handle_poll_contents me, tMsg 
  tPollID = connection.GetIntFrom()
  tPollHeadLine = connection.GetStrFrom()
  tPollThankYou = connection.GetStrFrom()
  me.getComponent().setThanks(tPollThankYou)
  tCount = connection.GetIntFrom()
  i = 1
  repeat while i <= tCount
    tdata = [:]
    tdata.setAt(#pollID, tPollID)
    tdata.setAt(#pollHeadLine, tPollHeadLine)
    #questionID.setAt(tMsg, connection.GetIntFrom())
    #questionNumber.setAt(tMsg, connection.GetIntFrom())
    tdata.setAt(#questionCount, tCount)
    #questionType.setAt(tMsg, connection.GetIntFrom())
    #questionText.setAt(tMsg, connection.GetStrFrom())
    if tdata.getAt(#questionType) = 1 or tdata.getAt(#questionType) = 2 then
      tSelectionData = [:]
      tSelectionCount = connection.GetIntFrom()
      #minSelect.setAt(tMsg, connection.GetIntFrom())
      #maxSelect.setAt(tMsg, connection.GetIntFrom())
      tSelectionData.setAt(#questions, [])
      j = 1
      repeat while j <= tSelectionCount
        tMsg.add(connection.GetStrFrom())
        j = 1 + j
      end repeat
      tdata.setAt(#selectionData, tSelectionData)
    end if
    me.getComponent().parseQuestion(tdata)
    i = 1 + i
  end repeat
end

on handle_poll_error me, tMsg 
  me.getComponent().pollError()
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(316, #handle_poll_offer)
  tMsgs.setaProp(317, #handle_poll_contents)
  tMsgs.setaProp(318, #handle_poll_error)
  tCmds = [:]
  tCmds.setaProp("POLL_START", 234)
  tCmds.setaProp("POLL_REJECT", 235)
  tCmds.setaProp("POLL_ANSWER", 236)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return(1)
end

on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_poll_offer me, tMsg
  tPollID = tMsg.connection.GetIntFrom()
  tPollDescription = tMsg.connection.GetStrFrom()
  tdata = [:]
  tdata[#pollID] = tPollID
  tdata[#pollDescription] = tPollDescription
  me.getComponent().offerPoll(tdata)
end

on handle_poll_contents me, tMsg
  tPollID = tMsg.connection.GetIntFrom()
  tPollHeadLine = tMsg.connection.GetStrFrom()
  tPollThankYou = tMsg.connection.GetStrFrom()
  me.getComponent().setThanks(tPollThankYou)
  tCount = tMsg.connection.GetIntFrom()
  repeat with i = 1 to tCount
    tdata = [:]
    tdata[#pollID] = tPollID
    tdata[#pollHeadLine] = tPollHeadLine
    tdata[#questionID] = tMsg.connection.GetIntFrom()
    tdata[#questionNumber] = tMsg.connection.GetIntFrom()
    tdata[#questionCount] = tCount
    tdata[#questionType] = tMsg.connection.GetIntFrom()
    tdata[#questionText] = tMsg.connection.GetStrFrom()
    if (tdata[#questionType] = 1) or (tdata[#questionType] = 2) then
      tSelectionData = [:]
      tSelectionCount = tMsg.connection.GetIntFrom()
      tSelectionData[#minSelect] = tMsg.connection.GetIntFrom()
      tSelectionData[#maxSelect] = tMsg.connection.GetIntFrom()
      tSelectionData[#questions] = []
      repeat with j = 1 to tSelectionCount
        tSelectionData[#questions].add(tMsg.connection.GetStrFrom())
      end repeat
      tdata[#selectionData] = tSelectionData
    end if
    me.getComponent().parseQuestion(tdata)
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
  return 1
end

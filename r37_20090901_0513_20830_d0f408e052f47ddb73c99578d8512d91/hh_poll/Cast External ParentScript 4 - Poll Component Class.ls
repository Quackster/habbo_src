property pQuestionList, pQuestionIndex, pConfirmedAction, pConnectionId, pPollOfferID, pThanksText

on construct me
  pQuestionList = []
  pQuestionIndex = 1
  pConnectionId = getVariable("connection.info.id", #Info)
  registerMessage(#show_poll_question, me.getID(), #parseQuestion)
  return 1
end

on deconstruct me
  unregisterMessage(#show_poll_question, me.getID())
  return 1
end

on getQuestionAvailable me
  if pQuestionList.count >= pQuestionIndex then
    return 1
  end if
  return 0
end

on getNewQuestion me, tNext
  if tNext then
    if pQuestionIndex < pQuestionList.count then
      pQuestionIndex = pQuestionIndex + 1
    end if
  else
    if pQuestionIndex > 1 then
      pQuestionIndex = pQuestionIndex - 1
    end if
  end if
end

on getPollHeadLine me
  return me.getQuestionData(#pollHeadLine)
end

on getQuestionText me
  return me.getQuestionData(#questionText)
end

on getQuestionNumber me
  return me.getQuestionData(#questionNumber)
end

on getQuestionCount me
  return me.getQuestionData(#questionCount)
end

on getQuestionType me
  return me.getQuestionData(#questionType)
end

on getSelectionCount me
  tSelectionData = me.getQuestionData(#selectionData)
  if voidp(tSelectionData) then
    return 0
  end if
  tQuestions = tSelectionData[#questions]
  if voidp(tQuestions) then
    return 0
  end if
  return tQuestions.count
end

on getSelectionMinCount me
  tSelectionData = me.getQuestionData(#selectionData)
  if voidp(tSelectionData) then
    return 0
  end if
  if voidp(tSelectionData[#minSelect]) then
    return 0
  end if
  return tSelectionData[#minSelect]
end

on getSelectionMaxCount me
  tSelectionData = me.getQuestionData(#selectionData)
  if voidp(tSelectionData) then
    return 0
  end if
  if voidp(tSelectionData[#maxSelect]) then
    return 0
  end if
  return tSelectionData[#maxSelect]
end

on getSelectionText me, tIndex
  tSelectionData = me.getQuestionData(#selectionData)
  if voidp(tSelectionData) then
    return 0
  end if
  tQuestions = tSelectionData[#questions]
  if voidp(tQuestions) then
    return EMPTY
  end if
  if (tIndex < 1) or (tIndex > tQuestions.count) then
    return EMPTY
  end if
  return tQuestions[tIndex]
end

on getSelectionState me, tIndex
  tSelections = me.getQuestionData(#answerSelections)
  if voidp(tSelections) then
    return 0
  end if
  if (tIndex < 1) or (tIndex > tSelections.count) then
    return 0
  end if
  return tSelections[tIndex]
end

on changeSelectionState me, tIndex
  tSelections = me.getQuestionData(#answerSelections)
  if voidp(tSelections) then
    return 0
  end if
  if (tIndex < 1) or (tIndex > tSelections.count) then
    return 0
  end if
  tMaxSelect = me.getSelectionMaxCount()
  if tMaxSelect = 1 then
    tstate = 1
    repeat with i = tSelections.count down to 1
      tSelections[i] = 0
    end repeat
  else
    tstate = not tSelections[tIndex]
    tCount = 0
    repeat with i = tSelections.count down to 1
      if tSelections[i] <> 0 then
        tCount = tCount + 1
      end if
    end repeat
    if (tCount + tstate) > tMaxSelect then
      return 0
    end if
  end if
  tSelections[tIndex] = tstate
  return 1
end

on setAnswerText me, tText
  if pQuestionList.count < pQuestionIndex then
    return 0
  end if
  pQuestionList[pQuestionIndex][#answerText] = tText
  return 1
end

on getAnswerText me
  return me.getQuestionData(#answerText)
end

on getThanks me
  return pThanksText
end

on confirmAction me, tAction
  pConfirmedAction = tAction
  return 1
end

on actionConfirmed me
  if pConfirmedAction = "cancel" then
    me.cancelAnswer()
    me.getInterface().hideQuestion()
  end if
end

on sendAnswer me
  if not me.getQuestionAvailable() then
    return 0
  end if
  tQuestionIndex = pQuestionIndex
  repeat with tIndex = 1 to tQuestionIndex
    pQuestionIndex = 1
    tPollID = me.getQuestionData(#pollID)
    tQuestionID = me.getQuestionData(#questionID)
    tQuestionType = me.getQuestionData(#questionType)
    tReply = [#integer: tPollID, #integer: tQuestionID]
    tQuestionType = me.getQuestionType()
    if (tQuestionType = 1) or (tQuestionType = 2) then
      tSelectionCount = me.getSelectionCount()
      tMinSelect = me.getSelectionMinCount()
      tSelected = 0
      tSelectionList = []
      repeat with i = 1 to tSelectionCount
        tSelectionList[i] = me.getSelectionState(i)
        if tSelectionList[i] <> 0 then
          tSelected = tSelected + 1
        end if
      end repeat
      if tSelected < tMinSelect then
        pQuestionIndex = tQuestionIndex - (tIndex - 1)
        return 0
      end if
      tReply.addProp(#integer, tSelected)
      repeat with i = 1 to tSelectionList.count
        if tSelectionList[i] <> 0 then
          tReply.addProp(#integer, i)
        end if
      end repeat
    else
      if (tQuestionType = 3) or (tQuestionType = 4) then
        tAnswer = me.getAnswerText()
        if tAnswer.length = 0 then
          pQuestionIndex = tQuestionIndex - (tIndex - 1)
          return 0
        end if
        tAnswerText = me.getQuestionData(#answerText)
        tReply.addProp(#string, tAnswerText)
      end if
    end if
    if getConnection(pConnectionId) <> 0 then
      getConnection(pConnectionId).send("POLL_ANSWER", tReply)
    end if
    pQuestionList.deleteAt(1)
  end repeat
  pQuestionIndex = 1
  return 1
end

on cancelAnswer me
  tPollID = VOID
  repeat with i = 1 to pQuestionList.count
    pQuestionIndex = i
    tPollIDNew = me.getQuestionData(#pollID)
    tQuestionID = me.getQuestionData(#questionID)
    if tPollIDNew <> tPollID then
      tPollID = tPollIDNew
      tReply = [#integer: tPollID, #integer: tQuestionID]
      if getConnection(pConnectionId) <> 0 then
        getConnection(pConnectionId).send("POLL_CANCEL", tReply)
      end if
    end if
  end repeat
  pQuestionList = []
  pQuestionIndex = 1
end

on getQuestionData me, tProperty
  if pQuestionList.count < pQuestionIndex then
    return EMPTY
  end if
  return pQuestionList[pQuestionIndex][tProperty]
end

on setThanks me, tText
  pThanksText = tText
end

on offerPoll me, tdata
  if ilk(tdata) <> #propList then
    return 0
  end if
  if voidp(tdata[#pollID]) or voidp(tdata[#pollDescription]) then
    return 0
  end if
  pPollOfferID = tdata[#pollID]
  tPollDescription = tdata[#pollDescription]
  me.getInterface().showOffer(tPollDescription)
end

on acceptPoll me
  if getConnection(pConnectionId) <> 0 then
    getConnection(pConnectionId).send("POLL_START", [#integer: pPollOfferID])
  end if
end

on rejectPoll me
  if getConnection(pConnectionId) <> 0 then
    getConnection(pConnectionId).send("POLL_REJECT", [#integer: pPollOfferID])
  end if
end

on parseQuestion me, tdata
  if not me.validateQuestion(tdata) then
    return 0
  end if
  pQuestionList.add(tdata)
  tdata[#answerText] = EMPTY
  tdata[#answerSelections] = []
  tTmpIndex = pQuestionIndex
  pQuestionIndex = pQuestionList.count()
  tSelectionCount = me.getSelectionCount()
  repeat with i = 1 to tSelectionCount
    tdata[#answerSelections].add(0)
  end repeat
  pQuestionIndex = tTmpIndex
  me.getInterface().showQuestion()
end

on validateQuestion me, tdata
  if ilk(tdata) <> #propList then
    return 0
  end if
  tList = [#pollID, #pollHeadLine, #questionID, #questionNumber, #questionCount, #questionType, #questionText]
  repeat with tItem in tList
    if voidp(tdata[tItem]) then
      return 0
    end if
  end repeat
  if (tdata[#questionType] = 1) or (tdata[#questionType] = 2) then
    if voidp(tdata[#selectionData]) then
      return 0
    end if
    tSelectionData = tdata[#selectionData]
    tListSelection = [#minSelect, #maxSelect, #questions]
    repeat with tItem in tListSelection
      if voidp(tSelectionData[tItem]) then
        return 0
      end if
    end repeat
    if ilk(tSelectionData[#questions]) <> #list then
      return 0
    end if
    if tSelectionData[#questions].count = 0 then
      return 0
    end if
    tSelectionData[#maxSelect] = value(tSelectionData[#maxSelect])
    if tSelectionData[#maxSelect] < 1 then
      return 0
    end if
    tSelectionData[#minSelect] = value(tSelectionData[#minSelect])
    if tSelectionData[#minSelect] > tSelectionData[#maxSelect] then
      return 0
    end if
  end if
  return 1
end

on pollError me
  me.getInterface().hideWindows()
  me.getInterface().ShowAlert("server_error")
end

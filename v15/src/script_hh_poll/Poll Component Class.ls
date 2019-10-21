property pQuestionList, pQuestionIndex, pThanksText, pConfirmedAction, pConnectionId, pPollOfferID

on construct me 
  pQuestionList = []
  pQuestionIndex = 1
  pConnectionId = getVariableValue("connection.info.id", #info)
  registerMessage(#show_poll_question, me.getID(), #parseQuestion)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#show_poll_question, me.getID())
  return TRUE
end

on getQuestionAvailable me 
  if pQuestionList.count >= pQuestionIndex then
    return TRUE
  end if
  return FALSE
end

on getNewQuestion me, tNext 
  if tNext then
    if pQuestionIndex < pQuestionList.count then
      pQuestionIndex = (pQuestionIndex + 1)
    end if
  else
    if pQuestionIndex > 1 then
      pQuestionIndex = (pQuestionIndex - 1)
    end if
  end if
end

on getPollHeadLine me 
  return(me.getQuestionData(#pollHeadLine))
end

on getQuestionText me 
  return(me.getQuestionData(#questionText))
end

on getQuestionNumber me 
  return(me.getQuestionData(#questionNumber))
end

on getQuestionCount me 
  return(me.getQuestionData(#questionCount))
end

on getQuestionType me 
  return(me.getQuestionData(#questionType))
end

on getSelectionCount me 
  tSelectionData = me.getQuestionData(#selectionData)
  if voidp(tSelectionData) then
    return FALSE
  end if
  tQuestions = tSelectionData.getAt(#questions)
  if voidp(tQuestions) then
    return FALSE
  end if
  return(tQuestions.count)
end

on getSelectionMinCount me 
  tSelectionData = me.getQuestionData(#selectionData)
  if voidp(tSelectionData) then
    return FALSE
  end if
  if voidp(tSelectionData.getAt(#minSelect)) then
    return FALSE
  end if
  return(tSelectionData.getAt(#minSelect))
end

on getSelectionMaxCount me 
  tSelectionData = me.getQuestionData(#selectionData)
  if voidp(tSelectionData) then
    return FALSE
  end if
  if voidp(tSelectionData.getAt(#maxSelect)) then
    return FALSE
  end if
  return(tSelectionData.getAt(#maxSelect))
end

on getSelectionText me, tIndex 
  tSelectionData = me.getQuestionData(#selectionData)
  if voidp(tSelectionData) then
    return FALSE
  end if
  tQuestions = tSelectionData.getAt(#questions)
  if voidp(tQuestions) then
    return("")
  end if
  if tIndex < 1 or tIndex > tQuestions.count then
    return("")
  end if
  return(tQuestions.getAt(tIndex))
end

on getSelectionState me, tIndex 
  tSelections = me.getQuestionData(#answerSelections)
  if voidp(tSelections) then
    return FALSE
  end if
  if tIndex < 1 or tIndex > tSelections.count then
    return FALSE
  end if
  return(tSelections.getAt(tIndex))
end

on changeSelectionState me, tIndex 
  tSelections = me.getQuestionData(#answerSelections)
  if voidp(tSelections) then
    return FALSE
  end if
  if tIndex < 1 or tIndex > tSelections.count then
    return FALSE
  end if
  tMaxSelect = me.getSelectionMaxCount()
  if (tMaxSelect = 1) then
    tstate = 1
    i = tSelections.count
    repeat while i >= 1
      tSelections.setAt(i, 0)
      i = (255 + i)
    end repeat
    exit repeat
  end if
  tstate = not tSelections.getAt(tIndex)
  tCount = 0
  i = tSelections.count
  repeat while i >= 1
    if tSelections.getAt(i) <> 0 then
      tCount = (tCount + 1)
    end if
    i = (255 + i)
  end repeat
  if (tCount + tstate) > tMaxSelect then
    return FALSE
  end if
  tSelections.setAt(tIndex, tstate)
  return TRUE
end

on setAnswerText me, tText 
  if pQuestionList.count < pQuestionIndex then
    return FALSE
  end if
  pQuestionList.getAt(pQuestionIndex).setAt(#answerText, tText)
  return TRUE
end

on getAnswerText me 
  return(me.getQuestionData(#answerText))
end

on getThanks me 
  return(pThanksText)
end

on confirmAction me, tAction 
  pConfirmedAction = tAction
  return TRUE
end

on actionConfirmed me 
  if (pConfirmedAction = "cancel") then
    me.cancelAnswer()
    me.getInterface().hideQuestion()
  end if
end

on sendAnswer me 
  if not me.getQuestionAvailable() then
    return FALSE
  end if
  tQuestionIndex = pQuestionIndex
  tIndex = 1
  repeat while tIndex <= tQuestionIndex
    pQuestionIndex = 1
    tPollID = me.getQuestionData(#pollID)
    tQuestionID = me.getQuestionData(#questionID)
    tQuestionType = me.getQuestionData(#questionType)
    tReply = [#integer:tPollID, #integer:tQuestionID]
    tQuestionType = me.getQuestionType()
    if (tQuestionType = 1) or (tQuestionType = 2) then
      tSelectionCount = me.getSelectionCount()
      tMinSelect = me.getSelectionMinCount()
      tSelected = 0
      tSelectionList = []
      i = 1
      repeat while i <= tSelectionCount
        tSelectionList.setAt(i, me.getSelectionState(i))
        if tSelectionList.getAt(i) <> 0 then
          tSelected = (tSelected + 1)
        end if
        i = (1 + i)
      end repeat
      if tSelected < tMinSelect then
        pQuestionIndex = (tQuestionIndex - (tIndex - 1))
        return FALSE
      end if
      tReply.addProp(#integer, tSelected)
      i = 1
      repeat while i <= tSelectionList.count
        if tSelectionList.getAt(i) <> 0 then
          tReply.addProp(#integer, i)
        end if
        i = (1 + i)
      end repeat
      exit repeat
    end if
    if (tQuestionType = 3) or (tQuestionType = 4) then
      tAnswer = me.getAnswerText()
      if (tAnswer.length = 0) then
        pQuestionIndex = (tQuestionIndex - (tIndex - 1))
        return FALSE
      end if
      tAnswerText = me.getQuestionData(#answerText)
      tReply.addProp(#string, tAnswerText)
    end if
    if getConnection(pConnectionId) <> 0 then
      getConnection(pConnectionId).send("POLL_ANSWER", tReply)
    end if
    pQuestionList.deleteAt(1)
    tIndex = (1 + tIndex)
  end repeat
  pQuestionIndex = 1
  return TRUE
end

on cancelAnswer me 
  tPollID = void()
  i = 1
  repeat while i <= pQuestionList.count
    pQuestionIndex = i
    tPollIDNew = me.getQuestionData(#pollID)
    tQuestionID = me.getQuestionData(#questionID)
    if tPollIDNew <> tPollID then
      tPollID = tPollIDNew
      tReply = [#integer:tPollID, #integer:tQuestionID]
      if getConnection(pConnectionId) <> 0 then
        getConnection(pConnectionId).send("POLL_CANCEL", tReply)
      end if
    end if
    i = (1 + i)
  end repeat
  pQuestionList = []
  pQuestionIndex = 1
end

on getQuestionData me, tProperty 
  if pQuestionList.count < pQuestionIndex then
    return("")
  end if
  return(pQuestionList.getAt(pQuestionIndex).getAt(tProperty))
end

on setThanks me, tText 
  pThanksText = tText
end

on offerPoll me, tdata 
  if ilk(tdata) <> #propList then
    return FALSE
  end if
  if voidp(tdata.getAt(#pollID)) or voidp(tdata.getAt(#pollDescription)) then
    return FALSE
  end if
  pPollOfferID = tdata.getAt(#pollID)
  tPollDescription = tdata.getAt(#pollDescription)
  me.getInterface().showOffer(tPollDescription)
end

on acceptPoll me 
  if getConnection(pConnectionId) <> 0 then
    getConnection(pConnectionId).send("POLL_START", [#integer:pPollOfferID])
  end if
end

on rejectPoll me 
  if getConnection(pConnectionId) <> 0 then
    getConnection(pConnectionId).send("POLL_REJECT", [#integer:pPollOfferID])
  end if
end

on parseQuestion me, tdata 
  if not me.validateQuestion(tdata) then
    return FALSE
  end if
  pQuestionList.add(tdata)
  tdata.setAt(#answerText, "")
  tdata.setAt(#answerSelections, [])
  tTmpIndex = pQuestionIndex
  pQuestionIndex = pQuestionList.count()
  tSelectionCount = me.getSelectionCount()
  i = 1
  repeat while i <= tSelectionCount
    tdata.getAt(#answerSelections).add(0)
    i = (1 + i)
  end repeat
  pQuestionIndex = tTmpIndex
  me.getInterface().showQuestion()
end

on validateQuestion me, tdata 
  if ilk(tdata) <> #propList then
    return FALSE
  end if
  tList = [#pollID, #pollHeadLine, #questionID, #questionNumber, #questionCount, #questionType, #questionText]
  repeat while tList <= undefined
    tItem = getAt(undefined, tdata)
    if voidp(tdata.getAt(tItem)) then
      return FALSE
    end if
  end repeat
  if (tdata.getAt(#questionType) = 1) or (tdata.getAt(#questionType) = 2) then
    if voidp(tdata.getAt(#selectionData)) then
      return FALSE
    end if
    tSelectionData = tdata.getAt(#selectionData)
    tListSelection = [#minSelect, #maxSelect, #questions]
    repeat while tList <= undefined
      tItem = getAt(undefined, tdata)
      if voidp(tSelectionData.getAt(tItem)) then
        return FALSE
      end if
    end repeat
    if ilk(tSelectionData.getAt(#questions)) <> #list then
      return FALSE
    end if
    if (tSelectionData.getAt(#questions).count = 0) then
      return FALSE
    end if
    tSelectionData.setAt(#maxSelect, value(tSelectionData.getAt(#maxSelect)))
    if tSelectionData.getAt(#maxSelect) < 1 then
      return FALSE
    end if
    tSelectionData.setAt(#minSelect, value(tSelectionData.getAt(#minSelect)))
    if tSelectionData.getAt(#minSelect) > tSelectionData.getAt(#maxSelect) then
      return FALSE
    end if
  end if
  return TRUE
end

on pollError me 
  me.getInterface().hideWindows()
  me.getInterface().ShowAlert("server_error")
end

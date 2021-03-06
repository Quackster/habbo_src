property pOfferWindowID, pPollWindowID, pThanksWindowID, pConfirmWindowID

on construct me 
  pPollWindowID = getText("poll_window")
  pOfferWindowID = getText("poll_offer_window")
  pThanksWindowID = getText("poll_thanks_window")
  pConfirmWindowID = getText("poll_confirm_window")
  registerMessage(#leaveRoom, me.getID(), #hideWindows)
  registerMessage(#changeRoom, me.getID(), #hideWindows)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  return TRUE
end

on showOffer me, tDescription 
  me.hideOffer()
  if not createWindow(pOfferWindowID, "habbo_full.window", void(), void()) then
    return(error(me, "Failed to open Poll offer window!!!", #showOffer))
  else
    tWndObj = getWindow(pOfferWindowID)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcOffer, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcOffer, me.getID(), #mouseDown)
    if not tWndObj.merge("poll_offer.window") then
      return(tWndObj.close())
    end if
    tElem = tWndObj.getElement("offer_scrollbar")
    if tElem <> 0 then
      tElem.setProperty(#visible, 0)
    end if
    tElem = tWndObj.getElement("poll_offer_text")
    if tElem <> 0 then
      tHeightNow = tElem.getProperty(#image).rect.height
      tElem.setText(tDescription)
      tNewHeight = tElem.getProperty(#image).rect.height
      tElem.setProperty(#height, tNewHeight)
      tWndObj.setProp(#pClientRect, 2, (tWndObj.getProp(#pClientRect, 2) + (tNewHeight - tHeightNow)))
    end if
    if not tWndObj.merge("poll_purkka.window") then
      return(tWndObj.close())
    end if
  end if
  return TRUE
end

on hideOffer me 
  if windowExists(pOfferWindowID) then
    return(removeWindow(pOfferWindowID))
  else
    return FALSE
  end if
end

on showQuestion me 
  tWndObj = getWindow(pPollWindowID)
  if tWndObj <> 0 then
    return TRUE
  end if
  if not me.getComponent().getQuestionAvailable() then
    me.showThanks()
    return FALSE
  end if
  if not createWindow(pPollWindowID, "habbo_full.window", void(), void()) then
    return(error(me, "Failed to open Poll window!!!", #showPoll))
  else
    tWndObj = getWindow(pPollWindowID)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcQuestion, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcQuestion, me.getID(), #mouseDown)
    if not tWndObj.merge("poll_question_main.window") then
      return(tWndObj.close())
    end if
    tElem = tWndObj.getElement("poll_description")
    if tElem <> 0 then
      tElem.setText(me.getComponent().getPollHeadLine())
    end if
    tElem = tWndObj.getElement("poll_question_number")
    if tElem <> 0 then
      tText = getText("poll_question_number")
      tText = replaceChunks(tText, "%number%", me.getComponent().getQuestionNumber())
      tText = replaceChunks(tText, "%count%", me.getComponent().getQuestionCount())
      tElem.setText(tText)
    end if
    tElem = tWndObj.getElement("question_scrollbar")
    if tElem <> 0 then
      tElem.setProperty(#visible, 0)
    end if
    tElem = tWndObj.getElement("question_text")
    if tElem <> 0 then
      tHeightNow = tElem.getProperty(#image).rect.height
      tElem.setText(me.getComponent().getQuestionText())
      tNewHeight = tElem.getProperty(#image).rect.height
      if tNewHeight > tHeightNow then
        tElem.setProperty(#height, tNewHeight)
        tWndObj.setProp(#pClientRect, 2, (tWndObj.getProp(#pClientRect, 2) + (tNewHeight - tHeightNow)))
      end if
    end if
    tQuestionType = me.getComponent().getQuestionType()
    if (tQuestionType = 3) or (tQuestionType = 4) then
      if not tWndObj.merge("poll_question_open.window") then
        return(tWndObj.close())
      end if
    else
      if (tQuestionType = 1) or (tQuestionType = 2) then
        tSelectionCount = me.getComponent().getSelectionCount()
        i = 1
        repeat while i <= tSelectionCount
          if not me.duplicateWindowRecording("poll_question_selection", "_1", "_" & i) then
            return(tWndObj.close())
          end if
          if not tWndObj.merge("poll_question_selection_" & i & ".window") then
            return(tWndObj.close())
          end if
          tElem = tWndObj.getElement("selection_scrollbar_" & i)
          if tElem <> 0 then
            tElem.setProperty(#visible, 0)
          end if
          tElem = tWndObj.getElement("poll_selection_text_" & i)
          if tElem <> 0 then
            tHeightNow = tElem.getProperty(#image).rect.height
            tElem.setText(me.getComponent().getSelectionText(i))
            tNewHeight = tElem.getProperty(#image).rect.height
            if tNewHeight > tHeightNow then
              tElem.setProperty(#height, tNewHeight)
              tWndObj.setProp(#pClientRect, 2, (tWndObj.getProp(#pClientRect, 2) + (tNewHeight - tHeightNow)))
            end if
          end if
          i = (1 + i)
        end repeat
        me.updateSelectionButtons()
      end if
    end if
  end if
  return TRUE
end

on hideQuestion me 
  if windowExists(pPollWindowID) then
    return(removeWindow(pPollWindowID))
  else
    return FALSE
  end if
end

on showThanks me 
  me.hideThanks()
  if not createWindow(pThanksWindowID, "habbo_full.window", void(), void()) then
    return(error(me, "Failed to open Poll thanks window!!!", #showThanks))
  else
    tWndObj = getWindow(pThanksWindowID)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcThanks, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcThanks, me.getID(), #mouseDown)
    if not tWndObj.merge("poll_thank_you.window") then
      return(tWndObj.close())
    end if
    tElem = tWndObj.getElement("thanks_scrollbar")
    if tElem <> 0 then
      tElem.setProperty(#visible, 0)
    end if
    tElem = tWndObj.getElement("poll_thanks_text")
    if tElem <> 0 then
      tHeightNow = tElem.getProperty(#image).rect.height
      tText = me.getComponent().getThanks()
      tElem.setText(tText)
      tNewHeight = tElem.getProperty(#image).rect.height
      tElem.setProperty(#height, tNewHeight)
      tWndObj.setProp(#pClientRect, 2, (tWndObj.getProp(#pClientRect, 2) + (tNewHeight - tHeightNow)))
    end if
    if not tWndObj.merge("poll_purkka.window") then
      return(tWndObj.close())
    end if
  end if
  return TRUE
end

on hideThanks me 
  if windowExists(pThanksWindowID) then
    return(removeWindow(pThanksWindowID))
  else
    return FALSE
  end if
end

on hideConfirm me 
  if windowExists(pConfirmWindowID) then
    return(removeWindow(pConfirmWindowID))
  else
    return FALSE
  end if
end

on hideWindows me 
  me.hideQuestion()
  me.hideConfirm()
  me.hideOffer()
  me.hideThanks()
end

on confirmAction me, tAction 
  tResult = me.getComponent().confirmAction(tAction)
  if tResult then
    if not windowExists(pConfirmWindowID) then
      if not createWindow(pConfirmWindowID, "habbo_full.window", void(), void(), #modal) then
        return(error(me, "Failed to open Poll confirm window!!!", #confirmAction))
      else
        tWndObj = getWindow(pConfirmWindowID)
        tWndObj.registerClient(me.getID())
        tWndObj.registerProcedure(#eventProcConfirm, me.getID(), #mouseUp)
        if not tWndObj.merge("habbo_decision_dialog.window") then
          return(tWndObj.close())
        end if
        tElem = tWndObj.getElement("habbo_decision_text_a")
        if tElem <> 0 then
          tText = getText("poll_confirm_" & tAction)
          tElem.setText(tText)
        end if
        tElem = tWndObj.getElement("habbo_decision_text_b")
        if tElem <> 0 then
          tText = getText("poll_confirm_" & tAction & "_long")
          tElem.setText(tText)
        end if
        tWndObj.center()
        tWndObj.moveBy(0, -30)
      end if
    end if
  end if
  return(tResult)
end

on ShowAlert me, ttype 
  tTextId = "poll_alert_" & ttype
  executeMessage(#alert, [#Msg:tTextId, #modal:1])
end

on duplicateWindowRecording me, tNameBase, tOriginalIDPart, tTargetIDPart 
  tSourceMemName = tNameBase & tOriginalIDPart & ".window"
  tSourceMember = member(tSourceMemName)
  if tSourceMember.name <> tSourceMemName then
    return FALSE
  end if
  if tSourceMember.type <> #field then
    return FALSE
  end if
  tTargetMemName = tNameBase & tTargetIDPart & ".window"
  if (member(tTargetMemName).name = tTargetMemName) then
    return TRUE
  end if
  tTargetMemberNum = createMember(tTargetMemName, tSourceMember.type, 0)
  if (tTargetMemberNum = 0) then
    return(error(me, "Could not create a new member for copying: " & tTargetMemName, #duplicateWindowRecording))
  end if
  tTargetMember = member(tTargetMemberNum)
  tTargetMember.media = tSourceMember.media
  tText = tTargetMember.text
  tText = replaceChunks(tText, tOriginalIDPart, tTargetIDPart)
  tTargetMember.text = tText
  return TRUE
end

on updateSelectionButtons me 
  tWndObj = getWindow(pPollWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tSelectionCount = me.getComponent().getSelectionCount()
  tSelectionMax = me.getComponent().getSelectionMaxCount()
  if (tSelectionMax = 1) then
    tImageList = ["button.radio.on", "button.radio.off"]
  else
    tImageList = ["button.checkbox.on", "button.checkbox.off"]
  end if
  i = 1
  repeat while i <= tSelectionCount
    tElem = tWndObj.getElement("poll_selection_button_" & i)
    if tElem <> 0 then
      if me.getComponent().getSelectionState(i) then
        tElem.feedImage(member(tImageList.getAt(1)).image)
      else
        tElem.feedImage(member(tImageList.getAt(2)).image)
      end if
    end if
    i = (1 + i)
  end repeat
  return TRUE
end

on eventProcOffer me, tEvent, tSprID, tParam, tWndID 
  if (tEvent = #mouseUp) then
    if tSprID <> "close" then
      if (tSprID = "poll_offer_cancel") then
        me.getComponent().rejectPoll()
        me.hideOffer()
      else
        if (tSprID = "poll_offer_ok") then
          me.getComponent().acceptPoll()
          me.hideOffer()
        end if
      end if
    end if
  end if
end

on eventProcQuestion me, tEvent, tSprID, tParam, tWndID 
  if (tEvent = #mouseUp) then
    if tSprID <> "close" then
      if (tSprID = "poll_question_cancel") then
        me.confirmAction("cancel")
      else
        if (tSprID = "poll_question_ok") then
          tWndObj = getWindow(pPollWindowID)
          if tWndObj <> 0 then
            tElem = tWndObj.getElement("poll_answer")
            if tElem <> 0 then
              tText = tElem.getText()
              me.getComponent().setAnswerText(tText)
            end if
          end if
          tRetVal = me.getComponent().sendAnswer()
          if tRetVal then
            me.hideQuestion()
            me.showQuestion()
          else
            me.ShowAlert("answer_missing")
          end if
        end if
      end if
      if (offset("poll_selection_button_", tSprID) = 1) then
        tIndex = value(tSprID.getProp(#char, ("poll_selection_button_".length + 1), tSprID.length))
        if me.getComponent().changeSelectionState(tIndex) then
          me.updateSelectionButtons()
        else
          me.ShowAlert("invalid_selection")
        end if
      end if
      return TRUE
    end if
  end if
end

on eventProcThanks me, tEvent, tSprID, tParam, tWndID 
  if (tEvent = #mouseUp) then
    if tSprID <> "close" then
      if (tSprID = "poll_thanks_ok") then
        me.hideThanks()
      end if
      return TRUE
    end if
  end if
end

on eventProcConfirm me, tEvent, tSprID, tParam, tWndID 
  if (tEvent = #mouseUp) then
    if tSprID <> "close" then
      if (tSprID = "habbo_decision_cancel") then
        me.hideConfirm()
      else
        if (tSprID = "habbo_decision_ok") then
          me.getComponent().actionConfirmed()
          me.hideConfirm()
        end if
      end if
      return TRUE
    end if
  end if
end

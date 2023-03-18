property pWindowTitle, pBuddyList, pRemoveCheckBoxList, pOnScreenNum, pPageNr, pPageCount, pArrangeType, pChosen, pLimitPntr, pRemoveList

on construct me
  pWindowTitle = getText("buddyremove_windowheader")
  pBuddyList = [:]
  pRemoveCheckBoxList = []
  pOnScreenNum = 10
  pPageNr = 1
  pPageCount = 1
  pArrangeType = #none
  pChosen = 0
  pLimitPntr = [:]
  pRemoveList = []
  repeat with i = 1 to pOnScreenNum
    pRemoveCheckBoxList.add(0)
  end repeat
end

on deconstruct me
end

on openRemoveWindow me, tFriendListCopy, tListLimitsPntr
  pBuddyList = tFriendListCopy
  pLimitPntr = tListLimitsPntr
  pBuddyList.sort()
  if (pBuddyList.ilk <> #propList) or (pLimitPntr.ilk <> #propList) then
    return 0
  end if
  if windowExists(pWindowTitle) then
    return 1
  end if
  if not createWindow(pWindowTitle, "habbo_full.window", 0, 0, #modal) then
    return error(me, "Failed to open Messenger window!!!", #openRemoveWindow)
  end if
  tWndObj = getWindow(pWindowTitle)
  if not tWndObj.merge("console_buddylistfull.window") then
    return tWndObj.close()
  end if
  tElem = tWndObj.getElement("console_friendremove_list_full")
  tText = getText("buddyremove_list_full")
  tText = replaceChunks(tText, "%mylimit%", string(pLimitPntr.getProp(#own)))
  tText = replaceChunks(tText, "%clublimit%", string(pLimitPntr.getProp(#club)))
  if not (getText("buddyremove_hc_info_url") starts "http") then
    tWndObj.getElement("buddyremove_hc_more_info").hide()
  end if
  tElem.setText(tText)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcBuddyRemove, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProcBuddyRemove, me.getID(), #mouseDown)
  tWndObj.center()
  return 1
end

on confirmationReceived me
  return me.sendRemoveList()
end

on removeUnnecessaryFromBuddylist me
  repeat with i = 1 to pBuddyList.count
    pBuddyList.deleteProp(#customText)
    pBuddyList.deleteProp(#msgs)
    pBuddyList.deleteProp(#update)
    pBuddyList.deleteProp(#sex)
    pBuddyList.deleteProp(#location)
    pBuddyList.deleteProp(#online)
  end repeat
  return 1
end

on setUpMassRemoveWindow me
  if not windowExists(pWindowTitle) then
    return 0
  end if
  tWndObj = getWindow(pWindowTitle)
  tWndObj.unmerge()
  if not tWndObj.merge("console_massbuddyremove.window") then
    return tWndObj.close()
  end if
  repeat with i = 1 to pBuddyList.count
    pBuddyList[i].addProp(#Remove, 0)
  end repeat
  pPageCount = pBuddyList.count / pOnScreenNum
  if (pBuddyList.count mod pOnScreenNum) <> 0 then
    pPageCount = pPageCount + 1
  end if
  me.arrangeFriendList(#name)
  return 1
end

on changeOptionLevel me, tStyle
  if not windowExists(pWindowTitle) then
    return 0
  end if
  case tStyle of
    #more:
      tWndObj = getWindow(pWindowTitle)
      tWndObj.unmerge()
      if not tWndObj.merge("console_massremove_extended.window") then
        return tWndObj.close()
      end if
    #less:
      tWndObj = getWindow(pWindowTitle)
      tWndObj.unmerge()
      if not tWndObj.merge("console_massbuddyremove.window") then
        return tWndObj.close()
      end if
  end case
  return me.updateView()
end

on updateView me
  if not windowExists(pWindowTitle) then
    return 0
  end if
  tWndObj = getWindow(pWindowTitle)
  tStartNr = (pPageNr - 1) * pOnScreenNum
  repeat with i = 1 to pOnScreenNum
    tElem1ID = "console_friendremove_name" & i
    tElem2ID = "friendremove_checkbox" & i
    tElem1 = tWndObj.getElement(tElem1ID)
    tElem2 = tWndObj.getElement(tElem2ID)
    if (tStartNr + i) > pBuddyList.count then
      tElem1.hide()
      tElem2.hide()
      next repeat
    end if
    tElem1.show()
    tElem2.show()
    tElem1.setText(pBuddyList[tStartNr + i].name)
    if not pBuddyList[tStartNr + i].Remove then
      pRemoveCheckBoxList[i] = 0
      me.updateCheckButton(tElem2ID, "button.checkbox.off")
      next repeat
    end if
    pRemoveCheckBoxList[i] = 1
    me.updateCheckButton(tElem2ID, "button.checkbox.on")
  end repeat
  tElem = tWndObj.getElement("console_friendremove_pagecounter")
  tElem.setText(getText("buddyremove_pagecounter") && pPageNr && "/" && pPageCount)
  tElem = tWndObj.getElement("console_friendremove_prev")
  if pPageNr = 1 then
    tElem.hide()
  else
    tElem.show()
  end if
  tElem = tWndObj.getElement("console_friendremove_next")
  if pPageNr = pPageCount then
    tElem.hide()
  else
    tElem.show()
  end if
  tElem = tWndObj.getElement("console_friendremove_accept_button")
  if pChosen = 0 then
    tElem.deactivate()
  else
    tElem.Activate()
  end if
  me.updateToChooseCounter()
  setcursor(#arrow)
end

on hideNames me
  if not windowExists(pWindowTitle) then
    return 0
  end if
  tWndObj = getWindow(pWindowTitle)
  repeat with i = 1 to pOnScreenNum
    tElem1 = tWndObj.getElement("console_friendremove_name" & i)
    tElem2 = tWndObj.getElement("friendremove_checkbox" & i)
    tElem1.hide()
    tElem2.hide()
  end repeat
  return 1
end

on nextPage me
  if pPageNr < pPageCount then
    pPageNr = pPageNr + 1
    me.updateView()
  end if
end

on prevPage me
  if pPageNr > 1 then
    pPageNr = pPageNr - 1
    me.updateView()
  end if
end

on nameClicked me, tid
  return me.checkBoxClicked(tid, #name)
end

on checkBoxClicked me, tid, ttype
  if not windowExists(pWindowTitle) then
    return 0
  end if
  if ttype = #name then
    tNum = integer(tid.char[26..tid.char.count])
  else
    tNum = integer(tid.char[22..tid.char.count])
  end if
  tStartNr = (pPageNr - 1) * pOnScreenNum
  tBoxID = "friendremove_checkbox" & tNum
  if pRemoveCheckBoxList[tNum] = 0 then
    pRemoveCheckBoxList[tNum] = 1
    pBuddyList[tStartNr + tNum].Remove = 1
    pChosen = pChosen + 1
    me.updateCheckButton(tBoxID, "button.checkbox.on")
  else
    pRemoveCheckBoxList[tNum] = 0
    pBuddyList[tStartNr + tNum].Remove = 0
    pChosen = pChosen - 1
    me.updateCheckButton(tBoxID, "button.checkbox.off")
  end if
  tWndObj = getWindow(pWindowTitle)
  tElem = tWndObj.getElement("console_friendremove_accept_button")
  if pChosen = 0 then
    tElem.deactivate()
  else
    tElem.Activate()
  end if
  return me.updateToChooseCounter()
end

on updateToChooseCounter me
  if not windowExists(pWindowTitle) then
    return 0
  end if
  tWndObj = getWindow(pWindowTitle)
  tToRemove = pBuddyList.count - pLimitPntr.own - pChosen + 1
  tElem1 = tWndObj.getElement("console_friendremove_ok_text")
  tElem2 = tWndObj.getElement("console_friendremove_header")
  if tToRemove < 1 then
    tElem1.show()
    tElem2.hide()
  else
    tElem2.show()
    tElem1.hide()
    tText = getText("buddyremove_header")
    tText = replaceChunks(tText, "%amount%", string(tToRemove))
    tElem2.setText(tText)
  end if
  return 1
end

on getStayCount me
  tStay = 0
  repeat with i = 1 to pBuddyList.count
    if not pBuddyList[i].Remove then
      tStay = tStay + 1
    end if
  end repeat
  return tStay
end

on updateCheckButton me, tElementId, tMemName
  if not windowExists(pWindowTitle) then
    return 0
  end if
  tWndObj = getWindow(pWindowTitle)
  tNewImg = member(getmemnum(tMemName)).image
  if tWndObj.elementExists(tElementId) then
    tWndObj.getElement(tElementId).feedImage(tNewImg)
  end if
  return 1
end

on endMassRemovalSession me, tHideMessenger
  tWndObj = getWindow(pWindowTitle)
  if not tWndObj = VOID then
    tWndObj.close()
  end if
  if objectExists("buddy_massremove") then
    removeObject("buddy_massremove")
  end if
  return 1
end

on showConfirmationWindow me
  tWndObj = getWindow(pWindowTitle)
  tWndObj.unmerge()
  if not tWndObj.merge("console_massremove_confirm.window") then
    return tWndObj.close()
  end if
  tElem = tWndObj.getElement("console_friendremove_remove_text")
  tText = getText("buddyremove_remove_text")
  tText = replaceChunks(tText, "%removeamount%", string(pChosen))
  tText = replaceChunks(tText, "%amountleft%", string(pBuddyList.count - pChosen))
  tElem.setText(tText)
  tText = EMPTY
  repeat with i = 1 to pBuddyList.count
    if not pBuddyList[i].Remove then
      tText = tText & pBuddyList[i].name & ", "
    end if
  end repeat
  tText = tText.char[1..tText.char.count - 2]
  tElem = tWndObj.getElement("console_friendremove_keep_list")
  tElem.setText(tText)
end

on commitRemove me
  pRemoveList = []
  repeat with i = 1 to pBuddyList.count
    if pBuddyList[i].Remove then
      pRemoveList.add(pBuddyList[i].id)
    end if
  end repeat
  tWndObj = getWindow(pWindowTitle)
  if not tWndObj = VOID then
    tWndObj.close()
  end if
  getThread(#messenger).getInterface().setMessengerInactive()
  return me.sendRemoveList()
end

on sendRemoveList me
  if pRemoveList = [] then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_UPDATE", [#integer: 0])
    return me.endMassRemovalSession()
  end if
  tListSize = 400
  tCount = 0
  tSendList = [#integer: 0]
  repeat with i = 1 to tListSize
    tSendList.addProp(#integer, integer(pRemoveList[1]))
    pRemoveList.deleteAt(1)
    tCount = tCount + 1
    if pRemoveList = [] then
      exit repeat
    end if
  end repeat
  tSendList[1] = tCount
  getConnection(getVariable("connection.info.id")).send("MESSENGER_REMOVEBUDDY", tSendList)
  return 1
end

on arrangeFriendList me, ttype
  if pArrangeType = ttype then
    return 0
  end if
  if ttype = #logintime then
    me.showWaitIfNecessary()
  end if
  tNewList = [:]
  tTemp = the itemDelimiter
  the itemDelimiter = "-"
  repeat with i = 1 to pBuddyList.count
    case ttype of
      #name:
        tNewList.addProp(pBuddyList[i].name, pBuddyList[i])
      #logintime:
        tTime = pBuddyList[i].lastAccess.word[1]
        tArrangedTime = tTime.item[3] & tTime.item[2] & tTime.item[1]
        tNewList.addProp(tArrangedTime, pBuddyList[i])
    end case
  end repeat
  tNewList.sort()
  the itemDelimiter = tTemp
  pBuddyList = tNewList.duplicate()
  pPageNr = 1
  pArrangeType = ttype
  me.updateView()
  return 1
end

on showWaitIfNecessary me
  if pBuddyList.count < 500 then
    return 1
  end if
  if not windowExists(pWindowTitle) then
    return 0
  end if
  tWndObj = getWindow(pWindowTitle)
  tElem = tWndObj.getElement("console_friendremove_header")
  tText = getText("buddyremove_pleasewait")
  tElem.setText(tText)
  me.hideNames()
  setcursor(#timer)
  updateStage()
  return 1
end

on selectAllFriends me
  repeat with i = 1 to pBuddyList.count
    pBuddyList[i].Remove = 1
  end repeat
  pChosen = pBuddyList.count
  me.updateView()
  return 1
end

on invertSelection me
  repeat with i = 1 to pBuddyList.count
    pBuddyList[i].Remove = not pBuddyList[i].Remove
  end repeat
  pChosen = pBuddyList.count - pChosen
  me.updateView()
  return 1
end

on eventProcBuddyRemove me, tEvent, tElemID, tParam
  if tEvent = #mouseUp then
    case tElemID of
      "console_friendremove_next":
        me.nextPage()
      "console_friendremove_prev":
        me.prevPage()
      "console_friendremove_accept_button":
        me.showConfirmationWindow()
      "console_friendremove_confirm":
        me.commitRemove()
      "console_friendremove_continue":
        me.setUpMassRemoveWindow()
      "console_friendremove_not_now", "console_friendremove_cancel_button":
        me.endMassRemovalSession()
      "console_friendremove_dropmenu":
        case tParam of
          "buddyremove_logintime":
            me.arrangeFriendList(#logintime)
          "buddyremove_alphabetical":
            me.arrangeFriendList(#name)
        end case
      "console_friendremove_select_all":
        me.selectAllFriends()
      "console_friendremove_invert":
        me.invertSelection()
      "console_friendremove_confirm_cancel":
        me.changeOptionLevel(#less)
    end case
    tLen = tElemID.char.count
    if tLen > 2 then
      if tElemID.char[1..21] = "friendremove_checkbox" then
        me.checkBoxClicked(tElemID)
      end if
      if tElemID.char[1..25] = "console_friendremove_name" then
        me.nameClicked(tElemID)
      end if
    end if
  end if
  if tEvent = #mouseDown then
    case tElemID of
      "close":
        me.endMassRemovalSession()
      "console_friendremove_moreoptions":
        me.changeOptionLevel(#more)
      "console_friendremove_lessoptions":
        me.changeOptionLevel(#less)
      "buddyremove_hc_more_info":
        openNetPage(getText("buddyremove_hc_info_url"))
    end case
  end if
end

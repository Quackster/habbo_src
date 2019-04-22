property pOnScreenNum, pRemoveCheckBoxList, pBuddyList, pLimitPntr, pWindowTitle, pPageCount, pPageNr, pChosen, pRemoveList, pArrangeType

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
  i = 1
  repeat while i <= pOnScreenNum
    pRemoveCheckBoxList.add(0)
    i = 1 + i
  end repeat
end

on deconstruct me 
end

on openRemoveWindow me, tFriendListCopy, tListLimitsPntr 
  pBuddyList = tFriendListCopy
  pLimitPntr = tListLimitsPntr
  pBuddyList.sort()
  if pBuddyList.ilk <> #propList or pLimitPntr.ilk <> #propList then
    return(0)
  end if
  if windowExists(pWindowTitle) then
    return(1)
  end if
  if not createWindow(pWindowTitle, "habbo_full.window", 0, 0, #modal) then
    return(error(me, "Failed to open Messenger window!!!", #openRemoveWindow))
  end if
  tWndObj = getWindow(pWindowTitle)
  if not tWndObj.merge("console_buddylistfull.window") then
    return(tWndObj.close())
  end if
  tElem = tWndObj.getElement("console_friendremove_list_full")
  tText = getText("buddyremove_list_full")
  tText = replaceChunks(tText, "%mylimit%", string(pLimitPntr.getProp(#own)))
  tText = replaceChunks(tText, "%clublimit%", string(pLimitPntr.getProp(#club)))
  if not getText("buddyremove_hc_info_url") starts "http" then
    tWndObj.getElement("buddyremove_hc_more_info").hide()
  end if
  tElem.setText(tText)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcBuddyRemove, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProcBuddyRemove, me.getID(), #mouseDown)
  tWndObj.center()
  return(1)
end

on confirmationReceived me 
  return(me.sendRemoveList())
end

on removeUnnecessaryFromBuddylist me 
  i = 1
  repeat while i <= pBuddyList.count
    pBuddyList.deleteProp(#customText)
    pBuddyList.deleteProp(#msgs)
    pBuddyList.deleteProp(#update)
    pBuddyList.deleteProp(#sex)
    pBuddyList.deleteProp(#location)
    pBuddyList.deleteProp(#online)
    i = 1 + i
  end repeat
  return(1)
end

on setUpMassRemoveWindow me 
  if not windowExists(pWindowTitle) then
    return(0)
  end if
  tWndObj = getWindow(pWindowTitle)
  tWndObj.unmerge()
  if not tWndObj.merge("console_massbuddyremove.window") then
    return(tWndObj.close())
  end if
  i = 1
  repeat while i <= pBuddyList.count
    pBuddyList.getAt(i).addProp(#Remove, 0)
    i = 1 + i
  end repeat
  pPageCount = pBuddyList.count / pOnScreenNum
  if pBuddyList.count mod pOnScreenNum <> 0 then
    pPageCount = pPageCount + 1
  end if
  me.arrangeFriendList(#name)
  return(1)
end

on changeOptionLevel me, tStyle 
  if not windowExists(pWindowTitle) then
    return(0)
  end if
  if tStyle = #more then
    tWndObj = getWindow(pWindowTitle)
    tWndObj.unmerge()
    if not tWndObj.merge("console_massremove_extended.window") then
      return(tWndObj.close())
    end if
  else
    if tStyle = #less then
      tWndObj = getWindow(pWindowTitle)
      tWndObj.unmerge()
      if not tWndObj.merge("console_massbuddyremove.window") then
        return(tWndObj.close())
      end if
    end if
  end if
  return(me.updateView())
end

on updateView me 
  if not windowExists(pWindowTitle) then
    return(0)
  end if
  tWndObj = getWindow(pWindowTitle)
  tStartNr = pPageNr - 1 * pOnScreenNum
  i = 1
  repeat while i <= pOnScreenNum
    tElem1ID = "console_friendremove_name" & i
    tElem2ID = "friendremove_checkbox" & i
    tElem1 = tWndObj.getElement(tElem1ID)
    tElem2 = tWndObj.getElement(tElem2ID)
    if tStartNr + i > pBuddyList.count then
      tElem1.hide()
      tElem2.hide()
    else
      tElem1.show()
      tElem2.show()
      tElem1.setText(pBuddyList.getAt(tStartNr + i).name)
      if not pBuddyList.getAt(tStartNr + i).Remove then
        pRemoveCheckBoxList.setAt(i, 0)
        me.updateCheckButton(tElem2ID, "button.checkbox.off")
      else
        pRemoveCheckBoxList.setAt(i, 1)
        me.updateCheckButton(tElem2ID, "button.checkbox.on")
      end if
    end if
    i = 1 + i
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
    return(0)
  end if
  tWndObj = getWindow(pWindowTitle)
  i = 1
  repeat while i <= pOnScreenNum
    tElem1 = tWndObj.getElement("console_friendremove_name" & i)
    tElem2 = tWndObj.getElement("friendremove_checkbox" & i)
    tElem1.hide()
    tElem2.hide()
    i = 1 + i
  end repeat
  return(1)
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
  return(me.checkBoxClicked(tid, #name))
end

on checkBoxClicked me, tid, ttype 
  if not windowExists(pWindowTitle) then
    return(0)
  end if
  if ttype = #name then
    tNum = integer(tid.getProp(#char, 26, tid.count(#char)))
  else
    tNum = integer(tid.getProp(#char, 22, tid.count(#char)))
  end if
  tStartNr = pPageNr - 1 * pOnScreenNum
  tBoxID = "friendremove_checkbox" & tNum
  if pRemoveCheckBoxList.getAt(tNum) = 0 then
    pRemoveCheckBoxList.setAt(tNum, 1)
    pBuddyList.getAt(tStartNr + tNum).Remove = 1
    pChosen = pChosen + 1
    me.updateCheckButton(tBoxID, "button.checkbox.on")
  else
    pRemoveCheckBoxList.setAt(tNum, 0)
    pBuddyList.getAt(tStartNr + tNum).Remove = 0
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
  return(me.updateToChooseCounter())
end

on updateToChooseCounter me 
  if not windowExists(pWindowTitle) then
    return(0)
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
  return(1)
end

on getStayCount me 
  tStay = 0
  i = 1
  repeat while i <= pBuddyList.count
    if not pBuddyList.getAt(i).Remove then
      tStay = tStay + 1
    end if
    i = 1 + i
  end repeat
  return(tStay)
end

on updateCheckButton me, tElementId, tMemName 
  if not windowExists(pWindowTitle) then
    return(0)
  end if
  tWndObj = getWindow(pWindowTitle)
  tNewImg = member(getmemnum(tMemName)).image
  if tWndObj.elementExists(tElementId) then
    tWndObj.getElement(tElementId).feedImage(tNewImg)
  end if
  return(1)
end

on endMassRemovalSession me, tHideMessenger 
  tWndObj = getWindow(pWindowTitle)
  if not tWndObj = void() then
    tWndObj.close()
  end if
  if objectExists("buddy_massremove") then
    removeObject("buddy_massremove")
  end if
  return(1)
end

on showConfirmationWindow me 
  tWndObj = getWindow(pWindowTitle)
  tWndObj.unmerge()
  if not tWndObj.merge("console_massremove_confirm.window") then
    return(tWndObj.close())
  end if
  tElem = tWndObj.getElement("console_friendremove_remove_text")
  tText = getText("buddyremove_remove_text")
  tText = replaceChunks(tText, "%removeamount%", string(pChosen))
  tText = replaceChunks(tText, "%amountleft%", string(pBuddyList.count - pChosen))
  tElem.setText(tText)
  tText = ""
  i = 1
  repeat while i <= pBuddyList.count
    if not pBuddyList.getAt(i).Remove then
      tText = tText & pBuddyList.getAt(i).name & ", "
    end if
    i = 1 + i
  end repeat
  tText = tText.getProp(#char, 1, tText.count(#char) - 2)
  tElem = tWndObj.getElement("console_friendremove_keep_list")
  tElem.setText(tText)
end

on commitRemove me 
  pRemoveList = []
  i = 1
  repeat while i <= pBuddyList.count
    if pBuddyList.getAt(i).Remove then
      pRemoveList.add(pBuddyList.getAt(i).id)
    end if
    i = 1 + i
  end repeat
  tWndObj = getWindow(pWindowTitle)
  if not tWndObj = void() then
    tWndObj.close()
  end if
  getThread(#messenger).getInterface().setMessengerInactive()
  return(me.sendRemoveList())
end

on sendRemoveList me 
  if pRemoveList = [] then
    getConnection(getVariable("connection.info.id")).send("MESSENGER_UPDATE", [#integer:0])
    return(me.endMassRemovalSession())
  end if
  tListSize = 400
  tCount = 0
  tSendList = [#integer:0]
  i = 1
  repeat while i <= tListSize
    tSendList.addProp(#integer, integer(pRemoveList.getAt(1)))
    pRemoveList.deleteAt(1)
    tCount = tCount + 1
    if pRemoveList = [] then
    else
      i = 1 + i
    end if
  end repeat
  tSendList.setAt(1, tCount)
  getConnection(getVariable("connection.info.id")).send("MESSENGER_REMOVEBUDDY", tSendList)
  return(1)
end

on arrangeFriendList me, ttype 
  if pArrangeType = ttype then
    return(0)
  end if
  if ttype = #logintime then
    me.showWaitIfNecessary()
  end if
  tNewList = [:]
  tTemp = the itemDelimiter
  the itemDelimiter = "-"
  i = 1
  repeat while i <= pBuddyList.count
    if ttype = #name then
      tNewList.addProp(pBuddyList.getAt(i).name, pBuddyList.getAt(i))
    else
      if ttype = #logintime then
        tTime = lastAccess.getProp(#word, 1)
        tArrangedTime = tTime.getProp(#item, 3) & tTime.getProp(#item, 2) & tTime.getProp(#item, 1)
        tNewList.addProp(tArrangedTime, pBuddyList.getAt(i))
      end if
    end if
    i = 1 + i
  end repeat
  tNewList.sort()
  the itemDelimiter = tTemp
  pBuddyList = tNewList.duplicate()
  pPageNr = 1
  pArrangeType = ttype
  me.updateView()
  return(1)
end

on showWaitIfNecessary me 
  if pBuddyList.count < 500 then
    return(1)
  end if
  if not windowExists(pWindowTitle) then
    return(0)
  end if
  tWndObj = getWindow(pWindowTitle)
  tElem = tWndObj.getElement("console_friendremove_header")
  tText = getText("buddyremove_pleasewait")
  tElem.setText(tText)
  me.hideNames()
  setcursor(#timer)
  updateStage()
  return(1)
end

on selectAllFriends me 
  i = 1
  repeat while i <= pBuddyList.count
    pBuddyList.getAt(i).Remove = 1
    i = 1 + i
  end repeat
  pChosen = pBuddyList.count
  me.updateView()
  return(1)
end

on invertSelection me 
  i = 1
  repeat while i <= pBuddyList.count
    pBuddyList.getAt(i).Remove = not pBuddyList.getAt(i).Remove
    i = 1 + i
  end repeat
  pChosen = pBuddyList.count - pChosen
  me.updateView()
  return(1)
end

on eventProcBuddyRemove me, tEvent, tElemID, tParam 
  if tEvent = #mouseUp then
    if tElemID = "console_friendremove_next" then
      me.nextPage()
    else
      if tElemID = "console_friendremove_prev" then
        me.prevPage()
      else
        if tElemID = "console_friendremove_accept_button" then
          me.showConfirmationWindow()
        else
          if tElemID = "console_friendremove_confirm" then
            me.commitRemove()
          else
            if tElemID = "console_friendremove_continue" then
              me.setUpMassRemoveWindow()
            else
              if tElemID <> "console_friendremove_not_now" then
                if tElemID = "console_friendremove_cancel_button" then
                  me.endMassRemovalSession()
                else
                  if tElemID = "console_friendremove_dropmenu" then
                    if tElemID = "buddyremove_logintime" then
                      me.arrangeFriendList(#logintime)
                    else
                      if tElemID = "buddyremove_alphabetical" then
                        me.arrangeFriendList(#name)
                      end if
                    end if
                  else
                    if tElemID = "console_friendremove_select_all" then
                      me.selectAllFriends()
                    else
                      if tElemID = "console_friendremove_invert" then
                        me.invertSelection()
                      else
                        if tElemID = "console_friendremove_confirm_cancel" then
                          me.changeOptionLevel(#less)
                        end if
                      end if
                    end if
                  end if
                end if
                tLen = tElemID.count(#char)
                if tLen > 2 then
                  if tElemID.getProp(#char, 1, 21) = "friendremove_checkbox" then
                    me.checkBoxClicked(tElemID)
                  end if
                  if tElemID.getProp(#char, 1, 25) = "console_friendremove_name" then
                    me.nameClicked(tElemID)
                  end if
                end if
                if tEvent = #mouseDown then
                  if tElemID = "close" then
                    me.endMassRemovalSession()
                  else
                    if tElemID = "console_friendremove_moreoptions" then
                      me.changeOptionLevel(#more)
                    else
                      if tElemID = "console_friendremove_lessoptions" then
                        me.changeOptionLevel(#less)
                      else
                        if tElemID = "buddyremove_hc_more_info" then
                          openNetPage(getText("buddyremove_hc_info_url"))
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

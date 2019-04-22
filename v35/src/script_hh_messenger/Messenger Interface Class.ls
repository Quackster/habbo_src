property pBuddylistItemHeight, pWriterID_nobuddies, pWriterID_consolemsg, pBuddyDrw_writerID_name, pBuddyDrw_writerID_msgs, pBuddyDrw_writerID_last, pBuddyDrw_writerID_text, pWindowTitle, pTimeOutID, pRequestRenderID, pMessengerInactive, pBuddyListLimits, pOpenWindow, pSelectedBuddies, pBuddyListPntr, pBuddyDrawObjList, pBuddyListBuffer, pBuddyDrawNum, pBuddyListBufferWidth, pRemoveBuddy, pLastSearch, pLastGetMsg, pComposeMsg, pLastOpenWindow

on construct me 
  pWindowTitle = getText("win_messenger", "Habbo Console")
  pBuddyListBufferWidth = 203
  pBuddylistItemHeight = 53
  if variableExists("messenger_friend_permsg_offset") then
    pBuddylistItemHeight = pBuddylistItemHeight + getVariable("messenger_friend_permsg_offset") + 1
  end if
  pLastOpenWindow = ""
  pSelectedBuddies = []
  pLastSearch = [:]
  pLastGetMsg = [:]
  pComposeMsg = ""
  pBuddyListPntr = void()
  pBuddyDrawObjList = [:]
  pRemoveBuddy = [:]
  pBuddyDrawNum = 1
  pCurrProf = []
  pMsgsStr = getText("console_msgs", "msgs")
  pFriendListSwitch = 1
  pMessengerInactive = 0
  pListRendering = 0
  pRequestRenderID = "ConsoleFriendRequestRenderer"
  pSelectionIsInverted = 0
  pBuddyListLimits = [#own:1000, #normal:1000, #club:1000]
  pWriterID_nobuddies = getUniqueID()
  pWriterID_consolemsg = getUniqueID()
  pBuddyDrw_writerID_name = getUniqueID()
  pBuddyDrw_writerID_msgs = getUniqueID()
  pBuddyDrw_writerID_last = getUniqueID()
  pBuddyDrw_writerID_text = getUniqueID()
  tPlain = getStructVariable("struct.font.plain")
  tBold = getStructVariable("struct.font.bold")
  tLink = getStructVariable("struct.font.link")
  tMetrics = [#font:tPlain.getaProp(#font), #fontStyle:tPlain.getaProp(#fontStyle), #color:rgb("#EEEEEE")]
  createWriter(pWriterID_nobuddies, tMetrics)
  tMetrics = [#font:tPlain.getaProp(#font), #fontStyle:tPlain.getaProp(#fontStyle), #color:rgb("#EEEEEE"), #fixedLineSpace:11, #wordWrap:1]
  createWriter(pWriterID_consolemsg, tMetrics)
  tMetrics = [#font:tBold.getaProp(#font), #fontStyle:tBold.getaProp(#fontStyle), #color:rgb("#EEEEEE")]
  createWriter(pBuddyDrw_writerID_name, tMetrics)
  tMetrics = [#font:tPlain.getaProp(#font), #fontStyle:tLink.getaProp(#fontStyle), #color:rgb("#EEEEEE")]
  createWriter(pBuddyDrw_writerID_msgs, tMetrics)
  tMetrics = [#font:tPlain.getaProp(#font), #fontStyle:tPlain.getaProp(#fontStyle), #color:rgb("#EEEEEE")]
  createWriter(pBuddyDrw_writerID_last, tMetrics)
  tMetrics = [#font:tPlain.getaProp(#font), #fontStyle:tPlain.getaProp(#fontStyle), #color:rgb("#EEEEEE")]
  createWriter(pBuddyDrw_writerID_text, tMetrics)
  pTimeOutID = "console_change_window_timeout"
  return(1)
end

on deconstruct me 
  if windowExists(pWindowTitle) then
    removeWindow(pWindowTitle)
  end if
  removeWriter(pWriterID_nobuddies)
  removeWriter(pWriterID_consolemsg)
  removeWriter(pBuddyDrw_writerID_name)
  removeWriter(pBuddyDrw_writerID_msgs)
  removeWriter(pBuddyDrw_writerID_last)
  removeWriter(pBuddyDrw_writerID_text)
  pBuddyDrawObjList = [:]
  removePrepare(me.getID())
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  if objectExists(pRequestRenderID) then
    removeObject(pRequestRenderID)
  end if
  return(1)
end

on showhidemessenger me 
  if windowExists(pWindowTitle) then
    return(me.hideMessenger())
  else
    return(me.showMessenger())
  end if
end

on showMessenger me 
  if pMessengerInactive then
    executeMessage(#alert, "buddyremove_messenger_updating")
    return(1)
  end if
  me.getComponent().send_BuddylistUpdate()
  executeMessage(#messengerOpened)
  if not windowExists(pWindowTitle) then
    me.ChangeWindowView("console_myinfo.window")
    return(1)
  else
    return(0)
  end if
end

on hideMessenger me 
  if windowExists(pWindowTitle) then
    me.getComponent().clearRequests()
    pOpenWindow = ""
    pLastOpenWindow = ""
    return(removeWindow(pWindowTitle))
  else
    return(0)
  end if
end

on setBuddyListLimits me, tOwn, tNormal, tClub 
  pBuddyListLimits.own = tOwn
  pBuddyListLimits.normal = tNormal
  pBuddyListLimits.club = tClub
  pBuddyListLimits.sort()
  return(1)
end

on getBuddyListLimits me 
  return(duplicate(pBuddyListLimits))
end

on setMessengerInactive me 
  pMessengerInactive = 1
  me.hideMessenger()
  me.getComponent().deleteAllMessages()
  me.getComponent().pause()
  return(1)
end

on setMessengerActive me 
  pMessengerInactive = 0
  me.getComponent().resume()
  return(1)
end

on isMessengerOpen me 
  if pOpenWindow = "" or voidp(pOpenWindow) then
    return(0)
  else
    return(1)
  end if
end

on isMessengerActive me 
  return(not pMessengerInactive)
end

on getSelectedBuddiesCount me 
  if listp(pSelectedBuddies) then
    return(pSelectedBuddies.count)
  else
    return(0)
  end if
end

on createBuddyList me, tBuddyListPntr 
  pBuddyListPntr = tBuddyListPntr
  pBuddyDrawObjList = [:]
  repeat while pBuddyListPntr.getaProp(#value).buddies <= undefined
    tdata = getAt(undefined, tBuddyListPntr)
    pBuddyDrawObjList.setAt(tdata.getAt(#name), me.createBuddyDrawObj(tdata))
  end repeat
  return(me.buildBuddyListImg())
end

on updateBuddyList me 
  call(#update, pBuddyDrawObjList)
  return(me.buildBuddyListImg())
end

on appendBuddy me, tdata 
  if voidp(pBuddyDrawObjList.getAt(tdata.getAt(#name))) then
    pBuddyDrawObjList.setAt(tdata.getAt(#name), me.createBuddyDrawObj(tdata))
  end if
  return(me.buildBuddyListImg())
end

on removeBuddy me, tID 
  if voidp(buddies.getaProp(tID)) then
    return(error(me, "Buddy data not found:" && tID, #removeBuddy, #minor))
  end if
  i = 1
  repeat while i <= pSelectedBuddies.count
    if pSelectedBuddies.getAt(i).getAt(#id) = tID then
      pSelectedBuddies.deleteAt(i)
    else
      i = 1 + i
    end if
  end repeat
  tName = buddies.getaProp(tID).name
  if voidp(pBuddyDrawObjList.getAt(tName)) then
    return(error(me, "Buddy renderer not found:" && tID, #removeBuddy, #minor))
  end if
  tPos = render.getPos(tName)
  if tPos = 0 then
    return(error(me, "Buddy renderer was lost:" && tID, #removeBuddy, #minor))
  end if
  pBuddyDrawObjList.deleteProp(tName)
  tW = pBuddyListBuffer.width
  tH = pBuddyListBuffer.height - pBuddylistItemHeight
  tD = pBuddyListBuffer.depth
  tImg = image(tW, tH, tD)
  tRect = rect(0, 0, tW, tPos - 1 * pBuddylistItemHeight)
  tImg.copyPixels(pBuddyListBuffer, tRect, tRect)
  tRect = rect(0, tPos * pBuddylistItemHeight, tW, pBuddyListBuffer.height)
  tImg.copyPixels(pBuddyListBuffer, tRect - [0, pBuddylistItemHeight, 0, pBuddylistItemHeight], tRect)
  pBuddyListBuffer = tImg
  return(me.updateBuddyListImg())
end

on updateFrontPage me 
  if windowExists(pWindowTitle) then
    if pOpenWindow = "console_myinfo.window" then
      tNumOfNewMsg = string(me.getComponent().getNumOfMessages()) && getText("console_newmessages", "new message(s)")
      tNumOfBuddyRequest = string(me.getComponent().getPendingRequestCount()) && getText("console_requests", "Friend Request(s)")
      tWndObj = getWindow(pWindowTitle)
      tWndObj.getElement("console_myinfo_messages_link").setText(tNumOfNewMsg)
      tWndObj.getElement("console_myinfo_requests_link").setText(tNumOfBuddyRequest)
    end if
  end if
end

on updateUserFind me, tMsg, tstate 
  if pOpenWindow <> "console_find.window" then
    return(0)
  end if
  tWinObj = getWindow(pWindowTitle)
  if tWinObj = 0 then
    return(0)
  end if
  if tstate then
    me.updateMyHeadPreview(tMsg.getAt(#FigureData), "console_search_habboface_image")
    pLastSearch = tMsg
    tUserName = tMsg.getAt(#name)
    tBuddyData = me.getComponent().getBuddyData()
    tBuddyAlreadyOnline = string(tBuddyData.online) contains "\"" & tUserName & "\""
    tBuddyAlreadyOffline = string(tBuddyData.offline) contains "\"" & tUserName & "\""
    tNotOwnUser = getObject(#session).GET("user_name") <> tUserName
    tBuddyButton = tWinObj.getElement("console_search_friendrequest_button")
    if not tBuddyAlreadyOnline and not tBuddyAlreadyOffline and tNotOwnUser then
      tBuddyButton.Activate()
      tBuddyButton.setProperty(#cursor, "cursor.finger")
    else
      tBuddyButton.deactivate()
      tBuddyButton.setProperty(#cursor, 0)
    end if
    tWinObj.getElement("console_magnifier").show()
    tWinObj.getElement("console_search_habbo_name_text").setText(tMsg.getAt(#name))
    tWinObj.getElement("console_search_habbo_mission_text").setText(tMsg.getAt(#customText))
    tWinObj.getElement("console_search_habbo_lasthere_text").setText(tMsg.getAt(#lastAccess))
    tlocation = tMsg.getAt(#location)
    if tMsg.getAt(#online) = 0 then
      tlocation = getText("console_offline")
    else
      if tlocation contains "Floor1" then
        tlocation = getText("console_online") && getText("console_inprivateroom")
      end if
      if tlocation contains "ENTERPRISESERVER" then
        tlocation = getText("console_online") && getText("console_onfrontpage")
      end if
    end if
    return(tWinObj.getElement("console_search_habbo_online_text").setText(tlocation))
  else
    pLastSearch = [:]
    tMsg = getText("console_usersnotfound")
    tWinObj.getElement("console_search_friendrequest_button").deactivate()
    tWinObj.getElement("console_search_friendrequest_button").setProperty(#cursor, 0)
    tWinObj.getElement("console_magnifier").hide()
    tWinObj.getElement("console_search_habbo_name_text").setText(tMsg)
    tWinObj.getElement("console_search_habbo_mission_text").setText("")
    tWinObj.getElement("console_search_habbo_lasthere_text").setText("")
    tWinObj.getElement("console_search_habbo_online_text").setText("")
    return(1)
  end if
end

on prepare me 
  if pBuddyListPntr.getaProp(#value).render = [] then
    return(1)
  end if
  tName = render.getAt(pBuddyDrawNum)
  pBuddyDrawObjList.getAt(tName).render(pBuddyListBuffer, pBuddyDrawNum)
  pBuddyDrawNum = pBuddyDrawNum + 1
  if pBuddyDrawNum > pBuddyListPntr.getaProp(#value).count(#render) then
    removePrepare(me.getID())
    pListRendering = 0
    tWndObj = getWindow(pWindowTitle)
    if tWndObj <> 0 and pOpenWindow = "console_friends.window" then
      me.updateBuddyListImg()
    end if
  end if
end

on createBuddyDrawObj me, tdata 
  tObject = createObject(#temp, "Draw Friend Class")
  tProps = [:]
  tProps.setAt(#width, pBuddyListBufferWidth)
  tProps.setAt(#height, pBuddylistItemHeight)
  tProps.setAt(#writer_name, pBuddyDrw_writerID_name)
  tProps.setAt(#writer_msgs, pBuddyDrw_writerID_msgs)
  tProps.setAt(#writer_last, pBuddyDrw_writerID_last)
  tProps.setAt(#writer_text, pBuddyDrw_writerID_text)
  tObject.define(tdata, tProps)
  return(tObject)
end

on buildBuddyListImg me 
  pBuddyDrawNum = 1
  if pBuddyListPntr.getaProp(#value).count(#buddies) = 0 then
    pBuddyListBuffer = image(pBuddyListBufferWidth, pBuddylistItemHeight, 8)
    tWndObj = getWindow(pWindowTitle)
    if tWndObj <> "" and pOpenWindow = "console_friends.window" then
      tElement = tWndObj.getElement("console_friends_friendlist")
      tElement.clearImage()
      tElement.feedImage(pBuddyListBuffer)
    end if
    return(0)
  else
    pListRendering = 1
    pBuddyListBuffer = image(pBuddyListBufferWidth, pBuddyListPntr.getaProp(#value).count(#buddies) * pBuddylistItemHeight, 8)
    return(receivePrepare(me.getID()))
  end if
end

on enterFriendRequestList me 
  tRenderer = me.getFriendRequestRenderer()
  tRenderer.Init(pWindowTitle)
end

on getFriendRequestRenderer me 
  if not objectExists(pRequestRenderID) then
    createObject(pRequestRenderID, "Friend Request Renderer Class")
  end if
  tRenderer = getObject(pRequestRenderID)
  return(tRenderer)
end

on updateRequests me 
  if pOpenWindow <> "console_request_list.window" then
    return(0)
  end if
  tRenderer = me.getFriendRequestRenderer()
  tRenderer.updateView()
end

on updateBuddyListImg me 
  if voidp(pBuddyListBuffer) then
    return(0)
  end if
  if pOpenWindow <> "console_friends.window" then
    return(0)
  end if
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return(0)
  end if
  return(tWndObj.getElement("console_friends_friendlist").feedImage(pBuddyListBuffer))
end

on updateRadioButton me, tElement, tListOfOthersElements 
  tOnImg = member(getmemnum("messenger_radio_on")).image
  tOffImg = member(getmemnum("messenger_radio_off")).image
  tWinObj = getWindow(pWindowTitle)
  if tWinObj.elementExists(tElement) then
    tWinObj.getElement(tElement).feedImage(tOnImg)
  end if
  repeat while tListOfOthersElements <= tListOfOthersElements
    tRadioElement = getAt(tListOfOthersElements, tElement)
    if tWinObj.elementExists(tRadioElement) then
      tWinObj.getElement(tRadioElement).feedImage(tOffImg)
    end if
  end repeat
end

on updateMyHeadPreview me, tFigure, tElement 
  me.createHeadPreview(tElement, tFigure)
end

on createHeadPreview me, tElemID, tFigure 
  if objectExists("Figure_Preview") then
    getObject("Figure_Preview").createHumanPartPreview(pWindowTitle, tElemID, #head, tFigure)
  end if
end

on buddySelectOrNot me, tName, tID, tstate 
  tdata = [#name:tName, #id:tID]
  if tstate then
    pSelectedBuddies.add(tdata)
  else
    tPos = pSelectedBuddies.findPos(tdata)
    if tPos > 0 then
      pSelectedBuddies.deleteAt(tPos)
    end if
  end if
  if pOpenWindow <> "console_friends.window" then
    return()
  end if
  tWndObj = getWindow(pWindowTitle)
  if pSelectedBuddies.count > 0 then
    tWndObj.getElement("messenger_friends_compose_button").Activate()
    tWndObj.getElement("messenger_friends_remove_button").Activate()
  else
    tWndObj.getElement("messenger_friends_compose_button").deactivate()
    tWndObj.getElement("messenger_friends_remove_button").deactivate()
  end if
end

on getSelectedBuddiesStr me, tProp, tItemDeLim 
  if voidp(pSelectedBuddies) then
    return("")
  end if
  if pSelectedBuddies.count = 0 then
    return("")
  end if
  tStr = ""
  f = 1
  repeat while f <= pSelectedBuddies.count
    tStr = tStr & pSelectedBuddies.getAt(f).getAt(tProp) & tItemDeLim
    f = 1 + f
  end repeat
  tStr = tStr.getProp(#char, 1, length(tStr) - length(tItemDeLim))
  return(tStr)
end

on renderMessage me, tMsgStruct 
  pActiveMessage = tMsgStruct
  if not listp(tMsgStruct) then
    return(error(me, "Invalid message struct:" && tMsgStruct, #renderMessage, #major))
  end if
  if pOpenWindow <> "console_getmessage.window" then
    me.ChangeWindowView("console_getmessage.window")
  end if
  pLastGetMsg = tMsgStruct
  tMsg = tMsgStruct.getAt(#message)
  tTime = tMsgStruct.getAt(#time)
  tSenderId = tMsgStruct.getAt(#senderID)
  tWndObj = getWindow(pWindowTitle)
  if tMsgStruct.getAt(#campaign) = 1 then
    me.ChangeWindowView("console_officialmessage.window")
    tWndObj.getElement("console_official_message").setText(tMsg)
    tWndObj.getElement("console_safety_info").setText(tMsgStruct.getAt(#link))
    tWndObj.getElement("console_safety_info").setaProp(#pLinkTarget, tMsgStruct.getAt(#url))
    tmessageId = tMsgStruct.getAt(#id)
    return(1)
  end if
  tdata = buddies.getaProp(tSenderId)
  tMessageIsValid = 1
  if not voidp(tdata) then
    tSenderName = tdata.name
  else
    tSenderName = getText("console_unknown_sender")
    tMsg = getText("console_invalid_message")
    tMessageIsValid = 0
  end if
  if objectExists("Figure_System") and tMessageIsValid then
    tFigure = getObject("Figure_System").parseFigure(tdata.getAt(#FigureData), tdata.getAt(#sex))
    me.updateMyHeadPreview(tFigure, "console_getmessage_face_image")
  end if
  tFrom = getText("console_getmessage_sender") && tSenderName & "\r" & tTime
  tWndObj.getElement("console_getmessage_sender").setText(tFrom)
  tElem = tWndObj.getElement("console_getmessage_follow")
  if tMessageIsValid then
    tOnline = tdata.getaProp(#online)
    tlocation = tdata.getaProp(#location)
    if not tOnline or tlocation = getText("console_onfrontpage") then
      tElem.hide()
    else
      tElem.show()
    end if
  else
    tElem.hide()
  end if
  tElem = tWndObj.getElement("console_getmessage_field")
  tRect = rect(0, 0, tElem.pwidth, tElem.pheight)
  tElem.feedImage(getWriter(pWriterID_consolemsg).render(tMsg, tRect))
  pSelectedBuddies = []
  call(#unselect, pBuddyDrawObjList)
  me.buddySelectOrNot(tSenderName, tSenderId, 1)
  return(1)
end

on openBuddyMassremoveWindow me 
  me.ChangeWindowView("console_myinfo.window")
  if objectp(createObject("buddy_massremove", "Buddy Massremove Class")) then
    pBuddyListPntr.getaProp(#value).openRemoveWindow(buddies.duplicate(), pBuddyListLimits)
    return(1)
  else
    return(0)
  end if
end

on ChangeWindowView me, tWindowName 
  tWndObj = getWindow(pWindowTitle)
  if objectp(tWndObj) then
    if pOpenWindow = "console_myinfo.window" then
      tMessage = tWndObj.getElement("console_myinfo_mission_field").getText()
      me.getComponent().send_PersistentMsg(tMessage)
    end if
    tWndObj.unmerge()
  else
    if not createWindow(pWindowTitle, "habbo_messenger.window") then
      return(error(me, "Failed to open Messenger window!!!", #ChangeWindowView, #major))
    else
      tWndObj = getWindow(pWindowTitle)
      tWndObj.registerClient(me.getID())
      tWndObj.registerProcedure(#eventProcMessenger, me.getID(), #mouseUp)
      tWndObj.registerProcedure(#eventProcMessenger, me.getID(), #mouseDown)
      tWndObj.registerProcedure(#eventProcMessenger, me.getID(), #keyDown)
      tWndObj.registerProcedure(#eventProcMessenger, me.getID(), #mouseWithin)
      tWndObj.registerProcedure(#eventProcMessenger, me.getID(), #mouseLeave)
    end if
  end if
  if not tWndObj.merge(tWindowName) then
    tWndObj.close()
    return(error(me, "Failed to open Messenger window!!!", #ChangeWindowView, #major))
  end if
  pLastOpenWindow = pOpenWindow
  pOpenWindow = tWindowName
  if tWindowName = "console_myinfo.window" then
    pSelectedBuddies = []
    me.updateMyHeadPreview(getObject(#session).GET("user_figure"), "console_myhead_image")
    tName = getObject(#session).GET("user_name")
    tNewMsgCount = string(me.getComponent().getNumOfMessages()) && getText("console_newmessages", "new message(s)")
    tNewReqCount = string(me.getComponent().getPendingRequestCount()) && getText("console_requests", "Friend Request(s)")
    tMission = me.getComponent().getMyPersistenMsg()
    tWndObj.getElement("console_myinfo_name").setText(tName)
    tWndObj.getElement("console_myinfo_mission_field").setText(tMission)
    tWndObj.getElement("console_myinfo_messages_link").setText(tNewMsgCount)
    tWndObj.getElement("console_myinfo_requests_link").setText(tNewReqCount)
    me.getComponent().clearRequests()
  else
    if tWindowName = "console_getmessage.window" then
      pLastGetMsg = [:]
    else
      if tWindowName = "console_friends.window" then
        pSelectedBuddies = []
        tRenderList = pBuddyListPntr.getaProp(#value).render
        if tRenderList.count > 0 then
          if pBuddyDrawNum >= tRenderList.count then
            call(#unselect, pBuddyDrawObjList)
            i = 1
            repeat while i <= tRenderList.count
              pBuddyDrawObjList.getAt(tRenderList.getAt(i)).render(pBuddyListBuffer, i)
              i = 1 + i
            end repeat
          end if
          me.updateBuddyListImg()
        else
          tImg = getWriter(pWriterID_nobuddies).render(getText("console_youdonthavebuddies"))
          getWindow(pWindowTitle).getElement("console_friends_friendlist").feedImage(tImg)
        end if
        tElem = tWndObj.getElement("console_select_friend_field")
        if tElem <> 0 then
          tElem.moveTo(2000, 2000)
          the keyboardFocusSprite = tElem.getProperty(#sprite).spriteNum
        end if
        if timeoutExists(pTimeOutID) then
          removeTimeout(pTimeOutID)
        end if
        createTimeout(pTimeOutID, 100, #changeWindowDelayedUpdate, me.getID(), void(), 1)
      else
        if tWindowName = "console_request_list.window" then
          me.enterFriendRequestList()
        else
          if tWindowName = "console_request_massoperations.window" then
            tMessageCount = me.getComponent().getPendingRequestCount()
            tTitleText = getText("console_request_massoperation_title")
            tTitleText = replaceChunks(tTitleText, "%messageCount%", string(tMessageCount))
            tWndObj = getWindow(pWindowTitle)
            tElem = tWndObj.getElement("console_request_massoperation_title")
            tElem.setText(tTitleText)
          else
            if tWindowName = "console_compose.window" then
              if pSelectedBuddies.count = 0 then
                return(me.ChangeWindowView("console_friends.window"))
              end if
              pComposeMsg = ""
              tWinObj = getWindow(pWindowTitle)
              tSelectedBuddies = me.getSelectedBuddiesStr(#name, "," & space())
              tWndObj.getElement("console_compose_recipients").setText(tSelectedBuddies)
            else
              if tWindowName = "console_removefriend.window" then
                if pSelectedBuddies.count > 0 then
                  pRemoveBuddy = pSelectedBuddies.getAt(1)
                  pSelectedBuddies.deleteAt(1)
                  tWndObj.getElement("console_removefriend_name").setText(pRemoveBuddy.getAt(#name))
                end if
                if pBuddyDrawObjList.count > 0 then
                  call(#unselect, pBuddyDrawObjList)
                end if
              else
                if tWindowName = "console_find.window" then
                  pLastSearch = [:]
                  tWndObj.getElement("console_magnifier").hide()
                  tWndObj.getElement("console_search_friendrequest_button").deactivate()
                  tWndObj.getElement("console_search_friendrequest_button").setProperty(#cursor, 0)
                else
                  if tWindowName = "console_sentrequest.window" then
                    tWndObj.getElement("console_request_habbo_name_text").setText(pLastSearch.getAt(#name))
                  else
                    if tWindowName = "console_reportmessage.window" then
                    else
                      if tWindowName = "console_main_help.window" then
                      else
                        if tWindowName = "console_messagemodes_help.window" then
                        else
                          if tWindowName = "console_friends_help.window" then
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
  end if
end

on changeWindowDelayedUpdate me 
  if pOpenWindow = "console_friends.window" then
    tElem = getWindow(pWindowTitle).getElement("console_select_friend_field")
    if tElem <> 0 then
      the keyboardFocusSprite = tElem.getProperty(#sprite).spriteNum
    end if
  end if
end

on getBuddyListName me, tpoint 
  if ilk(tpoint) <> #point then
    return(0)
  end if
  tRenderList = pBuddyListPntr.getaProp(#value).render
  if tRenderList.count = 0 then
    return(0)
  end if
  tLine = integer(tpoint.locV / pBuddylistItemHeight) + 1
  if tLine < 1 then
    return(0)
  end if
  if tLine > tRenderList.count then
    return(0)
  end if
  return(tRenderList.getAt(tLine))
end

on getBuddyListPoint me, tpoint 
  return(point(tpoint.locH, tpoint.locV mod pBuddylistItemHeight))
end

on eventProcMessenger me, tEvent, tElemID, tParm 
  if tEvent = #mouseDown then
    if tElemID = "console.myinfo.button" then
      me.ChangeWindowView("console_myinfo.window")
    else
      if tElemID = "console.myfriends.button" then
        me.ChangeWindowView("console_friends.window")
      else
        if tElemID = "console.find.button" then
          me.ChangeWindowView("console_find.window")
          executeMessage(#tutorial_console_find_button_clicked)
        else
          if tElemID = "console.help.button" then
            me.ChangeWindowView("console_main_help.window")
          else
            if tElemID = "console_myinfo_messages_link" then
              if me.getComponent().getNumOfMessages() > 0 then
                me.renderMessage(me.getComponent().getNextMessage())
              end if
            else
              if tElemID = "console_myinfo_requests_link" then
                if me.getComponent().getPendingRequestCount() = 0 then
                  return()
                end if
                me.ChangeWindowView("console_request_list.window")
              else
                if tElemID = "console_friends_friendlist" then
                  if tParm.ilk <> #point then
                    return(0)
                  end if
                  tRenderList = pBuddyListPntr.getaProp(#value).render
                  if tRenderList.count = 0 then
                    return(0)
                  end if
                  tClickLine = integer(tParm.locV / pBuddylistItemHeight)
                  if tClickLine < 0 then
                    return(0)
                  end if
                  if tClickLine > tRenderList.count - 1 then
                    return(0)
                  end if
                  if not the doubleClick then
                    tPosition = tClickLine + 1
                    tpoint = tParm - [0, tClickLine * pBuddylistItemHeight]
                    tName = tRenderList.getAt(tPosition)
                    pBuddyDrawObjList.getAt(tName).clickAt(tpoint, pBuddyListBuffer, tClickLine)
                    me.updateBuddyListImg()
                    tElem = getWindow(pWindowTitle).getElement("console_select_friend_field")
                    if tElem <> 0 then
                      the keyboardFocusSprite = tElem.getProperty(#sprite).spriteNum
                    end if
                  else
                    me.ChangeWindowView("console_compose.window")
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  else
    if tEvent = #mouseUp then
      if tElemID contains "request_accept" then
        tItemNo = integer(tElemID.getProp(#char, tElemID.length))
        me.getFriendRequestRenderer().confirmRequest(tItemNo, 1)
      end if
      if tElemID contains "request_decline" then
        tItemNo = integer(tElemID.getProp(#char, tElemID.length))
        me.getFriendRequestRenderer().confirmRequest(tItemNo, 0)
      end if
      if tElemID contains "request_name" then
        tItemNo = integer(tElemID.getProp(#char, tElemID.length))
        tUserID = me.getFriendRequestRenderer().getUserId(tItemNo)
        tHomepageURL = getVariable("link.format.userpage")
        tHomepageURL = replaceChunks(tHomepageURL, "%ID%", tUserID)
        openNetPage(tHomepageURL)
      end if
      if tElemID = "close" then
        tWndObj = getWindow(pWindowTitle)
        if objectp(tWndObj) then
          if pOpenWindow = "console_myinfo.window" and tWndObj.elementExists("console_myinfo_mission_field") then
            tMessage = tWndObj.getElement("console_myinfo_mission_field").getText().getProp(#line, 1)
            me.getComponent().send_PersistentMsg(tMessage)
          end if
        end if
        me.hideMessenger()
      else
        if tElemID = "console_fr_previous" then
          me.getFriendRequestRenderer().showPreviousPage()
        else
          if tElemID = "console_fr_next" then
            me.getFriendRequestRenderer().showNextPage()
          else
            if tElemID = "console_report_remove" then
              tMsgStruct = me.getComponent().getNextMessage()
              if listp(tMsgStruct) then
                me.getComponent().send_RemoveBuddy(integer(tMsgStruct.getAt(#senderID)))
                me.ChangeWindowView("console_friends.window")
              end if
            else
              if tElemID = "console_report_report" then
                tMsgStruct = me.getComponent().getNextMessage()
                me.ChangeWindowView("console_friends.window")
                me.getComponent().send_reportMessage(integer(tMsgStruct.getAt(#id)))
              else
                if tElemID = "console_report_cancel" then
                  if me.getComponent().getNumOfMessages() > 0 then
                    if me.getComponent().getMessageUpdateRequired() then
                      me.getComponent().send_AskForMessages()
                    end if
                    me.renderMessage(me.getComponent().getNextMessage())
                  end if
                else
                  if tElemID = "console_getmessage_follow" then
                    tID = integer(pLastGetMsg.getaProp(#senderID))
                    if voidp(pLastGetMsg.getAt(#senderID)) then
                      return(0)
                    end if
                    tConn = getConnection(getVariable("connection.info.id"))
                    tConn.send("FOLLOW_FRIEND", [#integer:tID])
                  else
                    if tElemID = "console_getmessage_reply" then
                      if voidp(pLastGetMsg.getAt(#id)) then
                        return(0)
                      end if
                      me.getComponent().send_MessageMarkRead(pLastGetMsg.getAt(#id), pLastGetMsg.getAt(#senderID))
                      me.ChangeWindowView("console_compose.window")
                    else
                      if tElemID = "console_getmessage_next" then
                        if voidp(pLastGetMsg.getAt(#id)) then
                          return(0)
                        end if
                        me.getComponent().send_MessageMarkRead(pLastGetMsg.getAt(#id), pLastGetMsg.getAt(#senderID), pLastGetMsg.getAt(#campaign))
                        if me.getComponent().getNumOfMessages() > 0 then
                          me.renderMessage(me.getComponent().getNextMessage())
                        else
                          if me.getComponent().getMessageUpdateRequired() then
                            me.getComponent().send_AskForMessages()
                          end if
                          me.ChangeWindowView("console_myinfo.window")
                        end if
                      else
                        if tElemID = "console_getmessage_report" then
                          me.ChangeWindowView("console_reportmessage.window")
                        else
                          if tElemID = "friend_request_options_button" then
                            me.ChangeWindowView("console_request_massoperations.window")
                          else
                            if tElemID = "friend_request_ok_button" then
                              me.ChangeWindowView("console_myinfo.window")
                            else
                              if tElemID = "console_fr_accept_all" then
                                me.getComponent().acceptAllRequests()
                                me.ChangeWindowView("console_myinfo.window")
                              else
                                if tElemID = "console_fr_decline_all" then
                                  me.getComponent().declineAllRequests()
                                  me.ChangeWindowView("console_myinfo.window")
                                else
                                  if tElemID = "friend_request_mass_operation_cancel" then
                                    me.ChangeWindowView("console_request_list.window")
                                  else
                                    if tElemID = "messenger_friends_compose_button" then
                                      if pSelectedBuddies.count < 1 then
                                        return(0)
                                      end if
                                      me.ChangeWindowView("console_compose.window")
                                    else
                                      if tElemID = "console_compose_send" then
                                        if pSelectedBuddies.count < 1 then
                                          if me.getComponent().getMessageUpdateRequired() then
                                            me.getComponent().send_AskForMessages()
                                          end if
                                          me.ChangeWindowView("console_myinfo.window")
                                          return(0)
                                        end if
                                        pComposeMsg = getWindow(pWindowTitle).getElement("console_compose_message_field").getText()
                                        me.getComponent().send_Message(pSelectedBuddies, pComposeMsg)
                                        if pLastOpenWindow = "console_friends.window" then
                                          me.ChangeWindowView("console_friends.window")
                                        else
                                          me.ChangeWindowView("console_myinfo.window")
                                        end if
                                      else
                                        if tElemID = "console_compose_cancel" then
                                          if pLastOpenWindow = "console_friends.window" then
                                            me.ChangeWindowView("console_friends.window")
                                          else
                                            me.ChangeWindowView("console_myinfo.window")
                                          end if
                                        else
                                          if tElemID = "messenger_friends_remove_button" then
                                            me.ChangeWindowView("console_removefriend.window")
                                          else
                                            if tElemID = "console_friendrequest_remove" then
                                              if voidp(pRemoveBuddy) or pRemoveBuddy = "" then
                                                return()
                                              end if
                                              me.getComponent().send_RemoveBuddy(integer(pRemoveBuddy.getAt(#id)))
                                              if pSelectedBuddies.count < 1 then
                                                me.ChangeWindowView("console_friends.window")
                                              else
                                                me.ChangeWindowView("console_removefriend.window")
                                              end if
                                            else
                                              if tElemID = "console_getfriendrequest_cancel" then
                                                if pSelectedBuddies.count < 1 then
                                                  me.ChangeWindowView("console_friends.window")
                                                else
                                                  me.ChangeWindowView("console_removefriend.window")
                                                end if
                                              else
                                                if tElemID = "console_compose_help_button" then
                                                  pComposeMsg = getWindow(pWindowTitle).getElement("console_compose_message_field").getText()
                                                  me.ChangeWindowView("console_messagemodes_help.window")
                                                else
                                                  if tElemID = "console_messagemode_back" then
                                                    if voidp(pComposeMsg) then
                                                      return(0)
                                                    end if
                                                    me.ChangeWindowView("console_compose.window")
                                                    getWindow(pWindowTitle).getElement("console_compose_message_field").setText(pComposeMsg)
                                                  else
                                                    if tElemID = "console_search_search_button" then
                                                      tQuery = getWindow(pWindowTitle).getElement("console_search_key_field").getText()
                                                      me.getComponent().send_FindUser(tQuery)
                                                      getWindow(pWindowTitle).getElement("console_search_key_field").setText("")
                                                    else
                                                      if tElemID = "console_search_friendrequest_button" then
                                                        executeMessage(#tutorial_console_friendrequest_button_clicked)
                                                        tListLimits = getBuddyListLimits()
                                                        tLimit = tListLimits.getAt(#own)
                                                        tBuddyData = me.getComponent().getBuddyData()
                                                        tBuddyCount = tBuddyData.getAt(#buddies).count
                                                        if tBuddyCount >= tLimit then
                                                          tClubLimit = tListLimits.getAt(#club)
                                                          tMessage = getText("buddyremove_list_full")
                                                          tMessage = replaceChunks(tMessage, "%mylimit%", tLimit)
                                                          tMessage = replaceChunks(tMessage, "%clublimit%", tClubLimit)
                                                          executeMessage(#alert, [#Msg:tMessage])
                                                        else
                                                          if voidp(pLastSearch.getAt(#name)) then
                                                            return(0)
                                                          end if
                                                          me.getComponent().send_RequestBuddy(pLastSearch.getAt(#name))
                                                          me.ChangeWindowView("console_sentrequest.window")
                                                        end if
                                                      else
                                                        if tElemID = "console_friendrequest_ok" then
                                                          me.ChangeWindowView("console_find.window")
                                                        else
                                                          if tElemID = "console_friends_help_button" then
                                                            me.ChangeWindowView("console_friends_help.window")
                                                          else
                                                            if tElemID = "console_friends_help_backbutton" then
                                                              me.ChangeWindowView("console_friends.window")
                                                            else
                                                              if tElemID = "console_safety_info" then
                                                                getConnection(getVariable("connection.info.id")).send("MESSENGER_C_CLICK", [#integer:integer(pLastGetMsg.getAt(#id))])
                                                                openNetPage(getWindow(pWindowTitle).getElement(tElemID).getaProp(#pLinkTarget))
                                                              else
                                                                if tElemID = "console_official_exit" then
                                                                  getConnection(getVariable("connection.info.id")).send("MESSENGER_C_READ", [#string:integer(pLastGetMsg.getAt(#id))])
                                                                  me.ChangeWindowView("console_myinfo.window")
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
                end if
              end if
            end if
          end if
        end if
      end if
    else
      if tEvent = #keyDown then
        if pOpenWindow = "console_myinfo.window" and tElemID = "console_myinfo_mission_field" and the key = "\r" then
          tWndObj = getWindow(pWindowTitle)
          tMessage = tWndObj.getElement("console_myinfo_mission_field").getText()
          me.getComponent().send_PersistentMsg(tMessage)
          return(1)
        end if
        if tElemID = "console_search_key_field" then
          if the key = "\r" then
            tElem = getWindow(pWindowTitle).getElement(tElemID)
            tQuery = tElem.getText()
            me.getComponent().send_FindUser(tQuery)
            tElem.setText("")
            return(1)
          end if
        end if
        if tElemID = "console_select_friend_field" then
          tElem = getWindow(pWindowTitle).getElement(tElemID)
          tElem.setText("")
          tElem = getWindow(pWindowTitle).getElement("friendlist_scrollbar")
          if tElemID = 126 then
            tElem.setScrollOffset(tElem.getProperty(#offset) - tElem.getProperty(#scrollStep))
          else
            if tElemID = 125 then
              tElem.setScrollOffset(tElem.getProperty(#offset) + tElem.getProperty(#scrollStep))
            end if
          end if
          if charToNum(the key) >= 32 and charToNum(the key) <> 127 then
            tBuddyList = me.getComponent().getBuddyData().getAt(#render)
            i = 1
            repeat while i <= tBuddyList.count()
              tBuddy = tBuddyList.getAt(i)
              if tBuddy.getProp(#char, 1) = the key then
                tScrollRange = tElem.getProperty(#scrollrange)
                tElem.setScrollOffset(tScrollRange * i - 1 / tBuddyList.count())
              else
                if tBuddy.getProp(#char, 1) > the key then
                  tScrollRange = tElem.getProperty(#scrollrange)
                  tElem.setScrollOffset(tScrollRange * i - 2 / tBuddyList.count())
                else
                  if i = tBuddyList.count() then
                    tScrollRange = tElem.getProperty(#scrollrange)
                    tElem.setScrollOffset(tScrollRange * i - 1 / tBuddyList.count())
                  else
                    i = 1 + i
                  end if
                  if tEvent = #mouseWithin then
                    if tElemID = "console_friends_friendlist" then
                      if tParm.ilk <> #point then
                        return(0)
                      end if
                      tBuddyName = me.getBuddyListName(tParm)
                      if tBuddyName = 0 then
                        return(0)
                      end if
                      tBuddyPoint = me.getBuddyListPoint(tParm)
                      tWindowRef = getWindow(pWindowTitle)
                      tElemRef = tWindowRef.getElement(tElemID)
                      if voidp(pBuddyDrawObjList.getAt(tBuddyName)) then
                        return(0)
                      end if
                      if pBuddyDrawObjList.getAt(tBuddyName).checkLinks(tBuddyPoint) then
                        tElemRef.setProperty(#cursor, "cursor.finger")
                      else
                        tElemRef.setProperty(#cursor, 0)
                      end if
                    else
                      nothing()
                    end if
                  else
                    if tEvent = #mouseLeave then
                      if tElemID = "console_friends_friendlist" then
                        tWindowRef = getWindow(pWindowTitle)
                        tElemRef = tWindowRef.getElement(tElemID)
                        tElemRef.setProperty(#cursor, 0)
                      else
                        nothing()
                      end if
                    end if
                  end if
                end if
              end if
            end repeat
          end if
        end if
      end if
    end if
  end if
end

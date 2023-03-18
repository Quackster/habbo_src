property pWindowTitle, pOpenWindow, pLastOpenWindow, pRoomProps, pBuddyListPntr, pSelectedBuddies, pBuddyListBuffer, pBuddyListBufferWidth, pBuddylistItemHeight, pBuddyDrawObjList, pLastSearch, pLastGetMsg, pComposeMsg, pBodyPartObjects, pRemoveBuddy, pBuddyDrawNum, pCurrProf, pMsgsStr, pFriendListSwitch, pFriendListObjs, pBuddyListLimits, pMessengerInactive, pListRendering, pActiveMessage, pWriterID_nobuddies, pWriterID_consolemsg, pBuddyDrw_writerID_name, pBuddyDrw_writerID_msgs, pBuddyDrw_writerID_last, pBuddyDrw_writerID_text, pTimeOutID, pRequestRenderID, pSelectionIsInverted

on construct me
  pWindowTitle = getText("win_messenger", "Habbo Console")
  pBuddyListBufferWidth = 203
  pBuddylistItemHeight = 40
  if variableExists("messenger_friend_permsg_offset") then
    pBuddylistItemHeight = pBuddylistItemHeight + getVariable("messenger_friend_permsg_offset") + 1
  end if
  pLastOpenWindow = EMPTY
  pSelectedBuddies = []
  pLastSearch = [:]
  pLastGetMsg = [:]
  pComposeMsg = EMPTY
  pBuddyListPntr = VOID
  pBuddyDrawObjList = [:]
  pRemoveBuddy = [:]
  pBodyPartObjects = [:]
  pBuddyDrawNum = 1
  pCurrProf = []
  pMsgsStr = getText("console_msgs", "msgs")
  pFriendListSwitch = 1
  pMessengerInactive = 0
  pListRendering = 0
  pRequestRenderID = "ConsoleFriendRequestRenderer"
  pSelectionIsInverted = 0
  pBuddyListLimits = [#own: 1000, #normal: 1000, #club: 1000]
  pWriterID_nobuddies = getUniqueID()
  pWriterID_consolemsg = getUniqueID()
  pBuddyDrw_writerID_name = getUniqueID()
  pBuddyDrw_writerID_msgs = getUniqueID()
  pBuddyDrw_writerID_last = getUniqueID()
  pBuddyDrw_writerID_text = getUniqueID()
  tPlain = getStructVariable("struct.font.plain")
  tBold = getStructVariable("struct.font.bold")
  tLink = getStructVariable("struct.font.link")
  tMetrics = [#font: tPlain.getaProp(#font), #fontStyle: tPlain.getaProp(#fontStyle), #color: rgb("#EEEEEE")]
  createWriter(pWriterID_nobuddies, tMetrics)
  tMetrics = [#font: tPlain.getaProp(#font), #fontStyle: tPlain.getaProp(#fontStyle), #color: rgb("#EEEEEE"), #fixedLineSpace: 11, #wordWrap: 1]
  createWriter(pWriterID_consolemsg, tMetrics)
  tMetrics = [#font: tBold.getaProp(#font), #fontStyle: tBold.getaProp(#fontStyle), #color: rgb("#EEEEEE")]
  createWriter(pBuddyDrw_writerID_name, tMetrics)
  tMetrics = [#font: tPlain.getaProp(#font), #fontStyle: tLink.getaProp(#fontStyle), #color: rgb("#EEEEEE")]
  createWriter(pBuddyDrw_writerID_msgs, tMetrics)
  tMetrics = [#font: tPlain.getaProp(#font), #fontStyle: tPlain.getaProp(#fontStyle), #color: rgb("#EEEEEE")]
  createWriter(pBuddyDrw_writerID_last, tMetrics)
  tMetrics = [#font: tPlain.getaProp(#font), #fontStyle: tPlain.getaProp(#fontStyle), #color: rgb("#EEEEEE")]
  createWriter(pBuddyDrw_writerID_text, tMetrics)
  pTimeOutID = "console_change_window_timeout"
  return 1
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
  pBodyPartObjects = [:]
  pBuddyDrawObjList = [:]
  removePrepare(me.getID())
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  if objectExists(pRequestRenderID) then
    removeObject(pRequestRenderID)
  end if
  return 1
end

on showhidemessenger me
  if windowExists(pWindowTitle) then
    return me.hideMessenger()
  else
    return me.showMessenger()
  end if
end

on showMessenger me
  if pMessengerInactive then
    executeMessage(#alert, "buddyremove_messenger_updating")
    return 1
  end if
  me.getComponent().send_BuddylistUpdate()
  if not windowExists(pWindowTitle) then
    if pBodyPartObjects.count = 0 then
      me.createTemplateHead()
    end if
    me.ChangeWindowView("console_myinfo.window")
    return 1
  else
    return 0
  end if
end

on hideMessenger me
  if windowExists(pWindowTitle) then
    pOpenWindow = EMPTY
    pLastOpenWindow = EMPTY
    return removeWindow(pWindowTitle)
  else
    return 0
  end if
end

on setBuddyListLimits me, tOwn, tNormal, tClub
  pBuddyListLimits.own = tOwn
  pBuddyListLimits.normal = tNormal
  pBuddyListLimits.club = tClub
  pBuddyListLimits.sort()
  return 1
end

on getBuddyListLimits me
  return duplicate(pBuddyListLimits)
end

on setMessengerInactive me
  pMessengerInactive = 1
  me.hideMessenger()
  me.getComponent().deleteAllMessages()
  me.getComponent().pause()
  return 1
end

on setMessengerActive me
  pMessengerInactive = 0
  me.getComponent().resume()
  return 1
end

on isMessengerActive me
  return not pMessengerInactive
end

on createBuddyList me, tBuddyListPntr
  pBuddyListPntr = tBuddyListPntr
  pBuddyDrawObjList = [:]
  repeat with tdata in pBuddyListPntr.getaProp(#value).buddies
    pBuddyDrawObjList[tdata[#name]] = me.createBuddyDrawObj(tdata)
  end repeat
  return me.buildBuddyListImg()
end

on updateBuddyList me
  call(#update, pBuddyDrawObjList)
  return me.buildBuddyListImg()
end

on appendBuddy me, tdata
  if voidp(pBuddyDrawObjList[tdata[#name]]) then
    pBuddyDrawObjList[tdata[#name]] = me.createBuddyDrawObj(tdata)
  end if
  return me.buildBuddyListImg()
end

on removeBuddy me, tID
  if voidp(pBuddyListPntr.getaProp(#value).buddies.getaProp(tID)) then
    return error(me, "Buddy data not found:" && tID, #removeBuddy, #minor)
  end if
  repeat with i = 1 to pSelectedBuddies.count
    if pSelectedBuddies[i][#id] = tID then
      pSelectedBuddies.deleteAt(i)
      exit repeat
    end if
  end repeat
  tName = pBuddyListPntr.getaProp(#value).buddies.getaProp(tID).name
  if voidp(pBuddyDrawObjList[tName]) then
    return error(me, "Buddy renderer not found:" && tID, #removeBuddy, #minor)
  end if
  tPos = pBuddyListPntr.getaProp(#value).render.getPos(tName)
  if tPos = 0 then
    return error(me, "Buddy renderer was lost:" && tID, #removeBuddy, #minor)
  end if
  pBuddyDrawObjList.deleteProp(tName)
  tW = pBuddyListBuffer.width
  tH = pBuddyListBuffer.height - pBuddylistItemHeight
  tD = pBuddyListBuffer.depth
  tImg = image(tW, tH, tD)
  tRect = rect(0, 0, tW, (tPos - 1) * pBuddylistItemHeight)
  tImg.copyPixels(pBuddyListBuffer, tRect, tRect)
  tRect = rect(0, tPos * pBuddylistItemHeight, tW, pBuddyListBuffer.height)
  tImg.copyPixels(pBuddyListBuffer, tRect - [0, pBuddylistItemHeight, 0, pBuddylistItemHeight], tRect)
  pBuddyListBuffer = tImg
  return me.updateBuddyListImg()
end

on updateFrontPage me
  if windowExists(pWindowTitle) then
    if pOpenWindow = "console_myinfo.window" then
      tNumOfNewMsg = string(me.getComponent().getNumOfMessages()) && getText("console_newmessages", "new message(s)")
      tNumOfBuddyRequest = string(me.getComponent().getNumOfBuddyRequest()) && getText("console_requests", "Friend Request(s)")
      tWndObj = getWindow(pWindowTitle)
      tWndObj.getElement("console_myinfo_messages_link").setText(tNumOfNewMsg)
      tWndObj.getElement("console_myinfo_requests_link").setText(tNumOfBuddyRequest)
    end if
  end if
end

on updateUserFind me, tMsg, tstate
  if pOpenWindow <> "console_find.window" then
    return 0
  end if
  tWinObj = getWindow(pWindowTitle)
  if tWinObj = 0 then
    return 0
  end if
  if tstate then
    me.updateMyHeadPreview(tMsg[#FigureData], "console_search_habboface_image")
    pLastSearch = tMsg
    tUserName = tMsg[#name]
    tBuddyData = me.getComponent().getBuddyData()
    tBuddyAlreadyOnline = string(tBuddyData.online) contains QUOTE & tUserName & QUOTE
    tBuddyAlreadyOffline = string(tBuddyData.offline) contains QUOTE & tUserName & QUOTE
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
    tWinObj.getElement("console_search_habbo_name_text").setText(tMsg[#name])
    tWinObj.getElement("console_search_habbo_mission_text").setText(tMsg[#customText])
    tWinObj.getElement("console_search_habbo_lasthere_text").setText(tMsg[#lastAccess])
    tlocation = tMsg[#location]
    if tMsg[#online] = 0 then
      tlocation = getText("console_offline")
    else
      if tlocation contains "Floor1" then
        tlocation = getText("console_online") && getText("console_inprivateroom")
      end if
      if tlocation contains "ENTERPRISESERVER" then
        tlocation = getText("console_online") && getText("console_onfrontpage")
      end if
    end if
    return tWinObj.getElement("console_search_habbo_online_text").setText(tlocation)
  else
    pLastSearch = [:]
    tMsg = getText("console_usersnotfound")
    tWinObj.getElement("console_search_friendrequest_button").deactivate()
    tWinObj.getElement("console_search_friendrequest_button").setProperty(#cursor, 0)
    tWinObj.getElement("console_magnifier").hide()
    tWinObj.getElement("console_search_habbo_name_text").setText(tMsg)
    tWinObj.getElement("console_search_habbo_mission_text").setText(EMPTY)
    tWinObj.getElement("console_search_habbo_lasthere_text").setText(EMPTY)
    tWinObj.getElement("console_search_habbo_online_text").setText(EMPTY)
    return 1
  end if
end

on prepare me
  if pBuddyListPntr.getaProp(#value).render = [] then
    return 1
  end if
  tName = pBuddyListPntr.getaProp(#value).render[pBuddyDrawNum]
  pBuddyDrawObjList[tName].render(pBuddyListBuffer, pBuddyDrawNum)
  pBuddyDrawNum = pBuddyDrawNum + 1
  if pBuddyDrawNum > pBuddyListPntr.getaProp(#value).render.count then
    removePrepare(me.getID())
    pListRendering = 0
    tWndObj = getWindow(pWindowTitle)
    if (tWndObj <> 0) and (pOpenWindow = "console_friends.window") then
      me.updateBuddyListImg()
    end if
  end if
end

on createBuddyDrawObj me, tdata
  tObject = createObject(#temp, "Draw Friend Class")
  tProps = [:]
  tProps[#width] = pBuddyListBufferWidth
  tProps[#height] = pBuddylistItemHeight
  tProps[#writer_name] = pBuddyDrw_writerID_name
  tProps[#writer_msgs] = pBuddyDrw_writerID_msgs
  tProps[#writer_last] = pBuddyDrw_writerID_last
  tProps[#writer_text] = pBuddyDrw_writerID_text
  tObject.define(tdata, tProps)
  return tObject
end

on buildBuddyListImg me
  pBuddyDrawNum = 1
  if pBuddyListPntr.getaProp(#value).buddies.count = 0 then
    pBuddyListBuffer = image(pBuddyListBufferWidth, pBuddylistItemHeight, 8)
    tWndObj = getWindow(pWindowTitle)
    if (tWndObj <> EMPTY) and (pOpenWindow = "console_friends.window") then
      tElement = tWndObj.getElement("console_friends_friendlist")
      tElement.clearImage()
      tElement.feedImage(pBuddyListBuffer)
    end if
    return 0
  else
    pListRendering = 1
    pBuddyListBuffer = image(pBuddyListBufferWidth, pBuddyListPntr.getaProp(#value).buddies.count * pBuddylistItemHeight, 8)
    return receivePrepare(me.getID())
  end if
end

on enterFriendRequestList me
  tRenderer = me.getFriendRequestRenderer()
  if tRenderer.unfinishedSelectionExists() then
    tRenderer.updateView()
  else
    tRequestList = me.getComponent().getFriendRequests()
    tRenderer.define(pWindowTitle, tRequestList)
  end if
end

on getFriendRequestRenderer me
  if not objectExists(pRequestRenderID) then
    createObject(pRequestRenderID, "Friend Request Renderer Class")
  end if
  tRenderer = getObject(pRequestRenderID)
  return tRenderer
end

on updateBuddyListImg me
  if voidp(pBuddyListBuffer) then
    return 0
  end if
  if pOpenWindow <> "console_friends.window" then
    return 0
  end if
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  return tWndObj.getElement("console_friends_friendlist").feedImage(pBuddyListBuffer)
end

on updateRadioButton me, tElement, tListOfOthersElements
  tOnImg = member(getmemnum("messenger_radio_on")).image
  tOffImg = member(getmemnum("messenger_radio_off")).image
  tWinObj = getWindow(pWindowTitle)
  if tWinObj.elementExists(tElement) then
    tWinObj.getElement(tElement).feedImage(tOnImg)
  end if
  repeat with tRadioElement in tListOfOthersElements
    if tWinObj.elementExists(tRadioElement) then
      tWinObj.getElement(tRadioElement).feedImage(tOffImg)
    end if
  end repeat
end

on createTemplateHead me
  tTempFigure = getObject(#session).GET("user_figure")
  if not listp(tTempFigure) then
    return error(me, "Missing user figure data!", #createTemplateHead, #minor)
  end if
  pBodyPartObjects = [:]
  if objectExists(#classes) then
    tBodyPartClass = value(getObject(#classes).GET("bodypart"))
  else
    if memberExists("fuse.object.classes") then
      tBodyPartClass = value(readValueFromField("fuse.object.classes", RETURN, "bodypart"))
    else
      return error(me, "Resources required to create character image not found!", #createTemplateHead, #major)
    end if
  end if
  repeat with tPart in ["hd", "fc", "ey", "hr"]
    tmodel = tTempFigure[tPart]["model"]
    tColor = tTempFigure[tPart]["color"]
    tDirection = 3
    tAction = "std"
    tAncestor = me
    tTempPartObj = createObject(#temp, tBodyPartClass)
    tTempPartObj.define(tPart, tmodel, tColor, tDirection, tAction, tAncestor)
    pBodyPartObjects.addProp(tPart, tTempPartObj)
  end repeat
  return 1
end

on updateMyHeadPreview me, tFigure, tElement
  if pBodyPartObjects.count = 0 then
    return 0
  end if
  repeat with tPart in ["hd", "fc", "ey", "hr"]
    if not voidp(tFigure[tPart]) then
      tmodel = tFigure[tPart]["model"]
      tColor = tFigure[tPart]["color"]
      case length(tmodel) of
        1:
          tmodel = "00" & tmodel
        2:
          tmodel = "0" & tmodel
      end case
      call(#setColor, pBodyPartObjects[tPart], tColor)
      call(#setModel, pBodyPartObjects[tPart], tmodel)
    end if
  end repeat
  me.createHeadPreview(tElement)
end

on createHeadPreview me, tElemID
  tWndObj = getWindow(pWindowTitle)
  if not tWndObj then
    return 0
  end if
  if tWndObj.elementExists(tElemID) then
    if pBodyPartObjects.count > 0 then
      tTempImg = image(64, 102, 16)
      repeat with tPart in ["hd", "fc", "ey", "hr"]
        call(#copyPicture, pBodyPartObjects[tPart], tTempImg, 3)
      end repeat
      tTempImg = tTempImg.trimWhiteSpace()
      tElement = tWndObj.getElement(tElemID)
      tWidth = tElement.getProperty(#width)
      tHeight = tElement.getProperty(#height)
      tDepth = tElement.getProperty(#depth)
      tPrewImg = image(tWidth, tHeight, tDepth)
      tdestrect = tPrewImg.rect - tTempImg.rect
      tdestrect = rect(tdestrect.width / 2, tdestrect.height / 2, tTempImg.width + (tdestrect.width / 2), (tdestrect.height / 2) + tTempImg.height)
      tPrewImg.copyPixels(tTempImg, tdestrect, tTempImg.rect, [#ink: 8])
      tElement.clearImage()
      tElement.feedImage(tPrewImg)
    end if
  end if
end

on buddySelectOrNot me, tName, tID, tstate
  tdata = [#name: tName, #id: tID]
  if tstate then
    pSelectedBuddies.add(tdata)
  else
    tPos = pSelectedBuddies.findPos(tdata)
    if tPos > 0 then
      pSelectedBuddies.deleteAt(tPos)
    end if
  end if
  if pOpenWindow <> "console_friends.window" then
    return 
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
    return EMPTY
  end if
  if pSelectedBuddies.count = 0 then
    return EMPTY
  end if
  tStr = EMPTY
  repeat with f = 1 to pSelectedBuddies.count
    tStr = tStr & pSelectedBuddies[f][tProp] & tItemDeLim
  end repeat
  tStr = tStr.char[1..length(tStr) - length(tItemDeLim)]
  return tStr
end

on renderMessage me, tMsgStruct
  pActiveMessage = tMsgStruct
  if not listp(tMsgStruct) then
    return error(me, "Invalid message struct:" && tMsgStruct, #renderMessage, #major)
  end if
  if pOpenWindow <> "console_getmessage.window" then
    me.ChangeWindowView("console_getmessage.window")
  end if
  pLastGetMsg = tMsgStruct
  tMsg = tMsgStruct[#message]
  tTime = tMsgStruct[#time]
  tSenderId = tMsgStruct[#senderID]
  tWndObj = getWindow(pWindowTitle)
  if tMsgStruct[#campaign] = 1 then
    me.ChangeWindowView("console_officialmessage.window")
    tWndObj.getElement("console_official_message").setText(tMsg)
    tWndObj.getElement("console_safety_info").setText(tMsgStruct[#link])
    tWndObj.getElement("console_safety_info").setaProp(#pLinkTarget, tMsgStruct[#url])
    tmessageId = tMsgStruct[#id]
    return 1
  end if
  tdata = pBuddyListPntr.getaProp(#value).buddies.getaProp(tSenderId)
  tMessageIsValid = 1
  if not voidp(tdata) then
    tSenderName = tdata.name
  else
    tSenderName = getText("console_unknown_sender")
    tMsg = getText("console_invalid_message")
    tMessageIsValid = 0
  end if
  if objectExists("Figure_System") and tMessageIsValid then
    tFigure = getObject("Figure_System").parseFigure(tdata[#FigureData], tdata[#sex])
    me.updateMyHeadPreview(tFigure, "console_getmessage_face_image")
  end if
  tFrom = getText("console_getmessage_sender") && tSenderName & RETURN & tTime
  tWndObj.getElement("console_getmessage_sender").setText(tFrom)
  tElem = tWndObj.getElement("console_getmessage_field")
  tRect = rect(0, 0, tElem.pwidth, tElem.pheight)
  tElem.feedImage(getWriter(pWriterID_consolemsg).render(tMsg, tRect))
  pSelectedBuddies = []
  call(#unselect, pBuddyDrawObjList)
  me.buddySelectOrNot(tSenderName, tSenderId, 1)
  return 1
end

on openBuddyMassremoveWindow me
  me.ChangeWindowView("console_myinfo.window")
  if objectp(createObject("buddy_massremove", "Buddy Massremove Class")) then
    getObject("buddy_massremove").openRemoveWindow(pBuddyListPntr.getaProp(#value).buddies.duplicate(), pBuddyListLimits)
    return 1
  else
    return 0
  end if
end

on purgeFriendRequestSelections me, tInverted
  if voidp(tInverted) then
    tInverted = 0
  end if
  tRenderer = me.getFriendRequestRenderer()
  if voidp(tRenderer) then
    return error(me, "Friend request list not available", #purgeFriendRequestSelections, #major)
  end if
  if tInverted then
    tAcceptedList = tRenderer.getDeselectedList()
    tDeclinedList = tRenderer.getSelectedList()
  else
    tAcceptedList = tRenderer.getSelectedList()
    tDeclinedList = tRenderer.getDeselectedList()
  end if
  tMsgList = [#integer: tAcceptedList.count]
  repeat with tItem in tAcceptedList
    tMsgList.addProp(#integer, integer(tItem[#id]))
  end repeat
  getConnection(getVariable("connection.info.id")).send("MESSENGER_ACCEPTBUDDY", tMsgList)
  tMsgList = [#integer: 0, #integer: tDeclinedList.count]
  repeat with tItem in tDeclinedList
    tMsgList.addProp(#integer, integer(tItem[#id]))
  end repeat
  getConnection(getVariable("connection.info.id")).send("MESSENGER_DECLINEBUDDY", tMsgList)
  tRenderer.clearRequests()
  me.getComponent().clearFriendRequests(tAcceptedList)
  me.getComponent().clearFriendRequests(tDeclinedList)
  me.getComponent().tellRequestCount()
  if me.getComponent().getFriendRequestUpdateRequired() then
    me.getComponent().send_AskForFriendRequests()
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
      return error(me, "Failed to open Messenger window!!!", #ChangeWindowView, #major)
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
    return error(me, "Failed to open Messenger window!!!", #ChangeWindowView, #major)
  end if
  pLastOpenWindow = pOpenWindow
  pOpenWindow = tWindowName
  case tWindowName of
    "console_myinfo.window":
      pSelectedBuddies = []
      me.updateMyHeadPreview(getObject(#session).GET("user_figure"), "console_myhead_image")
      tName = getObject(#session).GET("user_name")
      tNewMsgCount = string(me.getComponent().getNumOfMessages()) && getText("console_newmessages", "new message(s)")
      tNewReqCount = string(me.getComponent().getNumOfBuddyRequest()) && getText("console_requests", "Friend Request(s)")
      tMission = me.getComponent().getMyPersistenMsg()
      tWndObj.getElement("console_myinfo_name").setText(tName)
      tWndObj.getElement("console_myinfo_mission_field").setText(tMission)
      tWndObj.getElement("console_myinfo_messages_link").setText(tNewMsgCount)
      tWndObj.getElement("console_myinfo_requests_link").setText(tNewReqCount)
    "console_getmessage.window":
      pLastGetMsg = [:]
    "console_friends.window":
      pSelectedBuddies = []
      tRenderList = pBuddyListPntr.getaProp(#value).render
      if tRenderList.count > 0 then
        if pBuddyDrawNum >= tRenderList.count then
          call(#unselect, pBuddyDrawObjList)
          repeat with i = 1 to tRenderList.count
            pBuddyDrawObjList[tRenderList[i]].render(pBuddyListBuffer, i)
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
      createTimeout(pTimeOutID, 100, #changeWindowDelayedUpdate, me.getID(), VOID, 1)
    "console_request_list.window":
      me.enterFriendRequestList()
    "console_confirm_friend_requests.window":
      tRenderer = me.getFriendRequestRenderer()
      if pSelectionIsInverted then
        tDeclinedList = tRenderer.getSelectedList()
        tAcceptedList = tRenderer.getDeselectedList()
      else
        tAcceptedList = tRenderer.getSelectedList()
        tDeclinedList = tRenderer.getDeselectedList()
      end if
      tWindowObj = getWindow(pWindowTitle)
      tAcceptedText = getText("console_fr_accepted_count") & ": " & tAcceptedList.count
      tDeclinedText = getText("console_fr_declined_count") & ": " & tDeclinedList.count
      tWindowObj.getElement("console_fr_accepted_count").setText(tAcceptedText)
      tWindowObj.getElement("console_fr_declined_count").setText(tDeclinedText)
    "console_compose.window":
      if pSelectedBuddies.count = 0 then
        return me.ChangeWindowView("console_friends.window")
      end if
      pComposeMsg = EMPTY
      tWinObj = getWindow(pWindowTitle)
      tSelectedBuddies = me.getSelectedBuddiesStr(#name, "," & SPACE)
      tWndObj.getElement("console_compose_recipients").setText(tSelectedBuddies)
    "console_removefriend.window":
      if pSelectedBuddies.count > 0 then
        pRemoveBuddy = pSelectedBuddies[1]
        pSelectedBuddies.deleteAt(1)
        tWndObj.getElement("console_removefriend_name").setText(pRemoveBuddy[#name])
      end if
      if pBuddyDrawObjList.count > 0 then
        call(#unselect, pBuddyDrawObjList)
      end if
    "console_find.window":
      pLastSearch = [:]
      tWndObj.getElement("console_magnifier").hide()
      tWndObj.getElement("console_search_friendrequest_button").deactivate()
      tWndObj.getElement("console_search_friendrequest_button").setProperty(#cursor, 0)
    "console_sentrequest.window":
      tWndObj.getElement("console_request_habbo_name_text").setText(pLastSearch[#name])
    "console_reportmessage.window":
    "console_main_help.window":
    "console_messagemodes_help.window":
    "console_friends_help.window":
  end case
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
    return 0
  end if
  tRenderList = pBuddyListPntr.getaProp(#value).render
  if tRenderList.count = 0 then
    return 0
  end if
  tLine = integer(tpoint.locV / pBuddylistItemHeight) + 1
  if tLine < 1 then
    return 0
  end if
  if tLine > tRenderList.count then
    return 0
  end if
  return tRenderList[tLine]
end

on getBuddyListPoint me, tpoint
  return point(tpoint.locH, tpoint.locV mod pBuddylistItemHeight)
end

on setAllRequestSelectionsTo me, tValue
  tRenderer = me.getFriendRequestRenderer()
  tRenderer.setAllRequestSelectionsTo(tValue)
  tRenderer.updateView()
end

on acceptSelectedRequests me
  pSelectionIsInverted = 0
  if not me.getFriendRequestRenderer().isSelectedAmountValid(pSelectionIsInverted) then
    executeMessage(#alert, "console_fr_limit_exceeded_error")
  else
    me.ChangeWindowView("console_confirm_friend_requests.window")
  end if
end

on rejectSelectedRequests me
  pSelectionIsInverted = 1
  if not me.getFriendRequestRenderer().isSelectedAmountValid(pSelectionIsInverted) then
    executeMessage(#alert, "console_fr_limit_exceeded_error")
  else
    me.ChangeWindowView("console_confirm_friend_requests.window")
  end if
end

on eventProcMessenger me, tEvent, tElemID, tParm
  if tEvent = #mouseDown then
    case tElemID of
      "console.myinfo.button":
        me.ChangeWindowView("console_myinfo.window")
      "console.myfriends.button":
        me.ChangeWindowView("console_friends.window")
      "console.find.button":
        me.ChangeWindowView("console_find.window")
        executeMessage(#tutorial_console_find_button_clicked)
      "console.help.button":
        me.ChangeWindowView("console_main_help.window")
      "console_myinfo_messages_link":
        if me.getComponent().getNumOfMessages() > 0 then
          me.renderMessage(me.getComponent().getNextMessage())
        end if
      "console_myinfo_requests_link":
        if me.getComponent().getNumOfBuddyRequest() = 0 then
          return 
        end if
        me.ChangeWindowView("console_request_list.window")
      "console_friends_friendlist":
        if tParm.ilk <> #point then
          return 0
        end if
        tRenderList = pBuddyListPntr.getaProp(#value).render
        if tRenderList.count = 0 then
          return 0
        end if
        tClickLine = integer(tParm.locV / pBuddylistItemHeight)
        if tClickLine < 0 then
          return 0
        end if
        if tClickLine > (tRenderList.count - 1) then
          return 0
        end if
        if not (the doubleClick) then
          tPosition = tClickLine + 1
          tpoint = tParm - [0, tClickLine * pBuddylistItemHeight]
          tName = tRenderList[tPosition]
          pBuddyDrawObjList[tName].select(tpoint, pBuddyListBuffer, tClickLine)
          pBuddyDrawObjList[tName].clickAt(tParm.locH, tParm.locV - (tClickLine * pBuddylistItemHeight))
          me.updateBuddyListImg()
          tElem = getWindow(pWindowTitle).getElement("console_select_friend_field")
          if tElem <> 0 then
            the keyboardFocusSprite = tElem.getProperty(#sprite).spriteNum
          end if
        else
          me.ChangeWindowView("console_compose.window")
        end if
    end case
  else
    if tEvent = #mouseUp then
      if tElemID contains "fr_check_" then
        tDelim = the itemDelimiter
        the itemDelimiter = "_"
        tItemNo = tElemID.item[3]
        me.getFriendRequestRenderer().itemEvent(tItemNo)
        the itemDelimiter = tDelim
      end if
      if tElemID contains "fr_name_" then
        tDelim = the itemDelimiter
        the itemDelimiter = "_"
        tItemNo = tElemID.item[3]
        the itemDelimiter = tDelim
        tUserID = me.getFriendRequestRenderer().getUserIdForSelectionNo(tItemNo)
        tHomepageURL = getVariable("link.format.userpage")
        tHomepageURL = replaceChunks(tHomepageURL, "%ID%", tUserID)
        openNetPage(tHomepageURL)
      end if
      case tElemID of
        "close":
          tWndObj = getWindow(pWindowTitle)
          if objectp(tWndObj) then
            if (pOpenWindow = "console_myinfo.window") and tWndObj.elementExists("console_myinfo_mission_field") then
              tMessage = tWndObj.getElement("console_myinfo_mission_field").getText().line[1]
              me.getComponent().send_PersistentMsg(tMessage)
            end if
          end if
          me.hideMessenger()
        "console_accept_selection":
          me.purgeFriendRequestSelections(pSelectionIsInverted)
          me.ChangeWindowView("console_myinfo.window")
        "console_modify_selection":
          me.ChangeWindowView("console_request_list.window")
        "console_fr_previous":
          me.getFriendRequestRenderer().showPreviousPage()
        "console_fr_next":
          me.getFriendRequestRenderer().showNextPage()
        "console_report_remove":
          tMsgStruct = me.getComponent().getNextMessage()
          if listp(tMsgStruct) then
            me.getComponent().send_RemoveBuddy(integer(tMsgStruct[#senderID]))
            me.ChangeWindowView("console_friends.window")
          end if
        "console_report_report":
          tMsgStruct = me.getComponent().getNextMessage()
          me.ChangeWindowView("console_friends.window")
          me.getComponent().send_reportMessage(integer(tMsgStruct[#id]))
        "console_report_cancel":
          if me.getComponent().getNumOfMessages() > 0 then
            if me.getComponent().getMessageUpdateRequired() then
              me.getComponent().send_AskForMessages()
            end if
            me.renderMessage(me.getComponent().getNextMessage())
          end if
        "console_getmessage_reply":
          if voidp(pLastGetMsg[#id]) then
            return 0
          end if
          me.getComponent().send_MessageMarkRead(pLastGetMsg[#id], pLastGetMsg[#senderID])
          me.ChangeWindowView("console_compose.window")
        "console_getmessage_next":
          if voidp(pLastGetMsg[#id]) then
            return 0
          end if
          me.getComponent().send_MessageMarkRead(pLastGetMsg[#id], pLastGetMsg[#senderID], pLastGetMsg[#campaign])
          if me.getComponent().getNumOfMessages() > 0 then
            me.renderMessage(me.getComponent().getNextMessage())
          else
            if me.getComponent().getMessageUpdateRequired() then
              me.getComponent().send_AskForMessages()
            end if
            me.ChangeWindowView("console_myinfo.window")
          end if
        "console_getmessage_report":
          me.ChangeWindowView("console_reportmessage.window")
        "console_fr_deselect_all":
          me.setAllRequestSelectionsTo(0)
        "console_fr_select_all":
          me.setAllRequestSelectionsTo(1)
        "console_fr_accept_selected":
          me.acceptSelectedRequests()
        "console_fr_reject_selected":
          me.rejectSelectedRequests()
        "messenger_friends_compose_button":
          if pSelectedBuddies.count < 1 then
            return 0
          end if
          me.ChangeWindowView("console_compose.window")
        "console_compose_send":
          if pSelectedBuddies.count < 1 then
            if me.getComponent().getMessageUpdateRequired() then
              me.getComponent().send_AskForMessages()
            end if
            me.ChangeWindowView("console_myinfo.window")
            return 0
          end if
          pComposeMsg = getWindow(pWindowTitle).getElement("console_compose_message_field").getText()
          me.getComponent().send_Message(pSelectedBuddies, pComposeMsg)
          if pLastOpenWindow = "console_friends.window" then
            me.ChangeWindowView("console_friends.window")
          else
            me.ChangeWindowView("console_myinfo.window")
          end if
        "console_compose_cancel":
          if pLastOpenWindow = "console_friends.window" then
            me.ChangeWindowView("console_friends.window")
          else
            me.ChangeWindowView("console_myinfo.window")
          end if
        "messenger_friends_remove_button":
          me.ChangeWindowView("console_removefriend.window")
        "console_friendrequest_remove":
          if voidp(pRemoveBuddy) or (pRemoveBuddy = EMPTY) then
            return 
          end if
          me.getComponent().send_RemoveBuddy(integer(pRemoveBuddy[#id]))
          if pSelectedBuddies.count < 1 then
            me.ChangeWindowView("console_friends.window")
          else
            me.ChangeWindowView("console_removefriend.window")
          end if
        "console_getfriendrequest_cancel":
          if pSelectedBuddies.count < 1 then
            me.ChangeWindowView("console_friends.window")
          else
            me.ChangeWindowView("console_removefriend.window")
          end if
        "console_compose_help_button":
          pComposeMsg = getWindow(pWindowTitle).getElement("console_compose_message_field").getText()
          me.ChangeWindowView("console_messagemodes_help.window")
        "console_messagemode_back":
          if voidp(pComposeMsg) then
            return 0
          end if
          me.ChangeWindowView("console_compose.window")
          getWindow(pWindowTitle).getElement("console_compose_message_field").setText(pComposeMsg)
        "console_search_search_button":
          tQuery = getWindow(pWindowTitle).getElement("console_search_key_field").getText()
          me.getComponent().send_FindUser(tQuery)
          getWindow(pWindowTitle).getElement("console_search_key_field").setText(EMPTY)
        "console_search_friendrequest_button":
          tListLimits = getBuddyListLimits()
          tLimit = tListLimits[#own]
          tBuddyData = me.getComponent().getBuddyData()
          tBuddyCount = tBuddyData[#buddies].count
          if tBuddyCount >= tLimit then
            tClubLimit = tListLimits[#club]
            tMessage = getText("buddyremove_list_full")
            tMessage = replaceChunks(tMessage, "%mylimit%", tLimit)
            tMessage = replaceChunks(tMessage, "%clublimit%", tClubLimit)
            executeMessage(#alert, [#Msg: tMessage])
          else
            if voidp(pLastSearch[#name]) then
              return 0
            end if
            me.getComponent().send_RequestBuddy(pLastSearch[#name])
            me.ChangeWindowView("console_sentrequest.window")
          end if
        "console_friendrequest_ok":
          me.ChangeWindowView("console_find.window")
        "console_friends_help_button":
          me.ChangeWindowView("console_friends_help.window")
        "console_friends_help_backbutton":
          me.ChangeWindowView("console_friends.window")
        "console_safety_info":
          getConnection(getVariable("connection.info.id")).send("MESSENGER_C_CLICK", [#integer: integer(pLastGetMsg[#id])])
          openNetPage(getWindow(pWindowTitle).getElement(tElemID).getaProp(#pLinkTarget))
        "console_official_exit":
          getConnection(getVariable("connection.info.id")).send("MESSENGER_C_READ", [#string: integer(pLastGetMsg[#id])])
          me.ChangeWindowView("console_myinfo.window")
      end case
    else
      if tEvent = #keyDown then
        if (pOpenWindow = "console_myinfo.window") and (tElemID = "console_myinfo_mission_field") and (the key = RETURN) then
          tWndObj = getWindow(pWindowTitle)
          tMessage = tWndObj.getElement("console_myinfo_mission_field").getText()
          return me.getComponent().send_PersistentMsg(tMessage)
        end if
        if tElemID = "console_search_key_field" then
          if the key = RETURN then
            tElem = getWindow(pWindowTitle).getElement(tElemID)
            tQuery = tElem.getText()
            me.getComponent().send_FindUser(tQuery)
            tElem.setText(EMPTY)
            return 1
          end if
        end if
        if tElemID = "console_select_friend_field" then
          tElem = getWindow(pWindowTitle).getElement(tElemID)
          tElem.setText(EMPTY)
          tElem = getWindow(pWindowTitle).getElement("friendlist_scrollbar")
          case the keyCode of
            126:
              tElem.setScrollOffset(tElem.getProperty(#offset) - tElem.getProperty(#scrollStep))
            125:
              tElem.setScrollOffset(tElem.getProperty(#offset) + tElem.getProperty(#scrollStep))
          end case
          if (charToNum(the key) >= 32) and (charToNum(the key) <> 127) then
            tBuddyList = me.getComponent().getBuddyData()[#render]
            repeat with i = 1 to tBuddyList.count()
              tBuddy = tBuddyList[i]
              if tBuddy.char[1] = the key then
                tScrollRange = tElem.getProperty(#scrollrange)
                tElem.setScrollOffset(tScrollRange * (i - 1) / tBuddyList.count())
                exit repeat
                next repeat
              end if
              if tBuddy.char[1] > the key then
                tScrollRange = tElem.getProperty(#scrollrange)
                tElem.setScrollOffset(tScrollRange * (i - 2) / tBuddyList.count())
                exit repeat
                next repeat
              end if
              if i = tBuddyList.count() then
                tScrollRange = tElem.getProperty(#scrollrange)
                tElem.setScrollOffset(tScrollRange * (i - 1) / tBuddyList.count())
                exit repeat
              end if
            end repeat
          end if
        end if
      else
        if tEvent = #mouseWithin then
          case tElemID of
            "console_friends_friendlist":
              if tParm.ilk <> #point then
                return 0
              end if
              tBuddyName = me.getBuddyListName(tParm)
              if tBuddyName = 0 then
                return 0
              end if
              tBuddyPoint = me.getBuddyListPoint(tParm)
              tWindowRef = getWindow(pWindowTitle)
              tElemRef = tWindowRef.getElement(tElemID)
              if voidp(pBuddyDrawObjList[tBuddyName]) then
                return 0
              end if
              if pBuddyDrawObjList[tBuddyName].atWebLinkIcon(tBuddyPoint) then
                tElemRef.setProperty(#cursor, "cursor.finger")
              else
                if pBuddyDrawObjList[tBuddyName].atMessageCount(tBuddyPoint) then
                  tElemRef.setProperty(#cursor, "cursor.finger")
                else
                  tElemRef.setProperty(#cursor, 0)
                end if
              end if
            otherwise:
              nothing()
          end case
        else
          if tEvent = #mouseLeave then
            case tElemID of
              "console_friends_friendlist":
                tWindowRef = getWindow(pWindowTitle)
                tElemRef = tWindowRef.getElement(tElemID)
                tElemRef.setProperty(#cursor, 0)
              otherwise:
                nothing()
            end case
          end if
        end if
      end if
    end if
  end if
end

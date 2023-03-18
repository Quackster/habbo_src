property pWindowTitle, pOpenWindow, pLastOpenWindow, pRoomProps, pBuddyListPntr, pSelectedBuddies, pBuddyListBuffer, pBuddyListBufferWidth, pBuddylistItemHeigth, pBuddyDrawObjList, pLastSearch, pLastGetMsg, pComposeMsg, pBodyPartObjects, pRemoveBuddy, pBuddyDrawNum, pCurrProf, pMsgsStr, pFriendListSwitch, pFriendListObjs, pBuddyListLimits, pMessengerInactive, pListRendering, pActiveMessage, pWriterID_nobuddies, pWriterID_consolemsg, pBuddyDrw_writerID_name, pBuddyDrw_writerID_msgs, pBuddyDrw_writerID_last, pBuddyDrw_writerID_text, pTimeOutID

on construct me
  pWindowTitle = getText("win_messenger", "Habbo Console")
  pBuddyListBufferWidth = 203
  pBuddylistItemHeigth = 40
  if variableExists("messenger_friend_permsg_offset") then
    pBuddylistItemHeigth = pBuddylistItemHeigth + getVariable("messenger_friend_permsg_offset") + 1
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

on setMessengerInactive me
  pMessengerInactive = 1
  me.hideMessenger()
  me.getComponent().deleteAllMessages()
  me.getComponent().pause()
  return 1
end

on setMessengerActive me
  if pMessengerInactive = 1 then
    me.getComponent().send_AskForMessages()
  end if
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

on removeBuddy me, tid
  if voidp(pBuddyListPntr.getaProp(#value).buddies.getaProp(tid)) then
    return error(me, "Buddy data not found:" && tid, #removeBuddy)
  end if
  repeat with i = 1 to pSelectedBuddies.count
    if pSelectedBuddies[i][#id] = tid then
      pSelectedBuddies.deleteAt(i)
      exit repeat
    end if
  end repeat
  tName = pBuddyListPntr.getaProp(#value).buddies.getaProp(tid).name
  if voidp(pBuddyDrawObjList[tName]) then
    return error(me, "Buddy renderer not found:" && tid, #removeBuddy)
  end if
  tPos = pBuddyListPntr.getaProp(#value).render.getPos(tName)
  if tPos = 0 then
    return error(me, "Buddy renderer was lost:" && tid, #removeBuddy)
  end if
  pBuddyDrawObjList.deleteProp(tName)
  tW = pBuddyListBuffer.width
  tH = pBuddyListBuffer.height - pBuddylistItemHeigth
  tD = pBuddyListBuffer.depth
  tImg = image(tW, tH, tD)
  tRect = rect(0, 0, tW, (tPos - 1) * pBuddylistItemHeigth)
  tImg.copyPixels(pBuddyListBuffer, tRect, tRect)
  tRect = rect(0, tPos * pBuddylistItemHeigth, tW, pBuddyListBuffer.height)
  tImg.copyPixels(pBuddyListBuffer, tRect - [0, pBuddylistItemHeigth, 0, pBuddylistItemHeigth], tRect)
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
  tProps[#height] = pBuddylistItemHeigth
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
    pBuddyListBuffer = image(pBuddyListBufferWidth, pBuddylistItemHeigth, 8)
    tWndObj = getWindow(pWindowTitle)
    if (tWndObj <> EMPTY) and (pOpenWindow = "console_friends.window") then
      tElement = tWndObj.getElement("console_friends_friendlist")
      tElement.clearImage()
      tElement.feedImage(pBuddyListBuffer)
    end if
    return 0
  else
    pListRendering = 1
    pBuddyListBuffer = image(pBuddyListBufferWidth, pBuddyListPntr.getaProp(#value).buddies.count * pBuddylistItemHeigth, 8)
    return receivePrepare(me.getID())
  end if
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
    return error(me, "Missing user figure data!", #createTemplateHead)
  end if
  pBodyPartObjects = [:]
  if objectExists(#classes) then
    tBodyPartClass = value(getObject(#classes).GET("bodypart"))
  else
    if memberExists("fuse.object.classes") then
      tBodyPartClass = value(readValueFromField("fuse.object.classes", RETURN, "bodypart"))
    else
      return error(me, "Resources required to create character image not found!", #createTemplateHead)
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

on buddySelectOrNot me, tName, tid, tstate
  tdata = [#name: tName, #id: tid]
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
    return error(me, "Invalid message struct:" && tMsgStruct, #renderMessage)
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
  if not voidp(tdata) then
    tSenderName = tdata.name
  else
    error(me, "Unknown message sender:" && tSenderId, #renderMessage)
    tSenderName = "Unknown sender!"
  end if
  if objectExists("Figure_System") then
    tFigure = getObject("Figure_System").parseFigure(tdata[#FigureData], tdata[#sex])
    me.updateMyHeadPreview(tFigure, "console_getmessage_face_image")
  end if
  tFrom = getText("console_getmessage_sender", "From:") && tSenderName & RETURN & tTime
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
      return error(me, "Failed to open Messenger window!!!", #ChangeWindowView)
    else
      tWndObj = getWindow(pWindowTitle)
      tWndObj.registerClient(me.getID())
      tWndObj.registerProcedure(#eventProcMessenger, me.getID(), #mouseUp)
      tWndObj.registerProcedure(#eventProcMessenger, me.getID(), #mouseDown)
      tWndObj.registerProcedure(#eventProcMessenger, me.getID(), #keyDown)
    end if
  end if
  if not tWndObj.merge(tWindowName) then
    return tWndObj.close()
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
    "console_getrequest.window":
      tBuddyRequest = me.getComponent().getNextBuddyRequest()
      if listp(tBuddyRequest) then
        tWndObj.getElement("console_getrequest_habbo_name_text").setText(tBuddyRequest[#name])
      end if
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

on eventProcMessenger me, tEvent, tElemID, tParm
  if tEvent = #mouseDown then
    case tElemID of
      "console.myinfo.button":
        me.ChangeWindowView("console_myinfo.window")
      "console.myfriends.button":
        me.ChangeWindowView("console_friends.window")
      "console.find.button":
        me.ChangeWindowView("console_find.window")
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
        me.ChangeWindowView("console_getrequest.window")
      "console_friends_friendlist":
        if tParm.ilk <> #point then
          return 0
        end if
        tRenderList = pBuddyListPntr.getaProp(#value).render
        if tRenderList.count = 0 then
          return 0
        end if
        tClickLine = integer(tParm.locV / pBuddylistItemHeigth)
        if tClickLine < 0 then
          return 0
        end if
        if tClickLine > (tRenderList.count - 1) then
          return 0
        end if
        if not (the doubleClick) then
          tPosition = tClickLine + 1
          tpoint = tParm - [0, tClickLine * pBuddylistItemHeigth]
          tName = tRenderList[tPosition]
          pBuddyDrawObjList[tName].select(tpoint, pBuddyListBuffer, tClickLine)
          pBuddyDrawObjList[tName].clickAt(tParm.locH, tParm.locV - (tClickLine * pBuddylistItemHeigth))
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
        "console_report_remove":
          tMsgStruct = me.getComponent().getNextMessage()
          if listp(tMsgStruct) then
            me.getComponent().send_RemoveBuddy(integer(tMsgStruct[#senderID]))
            me.ChangeWindowView("console_friends.window")
          end if
        "console_report_report":
          tMsgStruct = me.getComponent().getNextMessage()
          if listp(tMsgStruct) then
            me.getComponent().send_RemoveBuddy(integer(tMsgStruct[#senderID]))
            me.ChangeWindowView("console_friends.window")
          end if
          me.getComponent().send_reportMessage(integer(tMsgStruct[#id]))
        "console_report_cancel":
          if me.getComponent().getNumOfMessages() > 0 then
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
            me.ChangeWindowView("console_myinfo.window")
          end if
        "console_getmessage_report":
          me.ChangeWindowView("console_reportmessage.window")
        "console_getfriendrequest_reject":
          me.getComponent().send_DeclineBuddy(#one)
          if me.getComponent().getNumOfBuddyRequest() > 0 then
            me.ChangeWindowView("console_getrequest.window")
          else
            me.ChangeWindowView("console_myinfo.window")
          end if
        "console_friendrequest_reject_all":
          me.getComponent().send_DeclineBuddy(#all)
          me.ChangeWindowView("console_myinfo.window")
        "console_friendrequest_accept":
          me.getComponent().send_AcceptBuddy()
          if me.getComponent().getNumOfBuddyRequest() > 0 then
            me.ChangeWindowView("console_getrequest.window")
          else
            me.ChangeWindowView("console_myinfo.window")
          end if
        "messenger_friends_compose_button":
          if pSelectedBuddies.count < 1 then
            return 0
          end if
          me.ChangeWindowView("console_compose.window")
        "console_compose_send":
          if pSelectedBuddies.count < 1 then
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
          if voidp(pLastSearch[#name]) then
            return 0
          end if
          me.getComponent().send_RequestBuddy(pLastSearch[#name])
          me.ChangeWindowView("console_sentrequest.window")
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
      end if
    end if
  end if
end

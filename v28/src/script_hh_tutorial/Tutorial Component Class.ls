property pTutorialID, pTutorialName, pTopics, pTopicStatuses, pTopicID, pSteps, pWaitingForPrefs, pEnabled, pRunning, pQuitting, pCurrentTopicID, pCurrentTopicNumber, pCurrentStepID, pCurrentStepNumber, pTriggerList, pRestrictionList, pUserSex, pUserName, pDefaultTutorial, pEnabledOnServer, pMessages

on construct me
  me.pEnabled = 0
  me.pRunning = 0
  me.pWaitingForPrefs = 1
  me.pQuitting = 0
  if variableExists("tutorial.name.new_user_flow") then
    me.pDefaultTutorial = getVariable("tutorial.name.new_user_flow")
  end if
  me.pMessages = [:]
  me.pMessages.setaProp(#userlogin, #getUserProperties)
  me.pMessages.setaProp(#restart_tutorial, #restartTutorial)
  me.pMessages.setaProp(#updateAvailableFlatCategories, #startDefaultTutorial)
  me.pMessages.setaProp(#enterRoom, #hideTutorial)
  me.pMessages.setaProp(#roomReady, #showTutorial)
  me.pMessages.setaProp(#leaveRoom, #showTutorial)
  me.pMessages.setaProp(#tutorial_send_console_message, #sendConsoleMessage)
  me.pMessages.setaProp(#tutorial_open_guestrooms_tab, #openGuestroomsTab)
  me.pMessages.setaProp(#tutorial_open_publicrooms_tab, #openPublicroomsTab)
  me.pMessages.setaProp(#exit_tutorial, #exitTutorial)
  me.pMessages.setaProp(#getHotelClosedDisconnectStatus, #hideTutorial)
  me.registerClientMessages(1)
  return 1
end

on deconstruct me
  me.registerClientMessages(0)
  return 1
end

on registerClientMessages me, tBool
  if (me.pMessages.ilk <> #propList) then
    return error(me, "Message list not initialized.", #registerClientMessages, #major)
  end if
  repeat with tMsgNo = 1 to me.pMessages.count
    tMessage = me.pMessages.getPropAt(tMsgNo)
    tHandler = me.pMessages[tMsgNo]
    if tBool then
      registerMessage(tMessage, me.getID(), tHandler)
      next repeat
    end if
    unregisterMessage(tMessage, me.getID())
  end repeat
end

on showTutorial me
  if (not me.pRunning or not me.pEnabled) then
    return 0
  end if
  me.getInterface().show()
  return 1
end

on hideTutorial me
  me.getInterface().hide()
  return 1
end

on getUserProperties me
  tSession = getObject(#session)
  me.pUserName = tSession.GET(#userName)
  me.pUserSex = tSession.GET(#user_sex)
  me.pEnabledOnServer = tSession.GET(#tutorial_enabled, 0)
  me.getInterface().setUserSex(me.pUserSex)
end

on startDefaultTutorial me
  if voidp(me.pDefaultTutorial) then
    return 0
  end if
  me.startTutorial(me.pDefaultTutorial)
end

on restartTutorial me
  me.pEnabled = 1
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return error(me, "Connection not found.", #startTutorial, #major)
  end if
  tConn.send("SET_TUTORIAL_MODE", [#integer: 1])
  me.startTutorial(me.pDefaultTutorial)
  me.sendTrackingRequest(#restart)
end

on setEnabled me, tBoolean
  me.pEnabled = tBoolean
  if ((me.pEnabled and me.pWaitingForPrefs) and me.pRunning) then
    me.pWaitingForPrefs = 0
    me.startTutorial()
  end if
  return 1
end

on startTutorial me, tTutorialName
  if not me.pEnabledOnServer then
    return 0
  end if
  me.pRunning = 1
  if not voidp(tTutorialName) then
    me.pTutorialName = tTutorialName
  end if
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return error(me, "Connection not found.", #startTutorial, #major)
  end if
  if me.pWaitingForPrefs then
    tConn.send("GET_ACCOUNT_PREFERENCES")
    return 0
  end if
  if (not me.pEnabled or voidp(me.pTutorialName)) then
    return 0
  end if
  tConn.send("GET_TUTORIAL_CONFIGURATION", [#string: me.pTutorialName])
  return 1
end

on setTutorialConfig me, tConfigList
  me.pTutorialID = tConfigList[#id]
  me.pTutorialName = tConfigList[#name]
  me.pTopics = tConfigList.getaProp(#topics)
  repeat with tTopicNum = 1 to me.pTopics.count
    tTextKey = ((me.pTutorialName & "_") & me.pTopics[tTopicNum])
    me.pTopics[tTopicNum] = tTextKey
  end repeat
  me.pTopicStatuses = tConfigList.getaProp(#statuses)
  me.getInterface().show()
  me.showMenu(#welcome)
end

on setTopicConfig me, tTopicConfig
  me.pTopicID = tTopicConfig[#id]
  me.pSteps = tTopicConfig[#steps]
  tTopicName = me.pTopics.getaProp(me.pTopicID)
  repeat with tStepNum = 1 to me.pSteps.count
    tStepName = me.pSteps[tStepNum][#name]
    tContentList = me.pSteps[tStepNum][#content]
    repeat with tContentNum = 1 to tContentList.count
      tContentName = tContentList[tContentNum][#textKey]
      tTextKey = ((((tTopicName & "_") & tStepName) & "_") & tContentName)
      tContentList[tContentNum][#textKey] = tTextKey
    end repeat
    me.pSteps[tStepNum][#tutor][#textKey] = (((tTopicName & "_") & tStepName) & "_tutor")
  end repeat
  me.pCurrentStepNumber = 0
  me.nextStep()
  return 1
end

on selectTopic me, tTopicID
  case tTopicID of
    #menu, #Cancel:
      me.showMenu()
      return 1
    #quit:
      me.exitTutorial()
      executeMessage(#show_navigator)
      return 1
    #otherwise:
      nothing()
  end case
  tTopicName = me.pTopics.getaProp(tTopicID)
  tURLKey = (tTopicName & "_url")
  if textExists(tURLKey) then
    tURL = getText(tURLKey)
    executeMessage(#externalLinkClick, the mouseLoc)
    openNetPage(tURL)
  end if
  me.pCurrentTopicID = tTopicID
  me.pCurrentTopicNumber = me.pTopics.getPos(me.pTopics.getaProp(tTopicID))
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return error(me, "Connection not found.", #startTutorial, #major)
  end if
  tConn.send("GET_TUTORIAL_TOPIC_CONFIGURATION", [#integer: tTopicID])
end

on nextStep me
  if (not me.pEnabled or not me.pRunning) then
    return 0
  end if
  if (me.pSteps.count = 0) then
    return 1
  end if
  me.pCurrentStepNumber = (me.pCurrentStepNumber + 1)
  if (me.pCurrentStepNumber > me.pSteps.count) then
    return 0
  end if
  me.sendTrackingRequest(#step)
  me.pCurrentStepID = me.pSteps.getPropAt(me.pCurrentStepNumber)
  tTopic = me.pSteps[me.pCurrentStepNumber]
  me.clearTriggers()
  me.clearRestrictions()
  me.setTriggers(tTopic[#triggers])
  me.setRestrictions(tTopic[#restrictions])
  me.executePrerequisites(tTopic[#prerequisites])
  me.getInterface().setBubbles(tTopic[#content])
  tTutorList = tTopic[#tutor]
  if (me.pCurrentStepNumber = me.pSteps.count) then
    tLinkList = [:]
    tNextTopicNumber = (me.pCurrentTopicNumber + 1)
    if (tNextTopicNumber <= me.pTopics.count) then
      tNextTopicID = me.pTopics.getPropAt(tNextTopicNumber)
      tNextTopicName = me.pTopics[tNextTopicNumber]
      tLinkList.setaProp(tNextTopicID, tNextTopicName)
    end if
    tLinkList.setaProp(#menu, "tutorial_select_another_topic")
    tTutorList.setaProp(#links, tLinkList)
    tStatusList = [#menu: 1]
    tTutorList.setaProp(#statuses, tStatusList)
    me.completeTopic(me.pTopicID)
  end if
  me.getInterface().setTutor(tTutorList)
end

on completeTopic me, tTopicID
  me.pTopicStatuses.setaProp(tTopicID, 1)
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return error(me, "Connection not found.", #startTutorial, #major)
  end if
  me.sendTrackingRequest(#topicCompleted)
  tConn.send("COMPLETE_TUTORIAL_TOPIC", [#integer: tTopicID])
  tConn.send("GET_TUTORIAL_STATUS", [#integer: me.pTutorialID])
end

on executePrerequisites me, tPrerequisiteList
  repeat with i = 1 to tPrerequisiteList.count
    tMessage = tPrerequisiteList.getPropAt(i)
    tParam = tPrerequisiteList[i]
    executeMessage(symbol(tMessage), tParam)
  end repeat
end

on setTriggers me, tTriggerList
  if not listp(tTriggerList) then
    return 0
  end if
  repeat with tTrigger in tTriggerList
    registerMessage(symbol(tTrigger), me.getID(), #nextStep)
  end repeat
  me.pTriggerList = tTriggerList
end

on setRestrictions me, tRestrictionList
  if not listp(tRestrictionList) then
    return 0
  end if
  repeat with tRestriction in tRestrictionList
    registerMessage(symbol(tRestriction), me.getID(), #restriction)
  end repeat
  me.pRestrictionList = tRestrictionList
end

on clearTriggers me, tForced
  if not listp(me.pTriggerList) then
    return 0
  end if
  repeat with tTrigger in me.pTriggerList
    unregisterMessage(symbol(tTrigger), me.getID())
    tHandler = me.pMessages.getaProp(tTrigger)
    if not voidp(tHandler) then
      registerMessage(tTrigger, me.getID(), tHandler)
      if not tForced then
        call(tHandler, me)
      end if
    end if
  end repeat
  me.pTriggerList = []
end

on clearRestrictions me, tForced
  if not listp(me.pRestrictionList) then
    return 0
  end if
  repeat with tRestriction in me.pRestrictionList
    unregisterMessage(symbol(tRestriction), me.getID())
    tHandler = me.pMessages.getaProp(tRestriction)
    if not voidp(tHandler) then
      registerMessage(tRestriction, me.getID(), tHandler)
      if not tForced then
        call(tHandler, me)
      end if
    end if
  end repeat
  me.pRestrictionList = []
end

on exitTutorial me
  me.pRunning = 0
  me.getInterface().hide()
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return error(me, "Connection not found.", #exitTutorial, #major)
  end if
  tConn.send("SET_TUTORIAL_MODE", [#integer: 0])
  me.pEnabled = 0
  me.sendTrackingRequest(#quit)
end

on restriction me
  me.showMenu(#offtopic)
end

on getTopics me
  return me.pTopics
end

on showMenu me, tstate
  me.pQuitting = 0
  me.clearTriggers(1)
  me.clearRestrictions(1)
  me.getInterface().showMenu(tstate)
end

on setTopicResult me, tBoolReward
  tConn = getConnection(getVariable("connection.info.id"))
  if voidp(tConn) then
    return error(me, "Connection not found.", #stopTutorial, #major)
  end if
  tConn.send("GET_TUTORIAL_STATUS", [#integer: me.pTutorialID])
end

on setTutorialStatus me, tStatusList
  me.pTopicStatuses = tStatusList
end

on getProperty me, tProp
  case tProp of
    #topics:
      return me.pTopics
    #statuses:
      return me.pTopicStatuses
  end case
end

on sendTrackingRequest me, tCase
  case tCase of
    #step:
      tTopicName = me.pTopics.getaProp(me.pTopicID)
      tTrackMsg = ((("/client/tutorial/" & tTopicName) & "/") & string(me.pCurrentStepNumber))
    #topicCompleted:
      tTopicName = me.pTopics.getaProp(me.pTopicID)
      tTrackMsg = (("/client/tutorial/" & tTopicName) & "/completed")
    #quit:
      tTrackMsg = "/client/tutorial/closed"
    #restart:
      tTrackMsg = "/client/tutorial/restarted"
  end case
  return 0
  executeMessage(#sendTrackingPoint, tTrackMsg)
  return 1
end

on tryExit me
  if me.pQuitting then
    me.selectTopic(#quit)
    return 1
  end if
  me.pQuitting = 1
  tPrerequisites = [:]
  tPrerequisites.setaProp(#hide_navigator, VOID)
  tPrerequisites.setaProp(#hide_purse, VOID)
  tPrerequisites.setaProp(#hide_messenger, VOID)
  tBubbles = [:]
  tBubble = [:]
  tBubble.setaProp(#textKey, "tutorial_help_button_bubble")
  tBubble.setaProp(#targetID, "help_icon_image")
  tBubble.setaProp(#direction, 5)
  tBubble.setaProp(#offsetx, 0)
  tBubble.setaProp(#offsety, 0)
  tBubbles.setaProp(#help, tBubble)
  tBubble = [:]
  tBubble.setaProp(#textKey, "tutorial_restart_button_bubble")
  tBubble.setaProp(#targetID, "help_restart_tutorial")
  tBubble.setaProp(#direction, 6)
  tBubble.setaProp(#offsetx, 50)
  tBubble.setaProp(#offsety, 0)
  tBubbles.setaProp(#restart, tBubble)
  tTutor = [:]
  tTutor.setaProp(#textKey, "tutorial_quit_confirmation")
  tTutor.setaProp(#targetID, "tutor")
  tTutor.setaProp(#direction, 1)
  tTutor.setaProp(#offsetx, 20)
  tTutor.setaProp(#offsety, 310)
  tTutor.setaProp(#links, [#quit: "tutorial_quit", #Cancel: "cancel"])
  me.clearTriggers(1)
  me.clearRestrictions(1)
  me.executePrerequisites(tPrerequisites)
  me.getInterface().setBubbles(tBubbles)
  me.getInterface().setTutor(tTutor)
end

on sendConsoleMessage me, tTextKey
  return 0
  if not objectExists(#messenger_component) then
    return error(me, "Messenger component not found", #sendConsoleMessage, #major)
  end if
  if (getObject(#messenger_component).pItemList[#messages].count > 0) then
    return 1
  end if
  tText = getText(tTextKey)
  tMsg = [#campaign: 1, #id: "3", #url: "http://www.fi", #message: tText]
  getObject("messenger_component").receive_Message(tMsg)
end

on openGuestroomsTab me
  executeMessage(#show_navigator)
  getObject(#navigator_interface).ChangeWindowView("nav_gr0")
  getObject(#navigator_component).expandHistoryItem(1)
  executeMessage(#hide_navigator)
end

on openPublicroomsTab me
  executeMessage(#show_navigator)
  getObject(#navigator_interface).ChangeWindowView("nav_pr")
  getObject(#navigator_component).expandHistoryItem(1)
  executeMessage(#hide_navigator)
end

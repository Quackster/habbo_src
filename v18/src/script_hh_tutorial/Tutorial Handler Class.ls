on construct me 
  me.registerServerMessages(1)
  return(1)
end

on deconstruct me 
  return(me.registerServerMessages(0))
end

on handleAccountPreferences me, tMsg 
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return(error(me, "Connection not found.", #handleAccountPreferences, #major))
  end if
  tSounds = tConn.GetBoolFrom()
  tTutorial = tConn.GetIntFrom()
  me.getComponent().setEnabled(tTutorial)
end

on handleTutorialConfig me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tConfig = [:]
  tTutorialID = tConn.GetIntFrom()
  tTutorialName = tConn.GetStrFrom()
  tNumOfTopics = tConn.GetIntFrom()
  tTopicList = [:]
  tStatusList = [:]
  tTopic = 1
  repeat while tTopic <= tNumOfTopics
    tTopicID = tConn.GetIntFrom()
    tTopicName = tConn.GetStrFrom()
    tTopicStatus = tConn.GetIntFrom()
    tTopicList.setaProp(tTopicID, tTopicName)
    tStatusList.setaProp(tTopicID, tTopicStatus)
    tTopic = 1 + tTopic
  end repeat
  tConfig.setaProp(#id, tTutorialID)
  tConfig.setaProp(#name, tTutorialName)
  tConfig.setaProp(#topics, tTopicList)
  tConfig.setaProp(#statuses, tStatusList)
  me.getComponent().setTutorialConfig(tConfig)
end

on handleTopicConfig me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tTopic = [:]
  tSteps = [:]
  tTopicID = tConn.GetIntFrom()
  tNumOfSteps = tConn.GetIntFrom()
  tStepNum = 1
  repeat while tStepNum <= tNumOfSteps
    tStepID = tConn.GetIntFrom()
    tStepName = tConn.GetStrFrom()
    tNumOfPrerequisites = tConn.GetIntFrom()
    tPreList = [:]
    tPre = 1
    repeat while tPre <= tNumOfPrerequisites
      tMessage = tConn.GetStrFrom()
      tParam = tConn.GetStrFrom()
      tPreList.setaProp(tMessage, tParam)
      tPre = 1 + tPre
    end repeat
    tNumOfTriggers = tConn.GetIntFrom()
    tTriggerList = []
    tTrig = 1
    repeat while tTrig <= tNumOfTriggers
      tTriggerList.add(tConn.GetStrFrom())
      tTrig = 1 + tTrig
    end repeat
    tNumOfRestrictions = tConn.GetIntFrom()
    tRestList = []
    tRest = 1
    repeat while tRest <= tNumOfRestrictions
      tRestList.add(tConn.GetStrFrom())
      tRest = 1 + tRest
    end repeat
    tNumOfContent = tConn.GetIntFrom()
    tContentList = []
    tCont = 1
    repeat while tCont <= tNumOfContent
      tContent = [:]
      tContent.setaProp(#textKey, tConn.GetStrFrom())
      tContent.setaProp(#targetID, tConn.GetStrFrom())
      tContent.setaProp(#direction, tConn.GetStrFrom())
      tContent.setaProp(#offsetx, tConn.GetStrFrom())
      tContent.setaProp(#offsety, tConn.GetStrFrom())
      tContent.setaProp(#special, tConn.GetStrFrom())
      if tContent.getAt(#targetID) = "tutor" then
        tContent.setaProp(#links, void())
        tTutorList = tContent
      else
        tContentList.add(tContent)
      end if
      tCont = 1 + tCont
    end repeat
    tStep = [:]
    tStep.setaProp(#name, tStepName)
    tStep.setaProp(#prerequisites, tPreList)
    tStep.setaProp(#triggers, tTriggerList)
    tStep.setaProp(#restrictions, tRestList)
    tStep.setaProp(#content, tContentList)
    tStep.setaProp(#tutor, tTutorList)
    tSteps.setaProp(tStepID, tStep)
    tStepNum = 1 + tStepNum
  end repeat
  tTopic.setaProp(#id, tTopicID)
  tTopic.setaProp(#steps, tSteps)
  me.getComponent().setTopicConfig(tTopic)
end

on handleTutorialStatus me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tTutorialID = tConn.GetIntFrom()
  tNumOfStatuses = tConn.GetIntFrom()
  tStatusList = [:]
  tStatusNum = 1
  repeat while tStatusNum <= tNumOfStatuses
    tID = tConn.GetIntFrom()
    tStatus = tConn.GetIntFrom()
    tStatusList.setaProp(tID, tStatus)
    tStatusNum = 1 + tStatusNum
  end repeat
  me.getComponent().setTutorialStatus(tStatusList)
end

on handleTopicResult me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tUserRewarded = tConn.GetIntFrom()
  me.getComponent().setTopicResult(tUserRewarded)
end

on registerServerMessages me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(308, #handleAccountPreferences)
  tMsgs.setaProp(327, #handleTutorialConfig)
  tMsgs.setaProp(328, #handleTopicConfig)
  tMsgs.setaProp(329, #handleTutorialStatus)
  tMsgs.setaProp(330, #handleTopicResult)
  tCmds = [:]
  tCmds.setaProp("GET_ACCOUNT_PREFERENCES", 228)
  tCmds.setaProp("SET_TUTORIAL_MODE", 249)
  tCmds.setaProp("GET_TUTORIAL_CONFIGURATION", 250)
  tCmds.setaProp("GET_TUTORIAL_TOPIC_CONFIGURATION", 251)
  tCmds.setaProp("GET_TUTORIAL_STATUS", 252)
  tCmds.setaProp("COMPLETE_TUTORIAL_TOPIC", 253)
  if tBool then
    registerListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
  end if
  return(1)
end

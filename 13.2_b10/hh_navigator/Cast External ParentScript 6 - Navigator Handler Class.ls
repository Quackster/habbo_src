property pLastRoomForwardTimeStamp

on construct me
  pLastRoomForwardTimeStamp = 0
  return me.regMsgList(1)
end

on deconstruct me
  pLastRoomForwardTimeStamp = 0
  return me.regMsgList(0)
end

on handle_flatinfo me, tMsg
  tConn = tMsg.connection
  tFlat = [:]
  tFlat[#ableothersmovefurniture] = tConn.GetIntFrom()
  tFlat[#door] = tConn.GetIntFrom()
  tFlat[#flatId] = string(tConn.GetIntFrom())
  tFlat[#id] = "f_" & tFlat[#flatId]
  tFlat[#owner] = tConn.GetStrFrom()
  tFlat[#marker] = tConn.GetStrFrom()
  tFlat[#name] = tConn.GetStrFrom()
  tFlat[#description] = tConn.GetStrFrom()
  tFlat[#showownername] = tConn.GetIntFrom()
  tFlat[#trading] = tConn.GetIntFrom()
  tFlat[#alert] = tConn.GetIntFrom()
  tFlat[#maxVisitors] = tConn.GetIntFrom()
  tFlat[#absoluteMaxVisitors] = tConn.GetIntFrom()
  tFlat[#nodeType] = 2
  case tFlat[#door] of
    0:
      tFlat[#door] = "open"
    1:
      tFlat[#door] = "closed"
    2:
      tFlat[#door] = "password"
  end case
  if tFlat[#maxVisitors] < 1 then
    tFlat[#maxVisitors] = 25
  end if
  if tFlat[#absoluteMaxVisitors] < 1 then
    tFlat[#absoluteMaxVisitors] = 50
  end if
  if (tFlat[#alert] = 1) and (tFlat[#owner] = getObject(#session).GET(#user_name)) then
    executeMessage(#setEnterRoomAlert, "alert_no_category")
  end if
  me.getComponent().updateSingleSubNodeInfo(tFlat)
  me.getComponent().getInfoBroker().processNavigatorData(tFlat)
  return 1
end

on handle_flat_results me, tMsg
  tResult = [:]
  tList = [:]
  tDelim = the itemDelimiter
  the itemDelimiter = TAB
  tContent = tMsg.content
  repeat with i = 1 to tContent.line.count
    tLine = tContent.line[i]
    if (tLine.item.count > 0) and (tLine.item.count < 9) then
      nothing()
      next repeat
    end if
    if tLine = EMPTY then
      exit repeat
    end if
    tFlat = [:]
    tFlat[#id] = "f_" & tLine.item[1]
    tFlat[#flatId] = tLine.item[1]
    tFlat[#name] = tLine.item[2]
    tFlat[#owner] = tLine.item[3]
    tFlat[#door] = tLine.item[4]
    tFlat[#port] = tLine.item[5]
    tFlat[#usercount] = tLine.item[6]
    tFlat[#maxUsers] = tLine.item[7]
    tFlat[#Filter] = tLine.item[8]
    tFlat[#description] = tLine.item[9]
    tFlat[#nodeType] = 2
    tList[tFlat[#id]] = tFlat
  end repeat
  tResult.addProp(#children, tList)
  case tMsg.subject of
    16:
      tResult[#id] = #own
    55:
      tResult[#id] = #src
  end case
  the itemDelimiter = tDelim
  me.getComponent().saveNodeInfo(tResult)
end

on handle_favouriteroomresults me, tMsg
  tConn = tMsg.connection
  tNodeMask = tConn.GetIntFrom()
  tNodeId = tConn.GetIntFrom()
  tNodeType = tConn.GetIntFrom()
  tNodeInfo = [#id: string(tNodeId), #nodeType: tNodeType, #name: tConn.GetStrFrom(), #usercount: tConn.GetIntFrom(), #maxUsers: tConn.GetIntFrom(), #parentid: string(tConn.GetIntFrom())]
  tResult = [#id: #fav, #children: [:]]
  if tNodeType = 2 then
    tResult[#children] = me.parseFlatCategoryNode(tMsg)
  end if
  repeat while tConn <> VOID
    tNode = me.parseNode(tMsg)
    if listp(tNode) then
      tResult[#children].addProp(tNode[#id], tNode)
      next repeat
    end if
    exit repeat
  end repeat
  return me.getComponent().saveNodeInfo(tResult)
end

on handle_noflatsforuser me, tMsg
  me.getComponent().noflatsforuser()
end

on handle_noflats me, tMsg
  me.getComponent().noflats()
end

on handle_flatpassword_ok me, tMsg
  me.getComponent().flatAccessResult("flatpassword_ok")
end

on handle_navnodeinfo me, tMsg
  tConn = tMsg.connection
  tCategoryIndex = [:]
  tNodeMask = tConn.GetIntFrom()
  tNodeInfo = me.parseNode(tMsg)
  if tNodeInfo = 0 then
    return 0
  end if
  tNodeInfo.addProp(#nodeMask, tNodeMask)
  tCategoryId = tNodeInfo[#id]
  tCategoryIndex.setaProp(tCategoryId, [#name: tNodeInfo[#name], #parentid: tNodeInfo[#parentid], #children: []])
  repeat while tConn <> VOID
    tNode = me.parseNode(tMsg)
    if tNode = 0 then
      exit repeat
    end if
    tNodeId = tNode[#id]
    tParentId = tNode[#parentid]
    if tParentId = tCategoryId then
      tNodeInfo[#children].setaProp(tNodeId, tNode)
    end if
    if tCategoryIndex[tParentId] <> 0 then
      tCategoryIndex[tParentId][#children].add(tNodeId)
    end if
    if (tNode[#nodeType] = 0) or ((tNode[#nodeType] = 1) and (tCategoryIndex[tNodeId] = 0)) then
      tCategoryIndex.setaProp(tNodeId, [#name: tNode[#name], #parentid: tParentId, #children: []])
    end if
  end repeat
  me.getComponent().updateCategoryIndex(tCategoryIndex)
  me.getComponent().saveNodeInfo(tNodeInfo)
  me.getComponent().getInfoBroker().processNavigatorData(tNodeInfo)
  return 1
end

on handle_error me, tMsg
  tErr = tMsg.content
  error(me, tMsg.connection.getID() & ":" && tErr, #handle_error)
  case tErr of
    "Only 10 favorite rooms allowed!", "nav_error_toomanyfavrooms":
      executeMessage(#alert, [#Msg: getText("nav_error_toomanyfavrooms")])
  end case
  return 1
end

on parseNode me, tMsg
  tConn = tMsg.connection
  tNodeId = tConn.GetIntFrom()
  if tNodeId <= 0 then
    return 0
  end if
  tNodeType = tConn.GetIntFrom()
  tNodeInfo = [#id: string(tNodeId), #nodeType: tNodeType, #name: tConn.GetStrFrom(), #usercount: tConn.GetIntFrom(), #maxUsers: tConn.GetIntFrom(), #parentid: string(tConn.GetIntFrom())]
  case tNodeType of
    0:
      tNodeInfo.addProp(#children, [:])
    1:
      tNodeInfo.addProp(#unitStrId, tConn.GetStrFrom())
      tNodeInfo.addProp(#port, tConn.GetIntFrom())
      tNodeInfo.addProp(#door, tConn.GetIntFrom())
      tCasts = tConn.GetStrFrom()
      tNodeInfo.addProp(#casts, [])
      tDelim = the itemDelimiter
      the itemDelimiter = ","
      repeat with c = 1 to tCasts.item.count
        tNodeInfo[#casts].add(tCasts.item[c])
      end repeat
      the itemDelimiter = tDelim
      tNodeInfo.addProp(#usersInQueue, tConn.GetIntFrom())
      tNodeInfo.addProp(#isVisible, tConn.GetBoolFrom())
    2:
      tNodeInfo[#nodeType] = 0
      tFlatList = me.parseFlatCategoryNode(tMsg)
      tNodeInfo.addProp(#children, tFlatList)
  end case
  return tNodeInfo
end

on parseFlatCategoryNode me, tMsg
  tConn = tMsg.connection
  tFlatCount = tConn.GetIntFrom()
  tFlatList = [:]
  repeat with i = 1 to tFlatCount
    tFlatID = string(tConn.GetIntFrom())
    tFlatInfo = [:]
    tFlatInfo[#id] = "f_" & tFlatID
    tFlatInfo[#flatId] = tFlatID
    tFlatInfo[#name] = tConn.GetStrFrom()
    tFlatInfo[#owner] = tConn.GetStrFrom()
    tFlatInfo[#door] = tConn.GetStrFrom()
    tFlatInfo[#usercount] = tConn.GetIntFrom()
    tFlatInfo[#maxUsers] = tConn.GetIntFrom()
    tFlatInfo[#description] = tConn.GetStrFrom()
    tFlatInfo[#nodeType] = 2
    tFlatList.addProp("f_" & tFlatID, tFlatInfo)
  end repeat
  return tFlatList
end

on handle_userflatcats me, tMsg
  tList = [:]
  tConn = tMsg.getaProp(#connection)
  tItemCount = tConn.GetIntFrom()
  repeat with t = 1 to tItemCount
    tNodeId = tConn.GetIntFrom()
    tNodeName = tConn.GetStrFrom()
    tList.addProp(string(tNodeId), tNodeName)
  end repeat
  getObject(#session).set("user_flat_cats", tList)
  return 1
end

on handle_flatcat me, tMsg
  tConn = tMsg.getaProp(#connection)
  tFlatID = tConn.GetIntFrom()
  tCategoryId = tConn.GetIntFrom()
  me.getComponent().setNodeProperty("f_" & tFlatID, #parentid, tCategoryId)
  executeMessage(#flatcat_received, [#flatId: tFlatID, #id: "f_" & tFlatID, #parentid: tCategoryId])
  return 1
end

on handle_spacenodeusers me, tMsg
  tConn = tMsg.getaProp(#connection)
  tNodeId = string(tConn.GetIntFrom())
  tUserCount = tConn.GetIntFrom()
  tUserList = []
  repeat with i = 1 to tUserCount
    tUserList.append(tConn.GetStrFrom())
  end repeat
  me.getInterface().showSpaceNodeUsers(tNodeId, tUserList)
  return 1
end

on handle_cantconnect me, tMsg
  tConn = tMsg.getaProp(#connection)
  tError = tConn.GetIntFrom()
  executeMessage(#leaveRoom)
  case tError of
    1:
      tError = "nav_error_room_full"
    2:
      tError = "nav_error_room_closed"
    3:
      tError = "queue_set." & tConn.GetStrFrom() & ".alert"
  end case
  return executeMessage(#alert, [#id: "nav_error", #Msg: tError])
end

on handle_success me, tMsg
  tConn = tMsg.getaProp(#connection)
  tMsgId = tConn.GetIntFrom()
  return 1
end

on handle_failure me, tMsg
  tConn = tMsg.getaProp(#connection)
  tMsgId = tConn.GetIntFrom()
  tErrorTxt = tConn.GetStrFrom()
  if tErrorTxt <> EMPTY then
    executeMessage(#alert, [#Msg: tErrorTxt])
  end if
  return 1
end

on handle_parentchain me, tMsg
  tConn = tMsg.getaProp(#connection)
  tChildId = string(tConn.GetIntFrom())
  tNodeName = tConn.GetStrFrom()
  tCategoryIndex = [:]
  repeat while tConn <> VOID
    tid = tConn.GetIntFrom()
    if tid <= 0 then
      exit repeat
    end if
    tid = string(tid)
    tName = tConn.GetStrFrom()
    if tCategoryIndex[tChildId] <> VOID then
      tCategoryIndex[tChildId].setaProp(#parentid, tid)
    end if
    tCategoryIndex.addProp(tid, [#name: tName, #parentid: tid, #children: [tChildId]])
    tChildId = tid
  end repeat
  return me.getComponent().updateCategoryIndex(tCategoryIndex)
end

on handle_roomforward me, tMsg
  tTimeSinceLast = the milliSeconds - pLastRoomForwardTimeStamp
  tTimeout = getVariable("navigator.room.forward.timeout")
  if tTimeSinceLast < tTimeout then
    return 0
  else
    pLastRoomForwardTimeStamp = the milliSeconds
  end if
  tConn = tMsg.connection
  tIsPublic = tConn.GetIntFrom()
  if tIsPublic > 0 then
    tStrRoomType = #public
  else
    tStrRoomType = #private
  end if
  tStrRoomId = string(tConn.GetIntFrom())
  return executeMessage(#roomForward, tStrRoomId, tStrRoomType)
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(16, #handle_flat_results)
  tMsgs.setaProp(33, #handle_error)
  tMsgs.setaProp(54, #handle_flatinfo)
  tMsgs.setaProp(55, #handle_flat_results)
  tMsgs.setaProp(57, #handle_noflatsforuser)
  tMsgs.setaProp(58, #handle_noflats)
  tMsgs.setaProp(61, #handle_favouriteroomresults)
  tMsgs.setaProp(130, #handle_flatpassword_ok)
  tMsgs.setaProp(220, #handle_navnodeinfo)
  tMsgs.setaProp(221, #handle_userflatcats)
  tMsgs.setaProp(222, #handle_flatcat)
  tMsgs.setaProp(223, #handle_spacenodeusers)
  tMsgs.setaProp(224, #handle_cantconnect)
  tMsgs.setaProp(225, #handle_success)
  tMsgs.setaProp(226, #handle_failure)
  tMsgs.setaProp(227, #handle_parentchain)
  tMsgs.setaProp(286, #handle_roomforward)
  tCmds = [:]
  tCmds.setaProp("SBUSYF", 13)
  tCmds.setaProp("SUSERF", 16)
  tCmds.setaProp("SRCHF", 17)
  tCmds.setaProp("GETFVRF", 18)
  tCmds.setaProp("ADD_FAVORITE_ROOM", 19)
  tCmds.setaProp("DEL_FAVORITE_ROOM", 20)
  tCmds.setaProp("GETFLATINFO", 21)
  tCmds.setaProp("DELETEFLAT", 23)
  tCmds.setaProp("UPDATEFLAT", 24)
  tCmds.setaProp("SETFLATINFO", 25)
  tCmds.setaProp("NAVIGATE", 150)
  tCmds.setaProp("GETUSERFLATCATS", 151)
  tCmds.setaProp("GETFLATCAT", 152)
  tCmds.setaProp("SETFLATCAT", 153)
  tCmds.setaProp("GETSPACENODEUSERS", 154)
  tCmds.setaProp("REMOVEALLRIGHTS", 155)
  tCmds.setaProp("GETPARENTCHAIN", 156)
  if tBool then
    registerListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
  end if
  return 1
end

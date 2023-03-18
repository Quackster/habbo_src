property pRemoteControlledUsers

on construct me
  pRemoteControlledUsers = []
  return me.regMsgList(1)
end

on deconstruct me
  pRemoteControlledUsers = []
  return me.regMsgList(0)
end

on handle_opc_ok me, tMsg
  if me.getComponent().getRoomID() = "private" then
    me.getComponent().roomConnected(VOID, "OPC_OK")
  end if
end

on handle_clc me
  me.getComponent().roomDisconnected()
end

on handle_youaremod me, tMsg
  return 1
end

on handle_flat_letin me, tMsg
  tConn = tMsg.connection
  tName = tConn.GetStrFrom()
  me.getInterface().showDoorBellAccepted(tName)
  if tName <> EMPTY then
    return 1
  end if
  return me.getComponent().roomConnected(VOID, "FLAT_LETIN")
end

on handle_room_ready me, tMsg
  me.getComponent().roomConnected(tMsg.content.word[1], "ROOM_READY")
end

on handle_logout me, tMsg
  tuser = tMsg.content.word[1]
  if tuser <> getObject(#session).GET("user_index") then
    me.getComponent().removeUserObject(tuser)
  end if
end

on handle_disconnect me
  me.getComponent().roomDisconnected()
end

on handle_error me, tMsg
  tErr = tMsg.content
  error(me, tMsg.connection.getID() & ":" && tErr, #handle_error)
  case tErr of
    "info: No place for stuff":
      me.getInterface().stopObjectMover()
    "Incorrect flat password":
      if threadExists(#navigator) then
        getThread(#navigator).getComponent().flatAccessResult(tErr)
      end if
    "Password required":
      if threadExists(#navigator) then
        getThread(#navigator).getComponent().flatAccessResult(tErr)
      end if
    "weird error":
      executeMessage(#leaveRoom)
    "Not owner":
      getObject(#session).set("room_controller", 0)
      me.getInterface().hideInterface(#hide)
  end case
end

on handle_doorbell_ringing me, tMsg
  if tMsg.content = EMPTY then
    return me.getInterface().showDoorBellWaiting()
  else
    return me.getInterface().showDoorBellDialog(tMsg.content)
  end if
end

on handle_flatnotallowedtoenter me, tMsg
  tConn = tMsg.connection
  tName = tConn.GetStrFrom()
  return me.getInterface().showDoorBellRejected(tName)
end

on handle_status me, tMsg
  tList = []
  tCount = tMsg.content.line.count
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  repeat with i = 1 to tCount
    tLine = tMsg.content.line[i]
    if length(tLine) > 5 then
      tuser = [:]
      tuser[#id] = tLine.item[1].word[1]
      tloc = tLine.item[1].word[2]
      the itemDelimiter = ","
      tuser[#x] = integer(tloc.item[1])
      tuser[#y] = integer(tloc.item[2])
      tuser[#h] = getLocalFloat(tloc.item[3])
      tuser[#dirHead] = integer(tloc.item[4]) mod 8
      tuser[#dirBody] = integer(tloc.item[5]) mod 8
      tActions = []
      the itemDelimiter = "/"
      repeat with j = 2 to tLine.item.count
        if length(tLine.item[j]) > 1 then
          tActions.add([#name: tLine.item[j].word[1], #params: tLine.item[j]])
        end if
      end repeat
      tuser[#actions] = tActions
      tList.add(tuser)
    end if
  end repeat
  the itemDelimiter = tDelim
  repeat with tuser in tList
    if not (pRemoteControlledUsers.getOne(tuser[#id]) > 0) then
      tUserObj = me.getComponent().getUserObject(tuser[#id])
      if tUserObj <> 0 then
        tUserObj.resetValues(tuser[#x], tuser[#y], tuser[#h], tuser[#dirHead], tuser[#dirBody])
        repeat with tAction in tuser[#actions]
          call(symbol("action_" & tAction[#name]), [tUserObj], tAction[#params])
        end repeat
        tUserObj.Refresh(tuser[#x], tuser[#y], tuser[#h])
      end if
    end if
  end repeat
end

on handle_chat me, tMsg
  tConn = tMsg.getaProp(#connection)
  tuser = string(tConn.GetIntFrom())
  tChat = tConn.GetStrFrom()
  if me.getInterface().getIgnoreStatus(tuser) then
    return 0
  end if
  case tMsg.getaProp(#subject) of
    24:
      tMode = "CHAT"
    25:
      tMode = "WHISPER"
    26:
      tMode = "SHOUT"
  end case
  if me.getComponent().userObjectExists(tuser) then
    me.getComponent().getBalloon().createBalloon([#command: tMode, #id: tuser, #message: tChat])
  end if
end

on handle_users me, tMsg
  tCount = tMsg.content.line.count
  tDelim = the itemDelimiter
  tList = [:]
  tuser = EMPTY
  if not objectExists("Figure_System") then
    return error(me, "Figure system object not found!", #handle_users)
  end if
  repeat with f = 1 to tCount
    tLine = tMsg.content.line[f]
    tProp = tLine.char[1]
    tdata = tLine.char[3..length(tLine)]
    case tProp of
      "i":
        tuser = tdata
        tList[tuser] = [:]
        tList[tuser][#direction] = [0, 0]
        tList[tuser][#id] = tdata
      "n":
        tList[tuser][#name] = tdata
        if tdata contains numToChar(4) then
          tList[tuser][#class] = "pet"
        else
          tList[tuser][#class] = "user"
        end if
      "f":
        tList[tuser][#figure] = tdata
      "l":
        tList[tuser][#x] = integer(tdata.word[1])
        tList[tuser][#y] = integer(tdata.word[2])
        tList[tuser][#h] = getLocalFloat(tdata.word[3])
      "c":
        tList[tuser][#custom] = tdata
      "s":
        if (tdata.char[1] = "F") or (tdata.char[1] = "f") then
          tList[tuser][#sex] = "F"
        else
          tList[tuser][#sex] = "M"
        end if
      "p":
        if tdata contains "ch=s" then
          the itemDelimiter = "/"
          tmodel = tdata.char[4..6]
          tColor = tdata.item[2]
          the itemDelimiter = ","
          if tColor.item.count = 3 then
            tColor = value("rgb(" & tColor & ")")
          else
            tColor = rgb("#EEEEEE")
          end if
          tList[tuser][#phfigure] = ["model": tmodel, "color": tColor]
          tList[tuser][#class] = "pelle"
        end if
      "b":
        tList[tuser][#badge] = tdata
      "a":
        tList[tuser][#webID] = tdata
      "g":
        tList[tuser][#groupid] = tdata
      "t":
        tList[tuser][#groupstatus] = tdata
      otherwise:
        if tLine.word[1] = "[bot]" then
          tList[tuser][#class] = "bot"
        end if
    end case
  end repeat
  tFigureParser = getObject("Figure_System")
  repeat with tObject in tList
    tObject[#figure] = tFigureParser.parseFigure(tObject[#figure], tObject[#sex], tObject[#class])
  end repeat
  the itemDelimiter = tDelim
  if count(tList) = 0 then
    me.getComponent().validateUserObjects(0)
  else
    tName = getObject(#session).GET(#userName)
    repeat with tuser in tList
      if tuser[#name] = tName then
        getObject(#session).set("user_index", tuser[#id])
      end if
      me.getComponent().validateUserObjects(tuser)
      if me.getComponent().getPickedCryName() = tuser[#name] then
        me.getComponent().showCfhSenderDelayed(tuser[#id])
      end if
      if tuser[#name] = tName then
        me.getInterface().eventProcUserObj(#selection, tuser[#id], #userEnters)
      end if
    end repeat
  end if
end

on handle_showprogram me, tMsg
  tLine = tMsg.content
  tDst = tLine.word[1]
  tCmd = tLine.word[2]
  tArg = tLine.word[3..tLine.word.count]
  tdata = [#command: "SHOWPROGRAM", #show_dest: tDst, #show_command: tCmd, #show_params: tArg]
  tObj = me.getComponent().getRoomPrg()
  if objectp(tObj) then
    call(#showprogram, [tObj], tdata)
  end if
end

on handle_no_user_for_gift me, tMsg
  tUserName = tMsg.content
  tAlertString = getText("no_user_for_gift")
  tAlertString = replaceChunks(tAlertString, "%user%", tUserName)
  executeMessage(#alert, [#Msg: tAlertString])
end

on handle_heightmap me, tMsg
  me.getComponent().validateHeightMap(tMsg.content)
end

on handle_heightmapupdate me, tMsg
  me.getComponent().updateHeightMap(tMsg.content)
end

on handle_OBJECTS me, tMsg
  tList = []
  tCount = tMsg.content.line.count
  repeat with i = 1 to tCount
    tLine = tMsg.content.line[i]
    if length(tLine) > 5 then
      tObj = [:]
      tObj[#id] = tLine.word[1]
      tObj[#class] = tLine.word[2]
      tObj[#x] = integer(tLine.word[3])
      tObj[#y] = integer(tLine.word[4])
      tObj[#h] = integer(tLine.word[5])
      if tLine.word.count = 6 then
        tdir = integer(tLine.word[6]) mod 8
        tObj[#direction] = [tdir, tdir, tdir]
        tObj[#dimensions] = 0
      else
        tWidth = integer(tLine.word[6])
        tHeight = integer(tLine.word[7])
        tObj[#dimensions] = [tWidth, tHeight]
        tObj[#x] = tObj[#x] + tObj[#width] - 1
        tObj[#y] = tObj[#y] + tObj[#height] - 1
      end if
      if tObj[#id] <> EMPTY then
        tList.add(tObj)
      end if
    end if
  end repeat
  if count(tList) > 0 then
    repeat with tObj in tList
      me.getComponent().validatePassiveObjects(tObj)
    end repeat
  else
    me.getComponent().validatePassiveObjects(0)
  end if
end

on parseActiveObject me, tConn
  if not tConn then
    return 0
  end if
  tObj = [:]
  tObj[#id] = tConn.GetStrFrom()
  tObj[#class] = tConn.GetStrFrom()
  tObj[#x] = tConn.GetIntFrom()
  tObj[#y] = tConn.GetIntFrom()
  tWidth = tConn.GetIntFrom()
  tHeight = tConn.GetIntFrom()
  tDirection = tConn.GetIntFrom() mod 8
  tObj[#direction] = [tDirection, tDirection, tDirection]
  tObj[#dimensions] = [tWidth, tHeight]
  tObj[#altitude] = getLocalFloat(tConn.GetStrFrom())
  tObj[#colors] = tConn.GetStrFrom()
  if tObj[#colors] = EMPTY then
    tObj[#colors] = "0"
  end if
  tRuntimeData = tConn.GetStrFrom()
  tExtra = tConn.GetIntFrom()
  tStuffData = tConn.GetStrFrom()
  tObj[#props] = [#runtimedata: tRuntimeData, #extra: tExtra, #stuffdata: tStuffData]
  return tObj
end

on handle_activeobjects me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tList = []
  tCount = tConn.GetIntFrom()
  repeat with i = 1 to tCount
    if tConn <> 0 then
      tObj = me.parseActiveObject(tConn)
      if listp(tObj) then
        tList.add(tObj)
      end if
    end if
  end repeat
  if count(tList) > 0 then
    repeat with tObj in tList
      me.getComponent().validateActiveObjects(tObj)
    end repeat
    executeMessage(#activeObjectsUpdated)
  else
    me.getComponent().validateActiveObjects(0)
  end if
end

on handle_activeobject_remove me, tMsg
  me.getComponent().removeActiveObject(tMsg.content.word[1])
  executeMessage(#activeObjectRemoved)
  return 1
end

on handle_activeobject_add me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tObj = me.parseActiveObject(tConn)
  if not listp(tObj) then
    return 0
  end if
  me.getComponent().validateActiveObjects(tObj)
  executeMessage(#activeObjectsUpdated)
  return 1
end

on handle_activeobject_update me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tObj = me.parseActiveObject(tConn)
  if not listp(tObj) then
    return 0
  end if
  tComponent = me.getComponent()
  if tComponent.activeObjectExists(tObj[#id]) then
    tObj = getThread(#buffer).getComponent().processObject(tObj, "active")
    tActiveObj = tComponent.getActiveObject(tObj[#id])
    tActiveObj.define(tObj)
    tComponent.removeSlideObject(tObj[#id])
    call(#movingFinished, [tActiveObj])
    executeMessage(#activeObjectsUpdated)
  else
    return error(me, "Active object not found:" && tObj[#id], #handle_activeobject_update)
  end if
end

on handle_items me, tMsg
  tList = []
  tDelim = the itemDelimiter
  repeat with i = 1 to tMsg.content.line.count
    the itemDelimiter = TAB
    tLine = tMsg.content.line[i]
    if tLine <> EMPTY then
      tObj = [:]
      tObj[#id] = tLine.item[1]
      tObj[#class] = tLine.item[2]
      tObj[#owner] = tLine.item[3]
      tObj[#type] = tLine.item[5]
      if not (tLine.item[4].char[1] = ":") then
        tObj[#direction] = tLine.item[4].word[1]
        if tObj[#direction] = "frontwall" then
          tObj[#direction] = "rightwall"
        end if
        tlocation = tLine.item[4].word[2..tLine.item[4].word.count]
        the itemDelimiter = ","
        tObj[#x] = 0
        tObj[#y] = tlocation.item[1]
        tObj[#h] = getLocalFloat(tlocation.item[2])
        tObj[#z] = integer(tlocation.item[3])
        tObj[#formatVersion] = #old
      else
        tLocString = tLine.item[4]
        tWallLoc = tLocString.word[1].char[4..length(tLocString.word[1])]
        the itemDelimiter = ","
        tObj[#wall_x] = value(tWallLoc.item[1])
        tObj[#wall_y] = value(tWallLoc.item[2])
        tLocalLoc = tLocString.word[2].char[3..length(tLocString.word[2])]
        tObj[#local_x] = value(tLocalLoc.item[1])
        tObj[#local_y] = value(tLocalLoc.item[2])
        tDirChar = tLocString.word[3]
        case tDirChar of
          "r":
            tObj[#direction] = "rightwall"
          "l":
            tObj[#direction] = "leftwall"
        end case
        tObj[#formatVersion] = #new
      end if
      tList.add(tObj)
    end if
  end repeat
  the itemDelimiter = tDelim
  if count(tList) > 0 then
    repeat with tItem in tList
      me.getComponent().validateItemObjects(tItem)
    end repeat
    executeMessage(#itemObjectsUpdated)
  else
    me.getComponent().validateItemObjects(0)
  end if
end

on handle_removeitem me, tMsg
  me.getComponent().removeItemObject(tMsg.content)
  executeMessage(#itemObjectRemoved)
  me.getInterface().stopObjectMover()
end

on handle_updateitem me, tMsg
  tItem = me.getComponent().getItemObject(tMsg.content.word[1])
  if objectp(tItem) then
    tItem.setState(the last word in the content of tMsg)
  end if
end

on handle_stuffdataupdate me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tTarget = tConn.GetStrFrom()
  tValue = tConn.GetStrFrom()
  if me.getComponent().activeObjectExists(tTarget) then
    call(#updateStuffdata, [me.getComponent().getActiveObject(tTarget)], tValue)
  else
    return error(me, "Active object not found:" && tTarget, #handle_stuffdataupdate)
  end if
end

on handle_presentopen me, tMsg
  ttype = tMsg.content.line[1]
  tCode = tMsg.content.line[2]
  tColors = tMsg.content.line[3]
  tCard = "PackageCardObj"
  if objectExists(tCard) then
    getObject(tCard).showContent([#type: ttype, #code: tCode, #color: tColors])
  else
    error(me, "Package card obj not found!", #handle_presentopen)
  end if
end

on handle_flatproperty me, tMsg
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tLine = tMsg.content
  tdata = [#key: tLine.item[1], #value: tLine.item[2]]
  the itemDelimiter = tDelim
  tRoomPrg = me.getComponent().getRoomPrg()
  if tRoomPrg <> 0 then
    tRoomPrg.setProperty(tdata[#key], tdata[#value])
  else
    error(me, "Private room program not found!", #handle_flatproperty)
  end if
end

on handle_room_rights me, tMsg
  case tMsg.subject of
    42:
      getObject(#session).set("room_controller", 1)
    43:
      getObject(#session).set("room_controller", 0)
    47:
      getObject(#session).set("room_owner", 1)
  end case
end

on handle_stripinfo me, tMsg
  tProps = [#objects: [], #count: 0]
  tDelim = the itemDelimiter
  tProps[#count] = integer(tMsg.content.line[tMsg.content.line.count])
  the itemDelimiter = "/"
  tCount = tMsg.content.item.count
  tStripMax = 0
  tTotalItemCount = 0
  repeat with i = 1 to tCount
    the itemDelimiter = "/"
    tItem = tMsg.content.item[i]
    if tItem = EMPTY then
      exit repeat
    end if
    the itemDelimiter = numToChar(30)
    if tItem.item.count < 2 then
      tTotalItemCount = integer(tItem - 1)
      exit repeat
    end if
    tObj = [:]
    tObj[#stripId] = tItem.item[2]
    tObjectPos = integer(tItem.item[3])
    tObj[#striptype] = tItem.item[4]
    tObj[#id] = tItem.item[5]
    tObj[#class] = tItem.item[6]
    case tObj[#striptype] of
      "S":
        tObj[#name] = getText("furni_" & tObj[#class] & "_name", "furni_" & tObj[#class] & "_name")
        tObj[#striptype] = "active"
        tObj[#custom] = getText("furni_" & tObj[#class] & "_name", "furni_" & tObj[#class] & "_desc")
        tObj[#dimensions] = [integer(tItem.item[7]), integer(tItem.item[8])]
        tObj[#stuffdata] = tItem.item[9]
        tObj[#colors] = tItem.item[10]
        tObj[#isRecyclable] = tItem.item[11]
        the itemDelimiter = ","
        if tObj[#colors].char[1] = "#" then
          if tObj[#colors].item.count > 1 then
            tObj[#stripColor] = rgb(tObj[#colors].item[tObj[#colors].item.count])
          else
            tObj[#stripColor] = rgb(tObj[#colors])
          end if
        else
          tObj[#stripColor] = 0
        end if
      "I":
        tObj[#striptype] = "item"
        tObj[#props] = tItem.item[7]
        tObj[#isRecyclable] = tItem.item[8]
        case tObj[#class] of
          "poster":
            tObj[#name] = getText("poster_" & tObj[#props] & "_name", "poster_" & tObj[#props] & "_name")
          otherwise:
            tObj[#name] = getText("wallitem_" & tObj[#class] & "_name", "wallitem_" & tObj[#class] & "_name")
        end case
    end case
    tProps[#objects].add(tObj)
    if tObjectPos > tStripMax then
      tStripMax = tObjectPos
    end if
  end repeat
  the itemDelimiter = tDelim
  tInventory = me.getInterface().getContainer()
  tInventory.setHandButton("next", tTotalItemCount > integer(tStripMax))
  tInventory.setHandButton("prev", integer(tStripMax) > 8)
  case tMsg.subject of
    140:
      tInventory.updateStripItems(tProps[#objects])
      tInventory.setStripItemCount(tProps[#count])
      tInventory.open(1)
      tInventory.Refresh()
    98:
      tInventory.appendStripItem(tProps[#objects][1])
      tInventory.open(1)
      tInventory.Refresh()
    108:
      return tProps
  end case
end

on handle_stripupdated me, tMsg
  tMsg.connection.send("GETSTRIP", "new")
end

on handle_removestripitem me, tMsg
  me.getInterface().getContainer().removeStripItem(tMsg.content.word[1])
  me.getInterface().getContainer().Refresh()
end

on handle_youarenotallowed me
  executeMessage(#alert, [#Msg: "trade_youarenotallowed", #id: "youarenotallowed"])
end

on handle_othernotallowed me
  executeMessage(#alert, [#Msg: "trade_othernotallowed", #id: "othernotallowed"])
end

on handle_idata me, tMsg
  tDelim = the itemDelimiter
  the itemDelimiter = TAB
  tid = integer(tMsg.content.line[1].item[1])
  ttype = tMsg.content.line[1].item[2]
  tText = tMsg.content.line[1].item[2] & RETURN & tMsg.content.line[2..tMsg.content.line.count]
  the itemDelimiter = tDelim
  executeMessage(symbol("itemdata_received" & tid), [#id: tid, #text: tText, #type: ttype])
end

on handle_trade_items me, tMsg
  tMessage = [:]
  repeat with i = 1 to 2
    tLine = tMsg.content.line[i]
    tdata = [:]
    tdata[#accept] = tLine.word[2]
    tItemStr = "foo" & RETURN & tLine.word[3..tLine.word.count] & RETURN & 1
    tdata[#items] = me.handle_stripinfo([#subject: 108, #content: tItemStr]).getaProp(#objects)
    if not listp(tdata[#items]) then
      return error(me, "Invalid itemdata from server!", #handle_trade_items)
    end if
    tUserName = tLine.word[1]
    if tUserName = EMPTY then
      return error(me, "No username from server", #handle_trade_items)
    end if
    if me.getInterface().getIgnoreStatus(VOID, tUserName) then
      return me.getComponent().getRoomConnection().send("TRADE_CLOSE")
    end if
    tMessage[tUserName] = tdata
  end repeat
  return me.getInterface().getSafeTrader().Refresh(tMessage)
end

on handle_trade_close me, tMsg
  me.getInterface().getSafeTrader().close()
  tMsg.connection.send("GETSTRIP", "new")
end

on handle_trade_accept me, tMsg
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tuser = tMsg.content.item[1]
  tValue = tMsg.content.item[2] = "true"
  the itemDelimiter = tDelim
  me.getInterface().getSafeTrader().accept(tuser, tValue)
end

on handle_trade_completed me, tMsg
  me.getInterface().getSafeTrader().complete()
end

on handle_door_in me, tMsg
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tDoor = tMsg.content.item[1]
  tuser = tMsg.content.item[2]
  the itemDelimiter = tDelim
  tDoorObj = me.getComponent().getActiveObject(tDoor)
  if tDoorObj <> 0 then
    tDoorObj.animate(18)
    if getObject(#session).GET("user_name") = tuser then
      tDoorObj.prepareToKick(tuser)
    end if
  end if
end

on handle_door_out me, tMsg
  tDelim = the itemDelimiter
  tDoor = me.getComponent().getActiveObject(tMsg.content.item[1])
  the itemDelimiter = "/"
  if tDoor <> 0 then
    return tDoor.animate()
  end if
end

on handle_doorflat me, tMsg
  tConn = tMsg.connection
  tTeleId = tConn.GetIntFrom()
  tFlatID = tConn.GetIntFrom()
  if not (tTeleId and tFlatID) then
    return error(me, "Retarded doorflat data!", #handle_doorflat)
  end if
  me.getComponent().startTeleport(tTeleId, tFlatID)
end

on handle_doordeleted me, tMsg
  if getObject(#session).exists("current_door_ID") then
    tDoorID = getObject(#session).GET("current_door_ID")
    tDoorObj = me.getComponent().getActiveObject(tDoorID)
    if tDoorObj <> 0 then
      tDoorObj.kickOut()
    end if
  end if
end

on handle_dice_value me, tMsg
  tid = tMsg.content.word[1]
  if tMsg.content.word.count = 1 then
    tValue = -1
  else
    tValue = integer(tMsg.content.word[2] - (tid * 38))
    if tValue > 6 then
      tValue = 0
    end if
  end if
  if me.getComponent().activeObjectExists(tid) then
    call(#diceThrown, [me.getComponent().getActiveObject(tid)], tValue)
  end if
end

on handle_roomad me, tMsg
  if tMsg.content.length > 1 then
    tDelim = the itemDelimiter
    the itemDelimiter = TAB
    tSourceURL = tMsg.content.item[1]
    tTargetURL = tMsg.content.item[2]
    the itemDelimiter = tDelim
    tLayoutID = me.getInterface().getRoomVisualizer().pLayout
    me.getComponent().getAd().Init(tSourceURL, tTargetURL, tLayoutID)
  else
    me.getComponent().getAd().Init(0)
  end if
end

on handle_petstat me, tMsg
  tPetObj = me.getComponent().getUserObject(tMsg.connection.GetIntFrom())
  if tPetObj = 0 then
    return error(me, "Pet object not found!", #handle_petstat)
  end if
  tName = tPetObj.getName()
  tAge = tMsg.connection.GetIntFrom()
  tHungry = getText("pet_hung_" & tMsg.connection.GetIntFrom(), "???")
  tThirsty = getText("pet_thir_" & tMsg.connection.GetIntFrom(), "???")
  tHappiness = getText("pet_mood_" & tMsg.connection.GetIntFrom(), "???")
  tNature01 = getText("pet_enrg_" & tMsg.connection.GetIntFrom(), "???")
  tNature02 = getText("pet_frnd_" & tMsg.connection.GetIntFrom(), "???")
  if createWindow("pet_status_dialog") then
    tWndObj = getWindow("pet_status_dialog")
    tWndObj.moveTo(8, 8)
    tWndObj.setProperty(#title, tName)
    if not tWndObj.merge("habbo_full.window") then
      return tWndObj.close()
    end if
    if not tWndObj.merge("petstatus.window") then
      return tWndObj.close()
    end if
    tWndObj.getElement("age").setText(tAge)
    tWndObj.getElement("hungry").setText(tHungry)
    tWndObj.getElement("thirsty").setText(tThirsty)
    tWndObj.getElement("happiness").setText(tHappiness)
    tWndObj.getElement("nature").setText(tNature01 & "," && tNature02)
    tWndObj.getElement("picture").feedImage(tPetObj.getPicture())
    registerMessage(#leaveRoom, tWndObj.getID(), #close)
    registerMessage(#changeRoom, tWndObj.getID(), #close)
  end if
end

on handle_userbadge me, tMsg
  if voidp(tMsg.connection) then
    return 0
  end if
  tUserID = string(tMsg.connection.GetIntFrom())
  tBadge = tMsg.connection.GetStrFrom()
  tUserObj = me.getComponent().getUserObject(tUserID)
  if not objectp(tUserObj) then
    return 0
  end if
  tUserObj.pBadge = tBadge
  me.getInterface().unignoreAdmin(tUserID, tBadge)
  me.getInterface().getInfoStandObject().updateInfoStandBadge(tBadge, tUserID)
end

on handle_slideobjectbundle me, tMsg
  tConn = tMsg.getaProp(#connection)
  tComponent = me.getComponent()
  tTimeNow = the milliSeconds
  tObjList = []
  tContainsObjects = 0
  tFromX = tConn.GetIntFrom()
  tFromY = tConn.GetIntFrom()
  tToX = tConn.GetIntFrom()
  tToY = tConn.GetIntFrom()
  tStuffCount = tConn.GetIntFrom()
  repeat with tCount = 1 to tStuffCount
    tObj = []
    tItemID = tConn.GetIntFrom()
    tItemFromH = getLocalFloat(tConn.GetStrFrom())
    tItemToH = getLocalFloat(tConn.GetStrFrom())
    tFrom = [tFromX, tFromY, tItemFromH]
    tTo = [tToX, tToY, tItemToH]
    tObj = [tItemID, tFrom, tTo]
    tObjList.add(tObj)
    tContainsObjects = 1
  end repeat
  tTileID = tConn.GetIntFrom()
  tTileObj = tComponent.getActiveObject(tTileID)
  if tTileObj <> 0 then
    if tTileObj.handler(#setAnimation) then
      call(#setAnimation, tTileObj, 1)
    end if
  end if
  tMoveType = tConn.GetIntFrom()
  case tMoveType of
    0:
      tHasCharacter = 0
    1:
      tMoveType = "mv"
      tHasCharacter = 1
    2:
      tMoveType = "sld"
      tHasCharacter = 1
    otherwise:
      return error(me, "Incompatible character movetype", #handle_slideobjectbundle)
  end case
  if tHasCharacter then
    tCharID = tConn.GetIntFrom()
    tFromH = getLocalFloat(tConn.GetStrFrom())
    tToH = getLocalFloat(tConn.GetStrFrom())
    tUserObj = me.getComponent().getUserObject(tCharID)
    if tUserObj <> 0 then
      tCommandStr = tMoveType && tToX & "," & tToY & "," & tToH && tContainsObjects.integer && tTimeNow
      call(symbol("action_" & tMoveType), [tUserObj], tCommandStr)
    end if
  end if
  repeat with tObj in tObjList
    tComponent.addSlideObject(tObj[1], tObj[2], tObj[3], tTimeNow, tHasCharacter)
  end repeat
end

on handle_interstitialdata me, tMsg
  if tMsg.content.length > 1 then
    tDelim = the itemDelimiter
    the itemDelimiter = TAB
    tSourceURL = tMsg.content.item[1]
    tTargetURL = tMsg.content.item[2]
    the itemDelimiter = tDelim
    me.getComponent().getInterstitial().Init(tSourceURL, tTargetURL)
  else
    me.getComponent().getInterstitial().Init(0)
  end if
end

on handle_roomqueuedata me, tMsg
  tConn = tMsg.getaProp(#connection)
  tSetCount = tConn.GetIntFrom()
  tQueueCollection = []
  repeat with i = 1 to tSetCount
    tQueueSetName = tConn.GetStrFrom()
    tQueueTarget = tConn.GetIntFrom()
    tNumberOfQueues = tConn.GetIntFrom()
    tQueueData = [:]
    tQueueSet = [:]
    repeat with t = 1 to tNumberOfQueues
      tQueueID = tConn.GetStrFrom()
      tQueueLength = tConn.GetIntFrom()
      tQueueData[tQueueID] = tQueueLength
    end repeat
    tQueueSet["name"] = tQueueSetName
    tQueueSet["target"] = tQueueTarget
    tQueueSet["data"] = tQueueData
    tQueueCollection[i] = tQueueSet
  end repeat
  me.getInterface().updateQueueWindow(tQueueCollection)
end

on handle_youarespectator me
  return me.getComponent().setSpectatorMode(1)
end

on handle_removespecs me
  me.getInterface().showRemoveSpecsNotice()
end

on handle_figure_change me, tMsg
  tConn = tMsg.connection
  tUserID = tConn.GetIntFrom()
  tUserFigure = tConn.GetStrFrom()
  tUserSex = tConn.GetStrFrom()
  tUserCustomInfo = tConn.GetStrFrom()
  me.getComponent().updateCharacterFigure(tUserID, tUserFigure, tUserSex, tUserCustomInfo)
end

on handle_spectator_amount me, tMsg
  tConn = tMsg.connection
  tSpecCount = tConn.GetIntFrom()
  tSpecMax = tConn.GetIntFrom()
  me.getComponent().updateSpectatorCount(tSpecCount, tSpecMax)
end

on handle_group_badges me, tMsg
  tConn = tMsg.connection
  tNumberOfGroups = tConn.GetIntFrom()
  tGroupData = []
  repeat with tNo = 1 to tNumberOfGroups
    tGroup = [:]
    tGroup[#id] = tConn.GetIntFrom()
    tGroup[#logo] = tConn.GetStrFrom()
    tGroupData.add(tGroup)
  end repeat
  me.getComponent().getGroupInfoObject().updateGroupInformation(tGroupData)
end

on handle_group_details me, tMsg
  tConn = tMsg.connection
  tGroupData = []
  tGroup = [:]
  tGroup[#id] = tConn.GetIntFrom()
  if tGroup[#id] = -1 then
    return 0
  end if
  tGroup[#name] = tConn.GetStrFrom()
  tGroup[#desc] = tConn.GetStrFrom()
  tGroupData.add(tGroup)
  me.getComponent().getGroupInfoObject().updateGroupInformation(tGroupData)
  executeMessage(#groupInfoRetrieved, tGroup[#id])
end

on handle_group_membership_update me, tMsg
  tConn = tMsg.connection
  tUserIndex = tConn.GetIntFrom()
  tGroupId = tConn.GetIntFrom()
  tStatus = tConn.GetIntFrom()
  tuser = me.getComponent().getUserObject(tUserIndex)
  if not voidp(tuser) then
    tuser.setProperty(#groupid, tGroupId)
    tuser.setProperty(#groupstatus, tStatus)
  end if
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(-1, #handle_disconnect)
  tMsgs.setaProp(18, #handle_clc)
  tMsgs.setaProp(19, #handle_opc_ok)
  tMsgs.setaProp(24, #handle_chat)
  tMsgs.setaProp(25, #handle_chat)
  tMsgs.setaProp(26, #handle_chat)
  tMsgs.setaProp(28, #handle_users)
  tMsgs.setaProp(29, #handle_logout)
  tMsgs.setaProp(30, #handle_OBJECTS)
  tMsgs.setaProp(31, #handle_heightmap)
  tMsgs.setaProp(32, #handle_activeobjects)
  tMsgs.setaProp(33, #handle_error)
  tMsgs.setaProp(34, #handle_status)
  tMsgs.setaProp(41, #handle_flat_letin)
  tMsgs.setaProp(45, #handle_items)
  tMsgs.setaProp(42, #handle_room_rights)
  tMsgs.setaProp(43, #handle_room_rights)
  tMsgs.setaProp(46, #handle_flatproperty)
  tMsgs.setaProp(47, #handle_room_rights)
  tMsgs.setaProp(48, #handle_idata)
  tMsgs.setaProp(62, #handle_doorflat)
  tMsgs.setaProp(63, #handle_doordeleted)
  tMsgs.setaProp(64, #handle_doordeleted)
  tMsgs.setaProp(69, #handle_room_ready)
  tMsgs.setaProp(70, #handle_youaremod)
  tMsgs.setaProp(71, #handle_showprogram)
  tMsgs.setaProp(76, #handle_no_user_for_gift)
  tMsgs.setaProp(83, #handle_items)
  tMsgs.setaProp(84, #handle_removeitem)
  tMsgs.setaProp(85, #handle_updateitem)
  tMsgs.setaProp(88, #handle_stuffdataupdate)
  tMsgs.setaProp(89, #handle_door_out)
  tMsgs.setaProp(90, #handle_dice_value)
  tMsgs.setaProp(91, #handle_doorbell_ringing)
  tMsgs.setaProp(92, #handle_door_in)
  tMsgs.setaProp(93, #handle_activeobject_add)
  tMsgs.setaProp(94, #handle_activeobject_remove)
  tMsgs.setaProp(95, #handle_activeobject_update)
  tMsgs.setaProp(98, #handle_stripinfo)
  tMsgs.setaProp(99, #handle_removestripitem)
  tMsgs.setaProp(101, #handle_stripupdated)
  tMsgs.setaProp(102, #handle_youarenotallowed)
  tMsgs.setaProp(103, #handle_othernotallowed)
  tMsgs.setaProp(105, #handle_trade_completed)
  tMsgs.setaProp(108, #handle_trade_items)
  tMsgs.setaProp(109, #handle_trade_accept)
  tMsgs.setaProp(110, #handle_trade_close)
  tMsgs.setaProp(112, #handle_trade_completed)
  tMsgs.setaProp(129, #handle_presentopen)
  tMsgs.setaProp(131, #handle_flatnotallowedtoenter)
  tMsgs.setaProp(140, #handle_stripinfo)
  tMsgs.setaProp(208, #handle_roomad)
  tMsgs.setaProp(210, #handle_petstat)
  tMsgs.setaProp(219, #handle_heightmapupdate)
  tMsgs.setaProp(228, #handle_userbadge)
  tMsgs.setaProp(230, #handle_slideobjectbundle)
  tMsgs.setaProp(258, #handle_interstitialdata)
  tMsgs.setaProp(259, #handle_roomqueuedata)
  tMsgs.setaProp(254, #handle_youarespectator)
  tMsgs.setaProp(283, #handle_removespecs)
  tMsgs.setaProp(266, #handle_figure_change)
  tMsgs.setaProp(298, #handle_spectator_amount)
  tMsgs.setaProp(309, #handle_group_badges)
  tMsgs.setaProp(310, #handle_group_membership_update)
  tMsgs.setaProp(311, #handle_group_details)
  tCmds = [:]
  tCmds.setaProp(#room_directory, 2)
  tCmds.setaProp("GETDOORFLAT", 28)
  tCmds.setaProp("CHAT", 52)
  tCmds.setaProp("SHOUT", 55)
  tCmds.setaProp("WHISPER", 56)
  tCmds.setaProp("QUIT", 53)
  tCmds.setaProp("GOVIADOOR", 54)
  tCmds.setaProp("TRYFLAT", 57)
  tCmds.setaProp("GOTOFLAT", 59)
  tCmds.setaProp("G_HMAP", 60)
  tCmds.setaProp("G_USRS", 61)
  tCmds.setaProp("G_OBJS", 62)
  tCmds.setaProp("G_ITEMS", 63)
  tCmds.setaProp("G_STAT", 64)
  tCmds.setaProp("GETSTRIP", 65)
  tCmds.setaProp("FLATPROPBYITEM", 66)
  tCmds.setaProp("ADDSTRIPITEM", 67)
  tCmds.setaProp("TRADE_UNACCEPT", 68)
  tCmds.setaProp("TRADE_ACCEPT", 69)
  tCmds.setaProp("TRADE_CLOSE", 70)
  tCmds.setaProp("TRADE_OPEN", 71)
  tCmds.setaProp("TRADE_ADDITEM", 72)
  tCmds.setaProp("MOVESTUFF", 73)
  tCmds.setaProp("SETSTUFFDATA", 74)
  tCmds.setaProp("MOVE", 75)
  tCmds.setaProp("THROW_DICE", 76)
  tCmds.setaProp("DICE_OFF", 77)
  tCmds.setaProp("PRESENTOPEN", 78)
  tCmds.setaProp("LOOKTO", 79)
  tCmds.setaProp("CARRYDRINK", 80)
  tCmds.setaProp("INTODOOR", 81)
  tCmds.setaProp("DOORGOIN", 82)
  tCmds.setaProp("G_IDATA", 83)
  tCmds.setaProp("SETITEMDATA", 84)
  tCmds.setaProp("REMOVEITEM", 85)
  tCmds.setaProp("CARRYITEM", 87)
  tCmds.setaProp("STOP", 88)
  tCmds.setaProp("USEITEM", 89)
  tCmds.setaProp("PLACESTUFF", 90)
  tCmds.setaProp("DANCE", 93)
  tCmds.setaProp("WAVE", 94)
  tCmds.setaProp("KICKUSER", 95)
  tCmds.setaProp("ASSIGNRIGHTS", 96)
  tCmds.setaProp("REMOVERIGHTS", 97)
  tCmds.setaProp("LETUSERIN", 98)
  tCmds.setaProp("REMOVESTUFF", 99)
  tCmds.setaProp("GOAWAY", 115)
  tCmds.setaProp("GETROOMAD", 126)
  tCmds.setaProp("GETPETSTAT", 128)
  tCmds.setaProp("SETBADGE", 158)
  tCmds.setaProp("GETINTERST", 182)
  tCmds.setaProp("CONVERT_FURNI_TO_CREDITS", 183)
  tCmds.setaProp("ROOM_QUEUE_CHANGE", 211)
  tCmds.setaProp("SETITEMSTATE", 214)
  tCmds.setaProp("GET_SPECTATOR_AMOUNT", 216)
  tCmds.setaProp("GET_GROUP_BADGES", 230)
  tCmds.setaProp("GET_GROUP_DETAILS", 231)
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  return 1
end

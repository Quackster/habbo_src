property pRemoteControlledUsers, pHighlightUser

on construct me 
  pRemoteControlledUsers = []
  return(me.regMsgList(1))
end

on deconstruct me 
  pRemoteControlledUsers = []
  return(me.regMsgList(0))
end

on handle_opc_ok me, tMsg 
  if me.getComponent().getRoomID() = "private" then
    me.getComponent().roomConnected(void(), "OPC_OK")
  end if
end

on handle_clc me 
  me.getComponent().roomDisconnected()
end

on handle_youaremod me, tMsg 
  return(1)
end

on handle_flat_letin me, tMsg 
  tConn = tMsg.connection
  tName = tConn.GetStrFrom()
  me.getInterface().showDoorBellAccepted(tName)
  if tName <> "" then
    return(1)
  end if
  return(me.getComponent().roomConnected(void(), "FLAT_LETIN"))
end

on handle_room_ready me, tMsg 
  me.getComponent().roomConnected(tMsg.getProp(#word, 1), "ROOM_READY")
end

on handle_logout me, tMsg 
  tuser = tMsg.getProp(#word, 1)
  if tuser <> getObject(#session).GET("user_index") then
    me.getComponent().removeUserObject(tuser)
  end if
end

on handle_disconnect me 
  me.getComponent().roomDisconnected()
end

on handle_error me, tMsg 
  tErr = tMsg.content
  error(me, tMsg.getID() & ":" && tErr, #handle_error, #dummy)
  if tErr = "info: No place for stuff" then
    me.getInterface().stopObjectMover()
  else
    if tErr = "Incorrect flat password" then
      if threadExists(#navigator) then
        getThread(#navigator).getComponent().flatAccessResult(tErr)
      end if
    else
      if tErr = "Password required" then
        if threadExists(#navigator) then
          getThread(#navigator).getComponent().flatAccessResult(tErr)
        end if
      else
        if tErr = "weird error" then
          executeMessage(#leaveRoom)
        else
          if tErr = "Not owner" then
            getObject(#session).set("room_controller", 0)
          end if
        end if
      end if
    end if
  end if
end

on handle_doorbell_ringing me, tMsg 
  if tMsg.content = "" then
    return(me.getInterface().showDoorBellWaiting())
  else
    return(me.getInterface().showDoorBellDialog(tMsg.content))
  end if
end

on handle_flatnotallowedtoenter me, tMsg 
  tConn = tMsg.connection
  tName = tConn.GetStrFrom()
  return(me.getInterface().showDoorBellRejected(tName))
end

on handle_status me, tMsg 
  tList = []
  tCount = tMsg.count(#line)
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  i = 1
  repeat while i <= tCount
    tLine = tMsg.getProp(#line, i)
    if length(tLine) > 5 then
      tuser = [:]
      tuser.setAt(#id, tLine.getPropRef(#item, 1).getProp(#word, 1))
      tloc = tLine.getPropRef(#item, 1).getProp(#word, 2)
      the itemDelimiter = ","
      tuser.setAt(#x, integer(tloc.getProp(#item, 1)))
      tuser.setAt(#y, integer(tloc.getProp(#item, 2)))
      tuser.setAt(#h, getLocalFloat(tloc.getProp(#item, 3)))
      tuser.setAt(#dirHead, (integer(tloc.getProp(#item, 4)) mod 8))
      tuser.setAt(#dirBody, (integer(tloc.getProp(#item, 5)) mod 8))
      tActions = []
      the itemDelimiter = "/"
      j = 2
      repeat while j <= tLine.count(#item)
        if length(tLine.getProp(#item, j)) > 1 then
          tActions.add([#name:tLine.getPropRef(#item, j).getProp(#word, 1), #params:tLine.getProp(#item, j)])
        end if
        j = 1 + j
      end repeat
      tuser.setAt(#actions, tActions)
      tList.add(tuser)
    end if
    i = 1 + i
  end repeat
  the itemDelimiter = tDelim
  repeat while tList <= undefined
    tuser = getAt(undefined, tMsg)
    if not pRemoteControlledUsers.getOne(tuser.getAt(#id)) > 0 then
      tUserObj = me.getComponent().getUserObject(tuser.getAt(#id))
      if tUserObj <> 0 then
        tUserObj.resetValues(tuser.getAt(#x), tuser.getAt(#y), tuser.getAt(#h), tuser.getAt(#dirHead), tuser.getAt(#dirBody))
        tPrimaryActions = ["mv", "sit", "lay"]
        tActionList = []
        i = tuser.getAt(#actions).count
        repeat while i >= 1
          tAction = tuser.getAt(#actions).getAt(i)
          if tPrimaryActions.findPos(tAction.getAt(#name)) then
            tActionList.add(tAction)
            tuser.getAt(#actions).deleteAt(i)
          end if
          i = 255 + i
        end repeat
        repeat while tList <= undefined
          tAction = getAt(undefined, tMsg)
          tActionList.add(tAction)
        end repeat
        repeat while tList <= undefined
          tAction = getAt(undefined, tMsg)
          call(symbol("action_" & tAction.getAt(#name)), [tUserObj], tAction.getAt(#params))
        end repeat
        tUserObj.Refresh(tuser.getAt(#x), tuser.getAt(#y), tuser.getAt(#h))
      end if
    end if
  end repeat
end

on handle_users me, tMsg 
  tCount = tMsg.count(#line)
  tDelim = the itemDelimiter
  tList = [:]
  tuser = ""
  if not objectExists("Figure_System") then
    return(error(me, "Figure system object not found!", #handle_users, #major))
  end if
  f = 1
  repeat while f <= tCount
    tLine = tMsg.getProp(#line, f)
    tProp = tLine.getProp(#char, 1)
    tdata = tLine.getProp(#char, 3, length(tLine))
    if tProp = "i" then
      tuser = tdata
      tList.setAt(tuser, [:])
      tList.getAt(tuser).setAt(#direction, [0, 0])
      tList.getAt(tuser).setAt(#id, tdata)
    else
      if tProp = "n" then
        tList.getAt(tuser).setAt(#name, tdata)
        if tdata contains numToChar(4) then
          tList.getAt(tuser).setAt(#class, "pet")
        else
          tList.getAt(tuser).setAt(#class, "user")
        end if
      else
        if tProp = "f" then
          tList.getAt(tuser).setAt(#figure, tdata)
        else
          if tProp = "l" then
            tList.getAt(tuser).setAt(#x, integer(tdata.getProp(#word, 1)))
            tList.getAt(tuser).setAt(#y, integer(tdata.getProp(#word, 2)))
            tList.getAt(tuser).setAt(#h, getLocalFloat(tdata.getProp(#word, 3)))
          else
            if tProp = "c" then
              tList.getAt(tuser).setAt(#custom, tdata)
            else
              if tProp = "s" then
                if tdata.getProp(#char, 1) = "F" or tdata.getProp(#char, 1) = "f" then
                  tList.getAt(tuser).setAt(#sex, "F")
                else
                  tList.getAt(tuser).setAt(#sex, "M")
                end if
              else
                if tProp = "p" then
                  if tdata contains "ch=s" then
                    the itemDelimiter = "/"
                    tmodel = tdata.getProp(#char, 4, 6)
                    tColor = tdata.getProp(#item, 2)
                    the itemDelimiter = ","
                    if tColor.count(#item) = 3 then
                      tColor = value("rgb(" & tColor & ")")
                    else
                      tColor = rgb("#EEEEEE")
                    end if
                    tList.getAt(tuser).setAt(#phfigure, ["model":tmodel, "color":tColor])
                    tList.getAt(tuser).setAt(#class, "pelle")
                  end if
                else
                  if tProp = "b" then
                    tList.getAt(tuser).setAt(#badge, tdata)
                  else
                    if tProp = "a" then
                      tList.getAt(tuser).setAt(#webID, tdata)
                    else
                      if tProp = "g" then
                        tList.getAt(tuser).setAt(#groupID, tdata)
                      else
                        if tProp = "t" then
                          tList.getAt(tuser).setAt(#groupstatus, tdata)
                        else
                          if tLine.getProp(#word, 1) = "[bot]" then
                            tList.getAt(tuser).setAt(#class, "bot")
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
    f = 1 + f
  end repeat
  tFigureParser = getObject("Figure_System")
  repeat while tProp <= undefined
    tObject = getAt(undefined, tMsg)
    tObject.setAt(#figure, tFigureParser.parseFigure(tObject.getAt(#figure), tObject.getAt(#sex), tObject.getAt(#class)))
  end repeat
  the itemDelimiter = tDelim
  if count(tList) = 0 then
    me.getComponent().validateUserObjects(0)
  else
    tName = getObject(#session).GET(#userName)
    repeat while tProp <= undefined
      tuser = getAt(undefined, tMsg)
      if tuser.getAt(#name) = tName then
        getObject(#session).set("user_index", tuser.getAt(#id))
      end if
      me.getComponent().validateUserObjects(tuser)
      if me.getComponent().getPickedCryName() = tuser.getAt(#name) then
        me.getComponent().showCfhSenderDelayed(tuser.getAt(#id))
      end if
      if tuser.getAt(#name) = tName then
        me.getInterface().eventProcUserObj(#selection, tuser.getAt(#id), #userEnters)
        if not voidp(pHighlightUser) then
          me.getComponent().highlightUser(pHighlightUser)
          pHighlightUser = void()
        end if
      end if
    end repeat
  end if
end

on handle_showprogram me, tMsg 
  tLine = tMsg.content
  tDst = tLine.getProp(#word, 1)
  tCmd = tLine.getProp(#word, 2)
  tArg = tLine.getProp(#word, 3, tLine.count(#word))
  tdata = [#command:"SHOWPROGRAM", #show_dest:tDst, #show_command:tCmd, #show_params:tArg]
  tObj = me.getComponent().getRoomPrg()
  if objectp(tObj) then
    call(#showprogram, [tObj], tdata)
  end if
end

on handle_no_user_for_gift me, tMsg 
  tUserName = tMsg.content
  tAlertString = getText("no_user_for_gift")
  tAlertString = replaceChunks(tAlertString, "%user%", tUserName)
  executeMessage(#alert, [#Msg:tAlertString])
end

on handle_heightmap me, tMsg 
  me.getComponent().validateHeightMap(tMsg.content)
end

on handle_heightmapupdate me, tMsg 
  me.getComponent().updateHeightMap(tMsg.content)
end

on handle_OBJECTS me, tMsg 
  tList = []
  tCount = tMsg.count(#line)
  i = 1
  repeat while i <= tCount
    tLine = tMsg.getProp(#line, i)
    if length(tLine) > 5 then
      tObj = [:]
      tObj.setAt(#id, tLine.getProp(#word, 1))
      tObj.setAt(#class, tLine.getProp(#word, 2))
      tObj.setAt(#x, integer(tLine.getProp(#word, 3)))
      tObj.setAt(#y, integer(tLine.getProp(#word, 4)))
      tObj.setAt(#h, integer(tLine.getProp(#word, 5)))
      if tLine.count(#word) = 6 then
        tdir = (integer(tLine.getProp(#word, 6)) mod 8)
        tObj.setAt(#direction, [tdir, tdir, tdir])
        tObj.setAt(#dimensions, 0)
      else
        tWidth = integer(tLine.getProp(#word, 6))
        tHeight = integer(tLine.getProp(#word, 7))
        tObj.setAt(#dimensions, [tWidth, tHeight])
        tObj.setAt(#x, tObj.getAt(#x) + tObj.getAt(#width) - 1)
        tObj.setAt(#y, tObj.getAt(#y) + tObj.getAt(#height) - 1)
      end if
      if tObj.getAt(#id) <> "" then
        tList.add(tObj)
      end if
    end if
    i = 1 + i
  end repeat
  if count(tList) > 0 then
    repeat while tList <= undefined
      tObj = getAt(undefined, tMsg)
      me.getComponent().validatePassiveObjects(tObj)
    end repeat
  else
    me.getComponent().validatePassiveObjects(0)
  end if
end

on parseActiveObject me, tConn 
  if not tConn then
    return(0)
  end if
  tObj = [:]
  tObj.setAt(#id, tConn.GetStrFrom())
  tObj.setAt(#class, tConn.GetStrFrom())
  tObj.setAt(#x, tConn.GetIntFrom())
  tObj.setAt(#y, tConn.GetIntFrom())
  tWidth = tConn.GetIntFrom()
  tHeight = tConn.GetIntFrom()
  tDirection = (tConn.GetIntFrom() mod 8)
  tObj.setAt(#direction, [tDirection, tDirection, tDirection])
  tObj.setAt(#dimensions, [tWidth, tHeight])
  tObj.setAt(#altitude, getLocalFloat(tConn.GetStrFrom()))
  tObj.setAt(#colors, tConn.GetStrFrom())
  if tObj.getAt(#colors) = "" then
    tObj.setAt(#colors, "0")
  end if
  tRuntimeData = tConn.GetStrFrom()
  tExtra = tConn.GetIntFrom()
  tStuffData = tConn.GetStrFrom()
  tObj.setAt(#props, [#runtimedata:tRuntimeData, #extra:tExtra, #stuffdata:tStuffData])
  return(tObj)
end

on handle_activeobjects me, tMsg 
  tConn = tMsg.connection
  if not tConn then
    return(0)
  end if
  tList = []
  tCount = tConn.GetIntFrom()
  i = 1
  repeat while i <= tCount
    if tConn <> 0 then
      tObj = me.parseActiveObject(tConn)
      if listp(tObj) then
        tList.add(tObj)
      end if
    end if
    i = 1 + i
  end repeat
  if count(tList) > 0 then
    repeat while tList <= undefined
      tObj = getAt(undefined, tMsg)
      me.getComponent().validateActiveObjects(tObj)
    end repeat
    executeMessage(#activeObjectsUpdated)
  else
    me.getComponent().validateActiveObjects(0)
  end if
end

on handle_activeobject_remove me, tMsg 
  me.getComponent().removeActiveObject(tMsg.getProp(#word, 1))
  executeMessage(#activeObjectRemoved)
  return(1)
end

on handle_activeobject_add me, tMsg 
  tConn = tMsg.connection
  if not tConn then
    return(0)
  end if
  tObj = me.parseActiveObject(tConn)
  if not listp(tObj) then
    return(0)
  end if
  me.getComponent().validateActiveObjects(tObj)
  executeMessage(#activeObjectsUpdated)
  return(1)
end

on handle_activeobject_update me, tMsg 
  tConn = tMsg.connection
  if not tConn then
    return(0)
  end if
  tObj = me.parseActiveObject(tConn)
  if not listp(tObj) then
    return(0)
  end if
  tComponent = me.getComponent()
  if tComponent.activeObjectExists(tObj.getAt(#id)) then
    tObj = getThread(#buffer).getComponent().processObject(tObj, "active")
    tActiveObj = tComponent.getActiveObject(tObj.getAt(#id))
    tActiveObj.define(tObj)
    tComponent.removeSlideObject(tObj.getAt(#id))
    call(#movingFinished, [tActiveObj])
    executeMessage(#activeObjectsUpdated)
  else
    return(error(me, "Active object not found:" && tObj.getAt(#id), #handle_activeobject_update, #major))
  end if
end

on handle_items me, tMsg 
  tList = []
  tDelim = the itemDelimiter
  i = 1
  repeat while i <= tMsg.count(#line)
    the itemDelimiter = "\t"
    tLine = tMsg.getProp(#line, i)
    if tLine <> "" then
      tObj = [:]
      tObj.setAt(#id, tLine.getProp(#item, 1))
      tObj.setAt(#class, tLine.getProp(#item, 2))
      tObj.setAt(#owner, tLine.getProp(#item, 3))
      tObj.setAt(#type, tLine.getProp(#item, 5))
      if not tLine.getPropRef(#item, 4).getProp(#char, 1) = ":" then
        tObj.setAt(#direction, tLine.getPropRef(#item, 4).getProp(#word, 1))
        if tObj.getAt(#direction) = "frontwall" then
          tObj.setAt(#direction, "rightwall")
        end if
        tlocation = tLine.getPropRef(#item, 4).getProp(#word, 2, tLine.getPropRef(#item, 4).count(#word))
        the itemDelimiter = ","
        tObj.setAt(#x, 0)
        tObj.setAt(#y, tlocation.getProp(#item, 1))
        tObj.setAt(#h, getLocalFloat(tlocation.getProp(#item, 2)))
        tObj.setAt(#z, integer(tlocation.getProp(#item, 3)))
        tObj.setAt(#formatVersion, #old)
      else
        tLocString = tLine.getProp(#item, 4)
        tWallLoc = tLocString.getPropRef(#word, 1).getProp(#char, 4, length(tLocString.getProp(#word, 1)))
        the itemDelimiter = ","
        tObj.setAt(#wall_x, value(tWallLoc.getProp(#item, 1)))
        tObj.setAt(#wall_y, value(tWallLoc.getProp(#item, 2)))
        tLocalLoc = tLocString.getPropRef(#word, 2).getProp(#char, 3, length(tLocString.getProp(#word, 2)))
        tObj.setAt(#local_x, value(tLocalLoc.getProp(#item, 1)))
        tObj.setAt(#local_y, value(tLocalLoc.getProp(#item, 2)))
        tDirChar = tLocString.getProp(#word, 3)
        if tDirChar = "r" then
          tObj.setAt(#direction, "rightwall")
        else
          if tDirChar = "l" then
            tObj.setAt(#direction, "leftwall")
          end if
        end if
        tObj.setAt(#formatVersion, #new)
      end if
      tList.add(tObj)
    end if
    i = 1 + i
  end repeat
  the itemDelimiter = tDelim
  if count(tList) > 0 then
    repeat while tDirChar <= undefined
      tItem = getAt(undefined, tMsg)
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
  tItem = me.getComponent().getItemObject(tMsg.getProp(#word, 1))
  if objectp(tItem) then
    tItem.setState(the last word in tMsg.content)
  end if
end

on handle_stuffdataupdate me, tMsg 
  tConn = tMsg.connection
  if not tConn then
    return(0)
  end if
  tTarget = tConn.GetStrFrom()
  tValue = tConn.GetStrFrom()
  if me.getComponent().activeObjectExists(tTarget) then
    call(#updateStuffdata, [me.getComponent().getActiveObject(tTarget)], tValue)
  else
    return(error(me, "Active object not found:" && tTarget, #handle_stuffdataupdate, #major))
  end if
end

on handle_presentopen me, tMsg 
  ttype = tMsg.getProp(#line, 1)
  tCode = tMsg.getProp(#line, 2)
  tColors = tMsg.getProp(#line, 3)
  tCard = "PackageCardObj"
  if objectExists(tCard) then
    getObject(tCard).showContent([#type:ttype, #code:tCode, #color:tColors])
  else
    error(me, "Package card obj not found!", #handle_presentopen, #major)
  end if
end

on handle_flatproperty me, tMsg 
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tLine = tMsg.content
  tdata = [#key:tLine.getProp(#item, 1), #value:tLine.getProp(#item, 2)]
  the itemDelimiter = tDelim
  me.getComponent().setRoomProperty(tdata.getAt(#key), tdata.getAt(#value))
end

on handle_room_rights me, tMsg 
  if tMsg.subject = 42 then
    getObject(#session).set("room_controller", 1)
  else
    if tMsg.subject = 43 then
      getObject(#session).set("room_controller", 0)
    else
      if tMsg.subject = 47 then
        getObject(#session).set("room_owner", 1)
      end if
    end if
  end if
end

on handle_stripinfo me, tMsg 
  tProps = [#objects:[], #count:0]
  tDelim = the itemDelimiter
  tProps.setAt(#count, integer(tMsg.getProp(#line, tMsg.count(#line))))
  the itemDelimiter = "/"
  tCount = tMsg.count(#item)
  tStripMax = 0
  tTotalItemCount = 0
  i = 1
  repeat while i <= tCount
    the itemDelimiter = "/"
    tItem = tMsg.getProp(#item, i)
    if tItem = "" then
    else
      the itemDelimiter = numToChar(30)
      if tItem.count(#item) < 2 then
        tTotalItemCount = integer(tItem - 1)
      else
        tObj = [:]
        tObj.setAt(#stripId, tItem.getProp(#item, 2))
        tObjectPos = integer(tItem.getProp(#item, 3))
        tObj.setAt(#striptype, tItem.getProp(#item, 4))
        tObj.setAt(#id, tItem.getProp(#item, 5))
        tObj.setAt(#class, tItem.getProp(#item, 6))
        if tObj.getAt(#striptype) = "S" then
          tObj.setAt(#name, getText("furni_" & tObj.getAt(#class) & "_name", "furni_" & tObj.getAt(#class) & "_name"))
          tObj.setAt(#striptype, "active")
          tObj.setAt(#custom, getText("furni_" & tObj.getAt(#class) & "_name", "furni_" & tObj.getAt(#class) & "_desc"))
          tObj.setAt(#dimensions, [integer(tItem.getProp(#item, 7)), integer(tItem.getProp(#item, 8))])
          tObj.setAt(#stuffdata, tItem.getProp(#item, 9))
          tObj.setAt(#colors, tItem.getProp(#item, 10))
          tObj.setAt(#isRecyclable, tItem.getProp(#item, 11))
          if tItem.getProp(#item, 12) <> "" and tItem.count(#item) >= 12 then
            tObj.setAt(#slotID, tItem.getProp(#item, 12))
          end if
          if tItem.getProp(#item, 13) <> "" and tItem.count(#item) >= 13 then
            tObj.setAt(#songID, tItem.getProp(#item, 13))
          end if
          the itemDelimiter = ","
          if tObj.getAt(#colors).getProp(#char, 1) = "#" then
            if tObj.getAt(#colors).count(#item) > 1 then
              tObj.setAt(#stripColor, rgb(tObj.getAt(#colors).getProp(#item, tObj.getAt(#colors).count(#item))))
            else
              tObj.setAt(#stripColor, rgb(tObj.getAt(#colors)))
            end if
          else
            tObj.setAt(#stripColor, 0)
          end if
        else
          if tObj.getAt(#striptype) = "I" then
            tObj.setAt(#striptype, "item")
            tObj.setAt(#props, tItem.getProp(#item, 7))
            tObj.setAt(#isRecyclable, tItem.getProp(#item, 8))
            if tObj.getAt(#striptype) = "poster" then
              tObj.setAt(#name, getText("poster_" & tObj.getAt(#props) & "_name", "poster_" & tObj.getAt(#props) & "_name"))
            else
              tObj.setAt(#name, getText("wallitem_" & tObj.getAt(#class) & "_name", "wallitem_" & tObj.getAt(#class) & "_name"))
            end if
          end if
        end if
        tProps.getAt(#objects).add(tObj)
        if tObjectPos > tStripMax then
          tStripMax = tObjectPos
        end if
        i = 1 + i
      end if
    end if
  end repeat
  the itemDelimiter = tDelim
  tInventory = me.getInterface().getContainer()
  tInventory.setHandButton("next", tTotalItemCount > integer(tStripMax))
  tInventory.setHandButton("prev", integer(tStripMax) > 8)
  if tObj.getAt(#striptype) = 140 then
    tInventory.updateStripItems(tProps.getAt(#objects))
    tInventory.setStripItemCount(tProps.getAt(#count))
    tInventory.open(1)
    tInventory.Refresh()
  else
    if tObj.getAt(#striptype) = 98 then
      tInventory.appendStripItem(tProps.getAt(#objects).getAt(1))
      tInventory.open(1)
      tInventory.Refresh()
    else
      if tObj.getAt(#striptype) = 108 then
        return(tProps)
      end if
    end if
  end if
end

on handle_stripupdated me, tMsg 
  tMsg.send("GETSTRIP", "new")
end

on handle_removestripitem me, tMsg 
  me.getInterface().getContainer().removeStripItem(tMsg.getProp(#word, 1))
  me.getInterface().getContainer().Refresh()
end

on handle_youarenotallowed me 
  executeMessage(#alert, [#Msg:"trade_youarenotallowed", #id:"youarenotallowed"])
end

on handle_othernotallowed me 
  executeMessage(#alert, [#Msg:"trade_othernotallowed", #id:"othernotallowed"])
end

on handle_idata me, tMsg 
  tDelim = the itemDelimiter
  the itemDelimiter = "\t"
  tID = integer(tMsg.getPropRef(#line, 1).getProp(#item, 1))
  ttype = tMsg.getPropRef(#line, 1).getProp(#item, 2)
  tText = tMsg.getPropRef(#line, 1).getProp(#item, 2) & "\r" & tMsg.getProp(#line, 2, tMsg.count(#line))
  the itemDelimiter = tDelim
  executeMessage(symbol("itemdata_received" & tID), [#id:tID, #text:tText, #type:ttype])
end

on handle_trade_items me, tMsg 
  tMessage = [:]
  i = 1
  repeat while i <= 2
    tLine = tMsg.getProp(#line, i)
    tdata = [:]
    tdata.setAt(#accept, tLine.getProp(#word, 2))
    tItemStr = "foo" & "\r" & tLine.getProp(#word, 3, tLine.count(#word)) & "\r" & 1
    tdata.setAt(#items, me.handle_stripinfo([#subject:108, #content:tItemStr]).getaProp(#objects))
    if not listp(tdata.getAt(#items)) then
      return(error(me, "Invalid itemdata from server!", #handle_trade_items, #major))
    end if
    tUserName = tLine.getProp(#word, 1)
    if tUserName = "" then
      return(error(me, "No username from server", #handle_trade_items, #major))
    end if
    if me.getInterface().getIgnoreStatus(void(), tUserName) then
      return(me.getComponent().getRoomConnection().send("TRADE_CLOSE"))
    end if
    tMessage.setAt(tUserName, tdata)
    i = 1 + i
  end repeat
  return(me.getInterface().getSafeTrader().Refresh(tMessage))
end

on handle_trade_close me, tMsg 
  me.getInterface().getSafeTrader().close()
  tMsg.send("GETSTRIP", "new")
end

on handle_trade_accept me, tMsg 
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tuser = tMsg.getProp(#item, 1)
  tValue = tMsg.getProp(#item, 2) = "true"
  the itemDelimiter = tDelim
  me.getInterface().getSafeTrader().accept(tuser, tValue)
end

on handle_trade_completed me, tMsg 
  me.getInterface().getSafeTrader().complete()
end

on handle_door_in me, tMsg 
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tDoor = tMsg.getProp(#item, 1)
  tuser = tMsg.getProp(#item, 2)
  the itemDelimiter = tDelim
  tDoorObj = me.getComponent().getActiveObject(tDoor)
  if tDoorObj <> 0 then
    call(#animate, [tDoorObj], 18)
    if getObject(#session).GET("user_name") = tuser then
      call(#prepareToKick, [tDoorObj], tuser)
    end if
  end if
end

on handle_door_out me, tMsg 
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tDoor = me.getComponent().getActiveObject(tMsg.getProp(#item, 1))
  the itemDelimiter = tDelim
  if tDoor <> 0 then
    call(#animate, [tDoor])
  end if
end

on handle_doorflat me, tMsg 
  tConn = tMsg.connection
  tTeleId = tConn.GetIntFrom()
  tFlatID = tConn.GetIntFrom()
  if not tTeleId and tFlatID then
    return(error(me, "Retarded doorflat data!", #handle_doorflat, #major))
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
  tID = tMsg.getProp(#word, 1)
  if tMsg.count(#word) = 1 then
    tValue = -1
  else
    tValue = integer(tMsg.getProp(#word, 2) - (tID * 38))
    if tValue > 6 then
      tValue = 0
    end if
  end if
  if me.getComponent().activeObjectExists(tID) then
    call(#diceThrown, [me.getComponent().getActiveObject(tID)], tValue)
  end if
end

on handle_roomad me, tMsg 
  if tMsg.length > 1 then
    tDelim = the itemDelimiter
    the itemDelimiter = "\t"
    tSourceURL = tMsg.getProp(#item, 1)
    tTargetURL = tMsg.getProp(#item, 2)
    the itemDelimiter = tDelim
    tLayoutID = me.getInterface().getRoomVisualizer().pLayout
    me.getComponent().getAd().Init(tSourceURL, tTargetURL, tLayoutID)
  else
    me.getComponent().getAd().Init(0)
  end if
end

on handle_petstat me, tMsg 
  tPetObj = me.getComponent().getUserObject(tMsg.GetIntFrom())
  if tPetObj = 0 then
    return(error(me, "Pet object not found!", #handle_petstat, #major))
  end if
  tName = tPetObj.getName()
  tAge = tMsg.GetIntFrom()
  tHungry = getText("pet_hung_" & tMsg.GetIntFrom(), "???")
  tThirsty = getText("pet_thir_" & tMsg.GetIntFrom(), "???")
  tHappiness = getText("pet_mood_" & tMsg.GetIntFrom(), "???")
  tNature01 = getText("pet_enrg_" & tMsg.GetIntFrom(), "???")
  tNature02 = getText("pet_frnd_" & tMsg.GetIntFrom(), "???")
  if createWindow("pet_status_dialog") then
    tWndObj = getWindow("pet_status_dialog")
    tWndObj.moveTo(8, 8)
    tWndObj.setProperty(#title, tName)
    if not tWndObj.merge("habbo_full.window") then
      return(tWndObj.close())
    end if
    if not tWndObj.merge("petstatus.window") then
      return(tWndObj.close())
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
    return(0)
  end if
  tUserID = string(tMsg.GetIntFrom())
  tBadge = tMsg.GetStrFrom()
  tUserObj = me.getComponent().getUserObject(tUserID)
  if not objectp(tUserObj) then
    return(0)
  end if
  tUserObj.pBadge = tBadge
  me.getInterface().unignoreAdmin(tUserID, tBadge)
  executeMessage(#updateInfoStandBadge, tBadge, tUserID)
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
  tCount = 1
  repeat while tCount <= tStuffCount
    tObj = []
    tItemID = tConn.GetIntFrom()
    tItemFromH = getLocalFloat(tConn.GetStrFrom())
    tItemToH = getLocalFloat(tConn.GetStrFrom())
    tFrom = [tFromX, tFromY, tItemFromH]
    tTo = [tToX, tToY, tItemToH]
    tObj = [tItemID, tFrom, tTo]
    tObjList.add(tObj)
    tContainsObjects = 1
    tCount = 1 + tCount
  end repeat
  tTileID = tConn.GetIntFrom()
  tTileObj = tComponent.getActiveObject(tTileID)
  if tTileObj <> 0 then
    if tTileObj.handler(#setAnimation) then
      call(#setAnimation, tTileObj, 1)
    end if
  end if
  tMoveType = tConn.GetIntFrom()
  if tMoveType = 0 then
    tHasCharacter = 0
  else
    if tMoveType = 1 then
      tMoveType = "mv"
      tHasCharacter = 1
    else
      if tMoveType = 2 then
        tMoveType = "sld"
        tHasCharacter = 1
      else
        return(error(me, "Incompatible character movetype", #handle_slideobjectbundle, #minor))
      end if
    end if
  end if
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
  repeat while tMoveType <= undefined
    tObj = getAt(undefined, tMsg)
    tComponent.addSlideObject(tObj.getAt(1), tObj.getAt(2), tObj.getAt(3), tTimeNow, tHasCharacter)
  end repeat
end

on handle_interstitialdata me, tMsg 
  if tMsg.length > 1 then
    tDelim = the itemDelimiter
    the itemDelimiter = "\t"
    tSourceURL = tMsg.getProp(#item, 1)
    tTargetURL = tMsg.getProp(#item, 2)
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
  i = 1
  repeat while i <= tSetCount
    tQueueSetName = tConn.GetStrFrom()
    tQueueTarget = tConn.GetIntFrom()
    tNumberOfQueues = tConn.GetIntFrom()
    tQueueData = [:]
    tQueueSet = [:]
    t = 1
    repeat while t <= tNumberOfQueues
      tQueueID = tConn.GetStrFrom()
      tQueueLength = tConn.GetIntFrom()
      tQueueData.setAt(tQueueID, tQueueLength)
      t = 1 + t
    end repeat
    tQueueSet.setAt("name", tQueueSetName)
    tQueueSet.setAt("target", tQueueTarget)
    tQueueSet.setAt("data", tQueueData)
    tQueueCollection.setAt(i, tQueueSet)
    i = 1 + i
  end repeat
  me.getInterface().updateQueueWindow(tQueueCollection)
end

on handle_youarespectator me 
  return(me.getComponent().setSpectatorMode(1))
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
  tNo = 1
  repeat while tNo <= tNumberOfGroups
    tGroup = [:]
    tGroup.setAt(#id, tConn.GetIntFrom())
    tGroup.setAt(#logo, tConn.GetStrFrom())
    tGroupData.add(tGroup)
    tNo = 1 + tNo
  end repeat
  me.getComponent().getGroupInfoObject().updateGroupInformation(tGroupData)
end

on handle_group_details me, tMsg 
  tConn = tMsg.connection
  tGroupData = []
  tGroup = [:]
  tGroup.setAt(#id, tConn.GetIntFrom())
  if tGroup.getAt(#id) = -1 then
    return(0)
  end if
  tGroup.setAt(#name, tConn.GetStrFrom())
  tGroup.setAt(#desc, tConn.GetStrFrom())
  tGroup.setAt(#roomid, tConn.GetIntFrom())
  tGroup.setAt(#roomname, tConn.GetStrFrom())
  tGroupData.add(tGroup)
  me.getComponent().getGroupInfoObject().updateGroupInformation(tGroupData)
  executeMessage(#groupInfoRetrieved, tGroup.getAt(#id))
end

on handle_group_membership_update me, tMsg 
  tConn = tMsg.connection
  tUserIndex = tConn.GetIntFrom()
  tGroupId = tConn.GetIntFrom()
  tStatus = tConn.GetIntFrom()
  tuser = me.getComponent().getUserObject(tUserIndex)
  if not voidp(tuser) then
    if tuser <> 0 then
      tuser.setProperty(#groupID, tGroupId)
      tuser.setProperty(#groupstatus, tStatus)
    end if
  end if
end

on handle_room_rating me, tMsg 
  tConn = tMsg.connection
  tRoomRating = tConn.GetIntFrom()
  tRoomRatingPercent = tConn.GetIntFrom()
  me.getComponent().setRoomRating(tRoomRating, tRoomRatingPercent)
  executeMessage(#roomRatingChanged)
end

on handle_user_tag_list me, tMsg 
  tConn = tMsg.connection
  tUserID = tConn.GetIntFrom()
  tNumOfTags = tConn.GetIntFrom()
  tTagList = []
  tTagNum = 1
  repeat while tTagNum <= tNumOfTags
    tTag = tConn.GetStrFrom()
    tTagList.add(tTag)
    tTagNum = 1 + tTagNum
  end repeat
  executeMessage(#updateUserTags, tUserID, tTagList)
end

on handle_user_typing_status me, tMsg 
  tConn = tMsg.connection
  tUserID = tConn.GetIntFrom()
  tstate = tConn.GetIntFrom()
  tUserID = string(tUserID)
  me.getComponent().setUserTypingStatus(tUserID, tstate)
end

on handle_highlight_user me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tUserID = tConn.GetStrFrom()
  pHighlightUser = tUserID
end

on handle_roomevent_permission me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tCanCreate = tConn.GetIntFrom()
  if tCanCreate then
    executeMessage(#allowRoomeventCreation)
  end if
end

on handle_roomevent_types me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tTypeCount = tConn.GetIntFrom()
  me.getComponent().setRoomEventTypeCount(tTypeCount)
end

on handle_roomevent_list me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tTypeID = tConn.GetIntFrom()
  tEventCount = tConn.GetIntFrom()
  tEvents = []
  tEventNum = 1
  repeat while tEventNum <= tEventCount
    tEvent = [:]
    tEvent.setaProp(#flatId, tConn.GetStrFrom())
    tEvent.setaProp(#hostName, tConn.GetStrFrom())
    tEvent.setaProp(#name, tConn.GetStrFrom())
    tEvent.setaProp(#desc, tConn.GetStrFrom())
    tEvent.setaProp(#time, tConn.GetStrFrom())
    tEvents.add(tEvent)
    tEventNum = 1 + tEventNum
  end repeat
  me.getComponent().setRoomEventList(tTypeID, tEvents)
end

on handle_roomevent_info me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tEventInfo = [:]
  tHostID = tConn.GetStrFrom()
  tEventInfo.setaProp(#hostID, tHostID)
  if tHostID > 0 then
    tEventInfo.setaProp(#hostName, tConn.GetStrFrom())
    tEventInfo.setaProp(#flatId, tConn.GetStrFrom())
    tEventInfo.setaProp(#typeID, tConn.GetIntFrom())
    tEventInfo.setaProp(#name, tConn.GetStrFrom())
    tEventInfo.setaProp(#desc, tConn.GetStrFrom())
    tEventInfo.setaProp(#time, tConn.GetStrFrom())
  end if
  me.getComponent().setRoomEvent(tEventInfo)
end

on handle_ignore_user_result me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tResult = tConn.GetIntFrom()
  return(executeMessage(#ignore_user_result, tResult))
end

on handle_ignore_list me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tCount = tConn.GetIntFrom()
  tList = []
  i = 1
  repeat while i <= tCount
    tList.append(tConn.GetStrFrom())
    i = 1 + i
  end repeat
  return(executeMessage(#save_ignore_list, tList))
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(-1, #handle_disconnect)
  tMsgs.setaProp(18, #handle_clc)
  tMsgs.setaProp(19, #handle_opc_ok)
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
  tMsgs.setaProp(345, #handle_room_rating)
  tMsgs.setaProp(350, #handle_user_tag_list)
  tMsgs.setaProp(361, #handle_user_typing_status)
  tMsgs.setaProp(362, #handle_highlight_user)
  tMsgs.setaProp(367, #handle_roomevent_permission)
  tMsgs.setaProp(368, #handle_roomevent_types)
  tMsgs.setaProp(369, #handle_roomevent_list)
  tMsgs.setaProp(370, #handle_roomevent_info)
  tMsgs.setaProp(419, #handle_ignore_user_result)
  tMsgs.setaProp(420, #handle_ignore_list)
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
  tCmds.setaProp("SPIN_WHEEL_OF_FORTUNE", 247)
  tCmds.setaProp("RATEFLAT", 261)
  tCmds.setaProp("GET_USER_TAGS", 263)
  tCmds.setaProp("SET_RANDOM_STATE", 314)
  tCmds.setaProp("USER_START_TYPING", 317)
  tCmds.setaProp("USER_CANCEL_TYPING", 318)
  tCmds.setaProp("IGNOREUSER", 319)
  tCmds.setaProp("BANUSER", 320)
  tCmds.setaProp("GET_IGNORE_LIST", 321)
  tCmds.setaProp("UNIGNORE_USER", 322)
  tCmds.setaProp("CAN_CREATE_ROOMEVENT", 345)
  tCmds.setaProp("CREATE_ROOMEVENT", 346)
  tCmds.setaProp("QUIT_ROOMEVENT", 347)
  tCmds.setaProp("EDIT_ROOMEVENT", 348)
  tCmds.setaProp("GET_ROOMEVENT_TYPE_COUNT", 349)
  tCmds.setaProp("GET_ROOMEVENTS_BY_TYPE", 350)
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  return(1)
end

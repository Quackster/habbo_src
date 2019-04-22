on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
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
  executeMessage("flat_letin")
  me.getComponent().roomConnected(void(), "FLAT_LETIN")
end

on handle_room_ready me, tMsg 
  me.getComponent().roomConnected(tMsg.getProp(#word, 1), "ROOM_READY")
end

on handle_logout me, tMsg 
  tuser = tMsg.getProp(#word, 1)
  if tuser <> getObject(#session).get("user_index") then
    me.getComponent().removeUserObject(tuser)
  end if
end

on handle_disconnect me 
  me.getComponent().roomDisconnected()
end

on handle_error me, tMsg 
  tErr = tMsg.content
  error(me, tMsg.getID() & ":" && tErr, #handle_error)
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
          me.getInterface().hideInterface(#hide)
        end if
      end if
    end if
  end if
end

on handle_doorbell_ringing me, tMsg 
  me.getInterface().showDoorBell(tMsg.content)
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
      tuser.setAt(#h, float(tloc.getProp(#item, 3)))
      tuser.setAt(#dirHead, integer(tloc.getProp(#item, 4)) mod 8)
      tuser.setAt(#dirBody, integer(tloc.getProp(#item, 5)) mod 8)
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
    tUserObj = me.getComponent().getUserObject(tuser.getAt(#id))
    if tUserObj <> 0 then
      tUserObj.refresh(tuser.getAt(#x), tuser.getAt(#y), tuser.getAt(#h), tuser.getAt(#dirHead), tuser.getAt(#dirBody))
      repeat while tList <= undefined
        tAction = getAt(undefined, tMsg)
        call(symbol("action_" & tAction.getAt(#name)), [tUserObj], tAction.getAt(#params))
      end repeat
    end if
  end repeat
end

on handle_chat me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tuser = string(tConn.GetIntFrom())
  tChat = tConn.GetStrFrom()
  if me.getInterface().getIgnoreStatus(tuser) then
    return(0)
  end if
  if tMsg.getaProp(#subject) = 24 then
    tMode = "CHAT"
  else
    if tMsg.getaProp(#subject) = 25 then
      tMode = "WHISPER"
    else
      if tMsg.getaProp(#subject) = 26 then
        tMode = "SHOUT"
      end if
    end if
  end if
  if me.getComponent().userObjectExists(tuser) then
    me.getComponent().getBalloon().createBalloon([#command:tMode, #id:tuser, #message:tChat])
  end if
end

on handle_users me, tMsg 
  tCount = tMsg.count(#line)
  tDelim = the itemDelimiter
  tList = [:]
  tuser = ""
  if not objectExists("Figure_System") then
    return(error(me, "Figure system object not found!", #handle_users))
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
            tList.getAt(tuser).setAt(#h, float(tdata.getProp(#word, 3)))
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
    tName = getObject(#session).get(#userName)
    repeat while tProp <= undefined
      tuser = getAt(undefined, tMsg)
      me.getInterface().roomEnterDoorBell(tuser.getAt(#name))
      me.getComponent().validateUserObjects(tuser)
      if tuser.getAt(#name) = tName then
        getObject(#session).set("user_index", tuser.getAt(#id))
        me.getInterface().eventProcUserObj(#selection, tuser.getAt(#id))
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
        tdir = integer(tLine.getProp(#word, 6)) mod 8
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

on handle_active_objects me, tMsg 
  tList = []
  tCount = tMsg.count(#line)
  tDelim = the itemDelimiter
  i = 1
  repeat while i <= tCount
    tLine = tMsg.getProp(#line, i)
    if tLine = "" then
    else
      the itemDelimiter = "/"
      tstate = tLine.getProp(#item, 1)
      the itemDelimiter = ","
      tObj = [:]
      tObj.setAt(#id, tstate.getProp(#item, 1))
      tOther = tstate.getProp(#char, offset(",", tstate) + 1, length(tstate))
      tObj.setAt(#class, tOther.getProp(#word, 1))
      tObj.setAt(#x, integer(tOther.getProp(#word, 2)))
      tObj.setAt(#y, integer(tOther.getProp(#word, 3)))
      tWidth = integer(tOther.getProp(#word, 4))
      tHeight = integer(tOther.getProp(#word, 5))
      tDirection = integer(tOther.getProp(#word, 6)) mod 8
      tObj.setAt(#direction, [tDirection, tDirection, tDirection])
      tObj.setAt(#dimensions, [tWidth, tHeight])
      tObj.setAt(#altitude, float(tOther.getProp(#word, 7)))
      tObj.setAt(#colors, tOther.getProp(#word, 8))
      the itemDelimiter = "/"
      tObj.setAt(#props, [:])
      tBool = 1
      j = 2
      repeat while tBool
        tKey = tLine.getProp(#item, j)
        tdata = tLine.getProp(#item, j + 1)
        if length(tKey) = 0 then
          tBool = 0
        else
          tObj.getAt(#props).setAt(tKey, tdata)
        end if
        j = j + 2
      end repeat
      if tObj.getAt(#id) <> "" then
        tList.add(tObj)
      end if
      i = 1 + i
    end if
  end repeat
  the itemDelimiter = tDelim
  if count(tList) > 0 then
    repeat while tList <= undefined
      tObj = getAt(undefined, tMsg)
      me.getComponent().validateActiveObjects(tObj)
    end repeat
    if objectExists(#furniChooser) then
      getObject(#furniChooser).update()
    end if
  else
    me.getComponent().validateActiveObjects(0)
  end if
end

on handle_activeobject_remove me, tMsg 
  me.getComponent().removeActiveObject(tMsg.getProp(#word, 1))
  executeMessage(#activeObjectRemoved)
end

on handle_activeobject_update me, tMsg 
  tLine = tMsg.getProp(#line, 1)
  if tLine = "" then
    return(0)
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tstate = tLine.getProp(#item, 1)
  the itemDelimiter = ","
  tObj = [:]
  tObj.setAt(#id, tstate.getProp(#item, 1))
  tOther = tstate.getProp(#char, offset(",", tstate) + 1, length(tstate))
  tObj.setAt(#class, tOther.getProp(#word, 1))
  tObj.setAt(#x, integer(tOther.getProp(#word, 2)))
  tObj.setAt(#y, integer(tOther.getProp(#word, 3)))
  tWidth = integer(tOther.getProp(#word, 4))
  tHeight = integer(tOther.getProp(#word, 5))
  tDirection = integer(tOther.getProp(#word, 6)) mod 8
  tObj.setAt(#direction, [tDirection, tDirection, tDirection])
  tObj.setAt(#dimensions, [tWidth, tHeight])
  tObj.setAt(#altitude, float(tOther.getProp(#word, 7)))
  tObj.setAt(#colors, tOther.getProp(#word, 8))
  the itemDelimiter = "/"
  tObj.setAt(#props, [:])
  tObj.setAt(#name, getText("furni_" & tObj.getAt(#class) & "_name"))
  tObj.setAt(#custom, getText("furni_" & tObj.getAt(#class) & "_desc"))
  tBool = 1
  j = 2
  repeat while tBool
    tKey = tLine.getProp(#item, j)
    tdata = tLine.getProp(#item, j + 1)
    if length(tKey) = 0 then
      tBool = 0
    else
      tObj.getAt(#props).setAt(tKey, tdata)
    end if
    j = j + 2
  end repeat
  the itemDelimiter = tDelim
  tComponent = me.getComponent()
  if tComponent.activeObjectExists(tObj.getAt(#id)) then
    tActiveObj = tComponent.getActiveObject(tObj.getAt(#id))
    tActiveObj.define(tObj)
    tComponent.removeSlideObject(tObj.getAt(#id))
    call(#prepareForMove, [tActiveObj])
    if objectExists(#furniChooser) then
      getObject(#furniChooser).update()
    end if
  else
    return(error(me, "Active object not found:" && tObj.getAt(#id), #handle_activeobject_update))
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
        tObj.setAt(#y, float(tlocation.getProp(#item, 1)))
        tObj.setAt(#h, float(tlocation.getProp(#item, 2)))
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
    if objectExists(#furniChooser) then
      getObject(#furniChooser).update()
    end if
  else
    me.getComponent().validateItemObjects(0)
  end if
end

on handle_removeitem me, tMsg 
  me.getComponent().removeItemObject(tMsg.content)
  if objectExists(#furniChooser) then
    getObject(#furniChooser).update()
  end if
  me.getInterface().stopObjectMover()
end

on handle_updateitem me, tMsg 
  tItem = me.getComponent().getItemObject(tMsg.getProp(#word, 1))
  if objectp(tItem) then
    tItem.updateColor(the last word in tMsg.content)
  end if
end

on handle_stuffdataupdate me, tMsg 
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tLine = tMsg.getProp(#line, 1)
  tTarget = tLine.getProp(#item, 1)
  tKey = tLine.getProp(#item, 3)
  tValue = tLine.getProp(#item, 4)
  the itemDelimiter = tDelim
  if me.getComponent().activeObjectExists(tTarget) then
    call(#updateStuffdata, [me.getComponent().getActiveObject(tTarget)], tKey, tValue)
  else
    return(error(me, "Active object not found:" && tTarget, #handle_stuffdataupdate))
  end if
end

on handle_presentopen me, tMsg 
  ttype = tMsg.getProp(#line, 1)
  tCode = tMsg.getProp(#line, 2)
  tCard = "PackageCardObj"
  if objectExists(tCard) then
    getObject(tCard).showContent([#type:ttype, #code:tCode])
  else
    error(me, "Package card obj not found!", #handle_presentopen)
  end if
end

on handle_flatproperty me, tMsg 
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tLine = tMsg.content
  tdata = [#key:tLine.getProp(#item, 1), #value:tLine.getProp(#item, 2)]
  the itemDelimiter = tDelim
  tRoomPrg = me.getComponent().getRoomPrg()
  if tRoomPrg <> 0 then
    tRoomPrg.setProperty(tdata.getAt(#key), tdata.getAt(#value))
  else
    error(me, "Private room program not found!", #handle_flatproperty)
  end if
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
  i = 1
  repeat while i <= tCount
    the itemDelimiter = "/"
    tItem = tMsg.getProp(#item, i)
    if tItem = "" then
    else
      the itemDelimiter = numToChar(30)
      if tItem.count(#item) < 2 then
      else
        tObj = [:]
        tObj.setAt(#stripId, tItem.getProp(#item, 2))
        tObj.setAt(#striptype, tItem.getProp(#item, 4))
        tObj.setAt(#id, tItem.getProp(#item, 5))
        tObj.setAt(#class, tItem.getProp(#item, 6))
        if tObj.getAt(#striptype) = "S" then
          tObj.setAt(#name, getText("furni_" & tObj.getAt(#class) & "_name", "furni_" & tObj.getAt(#class) & "_name"))
          tObj.setAt(#striptype, "active")
          tObj.setAt(#custom, getText("furni_" & tObj.getAt(#class) & "_name", "furni_" & tObj.getAt(#class) & "_desc"))
          tObj.setAt(#dimensions, [integer(tItem.getProp(#item, 7)), integer(tItem.getProp(#item, 8))])
          tObj.setAt(#colors, tItem.getProp(#item, 9))
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
            if tObj.getAt(#striptype) = "poster" then
              tObj.setAt(#name, getText("poster_" & tObj.getAt(#props) & "_name", "poster_" & tObj.getAt(#props) & "_name"))
            else
              tObj.setAt(#name, getText("wallitem_" & tObj.getAt(#class) & "_name", "wallitem_" & tObj.getAt(#class) & "_name"))
            end if
          end if
        end if
        tProps.getAt(#objects).add(tObj)
        i = 1 + i
      end if
    end if
  end repeat
  the itemDelimiter = tDelim
  tInventory = me.getInterface().getContainer()
  if tObj.getAt(#striptype) = 140 then
    tInventory.updateStripItems(tProps.getAt(#objects))
    tInventory.setStripItemCount(tProps.getAt(#count))
    tInventory.open(1)
    tInventory.refresh()
  else
    if tObj.getAt(#striptype) = 98 then
      tInventory.appendStripItem(tProps.getAt(#objects).getAt(1))
      tInventory.open(1)
      tInventory.refresh()
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
end

on handle_youarenotallowed me 
  executeMessage(#alert, [#msg:"trade_youarenotallowed", #id:"youarenotallowed"])
end

on handle_othernotallowed me 
  executeMessage(#alert, [#msg:"trade_othernotallowed", #id:"othernotallowed"])
end

on handle_idata me, tMsg 
  tDelim = the itemDelimiter
  the itemDelimiter = "\t"
  tid = integer(tMsg.getPropRef(#line, 1).getProp(#item, 1))
  ttype = tMsg.getPropRef(#line, 1).getProp(#item, 2)
  tText = tMsg.getPropRef(#line, 1).getProp(#item, 2) & "\r" & tMsg.getProp(#line, 2, tMsg.count(#line))
  the itemDelimiter = tDelim
  executeMessage(symbol("itemdata_received" & tid), [#id:tid, #text:tText, #type:ttype])
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
    tMessage.setAt(tLine.getProp(#word, 1), tdata)
    i = 1 + i
  end repeat
  me.getInterface().getSafeTrader().refresh(tMessage)
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
    tDoorObj.animate(18)
    if getObject(#session).get("user_name") = tuser then
      tDoorObj.prepareToKick(tuser)
    end if
  end if
end

on handle_door_out me, tMsg 
  tDelim = the itemDelimiter
  tDoor = me.getComponent().getActiveObject(tMsg.getProp(#item, 1))
  the itemDelimiter = "/"
  if tDoor <> 0 then
    return(tDoor.animate())
  end if
end

on handle_doorflat me, tMsg 
  tConn = tMsg.connection
  tTeleId = tConn.GetIntFrom()
  tFlatID = tConn.GetIntFrom()
  if not tTeleId and tFlatID then
    return(error(me, "Retarded doorflat data!", #handle_doorflat))
  end if
  me.getComponent().startTeleport(tTeleId, tFlatID)
end

on handle_doordeleted me, tMsg 
  if getObject(#session).exists("current_door_ID") then
    tDoorID = getObject(#session).get("current_door_ID")
    tDoorObj = me.getComponent().getActiveObject(tDoorID)
    if tDoorObj <> 0 then
      tDoorObj.kickOut()
    end if
  end if
end

on handle_dice_value me, tMsg 
  tid = tMsg.getProp(#word, 1)
  tValue = integer(tMsg.getProp(#word, 2) - tid * 38)
  if me.getComponent().activeObjectExists(tid) then
    me.getComponent().getActiveObject(tid).diceThrown(tValue)
  end if
end

on handle_roomad me, tMsg 
  if tMsg.length > 1 then
    tDelim = the itemDelimiter
    the itemDelimiter = "\t"
    tSourceURL = tMsg.getProp(#item, 1)
    tTargetURL = tMsg.getProp(#item, 2)
    the itemDelimiter = tDelim
    me.getComponent().getAd().Init(tSourceURL, tTargetURL)
  else
    me.getComponent().getAd().Init(0)
  end if
end

on handle_petstat me, tMsg 
  tPetObj = me.getComponent().getUserObject(tMsg.GetIntFrom())
  if tPetObj = 0 then
    return(error(me, "Pet object not found!", #handle_petstat))
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
  if voidp(tUserObj) then
    return(0)
  end if
  tUserObj.pBadge = tBadge
  me.getInterface().uningoreAdmin(tUserID, tBadge)
  me.getInterface().updateInfoStandBadge(tBadge, tUserID)
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
    tItemFromH = tConn.GetStrFrom().float
    tItemToH = tConn.GetStrFrom().float
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
    call(#updateStuffdata, [tTileObj], "animate", 1)
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
        return(error(me, "Incompatible character movetype", #handle_slideobjectbundle))
      end if
    end if
  end if
  if tHasCharacter then
    tCharID = tConn.GetIntFrom()
    tFromH = float(tConn.GetStrFrom())
    tToH = float(tConn.GetStrFrom())
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
  tMsgs.setaProp(32, #handle_active_objects)
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
  tMsgs.setaProp(83, #handle_items)
  tMsgs.setaProp(84, #handle_removeitem)
  tMsgs.setaProp(85, #handle_updateitem)
  tMsgs.setaProp(88, #handle_stuffdataupdate)
  tMsgs.setaProp(89, #handle_door_out)
  tMsgs.setaProp(90, #handle_dice_value)
  tMsgs.setaProp(91, #handle_doorbell_ringing)
  tMsgs.setaProp(92, #handle_door_in)
  tMsgs.setaProp(93, #handle_active_objects)
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
  tMsgs.setaProp(140, #handle_stripinfo)
  tMsgs.setaProp(208, #handle_roomad)
  tMsgs.setaProp(210, #handle_petstat)
  tMsgs.setaProp(219, #handle_heightmapupdate)
  tMsgs.setaProp(228, #handle_userbadge)
  tMsgs.setaProp(230, #handle_slideobjectbundle)
  tCmds = [:]
  tCmds.setaProp(#room_directory, 2)
  tCmds.setaProp("GET_ADV", 11)
  tCmds.setaProp("ADVIEW", 27)
  tCmds.setaProp("GETDOORFLAT", 28)
  tCmds.setaProp("ADCLICK", 45)
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
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  return(1)
end

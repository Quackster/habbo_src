property pLastStatusOK, pStatusPeriod

on construct me 
  pLastStatusOK = the milliSeconds
  pStatusPeriod = getIntVariable("room.status.period", 45000)
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on parse_opc_ok me, tMsg 
  if (me.getComponent().getRoomID() = "private") then
    me.getComponent().roomConnected(void(), tMsg.subject)
  end if
end

on parse_clc me 
  me.getComponent().roomDisconnected()
end

on parse_youaremod me, tMsg 
  getObject(#session).set("moderator", tMsg.message.getProp(#line, 2))
end

on parse_flat_letin me, tMsg 
  executeMessage("flat_letin")
  me.getComponent().roomConnected(void(), tMsg.subject)
end

on parse_room_ready me, tMsg 
  me.getComponent().roomConnected(tMsg.content.getProp(#word, 1), tMsg.subject)
end

on parse_logout me, tMsg 
  tuser = tMsg.content.getProp(#word, 1)
  if tuser <> getObject(#session).get("user_name") then
    me.getComponent().removeUserObject(tuser)
  end if
end

on parse_disconnect me 
  me.getComponent().roomDisconnected()
end

on parse_error me, tMsg 
  me.getHandler().handle_error(tMsg.content, tMsg.connection)
end

on parse_doorbell_ringing me, tMsg 
  me.getInterface().showDoorBell(tMsg.content)
end

on parse_status me, tMsg 
  tList = []
  tCount = tMsg.content.count(#line)
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  i = 1
  repeat while i <= tCount
    tLine = tMsg.content.getProp(#line, i)
    if length(tLine) > 5 then
      tuser = [:]
      tuser.setAt(#id, tLine.getPropRef(#item, 1).getProp(#word, 1))
      tloc = tLine.getPropRef(#item, 1).getProp(#word, 2)
      the itemDelimiter = ","
      tuser.setAt(#x, integer(tloc.getProp(#item, 1)))
      tuser.setAt(#y, integer(tloc.getProp(#item, 2)))
      tuser.setAt(#h, integer(tloc.getProp(#item, 3)))
      tuser.setAt(#dirHead, (integer(tloc.getProp(#item, 4)) mod 8))
      tuser.setAt(#dirBody, (integer(tloc.getProp(#item, 5)) mod 8))
      tActions = []
      the itemDelimiter = "/"
      j = 2
      repeat while j <= tLine.count(#item)
        if length(tLine.getProp(#item, j)) > 1 then
          tActions.add([#name:tLine.getPropRef(#item, j).getProp(#word, 1), #params:tLine.getProp(#item, j)])
        end if
        j = (1 + j)
      end repeat
      tuser.setAt(#actions, tActions)
      tList.add(tuser)
    end if
    i = (1 + i)
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
  if (the milliSeconds - pLastStatusOK) > pStatusPeriod then
    getConnection(tMsg.connection).send(#room, "STATUSOK")
    pLastStatusOK = the milliSeconds
  end if
end

on parse_chat me, tMsg 
  tuser = tMsg.content.getProp(#word, 1)
  tChat = tMsg.content.getProp(#word, 2, tMsg.content.count(#word))
  tProp = [#command:tMsg.subject, #id:tuser, #message:tChat]
  if me.getComponent().userObjectExists(tuser) then
    me.getComponent().getBalloon().createBalloon(tProp)
  end if
end

on parse_users me, tMsg 
  tCount = tMsg.content.count(#line)
  tDelim = the itemDelimiter
  tList = [:]
  tuser = ""
  if not threadExists(#registration) then
    error(me, "Registration thread not found!", #parse_users)
    return FALSE
  end if
  f = 1
  repeat while f <= tCount
    tLine = tMsg.content.getProp(#line, f)
    tProp = tLine.getProp(#char, 1)
    tdata = tLine.getProp(#char, 3, length(tLine))
    if (tProp = "n") then
      tuser = tdata
      tList.setAt(tuser, [:])
      tList.getAt(tuser).setAt(#id, tuser)
      tList.getAt(tuser).setAt(#direction, [0, 0])
      tList.getAt(tuser).setAt(#class, "user")
    else
      if (tProp = "f") then
        tList.getAt(tuser).setAt(#figure, tdata)
      else
        if (tProp = "l") then
          tList.getAt(tuser).setAt(#x, integer(tdata.getProp(#word, 1)))
          tList.getAt(tuser).setAt(#y, integer(tdata.getProp(#word, 2)))
          tList.getAt(tuser).setAt(#h, integer(tdata.getProp(#word, 3)))
        else
          if (tProp = "c") then
            tList.getAt(tuser).setAt(#custom, tdata)
          else
            if (tProp = "s") then
              if (tdata.getProp(#char, 1) = "F") or (tdata.getProp(#char, 1) = "f") then
                tList.getAt(tuser).setAt(#sex, "F")
              else
                tList.getAt(tuser).setAt(#sex, "M")
              end if
            else
              if (tProp = "p") then
                if tdata contains "ch=s" then
                  the itemDelimiter = "/"
                  tmodel = tdata.getProp(#char, 4, 6)
                  tColor = tdata.getProp(#item, 2)
                  the itemDelimiter = ","
                  if (tColor.count(#item) = 3) then
                    tColor = value("rgb(" & tColor & ")")
                  else
                    tColor = rgb(#EEEEEE)
                  end if
                  tList.getAt(tuser).setAt(#phfigure, ["model":tmodel, "color":tColor])
                  tList.getAt(tuser).setAt(#class, "pelle")
                end if
              else
                if (tLine.getProp(#word, 1) = "[bot]") then
                  tList.getAt(tuser).setAt(#class, "bot")
                end if
              end if
            end if
          end if
        end if
      end if
    end if
    f = (1 + f)
  end repeat
  tFigureParser = getThread(#registration).getComponent()
  repeat while tProp <= undefined
    tuser = getAt(undefined, tMsg)
    tuser.setAt(#figure, tFigureParser.parseFigure(tuser.getAt(#figure), tuser.getAt(#sex), tuser.getAt(#class)))
  end repeat
  the itemDelimiter = tDelim
  me.getHandler().handle_users(tList)
end

on parse_showprogram me, tMsg 
  tLine = tMsg.content
  tDst = tLine.getProp(#word, 1)
  tCmd = tLine.getProp(#word, 2)
  tArg = tLine.getProp(#word, 3, tLine.count(#word))
  tList = [#command:tMsg.subject, #show_dest:tDst, #show_command:tCmd, #show_params:tArg]
  tObj = me.getComponent().getRoomPrg()
  if objectp(tObj) then
    call(#showprogram, [tObj], tList)
  end if
end

on parse_heightmap me, tMsg 
  me.getComponent().validateHeightMap(tMsg.content)
end

on parse_objects me, tMsg 
  tList = []
  tCount = tMsg.message.count(#line)
  i = 2
  repeat while i <= tCount
    tLine = tMsg.content.getProp(#line, i)
    if length(tLine) > 5 then
      tObj = [:]
      tObj.setAt(#id, tLine.getProp(#word, 1))
      tObj.setAt(#class, tLine.getProp(#word, 2))
      tObj.setAt(#x, integer(tLine.getProp(#word, 3)))
      tObj.setAt(#y, integer(tLine.getProp(#word, 4)))
      tObj.setAt(#h, integer(tLine.getProp(#word, 5)))
      if (tLine.count(#word) = 6) then
        tdir = (integer(tLine.getProp(#word, 6)) mod 8)
        tObj.setAt(#direction, [tdir, tdir, tdir])
        tObj.setAt(#dimensions, 0)
      else
        tObj.setAt(#width, integer(tLine.getProp(#word, 6)))
        tObj.setAt(#height, integer(tLine.getProp(#word, 7)))
        tObj.setAt(#dimensions, [tObj.getAt(#width), tObj.getAt(#height)])
        tObj.setAt(#x, ((tObj.getAt(#x) + tObj.getAt(#width)) - 1))
        tObj.setAt(#y, ((tObj.getAt(#y) + tObj.getAt(#height)) - 1))
      end if
      if tObj.getAt(#id) <> "" then
        tList.add(tObj)
      end if
    end if
    i = (1 + i)
  end repeat
  me.getHandler().handle_OBJECTS(tList)
end

on parse_active_objects me, tMsg 
  tList = []
  tCount = tMsg.content.count(#line)
  tDelim = the itemDelimiter
  i = 1
  repeat while i <= tCount
    tLine = tMsg.content.getProp(#line, i)
    if (tLine = "") then
    else
      the itemDelimiter = "/"
      tstate = tLine.getProp(#item, 1)
      the itemDelimiter = ","
      tObj = [:]
      tObj.setAt(#id, tstate.getProp(#item, 1))
      tOther = tstate.getProp(#char, (offset(",", tstate) + 1), length(tstate))
      tObj.setAt(#class, tOther.getProp(#word, 1))
      tObj.setAt(#x, integer(tOther.getProp(#word, 2)))
      tObj.setAt(#y, integer(tOther.getProp(#word, 3)))
      tObj.setAt(#width, integer(tOther.getProp(#word, 4)))
      tObj.setAt(#height, integer(tOther.getProp(#word, 5)))
      tDirection = (integer(tOther.getProp(#word, 6)) mod 8)
      tObj.setAt(#direction, [tDirection, tDirection, tDirection])
      tObj.setAt(#dimensions, [tObj.width, tObj.height])
      tObj.setAt(#altitude, float(tOther.getProp(#word, 7)))
      tObj.setAt(#colors, tOther.getProp(#word, 8))
      the itemDelimiter = "/"
      tObj.setAt(#props, [:])
      tObj.setAt(#name, tLine.getProp(#item, 2))
      tObj.setAt(#custom, tLine.getProp(#item, 3))
      tBool = 1
      j = 4
      repeat while tBool
        tKey = tLine.getProp(#item, j)
        tdata = tLine.getProp(#item, (j + 1))
        if (length(tKey) = 0) then
          tBool = 0
        else
          tObj.getAt(#props).setAt(tKey, tdata)
        end if
        j = (j + 2)
      end repeat
      if tObj.getAt(#id) <> "" then
        tList.add(tObj)
      end if
      i = (1 + i)
    end if
  end repeat
  the itemDelimiter = tDelim
  me.getHandler().handle_active_objects(tList)
end

on parse_activeobject_remove me, tMsg 
  me.getComponent().removeActiveObject(tMsg.content.getProp(#word, 1))
end

on parse_activeobject_update me, tMsg 
  tLine = tMsg.content.getProp(#line, 1)
  if (tLine = "") then
    return FALSE
  end if
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tstate = tLine.getProp(#item, 1)
  the itemDelimiter = ","
  tObj = [:]
  tObj.setAt(#id, tstate.getProp(#item, 1))
  tOther = tstate.getProp(#char, (offset(",", tstate) + 1), length(tstate))
  tObj.setAt(#class, tOther.getProp(#word, 1))
  tObj.setAt(#x, integer(tOther.getProp(#word, 2)))
  tObj.setAt(#y, integer(tOther.getProp(#word, 3)))
  tObj.setAt(#width, integer(tOther.getProp(#word, 4)))
  tObj.setAt(#height, integer(tOther.getProp(#word, 5)))
  tDirection = (integer(tOther.getProp(#word, 6)) mod 8)
  tObj.setAt(#direction, [tDirection, tDirection, tDirection])
  tObj.setAt(#dimensions, [tObj.width, tObj.height])
  tObj.setAt(#altitude, float(tOther.getProp(#word, 7)))
  tObj.setAt(#colors, tOther.getProp(#word, 8))
  the itemDelimiter = "/"
  tObj.setAt(#props, [:])
  tObj.setAt(#name, tLine.getProp(#item, 2))
  tObj.setAt(#custom, tLine.getProp(#item, 3))
  tBool = 1
  j = 4
  repeat while tBool
    tKey = tLine.getProp(#item, j)
    tdata = tLine.getProp(#item, (j + 1))
    if (length(tKey) = 0) then
      tBool = 0
    else
      tObj.getAt(#props).setAt(tKey, tdata)
    end if
    j = (j + 2)
  end repeat
  the itemDelimiter = tDelim
  me.getHandler().handle_activeobject_update(tObj)
end

on parse_items me, tMsg 
  tList = []
  tDelim = the itemDelimiter
  i = 1
  repeat while i <= tMsg.content.count(#line)
    the itemDelimiter = "\t"
    tLine = tMsg.content.getProp(#line, i)
    if tLine <> "" then
      tObj = [:]
      tObj.setAt(#id, tLine.getProp(#item, 1))
      tObj.setAt(#class, tLine.getProp(#item, 2))
      tObj.setAt(#owner, tLine.getProp(#item, 3))
      tObj.setAt(#type, tLine.getProp(#item, 5))
      if not (tLine.getPropRef(#item, 4).getProp(#char, 1) = ":") then
        tObj.setAt(#direction, tLine.getPropRef(#item, 4).getProp(#word, 1))
        if (tObj.getAt(#direction) = "frontwall") then
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
        if (tDirChar = "r") then
          tObj.setAt(#direction, "rightwall")
        else
          if (tDirChar = "l") then
            tObj.setAt(#direction, "leftwall")
          end if
        end if
        tObj.setAt(#formatVersion, #new)
      end if
      tList.add(tObj)
    end if
    i = (1 + i)
  end repeat
  the itemDelimiter = tDelim
  me.getHandler().handle_items(tList)
end

on parse_removeitem me, tMsg 
  me.getComponent().removeItemObject(tMsg.content)
end

on parse_updateitem me 
  error(me, "Unfinished method!!!", #parse_updateitem)
end

on parse_stuffdataupdate me, tMsg 
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tLine = tMsg.content.getProp(#line, 1)
  tProps = [#target:tLine.getProp(#item, 1), #key:tLine.getProp(#item, 3), #value:tLine.getProp(#item, 4)]
  the itemDelimiter = tDelim
  me.getHandler().handle_stuffdataupdate(tProps)
end

on parse_presentopen me, tMsg 
  ttype = tMsg.message.getProp(#line, 2)
  tCode = tMsg.message.getProp(#line, 3)
  me.getHandler().handle_presentopen([#type:ttype, #code:tCode])
end

on parse_present_nottimeyet me, tMsg 
  put("Hands off! Christmas presents can't be opened until December 24th (6pm GMT).")
end

on parse_flatproperty me, tMsg 
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

on parse_room_rights me, tMsg 
  if (tMsg.subject = "YOUARECONTROLLER") then
    getObject(#session).set("room_controller", 1)
  else
    if (tMsg.subject = "YOUNOTCONTROLLER") then
      getObject(#session).set("room_controller", 0)
    else
      if (tMsg.subject = "YOUAREOWNER") then
        getObject(#session).set("room_owner", 1)
      end if
    end if
  end if
end

on parse_stripinfo me, tMsg 
  tProps = [#objects:[], #count:0]
  tDelim = the itemDelimiter
  tProps.setAt(#count, integer(tMsg.content.getProp(#line, tMsg.content.count(#line))))
  the itemDelimiter = "/"
  tCount = tMsg.content.count(#item)
  i = 1
  repeat while i <= tCount
    the itemDelimiter = "/"
    tItem = tMsg.content.getProp(#item, i)
    if (tItem = "") then
    else
      the itemDelimiter = "|"
      if tItem.count(#item) < 2 then
      else
        tObj = [:]
        tObj.setAt(#stripId, tItem.getProp(#item, 2))
        tObj.setAt(#striptype, tItem.getProp(#item, 4))
        tObj.setAt(#id, tItem.getProp(#item, 5))
        tObj.setAt(#class, tItem.getProp(#item, 6))
        tObj.setAt(#name, tItem.getProp(#item, 7))
        if (tObj.getAt(#striptype) = "S") then
          tObj.setAt(#striptype, "active")
          tObj.setAt(#custom, tItem.getProp(#item, 8))
          tObj.setAt(#dimensions, [integer(tItem.getProp(#item, 9)), integer(tItem.getProp(#item, 10))])
          tObj.setAt(#colors, tItem.getProp(#item, 11))
          the itemDelimiter = ","
          if (tObj.getAt(#colors).getProp(#char, 1) = "*") then
            if tObj.getAt(#colors).count(#item) > 1 then
              tObj.setAt(#stripColor, rgb(tObj.getAt(#colors).getPropRef(#item, tObj.getAt(#colors).count(#item)).getProp(#char, 2, 7)))
            else
              tObj.setAt(#stripColor, rgb(tObj.getAt(#colors).getProp(#char, 2, 7)))
            end if
          else
            tObj.setAt(#stripColor, 0)
          end if
        else
          if (tObj.getAt(#striptype) = "I") then
            tObj.setAt(#striptype, "item")
            tObj.setAt(#props, tItem.getProp(#item, 8))
            tObj.setAt(#custom, tItem.getProp(#item, 9))
          end if
        end if
        tProps.getAt(#objects).add(tObj)
        i = (1 + i)
      end if
    end if
  end repeat
  the itemDelimiter = tDelim
  if (tObj.getAt(#striptype) = "STRIPINFO") then
    me.getHandler().handle_stripinfo(tProps)
  else
    if (tObj.getAt(#striptype) = "ADDSTRIPITEM") then
      me.getHandler().handle_addstripitem(tProps)
    else
      if (tObj.getAt(#striptype) = "TRADE_ITEMS") then
        return(tProps)
      end if
    end if
  end if
end

on parse_stripupdated me, tMsg 
  getConnection(tMsg.connection).send(#room, "GETSTRIP new")
end

on parse_removestripitem me, tMsg 
  me.getInterface().getContainer().removeStripItem(tMsg.content.getProp(#word, 1))
end

on parse_youarenotallowed me 
  executeMessage(#alert, [#msg:"trade_youarenotallowed", #id:"youarenotallowed"])
end

on parse_othernotallowed me 
  executeMessage(#alert, [#msg:"trade_othernotallowed", #id:"othernotallowed"])
end

on parse_idata me, tMsg 
  tDelim = the itemDelimiter
  the itemDelimiter = "\t"
  tid = integer(tMsg.content.getPropRef(#line, 1).getProp(#item, 1))
  tText = tMsg.content.getPropRef(#line, 1).getProp(#item, 2) & "\r" & tMsg.content.getProp(#line, 2, tMsg.content.count(#line))
  the itemDelimiter = tDelim
  tProps = [#id:tid, #text:tText]
  executeMessage(symbol("itemdata_received" & tid), tProps)
end

on parse_trade_items me, tMsg 
  tMessage = [:]
  i = 1
  repeat while i <= 2
    tLine = tMsg.content.getProp(#line, i)
    tdata = [:]
    tdata.setAt(#accept, tLine.getProp(#word, 2))
    tItemStr = "Kludgetus" & "\r" & tLine.getProp(#word, 3, tLine.count(#word)) & "\r" & 1
    tdata.setAt(#items, me.parse_stripinfo([#subject:"TRADE_ITEMS", #content:tItemStr]).getaProp(#objects))
    tMessage.setAt(tLine.getProp(#word, 1), tdata)
    i = (1 + i)
  end repeat
  me.getInterface().getSafeTrader().refresh(tMessage)
end

on parse_trade_close me, tMsg 
  me.getInterface().getSafeTrader().close()
  getConnection(tMsg.connection).send(#room, "GETSTRIP new")
end

on parse_trade_accept me, tMsg 
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tuser = tMsg.content.getProp(#item, 1)
  tValue = tMsg.content.getProp(#item, 2)
  if (tValue = "true") then
    tValue = 1
  else
    if (tValue = "false") then
      tValue = 0
    end if
  end if
  the itemDelimiter = tDelim
  me.getInterface().getSafeTrader().accept(tuser, tValue)
end

on parse_trade_completed me, tMsg 
  me.getInterface().getSafeTrader().complete()
end

on parse_door_in me, tMsg 
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tDoor = tMsg.content.getProp(#item, 1)
  tuser = tMsg.content.getProp(#item, 2)
  tParam = tMsg.content.getProp(#item, 3)
  the itemDelimiter = tDelim
  tProps = [#door:tDoor, #user:tuser, #param:tParam]
  me.getHandler().handle_door_in(tProps)
end

on parse_door_out me, tMsg 
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tDoor = tMsg.content.getProp(#item, 1)
  tuser = tMsg.content.getProp(#item, 2)
  tParam = tMsg.content.getProp(#item, 3)
  the itemDelimiter = tDelim
  tProps = [#door:tDoor, #user:tuser, #param:tParam]
  me.getHandler().handle_door_out(tProps)
end

on parse_doorflat me, tMsg 
  tDelim = the itemDelimiter
  the itemDelimiter = "/"
  tStr = tMsg.content
  tDoorID = tStr.getPropRef(#line, 1).getProp(#word, 1)
  tFlatID = tStr.getPropRef(#line, 2).getProp(#item, 1)
  tName = tStr.getPropRef(#line, 2).getProp(#item, 2)
  towner = tStr.getPropRef(#line, 2).getProp(#item, 3)
  tOpen = tStr.getPropRef(#line, 2).getProp(#item, 4)
  tFloorA = tStr.getPropRef(#line, 2).getProp(#item, 5)
  tFloorB = tStr.getPropRef(#line, 2).getProp(#item, 6)
  tHost = tStr.getPropRef(#line, 2).getProp(#item, 7)
  tip = tStr.getPropRef(#line, 2).getProp(#item, 8)
  tPort = tStr.getPropRef(#line, 2).getProp(#item, 9)
  tDesc = tStr.getPropRef(#line, 2).getProp(#item, 12)
  the itemDelimiter = tDelim
  tMsg = [#name:tName, #owner:towner, #door:"open", #id:tFlatID, #ip:tip, #port:tPort, #teleport:tDoorID]
  me.getHandler().handle_doorflat(tMsg)
end

on parse_doordeleted me, tMsg 
  if getObject(#session).exists("current_door_ID") then
    tDoorID = getObject(#session).get("current_door_ID")
    tDoorObj = me.getComponent().getActiveObject(tDoorID)
    if tDoorObj <> 0 then
      tDoorObj.kickOut()
    end if
  end if
end

on parse_dice_value me, tMsg 
  tid = tMsg.message.getProp(#word, 2)
  tValue = integer((tMsg.message.getProp(#word, 3) - (tid * 38)))
  if me.getComponent().activeObjectExists(tid) then
    me.getComponent().getActiveObject(tid).diceThrown(tValue)
  end if
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setAt("OPC_OK", #parse_opc_ok)
  tMsgs.setAt("CLC", #parse_clc)
  tMsgs.setAt("YOUAREMOD", #parse_youaremod)
  tMsgs.setAt("FLAT_LETIN", #parse_flat_letin)
  tMsgs.setAt("ROOM_READY", #parse_room_ready)
  tMsgs.setAt("LOGOUT", #parse_logout)
  tMsgs.setAt("DISCONNECT", #parse_disconnect)
  tMsgs.setAt("ERROR", #parse_error)
  tMsgs.setAt("DOORBELL_RINGING", #parse_doorbell_ringing)
  tMsgs.setAt("STATUS", #parse_status)
  tMsgs.setAt("CHAT", #parse_chat)
  tMsgs.setAt("SHOUT", #parse_chat)
  tMsgs.setAt("WHISPER", #parse_chat)
  tMsgs.setAt("USERS", #parse_users)
  tMsgs.setAt("SHOWPROGRAM", #parse_showprogram)
  tMsgs.setAt("HEIGHTMAP", #parse_heightmap)
  tMsgs.setAt("OBJECTS", #parse_objects)
  tMsgs.setAt("ACTIVE_OBJECTS", #parse_active_objects)
  tMsgs.setAt("ACTIVEOBJECT_ADD", #parse_active_objects)
  tMsgs.setAt("ACTIVEOBJECT_REMOVE", #parse_activeobject_remove)
  tMsgs.setAt("ITEMS", #parse_items)
  tMsgs.setAt("ADDITEM", #parse_items)
  tMsgs.setAt("REMOVEITEM", #parse_removeitem)
  tMsgs.setAt("UPDATEITEM", #parse_updateitem)
  tMsgs.setAt("ACTIVEOBJECT_UPDATE", #parse_activeobject_update)
  tMsgs.setAt("STUFFDATAUPDATE", #parse_stuffdataupdate)
  tMsgs.setAt("PRESENTOPEN", #parse_presentopen)
  tMsgs.setAt("PRESENT_NOTTIMEYET", #parse_present_nottimeyet)
  tMsgs.setAt("FLATPROPERTY", #parse_flatproperty)
  tMsgs.setAt("YOUARECONTROLLER", #parse_room_rights)
  tMsgs.setAt("YOUNOTCONTROLLER", #parse_room_rights)
  tMsgs.setAt("YOUAREOWNER", #parse_room_rights)
  tMsgs.setAt("STRIPINFO", #parse_stripinfo)
  tMsgs.setAt("ADDSTRIPITEM", #parse_stripinfo)
  tMsgs.setAt("STRIPUPDATED", #parse_stripupdated)
  tMsgs.setAt("REMOVESTRIPITEM", #parse_removestripitem)
  tMsgs.setAt("TRADE_ITEMS", #parse_trade_items)
  tMsgs.setAt("TRADE_ACCEPT", #parse_trade_accept)
  tMsgs.setAt("TRADE_CLOSE", #parse_trade_close)
  tMsgs.setAt("TRADE_COMPLETED", #parse_trade_completed)
  tMsgs.setAt("TRADE_ALREADYOPEN", #parse_trade_completed)
  tMsgs.setAt("TRADE_YOUARENOTALLOWED", #parse_youarenotallowed)
  tMsgs.setAt("TRADE_OTHERNOTALLOWED", #parse_othernotallowed)
  tMsgs.setAt("IDATA", #parse_idata)
  tMsgs.setAt("DOOR_IN", #parse_door_in)
  tMsgs.setAt("DOOR_OUT", #parse_door_out)
  tMsgs.setAt("DICE_VALUE", #parse_dice_value)
  tCmds = [:]
  tCmds.setAt(#room_directory, numToChar(128) & numToChar(130))
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  tMsgs = [:]
  tMsgs.setAt("DOORFLAT", #parse_doorflat)
  tMsgs.setAt("DOORDELETED", #parse_doordeleted)
  tMsgs.setAt("DOORNOTINSTALLED", #parse_doordeleted)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
  end if
  return TRUE
end

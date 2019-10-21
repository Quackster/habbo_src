on construct(me)
  return(me.regMsgList(1))
  exit
end

on deconstruct(me)
  return(me.regMsgList(0))
  exit
end

on parse_hello(me, tMsg)
  getConnection(tMsg.connection).send(#info, "VERSIONCHECK" && getVariable("client.version.id"))
  exit
end

on parse_secret_key(me, tMsg)
  tKey = secretDecode(tMsg.content)
  tConnection = getConnection(tMsg.connection)
  tConnection.setDecoder(createObject(#temp, getClassVariable("connection.decoder.class")))
  tConnection.getDecoder().setKey(tKey)
  tConnection.setEncryption(1)
  tConnection.send(#info, "KEYENCRYPTED" && tKey)
  tConnection.send(#info, "CLIENTIP" && getNetAddressCookie(tConnection.getProperty(#xtra), 1))
  return(me.getComponent().updateState("connectionOk"))
  exit
end

on parse_ok(me, tMsg)
  tUserName = getObject(#session).get(#userName)
  tPassword = getObject(#session).get(#password)
  getConnection(tMsg.connection).send(#info, "INFORETRIEVE" && tUserName && tPassword)
  getConnection(tMsg.connection).send(#info, "GETCREDITS")
  exit
end

on parse_user_rights(me, tMsg)
  tList = []
  i = 1
  repeat while i <= tMsg.count(#line)
    tLine = tMsg.getPropRef(#line, i).getProp(#word, 1)
    if tLine <> "" then
      tList.add(tMsg.getPropRef(#line, i).getProp(#word, 1))
    end if
    i = 1 + i
  end repeat
  getObject(#session).set("user_rights", tList)
  exit
end

on parse_disconnect(me, tMsg)
  error(me, "Connection was disconnected:" && tMsg.getaProp(#connection), #parse_disconnect)
  return(me.getComponent().updateState("disconnection"))
  exit
end

on parse_systembroadcast(me, tMsg)
  tMsg = tMsg.getAt(#content)
  tMsg = replaceChunks(tMsg, "\\r", "\r")
  tMsg = replaceChunks(tMsg, "<br>", "\r")
  executeMessage(#alert, [#msg:tMsg])
  the keyboardFocusSprite = 0
  exit
end

on parse_units(me, tMsg)
  tList = []
  tDelim = the itemDelimiter
  the itemDelimiter = "\t"
  i = 1
  repeat while i <= tMsg.count(#line)
    tLine = tMsg.getProp(#line, i)
    if tLine = "" then
    else
      tUnit = []
      tUnit.setAt(#port, tLine.getProp(#item, 1))
      tUnit.setAt(#ip, tLine.getProp(#item, 2))
      tUnit.setAt(#name, tLine.getProp(#item, 3))
      tUnit.setAt(#usercount, integer(tLine.getProp(#item, 4)))
      tUnit.setAt(#maxUsers, integer(tLine.getProp(#item, 5)))
      tUnit.setAt(#marker, tLine.getProp(#item, 9))
      tTempUnitID = string(tUnit.getAt(#port)) & "/0"
      if not variableExists(tTempUnitID) then
        error(me, "Public room's ID not found:" && tTempUnitID && tUnit.getAt(#name), #parse_units)
      else
        tUnitid = getVariable(tTempUnitID)
        tUnit.setAt(#subunitcount, tLine.count(#item) - 5 / 4)
        tList.setAt(tUnitid, tUnit)
        if tUnit.getAt(#subunitcount) > 1 then
          tSubOrderNum = 1
          j = 6
          repeat while j <= tLine.count(#item)
            tSub = []
            tTempUnitID = string(tUnit.getAt(#port)) & "/" & tSubOrderNum
            if not variableExists(tTempUnitID) then
              if tList.getAt(tUnitid).getAt(#subunitcount) > 1 then
                tList.getAt(tUnitid).setAt(#subunitcount, tUnit.getAt(#subunitcount) - 1)
              end if
            else
              tSubId = getVariable(tTempUnitID)
              tSub.setAt(#name, tLine.getProp(#item, j))
              tSub.setAt(#usercount, integer(tLine.getProp(#item, j + 1)))
              tSub.setAt(#maxUsers, integer(tLine.getProp(#item, j + 2)))
              tSub.setAt(#marker, tLine.getProp(#item, j + 3))
              tSub.setAt(#ip, tUnit.getAt(#ip))
              tSub.setAt(#subunitcount, 0)
              tSub.setAt(#subordernum, tSubOrderNum)
              tSub.setAt(#door, tSubOrderNum - 1)
              tSub.setAt(#mymainunitid, tUnitid)
              tSub.setAt(#port, tUnit.getAt(#port))
              tList.setAt(tSubId, tSub)
              tSubOrderNum = tSubOrderNum + 1
            end if
            j = j + 3
            j = 1 + j
          end repeat
        end if
      end if
      i = 1 + i
    end if
  end repeat
  the itemDelimiter = tDelim
  me.getComponent().saveUnitList(tList)
  exit
end

on parse_unitupdates(me, tMsg)
  tList = []
  tDelim = the itemDelimiter
  the itemDelimiter = "\t"
  i = 1
  repeat while i <= tMsg.count(#line)
    tLine = tMsg.getProp(#line, i)
    if tLine = "" then
    else
      tUnit = [#usercount:integer(tLine.getProp(#item, 2))]
      tUnitPort = tLine.getProp(#item, 1)
      tTempUnitID = string(tUnitPort) & "/0"
      if variableExists(tTempUnitID) then
        tUnitid = getVariable(tTempUnitID)
        tList.setAt(tUnitid, tUnit)
        if tLine.count(#item) > 2 then
          tSubOrderNum = 1
          j = 3
          repeat while j <= tLine.count(#item)
            tSub = []
            tTempUnitID = string(tUnitPort) & "/" & tSubOrderNum
            if variableExists(tTempUnitID) then
              tSubId = getVariable(tTempUnitID)
              tSub.setAt(#usercount, integer(tLine.getProp(#item, j)))
              tList.setAt(tSubId, tSub)
              tSubOrderNum = tSubOrderNum + 1
            end if
            j = 1 + j
          end repeat
        end if
      end if
      i = 1 + i
    end if
  end repeat
  the itemDelimiter = tDelim
  me.getComponent().UpdateUnitList(tList)
  exit
end

on parse_flatinfo(me, tMsg)
  tFlat = []
  tDelim = the itemDelimiter
  f = 1
  repeat while f <= tMsg.count(#line)
    the itemDelimiter = "="
    tList = []
    tLine = tMsg.getProp(#line, f)
    tProp = tLine.getProp(#item, 1)
    tDesc = tLine.getProp(#item, 2, tLine.count(#item))
    if me = "i" then
      tFlat.setAt(#id, tDesc)
    else
      if me = "n" then
        tFlat.setAt(#name, tDesc)
      else
        if me = "o" then
          tFlat.setAt(#owner, tDesc)
        else
          if me = "m" then
            tFlat.setAt(#door, tDesc)
          else
            if me = "u" then
              tFlat.setAt(#port, tDesc)
            else
              if me = "w" then
                tFlat.setAt(#showownername, value(tDesc) = 1)
              else
                if me = "t" then
                  tFlat.setAt(#marker, tDesc)
                else
                  if me = "d" then
                    tFlat.setAt(#description, tDesc)
                  else
                    if me = "a" then
                      tFlat.setAt(#ableothersmovefurniture, value(tDesc) = 1)
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
  tList.setAt(tFlat.getAt(#id), tFlat)
  the itemDelimiter = tDelim
  me.getComponent().saveFlatInfo(tList)
  exit
end

on parse_flat_results(me, tMsg)
  tList = []
  tDelim = the itemDelimiter
  the itemDelimiter = "\t"
  i = 2
  repeat while i <= tMsg.count(#line)
    tLine = tMsg.getProp(#line, i)
    if tLine = "" then
    else
      tFlat = []
      tFlat.setAt(#id, tLine.getProp(#item, 1))
      tFlat.setAt(#name, tLine.getProp(#item, 2))
      tFlat.setAt(#owner, tLine.getProp(#item, 3))
      tFlat.setAt(#door, tLine.getProp(#item, 4))
      tFlat.setAt(#port, tLine.getProp(#item, 5))
      tFlat.setAt(#usercount, tLine.getProp(#item, 6))
      tFlat.setAt(#filter, tLine.getProp(#item, 7))
      tFlat.setAt(#description, tLine.getProp(#item, 8))
      tList.setAt(tFlat.getAt(#id), tFlat)
      i = 1 + i
    end if
  end repeat
  if me = "FLAT_RESULTS" then
    tMode = #update
  else
    if me = "BUSY_FLAT_RESULTS" then
      tMode = #busy
    else
      if me = "FAVORITE_FLAT_RESULTS" then
        tMode = #favorite
      end if
    end if
  end if
  the itemDelimiter = tDelim
  me.getComponent().saveFlatList(tList, tMode)
  exit
end

on parse_noflatsforuser(me, tMsg)
  me.getComponent().noflatsforuser(tMsg.content)
  exit
end

on parse_noflats(me, tMsg)
  me.getComponent().noflats("NO_FLATS_FOUND")
  exit
end

on parse_nosuchflat(me, tMsg)
  put("TODO: nosuchflat")
  exit
end

on parse_noprvusers(me, tMsg)
  exit
end

on parse_prvunits(me, tMsg)
  tList = []
  tDelim = the itemDelimiter
  the itemDelimiter = "\t"
  f = 1
  repeat while f <= tMsg.count(#line)
    tLine = tMsg.getProp(#line, f)
    if length(tLine) > 5 then
      tPort = tLine.getProp(#item, 1)
      tip = tLine.getProp(#item, 2)
      tFloor = tLine.getProp(#item, 3)
      tUsers = integer(tLine.getProp(#item, 4))
      tMaxUsers = integer(tLine.getProp(#item, 5))
      tList.setAt(tPort, [#ip:tip, #floor:tFloor, #users:tUsers, #maxUsers:tMaxUsers])
    end if
    f = 1 + f
  end repeat
  the itemDelimiter = tDelim
  me.getComponent().prepareFlatList(tList)
  exit
end

on parse_unitmembers(me, tMsg)
  tStr = ""
  i = 1
  repeat while i <= tMsg.count(#line)
    tLine = tMsg.getProp(#line, i)
    if tLine = "" then
    else
      tStr = tStr & tLine & ", "
      i = 1 + i
    end if
  end repeat
  tStr = tStr.getProp(#char, 1, length(tStr) - 2)
  me.getInterface().updateUnitUsers(tStr)
  exit
end

on parse_userobject(me, tMsg)
  tuser = []
  tDelim = the itemDelimiter
  the itemDelimiter = "="
  i = 1
  repeat while i <= tMsg.count(#line)
    tLine = tMsg.getProp(#line, i)
    tuser.setAt(tLine.getProp(#item, 1), tLine.getProp(#item, 2, tLine.count(#item)))
    i = 1 + i
  end repeat
  if not voidp(tuser.getAt("sex")) then
    if tuser.getAt("sex") contains "F" or tuser.getAt("sex") contains "f" then
      tuser.setAt("sex", "F")
    else
      tuser.setAt("sex", "M")
    end if
  end if
  if not voidp(tuser.getAt("figure")) then
    if threadExists(#registration) then
      tuser.setAt("figure", getThread(#registration).getComponent().parseFigure(tuser.getAt("figure"), tuser.getAt("sex"), "user", "USEROBJECT"))
    end if
  end if
  the itemDelimiter = tDelim
  me.getHandler().handle_userobject(tuser)
  exit
end

on parse_walletbalance(me, tMsg)
  tCredits = integer(value(tMsg.getProp(#word, 1)))
  getObject(#session).set("user_walletbalance", tCredits)
  executeMessage(#updateCreditCount, tCredits)
  exit
end

on parse_MEMBERINFO(me, tMsg)
  if me = "REGNAME" then
    tMsg.setaProp(#subject, "NAMERESERVED")
    tMsg.setaProp(#content, tMsg.getProp(#line, 2))
    tMsg.setaProp(#message, "NAMERESERVED" & "\r" & tMsg.content)
  else
    if me = "MESSENGER" then
      tProps = []
      tStr = tMsg.getaProp(#message)
      tStr = tStr.getProp(#line, 2, tStr.count(#line))
      tProps.setAt(#name, tStr.getProp(#line, 1))
      tProps.setAt(#customText, "\"" & tStr.getProp(#line, 2) & "\"")
      tProps.setAt(#lastAccess, tStr.getProp(#line, 3))
      tProps.setAt(#location, tStr.getProp(#line, 4))
      tProps.setAt(#FigureData, tStr.getProp(#line, 5))
      tProps.setAt(#sex, tStr.getProp(#line, 6))
      if tProps.getAt(#sex) contains "f" or tProps.getAt(#sex) contains "F" then
        tProps.setAt(#sex, "F")
      else
        tProps.setAt(#sex, "M")
      end if
      if tProps.getAt(#location) = "ENTERPRISESERVER" then
        tProps.setAt(#location, "messenger")
      end if
      tProps.setAt(#FigureData, getThread(#registration).getComponent().parseFigure(tProps.getAt(#FigureData), tProps.getAt(#sex), "user"))
      tMsg.setaProp(#subject, "MEMBERINFO")
      tMsg.setaProp(#content, tProps)
    end if
  end if
  me.getHandler().handle_memberinfo(tMsg)
  exit
end

on parse_advertisement(me, tMsg)
  tStr = tMsg.getaProp(#message)
  tTxt = replaceChunks(tStr.getProp(#line, 5), "<br>", "\r")
  tTxt = replaceChunks(tTxt, "\\r", "\r")
  tProps = [#id:tStr.getProp(#line, 2), #url:tStr.getProp(#line, 3), #type:tStr.getProp(#line, 4), #text:tTxt, #link:tStr.getProp(#line, 6)]
  me.getHandler().handle_advertisement(tProps)
  exit
end

on parse_flatpassword_ok(me, tMsg)
  me.getComponent().flatAccessResult("flatpassword_ok")
  exit
end

on parse_error(me, tMsg)
  me.getHandler().handle_error(tMsg)
  exit
end

on parse_checksum(me, tMsg)
  getObject(#session).set("user_checksum", tMsg.getProp(#line, 2))
  exit
end

on parse_eps_notify(me, tMsg)
  ttype = ""
  tdata = ""
  tDelim = the itemDelimiter
  the itemDelimiter = "="
  f = 1
  repeat while f <= tMsg.count(#line)
    tProp = tMsg.getPropRef(#line, f).getProp(#item, 1)
    tDesc = tMsg.getPropRef(#line, f).getProp(#item, 2)
    if me = "t.cc" then
      ttype = integer(tDesc)
    else
      if me = "p" then
        tdata = tDesc
      end if
    end if
    f = 1 + f
  end repeat
  the itemDelimiter = tDelim
  executeMessage(#notify, ttype, tdata, tMsg.connection)
  exit
end

on parse_userbanned(me, tMsg)
  executeMessage(#alert, [#id:"BannWarning", #title:"Alert_YouAreBanned_T", #msg:"Alert_YouAreBanned"])
  removeConnection(getVariableValue("connection.info.id"))
  me.getInterface().getLogin().hideLogin()
  exit
end

on regMsgList(me, tBool)
  tMsgs = []
  tMsgs.setAt("HELLO", #parse_hello)
  tMsgs.setAt("SECRET_KEY", #parse_secret_key)
  tMsgs.setAt("OK", #parse_ok)
  tMsgs.setAt("U_RTS", #parse_user_rights)
  tMsgs.setAt("DISCONNECT", #parse_disconnect)
  tMsgs.setAt("SYSTEMBROADCAST", #parse_systembroadcast)
  tMsgs.setAt("UNITS", #parse_units)
  tMsgs.setAt("UNITUPDATES", #parse_unitupdates)
  tMsgs.setAt("UNITMEMBERS", #parse_unitmembers)
  tMsgs.setAt("FLATINFO", #parse_flatinfo)
  tMsgs.setAt("FLAT_RESULTS", #parse_flat_results)
  tMsgs.setAt("BUSY_FLAT_RESULTS", #parse_flat_results)
  tMsgs.setAt("FAVORITE_FLAT_RESULTS", #parse_flat_results)
  tMsgs.setAt("NOFLATSFORUSER", #parse_noflatsforuser)
  tMsgs.setAt("NOFLATS", #parse_noflats)
  tMsgs.setAt("NOSUCHFLAT", #parse_nosuchflat)
  tMsgs.setAt("NOPRVUSERS", #parse_noprvusers)
  tMsgs.setAt("PRVUNITS", #parse_prvunits)
  tMsgs.setAt("USEROBJECT", #parse_userobject)
  tMsgs.setAt("WALLETBALANCE", #parse_walletbalance)
  tMsgs.setAt("MEMBERINFO", #parse_MEMBERINFO)
  tMsgs.setAt("ADVERTISEMENT", #parse_advertisement)
  tMsgs.setAt("ERROR", #parse_error)
  tMsgs.setAt("MD5ID", #parse_checksum)
  tMsgs.setAt("EPS_NOTIFY", #parse_eps_notify)
  tMsgs.setAt("USERBANNED", #parse_userbanned)
  tCmds = []
  tCmds.setAt(#info, numToChar(128) & numToChar(128))
  tCmds.setAt(#room, numToChar(128) & numToChar(129))
  if tBool then
    registerListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
    registerListener(getVariable("connection.room.id", #info), me.getID(), ["FLATPASSWORD_OK":#parse_flatpassword_ok])
  else
    unregisterListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
    unregisterListener(getVariable("connection.room.id", #info), me.getID(), ["FLATPASSWORD_OK":#parse_flatpassword_ok])
  end if
  return(1)
  exit
end
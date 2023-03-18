on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on parse_hello me, tMsg
  getConnection(tMsg.connection).send(#info, "VERSIONCHECK" && getVariable("client.version.id"))
end

on parse_secret_key me, tMsg
  tKey = secretDecode(tMsg.content)
  tConnection = getConnection(tMsg.connection)
  tConnection.setDecoder(createObject(#temp, getClassVariable("connection.decoder.class")))
  tConnection.getDecoder().setKey(tKey)
  tConnection.setEncryption(1)
  tConnection.send(#info, "KEYENCRYPTED" && tKey)
  tConnection.send(#info, "CLIENTIP" && getNetAddressCookie(tConnection.getProperty(#xtra), 1))
  return me.getComponent().updateState("connectionOk")
end

on parse_ok me, tMsg
  tUserName = getObject(#session).get(#userName)
  tPassword = getObject(#session).get(#password)
  getConnection(tMsg.connection).send(#info, "INFORETRIEVE" && tUserName && tPassword)
  getConnection(tMsg.connection).send(#info, "GETCREDITS")
end

on parse_user_rights me, tMsg
  tList = []
  repeat with i = 1 to tMsg.content.line.count
    tLine = tMsg.content.line[i].word[1]
    if tLine <> EMPTY then
      tList.add(tMsg.content.line[i].word[1])
    end if
  end repeat
  getObject(#session).set("user_rights", tList)
end

on parse_disconnect me, tMsg
  error(me, "Connection was disconnected:" && tMsg.getaProp(#connection), #parse_disconnect)
  return me.getComponent().updateState("disconnection")
end

on parse_systembroadcast me, tMsg
  tMsg = tMsg[#content]
  tMsg = replaceChunks(tMsg, "\r", RETURN)
  tMsg = replaceChunks(tMsg, "<br>", RETURN)
  executeMessage(#alert, [#msg: tMsg])
  the keyboardFocusSprite = 0
end

on parse_units me, tMsg
  tList = [:]
  tDelim = the itemDelimiter
  the itemDelimiter = TAB
  repeat with i = 1 to tMsg.content.line.count
    tLine = tMsg.content.line[i]
    if tLine = EMPTY then
      exit repeat
    end if
    tUnit = [:]
    tUnit[#port] = tLine.item[1]
    tUnit[#ip] = tLine.item[2]
    tUnit[#name] = tLine.item[3]
    tUnit[#usercount] = integer(tLine.item[4])
    tUnit[#maxUsers] = integer(tLine.item[5])
    tUnit[#marker] = tLine.item[9]
    tTempUnitID = string(tUnit[#port]) & "/0"
    if not variableExists(tTempUnitID) then
      error(me, "Public room's ID not found:" && tTempUnitID && tUnit[#name], #parse_units)
      next repeat
    end if
    tUnitid = getVariable(tTempUnitID)
    tUnit[#subunitcount] = (tLine.item.count - 5) / 4
    tList[tUnitid] = tUnit
    if tUnit[#subunitcount] > 1 then
      tSubOrderNum = 1
      repeat with j = 6 to tLine.item.count
        tSub = [:]
        tTempUnitID = string(tUnit[#port]) & "/" & tSubOrderNum
        if not variableExists(tTempUnitID) then
          if tList[tUnitid][#subunitcount] > 1 then
            tList[tUnitid][#subunitcount] = tUnit[#subunitcount] - 1
          end if
        else
          tSubId = getVariable(tTempUnitID)
          tSub[#name] = tLine.item[j]
          tSub[#usercount] = integer(tLine.item[j + 1])
          tSub[#maxUsers] = integer(tLine.item[j + 2])
          tSub[#marker] = tLine.item[j + 3]
          tSub[#ip] = tUnit[#ip]
          tSub[#subunitcount] = 0
          tSub[#subordernum] = tSubOrderNum
          tSub[#door] = tSubOrderNum - 1
          tSub[#mymainunitid] = tUnitid
          tSub[#port] = tUnit[#port]
          tList[tSubId] = tSub
          tSubOrderNum = tSubOrderNum + 1
        end if
        j = j + 3
      end repeat
    end if
  end repeat
  the itemDelimiter = tDelim
  me.getComponent().saveUnitList(tList)
end

on parse_unitupdates me, tMsg
  tList = [:]
  tDelim = the itemDelimiter
  the itemDelimiter = TAB
  repeat with i = 1 to tMsg.content.line.count
    tLine = tMsg.content.line[i]
    if tLine = EMPTY then
      exit repeat
    end if
    tUnit = [#usercount: integer(tLine.item[2])]
    tUnitPort = tLine.item[1]
    tTempUnitID = string(tUnitPort) & "/0"
    if variableExists(tTempUnitID) then
      tUnitid = getVariable(tTempUnitID)
      tList[tUnitid] = tUnit
      if tLine.item.count > 2 then
        tSubOrderNum = 1
        repeat with j = 3 to tLine.item.count
          tSub = [:]
          tTempUnitID = string(tUnitPort) & "/" & tSubOrderNum
          if variableExists(tTempUnitID) then
            tSubId = getVariable(tTempUnitID)
            tSub[#usercount] = integer(tLine.item[j])
            tList[tSubId] = tSub
            tSubOrderNum = tSubOrderNum + 1
          end if
        end repeat
      end if
    end if
  end repeat
  the itemDelimiter = tDelim
  me.getComponent().UpdateUnitList(tList)
end

on parse_flatinfo me, tMsg
  tFlat = [:]
  tDelim = the itemDelimiter
  repeat with f = 1 to tMsg.content.line.count
    the itemDelimiter = "="
    tList = [:]
    tLine = tMsg.content.line[f]
    tProp = tLine.item[1]
    tDesc = tLine.item[2..tLine.item.count]
    case tProp of
      "i":
        tFlat[#id] = tDesc
      "n":
        tFlat[#name] = tDesc
      "o":
        tFlat[#owner] = tDesc
      "m":
        tFlat[#door] = tDesc
      "u":
        tFlat[#port] = tDesc
      "w":
        tFlat[#showownername] = value(tDesc) = 1
      "t":
        tFlat[#marker] = tDesc
      "d":
        tFlat[#description] = tDesc
      "a":
        tFlat[#ableothersmovefurniture] = value(tDesc) = 1
    end case
  end repeat
  tList[tFlat[#id]] = tFlat
  the itemDelimiter = tDelim
  me.getComponent().saveFlatInfo(tList)
end

on parse_flat_results me, tMsg
  tList = [:]
  tDelim = the itemDelimiter
  the itemDelimiter = TAB
  repeat with i = 2 to tMsg.message.line.count
    tLine = tMsg.message.line[i]
    if tLine = EMPTY then
      exit repeat
    end if
    tFlat = [:]
    tFlat[#id] = tLine.item[1]
    tFlat[#name] = tLine.item[2]
    tFlat[#owner] = tLine.item[3]
    tFlat[#door] = tLine.item[4]
    tFlat[#port] = tLine.item[5]
    tFlat[#usercount] = tLine.item[6]
    tFlat[#filter] = tLine.item[7]
    tFlat[#description] = tLine.item[8]
    tList[tFlat[#id]] = tFlat
  end repeat
  case tMsg.subject of
    "FLAT_RESULTS":
      tMode = #update
    "BUSY_FLAT_RESULTS":
      tMode = #busy
    "FAVORITE_FLAT_RESULTS":
      tMode = #favorite
  end case
  the itemDelimiter = tDelim
  me.getComponent().saveFlatList(tList, tMode)
end

on parse_noflatsforuser me, tMsg
  me.getComponent().noflatsforuser(tMsg.content)
end

on parse_noflats me, tMsg
  me.getComponent().noflats("NO_FLATS_FOUND")
end

on parse_nosuchflat me, tMsg
  put "TODO: nosuchflat"
end

on parse_noprvusers me, tMsg
end

on parse_prvunits me, tMsg
  tList = [:]
  tDelim = the itemDelimiter
  the itemDelimiter = TAB
  repeat with f = 1 to tMsg.content.line.count
    tLine = tMsg.content.line[f]
    if length(tLine) > 5 then
      tPort = tLine.item[1]
      tip = tLine.item[2]
      tFloor = tLine.item[3]
      tUsers = integer(tLine.item[4])
      tMaxUsers = integer(tLine.item[5])
      tList[tPort] = [#ip: tip, #floor: tFloor, #users: tUsers, #maxUsers: tMaxUsers]
    end if
  end repeat
  the itemDelimiter = tDelim
  me.getComponent().prepareFlatList(tList)
end

on parse_unitmembers me, tMsg
  tStr = EMPTY
  repeat with i = 1 to tMsg.content.line.count
    tLine = tMsg.content.line[i]
    if tLine = EMPTY then
      exit repeat
    end if
    tStr = tStr & tLine & ", "
  end repeat
  tStr = tStr.char[1..length(tStr) - 2]
  me.getInterface().updateUnitUsers(tStr)
end

on parse_userobject me, tMsg
  tuser = [:]
  tDelim = the itemDelimiter
  the itemDelimiter = "="
  repeat with i = 1 to tMsg.content.line.count
    tLine = tMsg.content.line[i]
    tuser[tLine.item[1]] = tLine.item[2..tLine.item.count]
  end repeat
  if not voidp(tuser["sex"]) then
    if (tuser["sex"] contains "F") or (tuser["sex"] contains "f") then
      tuser["sex"] = "F"
    else
      tuser["sex"] = "M"
    end if
  end if
  if not voidp(tuser["figure"]) then
    if threadExists(#registration) then
      tuser["figure"] = getThread(#registration).getComponent().parseFigure(tuser["figure"], tuser["sex"], "user", "USEROBJECT")
    end if
  end if
  the itemDelimiter = tDelim
  me.getHandler().handle_userobject(tuser)
end

on parse_walletbalance me, tMsg
  tCredits = integer(value(tMsg.content.word[1]))
  getObject(#session).set("user_walletbalance", tCredits)
  executeMessage(#updateCreditCount, tCredits)
end

on parse_MEMBERINFO me, tMsg
  case tMsg.message.line[1].word[2] of
    "REGNAME":
      tMsg.setaProp(#subject, "NAMERESERVED")
      tMsg.setaProp(#content, tMsg.message.line[2])
      tMsg.setaProp(#message, "NAMERESERVED" & RETURN & tMsg.content)
    "MESSENGER":
      tProps = [:]
      tStr = tMsg.getaProp(#message)
      tStr = tStr.line[2..tStr.line.count]
      tProps[#name] = tStr.line[1]
      tProps[#customText] = QUOTE & tStr.line[2] & QUOTE
      tProps[#lastAccess] = tStr.line[3]
      tProps[#location] = tStr.line[4]
      tProps[#FigureData] = tStr.line[5]
      tProps[#sex] = tStr.line[6]
      if (tProps[#sex] contains "f") or (tProps[#sex] contains "F") then
        tProps[#sex] = "F"
      else
        tProps[#sex] = "M"
      end if
      if tProps[#location] = "ENTERPRISESERVER" then
        tProps[#location] = "messenger"
      end if
      tProps[#FigureData] = getThread(#registration).getComponent().parseFigure(tProps[#FigureData], tProps[#sex], "user")
      tMsg.setaProp(#subject, "MEMBERINFO")
      tMsg.setaProp(#content, tProps)
  end case
  me.getHandler().handle_memberinfo(tMsg)
end

on parse_advertisement me, tMsg
  tStr = tMsg.getaProp(#message)
  tTxt = replaceChunks(tStr.line[5], "<br>", RETURN)
  tTxt = replaceChunks(tTxt, "\r", RETURN)
  tProps = [#id: tStr.line[2], #url: tStr.line[3], #type: tStr.line[4], #text: tTxt, #link: tStr.line[6]]
  me.getHandler().handle_advertisement(tProps)
end

on parse_flatpassword_ok me, tMsg
  me.getComponent().flatAccessResult("flatpassword_ok")
end

on parse_error me, tMsg
  me.getHandler().handle_error(tMsg)
end

on parse_checksum me, tMsg
  getObject(#session).set("user_checksum", tMsg.message.line[2])
end

on parse_eps_notify me, tMsg
  ttype = EMPTY
  tdata = EMPTY
  tDelim = the itemDelimiter
  the itemDelimiter = "="
  repeat with f = 1 to tMsg.content.line.count
    tProp = tMsg.content.line[f].item[1]
    tDesc = tMsg.content.line[f].item[2]
    case tProp of
      "t.cc":
        ttype = integer(tDesc)
      "p":
        tdata = tDesc
    end case
  end repeat
  the itemDelimiter = tDelim
  executeMessage(#notify, ttype, tdata, tMsg.connection)
end

on parse_userbanned me, tMsg
  executeMessage(#alert, [#id: "BannWarning", #title: "Alert_YouAreBanned_T", #msg: "Alert_YouAreBanned"])
  removeConnection(getVariableValue("connection.info.id"))
  me.getInterface().getLogin().hideLogin()
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs["HELLO"] = #parse_hello
  tMsgs["SECRET_KEY"] = #parse_secret_key
  tMsgs["OK"] = #parse_ok
  tMsgs["U_RTS"] = #parse_user_rights
  tMsgs["DISCONNECT"] = #parse_disconnect
  tMsgs["SYSTEMBROADCAST"] = #parse_systembroadcast
  tMsgs["UNITS"] = #parse_units
  tMsgs["UNITUPDATES"] = #parse_unitupdates
  tMsgs["UNITMEMBERS"] = #parse_unitmembers
  tMsgs["FLATINFO"] = #parse_flatinfo
  tMsgs["FLAT_RESULTS"] = #parse_flat_results
  tMsgs["BUSY_FLAT_RESULTS"] = #parse_flat_results
  tMsgs["FAVORITE_FLAT_RESULTS"] = #parse_flat_results
  tMsgs["NOFLATSFORUSER"] = #parse_noflatsforuser
  tMsgs["NOFLATS"] = #parse_noflats
  tMsgs["NOSUCHFLAT"] = #parse_nosuchflat
  tMsgs["NOPRVUSERS"] = #parse_noprvusers
  tMsgs["PRVUNITS"] = #parse_prvunits
  tMsgs["USEROBJECT"] = #parse_userobject
  tMsgs["WALLETBALANCE"] = #parse_walletbalance
  tMsgs["MEMBERINFO"] = #parse_MEMBERINFO
  tMsgs["ADVERTISEMENT"] = #parse_advertisement
  tMsgs["ERROR"] = #parse_error
  tMsgs["MD5ID"] = #parse_checksum
  tMsgs["EPS_NOTIFY"] = #parse_eps_notify
  tMsgs["USERBANNED"] = #parse_userbanned
  tCmds = [:]
  tCmds[#info] = numToChar(128) & numToChar(128)
  tCmds[#room] = numToChar(128) & numToChar(129)
  if tBool then
    registerListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
    registerListener(getVariable("connection.room.id", #info), me.getID(), ["FLATPASSWORD_OK": #parse_flatpassword_ok])
  else
    unregisterListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
    unregisterListener(getVariable("connection.room.id", #info), me.getID(), ["FLATPASSWORD_OK": #parse_flatpassword_ok])
  end if
  return 1
end

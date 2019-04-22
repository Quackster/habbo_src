property pCryDataBase

on construct me 
  pCryDataBase = [:]
  registerMessage(#sendCallForHelp, me.getID(), #send_cryForHelp)
  return(1)
end

on deconstruct me 
  pCryDataBase = [:]
  unregisterMessage(#sendCallForHelp, me.getID())
  return(1)
end

on getPendingCFHs me 
  tConnection = getConnection(getVariable("connection.info.id"))
  if not tConnection then
    error(me, "Connection not found.", #showDialog, #major)
  end if
  tConnection.send("GET_PENDING_CALLS_FOR_HELP")
end

on receive_cryforhelp me, tMsg 
  pCryDataBase.setAt(tMsg.getAt(#cry_id), tMsg)
  me.getInterface().ShowAlert()
  me.getInterface().updateCryWnd()
  return(1)
end

on receive_pickedCry me, tMsg 
  if voidp(pCryDataBase.getAt(tMsg.getAt(#cry_id))) then
    return(0)
  end if
  pCryDataBase.getAt(tMsg.getAt(#cry_id)).picker = tMsg.getAt(#picker)
  me.getInterface().updateCryWnd()
  return(1)
end

on deleteCry me, tID 
  pCryDataBase.deleteProp(tID)
  if pCryDataBase.count = 0 then
    me.getInterface().hideAlert()
  end if
  me.getInterface().updateCryWnd()
  return(1)
end

on send_changeCfhType me, tCryID, tCategoryNum 
  if not connectionExists(getVariable("connection.info.id")) then
    return(0)
  end if
  if tCategoryNum = 2 then
    tNewCategory = 1
    executeMessage(#alert, [#Msg:"hobba_sent_to_moderators"])
  else
    if tCategoryNum = 1 then
      tNewCategory = 2
      executeMessage(#alert, [#Msg:"hobba_sent_to_helpers"])
    else
      return(error(me, "Original category number illegal:" && tCategoryNum, #send_changeCfhType, #major))
    end if
  end if
  getConnection(getVariable("connection.info.id")).send("CHANGECALLCATEGORY", [#string:tCryID, #integer:tNewCategory])
  return(1)
end

on send_cryPick me, tCryID, tGoHelp 
  if not connectionExists(getVariable("connection.info.id")) then
    return(0)
  end if
  getConnection(getVariable("connection.info.id")).send("PICK_CRYFORHELP", [#string:tCryID])
  if tGoHelp then
    tdata = pCryDataBase.getAt(tCryID).duplicate()
    if voidp(tdata) then
      return(0)
    end if
    tOk = 1
    tOk = tdata.getAt(#picker).ilk = #string and tOk
    tOk = tdata.getAt(#url_id).ilk = #string and tOk
    tOk = tdata.getAt(#roomname).ilk = #string and tOk
    tOk = tdata.getAt(#cry_id).ilk = #string and tOk
    tOk = tdata.getAt(#type).ilk = #symbol and tOk
    tOk = tdata.getAt(#Msg).ilk = #string and tOk
    if not tOk then
      return(error(me, "Invalid or missing data in saved help cry!", #send_cryPick, #major))
    end if
    if tdata.getAt(#room_id) = 0 then
      tdata.setAt(#id, tdata.getAt(#roomname))
    else
      tdata.setAt(#id, string(tdata.getAt(#room_id)))
    end if
    tdata.setAt(#name, tdata.getAt(#roomname))
    if tdata.getAt(#type) = #private then
      tdata.setAt(#nodeType, 2)
      tdata.setAt(#flatId, tdata.getAt(#id))
      tdata.setAt(#id, "f_" & tdata.getAt(#id))
      tdata.setAt(#casts, getVariableValue("room.cast.private"))
    else
      tdata.setAt(#nodeType, 1)
      tdata.setAt(#unitStrId, tdata.getAt(#roomname))
      if ilk(tdata.getAt(#casts)) = #string then
        tCasts = tdata.getAt(#casts)
        tdata.setAt(#casts, [])
        tDelim = the itemDelimiter
        the itemDelimiter = ","
        c = 1
        repeat while c <= tCasts.count(#item)
          tdata.getAt(#casts).add(tCasts.getProp(#item, c))
          c = 1 + c
        end repeat
        the itemDelimiter = tDelim
      end if
    end if
    executeMessage(#pickAndGoCFH, tdata.getAt(#sender))
    getConnection(getVariable("connection.info.id")).send("FOLLOW_CRYFORHELP", [#string:tCryID])
  end if
  return(1)
end

on send_cryForHelp me, tMsg, ttype 
  tMsg = replaceChars(tMsg, "/", space())
  tMsg = replaceChunks(tMsg, "\r", "<br>")
  tMsg = convertSpecialChars(tMsg, 1)
  if ttype = #habbo_helpers then
    tSendType = 2
  else
    if ttype = #emergency then
      tSendType = 1
    else
      return(error(me, "Illegal type for CFH!", #send_cryForHelp, #major))
    end if
  end if
  tPropList = [#string:tMsg, #integer:tSendType]
  if connectionExists(getVariable("connection.room.id")) then
    return(getConnection(getVariable("connection.room.id")).send("CALL_FOR_HELP", tPropList))
  else
    return(error(me, "Failed to access room connection!", #send_cryForHelp, #major))
  end if
end

on send_CfhReply me, tCryID, tMsg 
  if not connectionExists(getVariable("connection.info.id")) then
    return(0)
  end if
  tCharsCounted = 0
  i = 1
  repeat while i <= tMsg.count(#char)
    tCharsCounted = tCharsCounted + 1
    if tCharsCounted > 45 and tMsg.getProp(#char, i) = space() then
      -- UNK_21
      ERROR.setContents()
      tCharsCounted = 0
    end if
    i = 1 + i
  end repeat
  tMsg = replaceChunks(tMsg, "\r", "<br>")
  tMsg = convertSpecialChars(tMsg, 1)
  getConnection(getVariable("connection.info.id")).send("MESSAGETOCALLER", [#string:tCryID, #string:tMsg])
  return(1)
end

on getCryDataBase me 
  return(pCryDataBase)
end

on clearCryDataBase me 
  pCryDataBase = [:]
  return(1)
end

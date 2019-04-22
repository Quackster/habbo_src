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

on receive_cryforhelp me, tMsg 
  pCryDataBase.setAt(tMsg.getAt(#url), tMsg)
  me.getInterface().ShowAlert()
  me.getInterface().updateCryWnd()
  return(1)
end

on receive_pickedCry me, tMsg 
  if voidp(pCryDataBase.getAt(tMsg.getAt(#url))) then
    return(0)
  end if
  pCryDataBase.getAt(tMsg.getAt(#url)).picker = tMsg.getAt(#picker)
  me.getInterface().updateCryWnd()
  return(1)
end

on send_cryPick me, tCryID, tGoHelp 
  if not connectionExists(getVariable("connection.info.id")) then
    return(0)
  end if
  getConnection(getVariable("connection.info.id")).send("PICK_CRYFORHELP", tCryID)
  if tGoHelp then
    tdata = pCryDataBase.getAt(tCryID)
    if voidp(tdata) then
      return(0)
    end if
    tOk = 1
    tOk = tdata.getAt(#picker).ilk = #string and tOk
    tOk = tdata.getAt(#url).ilk = #string and tOk
    tOk = tdata.getAt(#name).ilk = #string and tOk
    tOk = tdata.getAt(#id).ilk = #string and tOk
    tOk = tdata.getAt(#type).ilk = #symbol and tOk
    tOk = tdata.getAt(#msg).ilk = #string and tOk
    if not tOk then
      return(error(me, "Invalid or missing data in saved help cry!", #send_cryPick))
    end if
    if tdata.getAt(#type) = #public then
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
    else
      tdata.setAt(#casts, getVariableValue("room.cast.private"))
    end if
    executeMessage(#executeRoomEntry, tdata.getAt(#id), tdata)
  end if
  return(1)
end

on send_cryForHelp me, tMsg 
  tRoomData = getObject(#session).get("lastroom")
  if not tRoomData.ilk = #propList then
    return(0)
  end if
  tMsg = replaceChars(tMsg, "/", space())
  tMsg = replaceChunks(tMsg, "\r", "<br>")
  tMsg = getStringServices().convertSpecialChars(tMsg, 1)
  if tRoomData.getAt(#type) = #private then
    tPropList = [#string:tMsg, #integer:1, #string:tRoomData.getAt(#marker), #string:tRoomData.getAt(#name), #integer:integer(tRoomData.getAt(#id)), #string:tRoomData.getAt(#owner)]
  else
    tCasts = string(tRoomData.getAt(#casts))
    tCasts = replaceChars(tCasts, "\"", "")
    tCasts = replaceChars(tCasts, " ", "")
    tCasts = replaceChars(tCasts, "[", "")
    tCasts = replaceChars(tCasts, "]", "")
    tPropList = [#string:tMsg, #integer:0, #string:tCasts, #string:tRoomData.getAt(#name), #string:tRoomData.getAt(#id), #integer:tRoomData.getAt(#port), #integer:tRoomData.getAt(#door)]
  end if
  if connectionExists(getVariable("connection.room.id")) then
    return(getConnection(getVariable("connection.room.id")).send("CRYFORHELP", tPropList))
  else
    return(error(me, "Failed to access room connection!", #send_cryForHelp))
  end if
end

on getCryDataBase me 
  return(pCryDataBase)
end

on clearCryDataBase me 
  pCryDataBase = [:]
  return(1)
end

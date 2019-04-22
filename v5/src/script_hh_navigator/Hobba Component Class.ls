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
  getConnection(getVariable("connection.info.id")).send(#info, "PICK_CRYFORHELP" && tCryID)
  if tGoHelp then
    me.getInterface().hideCryWnd()
    tdata = pCryDataBase.getAt(tCryID)
    if voidp(tdata) then
      return(0)
    end if
    tOk = 1
    tOk = tdata.getAt(#picker).ilk = #string and tOk
    tOk = tdata.getAt(#url).ilk = #string and tOk
    tOk = tdata.getAt(#name).ilk = #string and tOk
    tOk = tdata.getAt(#id).ilk = #string and tOk
    tOk = tdata.getAt(#port).ilk = #string and tOk
    tOk = tdata.getAt(#type).ilk = #symbol and tOk
    tOk = tdata.getAt(#msg).ilk = #string and tOk
    if not tOk then
      return(error(me, "Invalid or missing data in saved help cry!", #send_cryPick))
    end if
    if tdata.getAt(#type) = #private then
      getThread(#navigator).getInterface().pFlatInfoAction = #enterflat
      getThread(#navigator).getComponent().getFlatInfo(tdata.getAt(#id))
    else
      getThread(#navigator).getComponent().updateState("enterUnit", tdata.getAt(#id))
    end if
  end if
  return(1)
end

on send_cryForHelp me, tMsg 
  tRoomData = getObject(#session).get("lastroom")
  if tRoomData.ilk = #propList then
    tid = tRoomData.getAt(#id)
    tName = tRoomData.getAt(#name)
    tPort = tRoomData.getAt(#port)
    ttype = tRoomData.getAt(#type)
    tMarker = tRoomData.getAt(#marker)
  else
    tid = "unknown"
    tName = "unknown"
    tPort = "unknown"
    ttype = "unknown"
    tMarker = "unknown"
  end if
  tMsg = replaceChars(tMsg, "/", space())
  tMsg = replaceChunks(tMsg, "\r", "<br>")
  tStr = "\r"
  tStr = tStr & "name:" & tName & "\r"
  tStr = tStr & "id:" & tid & "\r"
  tStr = tStr & "port:" & tPort & "\r"
  tStr = tStr & "type:" & ttype & "\r"
  tStr = tStr & "marker:" & tMarker & "\r"
  tStr = tStr & "text:" & tMsg
  if connectionExists(getVariable("connection.room.id")) then
    return(getConnection(getVariable("connection.room.id")).send(#room, "CRYFORHELP /" & tStr))
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

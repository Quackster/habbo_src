property pMessageBuffer, pPlaceHolderList, pDownloader, pTempTimeOutID, pTempDownloadList, pSimulatedDownload

on construct me
  registerMessage(#leaveRoom, me.getID(), #leaveRoom)
  registerMessage(#changeRoom, me.getID(), #leaveRoom)
  registerMessage(#downloadObject, me.getID(), #downloadObject)
  pPlaceHolderList = ["active": [:], "item": [:]]
  pMessageBuffer = ["active": [:], "item": [:]]
  pTempTimeOutID = "temp_temp_timeout"
  pTempDownloadList = [:]
  pSimulatedDownload = max(0, getIntVariable("buffer.simulateddownload", 0))
  return 1
end

on deconstruct me
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#downloadObject, me.getID())
  pPlaceHolderList = [:]
  pMessageBuffer = [:]
  if timeoutExists(pTempTimeOutID) then
    removeTimeout(pTempTimeOutID)
  end if
  return 1
end

on processObject me, tObj, ttype
  tClass = me.getClassName(tObj[#class], tObj[#type])
  tID = tObj[#id]
  if voidp(tClass) or voidp(tID) then
    return tObj
  end if
  if (ttype <> "active") and (ttype <> "item") then
    return tObj
  end if
  if pSimulatedDownload then
    tIsDownloaded = pTempDownloadList[tClass]
  else
    if getThread(#dynamicdownloader) = 0 then
      tIsDownloaded = 1
    else
      tIsDownloaded = getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass)
    end if
  end if
  if not tIsDownloaded then
    if voidp(pPlaceHolderList[ttype]) then
      pPlaceHolderList[ttype] = [:]
    end if
    tObjCopy = tObj.duplicate()
    if voidp(pPlaceHolderList[ttype].findPos(tID)) then
      pPlaceHolderList[ttype].addProp(tID, tObjCopy)
    else
      pPlaceHolderList[ttype][tID] = tObjCopy
    end if
    tAssetType = EMPTY
    if ttype = "active" then
      tObj[#dimensions] = [1, 1]
      tObj[#class] = "active_placeholder"
      tAssetType = #Active
    else
      if ttype = "item" then
        tObj[#class] = "item_placeholder"
        tObj[#type] = EMPTY
        tAssetType = #item
      end if
    end if
    me.downloadClass(tClass, tAssetType)
  end if
  return tObj
end

on downloadCompleted me, tClassID, tSuccess
  repeat with ttype = 1 to pPlaceHolderList.count
    tUpdated = 0
    tTypeName = pPlaceHolderList.getPropAt(ttype)
    tPlaceHolderList = pPlaceHolderList[ttype]
    repeat with tIndex = tPlaceHolderList.count down to 1
      tObj = tPlaceHolderList[tIndex]
      tClass = me.getClassName(tObj[#class], tObj[#type])
      if tClass = tClassID then
        tID = tObj[#id]
        tExists = 0
        if tTypeName = "active" then
          tExists = getThread(#room).getComponent().activeObjectExists(tID)
        else
          if tTypeName = "item" then
            tExists = getThread(#room).getComponent().itemObjectExists(tID)
          end if
        end if
        if tExists and tSuccess then
          if tTypeName = "active" then
            getThread(#room).getComponent().validateActiveObjects(tObj)
            if not voidp(tObj.findPos(#stripId)) then
              getThread(#room).getComponent().getActiveObject(tID).setaProp(#stripId, tObj[#stripId])
            end if
          else
            if tTypeName = "item" then
              getThread(#room).getComponent().validateItemObjects(tObj)
              if not voidp(tObj.findPos(#stripId)) then
                getThread(#room).getComponent().getItemObject(tID).setaProp(#stripId, tObj[#stripId])
              end if
            end if
          end if
          me.processMessageBuffer(tID, ttype)
          tUpdated = 1
          executeMessage(#objectFinalized, tID)
        else
          if not voidp(pMessageBuffer[ttype]) then
            pMessageBuffer[ttype].deleteProp(tID)
          end if
        end if
        tPlaceHolderList.deleteAt(tIndex)
      end if
    end repeat
    if tUpdated then
      if tTypeName = "active" then
        executeMessage(#activeObjectsUpdated)
        next repeat
      end if
      if tTypeName = "item" then
        executeMessage(#itemObjectsUpdated)
      end if
    end if
  end repeat
end

on downloadObject me, tdata
  if ilk(tdata) <> #propList then
    return 0
  end if
  tClass = me.getClassName(tdata[#class], tdata[#type])
  if getThread(#dynamicdownloader) = 0 then
    tIsDownloaded = 1
  else
    tIsDownloaded = getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass)
  end if
  if tIsDownloaded then
    tdata[#ready] = 1
    return 1
  end if
  tdata[#ready] = 0
  me.downloadClass(tClass, tdata[#type])
  return 1
end

on removeObject me, tID, ttype
  if not voidp(pPlaceHolderList[ttype]) then
    pPlaceHolderList[ttype].deleteProp(tID)
  end if
  if not voidp(pMessageBuffer[ttype]) then
    pMessageBuffer[ttype].deleteProp(tID)
  end if
end

on bufferMessage me, tMsg, tID, ttype
  if not listp(tMsg) then
    return 0
  end if
  tSubject = tMsg[#subject]
  if voidp(tID) or voidp(ttype) or voidp(tSubject) then
    return 0
  end if
  if voidp(pPlaceHolderList[ttype]) or voidp(pMessageBuffer[ttype]) then
    return 0
  end if
  if not voidp(pPlaceHolderList[ttype].findPos(tID)) then
    if voidp(pMessageBuffer[ttype].findPos(tID)) then
      pMessageBuffer[ttype][tID] = []
    end if
    tBuffer = pMessageBuffer[ttype][tID]
    repeat with tIndex = 1 to tBuffer.count
      tMsg_old = tBuffer[tIndex]
      tSubjectOld = tMsg_old[#subject]
      if tSubject = tSubjectOld then
        tBuffer.deleteAt(tIndex)
        exit repeat
      end if
    end repeat
    pMessageBuffer[ttype][tID].add(tMsg)
  end if
end

on processMessageBuffer me, tID, ttype
  if voidp(tID) or voidp(ttype) then
    return 0
  end if
  if voidp(pMessageBuffer[ttype]) then
    return 0
  end if
  tBuffer = pMessageBuffer[ttype].getaProp(tID)
  if not voidp(tBuffer) then
    repeat with tMsg in tBuffer
      tSubject = tMsg[#subject]
      tContent = tMsg.content
      tConn = tMsg.connection
      if not voidp(tConn) then
        tMsgStr = tConn.getProperty(#message)
        tMsgCopy = [:]
        repeat with tIndex = 1 to tMsgStr.count
          tProp = tMsgStr.getPropAt(tIndex)
          tValue = tMsgStr[tIndex]
          tMsgCopy[tProp] = tValue
          tMsgStr[tProp] = tMsg.getaProp(tProp)
        end repeat
        case tSubject of
          "88":
            getThread(#room).getHandler().handle_stuffdataupdate(tMsg)
          "95":
            getThread(#room).getHandler().handle_activeobject_update(tMsg)
          "85":
            getThread(#room).getHandler().handle_updateitem(tMsg)
        end case
        repeat with tIndex = 1 to tMsgCopy.count
          tProp = tMsgCopy.getPropAt(tIndex)
          tValue = tMsgCopy[tIndex]
          tMsgStr[tProp] = tValue
        end repeat
      end if
    end repeat
    pMessageBuffer[ttype].deleteProp(tID)
  end if
  return 1
end

on leaveRoom me
  pPlaceHolderList = ["active": [:], "item": [:]]
  pMessageBuffer = ["active": [:], "item": [:]]
end

on getClassName me, tClass, ttype
  tName = tClass
  if tName contains "*" then
    tDelim = the itemDelimiter
    the itemDelimiter = "*"
    tName = tName.item[1]
    the itemDelimiter = tDelim
  end if
  if getThread(#room).getInterface().getGeometry().getTileWidth() < 64 then
    tName = "s_" & tName
  end if
  if not voidp(ttype) and (ttype <> EMPTY) and (tClass = "poster") then
    tName = tName && string(ttype)
  end if
  return tName
end

on downloadClass me, tClass, ttype
  if pSimulatedDownload then
    if voidp(pTempDownloadList.findPos(tClass)) then
      pTempDownloadList.addProp(tClass, 0)
    end if
    if timeoutExists(pTempTimeOutID) then
      removeTimeout(pTempTimeOutID)
    end if
    createTimeout(pTempTimeOutID, pSimulatedDownload, #tempCallback, me.getID(), VOID, 1)
  else
    getThread(#dynamicdownloader).getComponent().downloadCastDynamically(tClass, ttype, me.getID(), #downloadCompleted)
  end if
end

on tempCallback me
  tIndex = pTempDownloadList.getPos(0)
  if tIndex > 0 then
    pTempDownloadList[tIndex] = 1
    me.downloadCompleted(pTempDownloadList.getPropAt(tIndex), 1)
    if timeoutExists(pTempTimeOutID) then
      removeTimeout(pTempTimeOutID)
    end if
    createTimeout(pTempTimeOutID, pSimulatedDownload, #tempCallback, me.getID(), VOID, 1)
  end if
end

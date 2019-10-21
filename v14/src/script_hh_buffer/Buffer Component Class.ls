property pTempTimeOutID, pSimulatedDownload, pTempDownloadList, pPlaceHolderList, pMessageBuffer

on construct me 
  registerMessage(#leaveRoom, me.getID(), #leaveRoom)
  registerMessage(#changeRoom, me.getID(), #leaveRoom)
  registerMessage(#downloadObject, me.getID(), #downloadObject)
  pPlaceHolderList = ["active":[:], "item":[:]]
  pMessageBuffer = ["active":[:], "item":[:]]
  pTempTimeOutID = "temp_temp_timeout"
  pTempDownloadList = [:]
  pSimulatedDownload = max(0, getIntVariable("buffer.simulateddownload", 0))
  return TRUE
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
  return TRUE
end

on processObject me, tObj, ttype 
  tClass = me.getClassName(tObj.getAt(#class), tObj.getAt(#type))
  tid = tObj.getAt(#id)
  if voidp(tClass) or voidp(tid) then
    return(tObj)
  end if
  if ttype <> "active" and ttype <> "item" then
    return(tObj)
  end if
  if pSimulatedDownload then
    tIsDownloaded = pTempDownloadList.getAt(tClass)
  else
    if (getThread(#dynamicdownloader) = 0) then
      tIsDownloaded = 1
    else
      tIsDownloaded = getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass)
    end if
  end if
  if not tIsDownloaded then
    if voidp(pPlaceHolderList.getAt(ttype)) then
      pPlaceHolderList.setAt(ttype, [:])
    end if
    tObjCopy = tObj.duplicate()
    if voidp(pPlaceHolderList.getAt(ttype).findPos(tid)) then
      pPlaceHolderList.getAt(ttype).addProp(tid, tObjCopy)
    else
      pPlaceHolderList.getAt(ttype).setAt(tid, tObjCopy)
    end if
    tAssetType = ""
    if (ttype = "active") then
      tObj.setAt(#dimensions, [1, 1])
      tObj.setAt(#class, "active_placeholder")
      tAssetType = #Active
    else
      if (ttype = "item") then
        tObj.setAt(#class, "item_placeholder")
        tObj.setAt(#type, "")
        tAssetType = #item
      end if
    end if
    me.downloadClass(tClass, tAssetType)
  end if
  return(tObj)
end

on downloadCompleted me, tClassID, tSuccess 
  ttype = 1
  repeat while ttype <= pPlaceHolderList.count
    tUpdated = 0
    tTypeName = pPlaceHolderList.getPropAt(ttype)
    tPlaceHolderList = pPlaceHolderList.getAt(ttype)
    tIndex = tPlaceHolderList.count
    repeat while tIndex >= 1
      tObj = tPlaceHolderList.getAt(tIndex)
      tClass = me.getClassName(tObj.getAt(#class), tObj.getAt(#type))
      if (tClass = tClassID) then
        tid = tObj.getAt(#id)
        tExists = 0
        if (tTypeName = "active") then
          tExists = getThread(#room).getComponent().activeObjectExists(tid)
        else
          if (tTypeName = "item") then
            tExists = getThread(#room).getComponent().itemObjectExists(tid)
          end if
        end if
        if tExists and tSuccess then
          if (tTypeName = "active") then
            getThread(#room).getComponent().validateActiveObjects(tObj)
            if not voidp(tObj.findPos(#stripId)) then
              getThread(#room).getComponent().getActiveObject(tid).setaProp(#stripId, tObj.getAt(#stripId))
            end if
          else
            if (tTypeName = "item") then
              getThread(#room).getComponent().validateItemObjects(tObj)
              if not voidp(tObj.findPos(#stripId)) then
                getThread(#room).getComponent().getItemObject(tid).setaProp(#stripId, tObj.getAt(#stripId))
              end if
            end if
          end if
          me.processMessageBuffer(tid, ttype)
          tUpdated = 1
          executeMessage(#objectFinalized, tid)
        else
          if not voidp(pMessageBuffer.getAt(ttype)) then
            pMessageBuffer.getAt(ttype).deleteProp(tid)
          end if
        end if
        tPlaceHolderList.deleteAt(tIndex)
      end if
      tIndex = (255 + tIndex)
    end repeat
    if tUpdated then
      if (tTypeName = "active") then
        executeMessage(#activeObjectsUpdated)
      else
        if (tTypeName = "item") then
          executeMessage(#itemObjectsUpdated)
        end if
      end if
    end if
    ttype = (1 + ttype)
  end repeat
end

on downloadObject me, tdata 
  if ilk(tdata) <> #propList then
    return FALSE
  end if
  tClass = me.getClassName(tdata.getAt(#class), tdata.getAt(#type))
  if (getThread(#dynamicdownloader) = 0) then
    tIsDownloaded = 1
  else
    tIsDownloaded = getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass)
  end if
  if tIsDownloaded then
    tdata.setAt(#ready, 1)
    return TRUE
  end if
  tdata.setAt(#ready, 0)
  me.downloadClass(tClass, tdata.getAt(#type))
  return TRUE
end

on removeObject me, tid, ttype 
  if not voidp(pPlaceHolderList.getAt(ttype)) then
    pPlaceHolderList.getAt(ttype).deleteProp(tid)
  end if
  if not voidp(pMessageBuffer.getAt(ttype)) then
    pMessageBuffer.getAt(ttype).deleteProp(tid)
  end if
end

on bufferMessage me, tMsg, tid, ttype 
  if not listp(tMsg) then
    return FALSE
  end if
  tSubject = tMsg.getAt(#subject)
  if voidp(tid) or voidp(ttype) or voidp(tSubject) then
    return FALSE
  end if
  if voidp(pPlaceHolderList.getAt(ttype)) or voidp(pMessageBuffer.getAt(ttype)) then
    return FALSE
  end if
  if not voidp(pPlaceHolderList.getAt(ttype).findPos(tid)) then
    if voidp(pMessageBuffer.getAt(ttype).findPos(tid)) then
      pMessageBuffer.getAt(ttype).setAt(tid, [])
    end if
    tBuffer = pMessageBuffer.getAt(ttype).getAt(tid)
    tIndex = 1
    repeat while tIndex <= tBuffer.count
      tMsg_old = tBuffer.getAt(tIndex)
      tSubjectOld = tMsg_old.getAt(#subject)
      if (tSubject = tSubjectOld) then
        tBuffer.deleteAt(tIndex)
      else
        tIndex = (1 + tIndex)
      end if
    end repeat
    pMessageBuffer.getAt(ttype).getAt(tid).add(tMsg)
  end if
end

on processMessageBuffer me, tid, ttype 
  if voidp(tid) or voidp(ttype) then
    return FALSE
  end if
  if voidp(pMessageBuffer.getAt(ttype)) then
    return FALSE
  end if
  tBuffer = pMessageBuffer.getAt(ttype).getaProp(tid)
  if not voidp(tBuffer) then
    repeat while tBuffer <= ttype
      tMsg = getAt(ttype, tid)
      tSubject = tMsg.getAt(#subject)
      tContent = tMsg.content
      tConn = tMsg.connection
      if not voidp(tConn) then
        tMsgStr = tConn.getProperty(#message)
        tMsgCopy = [:]
        tIndex = 1
        repeat while tIndex <= tMsgStr.count
          tProp = tMsgStr.getPropAt(tIndex)
          tValue = tMsgStr.getAt(tIndex)
          tMsgCopy.setAt(tProp, tValue)
          tMsgStr.setAt(tProp, tMsg.getaProp(tProp))
          tIndex = (1 + tIndex)
        end repeat
        if (tBuffer = "88") then
          getThread(#room).getHandler().handle_stuffdataupdate(tMsg)
        else
          if (tBuffer = "95") then
            getThread(#room).getHandler().handle_activeobject_update(tMsg)
          else
            if (tBuffer = "85") then
              getThread(#room).getHandler().handle_updateitem(tMsg)
            end if
          end if
        end if
        tIndex = 1
        repeat while tIndex <= tMsgCopy.count
          tProp = tMsgCopy.getPropAt(tIndex)
          tValue = tMsgCopy.getAt(tIndex)
          tMsgStr.setAt(tProp, tValue)
          tIndex = (1 + tIndex)
        end repeat
      end if
    end repeat
    pMessageBuffer.getAt(ttype).deleteProp(tid)
  end if
  return TRUE
end

on leaveRoom me 
  pPlaceHolderList = ["active":[:], "item":[:]]
  pMessageBuffer = ["active":[:], "item":[:]]
end

on getClassName me, tClass, ttype 
  tName = tClass
  if tName contains "*" then
    tDelim = the itemDelimiter
    the itemDelimiter = "*"
    tName = tName.getProp(#item, 1)
    the itemDelimiter = tDelim
  end if
  if getThread(#room).getInterface().getGeometry().getTileWidth() < 64 then
    tName = "s_" & tName
  end if
  if not voidp(ttype) and ttype <> "" and (tClass = "poster") then
    tName = tName && string(ttype)
  end if
  return(tName)
end

on downloadClass me, tClass, ttype 
  if pSimulatedDownload then
    if voidp(pTempDownloadList.findPos(tClass)) then
      pTempDownloadList.addProp(tClass, 0)
    end if
    if timeoutExists(pTempTimeOutID) then
      removeTimeout(pTempTimeOutID)
    end if
    createTimeout(pTempTimeOutID, pSimulatedDownload, #tempCallback, me.getID(), void(), 1)
  else
    getThread(#dynamicdownloader).getComponent().downloadCastDynamically(tClass, ttype, me.getID(), #downloadCompleted)
  end if
end

on tempCallback me 
  tIndex = pTempDownloadList.getPos(0)
  if tIndex > 0 then
    pTempDownloadList.setAt(tIndex, 1)
    me.downloadCompleted(pTempDownloadList.getPropAt(tIndex), 1)
    if timeoutExists(pTempTimeOutID) then
      removeTimeout(pTempTimeOutID)
    end if
    createTimeout(pTempTimeOutID, pSimulatedDownload, #tempCallback, me.getID(), void(), 1)
  end if
end

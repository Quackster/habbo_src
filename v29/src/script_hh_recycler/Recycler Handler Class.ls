property pPersistentFurniData

on construct me 
  pPersistentFurniData = void()
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on handle_recycler_configuration me, tMsg 
  tConn = tMsg.connection
  if not tConn then
    return FALSE
  end if
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  tServiceEnabled = tConn.GetIntFrom()
  tQuarantineMinutes = tConn.GetIntFrom()
  tRecyclingMinutes = tConn.GetIntFrom()
  tMinutesToTimeout = tConn.GetIntFrom()
  tNumOfRewardItems = tConn.GetIntFrom()
  tRewardItems = []
  tNo = 1
  repeat while tNo <= tNumOfRewardItems
    tItem = [:]
    tItem.setAt(#furniValue, tConn.GetIntFrom())
    tItem.setAt(#type, tConn.GetIntFrom())
    if (tItem.getAt(#type) = 0) then
      tClassID = tConn.GetIntFrom()
      tFurniProps = pPersistentFurniData.getProps("s", tClassID)
      if voidp(tFurniProps) then
        error(me, "Persistent properties missing for furni classid " & tClassID & " type s", #handle_recycler_status, #major)
        tItem.setAt(#class, "")
      else
        tItem.setAt(#class, tFurniProps.getAt(#class))
        tItem.setAt(#defaultDirection, tFurniProps.getAt(#defaultDir))
        tItem.setAt(#xDimension, tFurniProps.getAt(#xdim))
        tItem.setAt(#yDimension, tFurniProps.getAt(#ydim))
        tItem.setAt(#partColors, tFurniProps.getAt(#partColors))
        tItem.setAt(#name, tFurniProps.getAt(#localizedName))
      end if
    else
      if (tItem.getAt(#type) = 1) then
        tClassID = tConn.GetIntFrom()
        tFurniProps = pPersistentFurniData.getProps("i", tClassID)
        if voidp(tFurniProps) then
          error(me, "Persistent properties missing for furni classid " & tClassID & " type i", #handle_recycler_status, #major)
          tItem.setAt(#class, "")
        else
          tItem.setAt(#class, tFurniProps.getAt(#class))
          tItem.setAt(#name, tFurniProps.getAt(#localizedName))
        end if
      else
        if (tItem.getAt(#type) = 2) then
          tItem.setAt(#name, tConn.GetStrFrom())
        end if
      end if
    end if
    tRewardItems.add(tItem)
    tNo = (1 + tNo)
  end repeat
  tComponent = me.getComponent()
  tComponent.enableService(tServiceEnabled)
  tComponent.setRewardItems(tRewardItems)
  tComponent.setRecyclingTimes(tQuarantineMinutes, tRecyclingMinutes)
  tComponent.setRecyclingTimeout(tMinutesToTimeout)
end

on handle_recycler_status me, tMsg 
  tConn = tMsg.connection
  if not tConn then
    return FALSE
  end if
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  tStatus = tConn.GetIntFrom()
  if (tStatus = 0) then
    tStatus = "open"
  else
    if (tStatus = 1) then
      tStatus = "progress"
      tRewardType = tConn.GetIntFrom()
      tClassID = tConn.GetIntFrom()
      tMinutesLeft = tConn.GetIntFrom()
      if (tRewardType = 0) then
        tRewardType = #roomItem
        ttype = "s"
      else
        tRewardType = #wallItem
        ttype = "i"
      end if
      tFurniProps = pPersistentFurniData.getProps(ttype, tClassID)
      if voidp(tFurniProps) then
        error(me, "Persistent properties missing for furni classid " & tClassID & " type " & ttype, #handle_recycler_status, #major)
        tFurniProps = [#class:"", #localizedName:"", #localizedDesc:""]
      end if
      tFurniClass = tFurniProps.getAt(#class)
      tFurniName = tFurniProps.getAt(#localizedName)
      me.getComponent().setRewardProps(tRewardType, tFurniClass, tFurniName)
      me.getComponent().setTimeLeftProps(tMinutesLeft)
      tTimeoutTime = (((tMinutesLeft + 1) * 60) * 1000)
      createTimeout("recycler_status_request", tTimeoutTime, #statusRequestTimeout, me.getID(), void(), 1)
    else
      if (tStatus = 2) then
        tStatus = "ready"
        tRewardType = tConn.GetIntFrom()
        tClassID = tConn.GetIntFrom()
        tMinutesLeft = tConn.GetIntFrom()
        if (tRewardType = 0) then
          tRewardType = #roomItem
          ttype = "s"
        else
          tRewardType = #wallItem
          ttype = "i"
        end if
        tFurniProps = pPersistentFurniData.getProps(ttype, tClassID)
        if voidp(tFurniProps) then
          error(me, "Persistent properties missing for furni classid " & tClassID & " type " & ttype, #handle_recycler_status, #major)
          tFurniProps = [#class:"", #localizedName:"", #localizedDesc:""]
        end if
        tFurniClass = tFurniProps.getAt(#class)
        tFurniName = tFurniProps.getAt(#localizedName)
        me.getComponent().setRewardProps(tRewardType, tFurniClass, tFurniName)
      else
        if (tStatus = 3) then
          tStatus = "timeout"
        end if
      end if
    end if
  end if
  me.getComponent().openRecyclerWithState(tStatus)
end

on handle_approve_recycling_result me, tMsg 
  tConn = tMsg.connection
  if not tConn then
    return FALSE
  end if
  tResult = tConn.GetIntFrom()
  if not tResult then
    nothing()
  else
    me.getComponent().requestRecyclerState()
  end if
end

on handle_start_recycling_result me, tMsg 
  tConn = tMsg.connection
  if not tConn then
    return FALSE
  end if
  tResult = tConn.GetIntFrom()
  if not tResult then
    nothing()
  else
    me.getComponent().requestRecyclerState()
  end if
end

on handle_confirm_recycling_result me, tMsg 
  tConn = tMsg.connection
  if not tConn then
    return FALSE
  end if
  tResult = tConn.GetIntFrom()
  if not tResult then
    nothing()
  else
    me.getComponent().setStateTo("open")
  end if
end

on statusRequestTimeout me 
  me.getComponent().requestRecyclerState()
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(303, #handle_recycler_configuration)
  tMsgs.setaProp(304, #handle_recycler_status)
  tMsgs.setaProp(305, #handle_approve_recycling_result)
  tMsgs.setaProp(306, #handle_start_recycling_result)
  tMsgs.setaProp(307, #handle_confirm_recycling_result)
  tCmds = [:]
  tCmds.setaProp("GET_FURNI_RECYCLER_CONFIGURATION", 222)
  tCmds.setaProp("GET_FURNI_RECYCLER_STATUS", 223)
  tCmds.setaProp("APPROVE_RECYCLED_FURNI", 224)
  tCmds.setaProp("START_FURNI_RECYCLING", 225)
  tCmds.setaProp("CONFIRM_FURNI_RECYCLING", 226)
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  return TRUE
end

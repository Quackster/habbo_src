property pPersistentFurniData

on construct me
  pPersistentFurniData = VOID
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_recycler_configuration me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
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
  repeat with tNo = 1 to tNumOfRewardItems
    tItem = [:]
    tItem[#furniValue] = tConn.GetIntFrom()
    tItem[#type] = tConn.GetIntFrom()
    case tItem[#type] of
      0:
        tClassID = tConn.GetIntFrom()
        tFurniProps = pPersistentFurniData.getProps("s", tClassID)
        if voidp(tFurniProps) then
          error(me, "Persistent properties missing for furni classid " & tClassID & " type s", #handle_recycler_status, #major)
          tItem[#class] = EMPTY
        else
          tItem[#class] = tFurniProps[#class]
          tItem[#defaultDirection] = tFurniProps[#defaultDir]
          tItem[#xDimension] = tFurniProps[#xdim]
          tItem[#yDimension] = tFurniProps[#ydim]
          tItem[#partColors] = tFurniProps[#partColors]
          tItem[#name] = tFurniProps[#localizedName]
        end if
      1:
        tClassID = tConn.GetIntFrom()
        tFurniProps = pPersistentFurniData.getProps("i", tClassID)
        if voidp(tFurniProps) then
          error(me, "Persistent properties missing for furni classid " & tClassID & " type i", #handle_recycler_status, #major)
          tItem[#class] = EMPTY
        else
          tItem[#class] = tFurniProps[#class]
          tItem[#name] = tFurniProps[#localizedName]
        end if
      2:
        tItem[#name] = tConn.GetStrFrom()
    end case
    tRewardItems.add(tItem)
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
    return 0
  end if
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  tStatus = tConn.GetIntFrom()
  case tStatus of
    0:
      tStatus = "open"
    1:
      tStatus = "progress"
      tRewardType = tConn.GetIntFrom()
      tClassID = tConn.GetIntFrom()
      tMinutesLeft = tConn.GetIntFrom()
      if tRewardType = 0 then
        tRewardType = #roomItem
        ttype = "s"
      else
        tRewardType = #wallItem
        ttype = "i"
      end if
      tFurniProps = pPersistentFurniData.getProps(ttype, tClassID)
      if voidp(tFurniProps) then
        error(me, "Persistent properties missing for furni classid " & tClassID & " type " & ttype, #handle_recycler_status, #major)
        tFurniProps = [#class: EMPTY, #localizedName: EMPTY, #localizedDesc: EMPTY]
      end if
      tFurniClass = tFurniProps[#class]
      tFurniName = tFurniProps[#localizedName]
      me.getComponent().setRewardProps(tRewardType, tFurniClass, tFurniName)
      me.getComponent().setTimeLeftProps(tMinutesLeft)
      tTimeoutTime = (tMinutesLeft + 1) * 60 * 1000
      createTimeout("recycler_status_request", tTimeoutTime, #statusRequestTimeout, me.getID(), VOID, 1)
    2:
      tStatus = "ready"
      tRewardType = tConn.GetIntFrom()
      tClassID = tConn.GetIntFrom()
      tMinutesLeft = tConn.GetIntFrom()
      if tRewardType = 0 then
        tRewardType = #roomItem
        ttype = "s"
      else
        tRewardType = #wallItem
        ttype = "i"
      end if
      tFurniProps = pPersistentFurniData.getProps(ttype, tClassID)
      if voidp(tFurniProps) then
        error(me, "Persistent properties missing for furni classid " & tClassID & " type " & ttype, #handle_recycler_status, #major)
        tFurniProps = [#class: EMPTY, #localizedName: EMPTY, #localizedDesc: EMPTY]
      end if
      tFurniClass = tFurniProps[#class]
      tFurniName = tFurniProps[#localizedName]
      me.getComponent().setRewardProps(tRewardType, tFurniClass, tFurniName)
    3:
      tStatus = "timeout"
  end case
  me.getComponent().openRecyclerWithState(tStatus)
end

on handle_approve_recycling_result me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
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
    return 0
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
    return 0
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
  return 1
end

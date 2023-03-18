property pServiceEnabled, pRecyclerState, pGiveFurniPool, pGetFurniPool, pRewardProps, pREwardItems, pTimeProps, pQuarantineMinutes, pRecyclingMinutes, pIsVisible, pRecyclingTimeoutMinutes, pOpeningRequestPending

on construct me
  pIsVisible = 0
  pRecyclerState = VOID
  pGiveFurniPool = []
  pGetFurniPool = [:]
  pRewardProps = [:]
  pTimeProps = [:]
  pREwardItems = [:]
  pServiceEnabled = 0
  pOpeningRequestPending = 0
  pRecyclingTimeoutMinutes = 0
  registerMessage(#userloggedin, me.getID(), #Initialize)
  return 1
end

on deconstruct me
  unregisterMessage(#userloggedin, me.getID())
  if objectExists(#recyclingFinished) then
    removeTimeout(#recyclingFinished)
  end if
  return 1
end

on Initialize me
  tConn = getConnection(getVariableValue("connection.info.id"))
  tConn.send("GET_FURNI_RECYCLER_CONFIGURATION")
  me.requestRecyclerState()
end

on enableService me, tEnabled
  if tEnabled then
    pServiceEnabled = 1
  else
    pServiceEnabled = 0
  end if
end

on requestRecyclerState me
  tConn = getConnection(getVariableValue("connection.info.id"))
  tConn.send("GET_FURNI_RECYCLER_STATUS")
end

on openRecycler me
  pOpeningRequestPending = 1
  me.requestRecyclerState()
end

on openRecyclerWithState me, tstate
  if pOpeningRequestPending = 1 then
    pIsVisible = 1
    pOpeningRequestPending = 0
  end if
  me.setStateTo(tstate)
end

on closeRecycler me
  pIsVisible = 0
  pOpeningRequestPending = 0
  if threadExists(#room) then
    tRoomInterface = getThread(#room).getInterface()
    tContainer = tRoomInterface.getContainer()
    pGiveFurniPool = []
    me.getInterface().setHostWindowObject(VOID)
    me.clearObjectMover()
    tContainer.Refresh()
  end if
end

on startRecycling me
  tSafeTrader = getThread(#room).getInterface().getSafeTrader()
  if not voidp(tSafeTrader) then
    if tSafeTrader.getState() = #open then
      executeMessage(#alert, [#Msg: getText("recycler_trader_open_alert"), #modal: 1])
      return 0
    end if
  end if
  tRoomItemIds = []
  tWallItemIds = []
  tTargetItem = me.getRewardItemForCurrentAmount()
  if voidp(tTargetItem) or (ilk(tTargetItem) <> #propList) then
    return 0
  end if
  tGiveAmount = tTargetItem[#furniValue]
  if tGiveAmount > pGiveFurniPool.count then
    return 0
  end if
  repeat with tIndexNo = 1 to tGiveAmount
    tItem = pGiveFurniPool[tIndexNo]
    if tItem[#props][#type] = "active" then
      tRoomItemIds.add(integer(tItem[#props][#id]))
      next repeat
    end if
    tWallItemIds.add(integer(tItem[#props][#id]))
  end repeat
  tParams = [:]
  tParams.addProp(#integer, tRoomItemIds.count)
  repeat with tItem in tRoomItemIds
    tParams.addProp(#integer, tItem)
  end repeat
  tParams.addProp(#integer, tWallItemIds.count)
  repeat with tItem in tWallItemIds
    tParams.addProp(#integer, tItem)
  end repeat
  getConnection(getVariable("connection.info.id")).send("START_FURNI_RECYCLING", tParams)
end

on acceptRecycling me
  tConn = getConnection(getVariable("connection.info.id"))
  if pRecyclerState = "progress" then
    tConn.send("APPROVE_RECYCLED_FURNI", [#integer: 1])
  else
    tConn.send("CONFIRM_FURNI_RECYCLING", [#integer: 1])
  end if
end

on cancelRecycling me
  tConn = getConnection(getVariable("connection.info.id"))
  if pRecyclerState = "progress" then
    tConn.send("CONFIRM_FURNI_RECYCLING", [#integer: 0])
  else
    if pRecyclerState = "ready" then
      tConn.send("CONFIRM_FURNI_RECYCLING", [#integer: 0])
    else
      if pRecyclerState = "timeout" then
        tConn.send("CONFIRM_FURNI_RECYCLING", [#integer: 0])
      end if
    end if
  end if
  me.clearObjectMover()
end

on clearObjectMover me
  tRoomInterface = getThread(#room).getInterface()
  tObjMover = tRoomInterface.getObjectMover()
  if not voidp(tObjMover) then
    tObjMover.clear()
  end if
  tRoomInterface.setProperty(#clickAction, "moveHuman")
end

on isRecyclerOpenAndVisible me
  return (pRecyclerState = "open") and pIsVisible
end

on getGiveFurniPool me
  return pGiveFurniPool
end

on getState me
  return pRecyclerState
end

on removeFurniFromGivePool me, tGiveFurniIndex
  if pGiveFurniPool.count >= tGiveFurniIndex then
    pGiveFurniPool.deleteAt(tGiveFurniIndex)
  end if
end

on setRewardProps me, tObjectType, tFurniClass
  pRewardProps[#objectType] = tObjectType
  pRewardProps[#class] = tFurniClass
  if tObjectType = #roomItem then
    tNameLocalizationKey = "furni_" & tFurniClass & "_name"
  else
    tNameLocalizationKey = "wallitem_" & tFurniClass & "_name"
  end if
  pRewardProps[#name] = getText(tNameLocalizationKey)
end

on getRewardProps me, tProp
  case tProp of
    #name:
      return pRewardProps[#name]
    #type:
      return pRewardProps[#objectType]
    #class:
      return pRewardProps[#class]
    otherwise:
      return VOID
  end case
end

on setRewardItems me, tItemList
  pREwardItems = tItemList
end

on getRewardItemForCurrentAmount me
  tAmount = pGiveFurniPool.count
  tRewardItem = VOID
  tFurniValue = 0
  repeat with tNo = 1 to pREwardItems.count
    tItem = pREwardItems[tNo]
    if tItem[#furniValue] = tAmount then
      return tItem
      next repeat
    end if
    if (tItem[#furniValue] > tFurniValue) and (tItem[#furniValue] < tAmount) then
      tFurniValue = tItem[#furniValue]
      tRewardItem = tItem
    end if
  end repeat
  return tRewardItem
end

on getNextRewardItemForCurrentAmount me
  tAmount = pGiveFurniPool.count
  tNextItem = VOID
  tDifferenceToNext = 1000000
  repeat with tNo = 1 to pREwardItems.count
    tItem = pREwardItems[tNo]
    if tItem[#furniValue] > tAmount then
      if (tItem[#furniValue] - tAmount) < tDifferenceToNext then
        tNextItem = tItem
        tDifferenceToNext = tItem[#furniValue] - tAmount
      end if
    end if
  end repeat
  return tNextItem
end

on setRecyclingTimes me, tQuarantineMinutes, tRecyclingMinutes
  pQuarantineMinutes = tQuarantineMinutes
  pRecyclingMinutes = tRecyclingMinutes
end

on setRecyclingTimeout me, tMinutesToTimeout
  pRecyclingTimeoutMinutes = tMinutesToTimeout
end

on getQuarantineMinutes me
  return pQuarantineMinutes
end

on getRecyclingMinutes me
  return pRecyclingMinutes
end

on setTimeLeftProps me, tMinutesLeft
  pTimeProps[#minutesLeft] = tMinutesLeft
  pTimeProps[#timeStamp] = the milliSeconds
end

on getMinutesLeftToRecycle me
  if ilk(pTimeProps) <> #propList then
    return VOID
  end if
  tMillisSinceStarted = the milliSeconds - pTimeProps[#timeStamp]
  tMinutesSinceStarted = tMillisSinceStarted / 1000 / 60
  tMinutesLeft = pTimeProps[#minutesLeft] - tMinutesSinceStarted
  if tMinutesLeft < 0 then
    tMinutesLeft = 0
  end if
  return tMinutesLeft
end

on addFurnitureToGivePool me, tClass, tid, tProps
  if me.isFurniInRecycler(tid) then
    return 0
  end if
  pGiveFurniPool.add([#class: tClass, #id: tid, #props: tProps])
end

on isFurniInRecycler me, tStripID
  if (pRecyclerState <> "open") or (pGiveFurniPool.count = 0) then
    return 0
  end if
  repeat with tNo = 1 to pGiveFurniPool.count
    if pGiveFurniPool[tNo][#props][#stripId] = tStripID then
      return 1
    end if
  end repeat
  return 0
end

on setStateTo me, tstate
  pRecyclerState = tstate
  pStateRequestPending = 0
  if not threadExists(#room) then
    return 0
  end if
  tRoomInterface = getThread(#room).getInterface()
  tObjMover = tRoomInterface.getObjectMover()
  case tstate of
    "open":
      if not pServiceEnabled then
        return me.setStateTo("disabled")
      end if
      pGiveFurniPool = []
      pGetFurniPool = [:]
      tRoomInterface.cancelObjectMover()
      tRoomInterface.setProperty(#clickAction, "tradeItem")
      if tObjMover <> 0 then
        tObjMover.moveTrade()
      end if
    "progress":
      me.clearObjectMover()
    "ready":
      me.clearObjectMover()
    "disabled":
      me.clearObjectMover()
    "timeout":
      me.clearObjectMover()
    otherwise:
      me.clearObjectMover()
  end case
  executeMessage(#recyclerStateChange)
  me.getInterface().setViewToState(tstate)
end

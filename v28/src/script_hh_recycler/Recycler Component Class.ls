on construct(me)
  pIsVisible = 0
  pRecyclerState = void()
  pGiveFurniPool = []
  pGetFurniPool = []
  pRewardProps = []
  pTimeProps = []
  pREwardItems = []
  pServiceEnabled = 0
  pOpeningRequestPending = 0
  pRecyclingTimeoutMinutes = 0
  registerMessage(#userloggedin, me.getID(), #Initialize)
  return(1)
  exit
end

on deconstruct(me)
  unregisterMessage(#userloggedin, me.getID())
  if objectExists(#recyclingFinished) then
    removeTimeout(#recyclingFinished)
  end if
  return(1)
  exit
end

on Initialize(me)
  tConn = getConnection(getVariableValue("connection.info.id"))
  tConn.send("GET_FURNI_RECYCLER_CONFIGURATION")
  me.requestRecyclerState()
  exit
end

on enableService(me, tEnabled)
  if tEnabled then
    pServiceEnabled = 1
  else
    pServiceEnabled = 0
  end if
  exit
end

on requestRecyclerState(me)
  tConn = getConnection(getVariableValue("connection.info.id"))
  tConn.send("GET_FURNI_RECYCLER_STATUS")
  exit
end

on openRecycler(me)
  pOpeningRequestPending = 1
  me.requestRecyclerState()
  exit
end

on openRecyclerWithState(me, tstate)
  if pOpeningRequestPending = 1 then
    pIsVisible = 1
    pOpeningRequestPending = 0
  end if
  me.setStateTo(tstate)
  exit
end

on closeRecycler(me)
  pIsVisible = 0
  pOpeningRequestPending = 0
  if threadExists(#room) then
    tRoomInterface = getThread(#room).getInterface()
    tContainer = tRoomInterface.getContainer()
    pGiveFurniPool = []
    me.getInterface().setHostWindowObject(void())
    me.clearObjectMover()
    tContainer.Refresh()
  end if
  exit
end

on startRecycling(me)
  tSafeTrader = getThread(#room).getInterface().getSafeTrader()
  if not voidp(tSafeTrader) then
    if tSafeTrader.getState() = #open then
      executeMessage(#alert, [#Msg:getText("recycler_trader_open_alert"), #modal:1])
      return(0)
    end if
  end if
  tRoomItemIds = []
  tWallItemIds = []
  tTargetItem = me.getRewardItemForCurrentAmount()
  if voidp(tTargetItem) or ilk(tTargetItem) <> #propList then
    return(0)
  end if
  tGiveAmount = tTargetItem.getAt(#furniValue)
  if tGiveAmount > pGiveFurniPool.count then
    return(0)
  end if
  tIndexNo = 1
  repeat while tIndexNo <= tGiveAmount
    tItem = pGiveFurniPool.getAt(tIndexNo)
    if tItem.getAt(#props).getAt(#type) = "active" then
      tRoomItemIds.add(integer(tItem.getAt(#props).getAt(#id)))
    else
      tWallItemIds.add(integer(tItem.getAt(#props).getAt(#id)))
    end if
    tIndexNo = 1 + tIndexNo
  end repeat
  tParams = []
  tParams.addProp(#integer, tRoomItemIds.count)
  repeat while me <= undefined
    tItem = getAt(undefined, undefined)
    tParams.addProp(#integer, tItem)
  end repeat
  tParams.addProp(#integer, tWallItemIds.count)
  repeat while me <= undefined
    tItem = getAt(undefined, undefined)
    tParams.addProp(#integer, tItem)
  end repeat
  getConnection(getVariable("connection.info.id")).send("START_FURNI_RECYCLING", tParams)
  exit
end

on acceptRecycling(me)
  tConn = getConnection(getVariable("connection.info.id"))
  if pRecyclerState = "progress" then
    tConn.send("APPROVE_RECYCLED_FURNI", [#integer:1])
  else
    tConn.send("CONFIRM_FURNI_RECYCLING", [#integer:1])
  end if
  exit
end

on cancelRecycling(me)
  tConn = getConnection(getVariable("connection.info.id"))
  if pRecyclerState = "progress" then
    tConn.send("CONFIRM_FURNI_RECYCLING", [#integer:0])
  else
    if pRecyclerState = "ready" then
      tConn.send("CONFIRM_FURNI_RECYCLING", [#integer:0])
    else
      if pRecyclerState = "timeout" then
        tConn.send("CONFIRM_FURNI_RECYCLING", [#integer:0])
      end if
    end if
  end if
  me.clearObjectMover()
  exit
end

on clearObjectMover(me)
  tRoomInterface = getThread(#room).getInterface()
  tObjMover = tRoomInterface.getObjectMover()
  if not voidp(tObjMover) then
    tObjMover.clear()
  end if
  tRoomInterface.setProperty(#clickAction, "moveHuman")
  exit
end

on isRecyclerOpenAndVisible(me)
  return(pRecyclerState = "open" and pIsVisible)
  exit
end

on getGiveFurniPool(me)
  return(pGiveFurniPool)
  exit
end

on getState(me)
  return(pRecyclerState)
  exit
end

on removeFurniFromGivePool(me, tGiveFurniIndex)
  if pGiveFurniPool.count >= tGiveFurniIndex then
    pGiveFurniPool.deleteAt(tGiveFurniIndex)
  end if
  exit
end

on setRewardProps(me, tObjectType, tFurniClass, tFurniName)
  pRewardProps.setAt(#objectType, tObjectType)
  pRewardProps.setAt(#class, tFurniClass)
  pRewardProps.setAt(#name, tFurniName)
  exit
end

on getRewardProps(me, tProp)
  if me = #name then
    return(pRewardProps.getAt(#name))
  else
    if me = #type then
      return(pRewardProps.getAt(#objectType))
    else
      if me = #class then
        return(pRewardProps.getAt(#class))
      else
        return(void())
      end if
    end if
  end if
  exit
end

on setRewardItems(me, tItemList)
  pREwardItems = tItemList
  exit
end

on getRewardItemForCurrentAmount(me)
  tAmount = pGiveFurniPool.count
  tRewardItem = void()
  tFurniValue = 0
  tNo = 1
  repeat while tNo <= pREwardItems.count
    tItem = pREwardItems.getAt(tNo)
    if tItem.getAt(#furniValue) = tAmount then
      return(tItem)
    else
      if tItem.getAt(#furniValue) > tFurniValue and tItem.getAt(#furniValue) < tAmount then
        tFurniValue = tItem.getAt(#furniValue)
        tRewardItem = tItem
      end if
    end if
    tNo = 1 + tNo
  end repeat
  return(tRewardItem)
  exit
end

on getNextRewardItemForCurrentAmount(me)
  tAmount = pGiveFurniPool.count
  tNextItem = void()
  -- UNK_40 82
  -- UNK_2
  tNo = 1
  repeat while tNo <= pREwardItems.count
    tItem = pREwardItems.getAt(tNo)
    if tItem.getAt(#furniValue) > tAmount then
      if tItem.getAt(#furniValue) - tAmount < tDifferenceToNext then
        tNextItem = tItem
        tDifferenceToNext = tItem.getAt(#furniValue) - tAmount
      end if
    end if
    tNo = 1 + tNo
  end repeat
  return(tNextItem)
  exit
end

on setRecyclingTimes(me, tQuarantineMinutes, tRecyclingMinutes)
  pQuarantineMinutes = tQuarantineMinutes
  pRecyclingMinutes = tRecyclingMinutes
  exit
end

on setRecyclingTimeout(me, tMinutesToTimeout)
  pRecyclingTimeoutMinutes = tMinutesToTimeout
  exit
end

on getQuarantineMinutes(me)
  return(pQuarantineMinutes)
  exit
end

on getRecyclingMinutes(me)
  return(pRecyclingMinutes)
  exit
end

on setTimeLeftProps(me, tMinutesLeft)
  pTimeProps.setAt(#minutesLeft, tMinutesLeft)
  pTimeProps.setAt(#timeStamp, the milliSeconds)
  exit
end

on getMinutesLeftToRecycle(me)
  if ilk(pTimeProps) <> #propList then
    return(void())
  end if
  tMillisSinceStarted = the milliSeconds - pTimeProps.getAt(#timeStamp)
  tMinutesSinceStarted = tMillisSinceStarted / 1000 / 60
  tMinutesLeft = pTimeProps.getAt(#minutesLeft) - tMinutesSinceStarted
  if tMinutesLeft < 0 then
    tMinutesLeft = 0
  end if
  return(tMinutesLeft)
  exit
end

on addFurnitureToGivePool(me, tClass, tID, tProps)
  if me.isFurniInRecycler(tID) then
    return(0)
  end if
  pGiveFurniPool.add([#class:tClass, #id:tID, #props:tProps])
  exit
end

on isFurniInRecycler(me, tStripID)
  if pRecyclerState <> "open" or pGiveFurniPool.count = 0 then
    return(0)
  end if
  tNo = 1
  repeat while tNo <= pGiveFurniPool.count
    if pGiveFurniPool.getAt(tNo).getAt(#props).getAt(#stripId) = tStripID then
      return(1)
    end if
    tNo = 1 + tNo
  end repeat
  return(0)
  exit
end

on setStateTo(me, tstate)
  pRecyclerState = tstate
  pStateRequestPending = 0
  if not threadExists(#room) then
    return(0)
  end if
  tRoomInterface = getThread(#room).getInterface()
  tObjMover = tRoomInterface.getObjectMover()
  if me = "open" then
    if not pServiceEnabled then
      return(me.setStateTo("disabled"))
    end if
    pGiveFurniPool = []
    pGetFurniPool = []
    tRoomInterface.cancelObjectMover()
    tRoomInterface.setProperty(#clickAction, "tradeItem")
    if tObjMover <> 0 then
      tObjMover.moveTrade()
    end if
  else
    if me = "progress" then
      me.clearObjectMover()
    else
      if me = "ready" then
        me.clearObjectMover()
      else
        if me = "disabled" then
          me.clearObjectMover()
        else
          if me = "timeout" then
            me.clearObjectMover()
          else
            me.clearObjectMover()
          end if
        end if
      end if
    end if
  end if
  executeMessage(#recyclerStateChange)
  me.getInterface().setViewToState(tstate)
  exit
end
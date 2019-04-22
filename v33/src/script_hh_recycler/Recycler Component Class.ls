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
  pGivePoolSize = 5
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
  tConn = getConnection(getVariable("connection.info.id"))
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

on setState(me, tstate, tTimeout)
  pState = tstate
  pTimeout = tTimeout
  me.openRecyclerWithState(tstate)
  exit
end

on recyclingFinished(me, tSuccess)
  if not tSuccess then
    return(1)
  end if
  if threadExists(#catalogue) then
    getThread(#catalogue).getInterface().showPurchaseOk()
  end if
  me.requestRecyclerState()
  exit
end

on requestRecyclerState(me)
  tConn = getConnection(getVariable("connection.info.id"))
  tConn.send("GET_RECYCLER_STATUS")
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
  if not me.isPoolFull() then
    return(0)
  end if
  tSafeTrader = getThread(#room).getInterface().getSafeTrader()
  if not voidp(tSafeTrader) then
    if tSafeTrader.getState() = #open then
      executeMessage(#alert, [#Msg:getText("recycler_trader_open_alert"), #modal:1])
      return(0)
    end if
  end if
  me.setState(#closed)
  tMessage = []
  tMessage.addProp(#integer, 5)
  tIndexNo = 1
  repeat while tIndexNo <= 5
    tItem = pGiveFurniPool.getAt(tIndexNo)
    tStripID = tItem.getAt(#props).getAt(#stripId)
    tMessage.addProp(#integer, integer(tStripID))
    tIndexNo = 1 + tIndexNo
  end repeat
  getConnection(getVariable("connection.info.id")).send("RECYCLE_ITEMS", tMessage)
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
  return(pRecyclerState = #open and pIsVisible)
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

on getTimeout(me)
  return(pTimeout)
  exit
end

on removeFurniFromGivePool(me, tGiveFurniIndex)
  if pGiveFurniPool.count >= tGiveFurniIndex then
    pGiveFurniPool.deleteAt(tGiveFurniIndex)
    me.getInterface().updateRecycleButton()
  end if
  exit
end

on addFurnitureToGivePool(me, tClass, tID, tProps)
  if me.isFurniInRecycler(tID) then
    return(0)
  end if
  if me.isPoolFull() then
    return(0)
  end if
  pGiveFurniPool.add([#class:tClass, #id:tID, #props:tProps])
  me.getInterface().updateSlots()
  exit
end

on isPoolFull(me)
  return(pGiveFurniPool.count >= pGivePoolSize)
  exit
end

on isFurniInRecycler(me, tStripID)
  if pRecyclerState <> #open or pGiveFurniPool.count = 0 then
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
  if me = #open then
    pGiveFurniPool = []
    tRoomInterface.cancelObjectMover()
    tRoomInterface.setProperty(#clickAction, "tradeItem")
    if tObjMover <> 0 then
      tObjMover.moveTrade()
    end if
  else
    if me = #closed then
      me.clearObjectMover()
    else
      if me = #timeout then
        me.clearObjectMover()
      end if
    end if
  end if
  me.getInterface().updateView(tstate)
  exit
end
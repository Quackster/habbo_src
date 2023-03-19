property pServiceEnabled, pRecyclerState, pGiveFurniPool, pGetFurniPool, pRewardProps, pREwardItems, pTimeProps, pQuarantineMinutes, pRecyclingMinutes, pIsVisible, pRecyclingTimeoutMinutes, pOpeningRequestPending, pGivePoolSize, pTimeout, pState

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
  pGivePoolSize = 5
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
  tConn = getConnection(getVariable("connection.info.id"))
end

on enableService me, tEnabled
  if tEnabled then
    pServiceEnabled = 1
  else
    pServiceEnabled = 0
  end if
end

on setState me, tstate, tTimeout
  pState = tstate
  pTimeout = tTimeout
  me.openRecyclerWithState(tstate)
end

on recyclingFinished me, tSuccess
  if not tSuccess then
    return 1
  end if
  if threadExists(#catalogue) then
    getThread(#catalogue).getInterface().showPurchaseOk()
  end if
  me.requestRecyclerState()
end

on requestRecyclerState me
  tConn = getConnection(getVariable("connection.info.id"))
  tConn.send("GET_RECYCLER_STATUS")
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
  if not me.isPoolFull() then
    return 0
  end if
  tSafeTrader = getThread(#room).getInterface().getSafeTrader()
  if not voidp(tSafeTrader) then
    if tSafeTrader.getState() = #open then
      executeMessage(#alert, [#Msg: getText("recycler_trader_open_alert"), #modal: 1])
      return 0
    end if
  end if
  me.setState(#closed)
  tMessage = [:]
  tMessage.addProp(#integer, 5)
  repeat with tIndexNo = 1 to 5
    tItem = pGiveFurniPool[tIndexNo]
    tStripID = tItem[#props][#stripId]
    tMessage.addProp(#integer, integer(tStripID))
  end repeat
  getConnection(getVariable("connection.info.id")).send("RECYCLE_ITEMS", tMessage)
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
  return (pRecyclerState = #open) and pIsVisible
end

on getGiveFurniPool me
  return pGiveFurniPool
end

on getState me
  return pRecyclerState
end

on getTimeout me
  return pTimeout
end

on removeFurniFromGivePool me, tGiveFurniIndex
  if pGiveFurniPool.count >= tGiveFurniIndex then
    pGiveFurniPool.deleteAt(tGiveFurniIndex)
    me.getInterface().updateRecycleButton()
  end if
end

on addFurnitureToGivePool me, tClass, tID, tProps
  if me.isFurniInRecycler(tID) then
    return 0
  end if
  if me.isPoolFull() then
    return 0
  end if
  pGiveFurniPool.add([#class: tClass, #id: tID, #props: tProps])
  me.getInterface().updateSlots()
end

on isPoolFull me
  return pGiveFurniPool.count >= pGivePoolSize
end

on isFurniInRecycler me, tStripID
  if (pRecyclerState <> #open) or (pGiveFurniPool.count = 0) then
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
    #open:
      pGiveFurniPool = []
      tRoomInterface.cancelObjectMover()
      tRoomInterface.setProperty(#clickAction, "tradeItem")
      if tObjMover <> 0 then
        tObjMover.moveTrade()
      end if
    #closed:
      me.clearObjectMover()
    #timeout:
      me.clearObjectMover()
  end case
  me.getInterface().updateView(tstate)
end

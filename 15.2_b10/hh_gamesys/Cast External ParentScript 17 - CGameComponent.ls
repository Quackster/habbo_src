property pWaitingForSync, pWaitingForSyncCounter, pWaitingForSyncThreshold, pTurnContainerClass, pTurnContainerPool, m_iAllocationModel, m_rObjectPool, m_sHandler, m_rHandler, m_rQuickRandom, m_rCurrentTurn, m_rNextTurn, m_fTurnT, m_fTurnPulse, m_ar_turnBuffer, m_syncLostTime, m_iSpeedUp, m_iLastMS, m_iLastSubTurn, m_iSubTurnSpacing, m_aLastTurnData, m_bDump

on construct me
  pWaitingForSync = 0
  pWaitingForSyncCounter = 0
  pWaitingForSyncThreshold = 90
  pTurnContainerClass = getClassVariable("gamesystem.turn.class")
  pTurnContainerPool = []
  m_iAllocationModel = #pool
  m_rHandler = VOID
  m_sHandler = ["CMinigameHandlerPrototype"]
  m_rCurrentTurn = VOID
  m_rNextTurn = VOID
  m_fTurnT = 0.0
  m_fTurnPulse = 0.29999999999999999
  m_iLastMS = 0
  m_iLastSubTurn = 0
  m_ar_turnBuffer = []
  m_syncLostTime = 0.0
  m_iSpeedUp = 1
  m_iSubTurnSpacing = 100.0
  m_aLastTurnData = [:]
  m_bDump = 0
  createObject("MGEQuickRandom", "CIterateSeed")
  m_rQuickRandom = getObject("MGEQuickRandom")
  registerMessage(#SetMinigameHandler, me.getID(), #_SetMinigameHandler)
  return 1
end

on deconstruct me
  m_rCurrentTurn = VOID
  pTurnContainerPool = []
  m_ar_turnBuffer = []
  if not voidp(m_rHandler) then
    removeObject(m_rHandler.getID())
  end if
  removeObject(m_rQuickRandom.getID())
  unregisterMessage(#SetMinigameHandler, me.getID())
  removeUpdate(me.getID())
  return 1
end

on StartMinigameEngine me
  pWaitingForSync = 0
  pWaitingForSyncCounter = 0
  m_fTurnT = 0.0
  m_iLastMS = the milliSeconds
  m_iLastSubTurn = -1
  me._ClearCurrentTurn()
  me._ClearTurnBuffer()
  receiveUpdate(me.getID())
end

on stopMinigameEngine me
  me._ClearTurnBuffer()
  pTurnContainerPool = []
  m_fTurnT = 0.0
  m_iLastMS = the milliSeconds
  m_iLastSubTurn = -1
  m_aLastTurnData = [:]
  pWaitingForSync = 1
end

on getNewTurnContainer me
  if (pTurnContainerPool.count > 0) and (m_iAllocationModel <> #simple) then
    tTurnObject = pTurnContainerPool[1]
    pTurnContainerPool.deleteAt(1)
    return tTurnObject
  else
    return createObject(#temp, pTurnContainerClass)
  end if
end

on releaseTurnContainer me, tObject
  if tObject = 0 then
    return 1
  end if
  if m_iAllocationModel = #simple then
    return 1
  end if
  tObject.construct()
  pTurnContainerPool.add(tObject)
  return 1
end

on _SetMinigameHandler me, i_sClass
  m_sHandler = i_sClass
  createObject("MGEHandler", "CMinigameHandlerPrototype", m_sHandler)
  m_rHandler = getObject("MGEHandler")
end

on GetQuickRandom me
  return m_rQuickRandom
end

on GetTurnNumber me
  return m_rCurrentTurn.GetNumber()
end

on GetSubturnSpacing me
  return m_iSubTurnSpacing
end

on _TurnBufferState me
  if m_ar_turnBuffer.count > 1 then
    return #overfill
  end if
  if m_ar_turnBuffer.count = 1 then
    return #ready
  end if
  if m_ar_turnBuffer.count = 0 then
    return #empty
  end if
end

on _AdvanceTurn me
  me._ClearCurrentTurn()
  if pWaitingForSync then
    pWaitingForSyncCounter = pWaitingForSyncCounter + 1
    if pWaitingForSyncCounter < pWaitingForSyncThreshold then
      return 0
    end if
    pWaitingForSyncCounter = 0
    return me.getMessageSender().sendRequestFullStatusUpdate()
  end if
  case me._TurnBufferState() of
    #ready, #overfill:
      m_rCurrentTurn = m_ar_turnBuffer[1]
      m_ar_turnBuffer.deleteAt(1)
      m_fTurnT = 0.0
    #empty:
      m_iSpeedUp = 1
      m_rCurrentTurn = VOID
      if m_bDump then
        put "MGEngine: No turns in buffer. Speedup off"
      end if
  end case
  m_iLastSubTurn = 0
  m_fTurnT = 0.0
end

on addTurnToBuffer me, i_rTurn
  if pWaitingForSync then
    return 0
  end if
  if voidp(m_rCurrentTurn) then
    if m_bDump then
      put "MGEngine: Turn sync gained after" && m_syncLostTime && "seconds."
    else
      if m_bDump then
        put "MGEngine: Extra turn in buffer"
      end if
    end if
  end if
  m_ar_turnBuffer.append(i_rTurn)
end

on _ClearTurnBuffer me
  me._ClearCurrentTurn()
  m_ar_turnBuffer = []
end

on _ClearCurrentTurn me
  if voidp(m_rCurrentTurn) then
    return 1
  end if
  if m_iAllocationModel <> #simple then
    me.releaseTurnContainer(m_rCurrentTurn)
  end if
  m_rCurrentTurn = VOID
end

on floor i_fVal
  tInteger = integer(i_fVal)
  if tInteger > i_fVal then
    return float(tInteger - 1)
  else
    return float(tInteger)
  end if
end

on ProcessSubTurn me, i_iSubturn
  if i_iSubturn <= m_rCurrentTurn.GetNSubTurns() then
    t_ar_events = m_rCurrentTurn.GetSubTurn(i_iSubturn)
    repeat with tEvent in t_ar_events
      t_iEvent = tEvent[#event_type]
      t_ar_iData = []
      if tEvent.count > 1 then
        repeat with i = 2 to tEvent.count
          t_ar_iData.append(tEvent[i])
        end repeat
      end if
      m_rHandler.OnEvent(t_iEvent, tEvent)
    end repeat
  end if
  me.getComponent().executeSubturnMoves(pWaitingForSync, i_iSubturn)
end

on update me
  tTime = the milliSeconds
  dT = (tTime - m_iLastMS) / 1000.0
  m_iLastMS = tTime
  if not voidp(m_rCurrentTurn) then
    if not m_rCurrentTurn.GetTested() then
      me._MinigameTestChecksum(m_rCurrentTurn.GetCheckSum())
    end if
    m_syncLostTime = 0.0
    if me._TurnBufferState() = #overfill then
      m_iSpeedUp = m_ar_turnBuffer.count / 1.5
      if m_bDump then
        put "MGEngine: speedup on"
      end if
    end if
    m_fTurnT = m_fTurnT + dT
    if m_rCurrentTurn = VOID then
      return 1
    end if
    tSubturnSpacing = m_fTurnPulse / m_rCurrentTurn.GetNSubTurns()
    m_iSubTurnSpacing = tSubturnSpacing * (1.0 / m_iSpeedUp)
    tSubturnSpacing = m_iSubTurnSpacing
    tSubturn = integer(floor(m_fTurnT / tSubturnSpacing)) + 1
    if tSubturn > m_rCurrentTurn.GetNSubTurns() then
      tSubturn = m_rCurrentTurn.GetNSubTurns()
    end if
    if m_bDump then
      put "SubTurnSpacing :" && tSubturnSpacing && "ms, buffer size :" && m_ar_turnBuffer.count
    end if
    if tSubturn <> m_iLastSubTurn then
      if (tSubturn - 1) <> m_iLastSubTurn then
        tMissedCount = tSubturn - 1 - m_iLastSubTurn
        repeat with missedTurn = tSubturn - tMissedCount to tSubturn - 1
          me.ProcessSubTurn(missedTurn)
        end repeat
      end if
      if m_bDump then
        put "SubTurnN :" & tSubturn
      end if
      me.ProcessSubTurn(tSubturn)
      m_iLastSubTurn = tSubturn
    end if
  else
    m_syncLostTime = m_syncLostTime + dT
  end if
  tFrameRateEnough = 1
  if dT > m_fTurnPulse then
    if m_bDump then
      put "MGEngine: frame rate too slow!!!"
    end if
    tFrameRateEnough = 0
  end if
  if me.turnDone() or not tFrameRateEnough then
    if not voidp(m_rCurrentTurn) then
      if tSubturn < m_rCurrentTurn.GetNSubTurns() then
        tTurnsToDo = m_rCurrentTurn.GetNSubTurns() - tSubturn
        repeat with missedTurn = m_rCurrentTurn.GetNSubTurns() - tTurnsToDo + 1 to m_rCurrentTurn.GetNSubTurns()
          me.ProcessSubTurn(missedTurn)
        end repeat
      end if
    end if
    if not tFrameRateEnough then
      repeat with t = 1 to m_ar_turnBuffer.count - 1
        me._AdvanceTurn()
        repeat with tSubturn = 1 to m_rCurrentTurn.GetNSubTurns()
          me.ProcessSubTurn(tSubturn)
        end repeat
      end repeat
    end if
    me._AdvanceTurn()
  end if
end

on turnDone me
  tPulse = m_fTurnPulse * (1.0 / m_iSpeedUp)
  return (m_fTurnT >= tPulse) or voidp(m_rCurrentTurn)
end

on _MinigameTestChecksum me, i_iChecksum
  tMyChecksum = me.calculateChecksum()
  m_rCurrentTurn.SetTested(1)
  if i_iChecksum <> tMyChecksum then
    put "*** TURN" && m_rCurrentTurn.GetNumber() && " - CHECKSUM MISMATCH! server says:" && i_iChecksum & ", we say:" && tMyChecksum && ". Previous turn:" && m_aLastTurnData
    put "Turn was " & m_syncLostTime & " seconds late."
    put me.getComponent().dumpChecksumValues()
    me._ClearTurnBuffer()
    me.getMessageSender().sendRequestFullStatusUpdate()
    pWaitingForSync = 1
  end if
  if m_rCurrentTurn <> VOID then
    m_aLastTurnData.setaProp("Turn", m_rCurrentTurn.GetNumber())
    m_aLastTurnData.setaProp("Events", m_rCurrentTurn.GetSubTurns())
  end if
end

on calculateChecksum me
  if not voidp(m_rCurrentTurn) then
    tCheckSum = m_rQuickRandom.IterateSeed(m_rCurrentTurn.GetNumber())
    tCheckSum = me.getComponent().calculateChecksum(tCheckSum)
    return tCheckSum
  end if
end

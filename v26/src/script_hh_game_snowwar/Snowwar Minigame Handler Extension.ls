on construct(me)
  pGameSystem = getObject(getVariable("snowwar.gamesystem.id"))
  if pGameSystem = 0 then
    return(error(me, "Cannot locate game system!", #construct))
  end if
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end

on SetSyncState(me, i_bVal)
  m_bSyncState = i_bVal
  exit
end

on OnStartStage(me, i_iTime)
  exit
end

on OnEndStage(me, i_iTime, i_ar_params)
  exit
end

on OnLoadStage(me, i_sName)
  exit
end

on OnJoin(me)
  exit
end

on OnLeave(me)
  exit
end

on OnEvent(me, tEvent, tdata)
  pGameSystem.sendGameSystemEvent(symbol("snowwar_event_" & tEvent), tdata)
  return(1)
  exit
end

on OnPrepareRoom(me, a_iRoomCode)
  exit
end

on GetSyncState(me)
  return(m_bSyncState)
  exit
end
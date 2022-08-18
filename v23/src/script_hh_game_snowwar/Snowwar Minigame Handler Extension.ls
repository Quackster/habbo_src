property m_bSyncState, pGameSystem

on construct me
  pGameSystem = getObject(getVariable("snowwar.gamesystem.id"))
  if (pGameSystem = 0) then
    return error(me, "Cannot locate game system!", #construct)
  end if
  return 1
end

on deconstruct me
  return 1
end

on SetSyncState me, i_bVal
  m_bSyncState = i_bVal
end

on OnStartStage me, i_iTime
end

on OnEndStage me, i_iTime, i_ar_params
end

on OnLoadStage me, i_sName
end

on OnJoin me
end

on OnLeave me
end

on OnEvent me, tEvent, tdata
  pGameSystem.sendGameSystemEvent(symbol(("snowwar_event_" & tEvent)), tdata)
  return 1
end

on OnPrepareRoom me, a_iRoomCode
end

on GetSyncState me
  return m_bSyncState
end

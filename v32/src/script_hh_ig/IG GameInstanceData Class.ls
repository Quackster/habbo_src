property pUserTeamsIndex, pOwnPlayerId

on construct me 
  pOwnPlayerId = -1
  pUserTeamsIndex = [:]
  return(me.ancestor.construct())
end

on deconstruct me 
  pOwnPlayerId = -1
  pUserTeamsIndex = [:]
  return(me.ancestor.deconstruct())
end

on Refresh me, tdata 
  tAllTeamData = tdata.getaProp(#teams)
  if listp(tAllTeamData) then
    i = 1
    repeat while i <= tAllTeamData.count
      tTeam = tAllTeamData.getAt(i)
      tPlayers = tTeam.getaProp(#players)
      repeat while tPlayers <= undefined
        tPlayer = getAt(undefined, tdata)
        me.addUserToGame(tPlayer, 1)
      end repeat
      i = (1 + i)
    end repeat
  end if
  me.ancestor.Refresh(tdata)
  return TRUE
end

on addUserToGame me, tdata, tHoldAnnounce 
  if not listp(tdata) then
    return FALSE
  end if
  tUserID = tdata.getaProp(#id)
  if tdata.findPos(#players_required) then
    me.pData.setaProp(#players_required, tdata.getaProp(#players_required))
  end if
  tTeamId = tdata.getaProp(#team_id)
  if voidp(tTeamId) then
    return FALSE
  end if
  tOldTeamId = me.getTeamIdFromIndex(tUserID)
  if tOldTeamId <> 0 then
    if tOldTeamId <> tTeamId then
      me.removeUserFromGame(tdata)
    end if
  end if
  me.storeToIndex(tUserID, tTeamId)
  me.pData.setaProp(#player_count, pUserTeamsIndex.count)
  if (me.pData.findPos(#teams) = 0) then
    me.pData.setaProp(#teams, [:])
  end if
  tAllTeamData = me.pData.getaProp(#teams)
  if (tAllTeamData.findPos(tTeamId) = 0) then
    tAllTeamData.setaProp(tTeamId, [#players:[:]])
  end if
  tPlayers = tAllTeamData.getaProp(tTeamId).getaProp(#players)
  tPlayerData = [:]
  repeat while [#id, #name, #figure, #sex, #team_id, #room_index] <= tHoldAnnounce
    tKey = getAt(tHoldAnnounce, tdata)
    if tdata.findPos(tKey) then
      tPlayerData.setaProp(tKey, tdata.getaProp(tKey))
    end if
  end repeat
  if (tdata.getaProp(#name) = me.getOwnPlayerName()) then
    pOwnPlayerId = tUserID
  end if
  tPlayers.setaProp(tUserID, tPlayerData)
  if not tHoldAnnounce then
    towner = me.getOwnerIGComponent()
    if towner <> 0 then
      towner.announceUpdate(me.getProperty(#id))
    end if
  end if
  return TRUE
end

on removeUserFromGame me, tdata 
  tUserID = tdata.getaProp(#id)
  tAllTeamData = me.pData.getaProp(#teams)
  if (tAllTeamData = 0) then
    return FALSE
  end if
  tTeamId = me.getTeamIdFromIndex(tUserID)
  if (tTeamId = 0) then
    return TRUE
  end if
  me.storeToIndex(tUserID, -1)
  if (pOwnPlayerId = tUserID) then
    pOwnPlayerId = -1
  end if
  tTeam = tAllTeamData.getaProp(tTeamId)
  tPlayers = tTeam.getaProp(#players)
  if not tPlayers.findPos(tUserID) then
    return FALSE
  end if
  tPlayers.deleteProp(tUserID)
  me.pData.setaProp(#player_count, pUserTeamsIndex.count)
  if tdata.findPos(#players_required) then
    me.pData.setaProp(#players_required, tdata.getaProp(#players_required))
  end if
  towner = me.getOwnerIGComponent()
  if towner <> 0 then
    towner.announceUpdate(me.getProperty(#id))
  end if
  return TRUE
end

on getLevelHighscore me 
  tLevelRef = me.getLevelRef()
  if (tLevelRef = 0) then
    return FALSE
  end if
  return(tLevelRef.getLevelHighscore())
end

on getLevelTeamHighscore me 
  tLevelRef = me.getLevelRef()
  if (tLevelRef = 0) then
    return FALSE
  end if
  return(tLevelRef.getLevelTeamHighscore())
end

on getPlayerById me, tID 
  tAllTeamData = me.pData.getaProp(#teams)
  if (tAllTeamData = 0) then
    return FALSE
  end if
  repeat while tAllTeamData <= undefined
    tTeam = getAt(undefined, tID)
    tPlayers = tTeam.getaProp(#players)
    repeat while tAllTeamData <= undefined
      tPlayer = getAt(undefined, tID)
      if listp(tPlayer) then
        if (tPlayer.getaProp(#id) = tID) then
          return(tPlayer)
        end if
      end if
    end repeat
  end repeat
  return FALSE
end

on getAllTeamData me 
  return(me.pData.getaProp(#teams))
end

on getTeam me, tTeamId 
  tTeamData = me.pData.getaProp(#teams)
  if (tTeamData = void()) then
    return FALSE
  end if
  return(tTeamData.getaProp(tTeamId))
end

on getTeamPlayers me, tTeamIndex 
  tAllTeamData = me.getAllTeamData()
  if not listp(tAllTeamData) then
    return FALSE
  end if
  tTeamData = tAllTeamData.getaProp(tTeamIndex)
  if not listp(tTeamData) then
    return FALSE
  end if
  return(tTeamData.getaProp(#players))
end

on getPlayerCount me 
  if (me.pData.findPos(#player_count) = 0) then
    return FALSE
  end if
  return(me.pData.getaProp(#player_count))
end

on getMaxPlayerCount me 
  if (me.pData.findPos(#player_max_count) = 0) then
    return FALSE
  end if
  return(me.pData.getaProp(#player_max_count))
end

on getTeamSize me, tTeamIndex 
  tdata = me.getTeamPlayers(tTeamIndex)
  if listp(tdata) then
    return(tdata.count)
  else
    return FALSE
  end if
end

on getTeamCount me 
  if (me.pData.findPos(#number_of_teams) = 0) then
    return FALSE
  end if
  return(me.pData.getaProp(#number_of_teams))
end

on getTeamMaxSize me 
  tTeamCount = me.getTeamCount()
  if (tTeamCount = 1) then
    tCount = 12
  else
    if (tTeamCount = 2) then
      if tTeamCount <> 0 then
        if (tTeamCount = 1) then
          tCount = 6
        else
          tCount = 4
        end if
        if (tTeamCount = 3) then
          tCount = 4
        else
          if (tTeamCount = 4) then
            tCount = 3
          end if
        end if
        return(tCount)
      end if
    end if
  end if
end

on checkPlayerRequiredForSlot me, tTeamIndex, tPlayerIndex 
  tPlayersRequired = me.getProperty(#players_required)
  if not listp(tPlayersRequired) then
    return FALSE
  end if
  tRequiredCount = tPlayersRequired.getaProp(tTeamIndex)
  if voidp(tRequiredCount) then
    return FALSE
  end if
  tTeamSize = me.getTeamSize(tTeamIndex)
  return(((tTeamSize + tRequiredCount) = tPlayerIndex))
end

on getGameState me 
  return(me.pData.getaProp(#state))
end

on getGameStateTimer me 
  return(me.pData.getaProp(#state_timer))
end

on getBiggestTeamPlayerCount me 
  tResult = 0
  tTeamCount = me.getTeamCount()
  tTeamIndex = 1
  repeat while tTeamIndex <= tTeamCount
    tTeam = me.getTeamPlayers(tTeamIndex)
    tPlayerCount = tTeam.count
    if tPlayerCount > tResult then
      tResult = tPlayerCount
    end if
    tTeamIndex = (1 + tTeamIndex)
  end repeat
  return(tResult)
end

on canStart me 
  tList = me.pData.getaProp(#players_required)
  if not listp(tList) then
    return TRUE
  end if
  if (tList.count = 0) then
    return TRUE
  end if
  return FALSE
end

on getOwnPlayerTeam me 
  return(me.getTeamIdFromIndex(me.getOwnPlayerId()))
end

on getOwnPlayerName me 
  tSession = getObject(#session)
  if (tSession = 0) then
    return FALSE
  end if
  return(tSession.GET(#user_name))
end

on getOwnPlayerId me 
  return(pOwnPlayerId)
end

on checkIfOwnerOfGame me 
  tSession = getObject(#session)
  if (tSession = 0) then
    return FALSE
  end if
  return((tSession.GET(#user_name) = me.pData.getaProp(#owner_name)))
end

on hasCompleteData me 
  return(listp(me.getAllTeamData()))
end

on hasTeamScores me 
  return(me.pData.findPos(#level_team_scores) > 0)
end

on getTeamIdFromIndex me, tID 
  return(pUserTeamsIndex.getaProp(tID))
end

on storeToIndex me, tID, tTeamId 
  if voidp(tID) or voidp(tTeamId) then
    return FALSE
  end if
  if (tTeamId = -1) then
    pUserTeamsIndex.deleteProp(tID)
  else
    pUserTeamsIndex.setaProp(tID, tTeamId)
  end if
  return TRUE
end

on getLevelRef me 
  tLevelId = me.getProperty(#level_id)
  if voidp(tLevelId) then
    return FALSE
  end if
  tService = me.getIGComponent("LevelList")
  if (tService = 0) then
    return FALSE
  end if
  return(tService.getListEntry(tLevelId))
end

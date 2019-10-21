property pFrameworkId, pUserTeamIndex

on construct me 
  pFrameworkId = getVariable("bb.loungesystem.id")
  pUserTeamIndex = 0
  return TRUE
end

on deconstruct me 
  return TRUE
end

on getGameSystem me 
  return(getObject(pFrameworkId))
end

on getUserName me 
  return(getObject(#session).GET(#userName))
end

on isUserHost me 
  if (me.getGameSystem() = 0) then
    return FALSE
  end if
  tdata = me.getGameSystem().getObservedInstance()
  if (tdata = 0) then
    return FALSE
  end if
  tHostName = tdata.getAt(#host).getAt(#name)
  return((tHostName = me.getUserName()))
end

on observeInstance me, tIndexOnList 
  if (me.getGameSystem() = 0) then
    return FALSE
  end if
  tList = me.getGameSystem().getInstanceList()
  if (tList = 0) then
    return FALSE
  end if
  if tIndexOnList > tList.count then
    return FALSE
  end if
  if not listp(tList.getAt(tIndexOnList)) then
    return FALSE
  end if
  tGameId = tList.getAt(tIndexOnList).getAt(#id)
  if (me.getGameSystem() = 0) then
    return FALSE
  end if
  return(me.getGameSystem().observeInstance(tGameId))
end

on joinGame me, tTeamIndex 
  if (me.getGameSystem() = 0) then
    return FALSE
  end if
  tParamList = me.getGameSystem().getJoinParameters()
  if (tTeamIndex = 0) then
    tTeamIndex = pUserTeamIndex
  end if
  if (tTeamIndex = 0) then
    tTeamIndex = me.getUserTeamIndex()
  end if
  tInstance = me.getGameSystem().getObservedInstance()
  tInstanceId = tInstance.getAt(#id)
  if not listp(tParamList) then
    return(me.getGameSystem().initiateJoinGame(tInstanceId, tTeamIndex))
  end if
  return(me.getGameSystem().joinGame(void(), tInstanceId, tTeamIndex, tParamList))
end

on checkUserWasKicked me 
  if pUserTeamIndex <> 0 then
    if (me.getUserTeamIndex() = 0) then
      return TRUE
    end if
  end if
  return FALSE
end

on saveUserTeamIndex me 
  pUserTeamIndex = me.getUserTeamIndex()
  return TRUE
end

on resetUserTeamIndex me 
  pUserTeamIndex = 0
  return TRUE
end

on getUserTeamIndex me 
  return(me.getPlayerTeamIndex([#name:me.getUserName()]))
end

on gameCanStart me 
  tdata = me.getGameSystem().getObservedInstance()
  if (tdata = 0) then
    return FALSE
  end if
  tOneTeamOK = 0
  repeat while tdata.getAt(#teams) <= undefined
    tTeam = getAt(undefined, undefined)
    if tTeam.getAt(#players).count > 0 then
      if (tOneTeamOK = 1) then
        return TRUE
      end if
      tOneTeamOK = 1
    end if
  end repeat
  return FALSE
end

on getPlayerTeamIndex me, tSearchData 
  if (me.getGameSystem() = 0) then
    return FALSE
  end if
  tdata = me.getGameSystem().getObservedInstance()
  if (tdata.getAt(#teams) = void()) then
    return FALSE
  end if
  tTeamNum = 1
  repeat while tTeamNum <= tdata.getAt(#teams).count
    tTeam = tdata.getAt(#teams).getAt(tTeamNum).getAt(#players)
    if not listp(tTeam) then
      tTeam = []
    end if
    repeat while tTeam <= undefined
      tPlayer = getAt(undefined, tSearchData)
      if (tPlayer.getAt(#name) = tSearchData.getAt(#name)) and tSearchData.getAt(#name) <> void() then
        return(tTeamNum)
      end if
      if (tPlayer.getAt(#id) = tSearchData.getAt(#id)) and tSearchData.getAt(#id) <> void() then
        return(tTeamNum)
      end if
    end repeat
    tTeamNum = (1 + tTeamNum)
  end repeat
  return FALSE
end

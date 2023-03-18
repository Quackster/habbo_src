property pFrameworkId, pUserTeamIndex

on construct me
  pFrameworkId = getVariable("bb.loungesystem.id")
  pUserTeamIndex = 0
  repeat with i = 0 to 7
    tPartList = getVariable("human.parts.sh.sit." & i)
    if tPartList = 0 then
      tPartList = getVariable("human.parts.sh." & i)
    end if
    tPartListNew = ["bl"]
    if tPartList <> 0 then
      repeat with tPart in tPartList
        tPartListNew.add(tPart)
      end repeat
    end if
    setVariable("bouncing.human.parts.sh." & i, tPartListNew)
  end repeat
  tPartListNew = ["bl"]
  tPartList = getVariable("human.parts.sh")
  if tPartList <> 0 then
    repeat with tPart in tPartList
      tPartListNew.add(tPart)
    end repeat
  end if
  setVariable("bouncing.human.parts.sh", tPartListNew)
  return 1
end

on deconstruct me
  return 1
end

on getGameSystem me
  return getObject(pFrameworkId)
end

on getUserName me
  return getObject(#session).GET(#userName)
end

on isUserHost me
  if me.getGameSystem() = 0 then
    return 0
  end if
  tdata = me.getGameSystem().getObservedInstance()
  if tdata = 0 then
    return 0
  end if
  tHostName = tdata[#host][#name]
  return tHostName = me.getUserName()
end

on observeInstance me, tIndexOnList
  if me.getGameSystem() = 0 then
    return 0
  end if
  tList = me.getGameSystem().getInstanceList()
  if tList = 0 then
    return 0
  end if
  if tIndexOnList > tList.count then
    return 0
  end if
  if not listp(tList[tIndexOnList]) then
    return 0
  end if
  tGameId = tList[tIndexOnList][#id]
  if me.getGameSystem() = 0 then
    return 0
  end if
  return me.getGameSystem().observeInstance(tGameId)
end

on joinGame me, tTeamIndex
  if me.getGameSystem() = 0 then
    return 0
  end if
  tParamList = me.getGameSystem().getJoinParameters()
  if tTeamIndex = 0 then
    tTeamIndex = pUserTeamIndex
  end if
  if tTeamIndex = 0 then
    tTeamIndex = me.getUserTeamIndex()
  end if
  tInstance = me.getGameSystem().getObservedInstance()
  tInstanceId = tInstance[#id]
  if not listp(tParamList) then
    return me.getGameSystem().initiateJoinGame(tInstanceId, tTeamIndex)
  end if
  return me.getGameSystem().joinGame(VOID, tInstanceId, tTeamIndex, tParamList)
end

on checkUserWasKicked me
  if pUserTeamIndex <> 0 then
    if me.getUserTeamIndex() = 0 then
      return 1
    end if
  end if
  return 0
end

on saveUserTeamIndex me
  pUserTeamIndex = me.getUserTeamIndex()
  return 1
end

on resetUserTeamIndex me
  pUserTeamIndex = 0
  return 1
end

on getUserTeamIndex me
  return me.getPlayerTeamIndex([#name: me.getUserName()])
end

on gameCanStart me
  tdata = me.getGameSystem().getObservedInstance()
  if tdata = 0 then
    return 0
  end if
  tOneTeamOK = 0
  repeat with tTeam in tdata[#teams]
    if tTeam[#players].count > 0 then
      if tOneTeamOK = 1 then
        return 1
      end if
      tOneTeamOK = 1
    end if
  end repeat
  return 0
end

on getPlayerTeamIndex me, tSearchData
  if me.getGameSystem() = 0 then
    return 0
  end if
  tdata = me.getGameSystem().getObservedInstance()
  if tdata[#teams] = VOID then
    return 0
  end if
  repeat with tTeamNum = 1 to tdata[#teams].count
    tTeam = tdata[#teams][tTeamNum][#players]
    if not listp(tTeam) then
      tTeam = []
    end if
    repeat with tPlayer in tTeam
      if (tPlayer[#name] = tSearchData[#name]) and (tSearchData[#name] <> VOID) then
        return tTeamNum
      end if
      if (tPlayer[#id] = tSearchData[#id]) and (tSearchData[#id] <> VOID) then
        return tTeamNum
      end if
    end repeat
  end repeat
  return 0
end

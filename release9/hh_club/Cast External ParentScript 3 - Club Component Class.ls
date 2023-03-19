property pClubStatus

on construct me
  pClubStatus = [:]
  return 1
end

on deconstruct me
  pClubStatus = [:]
  return 1
end

on setStatus me, tStatus, tResponseFlag
  tOldClubStatus = pClubStatus
  pClubStatus = tStatus
  getObject(#session).set("club_status", tStatus)
  me.getInterface().updateClubStatus(tStatus, tResponseFlag, tOldClubStatus)
  executeMessage(#updateClubStatus, tStatus)
  return 1
end

on getStatus me
  if voidp(pClubStatus) then
    return 0
  else
    return pClubStatus
  end if
end

on subscribe me, tChosenLength
  if connectionExists(getVariable("connection.info.id")) then
    tList = [#string: "club_habbo", #integer: tChosenLength]
    return getConnection(getVariable("connection.info.id")).send("SCR_BUY", tList)
  else
    return error(me, "Couldn't find connection:" && getVariable("connection.info.id"), #subscribe)
  end if
end

on askforBadgeUpdate me
  if connectionExists(getVariable("connection.info.id")) then
    return getConnection(getVariable("connection.info.id")).send("GETAVAILABLEBADGES")
  else
    return error(me, "Couldn't find connection:" && getVariable("connection.info.id"), #askforBadgeUpdate)
  end if
end

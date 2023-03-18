property pClubStatus

on construct me
  pClubStatus = [:]
  return 1
end

on deconstruct me
  pClubStatus = [:]
  return 1
end

on setStatus me, tStatus
  pClubStatus = tStatus
  getObject(#session).set("club_status", tStatus)
  me.getInterface().updateClubStatus(tStatus)
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

on subscribe me, tDays
  if connectionExists(getVariable("connection.info.id")) then
    return getConnection(getVariable("connection.info.id")).send(#info, "SCR_SUBSCRIBE club_habbo 0" && tDays)
  else
    return error(me, "Couldn't find connection:" && getVariable("connection.info.id"), #subscribe)
  end if
end

on extendSubscription me, tDays
  if connectionExists(getVariable("connection.info.id")) then
    return getConnection(getVariable("connection.info.id")).send(#info, "SCR_EXTSCR club_habbo" && tDays)
  else
    return error(me, "Couldn't find connection:" && getVariable("connection.info.id"), #extendSubscription)
  end if
end

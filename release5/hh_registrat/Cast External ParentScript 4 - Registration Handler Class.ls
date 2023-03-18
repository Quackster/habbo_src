on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_ok me, tMsg
  if me.getComponent().pState = "openFigureCreator" then
    getConnection(tMsg.getaProp(#connection)).send(#info, "GETAVAILABLESETS")
  end if
end

on handle_regok me, tMsg
  case me.getComponent().pState of
    "openFigureCreator":
      me.getComponent().newFigureReady()
    "openFigureUpdate":
      me.getComponent().figureUpdateReady()
  end case
end

on handle_nameapproved me, tMsg
end

on handle_nameunacceptable me, tMsg
  me.getInterface().userNameUnacceptable()
end

on handle_availablesets me, tMsg
  tSets = value(tMsg.message.line[2])
  if not listp(tSets) then
    tSets = []
  end if
  if count(tSets) < 2 then
    tSets = VOID
  end if
  me.getComponent().setAvailableSetList(tSets)
end

on regMsgList me, tBool
  tList = [:]
  tList["SECRET_KEY"] = #handle_ok
  tList["REGOK"] = #handle_regok
  tList["NAME_APPROVED"] = #handle_nameapproved
  tList["NAME_UNACCEPTABLE"] = #handle_nameunacceptable
  tList["AVAILABLESETS"] = #handle_availablesets
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tList)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tList)
  end if
end

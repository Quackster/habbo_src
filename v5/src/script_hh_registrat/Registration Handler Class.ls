on construct(me)
  return(me.regMsgList(1))
  exit
end

on deconstruct(me)
  return(me.regMsgList(0))
  exit
end

on handle_ok(me, tMsg)
  if me.getComponent().pState = "openFigureCreator" then
    getConnection(tMsg.getaProp(#connection)).send(#info, "GETAVAILABLESETS")
  end if
  exit
end

on handle_regok(me, tMsg)
  if me = "openFigureCreator" then
    me.getComponent().newFigureReady()
  else
    if me = "openFigureUpdate" then
      me.getComponent().figureUpdateReady()
    end if
  end if
  exit
end

on handle_nameapproved(me, tMsg)
  exit
end

on handle_nameunacceptable(me, tMsg)
  me.getInterface().userNameUnacceptable()
  exit
end

on handle_availablesets(me, tMsg)
  tSets = value(tMsg.getProp(#line, 2))
  if not listp(tSets) then
    tSets = []
  end if
  if count(tSets) < 2 then
    tSets = void()
  end if
  me.getComponent().setAvailableSetList(tSets)
  exit
end

on regMsgList(me, tBool)
  tList = []
  tList.setAt("SECRET_KEY", #handle_ok)
  tList.setAt("REGOK", #handle_regok)
  tList.setAt("NAME_APPROVED", #handle_nameapproved)
  tList.setAt("NAME_UNACCEPTABLE", #handle_nameunacceptable)
  tList.setAt("AVAILABLESETS", #handle_availablesets)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tList)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tList)
  end if
  exit
end
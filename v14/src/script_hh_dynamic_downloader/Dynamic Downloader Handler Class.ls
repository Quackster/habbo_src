on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on handle_furni_revisions me, tMsg 
  tConn = tMsg.connection
  if not tConn then
    return FALSE
  end if
  tTypeList = [1, 0]
  ttype = 1
  repeat while ttype <= tTypeList.count
    tCount = tConn.GetIntFrom()
    tIndex = 1
    repeat while tIndex <= tCount
      tClass = tConn.GetStrFrom()
      tRevision = tConn.GetIntFrom()
      me.getComponent().setFurniRevision(tClass, tRevision, tTypeList.getAt(ttype))
      tIndex = (1 + tIndex)
    end repeat
    ttype = (1 + ttype)
  end repeat
  me.getComponent().setFurniRevision(void(), void(), void())
  return TRUE
end

on handle_alias_list me, tMsg 
  tConn = tMsg.connection
  if not tConn then
    return FALSE
  end if
  tCount = tConn.GetIntFrom()
  tIndex = 1
  repeat while tIndex <= tCount
    tOriginalClass = tConn.GetStrFrom()
    tAliasClass = tConn.GetStrFrom()
    me.getComponent().setAssetAlias(tOriginalClass, tAliasClass)
    tIndex = (1 + tIndex)
  end repeat
  me.getComponent().setAssetAlias(void(), void())
  me.getComponent().tryNextDownload()
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(295, #handle_furni_revisions)
  tMsgs.setaProp(297, #handle_alias_list)
  tCmds = [:]
  tCmds.setaProp("GET_FURNI_REVISIONS", 213)
  tCmds.setaProp("GET_ALIAS_LIST", 215)
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  return TRUE
end

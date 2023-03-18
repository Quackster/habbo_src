on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_furni_revisions me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tTypeList = [1, 0]
  repeat with ttype = 1 to tTypeList.count
    tCount = tConn.GetIntFrom()
    repeat with tIndex = 1 to tCount
      tClass = tConn.GetStrFrom()
      tRevision = tConn.GetIntFrom()
      me.getComponent().setFurniRevision(tClass, tRevision, tTypeList[ttype])
    end repeat
  end repeat
  me.getComponent().setFurniRevision(VOID, VOID, VOID)
  return 1
end

on handle_alias_list me, tMsg
  tConn = tMsg.connection
  if not tConn then
    return 0
  end if
  tCount = tConn.GetIntFrom()
  repeat with tIndex = 1 to tCount
    tOriginalClass = tConn.GetStrFrom()
    tAliasClass = tConn.GetStrFrom()
    me.getComponent().setAssetAlias(tOriginalClass, tAliasClass)
  end repeat
  me.getComponent().setAssetAlias(VOID, VOID)
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
  return 1
end

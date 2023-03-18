on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_ok me, tMsg
  getConnection(tMsg.getaProp(#connection)).send(#info, "SCR_GINFO club_habbo")
end

on handle_scr_sinfo me, tMsg
  tDelim = the itemDelimiter
  the itemDelimiter = TAB
  tList = [:]
  tList[#command] = "SCR_SINF"
  tList[#productName] = tMsg.content.item[1]
  tList[#status] = tMsg.content.item[2]
  tList[#daysLeft] = value(tMsg.content.item[3])
  the itemDelimiter = tDelim
  me.getComponent().setStatus(tList)
end

on handle_scr_nosub me, tMsg
  tList = [:]
  tList[#command] = "SCR_NOSUB"
  tList[#status] = "inactive"
  tList[#productName] = tMsg.getaProp(#content)
  me.getComponent().setStatus(tList)
end

on handle_scr_sok me, tMsg
  me.getInterface().subscriptionOkConfirmed()
end

on regMsgList me, tBool
  tList = [:]
  tList["OK"] = #handle_ok
  tList["SCR_SINF"] = #handle_scr_sinfo
  tList["SCR_NOSUB"] = #handle_scr_nosub
  tList["SCR_SOK"] = #handle_scr_sok
  if tBool then
    return registerListener(getVariable("connection.info.id"), me.getID(), tList)
  else
    return unregisterListener(getVariable("connection.info.id"), me.getID(), tList)
  end if
end

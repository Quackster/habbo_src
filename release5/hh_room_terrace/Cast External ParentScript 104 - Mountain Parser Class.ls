on construct me
  return me.regMsgList(1)
end

on deconsturct me
  return me.regMsgList(0)
end

on parse_open_uimakoppi me, tMsg
  me.getInterface().openPukukoppi()
end

on parse_close_uimakoppi me, tMsg
  me.getInterface().closePukukoppi()
end

on parse_md_exit me, tMsg
  me.getInterface().doTheDew(tMsg.content)
end

on parse_tickets me, tMsg
  me.getComponent().setTicketCount(integer(tMsg.content.word[1]))
end

on parse_tickets_buy me, tMsg
  me.getComponent().setTicketCount(integer(tMsg.content.word[1]))
  me.getInterface().openTicketWnd(1)
end

on parse_no_tickets me, tMsg
  me.getInterface().openTicketWnd()
end

on regMsgList me, tBool
  tList = [:]
  tList["OPEN_UIMAKOPPI"] = #parse_open_uimakoppi
  tList["CLOSE_UIMAKOPPI"] = #parse_close_uimakoppi
  tList["MD_EXIT"] = #parse_md_exit
  tList["PH_TICKETS"] = #parse_tickets
  tList["PH_TICKETS_BUY"] = #parse_tickets_buy
  tList["PT_NOTCKS"] = #parse_no_tickets
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tList)
    registerListener(getVariable("connection.info.id"), me.getID(), ["PH_TICKETS_BUY": #parse_tickets_buy])
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tList)
    unregisterListener(getVariable("connection.info.id"), me.getID(), ["PH_TICKETS_BUY": #parse_tickets_buy])
  end if
  return 1
end

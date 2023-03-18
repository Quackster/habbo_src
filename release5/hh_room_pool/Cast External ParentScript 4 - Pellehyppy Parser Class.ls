on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on parse_openuimakoppi me, tMsg
  me.getComponent().openUimakoppi()
end

on parse_closeuimakoppi me, tMsg
  me.getComponent().closeUimaKoppi()
end

on parse_phtickets me, tMsg
  me.getComponent().setNumOfPhTickets(tMsg.message.word[2])
end

on parse_phtickets_buy me, tMsg
  me.getComponent().setNumOfPhTickets(tMsg.message.line[2].word[1])
  me.getInterface().showTicketWnd()
end

on parse_notickets me, tMsg
  me.getComponent().setNumOfPhTickets(0)
  me.getInterface().showTicketWnd()
end

on parse_jumpdata me, tMsg
  tProps = ["name": tMsg.message.line[2], "jumpdata": tMsg.message.line[3]]
  me.getComponent().jumpPlayPack(tProps)
end

on parse_jumpliftdoor_open me, tMsg
  put "TODO:" && tMsg.getaProp(#subject)
end

on parse_jumpliftdoor_close me, tMsg
  put "TODO:" && tMsg.getaProp(#subject)
end

on parse_jumpingplace_ok me, tMsg
  me.getComponent().jumpingPlaceOk()
end

on regMsgList me, tBool
  tList = [:]
  tList["OPEN_UIMAKOPPI"] = #parse_openuimakoppi
  tList["CLOSE_UIMAKOPPI"] = #parse_closeuimakoppi
  tList["PH_TICKETS"] = #parse_phtickets
  tList["PH_NOTICKETS"] = #parse_notickets
  tList["JUMPDATA"] = #parse_jumpdata
  tList["JUMPLIFTDOOR_OPEN"] = #parse_jumpliftdoor_open
  tList["JUMPLIFTDOOR_CLOSE"] = #parse_jumpliftdoor_close
  tList["JUMPINGPLACE_OK"] = #parse_jumpingplace_ok
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tList)
    registerListener(getVariable("connection.info.id"), me.getID(), ["PH_TICKETS_BUY": #parse_phtickets_buy])
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tList)
    unregisterListener(getVariable("connection.info.id"), me.getID(), ["PH_TICKETS_BUY": #parse_phtickets_buy])
  end if
  return 1
end

on construct(me)
  return(me.regMsgList(1))
  exit
end

on deconstruct(me)
  return(me.regMsgList(0))
  exit
end

on parse_openuimakoppi(me, tMsg)
  me.getComponent().openUimakoppi()
  exit
end

on parse_closeuimakoppi(me, tMsg)
  me.getComponent().closeUimaKoppi()
  exit
end

on parse_phtickets(me, tMsg)
  me.getComponent().setNumOfPhTickets(tMsg.getProp(#word, 2))
  exit
end

on parse_phtickets_buy(me, tMsg)
  me.getComponent().setNumOfPhTickets(tMsg.getPropRef(#line, 2).getProp(#word, 1))
  me.getInterface().showTicketWnd()
  exit
end

on parse_notickets(me, tMsg)
  me.getComponent().setNumOfPhTickets(0)
  me.getInterface().showTicketWnd()
  exit
end

on parse_jumpdata(me, tMsg)
  tProps = ["name":tMsg.getProp(#line, 2), "jumpdata":tMsg.getProp(#line, 3)]
  me.getComponent().jumpPlayPack(tProps)
  exit
end

on parse_jumpliftdoor_open(me, tMsg)
  put("TODO:" && tMsg.getaProp(#subject))
  exit
end

on parse_jumpliftdoor_close(me, tMsg)
  put("TODO:" && tMsg.getaProp(#subject))
  exit
end

on parse_jumpingplace_ok(me, tMsg)
  me.getComponent().jumpingPlaceOk()
  exit
end

on regMsgList(me, tBool)
  tList = []
  tList.setAt("OPEN_UIMAKOPPI", #parse_openuimakoppi)
  tList.setAt("CLOSE_UIMAKOPPI", #parse_closeuimakoppi)
  tList.setAt("PH_TICKETS", #parse_phtickets)
  tList.setAt("PH_NOTICKETS", #parse_notickets)
  tList.setAt("JUMPDATA", #parse_jumpdata)
  tList.setAt("JUMPLIFTDOOR_OPEN", #parse_jumpliftdoor_open)
  tList.setAt("JUMPLIFTDOOR_CLOSE", #parse_jumpliftdoor_close)
  tList.setAt("JUMPINGPLACE_OK", #parse_jumpingplace_ok)
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tList)
    registerListener(getVariable("connection.info.id"), me.getID(), ["PH_TICKETS_BUY":#parse_phtickets_buy])
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tList)
    unregisterListener(getVariable("connection.info.id"), me.getID(), ["PH_TICKETS_BUY":#parse_phtickets_buy])
  end if
  return(1)
  exit
end
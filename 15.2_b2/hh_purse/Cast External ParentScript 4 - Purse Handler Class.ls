on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_purse me, tMsg
  case tMsg.subject of
    6:
      tPlaySnd = getObject(#session).exists("user_walletbalance")
      tCredits = integer(getLocalFloat(tMsg.content.word[1]))
      getObject(#session).set("user_walletbalance", tCredits)
      me.getInterface().updatePurseSaldo()
      executeMessage(#updateCreditCount, tCredits)
      if tPlaySnd then
        puppetSound(3, getmemnum("naw_snd_cash"))
      end if
      return 1
    209:
      tPages = [[]]
      tPageNum = 1
      tDelim = the itemDelimiter
      the itemDelimiter = TAB
      repeat with i = tMsg.content.line.count - 1 down to 1
        tLine = tMsg.content.line[i]
        if tLine = EMPTY then
          exit repeat
        end if
        tList = [:]
        tList["date"] = tLine.item[1]
        tList["time"] = tLine.item[2]
        tList["credit_value"] = tLine.item[3]
        tList["real_value"] = tLine.item[4]
        tList["currency"] = tLine.item[5]
        tList["transaction_system_name"] = tLine.item[6]
        tPages[tPageNum].add(tList)
        if count(tPages[tPageNum]) = 10 then
          tPageNum = tPageNum + 1
          tPages.add([])
        end if
      end repeat
      me.getInterface().dataReceived()
      if count(tPages[count(tPages)]) = 0 then
        tPages.deleteAt(count(tPages))
      end if
      if count(tPages) > 0 then
        getObject(#session).set("purse_transactions", 1)
        return me.getInterface().showPages(tPages)
      else
        getObject(#session).set("purse_transactions", 0)
        return me.getInterface().showPages()
      end if
    212:
      me.getInterface().hideVoucherWindow()
      me.getInterface().setVoucherInput(1)
      tConn = tMsg.connection
      if tConn = VOID then
        return 1
      end if
      tProductName = tConn.GetStrFrom()
      if tProductName <> EMPTY then
        tResultStr = getText("purse_vouchers_furni_success") & RETURN & RETURN
        repeat while tProductName <> EMPTY
          tDescription = tConn.GetStrFrom()
          tResultStr = tResultStr & tProductName & RETURN
          tProductName = tConn.GetStrFrom()
        end repeat
        return executeMessage(#alert, [#Msg: tResultStr])
      else
        return executeMessage(#alert, [#Msg: "purse_vouchers_success"])
      end if
    213:
      me.getInterface().setVoucherInput(1)
      tDelim = the itemDelimiter
      the itemDelimiter = TAB
      tErrorCode = tMsg.content.line[1].item[1]
      the itemDelimiter = tDelim
      return executeMessage(#alert, [#Msg: "purse_vouchers_error" & tErrorCode])
  end case
end

on handle_tickets me, tMsg
  getObject(#session).set("user_ph_tickets", integer(tMsg.content.word[1]))
  me.getInterface().updatePurseTickets()
  return 1
end

on handle_ticketsbuy me, tMsg
  getObject(#session).set("user_ph_tickets", integer(tMsg.content.word[1]))
  me.getInterface().updatePurseTickets()
  return 1
end

on handle_notickets me, tMsg
  executeMessage(#show_ticketWindow)
  return 1
end

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(6, #handle_purse)
  tMsgs.setaProp(209, #handle_purse)
  tMsgs.setaProp(212, #handle_purse)
  tMsgs.setaProp(213, #handle_purse)
  tMsgs.setaProp(72, #handle_tickets)
  tMsgs.setaProp(73, #handle_notickets)
  tMsgs.setaProp(124, #handle_ticketsbuy)
  tCmds = [:]
  tCmds.setaProp("GET_CREDITS", 8)
  tCmds.setaProp("GETUSERCREDITLOG", 127)
  tCmds.setaProp("REDEEM_VOUCHER", 129)
  if tBool then
    registerListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id", #info), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id", #info), me.getID(), tCmds)
  end if
  return 1
end

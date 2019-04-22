on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on handle_purse me, tMsg 
  if tMsg.subject = 6 then
    tPlaySnd = getObject(#session).exists("user_walletbalance")
    tCredits = integer(getLocalFloat(tMsg.getProp(#word, 1)))
    getObject(#session).set("user_walletbalance", tCredits)
    me.getInterface().updatePurseSaldo()
    executeMessage(#updateCreditCount, tCredits)
    if tPlaySnd then
      puppetSound(3, getmemnum("naw_snd_cash"))
    end if
    return(1)
  else
    if tMsg.subject = 209 then
      tPages = [[]]
      tPageNum = 1
      tDelim = the itemDelimiter
      the itemDelimiter = "\t"
      i = tMsg.count(#line) - 1
      repeat while i >= 1
        tLine = tMsg.getProp(#line, i)
        if tLine = "" then
        else
          tList = [:]
          tList.setAt("date", tLine.getProp(#item, 1))
          tList.setAt("time", tLine.getProp(#item, 2))
          tList.setAt("credit_value", tLine.getProp(#item, 3))
          tList.setAt("real_value", tLine.getProp(#item, 4))
          tList.setAt("currency", tLine.getProp(#item, 5))
          tList.setAt("transaction_system_name", tLine.getProp(#item, 6))
          tPages.getAt(tPageNum).add(tList)
          if count(tPages.getAt(tPageNum)) = 10 then
            tPageNum = tPageNum + 1
            tPages.add([])
          end if
          i = 255 + i
        end if
      end repeat
      me.getInterface().dataReceived()
      if count(tPages.getAt(count(tPages))) = 0 then
        tPages.deleteAt(count(tPages))
      end if
      if count(tPages) > 0 then
        getObject(#session).set("purse_transactions", 1)
        return(me.getInterface().showPages(tPages))
      else
        getObject(#session).set("purse_transactions", 0)
        return(me.getInterface().showPages())
      end if
    else
      if tMsg.subject = 212 then
        me.getInterface().hideVoucherWindow()
        me.getInterface().setVoucherInput(1)
        tConn = tMsg.connection
        if tConn = void() then
          return(1)
        end if
        tProductName = tConn.GetStrFrom()
        if tProductName <> "" then
          tResultStr = getText("purse_vouchers_furni_success") & "\r" & "\r"
          repeat while tProductName <> ""
            tDescription = tConn.GetStrFrom()
            tResultStr = tResultStr & tProductName & "\r"
            tProductName = tConn.GetStrFrom()
          end repeat
          return(executeMessage(#alert, [#Msg:tResultStr]))
        else
          return(executeMessage(#alert, [#Msg:"purse_vouchers_success"]))
        end if
      else
        if tMsg.subject = 213 then
          me.getInterface().setVoucherInput(1)
          tDelim = the itemDelimiter
          the itemDelimiter = "\t"
          tErrorCode = tMsg.getPropRef(#line, 1).getProp(#item, 1)
          the itemDelimiter = tDelim
          return(executeMessage(#alert, [#Msg:"purse_vouchers_error" & tErrorCode]))
        end if
      end if
    end if
  end if
end

on handle_tickets me, tMsg 
  getObject(#session).set("user_ph_tickets", integer(tMsg.getProp(#word, 1)))
  me.getInterface().updatePurseTickets()
  return(1)
end

on handle_ticketsbuy me, tMsg 
  getObject(#session).set("user_ph_tickets", integer(tMsg.getProp(#word, 1)))
  me.getInterface().updatePurseTickets()
  return(1)
end

on handle_notickets me, tMsg 
  executeMessage(#show_ticketWindow)
  return(1)
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
  return(1)
end

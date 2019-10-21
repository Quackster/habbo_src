on construct(me)
  registerMessage(#show_purse, me.getID(), #showPurse)
  registerMessage(#hide_purse, me.getID(), #hidePurse)
  registerMessage(#show_hide_purse, me.getID(), #showHidePurse)
  registerMessage(#enterRoom, me.getID(), #hidePurse)
  registerMessage(#leaveRoom, me.getID(), #hidePurse)
  registerMessage(#changeRoom, me.getID(), #hidePurse)
  return(1)
  exit
end

on deconstruct(me)
  unregisterMessage(#show_purse, me.getID())
  unregisterMessage(#hide_purse, me.getID())
  unregisterMessage(#show_hide_purse, me.getID())
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  return(1)
  exit
end

on sendVoucherCode(me, tCode)
  getConnection(getVariable("connection.info.id")).send("REDEEM_VOUCHER", [#string:tCode])
  return(1)
  exit
end

on showPurse(me)
  return(me.getInterface().showPurse())
  exit
end

on hidePurse(me)
  return(me.getInterface().hidePurse())
  exit
end

on showHidePurse(me)
  return(me.getInterface().showHidePurse(#hide))
  exit
end
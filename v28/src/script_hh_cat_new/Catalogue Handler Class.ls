on construct me 
  me.regMsgList(1)
end

on deconstruct me 
  me.regMsgList(0)
end

on requestPage me, tPageID 
  getConnection(getVariable("connection.info.id", #info)).send("GET_CATALOG_PAGE", [#integer:tPageID])
end

on requestCatalogIndex me 
  getConnection(getVariable("connection.info.id", #info)).send("GET_CATALOG_INDEX")
end

on sendPurchaseFromCatalog me, tPageID, tOfferCode, tExtraParam, tAsGift, tGiftReceiver, tGiftMessage 
  tMsg = [:]
  tMsg.addProp(#integer, tPageID)
  tMsg.addProp(#integer, tOfferCode)
  tMsg.addProp(#string, string(tExtraParam))
  tMsg.addProp(#integer, tAsGift)
  if tAsGift then
    tMsg.addProp(#string, tGiftReceiver)
    tMsg.addProp(#string, tGiftMessage)
  end if
  getConnection(getVariable("connection.info.id", #info)).send("PURCHASE_FROM_CATALOG", tMsg)
end

on sendPurchaseAndWear me, tPageID, tOfferCode 
  tMsg = [:]
  tMsg.addProp(#integer, tPageID)
  tMsg.addProp(#integer, tOfferCode)
  getConnection(getVariable("connection.info.id", #info)).send("PURCHASE_AND_WEAR", tMsg)
end

on sendRedeemVoucher me, tCode 
  tMsg = [:]
  tMsg.addProp(#string, tCode)
  getConnection(getVariable("connection.info.id", #info)).send("REDEEM_VOUCHER", tMsg)
end

on parseIndexNode me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tNodeProps = [:]
  tNodeProps.setAt(#navigateable, tConn.GetIntFrom())
  tNodeProps.setAt(#color, tConn.GetIntFrom())
  tNodeProps.setAt(#icon, tConn.GetIntFrom())
  tNodeProps.setAt(#pageid, tConn.GetIntFrom())
  tNodeProps.setAt(#nodename, tConn.GetStrFrom())
  tSubnodeCount = tConn.GetIntFrom()
  if tSubnodeCount > 0 then
    tNodeProps.setAt(#subnodes, [])
    i = 1
    repeat while i <= tSubnodeCount
      tNodeProps.getAt(#subnodes).add(me.parseIndexNode(tMsg))
      i = (1 + i)
    end repeat
  end if
  return(tNodeProps)
end

on parseProductData me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tProductData = [:]
  tProductData.setAt(#type, tConn.GetStrFrom())
  tProductData.setAt(#classID, tConn.GetIntFrom())
  tProductData.setAt(#extra_param, tConn.GetStrFrom())
  tProductData.setAt(#productcount, tConn.GetIntFrom())
  tProductData.setAt(#expiration, tConn.GetIntFrom())
  return(tProductData)
end

on parseOffer me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tOfferData = [:]
  tOfferData.setAt(#offercode, tConn.GetIntFrom())
  tOfferData.setAt(#offername, tConn.GetStrFrom())
  tOfferData.setAt(#price, [:])
  tOfferData.getAt(#price).setAt(#credits, tConn.GetIntFrom())
  tOfferData.getAt(#price).setAt(#pixels, tConn.GetIntFrom())
  tOfferData.setAt(#content, [])
  tProductCount = tConn.GetIntFrom()
  if tProductCount > 0 then
    i = 1
    repeat while i <= tProductCount
      tOfferData.getAt(#content).add(me.parseProductData(tMsg))
      i = (1 + i)
    end repeat
  end if
  return(tOfferData)
end

on handle_catalogindex me, tMsg 
  tNodes = me.parseIndexNode(tMsg)
  me.getComponent().updateCatalogIndex(tNodes)
end

on handle_catalogpage me, tMsg 
  tConn = tMsg.getaProp(#connection)
  tPageData = [:]
  tPageData.setAt(#pageid, tConn.GetIntFrom())
  tPageData.setAt(#layout, tConn.GetStrFrom())
  tPageData.setAt(#localization, [#images:[], #texts:[]])
  tImageCount = tConn.GetIntFrom()
  i = 1
  repeat while i <= tImageCount
    tPageData.getAt(#localization).getAt(#images).add(tConn.GetStrFrom())
    i = (1 + i)
  end repeat
  tTextCount = tConn.GetIntFrom()
  i = 1
  repeat while i <= tTextCount
    tText = decodeUTF8(tConn.GetStrFrom())
    tText = replaceChunks(tText, "\\n", "\r")
    tPageData.getAt(#localization).getAt(#texts).add(tText)
    i = (1 + i)
  end repeat
  tOfferCount = tConn.GetIntFrom()
  tPageData.setAt(#offers, [])
  i = 1
  repeat while i <= tOfferCount
    tPageData.getAt(#offers).add(me.parseOffer(tMsg))
    i = (1 + i)
  end repeat
  me.getComponent().updatePageData(tPageData.getAt(#pageid), tPageData)
end

on handle_purchasenotallowed me, tMsg 
  if voidp(tMsg.connection) then
    return FALSE
  end if
  tCode = tMsg.connection.GetIntFrom(tMsg)
  if (tCode = 0) then
  else
    if (tCode = 1) then
      return(executeMessage(#alert, [#Msg:"catalog_purchase_not_allowed_hc", #modal:1]))
    end if
  end if
  return FALSE
end

on handle_purse me, tMsg 
  tPlaySnd = getObject(#session).exists("user_walletbalance")
  tCredits = integer(getLocalFloat(tMsg.content.getProp(#word, 1)))
  getObject(#session).set("user_walletbalance", tCredits)
  me.getInterface().updatePurseSaldo()
  executeMessage(#updateCreditCount, tCredits)
  if tPlaySnd then
    playSound("naw_snd_cash_cat", #cut, [#loopCount:1, #infiniteloop:0, #volume:255])
  end if
  return TRUE
end

on handle_purchase_error me, tMsg 
  error(me, "Purchase error:" && tMsg, #purchaseReady, #major)
end

on handle_purchase_ok me, tMsg 
  me.getInterface().showPurchaseOk()
end

on handle_purchase_nobalance me, tMsg 
  tNotEnoughCredits = tMsg.connection.GetIntFrom()
  tNotEnoughPixels = tMsg.connection.GetIntFrom()
  me.getInterface().showNoBalance(tNotEnoughCredits, tNotEnoughPixels)
end

on handle_tickets me, tMsg 
  tNum = integer(tMsg.content.getPropRef(#line, 1).getProp(#word, 1))
  if not integerp(tNum) then
    return FALSE
  end if
  getObject(#session).set("user_ph_tickets", tNum)
  executeMessage(#updateTicketCount, tNum)
  return TRUE
end

on handle_voucher_redeem_ok me, tMsg 
  tProductName = tMsg.connection.GetStrFrom()
  tProductDesc = tMsg.connection.GetStrFrom()
  me.getInterface().showVoucherRedeemOk(tProductName, tProductDesc)
end

on handle_voucher_redeem_error me, tMsg 
  tError = tMsg.connection.GetStrFrom()
  me.getInterface().showVoucherRedeemError(tError)
end

on handle_refresh_catalogue me, tMsg 
  me.getComponent().refreshCatalogue()
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(6, #handle_purse)
  tMsgs.setaProp(65, #handle_purchase_error)
  tMsgs.setaProp(67, #handle_purchase_ok)
  tMsgs.setaProp(68, #handle_purchase_nobalance)
  tMsgs.setaProp(72, #handle_tickets)
  tMsgs.setaProp(124, #handle_tickets)
  tMsgs.setaProp(126, #handle_catalogindex)
  tMsgs.setaProp(127, #handle_catalogpage)
  tMsgs.setaProp(296, #handle_purchasenotallowed)
  tMsgs.setaProp(212, #handle_voucher_redeem_ok)
  tMsgs.setaProp(213, #handle_voucher_redeem_error)
  tMsgs.setaProp(441, #handle_refresh_catalogue)
  tCmds = [:]
  tCmds.setaProp("PURCHASE_FROM_CATALOG", 100)
  tCmds.setaProp("GET_CATALOG_INDEX", 101)
  tCmds.setaProp("GET_CATALOG_PAGE", 102)
  tCmds.setaProp("REDEEM_VOUCHER", 129)
  tCmds.setaProp("PURCHASE_AND_WEAR", 374)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return TRUE
end

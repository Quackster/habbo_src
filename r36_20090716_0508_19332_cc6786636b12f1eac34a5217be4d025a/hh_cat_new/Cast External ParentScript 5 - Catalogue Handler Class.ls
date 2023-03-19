on construct me
  me.regMsgList(1)
end

on deconstruct me
  me.regMsgList(0)
end

on requestPage me, tPageID
  getConnection(getVariable("connection.info.id", #Info)).send("GET_CATALOG_PAGE", [#integer: tPageID])
end

on requestCatalogIndex me
  getConnection(getVariable("connection.info.id", #Info)).send("GET_CATALOG_INDEX")
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
  getConnection(getVariable("connection.info.id", #Info)).send("PURCHASE_FROM_CATALOG", tMsg)
end

on sendPurchaseAndWear me, tPageID, tOfferCode
  tMsg = [:]
  tMsg.addProp(#integer, tPageID)
  tMsg.addProp(#integer, tOfferCode)
  getConnection(getVariable("connection.info.id", #Info)).send("PURCHASE_AND_WEAR", tMsg)
end

on sendRedeemVoucher me, tCode
  tMsg = [:]
  tMsg.addProp(#string, tCode)
  getConnection(getVariable("connection.info.id", #Info)).send("REDEEM_VOUCHER", tMsg)
end

on parseIndexNode me, tMsg
  tConn = tMsg.getaProp(#connection)
  tNodeProps = [:]
  tNodeProps[#navigateable] = tConn.GetIntFrom()
  tNodeProps[#color] = tConn.GetIntFrom()
  tNodeProps[#icon] = tConn.GetIntFrom()
  tNodeProps[#pageid] = tConn.GetIntFrom()
  tNodeProps[#nodename] = tConn.GetStrFrom()
  tDisabled = tConn.GetIntFrom()
  tSubnodeCount = tConn.GetIntFrom()
  if tSubnodeCount > 0 then
    tNodeProps[#subnodes] = []
    repeat with i = 1 to tSubnodeCount
      tNodeProps[#subnodes].add(me.parseIndexNode(tMsg))
    end repeat
  end if
  return tNodeProps
end

on parseProductData me, tMsg
  tConn = tMsg.getaProp(#connection)
  tProductData = [:]
  tProductData[#type] = tConn.GetStrFrom()
  tProductData[#classID] = tConn.GetIntFrom()
  tProductData[#extra_param] = tConn.GetStrFrom()
  tProductData[#productcount] = tConn.GetIntFrom()
  tProductData[#expiration] = tConn.GetIntFrom()
  return tProductData
end

on parseOffer me, tMsg
  tConn = tMsg.getaProp(#connection)
  tOfferData = [:]
  tOfferData[#offercode] = tConn.GetIntFrom()
  tOfferData[#offername] = tConn.GetStrFrom()
  tOfferData[#price] = [:]
  tOfferData[#price][#credits] = tConn.GetIntFrom()
  tOfferData[#price][#pixels] = tConn.GetIntFrom()
  tOfferData[#content] = []
  tProductCount = tConn.GetIntFrom()
  if tProductCount > 0 then
    repeat with i = 1 to tProductCount
      tOfferData[#content].add(me.parseProductData(tMsg))
    end repeat
  end if
  return tOfferData
end

on handle_catalogindex me, tMsg
  tNodes = me.parseIndexNode(tMsg)
  me.getComponent().updateCatalogIndex(tNodes)
end

on handle_catalogpage me, tMsg
  sendProcessTracking(500)
  tConn = tMsg.getaProp(#connection)
  tPageData = [:]
  tPageData[#pageid] = tConn.GetIntFrom()
  tPageData[#layout] = tConn.GetStrFrom()
  tPageData[#localization] = [#images: [], #texts: []]
  tImageCount = tConn.GetIntFrom()
  repeat with i = 1 to tImageCount
    tPageData[#localization][#images].add(tConn.GetStrFrom())
  end repeat
  tTextCount = tConn.GetIntFrom()
  repeat with i = 1 to tTextCount
    tText = tConn.GetStrFrom()
    tText = replaceChunks(tText, "\n", RETURN)
    tPageData[#localization][#texts].add(tText)
  end repeat
  tOfferCount = tConn.GetIntFrom()
  sendProcessTracking(501)
  tPageData[#offers] = []
  repeat with i = 1 to tOfferCount
    tPageData[#offers].add(me.parseOffer(tMsg))
  end repeat
  sendProcessTracking(502)
  me.getComponent().updatePageData(tPageData[#pageid], tPageData)
  sendProcessTracking(599)
end

on handle_purchasenotallowed me, tMsg
  if voidp(tMsg.connection) then
    return 0
  end if
  tCode = tMsg.connection.GetIntFrom(tMsg)
  case tCode of
    0:
    1:
      return executeMessage(#alert, [#Msg: "catalog_purchase_not_allowed_hc", #modal: 1])
  end case
  return 0
end

on handle_purse me, tMsg
  tPlaySnd = getObject(#session).exists("user_walletbalance")
  tCredits = integer(getLocalFloat(tMsg.content.word[1]))
  getObject(#session).set("user_walletbalance", tCredits)
  me.getInterface().updatePurseSaldo()
  executeMessage(#updateCreditCount, tCredits)
  if tPlaySnd then
    playSound("naw_snd_cash_cat", #cut, [#loopCount: 1, #infiniteloop: 0, #volume: 255])
  end if
  return 1
end

on handle_purchase_error me, tMsg
  error(me, "Purchase error.", #handle_purchase_error, #major)
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
  tNum = tMsg.connection.GetIntFrom()
  getObject(#session).set("user_ph_tickets", tNum)
  executeMessage(#updateTicketCount, tNum)
  return 1
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

on handle_recycler_prizes me, tMsg
  tConn = tMsg.getaProp(#connection)
  if not tConn then
    return 0
  end if
  tPrizes = [:]
  tCategoryCount = tConn.GetIntFrom()
  repeat with i = 1 to tCategoryCount
    tCategoryData = [:]
    tCategoryId = tConn.GetIntFrom()
    tCategoryOdds = tConn.GetIntFrom()
    tFurniCount = tConn.GetIntFrom()
    tFurniList = []
    repeat with j = 1 to tFurniCount
      tFurniType = tConn.GetStrFrom()
      tFurniID = tConn.GetIntFrom()
      tFurniList.add([tFurniType, tFurniID])
    end repeat
    tCategoryData.setaProp(#id, tCategoryId)
    tCategoryData.setaProp(#odds, tCategoryOdds)
    tCategoryData.setaProp(#furniList, tFurniList)
    tPrizes.setaProp(tCategoryId, tCategoryData)
  end repeat
  executeMessage(#recyclerPrizesReceived, tPrizes)
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
  tMsgs.setaProp(506, #handle_recycler_prizes)
  tCmds = [:]
  tCmds.setaProp("PURCHASE_FROM_CATALOG", 100)
  tCmds.setaProp("GET_CATALOG_INDEX", 101)
  tCmds.setaProp("GET_CATALOG_PAGE", 102)
  tCmds.setaProp("REDEEM_VOUCHER", 129)
  tCmds.setaProp("PURCHASE_AND_WEAR", 374)
  tCmds.setaProp("GET_RECYCLER_PRIZES", 412)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return 1
end

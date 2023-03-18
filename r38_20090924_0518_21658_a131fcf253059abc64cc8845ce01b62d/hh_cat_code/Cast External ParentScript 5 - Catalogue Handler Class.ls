property pPersistentFurniData, pPersistentCatalogData

on construct me
  pPersistentFurniData = VOID
  pPersistentCatalogData = VOID
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_purchase_ok me, tMsg
  me.getComponent().purchaseReady("OK")
end

on handle_purchase_error me, tMsg
  me.getComponent().purchaseReady("ERROR", tMsg.getaProp(#content))
end

on handle_purchase_nobalance me, tMsg
  me.getComponent().purchaseReady("NOBALANCE", tMsg.getaProp(#content))
end

on handle_tickets me, tMsg
  tNum = integer(tMsg.content.line[1].word[1])
  if not integerp(tNum) then
    return 0
  end if
  getObject(#session).set("user_ph_tickets", tNum)
  executeMessage(#updateTicketCount, tNum)
  return 1
end

on handle_catalogindex me, tMsg
  tCount = tMsg.content.line.count
  tDelim = the itemDelimiter
  tList = [:]
  the itemDelimiter = TAB
  repeat with tLineNum = 1 to tCount
    tLine = tMsg.content.line[tLineNum]
    if tLine.char.count > 3 then
      tProp = tLine.item[1]
      tdata = tLine.item[2..tLine.item.count]
      tList[tProp] = tdata
    end if
  end repeat
  the itemDelimiter = tDelim
  me.getComponent().saveCatalogueIndex(tList)
end

on handle_catalogpage me, tMsg
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
  if voidp(pPersistentCatalogData) then
    pPersistentCatalogData = me.getComponent().getPersistentCatalogDataObject()
  end if
  tCount = tMsg.content.line.count
  tDelim = the itemDelimiter
  tList = [:]
  tProductList = []
  tTextList = [:]
  tTextList.sort()
  tDealNumber = 1
  repeat with tLineNum = 1 to tCount
    the itemDelimiter = ":"
    tLine = tMsg.content.line[tLineNum]
    tProp = tLine.char[1]
    tNum = integer(tLine.item[1].char[2..tLine.item[1].length])
    tdata = tLine.item[2..tLine.item.count]
    case tProp of
      "i":
        tList["id"] = tdata
      "n":
        tList["pageName"] = tdata
      "l":
        tList["layout"] = tdata
      "h":
        tList["headerText"] = replaceChunks(tdata, "<br>", RETURN)
      "g":
        tList["headerImage"] = tdata
      "w":
        tList["teaserText"] = replaceChunks(tdata, "<br>", RETURN)
      "e":
        the itemDelimiter = ","
        tTempList = []
        repeat with f = 1 to tdata.item.count
          if tdata.item[f].length > 0 then
            tTempList.add(tdata.item[f])
          end if
        end repeat
        if tTempList.count > 0 then
          tList["teaserImgList"] = tTempList
        end if
      "s":
        tList["teaserSpecialText"] = replaceChunks(tdata, "<br>", RETURN)
      "t":
        if not voidp(tNum) then
          tTextList.addProp(tNum, replaceChunks(tdata, "<br>", RETURN))
        end if
      "u":
        the itemDelimiter = ","
        tTempList = []
        repeat with f = 1 to tdata.item.count
          tTempList.add(tdata.item[f])
        end repeat
        tList["linkList"] = tTempList
      "p":
        the itemDelimiter = TAB
        tTemp = [:]
        tCode = tdata.item[1]
        tTemp["price"] = tdata.item[2]
        ttype = tdata.item[3]
        tClassID = value(tdata.item[4])
        tTemp["purchaseCode"] = tCode
        tCatalogProps = pPersistentCatalogData.getProps(tCode)
        if voidp(tCatalogProps) then
          error(me, "Persistent catalog data missing for " & tCode, #handle_catalogpage, #major)
          tTemp["name"] = EMPTY
        else
          tTemp["name"] = tCatalogProps[#name]
          tTemp["description"] = tCatalogProps[#description]
          tTemp["specialText"] = tCatalogProps[#specialText]
        end if
        tFurniProps = pPersistentFurniData.getProps(ttype, tClassID)
        if voidp(tFurniProps) then
          error(me, "Persistent furnidata missing for classid " & tClassID & " type " & ttype, #handle_catalogpage, #major)
          tTemp["class"] = EMPTY
        else
          tTemp["class"] = tFurniProps[#class]
          tTemp["objectType"] = tFurniProps[#type]
          tTemp["direction"] = tFurniProps[#defaultDir]
          tTemp["dimensions"] = tFurniProps[#xdim] & "," & tFurniProps[#ydim]
          tTemp["partColors"] = tFurniProps[#partColors]
        end if
        if tdata.item[4] contains SPACE then
          tTemp["class"] = tTemp["class"] & chars(tdata.item[4], offset(SPACE, tdata.item[4]), tdata.item[4].length)
        end if
        tThisFurniCount = value(tdata.item[5])
        if (tThisFurniCount > 1) or (tdata.item.count > 5) then
          tDealList = []
          tDealItem = [:]
          tDealItem["class"] = tTemp["class"]
          tDealItem["count"] = tThisFurniCount
          tDealItem["partColors"] = tTemp["partColors"]
          tDealList[1] = tDealItem.duplicate()
          tTemp["dealList"] = tDealList
          tTemp["dealNumber"] = 0
          tTemp["class"] = EMPTY
        end if
        if tdata.item.count > 5 then
          tTemp["class"] = EMPTY
          tDealList = []
          tDealItem = [:]
          repeat with i = 1 to (tdata.item.count - 5) / 3
            ttype = tdata.item[5 + ((i - 1) * 3) + 1]
            tClassID = value(tdata.item[5 + ((i - 1) * 3) + 2])
            tFurniProps = pPersistentFurniData.getProps(ttype, tClassID)
            if voidp(tFurniProps) then
              error(me, "Persistent furnidata missing for classid " & tClassID & " type " & ttype, #handle_catalogpage, #major)
              tTemp["class"] = EMPTY
              next repeat
            end if
            tDealItem["class"] = tFurniProps[#class]
            tDealItem["count"] = tdata.item[5 + ((i - 1) * 3) + 3]
            tDealItem["partColors"] = tFurniProps[#partColors]
            tDealList[i] = tDealItem.duplicate()
          end repeat
          if ilk(tTemp["dealList"]) <> #list then
            tTemp["dealList"] = []
          end if
          repeat with i = 1 to tDealList.count
            tTemp["dealList"].add(tDealList[i])
          end repeat
          if tDealList.count > 0 then
            tTemp["dealNumber"] = tDealNumber
            tDealNumber = tDealNumber + 1
          else
            tTemp["dealNumber"] = 0
          end if
        end if
        tProductList.add(tTemp)
    end case
  end repeat
  tTempTextList = []
  repeat with tText in tTextList
    tTempTextList.add(tText)
  end repeat
  tList["textList"] = tTempTextList
  tList["productList"] = tProductList
  the itemDelimiter = tDelim
  me.getComponent().saveCataloguePage(tList)
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
  tCmds = [:]
  tCmds.setaProp("PURCHASE_FROM_CATALOG", 100)
  tCmds.setaProp("GCIX", 101)
  tCmds.setaProp("GCAP", 102)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return 1
end

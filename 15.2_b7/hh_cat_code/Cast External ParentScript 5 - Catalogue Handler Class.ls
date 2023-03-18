on construct me
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
        tTemp["name"] = tdata.item[1]
        tTemp["description"] = tdata.item[2]
        tTemp["price"] = tdata.item[3]
        tTemp["specialText"] = tdata.item[4]
        tTemp["objectType"] = tdata.item[5]
        tTemp["class"] = tdata.item[6]
        tTemp["direction"] = tdata.item[7]
        tTemp["dimensions"] = tdata.item[8]
        tTemp["purchaseCode"] = tdata.item[9]
        tTemp["partColors"] = tdata.item[10]
        if tdata.item.count > 10 then
          tItemCount = tdata.item[11]
          if tdata.item.count >= (11 + (tItemCount * 3)) then
            tDealList = []
            tDealItem = [:]
            repeat with i = 0 to tItemCount - 1
              tDealItem["class"] = tdata.item[11 + (i * 3) + 1]
              tDealItem["count"] = tdata.item[11 + (i * 3) + 2]
              tDealItem["partColors"] = tdata.item[11 + (i * 3) + 3]
              tDealList[i + 1] = tDealItem.duplicate()
            end repeat
            tTemp["dealList"] = tDealList
            if tDealList.count > 1 then
              tTemp["dealNumber"] = tDealNumber
              tDealNumber = tDealNumber + 1
            else
              tTemp["dealNumber"] = 0
            end if
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

on regMsgList me, tBool
  tMsgs = [:]
  tMsgs.setaProp(67, #handle_purchase_ok)
  tMsgs.setaProp(65, #handle_purchase_error)
  tMsgs.setaProp(68, #handle_purchase_nobalance)
  tMsgs.setaProp(126, #handle_catalogindex)
  tMsgs.setaProp(127, #handle_catalogpage)
  tMsgs.setaProp(296, #handle_purchasenotallowed)
  tCmds = [:]
  tCmds.setaProp("GPRC", 100)
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

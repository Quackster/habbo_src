on construct me
  return me.regMsgList(1)
end

on deconstruct me
  unregisterMessage(#GETCATALOGPAG, me.getID())
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

on handle_orderinfo me, tMsg
  tProps = [:]
  tProps[#code] = tMsg.message.line[2]
  tProps[#price] = tMsg.message.line[3]
  tProps[#class] = tMsg.message.line[4]
  tName = tMsg.message.line[5]
  if textExists("obj_name:" && tName) then
    tProps[#name] = getText("obj_name:" && tName)
  else
    tProps[#name] = tName
  end if
  me.getComponent().redirectOrderInfo("OK", tProps)
end

on handle_orderinfo_error me, tMsg
  me.getComponent().redirectOrderInfo("ERROR", tMsg.getaProp(#content))
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

on regMsgList me, tBool
  tList = [:]
  tList["PURCHASE_OK"] = #handle_purchase_ok
  tList["PURCHASE_ERROR"] = #handle_purchase_error
  tList["PURCHASE_NOBALANCE"] = #handle_purchase_nobalance
  tList["ORDERINFO"] = #handle_orderinfo
  tList["ORDERINFO_ERROR"] = #handle_orderinfo_error
  tList["C_I"] = #handle_catalogindex
  tList["C_P"] = #handle_catalogpage
  if tBool then
    return registerListener(getVariable("connection.info.id"), me.getID(), tList)
  else
    return unregisterListener(getVariable("connection.info.id"), me.getID(), tList)
  end if
end

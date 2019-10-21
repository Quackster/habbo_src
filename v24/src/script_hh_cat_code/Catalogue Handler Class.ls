on construct(me)
  return(me.regMsgList(1))
  exit
end

on deconstruct(me)
  return(me.regMsgList(0))
  exit
end

on handle_purchase_ok(me, tMsg)
  me.getComponent().purchaseReady("OK")
  exit
end

on handle_purchase_error(me, tMsg)
  me.getComponent().purchaseReady("ERROR", tMsg.getaProp(#content))
  exit
end

on handle_purchase_nobalance(me, tMsg)
  me.getComponent().purchaseReady("NOBALANCE", tMsg.getaProp(#content))
  exit
end

on handle_catalogindex(me, tMsg)
  tCount = tMsg.count(#line)
  tDelim = the itemDelimiter
  tList = []
  the itemDelimiter = "\t"
  tLineNum = 1
  repeat while tLineNum <= tCount
    tLine = tMsg.getProp(#line, tLineNum)
    if tLine.count(#char) > 3 then
      tProp = tLine.getProp(#item, 1)
      tdata = tLine.getProp(#item, 2, tLine.count(#item))
      tList.setAt(tProp, tdata)
    end if
    tLineNum = 1 + tLineNum
  end repeat
  the itemDelimiter = tDelim
  me.getComponent().saveCatalogueIndex(tList)
  exit
end

on handle_catalogpage(me, tMsg)
  tCount = tMsg.count(#line)
  tDelim = the itemDelimiter
  tList = []
  tProductList = []
  tTextList = []
  tTextList.sort()
  tDealNumber = 1
  tLineNum = 1
  repeat while tLineNum <= tCount
    the itemDelimiter = ":"
    tLine = tMsg.getProp(#line, tLineNum)
    tProp = tLine.getProp(#char, 1)
    tNum = integer(tLine.getPropRef(#item, 1).getProp(#char, 2, tLine.getPropRef(#item, 1).length))
    tdata = tLine.getProp(#item, 2, tLine.count(#item))
    if me = "i" then
      tList.setAt("id", tdata)
    else
      if me = "n" then
        tList.setAt("pageName", tdata)
      else
        if me = "l" then
          tList.setAt("layout", tdata)
        else
          if me = "h" then
            tList.setAt("headerText", replaceChunks(tdata, "<br>", "\r"))
          else
            if me = "g" then
              tList.setAt("headerImage", tdata)
            else
              if me = "w" then
                tList.setAt("teaserText", replaceChunks(tdata, "<br>", "\r"))
              else
                if me = "e" then
                  the itemDelimiter = ","
                  tTempList = []
                  f = 1
                  repeat while f <= tdata.count(#item)
                    if tdata.getPropRef(#item, f).length > 0 then
                      tTempList.add(tdata.getProp(#item, f))
                    end if
                    f = 1 + f
                  end repeat
                  if tTempList.count > 0 then
                    tList.setAt("teaserImgList", tTempList)
                  end if
                else
                  if me = "s" then
                    tList.setAt("teaserSpecialText", replaceChunks(tdata, "<br>", "\r"))
                  else
                    if me = "t" then
                      if not voidp(tNum) then
                        tTextList.addProp(tNum, replaceChunks(tdata, "<br>", "\r"))
                      end if
                    else
                      if me = "u" then
                        the itemDelimiter = ","
                        tTempList = []
                        f = 1
                        repeat while f <= tdata.count(#item)
                          tTempList.add(tdata.getProp(#item, f))
                          f = 1 + f
                        end repeat
                        tList.setAt("linkList", tTempList)
                      else
                        if me = "p" then
                          the itemDelimiter = "\t"
                          tTemp = []
                          tTemp.setAt("name", tdata.getProp(#item, 1))
                          tTemp.setAt("description", tdata.getProp(#item, 2))
                          tTemp.setAt("price", tdata.getProp(#item, 3))
                          tTemp.setAt("specialText", tdata.getProp(#item, 4))
                          tTemp.setAt("objectType", tdata.getProp(#item, 5))
                          tTemp.setAt("class", tdata.getProp(#item, 6))
                          tTemp.setAt("direction", tdata.getProp(#item, 7))
                          tTemp.setAt("dimensions", tdata.getProp(#item, 8))
                          tTemp.setAt("purchaseCode", tdata.getProp(#item, 9))
                          tTemp.setAt("partColors", tdata.getProp(#item, 10))
                          if tdata.count(#item) > 10 then
                            tItemCount = tdata.getProp(#item, 11)
                            if tdata.count(#item) >= 11 + tItemCount * 3 then
                              tDealList = []
                              tDealItem = []
                              i = 0
                              repeat while i <= tItemCount - 1
                                tDealItem.setAt("class", tdata.getProp(#item, 11 + i * 3 + 1))
                                tDealItem.setAt("count", tdata.getProp(#item, 11 + i * 3 + 2))
                                tDealItem.setAt("partColors", tdata.getProp(#item, 11 + i * 3 + 3))
                                tDealList.setAt(i + 1, tDealItem.duplicate())
                                i = 1 + i
                              end repeat
                              tTemp.setAt("dealList", tDealList)
                              if tDealList.count > 1 then
                                tTemp.setAt("dealNumber", tDealNumber)
                                tDealNumber = tDealNumber + 1
                              else
                                tTemp.setAt("dealNumber", 0)
                              end if
                            end if
                          end if
                          tProductList.add(tTemp)
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
    tLineNum = 1 + tLineNum
  end repeat
  tTempTextList = []
  repeat while me <= undefined
    tText = getAt(undefined, tMsg)
    tTempTextList.add(tText)
  end repeat
  tList.setAt("textList", tTempTextList)
  tList.setAt("productList", tProductList)
  the itemDelimiter = tDelim
  me.getComponent().saveCataloguePage(tList)
  exit
end

on handle_purchasenotallowed(me, tMsg)
  if voidp(tMsg.connection) then
    return(0)
  end if
  tCode = tMsg.GetIntFrom(tMsg)
  if me = 0 then
  else
    if me = 1 then
      return(executeMessage(#alert, [#Msg:"catalog_purchase_not_allowed_hc", #modal:1]))
    end if
  end if
  return(0)
  exit
end

on handle_purse(me, tMsg)
  tPlaySnd = getObject(#session).exists("user_walletbalance")
  tCredits = integer(getLocalFloat(tMsg.getProp(#word, 1)))
  getObject(#session).set("user_walletbalance", tCredits)
  me.getInterface().updatePurseSaldo()
  executeMessage(#updateCreditCount, tCredits)
  if tPlaySnd then
    playSound("naw_snd_cash_cat", #cut, [#loopCount:1, #infiniteloop:0, #volume:255])
  end if
  return(1)
  exit
end

on regMsgList(me, tBool)
  tMsgs = []
  tMsgs.setaProp(6, #handle_purse)
  tMsgs.setaProp(67, #handle_purchase_ok)
  tMsgs.setaProp(65, #handle_purchase_error)
  tMsgs.setaProp(68, #handle_purchase_nobalance)
  tMsgs.setaProp(126, #handle_catalogindex)
  tMsgs.setaProp(127, #handle_catalogpage)
  tMsgs.setaProp(296, #handle_purchasenotallowed)
  tCmds = []
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
  return(1)
  exit
end
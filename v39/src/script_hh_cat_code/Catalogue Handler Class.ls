property pPersistentFurniData, pPersistentCatalogData

on construct me 
  pPersistentFurniData = void()
  pPersistentCatalogData = void()
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
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
  tNum = integer(tMsg.content.getPropRef(#line, 1).getProp(#word, 1))
  if not integerp(tNum) then
    return FALSE
  end if
  getObject(#session).set("user_ph_tickets", tNum)
  executeMessage(#updateTicketCount, tNum)
  return TRUE
end

on handle_catalogindex me, tMsg 
  tCount = tMsg.content.count(#line)
  tDelim = the itemDelimiter
  tList = [:]
  the itemDelimiter = "\t"
  tLineNum = 1
  repeat while tLineNum <= tCount
    tLine = tMsg.content.getProp(#line, tLineNum)
    if tLine.count(#char) > 3 then
      tProp = tLine.getProp(#item, 1)
      tdata = tLine.getProp(#item, 2, tLine.count(#item))
      tList.setAt(tProp, tdata)
    end if
    tLineNum = (1 + tLineNum)
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
  tCount = tMsg.content.count(#line)
  tDelim = the itemDelimiter
  tList = [:]
  tProductList = []
  tTextList = [:]
  tTextList.sort()
  tDealNumber = 1
  tLineNum = 1
  repeat while tLineNum <= tCount
    the itemDelimiter = ":"
    tLine = tMsg.content.getProp(#line, tLineNum)
    tProp = tLine.getProp(#char, 1)
    tNum = integer(tLine.getPropRef(#item, 1).getProp(#char, 2, tLine.getPropRef(#item, 1).length))
    tdata = tLine.getProp(#item, 2, tLine.count(#item))
    if (tProp = "i") then
      tList.setAt("id", tdata)
    else
      if (tProp = "n") then
        tList.setAt("pageName", tdata)
      else
        if (tProp = "l") then
          tList.setAt("layout", tdata)
        else
          if (tProp = "h") then
            tList.setAt("headerText", replaceChunks(tdata, "<br>", "\r"))
          else
            if (tProp = "g") then
              tList.setAt("headerImage", tdata)
            else
              if (tProp = "w") then
                tList.setAt("teaserText", replaceChunks(tdata, "<br>", "\r"))
              else
                if (tProp = "e") then
                  the itemDelimiter = ","
                  tTempList = []
                  f = 1
                  repeat while f <= tdata.count(#item)
                    if tdata.getPropRef(#item, f).length > 0 then
                      tTempList.add(tdata.getProp(#item, f))
                    end if
                    f = (1 + f)
                  end repeat
                  if tTempList.count > 0 then
                    tList.setAt("teaserImgList", tTempList)
                  end if
                else
                  if (tProp = "s") then
                    tList.setAt("teaserSpecialText", replaceChunks(tdata, "<br>", "\r"))
                  else
                    if (tProp = "t") then
                      if not voidp(tNum) then
                        tTextList.addProp(tNum, replaceChunks(tdata, "<br>", "\r"))
                      end if
                    else
                      if (tProp = "u") then
                        the itemDelimiter = ","
                        tTempList = []
                        f = 1
                        repeat while f <= tdata.count(#item)
                          tTempList.add(tdata.getProp(#item, f))
                          f = (1 + f)
                        end repeat
                        tList.setAt("linkList", tTempList)
                      else
                        if (tProp = "p") then
                          the itemDelimiter = "\t"
                          tTemp = [:]
                          tCode = tdata.getProp(#item, 1)
                          tTemp.setAt("price", tdata.getProp(#item, 2))
                          ttype = tdata.getProp(#item, 3)
                          tClassID = value(tdata.getProp(#item, 4))
                          tTemp.setAt("purchaseCode", tCode)
                          tCatalogProps = pPersistentCatalogData.getProps(tCode)
                          if voidp(tCatalogProps) then
                            error(me, "Persistent catalog data missing for " & tCode, #handle_catalogpage, #major)
                            tTemp.setAt("name", "")
                          else
                            tTemp.setAt("name", tCatalogProps.getAt(#name))
                            tTemp.setAt("description", tCatalogProps.getAt(#description))
                            tTemp.setAt("specialText", tCatalogProps.getAt(#specialText))
                          end if
                          tFurniProps = pPersistentFurniData.getProps(ttype, tClassID)
                          if voidp(tFurniProps) then
                            error(me, "Persistent furnidata missing for classid " & tClassID & " type " & ttype, #handle_catalogpage, #major)
                            tTemp.setAt("class", "")
                          else
                            tTemp.setAt("class", tFurniProps.getAt(#class))
                            tTemp.setAt("objectType", tFurniProps.getAt(#type))
                            tTemp.setAt("direction", tFurniProps.getAt(#defaultDir))
                            tTemp.setAt("dimensions", tFurniProps.getAt(#xdim) & "," & tFurniProps.getAt(#ydim))
                            tTemp.setAt("partColors", tFurniProps.getAt(#partColors))
                          end if
                          if tdata.getProp(#item, 4) contains space() then
                            tTemp.setAt("class", tTemp.getAt("class") & chars(tdata.getProp(#item, 4), offset(space(), tdata.getProp(#item, 4)), tdata.getPropRef(#item, 4).length))
                          end if
                          tThisFurniCount = value(tdata.getProp(#item, 5))
                          if tThisFurniCount > 1 or tdata.count(#item) > 5 then
                            tDealList = []
                            tDealItem = [:]
                            tDealItem.setAt("class", tTemp.getAt("class"))
                            tDealItem.setAt("count", tThisFurniCount)
                            tDealItem.setAt("partColors", tTemp.getAt("partColors"))
                            tDealList.setAt(1, tDealItem.duplicate())
                            tTemp.setAt("dealList", tDealList)
                            tTemp.setAt("dealNumber", 0)
                            tTemp.setAt("class", "")
                          end if
                          if tdata.count(#item) > 5 then
                            tTemp.setAt("class", "")
                            tDealList = []
                            tDealItem = [:]
                            i = 1
                            repeat while i <= ((tdata.count(#item) - 5) / 3)
                              ttype = tdata.getProp(#item, ((5 + ((i - 1) * 3)) + 1))
                              tClassID = value(tdata.getProp(#item, ((5 + ((i - 1) * 3)) + 2)))
                              tFurniProps = pPersistentFurniData.getProps(ttype, tClassID)
                              if voidp(tFurniProps) then
                                error(me, "Persistent furnidata missing for classid " & tClassID & " type " & ttype, #handle_catalogpage, #major)
                                tTemp.setAt("class", "")
                              else
                                tDealItem.setAt("class", tFurniProps.getAt(#class))
                                tDealItem.setAt("count", tdata.getProp(#item, ((5 + ((i - 1) * 3)) + 3)))
                                tDealItem.setAt("partColors", tFurniProps.getAt(#partColors))
                                tDealList.setAt(i, tDealItem.duplicate())
                              end if
                              i = (1 + i)
                            end repeat
                            if ilk(tTemp.getAt("dealList")) <> #list then
                              tTemp.setAt("dealList", [])
                            end if
                            i = 1
                            repeat while i <= tDealList.count
                              tTemp.getAt("dealList").add(tDealList.getAt(i))
                              i = (1 + i)
                            end repeat
                            if tDealList.count > 0 then
                              tTemp.setAt("dealNumber", tDealNumber)
                              tDealNumber = (tDealNumber + 1)
                            else
                              tTemp.setAt("dealNumber", 0)
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
    tLineNum = (1 + tLineNum)
  end repeat
  tTempTextList = []
  repeat while tProp <= undefined
    tText = getAt(undefined, tMsg)
    tTempTextList.add(tText)
  end repeat
  tList.setAt("textList", tTempTextList)
  tList.setAt("productList", tProductList)
  the itemDelimiter = tDelim
  me.getComponent().saveCataloguePage(tList)
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
  return TRUE
end

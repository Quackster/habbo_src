on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  unregisterMessage(#GETCATALOGPAG, me.getID())
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

on handle_orderinfo me, tMsg 
  tProps = [:]
  tProps.setAt(#code, tMsg.message.getProp(#line, 2))
  tProps.setAt(#price, tMsg.message.getProp(#line, 3))
  tProps.setAt(#class, tMsg.message.getProp(#line, 4))
  tName = tMsg.message.getProp(#line, 5)
  if textExists("obj_name:" && tName) then
    tProps.setAt(#name, getText("obj_name:" && tName))
  else
    tProps.setAt(#name, tName)
  end if
  me.getComponent().redirectOrderInfo("OK", tProps)
end

on handle_orderinfo_error me, tMsg 
  me.getComponent().redirectOrderInfo("ERROR", tMsg.getaProp(#content))
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
  tCount = tMsg.content.count(#line)
  tDelim = the itemDelimiter
  tList = [:]
  tProductList = []
  tTextList = [:]
  tTextList.sort()
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

on regMsgList me, tBool 
  tList = [:]
  tList.setAt("PURCHASE_OK", #handle_purchase_ok)
  tList.setAt("PURCHASE_ERROR", #handle_purchase_error)
  tList.setAt("PURCHASE_NOBALANCE", #handle_purchase_nobalance)
  tList.setAt("ORDERINFO", #handle_orderinfo)
  tList.setAt("ORDERINFO_ERROR", #handle_orderinfo_error)
  tList.setAt("C_I", #handle_catalogindex)
  tList.setAt("C_P", #handle_catalogpage)
  if tBool then
    return(registerListener(getVariable("connection.info.id"), me.getID(), tList))
  else
    return(unregisterListener(getVariable("connection.info.id"), me.getID(), tList))
  end if
end

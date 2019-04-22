property pCatalogProps, pProductOrderData, pImageLibraryURL, pLoadingProps, pLastSelectedPageID

on construct me 
  pOrderInfoList = []
  pCatalogProps = [:]
  pProductOrderData = [:]
  pLoadingProps = [:]
  pLastSelectedPageID = void()
  if variableExists("ctlg.editmode") then
    pCatalogProps.setAt("editmode", getVariable("ctlg.editmode"))
  else
    pCatalogProps.setAt("editmode", "production")
  end if
  pImageLibraryURL = getVariable("image.library.url", "http://images.habbohotel.com/c_images/")
  registerMessage(#edit_catalogue, me.getID(), #editModeOn)
  return(1)
end

on deconstruct me 
  pOrderInfoList = []
  pCatalogProps = [:]
  pLoadingProps = [:]
  unregisterMessage(#edit_catalogue, me.getID())
  return(1)
end

on editModeOn me 
  setVariable("ctlg.editmode", "develop")
  pCatalogProps.setAt("editmode", getVariable("ctlg.editmode"))
end

on getLanguage me 
  if variableExists("language") then
    tLanguage = getVariable("language")
  else
    tLanguage = "en"
  end if
  return(tLanguage)
end

on checkProductOrder me, tProductProps 
  if tProductProps.ilk <> #propList then
    return(error(me, "Incorrect SelectedProduct proplist", #checkProductOrder, #major))
  end if
  if not voidp(tProductProps.getAt("purchaseCode")) then
    tProps = [:]
    tstate = "OK"
    if not voidp(tProductProps.getAt("name")) then
      tProps.setAt(#name, tProductProps.getAt("name"))
    else
      tProps.setAt(#name, "ERROR")
      tstate = "ERROR"
    end if
    if not voidp(tProductProps.getAt("purchaseCode")) then
      tProps.setAt(#code, tProductProps.getAt("purchaseCode"))
    else
      tProps.setAt(#code, "ERROR")
      tstate = "ERROR"
    end if
    if not voidp(tProductProps.getAt("price")) then
      tProps.setAt(#price, tProductProps.getAt("price"))
    else
      tProps.setAt(#price, "ERROR")
      tstate = "ERROR"
    end if
    pProductOrderData = tProductProps.duplicate()
    me.getInterface().showOrderInfo(tstate, tProps)
    return(1)
  else
    pProductOrderData = [:]
    return(0)
  end if
end

on purchaseProduct me, tGiftProps 
  if pProductOrderData.ilk <> #propList then
    return(error(me, "Incorrect Product data", #purchaseProduct, #major))
  end if
  if tGiftProps.ilk <> #propList then
    return(error(me, "Incorrect Gift Props", #purchaseProduct, #major))
  end if
  if voidp(pProductOrderData.getAt("name")) then
    return(error(me, "Product name not found", #purchaseProduct, #major))
  end if
  if voidp(pProductOrderData.getAt("purchaseCode")) then
    return(error(me, "PurchaseCode name not found", #purchaseProduct, #major))
  end if
  if voidp(pProductOrderData.getAt("extra_parm")) then
    pProductOrderData.setAt("extra_parm", "-")
  end if
  if voidp(pCatalogProps.getAt("editmode")) then
    return(error(me, "Catalogue mode not found", #purchaseProduct, #major))
  end if
  if voidp(pCatalogProps.getAt("lastPageID")) then
    return(error(me, "Catalogue page id missing", #purchaseProduct, #major))
  end if
  if not voidp(tGiftProps.getAt("gift")) then
    tGift = tGiftProps.getAt("gift") & "\r"
    if not voidp(tGiftProps.getAt("gift_receiver")) then
      tGift = tGift & tGiftProps.getAt("gift_receiver") & "\r"
    else
      tGift = ""
    end if
    if not voidp(tGiftProps.getAt("gift_msg")) then
      tGiftMsg = tGiftProps.getAt("gift_msg")
      tGiftMsg = convertSpecialChars(tGiftMsg, 1)
      tGift = tGift & tGiftMsg & "\r"
    else
      tGift = ""
    end if
  else
    tGift = "0"
  end if
  tOrderStr = ""
  tOrderStr = tOrderStr & pCatalogProps.getAt("editmode") & "\r"
  tOrderStr = tOrderStr & pCatalogProps.getAt("lastPageID") & "\r"
  tOrderStr = tOrderStr & me.getLanguage() & "\r"
  tOrderStr = tOrderStr & pProductOrderData.getAt("purchaseCode") & "\r"
  tExtra = pProductOrderData.getAt("extra_parm")
  tExtra = convertSpecialChars(tExtra, 1)
  tOrderStr = tOrderStr & tExtra & "\r"
  tOrderStr = tOrderStr & tGift
  if not connectionExists(getVariable("connection.info.id")) then
    return(0)
  end if
  return(getConnection(getVariable("connection.info.id")).send("GPRC", tOrderStr))
end

on retrieveCatalogueIndex me 
  if not voidp(pCatalogProps.getAt("editmode")) then
    tEditmode = pCatalogProps.getAt("editmode")
  else
    tEditmode = "production"
  end if
  tLanguage = me.getLanguage()
  if not voidp(pCatalogProps.getAt("catalogueIndex")) and tEditmode <> "develop" then
    me.getInterface().saveCatalogueIndex(pCatalogProps.getAt("catalogueIndex"))
  else
    if connectionExists(getVariable("connection.info.id")) then
      return(getConnection(getVariable("connection.info.id")).send("GCIX", tEditmode & "/" & tLanguage))
    else
      return(0)
    end if
  end if
end

on retrieveCataloguePage me, tPageID 
  if not voidp(pCatalogProps.getAt("editmode")) then
    tEditmode = pCatalogProps.getAt("editmode")
  else
    tEditmode = "production"
  end if
  tLanguage = me.getLanguage()
  pProductOrderData = void()
  pLastSelectedPageID = tPageID
  if not voidp(pCatalogProps.getAt(tPageID)) and tEditmode <> "develop" then
    pCatalogProps.setAt("lastPageID", tPageID)
    me.getInterface().cataloguePageData(pCatalogProps.getAt(tPageID))
  else
    if connectionExists(getVariable("connection.info.id")) then
      return(getConnection(getVariable("connection.info.id")).send("GCAP", tEditmode & "/" & tPageID & "/" & tLanguage))
    else
      return(0)
    end if
  end if
  return(0)
end

on purchaseReady me, tStatus, tMsg 
  if tStatus = "OK" then
    me.getInterface().showPurchaseOk()
  else
    if tStatus = "NOBALANCE" then
      me.getInterface().showNoBalance(void(), 1)
    else
      if tStatus = "ERROR" then
        error(me, "Purchase error:" && tMsg, #purchaseReady, #major)
      else
        error(me, "Unsupported purchase result:" && tStatus && tMsg, #purchaseReady, #major)
      end if
    end if
  end if
  return(1)
end

on saveCatalogueIndex me, tdata 
  if tdata.ilk <> #propList then
    return(error(me, "Incorrect Catalogue Format", #saveCatalogueIndex, #major))
  end if
  if tdata.count = 0 then
    return(0)
  end if
  pCatalogProps.setAt("catalogueIndex", tdata)
  me.getInterface().saveCatalogueIndex(tdata)
end

on saveCataloguePage me, tdata 
  if tdata.ilk <> #propList then
    return(error(me, "Incorrect Catalogue Page Format", #saveCataloguePage, #major))
  end if
  if tdata.count = 0 then
    return(0)
  end if
  if not voidp(tdata.getAt("id")) then
    if me.processCataloguePage(tdata) then
      tdata = me.solveCatalogueMembers(tdata)
      tPageID = tdata.getAt("id")
      pCatalogProps.setAt(tPageID, tdata)
      pCatalogProps.setAt("lastPageID", tPageID)
      me.getInterface().cataloguePageData(tdata)
    end if
  else
    return(error(me, "Catalogue Page ID missing", #saveCataloguePage, #major))
  end if
end

on solveCatalogueMembers me, tdata 
  tLanguage = me.getLanguage()
  if not voidp(tdata.getAt("headerImage")) then
    if memberExists(tdata.getAt("headerImage")) then
      tdata.setAt("headerImage", getmemnum(tdata.getAt("headerImage")))
    else
      tdata.setAt("headerImage", 0)
    end if
  end if
  if not voidp(tdata.getAt("teaserImgList")) then
    tImageNameList = tdata.getAt("teaserImgList")
    tMemList = []
    if tImageNameList.count > 0 then
      repeat while tImageNameList <= undefined
        tImg = getAt(undefined, tdata)
        if memberExists(tImg) then
          tMemList.add(getmemnum(tImg))
        else
          tMemList.add(0)
        end if
      end repeat
    end if
    tdata.setAt("teaserImgList", tMemList)
  end if
  if not voidp(tdata.getAt("productList")) then
    f = 1
    repeat while f <= tdata.getAt("productList").count
      tProductData = tdata.getAt("productList").getAt(f)
      if not voidp(tProductData.getAt("purchaseCode")) then
        tPrewMember = "ctlg_pic_"
        tPurchaseCode = tProductData.getAt("purchaseCode")
        tDealNumber = tProductData.getAt("dealNumber")
        if memberExists(tPrewMember & tPurchaseCode) then
          tdata.getAt("productList").getAt(f).setAt("prewImage", getmemnum(tPrewMember & tPurchaseCode))
        else
          tdata.getAt("productList").getAt(f).setAt("prewImage", 0)
        end if
        tdata.getAt("productList").getAt(f).setAt("smallColorFlag", 1)
        if memberExists(tPrewMember & "small_" & tPurchaseCode) then
          tdata.getAt("productList").getAt(f).setAt("smallPrewImg", getmemnum(tPrewMember & "small_" & tPurchaseCode))
        else
          tdata.getAt("productList").getAt(f).setAt("smallPrewImg", 0)
        end if
      end if
      if not voidp(tProductData.getAt("class")) then
        tClass = tProductData.getAt("class")
        if tClass contains "*" then
          tSmallMem = tClass & "_small"
          tClass = tClass.getProp(#char, 1, offset("*", tClass) - 1)
          if not memberExists(tSmallMem) then
            tSmallMem = tClass & "_small"
          else
            tdata.getAt("productList").getAt(f).setAt("smallColorFlag", 0)
          end if
        else
          tSmallMem = tClass & "_small"
        end if
        if tdata.getAt("productList").getAt(f).getAt("smallPrewImg") = 0 then
          if memberExists(tSmallMem) then
            tdata.getAt("productList").getAt(f).setAt("smallPrewImg", getmemnum(tSmallMem))
          else
            tdata.getAt("productList").getAt(f).setAt("smallPrewImg", getmemnum("no_icon_small"))
          end if
        end if
      end if
      if not voidp(tDealNumber) then
        tdata.getAt("productList").getAt(f).setAt("smallPrewImg", 0)
      end if
      f = 1 + f
    end repeat
  end if
  return(tdata)
end

on processCataloguePage me, tdata 
  tPageID = tdata.getAt("id")
  tObjectLoadList = []
  if not voidp(tdata.getAt("productList")) and not voidp(tPageID) then
    repeat while tdata.getAt("productList") <= undefined
      tProduct = getAt(undefined, tdata)
      tClass = me.getClassName(tProduct.getAt("class"))
      if not voidp(tClass) and tClass <> "" then
        if tObjectLoadList.findPos(tClass) = 0 then
          tObjectLoadList.add(tClass)
        end if
      else
        nothing()
      end if
      tDeal = tProduct.getAt("dealList")
      if not voidp(tDeal) then
        repeat while tdata.getAt("productList") <= undefined
          tDealProduct = getAt(undefined, tdata)
          tClass = me.getClassName(tDealProduct.getAt("class"))
          if not voidp(tClass) and tClass <> "" then
            if tObjectLoadList.findPos(tClass) = 0 then
              tObjectLoadList.add(tClass)
            end if
          else
            nothing()
          end if
        end repeat
      end if
    end repeat
    tIndex = tObjectLoadList.count
    repeat while tIndex >= 1
      tClass = tObjectLoadList.getAt(tIndex)
      if getThread(#dynamicdownloader) = 0 then
        tObjectLoadList.deleteAt(tIndex)
      else
        if getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
          tObjectLoadList.deleteAt(tIndex)
        else
          ttype = #Active
          getThread(#dynamicdownloader).getComponent().downloadCastDynamically(tClass, ttype, me.getID(), #objectDownloadCompleted, 1)
        end if
      end if
      tIndex = 255 + tIndex
    end repeat
  end if
  tHeaderImgName = tdata.getAt(#headerImage)
  tTeaserImgList = tdata.getAt(#teaserImgList)
  if string(tHeaderImgName).length > 0 then
    if not memberExists(tHeaderImgName) then
      tSourceURL = pImageLibraryURL & "catalogue/" & tHeaderImgName & "_" & me.getLanguage() & ".gif"
      tHeaderMemNum = queueDownload(tSourceURL, tHeaderImgName, #bitmap, 1)
      registerDownloadCallback(tHeaderMemNum, #catalogImgDownloaded, me.getID(), tHeaderImgName)
      if tObjectLoadList.findPos(tHeaderImgName) = 0 then
        tObjectLoadList.add(tHeaderImgName)
      end if
    end if
  end if
  if ilk(tTeaserImgList) = #list then
    repeat while tdata.getAt("productList") <= undefined
      tTeaserImg = getAt(undefined, tdata)
      if string(tTeaserImg).length > 0 then
        if not memberExists(tTeaserImg) then
          tSourceURL = pImageLibraryURL & "catalogue/" & tTeaserImg & "_" & me.getLanguage() & ".gif"
          tTeaserMemNum = queueDownload(tSourceURL, tTeaserImg, #bitmap, 1)
          registerDownloadCallback(tTeaserMemNum, #catalogImgDownloaded, me.getID(), tTeaserImg)
          if tObjectLoadList.findPos(tTeaserImg) = 0 then
            tObjectLoadList.add(tTeaserImg)
          end if
        end if
      end if
    end repeat
  end if
  if tObjectLoadList.count > 0 then
    pLoadingProps.setAt(tPageID, ["loadList":tObjectLoadList, "data":tdata.duplicate()])
    return(0)
  else
    return(1)
  end if
end

on getClassName me, tClass 
  tName = tClass
  if voidp(tName) then
    return(tName)
  end if
  if tName contains "*" then
    tDelim = the itemDelimiter
    the itemDelimiter = "*"
    tName = tName.getProp(#item, 1)
    the itemDelimiter = tDelim
  end if
  return(tName)
end

on objectDownloadCompleted me, tClass, tSuccess 
  me.downloadCompleted(tClass, tSuccess)
end

on catalogImgDownloaded me, tImgId 
  tSuccess = 0
  if memberExists(tImgId) then
    if member(getmemnum(tImgId)).type = #bitmap then
      tImage = member(getmemnum(tImgId)).image
      if tImage.width = 0 or tImage.height = 0 then
        member(getmemnum(tImgId)).image = member(getmemnum("loading_icon")).image
      else
        tSuccess = 1
      end if
    end if
  end if
  me.downloadCompleted(tImgId, tSuccess)
end

on downloadCompleted me, tClassID, tSuccess 
  if not tSuccess then
    nothing()
  end if
  tLoadCount = pLoadingProps.count
  tIndex = tLoadCount
  repeat while tIndex >= 1
    tDownloadList = pLoadingProps.getAt(tIndex).getAt("loadList")
    tPageID = pLoadingProps.getPropAt(tIndex)
    tPos = tDownloadList.findPos(tClassID)
    if tPos > 0 then
      tDownloadList.deleteAt(tPos)
    end if
    if tDownloadList.count = 0 then
      tdata = pLoadingProps.getAt(tIndex).getAt("data").duplicate()
      tdata = me.solveCatalogueMembers(tdata)
      tPageID = tdata.getAt("id")
      pCatalogProps.setAt(tPageID, tdata)
      if tPageID = pLastSelectedPageID then
        pCatalogProps.setAt("lastPageID", tPageID)
        tInterfaceId = me.getInterface().getID()
        createTimeout(#catalogpagedata, 10, #cataloguePageData, tInterfaceId, tdata, 1)
      end if
      pLoadingProps.deleteAt(tIndex)
    end if
    tIndex = 255 + tIndex
  end repeat
end

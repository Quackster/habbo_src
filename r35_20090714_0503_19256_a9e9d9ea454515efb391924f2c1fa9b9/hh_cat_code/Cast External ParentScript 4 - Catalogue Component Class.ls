property pLoadingProps, pCatalogProps, pProductOrderData, pLastSelectedPageID, pImageLibraryURL, pPersistentCatalogDataId

on construct me
  pOrderInfoList = []
  pCatalogProps = [:]
  pProductOrderData = [:]
  pLoadingProps = [:]
  pLastSelectedPageID = VOID
  if variableExists("ctlg.editmode") then
    pCatalogProps["editmode"] = getVariable("ctlg.editmode")
  else
    pCatalogProps["editmode"] = "production"
  end if
  pImageLibraryURL = getVariable("image.library.url", "http://images.habbohotel.com/c_images/")
  pPersistentCatalogDataId = "Persistent Catalog Data"
  createObject(pPersistentCatalogDataId, ["Persistent Product Data Container"])
  registerMessage(#edit_catalogue, me.getID(), #editModeOn)
  return 1
end

on deconstruct me
  pOrderInfoList = []
  pCatalogProps = [:]
  pLoadingProps = [:]
  unregisterMessage(#edit_catalogue, me.getID())
  return 1
end

on editModeOn me
  setVariable("ctlg.editmode", "develop")
  pCatalogProps["editmode"] = getVariable("ctlg.editmode")
end

on getLanguage me
  if variableExists("language") then
    tLanguage = getVariable("language")
  else
    tLanguage = "en"
  end if
  return tLanguage
end

on checkProductOrder me, tProductProps
  if tProductProps.ilk <> #propList then
    return error(me, "Incorrect SelectedProduct proplist", #checkProductOrder, #major)
  end if
  if not voidp(tProductProps["purchaseCode"]) then
    tProps = [:]
    tstate = "OK"
    if not voidp(tProductProps["name"]) then
      tProps[#name] = tProductProps["name"]
    else
      tProps[#name] = "ERROR"
      tstate = "ERROR"
    end if
    if not voidp(tProductProps["purchaseCode"]) then
      tProps[#code] = tProductProps["purchaseCode"]
    else
      tProps[#code] = "ERROR"
      tstate = "ERROR"
    end if
    if not voidp(tProductProps["price"]) then
      tProps[#price] = tProductProps["price"]
    else
      tProps[#price] = "ERROR"
      tstate = "ERROR"
    end if
    pProductOrderData = tProductProps.duplicate()
    me.getInterface().showOrderInfo(tstate, tProps)
    return 1
  else
    pProductOrderData = [:]
    return 0
  end if
end

on purchaseProduct me, tGiftProps
  if pProductOrderData.ilk <> #propList then
    return error(me, "Incorrect Product data", #purchaseProduct, #major)
  end if
  if tGiftProps.ilk <> #propList then
    return error(me, "Incorrect Gift Props", #purchaseProduct, #major)
  end if
  if voidp(pProductOrderData["name"]) then
    return error(me, "Product name not found", #purchaseProduct, #major)
  end if
  if voidp(pProductOrderData["purchaseCode"]) then
    return error(me, "PurchaseCode name not found", #purchaseProduct, #major)
  end if
  if voidp(pProductOrderData["extra_parm"]) then
    pProductOrderData["extra_parm"] = "-"
  end if
  if voidp(pCatalogProps["editmode"]) then
    return error(me, "Catalogue mode not found", #purchaseProduct, #major)
  end if
  if voidp(pCatalogProps["lastPageID"]) then
    return error(me, "Catalogue page id missing", #purchaseProduct, #major)
  end if
  if not voidp(tGiftProps["gift"]) then
    tGift = tGiftProps["gift"] & RETURN
    if not voidp(tGiftProps["gift_receiver"]) then
      tGift = tGift & tGiftProps["gift_receiver"] & RETURN
    else
      tGift = EMPTY
    end if
    if not voidp(tGiftProps["gift_msg"]) then
      tGiftMsg = tGiftProps["gift_msg"]
      tGiftMsg = convertSpecialChars(tGiftMsg, 1)
      tGift = tGift & tGiftMsg & RETURN
    else
      tGift = EMPTY
    end if
  else
    tGift = "0"
  end if
  tExtra = pProductOrderData["extra_parm"]
  tExtra = convertSpecialChars(tExtra, 1)
  tMessage = [:]
  tMessage.addProp(#string, string(pCatalogProps["editmode"]))
  tMessage.addProp(#string, string(pCatalogProps["lastPageID"]))
  tMessage.addProp(#string, string(me.getLanguage()))
  tMessage.addProp(#string, string(pProductOrderData["purchaseCode"]))
  tMessage.addProp(#string, tExtra)
  if tGiftProps["gift"] = 1 then
    tMessage.addProp(#integer, 1)
    tMessage.addProp(#string, tGiftProps["gift_receiver"])
    tMessage.addProp(#string, tGiftProps["gift_msg"])
  else
    tMessage.addProp(#integer, 0)
  end if
  if not connectionExists(getVariable("connection.info.id")) then
    return 0
  end if
  return getConnection(getVariable("connection.info.id")).send("PURCHASE_FROM_CATALOG", tMessage)
end

on retrieveCatalogueIndex me
  if not voidp(pCatalogProps["editmode"]) then
    tEditmode = pCatalogProps["editmode"]
  else
    tEditmode = "production"
  end if
  tLanguage = me.getLanguage()
  if not voidp(pCatalogProps["catalogueIndex"]) and (tEditmode <> "develop") then
    me.getInterface().saveCatalogueIndex(pCatalogProps["catalogueIndex"])
    return 0
  else
    if connectionExists(getVariable("connection.info.id")) then
      return getConnection(getVariable("connection.info.id")).send("GCIX", tEditmode & "/" & tLanguage)
    else
      return 0
    end if
  end if
end

on retrieveCataloguePage me, tPageID
  if not voidp(pCatalogProps["editmode"]) then
    tEditmode = pCatalogProps["editmode"]
  else
    tEditmode = "production"
  end if
  tLanguage = me.getLanguage()
  pProductOrderData = VOID
  pLastSelectedPageID = tPageID
  pCatalogProps["lastPageID"] = tPageID
  if not voidp(pCatalogProps[tPageID]) and (tEditmode <> "develop") then
    me.getInterface().cataloguePageData(pCatalogProps[tPageID], 1)
  else
    if connectionExists(getVariable("connection.info.id")) then
      return getConnection(getVariable("connection.info.id")).send("GCAP", tEditmode & "/" & tPageID & "/" & tLanguage)
    else
      return 0
    end if
  end if
  return 0
end

on purchaseReady me, tStatus, tMsg
  case tStatus of
    "OK":
      me.getInterface().showPurchaseOk()
    "NOBALANCE":
      me.getInterface().showNoBalance(VOID, 1)
    "ERROR":
      error(me, "Purchase error:" && tMsg, #purchaseReady, #major)
    otherwise:
      error(me, "Unsupported purchase result:" && tStatus && tMsg, #purchaseReady, #major)
  end case
  return 1
end

on saveCatalogueIndex me, tdata
  if tdata.ilk <> #propList then
    return error(me, "Incorrect Catalogue Format", #saveCatalogueIndex, #major)
  end if
  if tdata.count = 0 then
    return 0
  end if
  pCatalogProps["catalogueIndex"] = tdata
  me.getInterface().saveCatalogueIndex(tdata)
end

on saveCataloguePage me, tdata
  if tdata.ilk <> #propList then
    return error(me, "Incorrect Catalogue Page Format", #saveCataloguePage, #major)
  end if
  if tdata.count = 0 then
    return 0
  end if
  if not voidp(tdata["id"]) then
    if me.processCataloguePage(tdata) then
      tdata = me.solveCatalogueMembers(tdata)
      tPageID = tdata["id"]
      pCatalogProps[tPageID] = tdata
      pCatalogProps["lastPageID"] = tPageID
      me.getInterface().cataloguePageData(tdata)
    end if
  else
    return error(me, "Catalogue Page ID missing", #saveCataloguePage, #major)
  end if
end

on solveCatalogueMembers me, tdata
  tLanguage = me.getLanguage()
  if not voidp(tdata["headerImage"]) and not integerp(tdata["headerImage"]) then
    if memberExists(tdata["headerImage"]) then
      tdata["headerImage"] = getmemnum(tdata["headerImage"])
    else
      tdata["headerImage"] = 0
    end if
  end if
  if not voidp(tdata["teaserImgList"]) then
    tImageNameList = tdata["teaserImgList"]
    tMemList = []
    if tImageNameList.count > 0 then
      repeat with tImg in tImageNameList
        if not integerp(tImg) then
          if memberExists(tImg) then
            tMemList.add(getmemnum(tImg))
          else
            tMemList.add(0)
          end if
          next repeat
        end if
        tMemList.add(tImg)
      end repeat
    end if
    tdata["teaserImgList"] = tMemList
  end if
  if not voidp(tdata["productList"]) then
    repeat with f = 1 to tdata["productList"].count
      tProductData = tdata["productList"][f]
      if not voidp(tProductData["purchaseCode"]) then
        tPrewMember = "ctlg_pic_"
        tPurchaseCode = tProductData["purchaseCode"]
        tDealNumber = tProductData["dealNumber"]
        if memberExists(tPrewMember & tPurchaseCode) then
          tdata["productList"][f]["prewImage"] = getmemnum(tPrewMember & tPurchaseCode)
        else
          tdata["productList"][f]["prewImage"] = 0
        end if
        tdata["productList"][f]["smallColorFlag"] = 1
        if memberExists(tPrewMember & "small_" & tPurchaseCode) then
          tdata["productList"][f]["smallPrewImg"] = getmemnum(tPrewMember & "small_" & tPurchaseCode)
        else
          tdata["productList"][f]["smallPrewImg"] = 0
        end if
      end if
      if not voidp(tProductData["class"]) then
        tClass = tProductData["class"]
        if tClass contains "*" then
          tSmallMem = tClass & "_small"
          tClass = tClass.char[1..offset("*", tClass) - 1]
          if not memberExists(tSmallMem) then
            tSmallMem = tClass & "_small"
          else
            tdata["productList"][f]["smallColorFlag"] = 0
          end if
        else
          tSmallMem = tClass & "_small"
        end if
        if (tClass = EMPTY) and not voidp(tdata["productList"][f].getaProp("dealList")) then
          tLoading = 0
          repeat with tProduct in tdata["productList"][f]["dealList"]
            if me.isProductLoading(tProduct["class"], tdata["pageName"]) then
              tLoading = 1
            end if
          end repeat
          if tLoading then
            tdata["productList"][f]["smallPrewImg"] = getmemnum("ctlg_loading_icon2")
            tdata["productList"][f]["prewImage"] = getmemnum("ctlg_loading_icon2")
          end if
        end if
        if me.isProductLoading(tClass, tdata["pageName"]) then
          tdata["productList"][f]["smallPrewImg"] = getmemnum("ctlg_loading_icon2")
          tdata["productList"][f]["prewImage"] = getmemnum("ctlg_loading_icon2")
        end if
        if tdata["productList"][f]["smallPrewImg"] = 0 then
          if memberExists(tSmallMem) then
            tdata["productList"][f]["smallPrewImg"] = getmemnum(tSmallMem)
          else
            tdata["productList"][f]["smallPrewImg"] = getmemnum("no_icon_small")
          end if
        end if
      end if
      if not voidp(tDealNumber) and (tdata["productList"][f]["smallPrewImg"] <> getmemnum("ctlg_loading_icon2")) then
        tdata["productList"][f]["smallPrewImg"] = 0
      end if
    end repeat
  end if
  return tdata
end

on processCataloguePage me, tdata
  tObjectLoadList = []
  tHeaderImgName = tdata[#headerImage]
  tTeaserImgList = tdata[#teaserImgList]
  if string(tHeaderImgName).length > 0 then
    if not memberExists(tHeaderImgName) then
      tSourceURL = pImageLibraryURL & "catalogue/" & tHeaderImgName & "_" & me.getLanguage() & ".gif"
      tHeaderMemNum = queueDownload(tSourceURL, tHeaderImgName, #bitmap, 1)
      if tHeaderMemNum > 0 then
        registerDownloadCallback(tHeaderMemNum, #catalogImgDownloaded, me.getID(), tHeaderImgName)
        if tObjectLoadList.findPos(tHeaderImgName) = 0 then
          tObjectLoadList.addAt(1, tHeaderImgName)
        end if
      end if
    end if
  end if
  if ilk(tTeaserImgList) = #list then
    repeat with tTeaserImg in tTeaserImgList
      if string(tTeaserImg).length > 0 then
        if not memberExists(tTeaserImg) then
          tSourceURL = pImageLibraryURL & "catalogue/" & tTeaserImg & "_" & me.getLanguage() & ".gif"
          tTeaserMemNum = queueDownload(tSourceURL, tTeaserImg, #bitmap, 1)
          if tTeaserMemNum > 0 then
            registerDownloadCallback(tTeaserMemNum, #catalogImgDownloaded, me.getID(), tTeaserImg)
            if tObjectLoadList.findPos(tTeaserImg) = 0 then
              tObjectLoadList.addAt(1, tTeaserImg)
            end if
          end if
        end if
      end if
    end repeat
  end if
  tPageID = tdata["id"]
  tDisplayRightAway = 0
  if tObjectLoadList.count > 0 then
    pLoadingProps[tPageID] = ["loadList": tObjectLoadList, "data": tdata.duplicate()]
  else
    tDisplayRightAway = 1
  end if
  tObjectLoadList = []
  if not voidp(tdata["productList"]) and not voidp(tPageID) then
    repeat with tProduct in tdata["productList"]
      tClass = me.getClassName(tProduct["class"])
      if not voidp(tClass) and (tClass <> EMPTY) then
        if tObjectLoadList.findPos(tClass) = 0 then
          tObjectLoadList.addAt(1, tClass)
        end if
      else
        nothing()
      end if
      tDeal = tProduct["dealList"]
      if not voidp(tDeal) then
        repeat with tDealProduct in tDeal
          tClass = me.getClassName(tDealProduct["class"])
          if not voidp(tClass) and (tClass <> EMPTY) then
            if tObjectLoadList.findPos(tClass) = 0 then
              tObjectLoadList.add(tClass)
            end if
            next repeat
          end if
          nothing()
        end repeat
      end if
    end repeat
    repeat with tIndex = tObjectLoadList.count down to 1
      tClass = tObjectLoadList[tIndex]
      if getThread(#dynamicdownloader) = 0 then
        tObjectLoadList.deleteAt(tIndex)
        next repeat
      end if
      if getThread(#dynamicdownloader).getComponent().isAssetDownloaded(tClass) then
        tObjectLoadList.deleteAt(tIndex)
        next repeat
      end if
      ttype = #Active
      getThread(#dynamicdownloader).getComponent().downloadCastDynamically(tClass, ttype, me.getID(), #objectDownloadCompleted, 1)
    end repeat
  end if
  tOut = 1
  if tObjectLoadList.count > 0 then
    if voidp(pLoadingProps.getaProp(tPageID)) then
      pLoadingProps[tPageID] = ["loadList": tObjectLoadList, "data": tdata.duplicate()]
    else
      repeat with tObject in tObjectLoadList
        pLoadingProps[tPageID]["loadList"].add(tObject)
      end repeat
    end if
    tOut = 0
  end if
  if tDisplayRightAway then
    tdata = me.solveCatalogueMembers(tdata)
    tInterfaceId = me.getInterface().getID()
    if timeoutExists(#catalogpagedata) then
      removeTimeout(#catalogpagedata)
    end if
    createTimeout(#catalogpagedata, 10, #cataloguePageData, tInterfaceId, tdata, 1)
  end if
  return tOut
end

on getClassName me, tClass
  tName = tClass
  if voidp(tName) then
    return tName
  end if
  if tName contains "*" then
    tDelim = the itemDelimiter
    the itemDelimiter = "*"
    tName = tName.item[1]
    the itemDelimiter = tDelim
  end if
  return tName
end

on isLoading me, tName, tPageName
  tFoundIndex = 0
  tLoadCount = pLoadingProps.count
  repeat with tIndex = tLoadCount down to 1
    tDownloadList = pLoadingProps[tIndex]["loadList"]
    tPageID = pLoadingProps.getPropAt(tIndex)
    tPos = tDownloadList.findPos(tName)
    if tPos > 0 then
      tFoundIndex = tIndex
      exit repeat
    end if
  end repeat
  if tFoundIndex < 1 then
    return 0
  else
    return 1
  end if
end

on isProductLoading me, tProductName, tPageName
  tName = me.getClassName(tProductName)
  return me.isLoading(tName, tPageName)
end

on objectDownloadCompleted me, tClass, tSuccess
  tLoadCount = pLoadingProps.count
  repeat with tIndex = tLoadCount down to 1
    tDownloadList = pLoadingProps[tIndex]["loadList"]
    tPageID = pLoadingProps.getPropAt(tIndex)
    tPos = tDownloadList.findPos(tClass)
    if tPos > 0 then
      tFoundIndex = tIndex
      exit repeat
    end if
  end repeat
  me.downloadCompleted(tClass, tSuccess)
  if not voidp(tFoundIndex) then
    if tPageID = pLastSelectedPageID then
      tdata = me.solveCatalogueMembers(me.pCatalogProps[tPageID])
      me.getInterface().ShowSmallIcons(#furniLoaded, tClass)
      me.getInterface().showProductPageCounter()
      me.getInterface().refreshPreviewImage(tClass, tdata)
    end if
  end if
end

on catalogImgDownloaded me, tImgId
  tSuccess = 0
  if memberExists(tImgId) then
    if member(getmemnum(tImgId)).type = #bitmap then
      tImage = member(getmemnum(tImgId)).image
      if (tImage.width = 0) or (tImage.height = 0) then
        member(getmemnum(tImgId)).image = member(getmemnum("loading_icon")).image
      else
        tSuccess = 1
      end if
    end if
  end if
  tPageID = EMPTY
  tLoadCount = pLoadingProps.count
  repeat with tIndex = tLoadCount down to 1
    tDownloadList = pLoadingProps[tIndex]["loadList"]
    if tDownloadList.findPos(tImgId) > 0 then
      tPageID = pLoadingProps.getPropAt(tIndex)
      exit repeat
    end if
  end repeat
  me.downloadCompleted(tImgId, tSuccess)
  tHeaderDownloaded = 1
  if voidp(pLoadingProps.getaProp(tPageID)) then
    return 
  end if
  tHeaderImg = pLoadingProps[tPageID]["data"].getaProp("headerImage")
  if pLoadingProps[tPageID]["loadList"].getPos(tHeaderImg) > 0 then
    tHeaderDownloaded = 0
  end if
  if tPageID contains pLastSelectedPageID then
    if voidp(pLoadingProps.getaProp(pLastSelectedPageID)) then
      tdata = pCatalogProps[pLastSelectedPageID]["data"].duplicate()
    else
      tdata = pLoadingProps[pLastSelectedPageID]["data"].duplicate()
    end if
    tdata = me.solveCatalogueMembers(tdata)
    tInterfaceId = me.getInterface().getID()
    if timeoutExists(#catalogpagedata) then
      removeTimeout(#catalogpagedata)
    end if
    createTimeout(#catalogpagedata, 10, #cataloguePageData, tInterfaceId, tdata, 1)
  end if
end

on downloadCompleted me, tClassID, tSuccess
  if not tSuccess then
    nothing()
  end if
  tLoadCount = pLoadingProps.count
  repeat with tIndex = tLoadCount down to 1
    tDownloadList = pLoadingProps[tIndex]["loadList"]
    tPageID = pLoadingProps.getPropAt(tIndex)
    tPos = tDownloadList.findPos(tClassID)
    if tPos > 0 then
      tDownloadList.deleteAt(tPos)
    end if
    tdata = pLoadingProps[tIndex]["data"].duplicate()
    tdata = me.solveCatalogueMembers(tdata)
    tPageID = tdata["id"]
    pCatalogProps[tPageID] = tdata
    if tDownloadList.count = 0 then
      pLoadingProps.deleteAt(tIndex)
      if tPageID contains pLastSelectedPageID then
        tInterfaceId = me.getInterface().getID()
        if timeoutExists(#catalogpagedata) then
          removeTimeout(#catalogpagedata)
        end if
        createTimeout(#catalogpagedata, 10, #cataloguePageData, tInterfaceId, tdata, 1)
      end if
    end if
  end repeat
end

on getPersistentCatalogDataObject me
  if voidp(getObject(pPersistentCatalogDataId)) then
    error(me, "Persistent Catalog Data Missing!", #getPersistentCatalogDataObject, #major)
  end if
  return getObject(pPersistentCatalogDataId)
end

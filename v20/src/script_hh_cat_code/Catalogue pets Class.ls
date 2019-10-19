property pPetRacesList, pPageData, pSelectedProduct, pPetTemplateObj, pSelectedOrderNum, pLastProductNum, pNameCheckPending

on construct me 
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return(error(me, "Couldn't access catalogue window!", #construct, #major))
  end if
  tPetClass = value(readValueFromField("fuse.object.classes", "\r", "pet"))
  pPetTemplateObj = createObject(#temp, tPetClass)
  pPageData = [:]
  pPetRacesList = [:]
  tPetDEfText = member(getmemnum("pet.definitions")).text
  tPetDEfText = replaceChunks(tPetDEfText, "\r", "")
  pPetDefinitions = value(tPetDEfText)
  if ilk(pPetDefinitions) <> #propList then
    pPetDefinitions = [:]
    error(me, "Pet definitions has invalid data!", me.getID(), #construct, #major)
  end if
  i = 0
  repeat while 1
    tRaceDefExists = pPetDefinitions.getaProp(string(i)) <> void()
    tRaceTextExists = textExists("pet_race_" & i & "_000")
    if tRaceDefExists and tRaceTextExists then
      tPetType = string(i)
      tTempRaces = []
      tTempRaces.add("000")
      f = 1
      repeat while 1
        if string(f).length = 1 then
          tTemp = "00" & f
        else
          if string(f).length = 2 then
            tTemp = "0" & f
          else
            tTemp = string(f)
          end if
        end if
        if textExists("pet_race_" & i & "_" & tTemp) then
          tTempRaces.add(tTemp)
        else
        end if
        f = f + 1
      end repeat
      exit repeat
    end if
    i = i + 1
  end repeat
  me.regMsgList(1)
  return(1)
end

on deconstruct me 
  me.regMsgList(0)
  return(1)
end

on define me, tPageProps 
  if tPageProps.ilk <> #propList then
    return(error(me, "Incorrect Catalogue page data", #define, #major))
  end if
  if not voidp(tPageProps.getAt("productList")) then
    tProducts = tPageProps.getAt("productList")
    f = 1
    repeat while f <= tProducts.count
      if not voidp(tProducts.getAt(f).getAt("purchaseCode")) then
        tPurchaseCode = tProducts.getAt(f).getAt("purchaseCode")
        tPetType = tPurchaseCode.getProp(#char, tPurchaseCode.length)
        tPetCount = 1
        repeat while tPetCount <= 5
          if not voidp(pPetRacesList.getAt(tPetType)) then
            tCount = pPetRacesList.getAt(tPetType).getAt("races").count
            if tCount > 0 then
              tPetRace = pPetRacesList.getAt(tPetType).getAt("races").getAt(random(tCount))
            else
              tPetRace = ""
            end if
            tCount = pPetRacesList.getAt(tPetType).getAt("colors").count
            if tCount > 0 then
              tColor = pPetRacesList.getAt(tPetType).getAt("colors").getAt(random(tCount))
            else
              tColor = ""
            end if
            tProductData = tProducts.getAt(f).duplicate()
            tProductData.addProp("petType", tPetType)
            tProductData.addProp("petRace", tPetRace)
            tProductData.addProp("petColor", tColor)
            pPageData.setAt("pet_" & tPetType & "_" & tPetCount, tProductData)
          end if
          tPetCount = 1 + tPetCount
        end repeat
      end if
      f = 1 + f
    end repeat
  end if
  selectProduct(me, 1)
end

on petNameApproved me 
  if pSelectedProduct.ilk = #propList then
    getThread(#catalogue).getComponent().checkProductOrder(pSelectedProduct)
  end if
end

on petNameUnacceptable me 
  tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if tWndObj.elementExists("dedication_text") then
    tWndObj.getElement("dedication_text").setText("")
  end if
  return(executeMessage(#alert, [#Msg:"catalog_pet_unacceptable", #id:"ctlg_petunacceptable"]))
end

on definePet me, tProps 
  tdata = [:]
  tdata.setAt(#name, "PetTemplate")
  tdata.setAt(#class, "Pet Class")
  tdata.setAt(#direction, [1, 1, 1])
  tdata.setAt(#x, 1)
  tdata.setAt(#y, 1)
  tdata.setAt(#h, 1)
  tdata.setAt(#figure, tProps.getAt("petType") && tProps.getAt("petRace") && tProps.getAt("petColor"))
  if not voidp(pPetTemplateObj) then
    pPetTemplateObj.setup(tdata)
    return(1)
  else
    return(0)
  end if
end

on selectProduct me, tOrderNum 
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return(error(me, "Couldn't access catalogue window!", #selectProduct, #major))
  end if
  tWndObj = tCataloguePage
  if not integerp(tOrderNum) then
    return(error(me, "Incorrect value", #selectProduct, #major))
  end if
  if voidp(pPageData) then
    return(error(me, "product not found", #selectProduct, #major))
  end if
  if pPageData.count = 0 then
    return()
  end if
  if tOrderNum > pPageData.count then
    return()
  end if
  if voidp(pPageData.getAt(tOrderNum).getAt(1)) then
    return()
  end if
  pSelectedProduct = pPageData.getAt(tOrderNum)
  pSelectedColorNum = 1
  pSelectedOrderNum = tOrderNum
  if me.definePet(pSelectedProduct) = 1 then
    tElemID = "ctlg_teaserimg_1"
    if tWndObj.elementExists(tElemID) then
      tElem = tWndObj.getElement(tElemID)
      tImage = pPetTemplateObj.getPicture()
      if tImage.ilk = #image then
        tDestImg = tElem.getProperty(#image)
        tSourceImg = tImage
        tDestImg.fill(tDestImg.rect, rgb(255, 255, 255))
        tSourceRect = (tSourceImg.rect * 2)
        tdestrect = tDestImg.rect - tSourceRect
        tMargins = rect(14, -7, 14, -7)
        tdestrect = rect((tdestrect.width / 2), (tdestrect.height / 2), tSourceRect.width + (tdestrect.width / 2), (tdestrect.height / 2) + tSourceRect.height) + tMargins
        tDestImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect, [#ink:36])
        tElem.feedImage(tDestImg)
      end if
    end if
  end if
  if tWndObj.elementExists("ctlg_text_2") then
    tText = getText("pet_race_" & pSelectedProduct.getAt("petType") & "_" & pSelectedProduct.getAt("petRace"))
    tWndObj.getElement("ctlg_text_2").setText(tText)
  end if
  if not voidp(pSelectedProduct.getAt("price")) then
    if tWndObj.elementExists("ctlg_price_1") then
      if value(pSelectedProduct.getAt("price")) > 1 then
        tText = pSelectedProduct.getAt("price") && getText("credits", "credits")
      else
        tText = pSelectedProduct.getAt("price") && getText("credit", "credit")
      end if
      tWndObj.getElement("ctlg_price_1").setText(tText)
    end if
  end if
  if tWndObj.elementExists("ctlg_buy_button") then
    tWndObj.getElement("ctlg_buy_button").setProperty(#visible, 1)
  end if
  pLastProductNum = pSelectedOrderNum
end

on nextProduct me 
  if pPageData.ilk <> #propList then
    return(error(me, "Incorrect data", #nextProduct, #major))
  end if
  tNext = pLastProductNum + 1
  if tNext > pPageData.count then
    tNext = pPageData.count
  end if
  pSelectedOrderNum = tNext
  selectProduct(me, tNext)
end

on prevProduct me 
  if pPageData.ilk <> #propList then
    return(error(me, "Incorrect data", #prewProduct, #major))
  end if
  tPrev = pLastProductNum - 1
  if tPrev < 1 then
    tPrev = 1
  end if
  pSelectedOrderNum = tPrev
  selectProduct(me, tPrev)
end

on eventProc me, tEvent, tSprID, tProp 
  if tEvent = #mouseUp then
    if tSprID = "close" then
      return(0)
    end if
  end if
  if tEvent = #mouseDown then
    if tSprID = "ctlg_buy_button" then
      tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
      tText = ""
      if tWndObj.elementExists("dedication_text") then
        tText = tWndObj.getElement("dedication_text").getText()
        tText = replaceChunks(tText, "\r", "\\r")
      end if
      if tText.length < 1 then
        return(executeMessage(#alert, [#Msg:"catalog_give_petname", #id:"ctlg_petmsg"]))
      else
        if tText.length > 15 then
          return(executeMessage(#alert, [#Msg:"catalog_pet_name_length", #id:"ctlg_petmsg"]))
        end if
      end if
      tText = tText.getProp(#char, 1, 15)
      tText = convertSpecialChars(tText, 1)
      if pSelectedProduct.ilk <> #propList then
        return(error(me, "incorrect Selected Product Data", #eventProc, #major))
      end if
      tPet = numToChar(2) & pSelectedProduct.getAt("petRace") & numToChar(2) & pSelectedProduct.getAt("petColor")
      pSelectedProduct.setAt("extra_parm", tText & tPet)
      if connectionExists(getVariable("connection.info.id", #info)) then
        pNameCheckPending = 1
        getConnection(getVariable("connection.info.id", #info)).send("APPROVENAME", [#string:tText, #integer:1])
      end if
    else
      if tSprID = "ctlg_nextmodel_button" then
        me.nextProduct()
      else
        if tSprID = "ctlg_prevmodel_button" then
          me.prevProduct()
        else
          if tSprID = "ctlg_text_3" then
            put("TODO >>> link")
          else
            return(0)
          end if
        end if
      end if
    end if
  end if
  return(1)
end

on handle_nameapproved me, tMsg 
  if not pNameCheckPending then
    return(1)
  end if
  pNameCheckPending = 0
  tParm = tMsg.GetIntFrom(tMsg)
  if tParm = 0 then
    me.petNameApproved()
  else
    me.petNameUnacceptable()
  end if
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(36, #handle_nameapproved)
  tCmds = [:]
  tCmds.setaProp("APPROVENAME", 42)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return(1)
end

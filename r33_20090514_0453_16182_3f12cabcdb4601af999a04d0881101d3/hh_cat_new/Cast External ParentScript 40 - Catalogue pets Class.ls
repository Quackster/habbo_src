property pPageData, pSmallImg, pSelectedOrderNum, pSelectedColorNum, pSelectedProduct, pLastProductNum, pNumOfColorBoxies, pCurrentProductNum, pPetTemplateObj, pPetRacesList, pNameCheckPending, pDefinitions

on construct me
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return error(me, "Couldn't access catalogue window!", #construct, #major)
  end if
  tPetClass = value(readValueFromField("fuse.object.classes", RETURN, "pet"))
  pPetTemplateObj = createObject(#temp, tPetClass)
  pPageData = [:]
  pPetRacesList = [:]
  tPetDEfText = member(getmemnum("pet.definitions")).text
  tPetDEfText = replaceChunks(tPetDEfText, RETURN, EMPTY)
  pPetDefinitions = value(tPetDEfText)
  if ilk(pPetDefinitions) <> #propList then
    pPetDefinitions = [:]
    error(me, "Pet definitions has invalid data!", me.getID(), #construct, #major)
  end if
  i = 0
  repeat while 1
    tRaceDefExists = pPetDefinitions.getaProp(string(i)) <> VOID
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
          tColorList = []
          tPetColorId = pPetDefinitions[tPetType][#colorid]
          if memberExists("petColors_" & tPetColorId) then
            tColorTxt = member(getmemnum("petColors_" & tPetColorId)).text
            repeat with tLine = 1 to tColorTxt.line.count
              if tColorTxt.line[tLine].length = 7 then
                tColorList.add(tColorTxt.line[tLine].char[2..7])
              end if
            end repeat
          else
            error(me, "Couldn't find pet colors member!" && tPetColorId, #construct, #major)
            return 0
          end if
          pPetRacesList[tPetType] = ["races": tTempRaces, "colors": tColorList]
          exit repeat
        end if
        f = f + 1
      end repeat
    else
      exit repeat
    end if
    i = i + 1
  end repeat
  me.regMsgList(1)
  return 1
end

on deconstruct me
  me.regMsgList(0)
  return 1
end

on define me, tPageProps
  if tPageProps.ilk <> #propList then
    return error(me, "Incorrect Catalogue page data", #define, #major)
  end if
  if not voidp(tPageProps["productList"]) then
    tProducts = tPageProps["productList"]
    repeat with f = 1 to tProducts.count
      if not voidp(tProducts[f]["purchaseCode"]) then
        tPurchaseCode = tProducts[f]["purchaseCode"]
        tPetType = tPurchaseCode.char[tPurchaseCode.length]
        repeat with tPetCount = 1 to 5
          if not voidp(pPetRacesList[tPetType]) then
            tCount = pPetRacesList[tPetType]["races"].count
            if tCount > 0 then
              tPetRace = pPetRacesList[tPetType]["races"][random(tCount)]
            else
              tPetRace = EMPTY
            end if
            tCount = pPetRacesList[tPetType]["colors"].count
            if tCount > 0 then
              tColor = pPetRacesList[tPetType]["colors"][random(tCount)]
            else
              tColor = EMPTY
            end if
            tProductData = tProducts[f].duplicate()
            tProductData.addProp("petType", tPetType)
            tProductData.addProp("petRace", tPetRace)
            tProductData.addProp("petColor", tColor)
            pPageData["pet_" & tPetType & "_" & tPetCount] = tProductData
          end if
        end repeat
      end if
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
    tWndObj.getElement("dedication_text").setText(EMPTY)
  end if
  return executeMessage(#alert, [#Msg: "catalog_pet_unacceptable", #id: "ctlg_petunacceptable"])
end

on definePet me, tProps
  tdata = [:]
  tdata[#name] = "PetTemplate"
  tdata[#class] = "Pet Class"
  tdata[#direction] = [1, 1, 1]
  tdata[#x] = 1
  tdata[#y] = 1
  tdata[#h] = 1
  tdata[#figure] = tProps["petType"] && tProps["petRace"] && tProps["petColor"]
  if not voidp(pPetTemplateObj) then
    pPetTemplateObj.setup(tdata)
    return 1
  else
    return 0
  end if
end

on selectProduct me, tOrderNum
  tCataloguePage = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tCataloguePage then
    return error(me, "Couldn't access catalogue window!", #selectProduct, #major)
  end if
  tWndObj = tCataloguePage
  if not integerp(tOrderNum) then
    return error(me, "Incorrect value", #selectProduct, #major)
  end if
  if voidp(pPageData) then
    return error(me, "product not found", #selectProduct, #major)
  end if
  if pPageData.count = 0 then
    return 
  end if
  if tOrderNum > pPageData.count then
    return 
  end if
  if voidp(pPageData[tOrderNum][1]) then
    return 
  end if
  pSelectedProduct = pPageData[tOrderNum]
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
        tSourceRect = tSourceImg.rect * 2
        tdestrect = tDestImg.rect - tSourceRect
        tMargins = rect(14, -7, 14, -7)
        tdestrect = rect(tdestrect.width / 2, tdestrect.height / 2, tSourceRect.width + (tdestrect.width / 2), (tdestrect.height / 2) + tSourceRect.height) + tMargins
        tDestImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect, [#ink: 36])
        tElem.feedImage(tDestImg)
      end if
    end if
  end if
  if tWndObj.elementExists("ctlg_text_2") then
    tText = getText("pet_race_" & pSelectedProduct["petType"] & "_" & pSelectedProduct["petRace"])
    tWndObj.getElement("ctlg_text_2").setText(tText)
  end if
  if not voidp(pSelectedProduct["price"]) then
    if tWndObj.elementExists("ctlg_price_1") then
      if value(pSelectedProduct["price"]) > 1 then
        tText = pSelectedProduct["price"] && getText("credits", "credits")
      else
        tText = pSelectedProduct["price"] && getText("credit", "credit")
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
    return error(me, "Incorrect data", #nextProduct, #major)
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
    return error(me, "Incorrect data", #prewProduct, #major)
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
      return 0
    end if
  end if
  if tEvent = #mouseDown then
    if tSprID = "ctlg_buy_button" then
      tWndObj = getThread(#catalogue).getInterface().getCatalogWindow()
      tText = EMPTY
      if tWndObj.elementExists("dedication_text") then
        tText = tWndObj.getElement("dedication_text").getText()
        tText = replaceChunks(tText, RETURN, "\r")
      end if
      if tText.length < 1 then
        return executeMessage(#alert, [#Msg: "catalog_give_petname", #id: "ctlg_petmsg"])
      else
        if tText.length > 15 then
          return executeMessage(#alert, [#Msg: "catalog_pet_name_length", #id: "ctlg_petmsg"])
        end if
      end if
      tText = tText.char[1..15]
      tText = convertSpecialChars(tText, 1)
      if pSelectedProduct.ilk <> #propList then
        return error(me, "incorrect Selected Product Data", #eventProc, #major)
      end if
      tPet = numToChar(10) & pSelectedProduct["petRace"] & numToChar(10) & pSelectedProduct["petColor"]
      pSelectedProduct["extra_parm"] = tText & tPet
      if connectionExists(getVariable("connection.info.id", #Info)) then
        pNameCheckPending = 1
        getConnection(getVariable("connection.info.id", #Info)).send("APPROVE_PET_NAME", [#string: tText])
      end if
    else
      if tSprID = "ctlg_nextmodel_button" then
        me.nextProduct()
      else
        if tSprID = "ctlg_prevmodel_button" then
          me.prevProduct()
        else
          if tSprID = "ctlg_text_3" then
            put "TODO >>> link"
          else
            return 0
          end if
        end if
      end if
    end if
  end if
  return 1
end

on handle_nameapproved me, tMsg
  if not pNameCheckPending then
    return 1
  end if
  pNameCheckPending = 0
  tParm = tMsg.connection.GetIntFrom(tMsg)
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
  tCmds.setaProp("APPROVE_PET_NAME", 42)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return 1
end

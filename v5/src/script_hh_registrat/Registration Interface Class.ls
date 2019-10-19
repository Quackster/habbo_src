property pWindowTitle, pPropsToServer, pOpenWindow, pMode, pOldFigure, pOldSex, pBodyPartObjects, pPartChangeButtons, pLastNameCheck, pTempPassword, pErrorMsg, pNameChecked

on construct me 
  pTempPassword = [:]
  pPropsToServer = [:]
  pPartChangeButtons = [:]
  pLastNameCheck = ""
  pWindowTitle = getText("win_figurecreator", "Your own Habbo")
  if not variableExists("permitted.name.chars") then
    setVariable("permitted.name.chars", "1234567890qwertyuiopasdfghjklzxcvbnm_-=+?!@<>:.,")
  end if
  return(1)
end

on deconstruct me 
  pBodyPartObjects = void()
  if windowExists(pWindowTitle) then
    removeWindow(pWindowTitle)
  end if
  if objectExists(#temp_humanobj_figurecreator) then
    removeObject(#temp_humanobj_figurecreator)
  end if
  if objectExists("CountryMngr") then
    removeObject("CountryMngr")
  end if
  return(1)
end

on showHideFigureCreator me, tNewOrUpdate 
  if windowExists(pWindowTitle) then
    me.closeFigureCreator()
  else
    me.openFigureCreator(tNewOrUpdate)
  end if
end

on openFigureCreator me, tNewOrUpdate 
  pPropsToServer = [:]
  me.ChangeWindowView("figure_namepage.window")
  if not voidp(tNewOrUpdate) then
    me.defineModes(tNewOrUpdate)
  end if
end

on closeFigureCreator me 
  pPropsToServer = [:]
  pBodyPartObjects = void()
  if windowExists(pWindowTitle) then
    removeWindow(pWindowTitle)
  end if
  return(1)
end

on showLoadingWindow me 
  me.ChangeWindowView("figure_loading.window")
  me.blinkLoading()
  return(1)
end

on blinkLoading me 
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("reg_loading")
  if tElem = 0 then
    return(0)
  end if
  tElem.setProperty(#visible, not tElem.getProperty(#visible))
  me.delay(500, #blinkLoading)
  return(1)
end

on defineModes me, tMode 
  pTempPassword = [:]
  pPartChangeButtons = [:]
  pLastNameCheck = ""
  pMode = tMode
  if tMode = "update" then
    tUserName = getObject(#session).get(#userName)
    pNameChecked = 1
    me.NewFigureInformation()
    me.getMyInformation()
    me.createTemplateHuman()
    me.setMyDataToFields()
  else
    pNameChecked = 0
    if voidp(pPropsToServer.getAt("name")) then
      me.NewFigureInformation()
      me.createDefaultFigure()
      me.createTemplateHuman()
      me.setMyDataToFields()
    else
      me.setMyDataToFields()
    end if
  end if
  me.updateSexRadioButtons()
  me.updateFigurePreview()
  me.updateAllPrewIcons()
end

on NewFigureInformation me 
  pPropsToServer.setAt("name", "")
  pPropsToServer.setAt("figure", [:])
  pPropsToServer.setAt("sex", "M")
  pPropsToServer.setAt("customData", "")
  pPropsToServer.setAt("email", "")
  pPropsToServer.setAt("birthday", "")
  pPropsToServer.setAt("country", "")
  pPropsToServer.setAt("phoneNumber", "")
  pPropsToServer.setAt("directMail", "0")
  pPropsToServer.setAt("has_read_agreement", "0")
end

on ChangeWindowView me, tWindowName 
  if not windowExists(pWindowTitle) then
    createWindow(pWindowTitle, "habbo_basic.window", 381, 73)
    tWndObj = getWindow(pWindowTitle)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcFigurecreator, me.getID(), #mouseDown)
    tWndObj.registerProcedure(#eventProcFigurecreator, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcFigurecreator, me.getID(), #keyDown)
  else
    tWndObj = getWindow(pWindowTitle)
    tWndObj.unmerge()
  end if
  tWndObj.merge(tWindowName)
  pOpenWindow = tWindowName
end

on getMyInformation me 
  pPropsToServer = [:]
  tTempProps = ["name", "password", "figure", "sex", "customData", "email", "birthday", "country", "region", "phoneNumber", "directMail", "has_read_agreement"]
  repeat while tTempProps <= undefined
    tProp = getAt(undefined, undefined)
    if getObject(#session).exists("user_" & tProp) then
      pPropsToServer.setAt(tProp, getObject(#session).get("user_" & tProp))
    else
      pPropsToServer.setAt(tProp, "")
    end if
  end repeat
  pPropsToServer.getAt("figure").deleteProp("li")
  pPropsToServer.getAt("figure").deleteProp("ri")
  pOldFigure = pPropsToServer.getAt("figure").duplicate()
  if pPropsToServer.getAt("sex").getProp(#char, 1) = "f" or pPropsToServer.getAt("sex").getProp(#char, 1) = "F" then
    pPropsToServer.setAt("sex", "F")
  else
    pPropsToServer.setAt("sex", "M")
  end if
  pOldSex = pPropsToServer.getAt("sex")
end

on setMyDataToFields me 
  tWndObj = getWindow(pWindowTitle)
  tTempProps = [:]
  if pOpenWindow = "figure_namepage.window" then
    if pMode = "update" then
      tWndObj.getElement("char_mission_field").setFocus(1)
      tWndObj.getElement("char_name_field").setProperty(#blend, 30)
      tWndObj.getElement("char_name_field").setEdit(0)
      tWndObj.getElement("char_name_field").setText(pPropsToServer.getAt("name"))
    else
      tWndObj.getElement("char_name_field").setFocus(1)
      tWndObj.getElement("char_namepage_done_button").hide()
      tWndObj.getElement("char_page_number").setText("1/3")
    end if
    tTempProps = ["name":"char_name_field", "customData":"char_mission_field"]
  else
    if pOpenWindow = "figure_infopage.window" then
      tTempProps = ["email":"char_email_field", "phoneNumber":"char_mobile_field"]
      pTempPassword = [:]
      tDelim = the itemDelimiter
      the itemDelimiter = "."
      tWndObj.getElement("char_birth_dd_field").setText(pPropsToServer.getAt("birthday").getProp(#item, 1))
      tWndObj.getElement("char_birth_mm_field").setText(pPropsToServer.getAt("birthday").getProp(#item, 2))
      tWndObj.getElement("char_birth_yyyy_field").setText(pPropsToServer.getAt("birthday").getProp(#item, 3))
      the itemDelimiter = tDelim
      if pMode <> "update" then
        tTempProps.deleteProp("phoneNumber")
        tWndObj.getElement("char_mobile_field").setText(getText("char_defphonenum"))
        tWndObj.getElement("char_infopage_done_button").hide()
        tWndObj.getElement("char_page_number").setText("2/3")
      end if
    else
      if pOpenWindow = "figure_areapage.window" then
        tTempProps = [:]
        tSelection = tWndObj.getElement("char_continent_drop").getSelection()
        tCountryListImg = getObject("CountryMngr").getCountryListImg(tSelection)
        tWndObj.getElement("char_country_field").feedImage(tCountryListImg)
        if pMode <> "update" then
          tWndObj.getElement("char_page_number").setText("3/3")
        end if
      end if
    end if
  end if
  f = 1
  repeat while f <= tTempProps.count
    tProp = tTempProps.getPropAt(f)
    tElem = tTempProps.getAt(tProp)
    if tWndObj.elementExists(tElem) then
      tWndObj.getElement(tElem).setText(pPropsToServer.getAt(tProp))
    end if
    f = 1 + f
  end repeat
end

on getMyDataFromFields me 
  tWndObj = getWindow(pWindowTitle)
  tTempProps = [:]
  if pOpenWindow = "figure_namepage.window" then
    tTempProps = ["name":"char_name_field", "customData":"char_mission_field"]
  else
    if pOpenWindow = "figure_infopage.window" then
      tDay = tWndObj.getElement("char_birth_dd_field").getText()
      tMonth = tWndObj.getElement("char_birth_mm_field").getText()
      tYear = tWndObj.getElement("char_birth_yyyy_field").getText()
      pPropsToServer.setAt("birthday", tDay & "." & tMonth & "." & tYear)
      tTempProps = ["email":"char_email_field", "phoneNumber":"char_mobile_field"]
    else
      if pOpenWindow = "figure_areapage.window" then
        tSelection = tWndObj.getElement("char_continent_drop").getSelection(#text)
        if voidp(tSelection) then
          error(me, "Drop selection returns VOID!!!", #getMyDataFromFields)
        end if
        tContinent = getObject("CountryMngr").getContinentData(tSelection)
        if not voidp(tContinent) then
          if tContinent.type = #country then
            pPropsToServer.setAt("region", getObject("CountryMngr").getSelectedCountryID())
            pPropsToServer.setAt("country", "0")
          else
            pPropsToServer.setAt("region", tContinent.getAt(#number))
            pPropsToServer.setAt("country", getObject("CountryMngr").getSelectedCountryID())
          end if
        else
          pPropsToServer.setAt("region", "0")
          pPropsToServer.setAt("country", "0")
        end if
      end if
    end if
  end if
  f = 1
  repeat while f <= tTempProps.count
    tProp = tTempProps.getPropAt(f)
    tElem = tTempProps.getAt(tProp)
    if tWndObj.elementExists(tElem) then
      pPropsToServer.setAt(tProp, tWndObj.getElement(tElem).getText())
    end if
    f = 1 + f
  end repeat
  return(1)
end

on updateSexRadioButtons me 
  tRadioButtonOnImg = member(getmemnum("button.radio.on")).image
  tRadioButtonOffImg = member(getmemnum("button.radio.off")).image
  if voidp(pPropsToServer.getAt("sex")) then
    pPropsToServer.setAt("sex", "M")
  end if
  tWndObj = getWindow(pWindowTitle)
  if pPropsToServer.getAt("sex") contains "F" then
    if tWndObj.elementExists("char_sex_f") then
      tWndObj.getElement("char_sex_f").feedImage(tRadioButtonOnImg)
    end if
    if tWndObj.elementExists("char_sex_m") then
      tWndObj.getElement("char_sex_m").feedImage(tRadioButtonOffImg)
    end if
  else
    if tWndObj.elementExists("char_sex_m") then
      tWndObj.getElement("char_sex_m").feedImage(tRadioButtonOnImg)
    end if
    if tWndObj.elementExists("char_sex_f") then
      tWndObj.getElement("char_sex_f").feedImage(tRadioButtonOffImg)
    end if
  end if
end

on updateCheckButton me, tElement, tProp, tChangeMode 
  tOnImg = member(getmemnum("button.checkbox.on")).image
  tOffImg = member(getmemnum("button.checkbox.off")).image
  tWndObj = getWindow(pWindowTitle)
  if voidp(pPropsToServer.getAt(tProp)) then
    pPropsToServer.setAt(tProp, "1")
  end if
  if voidp(tChangeMode) then
    tChangeMode = 0
  end if
  if tChangeMode then
    if pPropsToServer.getAt(tProp) = "1" then
      pPropsToServer.setAt(tProp, "0")
    else
      pPropsToServer.setAt(tProp, "1")
    end if
  end if
  if pPropsToServer.getAt(tProp) = "1" then
    if tWndObj.elementExists(tElement) then
      tWndObj.getElement(tElement).feedImage(tOnImg)
    end if
  else
    if tWndObj.elementExists(tElement) then
      tWndObj.getElement(tElement).feedImage(tOffImg)
    end if
  end if
end

on createDefaultFigure me, tRandom 
  pPropsToServer.setAt("figure", [:])
  if not voidp(pOldFigure) and pOldSex = pPropsToServer.getAt("sex") then
    pPropsToServer.setAt("figure", pOldFigure)
    repeat while ["lh", "ls", "bd", "sh", "lg", "ch", "hd", "fc", "ey", "hr", "rh", "rs"] <= undefined
      tPart = getAt(undefined, tRandom)
      tmodel = pPropsToServer.getAt("figure").getAt(tPart).getAt("model")
      tColor = pPropsToServer.getAt("figure").getAt(tPart).getAt("color")
      me.setPartModel(tPart, tmodel)
      me.setPartColor(tPart, tColor)
    end repeat
    me.updateFigurePreview()
    me.updateAllPrewIcons()
    return()
  end if
  repeat while ["lh", "ls", "bd", "sh", "lg", "ch", "hd", "fc", "ey", "hr", "rh", "rs"] <= undefined
    tPart = getAt(undefined, tRandom)
    if voidp(tRandom) then
      tRandom = 0
    end if
    if tRandom then
      tMaxValue = me.getComponent().getCountOfPart(tPart, pPropsToServer.getAt("sex"))
      tNumber = random(tMaxValue)
    else
      tNumber = 1
    end if
    tPartProps = me.getComponent().getModelOfPartByOrderNum(tPart, tNumber, pPropsToServer.getAt("sex"))
    if tPartProps.ilk = #propList then
      tColorList = tPartProps.getAt("firstcolor")
      tSetID = tPartProps.getAt("setid")
      tColorId = 1
      if not listp(tColorList) then
        tColorList = list(tColorList)
      end if
      f = 1
      repeat while f <= tPartProps.getAt("changeparts").count
        tMultiPart = tPartProps.getAt("changeparts").getPropAt(f)
        tmodel = string(tPartProps.getAt("changeparts").getAt(tMultiPart))
        if tmodel.count(#char) = 1 then
          tmodel = "00" & tmodel
        else
          if tmodel.count(#char) = 2 then
            tmodel = "0" & tmodel
          end if
        end if
        if tColorList.count >= f then
          tColor = rgb(tColorList.getAt(f))
        else
          tColor = rgb(tColorList.getAt(1))
        end if
        me.setPartModel(tMultiPart, tmodel)
        me.setPartColor(tMultiPart, tColor)
        pPropsToServer.getAt("figure").setAt(tMultiPart, ["model":tmodel, "color":tColor, "setid":tSetID, "colorid":tColorId])
        me.setIndexNumOfPartOrColor("partcolor", tMultiPart, 0)
        f = 1 + f
      end repeat
    end if
  end repeat
  me.updateFigurePreview()
  me.updateAllPrewIcons()
end

on createTemplateHuman me 
  if not voidp(pBodyPartObjects) then
    return(0)
  end if
  tProps = pPropsToServer
  pPeopleSize = "h"
  pBuffer = image(1, 1, 8)
  pFlipList = [0, 1, 2, 3, 2, 1, 0, 7]
  pBodyPartObjects = [:]
  repeat while ["lh", "ls", "bd", "sh", "lg", "ch", "hd", "fc", "ey", "hr", "rh", "rs"] <= undefined
    tPart = getAt(undefined, undefined)
    tmodel = pPropsToServer.getAt("figure").getAt(tPart).getAt("model")
    tColor = pPropsToServer.getAt("figure").getAt(tPart).getAt("color")
    tDirection = 1
    tAction = "std"
    tAncestor = me
    tTempPartObj = createObject(#temp, "Bodypart Template Class")
    tTempPartObj.define(tPart, tmodel, tColor, tDirection, tAction, tAncestor)
    pBodyPartObjects.addProp(tPart, tTempPartObj)
  end repeat
end

on getSetID me, tPart 
  if voidp(pPropsToServer.getAt("figure").getAt(tPart)) then
    return(error(me, "Part missing:" && tPart, #getSetID))
  end if
  if voidp(pPropsToServer.getAt("figure").getAt(tPart).getAt("setid")) then
    return(error(me, "Part setid missing:" && tPart, #getSetID))
  end if
  return(pPropsToServer.getAt("figure").getAt(tPart).getAt("setid"))
end

on updateFigurePreview me 
  if not voidp(pBodyPartObjects) and windowExists(pWindowTitle) then
    tWndObj = getWindow(pWindowTitle)
    tHumanImg = image(64, 102, 16)
    me.getPartImg(["lh", "ls", "bd", "sh", "lg", "ch", "hd", "fc", "ey", "hr", "rh", "rs"], tHumanImg)
    tHumanImg = me.flipImage(tHumanImg)
    tWidth = tWndObj.getElement("human.preview.img").getProperty(#width)
    tHeight = tWndObj.getElement("human.preview.img").getProperty(#height)
    tPrewImg = image(tWidth, tHeight, 16)
    tdestrect = tPrewImg.rect - (tHumanImg.rect * 2)
    tMargins = rect(-11, -6, -11, -6)
    tdestrect = rect(tdestrect.bottom, (tHumanImg.width * 2), tPrewImg, rect.bottom) + tMargins
    tPrewImg.copyPixels(tHumanImg, tdestrect, tHumanImg.rect)
    if tWndObj.elementExists("human.preview.img") then
      tWndObj.getElement("human.preview.img").feedImage(tPrewImg)
    end if
  end if
end

on updateAllPrewIcons me 
  repeat while ["hr", "hd", "ch", "lg", "sh"] <= undefined
    tPart = getAt(undefined, undefined)
    me.setIndexNumOfPartOrColor("partcolor", tPart, 0)
    me.setIndexNumOfPartOrColor("partmodel", tPart, 0)
    if not voidp(pPropsToServer.getAt("figure").getAt(tPart).getAt("color")) then
      me.updatePartColorPreview(tPart, pPropsToServer.getAt("figure").getAt(tPart).getAt("color"))
      if ["hr", "hd", "ch", "lg", "sh"] = "hd" then
        tTemp = ["hd":pPropsToServer.getAt("figure").getAt("hd").getAt("model"), "ey":pPropsToServer.getAt("figure").getAt("ey").getAt("model"), "fc":pPropsToServer.getAt("figure").getAt("fc").getAt("model")]
        me.updatePartPreview(tPart, tTemp)
      else
        if ["hr", "hd", "ch", "lg", "sh"] = "ch" then
          tTemp = ["ls":pPropsToServer.getAt("figure").getAt("ls").getAt("model"), "ch":pPropsToServer.getAt("figure").getAt("ch").getAt("model"), "rs":pPropsToServer.getAt("figure").getAt("rs").getAt("model")]
          me.updatePartPreview(tPart, tTemp)
        else
          tTemp = [:]
          tTemp.addProp(tPart, pPropsToServer.getAt("figure").getAt(tPart).getAt("model"))
          me.updatePartPreview(tPart, tTemp)
        end if
      end if
    end if
  end repeat
end

on updatePartPreview me, tPart, tChangingPartPropList 
  tElemID = "part." & tPart & ".preview"
  tWndObj = getWindow(pWindowTitle)
  tElem = tWndObj.getElement(tElemID)
  if not voidp(pBodyPartObjects) and tElem <> 0 then
    tTempPartImg = image(64, 102, 16)
    tPartList = []
    if tPart = "hd" then
      tTempChangingParts = ["hd", "ey", "fc"]
    else
      if tPart = "ch" then
        tTempChangingParts = ["ls", "ch", "rs"]
      else
        tTempChangingParts = [tPart]
      end if
    end if
    repeat while tPart <= tChangingPartPropList
      tChancePart = getAt(tChangingPartPropList, tPart)
      tMultiPart = tChancePart
      tTempChangeParts = ["hr", "hd", "ch", "lg", "sh", "ey", "fc", "ls", "rs", "ls", "rs"]
      if tTempChangeParts.getOne(tMultiPart) > 0 then
        tmodel = string(tChangingPartPropList.getAt(tMultiPart))
        tPartList.add(tMultiPart)
        if length(tmodel) = 1 then
          tmodel = "00" & tmodel
        else
          if length(tmodel) = 2 then
            tmodel = "0" & tmodel
          end if
        end if
        me.setPartModel(tMultiPart, tmodel)
      end if
    end repeat
    me.getPartImg(tPartList, tTempPartImg)
    tTempPartImg = me.flipImage(tTempPartImg).trimWhiteSpace()
    tWidth = tElem.getProperty(#width)
    tHeight = tElem.getProperty(#height)
    tPrewImg = image(tWidth, tHeight, 16)
    tdestrect = tPrewImg.rect - tTempPartImg.rect
    tMarginH = (tPrewImg.width / 2) - (tTempPartImg.width / 2)
    tMarginV = (tPrewImg.height / 2) - (tTempPartImg.height / 2)
    tdestrect = tTempPartImg.rect + rect(tMarginH, tMarginV, tMarginH, tMarginV)
    tPrewImg.copyPixels(tTempPartImg, tdestrect, tTempPartImg.rect)
    tElem.feedImage(tPrewImg)
  end if
end

on updatePartColorPreview me, tPart, tColor 
  tElemID = "part.color." & tPart & ".preview"
  if voidp(tColor) then
    tColor = rgb(255, 255, 255)
  end if
  tWndObj = getWindow(pWindowTitle)
  if tWndObj.elementExists(tElemID) then
    tWndObj.getElement(tElemID).getProperty(#sprite).bgColor = tColor
  end if
end

on getPartImg me, tPartList, tImg 
  if tPartList.ilk <> #list then
    tPartList = [tPartList]
  end if
  repeat while tPartList <= tImg
    tPart = getAt(tImg, tPartList)
    call(#copyPicture, [pBodyPartObjects.getAt(tPart)], tImg)
  end repeat
end

on setPartColor me, tPart, tColor 
  if not voidp(pBodyPartObjects) then
    call(#setColor, [pBodyPartObjects.getAt(tPart)], tColor)
  end if
end

on setPartModel me, tPart, tmodel 
  if not voidp(pBodyPartObjects) then
    call(#setModel, [pBodyPartObjects.getAt(tPart)], tmodel)
  end if
end

on setIndexNumOfPartOrColor me, tChange, tPart, tOrderNum, tMaxValue 
  if voidp(pPartChangeButtons.getAt(tChange)) then
    pPartChangeButtons.setAt(tChange, [:])
  end if
  if voidp(pPartChangeButtons.getAt(tChange).getAt(tPart)) then
    pPartChangeButtons.getAt(tChange).setAt(tPart, [:])
  end if
  if tOrderNum = 0 then
    pPartChangeButtons.getAt(tChange).setAt(tPart, 1)
  else
    if pPartChangeButtons.getAt(tChange).getAt(tPart) + tOrderNum > tMaxValue then
      pPartChangeButtons.getAt(tChange).setAt(tPart, 1)
    else
      if pPartChangeButtons.getAt(tChange).getAt(tPart) + tOrderNum < 1 then
        pPartChangeButtons.getAt(tChange).setAt(tPart, tMaxValue)
      else
        pPartChangeButtons.getAt(tChange).setAt(tPart, pPartChangeButtons.getAt(tChange).getAt(tPart) + tOrderNum)
      end if
    end if
  end if
  return(pPartChangeButtons.getAt(tChange).getAt(tPart))
end

on changePart me, tPart, tButtonDir 
  tSetID = me.getSetID(tPart)
  if tSetID = 0 then
    return(error(me, "Incorrect part data", #changePart))
  end if
  tMaxValue = me.getComponent().getCountOfPart(tPart, pPropsToServer.getAt("sex"))
  tPartIndexNum = me.setIndexNumOfPartOrColor("partmodel", tPart, tButtonDir, tMaxValue)
  tPartProps = me.getComponent().getModelOfPartByOrderNum(tPart, tPartIndexNum, pPropsToServer.getAt("sex"))
  if tPartProps.ilk = #propList then
    tColorList = tPartProps.getAt("firstcolor")
    tSetID = tPartProps.getAt("setid")
    tColorId = 1
    if not listp(tColorList) then
      tColorList = list(tColorList)
    end if
    f = 1
    repeat while f <= tPartProps.getAt("changeparts").count
      tMultiPart = tPartProps.getAt("changeparts").getPropAt(f)
      tmodel = string(tPartProps.getAt("changeparts").getAt(tMultiPart))
      if tmodel.count(#char) = 1 then
        tmodel = "00" & tmodel
      else
        if tmodel.count(#char) = 2 then
          tmodel = "0" & tmodel
        end if
      end if
      if tColorList.count >= f then
        tColor = rgb(tColorList.getAt(f))
      else
        tColor = rgb(tColorList.getAt(1))
      end if
      me.setPartModel(tMultiPart, tmodel)
      me.setPartColor(tMultiPart, tColor)
      pPropsToServer.getAt("figure").setAt(tMultiPart, ["model":tmodel, "color":tColor, "setid":tSetID, "colorid":tColorId])
      me.setIndexNumOfPartOrColor("partcolor", tMultiPart, 0)
      f = 1 + f
    end repeat
    if not voidp(pPropsToServer.getAt("figure").getAt(tPart)) then
      if not voidp(pPropsToServer.getAt("figure").getAt(tPart).getAt("color")) then
        tColor = pPropsToServer.getAt("figure").getAt(tPart).getAt("color")
      end if
    end if
    me.updateFigurePreview()
    me.updatePartColorPreview(tPart, tColor)
    me.updatePartPreview(tPart, tPartProps.getAt("changeparts"))
  end if
end

on changePartColor me, tPart, tButtonDir 
  tSetID = me.getSetID(tPart)
  if tSetID = 0 then
    return(error(me, "Incorrect part data", #changePartColor))
  end if
  tMaxValue = me.getComponent().getCountOfPartColors(tPart, tSetID, pPropsToServer.getAt("sex"))
  tColorIndexNum = me.setIndexNumOfPartOrColor("partcolor", tPart, tButtonDir, tMaxValue)
  tPartProps = me.getComponent().getColorOfPartByOrderNum(tPart, tColorIndexNum, tSetID, pPropsToServer.getAt("sex"))
  if tPartProps.ilk = #propList then
    tColorList = tPartProps.getAt("color")
    if not listp(tColorList) then
      tColorList = list(tColorList)
    end if
    f = 1
    repeat while f <= tPartProps.getAt("changeparts").count
      tMultiPart = tPartProps.getAt("changeparts").getPropAt(f)
      if tColorList.count >= f then
        tColor = rgb(tColorList.getAt(f))
      else
        tColor = rgb(tColorList.getAt(1))
      end if
      me.setPartColor(tMultiPart, tColor)
      pPropsToServer.getAt("figure").getAt(tMultiPart).setAt("color", tColor)
      pPropsToServer.getAt("figure").getAt(tMultiPart).setAt("colorid", tColorIndexNum)
      f = 1 + f
    end repeat
    if not voidp(pPropsToServer.getAt("figure").getAt(tPart)) then
      if not voidp(pPropsToServer.getAt("figure").getAt(tPart).getAt("color")) then
        tColor = pPropsToServer.getAt("figure").getAt(tPart).getAt("color")
      end if
    end if
    me.updateFigurePreview()
    me.updatePartColorPreview(tPart, tColor)
    me.updatePartPreview(tPart, tPartProps.getAt("changeparts"))
  end if
end

on focusKeyboardToSprite me, tElemID 
  getWindow(pWindowTitle).getElement(tElemID).setFocus(1)
end

on checkName me 
  if pMode <> "update" then
    tField = getWindow(pWindowTitle).getElement("char_name_field")
    if tField = 0 then
      return(error(me, "Couldn't perform name check!", #checkName))
    end if
    tName = tField.getText().getProp(#word, 1)
    tField.setText(tName)
    if length(tName) = 0 then
      executeMessage(#alert, [#msg:"Alert_NoNameSet", #id:"nonameset"])
      return(0)
    else
      if length(tName) < getIntVariable("name.length.min", 3) then
        executeMessage(#alert, [#msg:"Alert_YourNameIstooShort", #id:"name2short"])
        me.focusKeyboardToSprite("char_name_field")
        return(0)
      else
        if pLastNameCheck <> tName then
          if me.getComponent().checkUserName(tName) = 0 then
            return(0)
          end if
        end if
      end if
    end if
  end if
  pNameChecked = 1
  return(1)
end

on checkPassword me 
  if voidp(pTempPassword.getAt("char_pw_field")) then
    tPw1 = []
  else
    tPw1 = pTempPassword.getAt("char_pw_field")
  end if
  if voidp(pTempPassword.getAt("char_pwagain_field")) then
    tPw2 = []
  else
    tPw2 = pTempPassword.getAt("char_pwagain_field")
  end if
  if tPw1.count = 0 then
    pErrorMsg = pErrorMsg & getText("Alert_ForgotSetPassword") & "\r"
    return(0)
  end if
  if tPw1.count < getIntVariable("pass.length.min", 3) then
    pErrorMsg = pErrorMsg & getText("Alert_YourPasswordIsTooShort") & "\r"
    me.ClearPasswordFields()
    return(0)
  end if
  if tPw1 <> tPw2 then
    pErrorMsg = pErrorMsg & getText("Alert_WrongPassword") & "\r"
    me.ClearPasswordFields()
    return(0)
  end if
  return(1)
end

on BirthdayANDemailcheck me 
  tWndObj = getWindow(pWindowTitle)
  tDay = integer(tWndObj.getElement("char_birth_dd_field").getText())
  tMonth = integer(tWndObj.getElement("char_birth_mm_field").getText())
  tYear = integer(tWndObj.getElement("char_birth_yyyy_field").getText())
  tBirthday = tDay & "." & tMonth & "." & tYear
  tEmail = tWndObj.getElement("char_email_field").getText()
  tBirthOK = 1
  if voidp(tDay) or tDay < 1 or tDay > 31 then
    tBirthOK = 0
  end if
  if voidp(tMonth) or tMonth < 1 or tMonth > 12 then
    tBirthOK = 0
  end if
  if voidp(tYear) or tYear < 1900 or tYear > 2100 then
    tBirthOK = 0
  end if
  tEmailOK = 0
  if length(tEmail) > 6 and tEmail contains "@" then
    f = offset("@", tEmail) + 1
    repeat while f <= length(tEmail)
      if tEmail.getProp(#char, f) = "." then
        tEmailOK = 1
      end if
      if tEmail.getProp(#char, f) = "@" then
        tEmailOK = 0
      else
        f = 1 + f
      end if
    end repeat
  end if
  if not tBirthOK then
    pErrorMsg = pErrorMsg & getText("Alert_Char_Birthday") & "\r"
  end if
  if not tEmailOK then
    pErrorMsg = pErrorMsg & getText("Alert_Char_Email") & "\r"
  end if
  if not tEmailOK or not tBirthOK then
    return(0)
  else
    return(1)
  end if
end

on checkAgreeTerms me 
  if pPropsToServer.getAt("has_read_agreement") <> "1" then
    pErrorMsg = pErrorMsg & getText("Alert_Char_Terms") & "\r"
    return(0)
  else
    return(1)
  end if
end

on userNameUnacceptable me 
  executeMessage(#alert, [#msg:"Alert_unacceptableName", #id:"namenogood"])
  me.clearUserNameField()
end

on userNameAlreadyReserved me 
  executeMessage(#alert, [#msg:"Alert_NameAlreadyUse", #id:"namereserved"])
  me.clearUserNameField()
end

on clearUserNameField me 
  pNameChecked = 0
  tElem = getWindow(pWindowTitle).getElement("char_name_field")
  if tElem = 0 then
    return(0)
  end if
  tElem.setText("")
  tElem.setFocus(1)
end

on ClearPasswordFields me 
  tWndObj = getWindow(pWindowTitle)
  tWndObj.getElement("char_pw_field").setText("")
  tWndObj.getElement("char_pwagain_field").setText("")
  pTempPassword.setAt("char_pw_field", [])
  pTempPassword.setAt("char_pwagain_field", [])
  tWndObj.getElement("char_pw_field").setFocus(1)
end

on getPassword me 
  tPw = ""
  repeat while pTempPassword.getAt("char_pw_field") <= undefined
    f = getAt(undefined, undefined)
    tPw = tPw & f
  end repeat
  return(tPw)
end

on flipImage me, tImg_a 
  tImg_b = image(tImg_a.width, tImg_a.height, tImg_a.depth)
  tQuad = [point(tImg_a.width, 0), point(0, 0), point(0, tImg_a.height), point(tImg_a.width, tImg_a.height)]
  tImg_b.copyPixels(tImg_a, tQuad, tImg_a.rect)
  return(tImg_b)
end

on eventProcFigurecreator me, tEvent, tSprID, tParm, tWndID 
  if tEvent = #mouseUp then
    if tSprID <> "close" then
      if tSprID = "char_namepage_back_button" then
        me.getComponent().closeFigureCreator()
        me.getComponent().updateState("start")
        if getObject(#session).get(#userName) = "" then
          if threadExists(#navigator) then
            getThread(#navigator).getInterface().getLogin().showLogin()
          end if
          if connectionExists(getVariable("connection.info.id")) then
            removeConnection(getVariable("connection.info.id"))
          end if
        end if
      else
        if tSprID = "char_namepage_done_button" then
          me.getMyDataFromFields()
          getObject(#session).set("user_figure", pPropsToServer.getAt("figure").duplicate())
          me.getComponent().sendFigureUpdateToServer(pPropsToServer)
          return(me.closeFigureCreator())
        else
          if tSprID = "char_namepage_next_button" then
            if pNameChecked = 0 then
              if me.checkName() = 0 then
                return(1)
              end if
            end if
            me.getMyDataFromFields()
            me.ChangeWindowView("figure_infopage.window")
            me.setMyDataToFields()
            me.updateCheckButton("char_spam_checkbox", "directMail")
            me.updateCheckButton("char_terms_checkbox", "has_read_agreement")
            if pMode = "update" then
              executeMessage(#alert, [#title:"char_note_title", #msg:"char_note_text", #id:"pwnote"])
            end if
          else
            if tSprID = "char_infopage_back_button" then
              me.getMyDataFromFields()
              me.ChangeWindowView("figure_namepage.window")
              me.setMyDataToFields()
              me.defineModes(pMode)
            else
              if tSprID <> "char_infopage_next_button" then
                if tSprID = "char_infopage_done_button" then
                  if not objectExists("CountryMngr") then
                    createObject("CountryMngr", "Country Selection Manager")
                  end if
                  pErrorMsg = ""
                  tProceed = 1
                  tProceed = tProceed and me.checkPassword()
                  tProceed = tProceed and me.BirthdayANDemailcheck()
                  tProceed = tProceed and me.checkAgreeTerms()
                  if tProceed then
                    pPropsToServer.setAt("password", getPassword())
                    me.getMyDataFromFields()
                    if tSprID = "char_infopage_done_button" then
                      getObject(#session).set(#userName, pPropsToServer.getAt("name"))
                      getObject(#session).set(#password, pPropsToServer.getAt("password"))
                      getObject(#session).set("user_figure", pPropsToServer.getAt("figure").duplicate())
                      me.getComponent().sendFigureUpdateToServer(pPropsToServer)
                      return(me.closeFigureCreator())
                    else
                      if tSprID = "char_infopage_next_button" then
                        me.ChangeWindowView("figure_areapage.window")
                        return(me.setMyDataToFields())
                      end if
                    end if
                  else
                    executeMessage(#alert, [#title:"Alert_Char_T", #msg:pErrorMsg, #id:"problems"])
                  end if
                else
                  if tSprID = "char_areapage_back_button" then
                    me.getMyDataFromFields()
                    me.ChangeWindowView("figure_infopage.window")
                    me.setMyDataToFields()
                    me.updateCheckButton("char_spam_checkbox", "directMail")
                    me.updateCheckButton("char_terms_checkbox", "has_read_agreement")
                  else
                    if tSprID = "char_areapage_done_button" then
                      me.getMyDataFromFields()
                      getObject(#session).set(#userName, pPropsToServer.getAt("name"))
                      getObject(#session).set(#password, pPropsToServer.getAt("password"))
                      getObject(#session).set("user_figure", pPropsToServer.getAt("figure").duplicate())
                      if pMode = "update" then
                        me.getComponent().sendFigureUpdateToServer(pPropsToServer)
                      else
                        me.getComponent().sendNewFigureDataToServer(pPropsToServer)
                      end if
                      return(me.getComponent().closeFigureCreator())
                    else
                      if tSprID = "char_sex_m" then
                        pPropsToServer.setAt("sex", "M")
                        me.createDefaultFigure(1)
                        me.updateSexRadioButtons()
                      else
                        if tSprID = "char_sex_f" then
                          pPropsToServer.setAt("sex", "F")
                          me.createDefaultFigure(1)
                          me.updateSexRadioButtons()
                        else
                          if tSprID = "char_spam_checkbox" then
                            me.updateCheckButton("char_spam_checkbox", "directMail", 1)
                          else
                            if tSprID = "char_terms_checkbox" then
                              me.updateCheckButton("char_terms_checkbox", "has_read_agreement", 1)
                            else
                              if tSprID = "char_name_field" then
                                if pMode <> "update" and pNameChecked = 1 then
                                  pNameChecked = 0
                                end if
                              else
                                if tSprID = "char_continent_drop" then
                                  tCountryListImg = getObject("CountryMngr").getCountryListImg(tParm)
                                  getWindow(pWindowTitle).getElement("char_country_field").feedImage(tCountryListImg)
                                else
                                  if tSprID = "char_terms_linktext" then
                                    openNetPage("url_helpterms")
                                  else
                                    if tSprID = "char_pledge_linktext" then
                                      openNetPage("url_helppledge")
                                    else
                                      if tSprID = "char_country_field" then
                                        tWndObj = getWindow(pWindowTitle)
                                        tCntryMngr = getObject("CountryMngr")
                                        tCont = tWndObj.getElement("char_continent_drop").getSelection()
                                        tLine = tCntryMngr.getClickedLineNum(tParm)
                                        tName = tCntryMngr.getNthCountryName(tLine, tCont)
                                        if tName = 0 then
                                          return(1)
                                        end if
                                        tCntryMngr.selectCountry(tName, tCont)
                                        tWndObj.getElement("char_country_field").feedImage(tCntryMngr.getCountryListImg(tCont))
                                      else
                                        if tSprID contains "change" and tSprID contains "button" then
                                          tTempDelim = the itemDelimiter
                                          the itemDelimiter = "."
                                          tPart = tSprID.getProp(#item, 2)
                                          tButtonType = tSprID.getProp(#item, tSprID.count(#item) - 1)
                                          the itemDelimiter = tTempDelim
                                          if tButtonType contains "left" then
                                            tButtonType = -1
                                          else
                                            tButtonType = 1
                                          end if
                                          if not tSprID contains "color" then
                                            me.changePart(tPart, tButtonType)
                                          else
                                            me.changePartColor(tPart, tButtonType)
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
                    end if
                  end if
                end if
                if tEvent = #keyDown then
                  if tSprID = "char_name_field" then
                    if charToNum(the key) = 0 then
                      return(0)
                    end if
                    tValidKeys = getVariable("permitted.name.chars")
                    if not tValidKeys contains the key then
                      if tSprID = 48 then
                        me.checkName()
                        return(0)
                      else
                        if tSprID = 49 then
                          return(1)
                        else
                          if tSprID = 51 then
                            return(0)
                          else
                            if tSprID = 117 then
                              getWindow(pWindowTitle).getElement(tSprID).setText("")
                              return(0)
                            else
                              if tValidKeys = "" then
                                return(0)
                              else
                                return(1)
                              end if
                            end if
                          end if
                        end if
                      end if
                    else
                      return(0)
                    end if
                  else
                    if tSprID <> "char_pw_field" then
                      if tSprID = "char_pwagain_field" then
                        if pNameChecked = 0 then
                          if not me.checkName() then
                            return(1)
                          end if
                        end if
                        if voidp(pTempPassword.getAt(tSprID)) then
                          pTempPassword.setAt(tSprID, [])
                        end if
                        if tSprID = 48 then
                          return(0)
                        else
                          if tSprID = 49 then
                            return(1)
                          else
                            if tSprID = 51 then
                              if pTempPassword.getAt(tSprID).count > 0 then
                                pTempPassword.getAt(tSprID).deleteAt(pTempPassword.getAt(tSprID).count)
                              end if
                            else
                              if tSprID = 117 then
                                pTempPassword.setAt(tSprID, [])
                              else
                                tValidKeys = getVariable("permitted.name.chars")
                                tTheKey = the key
                                tASCII = charToNum(tTheKey)
                                if tASCII > 31 and tASCII < 128 then
                                  if tValidKeys contains tTheKey or tValidKeys = "" then
                                    if pTempPassword.getAt(tSprID).count < getIntVariable("pass.length.max", 16) then
                                      pTempPassword.getAt(tSprID).append(tTheKey)
                                    else
                                      executeMessage(#alert, [#title:"alert_tooLongPW", #msg:"alert_shortenPW", #id:"pw2long"])
                                    end if
                                  end if
                                end if
                              end if
                            end if
                          end if
                        end if
                        tStr = ""
                        repeat while tSprID <= tSprID
                          tChar = getAt(tSprID, tEvent)
                        end repeat
                        getWindow(pWindowTitle).getElement(tSprID).setText(tStr)
                        the selStart = pTempPassword.getAt(tSprID).count
                        the selEnd = pTempPassword.getAt(tSprID).count
                        return(1)
                      else
                        if tSprID = "char_mission_field" then
                          if pNameChecked = 0 then
                            if not me.checkName() then
                              return(1)
                            end if
                          end if
                        else
                          if tSprID = "char_email_field" then
                            return(0)
                          else
                            if tSprID <> "char_birth_dd_field" then
                              if tSprID = "char_birth_mm_field" then
                                if tSprID = 48 then
                                  return(0)
                                else
                                  if tSprID = 51 then
                                    return(0)
                                  else
                                    if tSprID = 117 then
                                      return(0)
                                    else
                                      if getWindow(tWndID).getElement(tSprID).getText().length < 2 then
                                        return(0)
                                      else
                                        return(1)
                                      end if
                                    end if
                                  end if
                                end if
                              else
                                if tSprID = "char_birth_yyyy_field" then
                                  if tSprID = 48 then
                                    return(0)
                                  else
                                    if tSprID = 51 then
                                      return(0)
                                    else
                                      if tSprID = 117 then
                                        return(0)
                                      else
                                        if getWindow(tWndID).getElement(tSprID).getText().length < 4 then
                                          return(0)
                                        else
                                          return(1)
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
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

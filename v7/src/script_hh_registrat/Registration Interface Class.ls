property pWindowTitle, pOpenWindow, pmode, pPropsToServer, pRegProcess, pRegProcessLocation, pOldFigure, pOldSex, pBodyPartObjects, pPartChangeButtons, pLastNameCheck, pTempPassword, pErrorMsg, pNameChecked, pVerifyChangeWndID, pLastWindow

on construct me 
  pTempPassword = [:]
  pPropsToServer = [:]
  pPartChangeButtons = [:]
  pLastNameCheck = ""
  pWindowTitle = getText("win_figurecreator", "Your own Habbo")
  pOpenWindow = ""
  pRegProcessLocation = 1
  pVerifyChangeWndID = "VerifyingChangeWindow"
  pLastWindow = ""
  if not dumpVariableField("registration.props") then
    error(me, "registration props field not found!", #construct)
  end if
  if not variableExists("permitted.name.chars") then
    setVariable("permitted.name.chars", "1234567890qwertyuiopasdfghjklzxcvbnm_-=+?!@<>:.,")
  end if
  if not variableExists("denied.name.chars") then
    setVariable("denied.name.chars", "_")
  end if
  if (getVariable("fuse.project.id") = "habbo_us") then
    tRegProcessEmail = ["reg_welcome_no_age", "reg_age_check", "reg_legal", "reg_namepage", "reg_infopage_no_age", "reg_confirm", "reg_parent_email", "reg_done"]
    tRegProcess = ["reg_welcome_no_age", "reg_age_check", "reg_legal", "reg_namepage", "reg_infopage_no_age", "reg_confirm", "reg_done"]
    setVariable("parent_email.process", tRegProcessEmail)
    setVariable("registration.process", tRegProcess)
  end if
  return TRUE
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
  return TRUE
end

on showHideFigureCreator me, tNewOrUpdate 
  if windowExists(pWindowTitle) and pOpenWindow <> "reg_loading.window" then
    closeFigureCreator(me)
  else
    me.openFigureCreator(tNewOrUpdate)
  end if
end

on openFigureCreator me, tMode 
  if not voidp(tMode) then
    me.defineModes(tMode)
  end if
  tRegPages = getVariableValue(tMode & ".process")
  if tRegPages.ilk <> #list then
    tWindow = "reg_namepage.window"
    error(me, "registration process variable not found", #openFigureCreator)
  else
    if tRegPages.count > 0 then
      pRegProcessLocation = 1
      tWindow = tRegPages.getAt(1) & ".window"
    end if
  end if
  me.enterPage(tWindow)
end

on closeFigureCreator me 
  pPropsToServer = [:]
  pBodyPartObjects = void()
  if windowExists(pWindowTitle) then
    removeWindow(pWindowTitle)
  end if
  return TRUE
end

on showLoadingWindow me, tMode 
  pmode = tMode
  me.ChangeWindowView("reg_loading.window")
  me.blinkLoading()
  return TRUE
end

on finishRegistration me, tdata 
  tAgeOk = value(tdata)
  if tAgeOk then
    me.changePage(1)
  else
    me.getComponent().getRealtime()
  end if
end

on blinkLoading me 
  tWndObj = getWindow(pWindowTitle)
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("reg_loading")
  if (tElem = 0) then
    return FALSE
  end if
  tElem.setProperty(#visible, not tElem.getProperty(#visible))
  me.delay(500, #blinkLoading)
  return TRUE
end

on defineModes me, tMode 
  pPropsToServer = [:]
  pTempPassword = [:]
  pPartChangeButtons = [:]
  pLastNameCheck = ""
  pmode = tMode
  pRegProcess = getVariableValue(pmode & ".process")
  me.NewFigureInformation()
  if (pmode = "registration") or (pmode = "parent_email") then
    pNameChecked = 0
  else
    pNameChecked = 1
    me.getMyInformation()
  end if
end

on NewFigureInformation me 
  pPropsToServer.setAt("name", "")
  pPropsToServer.setAt("figure", [:])
  pPropsToServer.setAt("sex", "M")
  pPropsToServer.setAt("customData", "")
  pPropsToServer.setAt("email", "")
  pPropsToServer.setAt("birthday", "")
  pPropsToServer.setAt("has_read_agreement", "0")
  pPropsToServer.setAt("parentagree", 1)
  if getObject(#session).exists("conf_allow_direct_mail") then
    pPropsToServer.setAt("directMail", string(getObject(#session).get("conf_allow_direct_mail")))
  else
    pPropsToServer.setAt("directMail", "0")
  end if
end

on ChangeWindowView me, tWindowName 
  if not windowExists(pWindowTitle) then
    if (pmode = "forced") then
      createWindow(pWindowTitle, "habbo_simple.window", 0, 0, #modal)
    else
      createWindow(pWindowTitle, "habbo_basic.window", 381, 73)
    end if
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
  if (pmode = "forced") then
    tWndObj.center()
    tWndObj.moveBy(172, 0)
  end if
  pOpenWindow = tWindowName
end

on getMyInformation me 
  pPropsToServer = [:]
  tTempProps = ["name", "password", "figure", "sex", "customData", "email", "birthday", "directMail"]
  repeat while tTempProps <= undefined
    tProp = getAt(undefined, undefined)
    if getObject(#session).exists("user_" & tProp) then
      tdata = getObject(#session).get("user_" & tProp)
      if (tdata.ilk = #list) or (tdata.ilk = #propList) then
        pPropsToServer.setAt(tProp, tdata.duplicate())
      else
        pPropsToServer.setAt(tProp, tdata)
      end if
    else
      pPropsToServer.setAt(tProp, "")
    end if
  end repeat
  pPropsToServer.getAt("figure").deleteProp("li")
  pPropsToServer.getAt("figure").deleteProp("ri")
  pOldFigure = pPropsToServer.getAt("figure").duplicate()
  if (pPropsToServer.getAt("sex").getProp(#char, 1) = "f") or (pPropsToServer.getAt("sex").getProp(#char, 1) = "F") then
    pPropsToServer.setAt("sex", "F")
  else
    pPropsToServer.setAt("sex", "M")
  end if
  pOldSex = pPropsToServer.getAt("sex")
end

on setMyDataToFields me 
  tWndObj = getWindow(pWindowTitle)
  tTempProps = [:]
  if (pOpenWindow = "reg_welcome.window") then
    if (pmode = "forced") or (pmode = "parent_email_forced") then
      if tWndObj.elementExists("reg_exit_button") then
        tWndObj.getElement("reg_exit_button").hide()
      end if
      tWndObj.getElement("reg_welcome_balloon").setText(getText("reg_forcedupdate"))
      tWndObj.getElement("reg_welcome_header").setText(getText("reg_forcedupdate2"))
      tWndObj.getElement("reg_welcome_txt").setText(getText("reg_forcedupdate3"))
    end if
  else
    if (pOpenWindow = "reg_coppa_forced.window") then
      if tWndObj.elementExists("reg_exit_button") then
        tWndObj.getElement("reg_exit_button").hide()
      end if
      tWndObj.getElement("reg_welcome_balloon").setText(getText("reg_forcedupdate"))
      tWndObj.getElement("reg_welcome_header").setText(getText("reg_forcedupdate2"))
      tWndObj.getElement("reg_welcome_txt").setText(getText("reg_forcedupdate3"))
    else
      if (pOpenWindow = "reg_legal.window") then
        if (pPropsToServer.getAt("parentagree") = 0) then
          tWndObj.getElement("reg_legal_header").setText(getText("reg_legal_header2"))
          tWndObj.getElement("reg_agree_text").setText(getText("reg_agree2"))
        end if
      else
        if (pOpenWindow = "reg_namepage.window") then
          if (pmode = "registration") or (pmode = "parent_email") then
            tWndObj.getElement("char_name_field").setFocus(1)
          else
            tWndObj.getElement("char_mission_field").setFocus(1)
            tWndObj.getElement("char_name_field").setProperty(#blend, 30)
            tWndObj.getElement("char_name_field").setEdit(0)
            tWndObj.getElement("char_name_field").setText(pPropsToServer.getAt("name"))
          end if
          tTempProps = ["name":"char_name_field", "customData":"char_mission_field"]
        else
          if (pOpenWindow = "reg_infopage.window") then
            tTempProps = ["email":"char_email_field"]
            pTempPassword = [:]
            if (pmode = "registration") or (pmode = "parent_email") then
              tWndObj.getElement("char_birth_dd_field").setEdit(1)
              tWndObj.getElement("char_birth_mm_field").setEdit(1)
              tWndObj.getElement("char_birth_yyyy_field").setEdit(1)
            else
              tField = tWndObj.getElement("char_birth_dd_field")
              tField.setEdit(0)
              tField.setProperty(#blend, 30)
              tField = tWndObj.getElement("char_birth_mm_field")
              tField.setEdit(0)
              tField.setProperty(#blend, 30)
              tField = tWndObj.getElement("char_birth_yyyy_field")
              tField.setEdit(0)
              tField.setProperty(#blend, 30)
            end if
            tDelim = the itemDelimiter
            the itemDelimiter = "."
            tWndObj.getElement("char_birth_dd_field").setText(pPropsToServer.getAt("birthday").getProp(#item, 1))
            tWndObj.getElement("char_birth_mm_field").setText(pPropsToServer.getAt("birthday").getProp(#item, 2))
            tWndObj.getElement("char_birth_yyyy_field").setText(pPropsToServer.getAt("birthday").getProp(#item, 3))
            the itemDelimiter = tDelim
            me.updateCheckButton("char_spam_checkbox", "directMail")
          else
            if (pOpenWindow = "reg_infopage_no_age.window") then
              me.updateCheckButton("char_spam_checkbox", "directMail")
            else
              if (pOpenWindow = "reg_confirm.window") then
                if tWndObj.elementExists("reg_name") then
                  tText = getText("reg_check_name", "reg_check_name") && pPropsToServer.getAt("name")
                  tWndObj.getElement("reg_name").setText(tText)
                end if
                if tWndObj.elementExists("reg_age") then
                  tText = getText("reg_check_age", "reg_check_age") && pPropsToServer.getAt("birthday")
                  tWndObj.getElement("reg_age").setText(tText)
                end if
                if tWndObj.elementExists("reg_mail") then
                  tText = getText("reg_check_mail", "reg_check_mail") && pPropsToServer.getAt("email")
                  tWndObj.getElement("reg_mail").setText(tText)
                end if
              end if
            end if
          end if
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
    f = (1 + f)
  end repeat
  if pRegProcess <> 0 and (pRegProcessLocation.ilk = #integer) then
    if tWndObj.elementExists("reg_page_number") then
      if pmode <> "update" then
        tText = pRegProcessLocation & "/" & pRegProcess.count
        tWndObj.getElement("reg_page_number").setText(tText)
      end if
    end if
    if (pmode = "update") and (pRegProcessLocation = 1) then
      if tWndObj.elementExists("reg_prev_button") then
        tWndObj.getElement("reg_prev_button").hide()
      end if
    else
      if (pmode = "update") and pRegProcessLocation <> 1 then
        if tWndObj.elementExists("reg_cancel_button") then
          tWndObj.getElement("reg_cancel_button").hide()
        end if
      else
        if pmode <> "update" then
          if tWndObj.elementExists("reg_done_button") then
            tWndObj.getElement("reg_done_button").hide()
          end if
          if tWndObj.elementExists("reg_cancel_button") then
            tWndObj.getElement("reg_cancel_button").hide()
          end if
        end if
      end if
    end if
    if (pRegProcessLocation = pRegProcess.count) then
      if pmode <> "registration" and pmode <> " parent_email" then
        if tWndObj.elementExists("reg_done_button") and tWndObj.elementExists("reg_page_number") then
          tWndObj.getElement("reg_done_button").show()
          tWndObj.getElement("reg_next_button").hide()
          tMoveX = (tWndObj.getElement("reg_next_button").getProperty(#locH) - tWndObj.getElement("reg_done_button").getProperty(#locH))
          tMoveX = (tWndObj.getElement("reg_done_button").getProperty(#locH) + tMoveX)
          tWndObj.getElement("reg_done_button").setProperty(#locH, tMoveX)
          tText = pRegProcessLocation & "/" & pRegProcess.count
          if tWndObj.elementExists("reg_page_number") then
            tWndObj.getElement("reg_page_number").setText(tText)
          end if
        end if
      end if
    end if
  end if
end

on getMyDataFromFields me 
  tWndObj = getWindow(pWindowTitle)
  tTempProps = [:]
  if (pOpenWindow = "reg_namepage.window") then
    tTempProps = ["name":"char_name_field", "customData":"char_mission_field"]
  else
    if (pOpenWindow = "reg_infopage.window") then
      tDay = integer(tWndObj.getElement("char_birth_dd_field").getText())
      tMonth = integer(tWndObj.getElement("char_birth_mm_field").getText())
      tYear = integer(tWndObj.getElement("char_birth_yyyy_field").getText())
      if tDay < 10 then
        tDay = "0" & tDay
      end if
      if tMonth < 10 then
        tMonth = "0" & tMonth
      end if
      pPropsToServer.setAt("birthday", tDay & "." & tMonth & "." & tYear)
      tTempProps = ["email":"char_email_field"]
    else
      if (pOpenWindow = "reg_infopage_no_age.window") then
        tTempProps = ["email":"char_email_field"]
      end if
    end if
  end if
  f = 1
  repeat while f <= tTempProps.count
    tProp = tTempProps.getPropAt(f)
    tElem = tTempProps.getAt(tProp)
    if tWndObj.elementExists(tElem) then
      tElemTxt = getStringServices().convertSpecialChars(tWndObj.getElement(tElem).getText(), 1)
      pPropsToServer.setAt(tProp, tElemTxt)
    end if
    f = (1 + f)
  end repeat
  return TRUE
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
    pPropsToServer.setAt(tProp, "0")
  end if
  if voidp(tChangeMode) then
    tChangeMode = 0
  end if
  if tChangeMode then
    if (pPropsToServer.getAt(tProp) = "1") then
      pPropsToServer.setAt(tProp, "0")
    else
      pPropsToServer.setAt(tProp, "1")
    end if
  end if
  if (pPropsToServer.getAt(tProp) = "1") then
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
  if not objectExists("Figure_System") then
    return(error(me, "Figure system object not found", #createDefaultFigure))
  end if
  pPropsToServer.setAt("figure", [:])
  if not voidp(pOldFigure) and (pOldSex = pPropsToServer.getAt("sex")) then
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
      tMaxValue = getObject("Figure_System").getCountOfPart(tPart, pPropsToServer.getAt("sex"))
      tNumber = random(tMaxValue)
    else
      tNumber = 1
    end if
    tPartProps = getObject("Figure_System").getModelOfPartByOrderNum(tPart, tNumber, pPropsToServer.getAt("sex"))
    if (tPartProps.ilk = #propList) then
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
        if (tmodel.count(#char) = 1) then
          tmodel = "00" & tmodel
        else
          if (tmodel.count(#char) = 2) then
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
        f = (1 + f)
      end repeat
    end if
  end repeat
  me.updateFigurePreview()
  me.updateAllPrewIcons()
end

on createTemplateHuman me 
  if not voidp(pBodyPartObjects) then
    return FALSE
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
    if tWndObj.elementExists("human.preview.img") then
      tHumanImg = image(64, 102, 16)
      me.getPartImg(["lh", "ls", "bd", "sh", "lg", "ch", "hd", "fc", "ey", "hr", "rh", "rs"], tHumanImg)
      tHumanImg = me.flipImage(tHumanImg)
      tWidth = tWndObj.getElement("human.preview.img").getProperty(#width)
      tHeight = tWndObj.getElement("human.preview.img").getProperty(#height)
      tPrewImg = image(tWidth, tHeight, 16)
      tdestrect = (tPrewImg.rect - (tHumanImg.rect * 2))
      tMargins = rect(-11, -6, -11, -6)
      tdestrect = (rect(0, tdestrect.bottom, (tHumanImg.width * 2), tPrewImg.rect.bottom) + tMargins)
      tPrewImg.copyPixels(tHumanImg, tdestrect, tHumanImg.rect)
      if tWndObj.elementExists("human.preview.img") then
        tWndObj.getElement("human.preview.img").feedImage(tPrewImg)
      end if
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
      if (["hr", "hd", "ch", "lg", "sh"] = "hd") then
        tTemp = ["hd":pPropsToServer.getAt("figure").getAt("hd").getAt("model"), "ey":pPropsToServer.getAt("figure").getAt("ey").getAt("model"), "fc":pPropsToServer.getAt("figure").getAt("fc").getAt("model")]
        me.updatePartPreview(tPart, tTemp)
      else
        if (["hr", "hd", "ch", "lg", "sh"] = "ch") then
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
    if (tPart = "hd") then
      tTempChangingParts = ["hd", "ey", "fc"]
    else
      if (tPart = "ch") then
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
        if (length(tmodel) = 1) then
          tmodel = "00" & tmodel
        else
          if (length(tmodel) = 2) then
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
    tdestrect = (tPrewImg.rect - tTempPartImg.rect)
    tMarginH = ((tPrewImg.width / 2) - (tTempPartImg.width / 2))
    tMarginV = ((tPrewImg.height / 2) - (tTempPartImg.height / 2))
    tdestrect = (tTempPartImg.rect + rect(tMarginH, tMarginV, tMarginH, tMarginV))
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
  if (tOrderNum = 0) then
    pPartChangeButtons.getAt(tChange).setAt(tPart, 1)
  else
    if (pPartChangeButtons.getAt(tChange).getAt(tPart) + tOrderNum) > tMaxValue then
      pPartChangeButtons.getAt(tChange).setAt(tPart, 1)
    else
      if (pPartChangeButtons.getAt(tChange).getAt(tPart) + tOrderNum) < 1 then
        pPartChangeButtons.getAt(tChange).setAt(tPart, tMaxValue)
      else
        pPartChangeButtons.getAt(tChange).setAt(tPart, (pPartChangeButtons.getAt(tChange).getAt(tPart) + tOrderNum))
      end if
    end if
  end if
  return(pPartChangeButtons.getAt(tChange).getAt(tPart))
end

on changePart me, tPart, tButtonDir 
  if not objectExists("Figure_System") then
    return(error(me, "Figure system object not found", #changePart))
  end if
  tSetID = me.getSetID(tPart)
  if (tSetID = 0) then
    return(error(me, "Incorrect part data", #changePart))
  end if
  tMaxValue = getObject("Figure_System").getCountOfPart(tPart, pPropsToServer.getAt("sex"))
  tPartIndexNum = me.setIndexNumOfPartOrColor("partmodel", tPart, tButtonDir, tMaxValue)
  tPartProps = getObject("Figure_System").getModelOfPartByOrderNum(tPart, tPartIndexNum, pPropsToServer.getAt("sex"))
  if (tPartProps.ilk = #propList) then
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
      if (tmodel.count(#char) = 1) then
        tmodel = "00" & tmodel
      else
        if (tmodel.count(#char) = 2) then
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
      f = (1 + f)
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
  if not objectExists("Figure_System") then
    return(error(me, "Figure system object not found", #changePartColor))
  end if
  tSetID = me.getSetID(tPart)
  if (tSetID = 0) then
    return(error(me, "Incorrect part data", #changePartColor))
  end if
  tMaxValue = getObject("Figure_System").getCountOfPartColors(tPart, tSetID, pPropsToServer.getAt("sex"))
  tColorIndexNum = me.setIndexNumOfPartOrColor("partcolor", tPart, tButtonDir, tMaxValue)
  tPartProps = getObject("Figure_System").getColorOfPartByOrderNum(tPart, tColorIndexNum, tSetID, pPropsToServer.getAt("sex"))
  if (tPartProps.ilk = #propList) then
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
      f = (1 + f)
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
  if (pmode = "registration") or (pmode = "parent_email") then
    tField = getWindow(pWindowTitle).getElement("char_name_field")
    if (tField = 0) then
      return(error(me, "Couldn't perform name check!", #checkName))
    end if
    tName = tField.getText().getProp(#word, 1)
    tField.setText(tName)
    if (length(tName) = 0) then
      executeMessage(#alert, [#msg:"Alert_NoNameSet", #id:"nonameset", #modal:1])
      return FALSE
    else
      if length(tName) < getIntVariable("name.length.min", 3) then
        executeMessage(#alert, [#msg:"Alert_YourNameIstooShort", #id:"name2short", #modal:1])
        me.focusKeyboardToSprite("char_name_field")
        return FALSE
      else
        if pLastNameCheck <> tName then
          if (me.getComponent().checkUserName(tName) = 0) then
            return FALSE
          end if
        end if
      end if
    end if
  end if
  getObject(#session).set(#userName, tName)
  pNameChecked = 1
  return TRUE
end

on checkPassword me 
  if voidp(pTempPassword.getAt("char_pw_field")) then
    tPw1 = ""
  else
    i = 1
    repeat while i <= pTempPassword.getAt("char_pw_field").count
      tPw1 = tPw1 & pTempPassword.getAt("char_pw_field").getAt(i)
      i = (1 + i)
    end repeat
  end if
  if voidp(pTempPassword.getAt("char_pwagain_field")) then
    tPw2 = ""
  else
    i = 1
    repeat while i <= pTempPassword.getAt("char_pwagain_field").count
      tPw2 = tPw2 & pTempPassword.getAt("char_pwagain_field").getAt(i)
      i = (1 + i)
    end repeat
  end if
  if not me.checkPasswordsEnforced(tPw1, tPw2) then
    me.ClearPasswordFields()
    return FALSE
  else
    return TRUE
  end if
end

on checkPasswordsEnforced me, tPw1, tPw2 
  if (tPw1.length = 0) then
    pErrorMsg = getText("Alert_WrongPassword") & "\r"
    return FALSE
  end if
  if tPw1 <> tPw2 then
    pErrorMsg = getText("Alert_WrongPassword") & "\r"
    return FALSE
  end if
  tMinPwdLen = getIntVariable("pass.length.min.patched", -1)
  if (tMinPwdLen = -1) then
    tMinPwdLen = getIntVariable("pass.length.min", 6)
  end if
  if tPw1.length < tMinPwdLen then
    pErrorMsg = getText("Alert_YourPasswordIsTooShort") & "\r"
    return FALSE
  else
    if tPw1.length > getIntVariable("pass.length.max", 32) then
      pErrorMsg = getText("Alert_YourPasswordIsTooLong") & "\r"
      return FALSE
    else
      tNumTestOK = 0
      c = 48
      repeat while c <= 57
        if offset(numToChar(c), tPw1) > 0 then
          tNumTestOK = 1
        else
          c = (1 + c)
        end if
      end repeat
    end if
  end if
  if not tNumTestOK then
    pErrorMsg = getText("reg_passwordContainsNoNumber") & "\r"
    return FALSE
  end if
  if not getObject(#session).exists(#userName) then
    return TRUE
  end if
  if (getObject(#session).get(#userName) = "") then
    return TRUE
  end if
  tNameStr = getObject(#session).get(#userName)
  tPasswordRevStr = ""
  if tNameStr.length < 3 then
    return TRUE
  end if
  i = tPw1.length
  repeat while i >= 1
    tPasswordRevStr = tPasswordRevStr & chars(tPw1, i, i)
    i = (255 + i)
  end repeat
  tSimilarityConflict = tNameStr contains tPw1 or tNameStr contains tPasswordRevStr or tPw1 contains tNameStr or tPasswordRevStr contains tNameStr
  if tSimilarityConflict then
    pErrorMsg = getText("reg_nameAndPassTooSimilar") & "\r"
    return FALSE
  end if
  return TRUE
end

on BirthdayANDemailcheck me 
  tWndObj = getWindow(pWindowTitle)
  tDay = integer(tWndObj.getElement("char_birth_dd_field").getText())
  tMonth = integer(tWndObj.getElement("char_birth_mm_field").getText())
  tYear = integer(tWndObj.getElement("char_birth_yyyy_field").getText())
  tEmail = tWndObj.getElement("char_email_field").getText()
  tBirthOK = 1
  if (pmode = "registration") or (pmode = "parent_email") then
    if voidp(tDay) or tDay < 1 or tDay > 31 then
      tBirthOK = 0
    end if
    if voidp(tMonth) or tMonth < 1 or tMonth > 12 then
      tBirthOK = 0
    end if
    if voidp(tYear) or tYear < 1900 or tYear > 2100 then
      tBirthOK = 0
    end if
    if (tBirthOK = 1) and getObject(#session).exists("server_date") then
      tServerDate = getObject(#session).get("server_date")
      tDelim = the itemDelimiter
      the itemDelimiter = "."
      tServerDay = integer(tServerDate.getProp(#item, 1))
      tServerMonth = integer(tServerDate.getProp(#item, 2))
      tServerYear = integer(tServerDate.getProp(#item, 3))
      if tYear > tServerYear then
        tBirthOK = 0
      else
        if tMonth > tServerMonth and (tYear = tServerYear) then
          tBirthOK = 0
        else
          if tDay > tServerDay and (tMonth = tServerMonth) and (tYear = tServerYear) then
            tBirthOK = 0
          end if
        end if
      end if
      the itemDelimiter = tDelim
    end if
  end if
  tEmailOK = 0
  if length(tEmail) > 6 and tEmail contains "@" then
    f = (offset("@", tEmail) + 1)
    repeat while f <= length(tEmail)
      if (tEmail.getProp(#char, f) = ".") then
        tEmailOK = 1
      end if
      if (tEmail.getProp(#char, f) = "@") then
        tEmailOK = 0
      else
        f = (1 + f)
      end if
    end repeat
  end if
  if not tBirthOK then
    pErrorMsg = pErrorMsg & getText("alert_reg_birthday") & "\r"
  end if
  if not tEmailOK then
    pErrorMsg = pErrorMsg & getText("alert_reg_email") & "\r"
  end if
  if not tEmailOK or not tBirthOK then
    return FALSE
  else
    return TRUE
  end if
end

on emailCheck me 
  tWndObj = getWindow(pWindowTitle)
  tEmail = tWndObj.getElement("char_email_field").getText()
  tEmailOK = 0
  if length(tEmail) > 6 and tEmail contains "@" then
    f = (offset("@", tEmail) + 1)
    repeat while f <= length(tEmail)
      if (tEmail.getProp(#char, f) = ".") then
        tEmailOK = 1
      end if
      if (tEmail.getProp(#char, f) = "@") then
        tEmailOK = 0
      else
        f = (1 + f)
      end if
    end repeat
  end if
  if not tEmailOK then
    pErrorMsg = pErrorMsg & getText("alert_reg_email") & "\r"
  end if
  if tEmailOK then
    return TRUE
  else
    return FALSE
  end if
end

on checkAgreeTerms me 
  if (getText("reg_terms") = "reg_terms") then
    return FALSE
  end if
  tWndObj = getWindow(pWindowTitle)
  if tWndObj.elementExists("reg_termstxt") then
    tScroll = tWndObj.getElement("char_scrollbar").getScrollOffset()
    tMaxH = (tWndObj.getElement("reg_termstxt").getProperty(#image).height - tWndObj.getElement("reg_termstxt").getProperty(#height))
    if (tScroll + 2) < tMaxH then
      pErrorMsg = pErrorMsg & getText("reg_readterms_alert") & "\r"
      return FALSE
    end if
  else
    return FALSE
  end if
  if pPropsToServer.getAt("has_read_agreement") <> "1" then
    pErrorMsg = pErrorMsg & getText("reg_agree_alert") & "\r"
    return FALSE
  else
    return TRUE
  end if
end

on userNameOk me 
  if (pOpenWindow = "reg_loading.window") then
    me.changePage(1)
  end if
end

on userNameUnacceptable me 
  if (pOpenWindow = "reg_loading.window") then
    me.changePage("reg_namepage.window")
  end if
  executeMessage(#alert, [#msg:"Alert_unacceptableName", #id:"namenogood", #modal:1])
  me.clearUserNameField()
end

on userNameTooLong me 
  if (pOpenWindow = "reg_loading.window") then
    me.changePage("reg_namepage.window")
  end if
  executeMessage(#alert, [#msg:"Alert_NameTooLong", #id:"nametoolong", #modal:1])
end

on userNameAlreadyReserved me 
  if (pOpenWindow = "reg_loading.window") then
    me.changePage("reg_namepage.window")
  end if
  executeMessage(#alert, [#msg:"Alert_NameAlreadyUse", #id:"namereserved", #modal:1])
  me.clearUserNameField()
end

on parentEmailQueryStatus me, tFlag 
  if (pmode = "parent_email") then
    if not tFlag then
      if (pOpenWindow = "reg_loading.window") then
        me.changePage(1)
      end if
    else
      me.parentEmailNotNeeded()
      me.changePage(1)
    end if
  else
    if (tFlag = 1) then
      me.parentEmailNotNeeded()
    end if
  end if
end

on parentEmailNotNeeded me 
  if (pRegProcess.ilk = #list) then
    tPos = pRegProcess.findPos("reg_parent_email")
    if tPos > 0 then
      pRegProcess.deleteAt(tPos)
    end if
  end if
end

on parentEmailOk me 
  if (pRegProcess.ilk = #list) then
    if (pmode = "parent_email") then
      tPos = pRegProcess.findPos("reg_parent_email")
      tNextPage = pRegProcess.getAt((tPos + 1))
      me.changePage(tNextPage & ".window")
    else
      if (pRegProcessLocation = pRegProcess.count) then
        getObject(#session).set("user_figure", pPropsToServer.getAt("figure").duplicate())
        me.getComponent().sendFigureUpdateToServer(pPropsToServer)
        me.getComponent().updateState("start")
        return(me.closeFigureCreator())
      else
        tPos = pRegProcess.findPos("reg_parent_email")
        tNextPage = pRegProcess.getAt((tPos + 1))
        me.changePage(tNextPage & ".window")
      end if
    end if
  end if
end

on parentEmailIncorrect me 
  if pOpenWindow <> "reg_parent_email.window" then
    me.changePage("reg_parent_email.window")
  end if
  executeMessage(#alert, [#msg:"alert_reg_parent_email", #id:"parentemailincorrect", #modal:1])
  return FALSE
end

on clearUserNameField me 
  pNameChecked = 0
  tElem = getWindow(pWindowTitle).getElement("char_name_field")
  if (tElem = 0) then
    return FALSE
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

on registrationReady me 
  getObject(#session).set(#userName, pPropsToServer.getAt("name"))
  getObject(#session).set(#password, pPropsToServer.getAt("password"))
  getObject(#session).set("user_figure", pPropsToServer.getAt("figure").duplicate())
  if (pmode = "registration") or (pmode = "parent_email") then
    if objectExists("Figure_Preview") then
      getObject("Figure_Preview").createTemplateHuman("h", 3, "remove")
    end if
    me.getComponent().sendNewFigureDataToServer(pPropsToServer)
  else
    me.getComponent().sendFigureUpdateToServer(pPropsToServer)
  end if
end

on changePage me, tParm 
  if voidp(tParm) then
    tParm = 1
  end if
  if (pRegProcess = 0) then
    return(error(me, "registration process not found", #changePage))
  end if
  if (tParm.ilk = #string) then
    me.getMyDataFromFields()
    me.enterPage(tParm)
  else
    if (tParm.ilk = #integer) then
      if tParm > 0 then
        if (me.leavePage(pOpenWindow) = 0) then
          return FALSE
        end if
      else
        me.getMyDataFromFields()
      end if
      pRegProcessLocation = (pRegProcessLocation + tParm)
      if pRegProcessLocation < 1 then
        pRegProcessLocation = 1
      end if
      if pRegProcessLocation > pRegProcess.count then
        pRegProcessLocation = pRegProcess.count
      end if
      tNextWindow = pRegProcess.getAt(pRegProcessLocation)
      me.enterPage(tNextWindow & ".window")
    end if
  end if
end

on leavePage me, tCurrentWindow 
  if (tCurrentWindow = "reg_legal.window") then
    pErrorMsg = ""
    tProceed = 1
    tProceed = tProceed and me.checkAgreeTerms()
    if tProceed then
      me.getMyDataFromFields()
    else
      executeMessage(#alert, [#title:"alert_reg_t", #msg:pErrorMsg, #id:"problems", #modal:1])
      return FALSE
    end if
  else
    if (tCurrentWindow = "reg_namepage.window") then
      me.getMyDataFromFields()
      if (pNameChecked = 0) then
        if (me.checkName() = 1) then
          me.ChangeWindowView("reg_loading.window")
        end if
        return FALSE
      end if
    else
      if (tCurrentWindow = "reg_infopage.window") then
        pErrorMsg = ""
        tProceed = 1
        tProceed = tProceed and me.checkPassword()
        tProceed = tProceed and me.BirthdayANDemailcheck()
        if tProceed then
          pPropsToServer.setAt("password", getPassword())
          me.getMyDataFromFields()
        else
          executeMessage(#alert, [#title:"alert_reg_t", #msg:pErrorMsg, #id:"problems", #modal:1])
          return FALSE
        end if
        if (pmode = "parent_email") then
          if me.getComponent().getParentEmailNeededFlag() <> 1 then
            tItemD = the itemDelimiter
            the itemDelimiter = "."
            tBirthday = pPropsToServer.getAt("birthday").getProp(#item, 3) & "." & pPropsToServer.getAt("birthday").getProp(#item, 2) & "." & pPropsToServer.getAt("birthday").getProp(#item, 1)
            the itemDelimiter = tItemD
            tHabboID = pPropsToServer.getAt("name")
            me.getComponent().parentEmailNeedGuery(tBirthday, tHabboID)
            me.ChangeWindowView("reg_loading.window")
            return FALSE
          end if
        end if
      else
        if (tCurrentWindow = "reg_confirm.window") then
          if getObject(#session).get("conf_coppa") then
            tItemD = the itemDelimiter
            the itemDelimiter = "."
            tdata = pPropsToServer.getAt("birthday").getProp(#item, 3) & "." & pPropsToServer.getAt("birthday").getProp(#item, 2) & "." & pPropsToServer.getAt("birthday").getProp(#item, 1)
            the itemDelimiter = tItemD
            me.getComponent().checkAge(tdata)
            me.ChangeWindowView("reg_loading.window")
            return FALSE
          else
            return TRUE
          end if
        else
          if (tCurrentWindow = "reg_parent_email.window") then
            tWndObj = getWindow(pWindowTitle)
            tParentEmail = tWndObj.getElement("reg_parent_email_field").getText()
            tUserEmail = pPropsToServer.getAt("email")
            if (tParentEmail = "") then
              return(me.parentEmailIncorrect())
            end if
            me.getComponent().validateParentEmail(tUserEmail, tParentEmail)
            me.ChangeWindowView("reg_loading.window")
            return FALSE
          else
            if (tCurrentWindow = "reg_age_check.window") then
              tWndObj = getWindow(pWindowTitle)
              tDay = integer(tWndObj.getElement("char_birth_dd_field").getText())
              tMonth = integer(tWndObj.getElement("char_birth_mm_field").getText())
              tYear = integer(tWndObj.getElement("char_birth_yyyy_field").getText())
              if voidp(tDay) or voidp(tMonth) or voidp(tYear) or tYear < 1900 or tMonth > 12 or tDay > 31 then
                executeMessage(#alert, [#title:"alert_reg_t", #msg:"Alert_CheckBirthday", #id:"problems", #modal:1])
                return FALSE
              end if
              if tDay < 10 then
                tDay = "0" & tDay
              end if
              if tMonth < 10 then
                tMonth = "0" & tMonth
              end if
              tdata = tYear & "." & tMonth & "." & tDay
              pPropsToServer.setAt("birthday", tDay & "." & tMonth & "." & tYear)
              me.getComponent().checkAge(tdata)
              me.ChangeWindowView("reg_loading.window")
              return FALSE
            else
              if (tCurrentWindow = "reg_infopage_no_age.window") then
                pErrorMsg = ""
                tProceed = me.checkPassword()
                tProceed = tProceed and me.emailCheck()
                if tProceed then
                  pPropsToServer.setAt("password", getPassword())
                  me.getMyDataFromFields()
                else
                  executeMessage(#alert, [#title:"alert_reg_t", #msg:pErrorMsg, #id:"problems", #modal:1])
                  return FALSE
                end if
                if (pmode = "parent_email") then
                  if me.getComponent().getParentEmailNeededFlag() <> 1 then
                    tItemD = the itemDelimiter
                    the itemDelimiter = "."
                    tBirthday = pPropsToServer.getAt("birthday").getProp(#item, 3) & "." & pPropsToServer.getAt("birthday").getProp(#item, 2) & "." & pPropsToServer.getAt("birthday").getProp(#item, 1)
                    the itemDelimiter = tItemD
                    tHabboID = pPropsToServer.getAt("name")
                    me.getComponent().parentEmailNeedGuery(tBirthday, tHabboID)
                    me.ChangeWindowView("reg_loading.window")
                    return FALSE
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return TRUE
end

on enterPage me, tWindow 
  me.ChangeWindowView(tWindow)
  if (tWindow = "reg_legal.window") then
    me.setMyDataToFields()
    me.updateCheckButton("char_terms_checkbox", "has_read_agreement")
  else
    if (tWindow = "reg_namepage.window") then
      me.setMyDataToFields()
      if (pmode = "registration") or (pmode = "parent_email") then
        pNameChecked = 0
      else
        pNameChecked = 1
      end if
      if (pPropsToServer.getAt("figure").count = 0) then
        me.createDefaultFigure()
      end if
      me.createTemplateHuman()
      me.updateSexRadioButtons()
      me.updateFigurePreview()
      me.updateAllPrewIcons()
    else
      if (tWindow = "reg_infopage.window") then
        me.setMyDataToFields()
        me.updateCheckButton("char_spam_checkbox", "directMail")
        if (pmode = "update") then
          executeMessage(#alert, [#title:"reg_note_title", #msg:"reg_note_text", #id:"pwnote", #modal:1])
        end if
      else
        if (tWindow = "reg_infopage_no_age") then
          me.setMyDataToFields()
          me.updateCheckButton("char_spam_checkbox", "directMail")
        else
          if (tWindow = "reg_info_update.window") then
            me.setMyDataToFields()
            me.updateCheckButton("char_spam_checkbox", "directMail")
            tWinObj = getWindow(pWindowTitle)
            tStr = tWinObj.getElement("update_change_email").getText()
            tStr = tStr & " >>"
            tWinObj.getElement("update_change_email").setText(tStr)
            tStr = tWinObj.getElement("update_change_pwd").getText()
            tStr = tStr & " >>"
            tWinObj.getElement("update_change_pwd").setText(tStr)
          else
            if (tWindow = "reg_done.window") then
              getObject(#session).set("user_figure", pPropsToServer.getAt("figure").duplicate())
              if objectExists("Figure_Preview") then
                tBuffer = getObject("Figure_Preview").createTemplateHuman("h", 2, "gest", "temp sml")
                getWindow(pWindowTitle).getElement("reg_ownhabbo").setProperty(#buffer, tBuffer)
              end if
            else
              me.setMyDataToFields()
            end if
          end if
        end if
      end if
    end if
  end if
end

on flipImage me, tImg_a 
  tImg_b = image(tImg_a.width, tImg_a.height, tImg_a.depth)
  tQuad = [point(tImg_a.width, 0), point(0, 0), point(0, tImg_a.height), point(tImg_a.width, tImg_a.height)]
  tImg_b.copyPixels(tImg_a, tQuad, tImg_a.rect)
  return(tImg_b)
end

on highlightVerifyTopic me 
  getWindow(pVerifyChangeWndID).getElement("updateaccount_topic").setProperty(#color, rgb(220, 80, 0))
end

on responseToAccountUpdate me, tStatus 
  tWndObj = getWindow(pVerifyChangeWndID)
  tWndObj.unmerge()
  if (tStatus = "0") then
    tWndObj.merge("reg_update_success.window")
  else
    if (tStatus = "1") then
      tWndObj.merge(pLastWindow)
      tWndObj.getElement("updateaccount_topic").setText(getText("reg_verification_incorrectPassword"))
      me.highlightVerifyTopic()
    else
      if (tStatus = "2") then
        tWndObj.merge(pLastWindow)
        tWndObj.getElement("updateaccount_topic").setText(getText("reg_verification_incorrectBirthday"))
        me.highlightVerifyTopic()
      else
        return(error(me, "Invalid parameter in ACCOUNT_UPDATE_STATUS", #responseToAccountUpdate))
      end if
    end if
  end if
end

on blinkChecking me 
  if not windowExists(pVerifyChangeWndID) then
    return FALSE
  end if
  if timeoutExists(#checking_blinker) then
    return FALSE
  end if
  tElem = getWindow(pVerifyChangeWndID).getElement("updating_text")
  if not tElem then
    return FALSE
  end if
  tElem.setProperty(#visible, not tElem.getProperty(#visible))
  return(createTimeout(#checking_blinker, 500, #blinkChecking, me.getID(), void(), 1))
end

on eventProcFigurecreator me, tEvent, tSprID, tParm, tWndID 
  if (tEvent = #mouseUp) then
    if tSprID <> "close" then
      if tSprID <> "reg_cancel_button" then
        if (tSprID = "reg_exit_button") then
          if (pmode = "registration") or (pmode = "parent_email") then
            if (pRegProcess.ilk = #list) then
              if (pRegProcessLocation = pRegProcess.count) then
                me.registrationReady()
              end if
            end if
          end if
          me.getComponent().closeFigureCreator()
          me.getComponent().updateState("start")
          if (getObject(#session).get(#userName) = "") then
            if threadExists(#login) then
              getThread(#login).getInterface().showLogin()
            end if
            if connectionExists(getVariable("connection.info.id")) then
              removeConnection(getVariable("connection.info.id"))
            end if
          end if
        else
          if (tSprID = "reg_underage_button") then
            if getObject(#session).get("conf_coppa") and pmode <> "forced" then
              me.getComponent().getRealtime()
            else
              pPropsToServer.setAt("parentagree", 1)
              me.changePage(1)
            end if
          else
            if (tSprID = "reg_olderage_button") then
              pPropsToServer.setAt("parentagree", 0)
              me.changePage(1)
            else
              if (tSprID = "reg_next_button") then
                me.changePage(1)
              else
                if (tSprID = "reg_prev_button") then
                  me.changePage(-1)
                else
                  if (tSprID = "reg_done_button") then
                    if (me.leavePage(pOpenWindow) = 1) then
                      getObject(#session).set("user_figure", pPropsToServer.getAt("figure").duplicate())
                      me.getComponent().sendFigureUpdateToServer(pPropsToServer)
                      me.getComponent().updateState("start")
                      return(me.closeFigureCreator())
                    else
                      return FALSE
                    end if
                  else
                    if (tSprID = "reg_ready") then
                      me.registrationReady()
                      me.getComponent().closeFigureCreator()
                      me.getComponent().updateState("start")
                    else
                      if (tSprID = "char_sex_m") then
                        pPropsToServer.setAt("sex", "M")
                        me.createDefaultFigure(1)
                        me.updateSexRadioButtons()
                      else
                        if (tSprID = "char_sex_f") then
                          pPropsToServer.setAt("sex", "F")
                          me.createDefaultFigure(1)
                          me.updateSexRadioButtons()
                        else
                          if (tSprID = "char_spam_checkbox") then
                            me.updateCheckButton("char_spam_checkbox", "directMail", 1)
                          else
                            if (tSprID = "char_terms_checkbox") then
                              me.updateCheckButton("char_terms_checkbox", "has_read_agreement", 1)
                            else
                              if (tSprID = "char_permission_checkbox") then
                                me.updateCheckButton("char_permission_checkbox", "parent_permission", 1)
                              else
                                if (tSprID = "char_name_field") then
                                  if (pNameChecked = 1) then
                                    if (pmode = "registration") or (pmode = "parent_email") then
                                      pNameChecked = 0
                                    end if
                                  end if
                                else
                                  if (tSprID = "char_continent_drop") then
                                    tCountryListImg = getObject("CountryMngr").getCountryListImg(tParm)
                                    getWindow(pWindowTitle).getElement("char_country_field").feedImage(tCountryListImg)
                                  else
                                    if (tSprID = "char_terms_linktext") then
                                      openNetPage("url_helpterms")
                                    else
                                      if (tSprID = "char_pledge_linktext") then
                                        openNetPage("url_helppledge")
                                      else
                                        if (tSprID = "char_ppledge_linktext") then
                                          openNetPage("url_privacypledge")
                                        else
                                          if (tSprID = "char_pglink") then
                                            openNetPage("url_helpparents")
                                          else
                                            if (tSprID = "reg_parentemail_link1") then
                                              openNetPage("reg_parentemail_link_url1")
                                            else
                                              if (tSprID = "reg_parentemail_link2") then
                                                openNetPage("reg_parentemail_link_url2")
                                              else
                                                if tSprID <> "update_change_pwd" then
                                                  if (tSprID = "update_change_email") then
                                                    if createWindow(pVerifyChangeWndID, void(), 0, 0, #modal) then
                                                      if (tSprID = "update_change_pwd") then
                                                        tWindowTitleStr = getText("reg_changePassword")
                                                        tWndType = "reg_update_password.window"
                                                      else
                                                        tWindowTitleStr = getText("reg_changeEmail")
                                                        tWndType = "reg_update_email.window"
                                                      end if
                                                      pTempPassword = [:]
                                                      tWinObj = getWindow(pVerifyChangeWndID)
                                                      tWinObj.setProperty(#title, tWindowTitleStr)
                                                      tWinObj.merge("habbo_basic.window")
                                                      tWinObj.merge(tWndType)
                                                      tWinObj.center()
                                                      tWinObj.registerProcedure(#eventProcVerifyWindow, me.getID(), #mouseUp)
                                                      tWinObj.registerProcedure(#eventProcVerifyWindow, me.getID(), #keyDown)
                                                    end if
                                                  else
                                                    if tSprID contains "change" and tSprID contains "button" then
                                                      tTempDelim = the itemDelimiter
                                                      the itemDelimiter = "."
                                                      tPart = tSprID.getProp(#item, 2)
                                                      tButtonType = tSprID.getProp(#item, (tSprID.count(#item) - 1))
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
                                                  if (tEvent = #keyDown) then
                                                    if (tSprID = "char_name_field") then
                                                      if (charToNum(the key) = 0) then
                                                        return FALSE
                                                      end if
                                                      tValidKeys = getVariable("permitted.name.chars")
                                                      tDeniedKeys = getVariable("denied.name.chars", "")
                                                      if not tValidKeys contains the key then
                                                        if (tSprID = 48) then
                                                          me.checkName()
                                                          return FALSE
                                                        else
                                                          if (tSprID = 49) then
                                                            return TRUE
                                                          else
                                                            if (tSprID = 51) then
                                                              return FALSE
                                                            else
                                                              if (tSprID = 117) then
                                                                getWindow(pWindowTitle).getElement(tSprID).setText("")
                                                                return FALSE
                                                              else
                                                                if tDeniedKeys contains the key then
                                                                  return TRUE
                                                                end if
                                                                if (tValidKeys = "") then
                                                                  return FALSE
                                                                else
                                                                  return TRUE
                                                                end if
                                                              end if
                                                            end if
                                                          end if
                                                        end if
                                                      else
                                                        return FALSE
                                                      end if
                                                    else
                                                      if tSprID <> "char_pw_field" then
                                                        if (tSprID = "char_pwagain_field") then
                                                          if (pNameChecked = 0) then
                                                            if not me.checkName() then
                                                              return TRUE
                                                            end if
                                                          end if
                                                          if voidp(pTempPassword.getAt(tSprID)) then
                                                            pTempPassword.setAt(tSprID, [])
                                                          end if
                                                          if (tSprID = 48) then
                                                            return FALSE
                                                          else
                                                            if (tSprID = 49) then
                                                              return TRUE
                                                            else
                                                              if (tSprID = 51) then
                                                                if pTempPassword.getAt(tSprID).count > 0 then
                                                                  pTempPassword.getAt(tSprID).deleteAt(pTempPassword.getAt(tSprID).count)
                                                                end if
                                                              else
                                                                if (tSprID = 117) then
                                                                  pTempPassword.setAt(tSprID, [])
                                                                else
                                                                  tValidKeys = getVariable("permitted.name.chars")
                                                                  tTheKey = the key
                                                                  tASCII = charToNum(tTheKey)
                                                                  if tASCII > 31 and tASCII < 128 then
                                                                    if tValidKeys contains tTheKey or (tValidKeys = "") then
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
                                                          return TRUE
                                                        else
                                                          if (tSprID = "char_mission_field") then
                                                            if (pNameChecked = 0) then
                                                              if not me.checkName() then
                                                                return TRUE
                                                              end if
                                                            end if
                                                          else
                                                            if (tSprID = "char_email_field") then
                                                              return FALSE
                                                            else
                                                              if tSprID <> "char_birth_dd_field" then
                                                                if (tSprID = "char_birth_mm_field") then
                                                                  if (tSprID = 48) then
                                                                    return FALSE
                                                                  else
                                                                    if (tSprID = 51) then
                                                                      return FALSE
                                                                    else
                                                                      if (tSprID = 117) then
                                                                        return FALSE
                                                                      else
                                                                        if getWindow(tWndID).getElement(tSprID).getText().length >= 2 then
                                                                          return TRUE
                                                                        end if
                                                                        tASCII = charToNum(the key)
                                                                        if tASCII < 48 or tASCII > 57 then
                                                                          return TRUE
                                                                        end if
                                                                      end if
                                                                    end if
                                                                  end if
                                                                else
                                                                  if (tSprID = "char_birth_yyyy_field") then
                                                                    if (tSprID = 48) then
                                                                      return FALSE
                                                                    else
                                                                      if (tSprID = 51) then
                                                                        return FALSE
                                                                      else
                                                                        if (tSprID = 117) then
                                                                          return FALSE
                                                                        else
                                                                          if getWindow(tWndID).getElement(tSprID).getText().length >= 4 then
                                                                            return TRUE
                                                                          end if
                                                                          tASCII = charToNum(the key)
                                                                          if tASCII < 48 or tASCII > 57 then
                                                                            return TRUE
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

on eventProcVerifyWindow me, tEvent, tSprID, tParm, tWndID 
  tWndObj = getWindow(tWndID)
  if voidp(pTempPassword.getAt(tSprID)) then
    pTempPassword.setAt(tSprID, [])
  end if
  if (tEvent = #keyDown) then
    if (the keyCode = 48) then
      return FALSE
    else
      if (the keyCode = 49) then
        return TRUE
      else
        if (the keyCode = 51) then
          if pTempPassword.getAt(tSprID).count > 0 then
            pTempPassword.getAt(tSprID).deleteAt(pTempPassword.getAt(tSprID).count)
          end if
        else
          if (the keyCode = 117) then
            pTempPassword.setAt(tSprID, [])
          else
            tPasswordFields = list("char_currpwd_field", "char_newpwd1_field", "char_newpwd2_field")
            tDOBFields = list("char_dd_field", "char_mm_field", "char_yyyy_field")
            tTheKey = the key
            tASCII = charToNum(tTheKey)
            if tPasswordFields.getPos(tSprID) > 0 then
              tValidKeys = getVariable("permitted.name.chars")
              if tASCII > 31 and tASCII < 128 then
                if tValidKeys contains tTheKey or (tValidKeys = "") then
                  if pTempPassword.getAt(tSprID).count < getIntVariable("pass.length.max", 16) then
                    pTempPassword.getAt(tSprID).append(tTheKey)
                  else
                    executeMessage(#alert, [#title:"alert_tooLongPW", #msg:"alert_shortenPW", #id:"pw2long"])
                  end if
                end if
              end if
              tStr = ""
              repeat while the keyCode <= tSprID
                tChar = getAt(tSprID, tEvent)
              end repeat
              getWindow(tWndID).getElement(tSprID).setText(tStr)
              the selStart = pTempPassword.getAt(tSprID).count
              the selEnd = pTempPassword.getAt(tSprID).count
              return TRUE
            else
              if tDOBFields.getPos(tSprID) > 0 then
                if tASCII < 48 or tASCII > 57 then
                  return TRUE
                else
                  if (tSprID = "char_dd_field") and tWndObj.getElement("char_dd_field").getText().length >= 2 then
                    return TRUE
                  else
                    if (tSprID = "char_mm_field") and tWndObj.getElement("char_mm_field").getText().length >= 2 then
                      return TRUE
                    else
                      if (tSprID = "char_yyyy_field") and tWndObj.getElement("char_yyyy_field").getText().length >= 4 then
                        return TRUE
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
  else
    if the keyCode <> "updatepw_cancel_button" then
      if the keyCode <> "updatemail_cancel_button" then
        if (the keyCode = "updateok_ok_button") then
          pTempPassword = [:]
          removeWindow(tWndID)
        else
          if (the keyCode = "updatepw_ok_button") then
            tCurrPwd = pTempPassword.getAt("char_currpwd_field")
            tNewPwd = pTempPassword.getAt("char_newpwd1_field")
            if voidp(tCurrPwd) then
              tWndObj.getElement("updateaccount_topic").setText(getText("Alert_ForgotSetPassword"))
              me.highlightVerifyTopic()
              return FALSE
            end if
            tDay = integer(tWndObj.getElement("char_dd_field").getText())
            tMonth = integer(tWndObj.getElement("char_mm_field").getText())
            tYear = integer(tWndObj.getElement("char_yyyy_field").getText())
            if tDay < 1 or tMonth < 1 or tYear < 1 then
              tWndObj.getElement("updateaccount_topic").setText(getText("Alert_CheckBirthday"))
              me.highlightVerifyTopic()
              return FALSE
            end if
            tPw1 = ""
            tPw2 = ""
            if pTempPassword.getAt("char_newpwd1_field").count > 0 then
              i = 1
              repeat while i <= pTempPassword.getAt("char_newpwd1_field").count
                tPw1 = tPw1 & pTempPassword.getAt("char_newpwd1_field").getAt(i)
                i = (1 + i)
              end repeat
            end if
            if pTempPassword.getAt("char_newpwd2_field").count > 0 then
              i = 1
              repeat while i <= pTempPassword.getAt("char_newpwd2_field").count
                tPw2 = tPw2 & pTempPassword.getAt("char_newpwd2_field").getAt(i)
                i = (1 + i)
              end repeat
            end if
            if not me.checkPasswordsEnforced(tPw1, tPw2) then
              tWndObj.getElement("char_newpwd1_field").setText("")
              tWndObj.getElement("char_newpwd2_field").setText("")
              tWndObj.getElement("char_newpwd1_field").setFocus(1)
              tWndObj.getElement("updateaccount_topic").setText(pErrorMsg)
              me.highlightVerifyTopic()
              pTempPassword.setAt("char_newpwd1_field", [])
              pTempPassword.setAt("char_newpwd2_field", [])
              return FALSE
            end if
            tWndObj.unmerge()
            tWndObj.merge("reg_update_progress.window")
            pLastWindow = "reg_update_password.window"
            pTempPassword = [:]
            me.blinkChecking()
            if tDay < 10 then
              tDay = "0" & tDay
            end if
            if tMonth < 10 then
              tMonth = "0" & tMonth
            end if
            tDOB = tDay & "." & tMonth & "." & tYear
            tcurrpwdstr = ""
            if tCurrPwd.count > 0 then
              i = 1
              repeat while i <= tCurrPwd.count
                tcurrpwdstr = tcurrpwdstr & tCurrPwd.getAt(i)
                i = (1 + i)
              end repeat
            end if
            tProp = ["oldpassword":tcurrpwdstr, "birthday":tDOB, "password":tPw1]
            me.getComponent().sendUpdateAccountMsg(tProp)
          else
            if (the keyCode = "updatemail_ok_button") then
              tWndObj = getWindow(pVerifyChangeWndID)
              tCurrPwd = pTempPassword.getAt("char_currpwd_field")
              tEmail = tWndObj.getElement("char_newemail_field").getText()
              tYear = integer(tWndObj.getElement("char_yyyy_field").getText())
              tMonth = integer(tWndObj.getElement("char_mm_field").getText())
              tDay = integer(tWndObj.getElement("char_dd_field").getText())
              if voidp(tCurrPwd) then
                tWndObj.getElement("updateaccount_topic").setText(getText("Alert_ForgotSetPassword"))
                me.highlightVerifyTopic()
                return FALSE
              end if
              if tDay < 1 or tMonth < 1 or tYear < 1 then
                tWndObj.getElement("updateaccount_topic").setText(getText("Alert_CheckBirthday"))
                me.highlightVerifyTopic()
                return FALSE
              end if
              tEmailOK = 0
              if length(tEmail) > 6 and tEmail contains "@" then
                f = (offset("@", tEmail) + 1)
                repeat while f <= length(tEmail)
                  if (tEmail.getProp(#char, f) = ".") then
                    tEmailOK = 1
                  end if
                  if (tEmail.getProp(#char, f) = "@") then
                    tEmailOK = 0
                  else
                    f = (1 + f)
                  end if
                end repeat
              end if
              if not tEmailOK then
                tWndObj.getElement("updateaccount_topic").setText(getText("reg_verification_invalidEmail"))
                me.highlightVerifyTopic()
              else
                tWndObj.unmerge()
                tWndObj.merge("reg_update_progress.window")
                pLastWindow = "reg_update_email.window"
                pTempPassword = [:]
                me.blinkChecking()
                if tDay < 10 then
                  tDay = "0" & tDay
                end if
                if tMonth < 10 then
                  tMonth = "0" & tMonth
                end if
                tDOB = tDay & "." & tMonth & "." & tYear
                tcurrpwdstr = ""
                i = 1
                repeat while i <= tCurrPwd.count
                  tcurrpwdstr = tcurrpwdstr & tCurrPwd.getAt(i)
                  i = (1 + i)
                end repeat
                tProp = ["oldpassword":tcurrpwdstr, "birthday":tDOB, "email":tEmail]
                me.getComponent().sendUpdateAccountMsg(tProp)
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

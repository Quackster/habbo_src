property pTempPassword, pOpenWindow, pWindowTitle, pmode, pOldFigure, pOldSex, pPartChangeButtons, pBodyPartObjects, pPeopleSize, pBuffer, pFlipList, pNameChecked, pEmailChecked, pLastNameCheck, pPropsToServer, pErrorMsg, pRegProcess, pRegProcessLocation, pVerifyChangeWndID, pLastWindow, pPwdEmailUpdateForced, pPasswordErrors, pUpdatingPassword, pPasswordChecked, pUpdatePropsToServer

on construct me
  pTempPassword = [:]
  pPropsToServer = [:]
  pPartChangeButtons = [:]
  pLastNameCheck = EMPTY
  pWindowTitle = getText("win_figurecreator", "Your own Habbo")
  pOpenWindow = EMPTY
  pRegProcessLocation = 1
  pVerifyChangeWndID = "VerifyingChangeWindow"
  pLastWindow = EMPTY
  pPwdEmailUpdateForced = 0
  pPasswordErrors = EMPTY
  if not dumpVariableField("registration.props") then
    error(me, "registration props field not found!", #construct)
  end if
  if not variableExists("permitted.name.chars") then
    setVariable("permitted.name.chars", "1234567890qwertyuiopasdfghjklzxcvbnm_-=+?!@<>:.,")
  end if
  if not variableExists("permitted.password.chars") then
    setVariable("permitted.password.chars", getVariable("permitted.name.chars"))
  end if
  if not variableExists("denied.name.chars") then
    setVariable("denied.name.chars", "_")
  end if
  return 1
end

on deconstruct me
  pBodyPartObjects = VOID
  if windowExists(pWindowTitle) then
    removeWindow(pWindowTitle)
  end if
  if objectExists(#temp_humanobj_figurecreator) then
    removeObject(#temp_humanobj_figurecreator)
  end if
  if objectExists("CountryMngr") then
    removeObject("CountryMngr")
  end if
  return 1
end

on showHideFigureCreator me, tNewOrUpdate, tForceOpen
  if windowExists(pWindowTitle) and (pOpenWindow <> "reg_loading.window") and not tForceOpen then
    return me.closeFigureCreator()
  else
    return me.openFigureCreator(tNewOrUpdate)
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
      tWindow = tRegPages[1] & ".window"
    end if
  end if
  return me.enterPage(tWindow)
end

on closeFigureCreator me
  pPropsToServer = [:]
  pBodyPartObjects = VOID
  if windowExists(pWindowTitle) then
    removeWindow(pWindowTitle)
  end if
  if objectExists(#session) then
    getObject(#session).set("creatingCharacter", 0)
  end if
  return 1
end

on showLoadingWindow me, tMode
  pmode = tMode
  me.ChangeWindowView("reg_loading.window")
  me.blinkLoading()
  return 1
end

on finishRegistration me, tdata
  tAgeOk = value(tdata)
  if tAgeOk then
    me.changePage(1)
  else
    me.getComponent().getRealtime()
  end if
end

on userNameOk me
  if pOpenWindow = "reg_loading.window" then
    me.changePage(1)
  end if
end

on userNameUnacceptable me
  if pOpenWindow = "reg_loading.window" then
    me.changePage("reg_namepage.window")
  end if
  executeMessage(#alert, [#Msg: "Alert_unacceptableName", #id: "namenogood", #modal: 1])
  me.clearUserNameField()
end

on userNameTooLong me
  if pOpenWindow = "reg_loading.window" then
    me.changePage("reg_namepage.window")
  end if
  executeMessage(#alert, [#Msg: "Alert_NameTooLong", #id: "nametoolong", #modal: 1])
end

on userNameAlreadyReserved me
  if pOpenWindow = "reg_loading.window" then
    me.changePage("reg_namepage.window")
  end if
  executeMessage(#alert, [#Msg: "Alert_NameAlreadyUse", #id: "namereserved", #modal: 1])
  me.clearUserNameField()
end

on userEmailOk me
  pEmailChecked = 1
  me.changePage(1)
  return 1
end

on userEmailUnacceptable me
  pEmailChecked = 0
  case pOpenWindow of
    "reg_info_update.window":
      removeWindow(pVerifyChangeWndID)
  end case
  executeMessage(#alert, [#Msg: "reg_verification_invalidEmail", #id: "emailnogood", #modal: 1])
  return 1
end

on userPasswordResult me, tResult
  if voidp(tResult) then
    return error(me, "Invalid password result!", #userPasswordResult)
  end if
  case tResult of
    0:
      pPasswordChecked = 1
      pPasswordErrors = EMPTY
    1:
      pPasswordChecked = 0
      pPasswordErrors = getText("Alert_YourPasswordIsTooShort") & RETURN
    2:
      pPasswordChecked = 0
      pPasswordErrors = getText("alert_tooLongPW") & RETURN
    3:
      pPasswordChecked = 0
      tValidKeys = getVariable("permitted.password.chars")
      pPasswordErrors = getText("reg_use_allowed_chars") && tValidKeys & RETURN
    4:
      pPasswordChecked = 0
      pPasswordErrors = getText("reg_passwordContainsNoNumber") & RETURN
    5:
      pPasswordChecked = 0
      pPasswordErrors = getText("reg_nameAndPassTooSimilar") & RETURN
  end case
  if pUpdatingPassword then
    if tResult = 0 then
      tDay = pUpdatePropsToServer[#day]
      tMonth = pUpdatePropsToServer[#month]
      tYear = pUpdatePropsToServer[#year]
      if tDay < 10 then
        tDay = "0" & tDay
      end if
      if tMonth < 10 then
        tMonth = "0" & tMonth
      end if
      tDOB = tDay & "." & tMonth & "." & tYear
      tProp = ["oldpassword": pUpdatePropsToServer[#currPwd], "birthday": tDOB, "password": pUpdatePropsToServer[#newPwd]]
      me.getComponent().sendUpdateAccountMsg(tProp)
    else
      tWndObj = getWindow(pVerifyChangeWndID)
      tWndObj.unmerge()
      tWndObj.merge(pLastWindow)
      tWndObj.getElement("updateaccount_topic").setText(getText(pPasswordErrors))
      if tWndObj.elementExists("monthDrop") then
        tWndObj.getElement("monthDrop").setOrdering(0)
      end if
      me.highlightVerifyTopic()
    end if
  else
    me.changePage(1)
  end if
  return 1
end

on parentEmailQueryStatus me, tFlag
  if (pmode = "parent_email") or (pmode = "parent_email_strong_coppa") then
    if not tFlag then
      if pOpenWindow = "reg_loading.window" then
        me.changePage(1)
      end if
    else
      me.parentEmailNotNeeded()
      me.changePage(1)
    end if
  else
    if tFlag = 1 then
      me.parentEmailNotNeeded()
    end if
  end if
end

on parentEmailOk me
  if pRegProcess.ilk = #list then
    if (pmode = "parent_email") or (pmode = "parent_email_strong_coppa") then
      tPos = pRegProcess.findPos("reg_parent_email")
      tNextPage = pRegProcess[tPos + 1]
      me.changePage(tNextPage & ".window")
    else
      if pRegProcessLocation = pRegProcess.count then
        getObject(#session).set("user_figure", pPropsToServer["figure"].duplicate())
        me.getComponent().sendFigureUpdateToServer(pPropsToServer)
        me.getComponent().updateState("start")
        return me.closeFigureCreator()
      else
        tPos = pRegProcess.findPos("reg_parent_email")
        tNextPage = pRegProcess[tPos + 1]
        me.changePage(tNextPage & ".window")
      end if
    end if
  end if
end

on parentEmailIncorrect me
  if pOpenWindow <> "reg_parent_email.window" then
    me.changePage("reg_parent_email.window")
  end if
  executeMessage(#alert, [#Msg: "alert_reg_parent_email", #id: "parentemailincorrect", #modal: 1])
  return 0
end

on openPasswordUpdate me, tForced, tMsg
  me.openPwdEmailUpdate(#password, tForced, tMsg)
end

on openEmailUpdate me, tForced, tMsg
  me.openPwdEmailUpdate(#email, tForced, tMsg)
end

on openPwdEmailUpdate me, ttype, tForced, tMsg
  if tForced then
    pPwdEmailUpdateForced = 1
  end if
  if ttype = #password then
    tWindowTitleStr = getText("reg_changePassword")
    tWndType = "reg_update_password.window"
  else
    tWindowTitleStr = getText("reg_changeEmail")
    tWndType = "reg_update_email.window"
  end if
  if not createWindow(pVerifyChangeWndID, VOID, 0, 0, #modal) then
    return 0
  end if
  pTempPassword = [:]
  tWinObj = getWindow(pVerifyChangeWndID)
  tWinObj.setProperty(#title, tWindowTitleStr)
  tWinObj.merge("habbo_simple.window")
  tWinObj.merge(tWndType)
  tWinObj.center()
  if tWinObj.elementExists("monthDrop") then
    tWinObj.getElement("monthDrop").setOrdering(0)
  end if
  if pPwdEmailUpdateForced and tWinObj.elementExists("update_cancel_button") then
    tWinObj.getElement("update_cancel_button").deactivate()
  end if
  if not voidp(tMsg) and tWinObj.elementExists("updateaccount_topic") then
    tWinObj.getElement("updateaccount_topic").setText(tMsg)
  end if
  tWinObj.registerProcedure(#eventProcVerifyWindow, me.getID(), #mouseUp)
  tWinObj.registerProcedure(#eventProcVerifyWindow, me.getID(), #keyDown)
end

on blinkLoading me
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("reg_loading")
  if tElem = 0 then
    return 0
  end if
  tElem.setProperty(#visible, not tElem.getProperty(#visible))
  me.delay(500, #blinkLoading)
  return 1
end

on defineModes me, tMode
  pPropsToServer = [:]
  pTempPassword = [:]
  pPartChangeButtons = [:]
  pLastNameCheck = EMPTY
  pmode = tMode
  pRegProcess = getVariableValue(pmode & ".process")
  me.NewFigureInformation()
  if (pmode = "registration") or (pmode = "parent_email") or (pmode = "parent_email_strong_coppa") then
    pNameChecked = 0
  else
    pNameChecked = 1
    me.getMyInformation()
  end if
end

on NewFigureInformation me
  pPropsToServer["name"] = EMPTY
  pPropsToServer["figure"] = [:]
  pPropsToServer["sex"] = "M"
  pPropsToServer["customData"] = EMPTY
  pPropsToServer["email"] = EMPTY
  pPropsToServer["birthday"] = EMPTY
  pPropsToServer["has_read_agreement"] = "0"
  pPropsToServer["parentagree"] = 1
  if getObject(#session).exists("conf_allow_direct_mail") then
    pPropsToServer["directMail"] = string(getObject(#session).GET("conf_allow_direct_mail"))
  else
    pPropsToServer["directMail"] = "0"
  end if
end

on ChangeWindowView me, tWindowName
  if not windowExists(pWindowTitle) then
    if pmode = "forced" then
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
  if tWndObj.elementExists("close") then
    tWndObj.getElement("close").setProperty(#visible, 0)
  end if
  if pmode = "forced" then
    tWndObj.center()
    tWndObj.moveBy(172, 0)
  end if
  pOpenWindow = tWindowName
end

on getMyInformation me
  pPropsToServer = [:]
  tTempProps = ["name", "password", "figure", "sex", "customData", "email", "birthday", "directMail"]
  repeat with tProp in tTempProps
    if getObject(#session).exists("user_" & tProp) then
      tdata = getObject(#session).GET("user_" & tProp)
      if (tdata.ilk = #list) or (tdata.ilk = #propList) then
        pPropsToServer[tProp] = tdata.duplicate()
      else
        pPropsToServer[tProp] = tdata
      end if
      next repeat
    end if
    pPropsToServer[tProp] = EMPTY
  end repeat
  pPropsToServer["figure"].deleteProp("li")
  pPropsToServer["figure"].deleteProp("ri")
  pOldFigure = pPropsToServer["figure"].duplicate()
  if (pPropsToServer["sex"].char[1] = "f") or (pPropsToServer["sex"].char[1] = "F") then
    pPropsToServer["sex"] = "F"
  else
    pPropsToServer["sex"] = "M"
  end if
  pOldSex = pPropsToServer["sex"]
end

on setMyDataToFields me
  tWndObj = getWindow(pWindowTitle)
  tTempProps = [:]
  case pOpenWindow of
    "reg_welcome.window":
      if (pmode = "forced") or (pmode = "parent_email_forced") then
        if tWndObj.elementExists("reg_exit_button") then
          tWndObj.getElement("reg_exit_button").hide()
        end if
        tWndObj.getElement("reg_welcome_balloon").setText(getText("reg_forcedupdate"))
        tWndObj.getElement("reg_welcome_header").setText(getText("reg_forcedupdate2"))
        tWndObj.getElement("reg_welcome_txt").setText(getText("reg_forcedupdate3"))
      end if
    "reg_coppa_forced.window":
      if tWndObj.elementExists("reg_exit_button") then
        tWndObj.getElement("reg_exit_button").hide()
      end if
      tWndObj.getElement("reg_welcome_balloon").setText(getText("reg_forcedupdate"))
      tWndObj.getElement("reg_welcome_header").setText(getText("reg_forcedupdate2"))
      tWndObj.getElement("reg_welcome_txt").setText(getText("reg_forcedupdate3"))
    "reg_legal.window":
      if pPropsToServer["parentagree"] = 0 then
        tWndObj.getElement("reg_legal_header").setText(getText("reg_legal_header2"))
        tWndObj.getElement("reg_agree_text").setText(getText("reg_agree2"))
      end if
    "reg_namepage.window":
      if (pmode = "registration") or (pmode = "parent_email") or (pmode = "parent_email_strong_coppa") then
        tWndObj.getElement("char_name_field").setFocus(1)
      else
        tWndObj.getElement("char_name_field").setProperty(#blend, 30)
        tWndObj.getElement("char_name_field").setEdit(0)
        tWndObj.getElement("char_name_field").setText(pPropsToServer["name"])
      end if
      tTempProps = ["name": "char_name_field"]
      if variableExists("username_input.font.size") then
        tElem = tWndObj.getElement("char_name_field")
        if tElem = 0 then
          return 0
        end if
        if tElem.pMember = VOID then
          return 0
        end if
        if tElem.pMember.type <> #field then
          return 0
        end if
        tElem.pMember.fontSize = getIntVariable("username_input.font.size")
      end if
    "reg_namepage_mission.window":
      tWndObj.getElement("char_mission_field").setFocus(1)
      tTempProps = ["name": "char_name_field", "customData": "char_mission_field"]
    "reg_infopage.window":
      tTempProps = ["email": "char_email_field"]
      pTempPassword = [:]
      tDelim = the itemDelimiter
      the itemDelimiter = "."
      tWndObj.getElement("char_dd_field").setText(integer(pPropsToServer["birthday"].item[1]))
      if not voidp(pPropsToServer["birthday"]) then
        tWndObj.getElement("monthDrop").setOrdering(0)
        tWndObj.getElement("monthDrop").setSelection(integer(pPropsToServer["birthday"].item[2]), 1)
      end if
      tWndObj.getElement("char_yyyy_field").setText(pPropsToServer["birthday"].item[3])
      the itemDelimiter = tDelim
      me.updateCheckButton("char_spam_checkbox", "directMail")
    "reg_infopage_no_age.window":
      pTempPassword = [:]
    "reg_confirm.window":
      if tWndObj.elementExists("reg_name") then
        tText = getText("reg_check_name", "reg_check_name") && pPropsToServer["name"]
        tWndObj.getElement("reg_name").setText(tText)
      end if
      if tWndObj.elementExists("reg_age") then
        if objectExists(#dateFormatter) then
          tDate = getObject(#dateFormatter).getLocalDateFromStr(pPropsToServer["birthday"])
          tText = getText("reg_check_age", "reg_check_age") && tDate
        else
          tText = getText("reg_check_age", "reg_check_age") && pPropsToServer["birthday"]
        end if
        tWndObj.getElement("reg_age").setText(tText)
      end if
      if tWndObj.elementExists("reg_mail") then
        tText = getText("reg_check_mail", "reg_check_mail") && pPropsToServer["email"]
        tWndObj.getElement("reg_mail").setText(tText)
      end if
  end case
  repeat with f = 1 to tTempProps.count
    tProp = tTempProps.getPropAt(f)
    tElem = tTempProps[tProp]
    if tWndObj.elementExists(tElem) then
      tWndObj.getElement(tElem).setText(pPropsToServer[tProp])
    end if
  end repeat
  if (pRegProcess <> 0) and (pRegProcessLocation.ilk = #integer) then
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
      if (pmode = "update") and (pRegProcessLocation <> 1) then
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
    if pRegProcessLocation = pRegProcess.count then
      if (pmode <> "registration") and (pmode <> " parent_email") then
        if tWndObj.elementExists("reg_done_button") and tWndObj.elementExists("reg_page_number") then
          tWndObj.getElement("reg_done_button").show()
          tWndObj.getElement("reg_next_button").hide()
          tMoveX = tWndObj.getElement("reg_next_button").getProperty(#locH) - tWndObj.getElement("reg_done_button").getProperty(#locH)
          tMoveX = tWndObj.getElement("reg_done_button").getProperty(#locH) + tMoveX
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
  case pOpenWindow of
    "reg_namepage.window":
      tTempProps = ["name": "char_name_field"]
    "reg_namepage_mission.window":
      tTempProps = ["customData": "char_mission_field"]
    "reg_infopage.window":
      tDay = integer(tWndObj.getElement("char_dd_field").getText())
      if not tWndObj.elementExists("monthDrop") then
        return error(me, "No month drop!", #leavePage)
      end if
      tMonthSelection = tWndObj.getElement("monthDrop").getSelection()
      tMonth = integer(chars(tMonthSelection, tMonthSelection.length - 1, tMonthSelection.length))
      tYear = integer(tWndObj.getElement("char_yyyy_field").getText())
      if (tDay < 10) and not voidp(tDay) then
        tDay = "0" & tDay
      end if
      if (tMonth < 10) and not voidp(tMonth) then
        tMonth = "0" & tMonth
      end if
      pPropsToServer["birthday"] = tDay & "." & tMonth & "." & tYear
      tTempProps = ["email": "char_email_field"]
    "reg_infopage_no_age.window":
      tTempProps = ["email": "char_email_field"]
  end case
  repeat with f = 1 to tTempProps.count
    tProp = tTempProps.getPropAt(f)
    tElem = tTempProps[tProp]
    if tWndObj.elementExists(tElem) then
      tElemTxt = convertSpecialChars(tWndObj.getElement(tElem).getText(), 1)
      pPropsToServer[tProp] = tElemTxt
    end if
  end repeat
  return 1
end

on updateSexRadioButtons me
  tRadioButtonOnImg = member(getmemnum("button.radio.on")).image
  tRadioButtonOffImg = member(getmemnum("button.radio.off")).image
  if voidp(pPropsToServer["sex"]) then
    pPropsToServer["sex"] = "M"
  end if
  tWndObj = getWindow(pWindowTitle)
  if pPropsToServer["sex"] contains "F" then
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
  if voidp(pPropsToServer[tProp]) then
    pPropsToServer[tProp] = "0"
  end if
  if voidp(tChangeMode) then
    tChangeMode = 0
  end if
  if tChangeMode then
    if pPropsToServer[tProp] = "1" then
      pPropsToServer[tProp] = "0"
    else
      pPropsToServer[tProp] = "1"
    end if
  end if
  if pPropsToServer[tProp] = "1" then
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
    return error(me, "Figure system object not found", #createDefaultFigure)
  end if
  pPropsToServer["figure"] = [:]
  if not voidp(pOldFigure) and (pOldSex = pPropsToServer["sex"]) then
    pPropsToServer["figure"] = pOldFigure
    repeat with tPart in ["lh", "ls", "bd", "sh", "lg", "ch", "hd", "fc", "ey", "hr", "rh", "rs"]
      tmodel = pPropsToServer["figure"][tPart]["model"]
      tColor = pPropsToServer["figure"][tPart]["color"]
      me.setPartModel(tPart, tmodel)
      me.setPartColor(tPart, tColor)
    end repeat
    me.updateFigurePreview()
    me.updateAllPrewIcons()
    return 
  end if
  repeat with tPart in ["hr", "hd", "ch", "lg", "sh"]
    if voidp(tRandom) then
      tRandom = 0
    end if
    if tRandom then
      tMaxValue = getObject("Figure_System").getCountOfPart(tPart, pPropsToServer["sex"])
      tNumber = random(tMaxValue)
    else
      tNumber = 1
    end if
    tPartProps = getObject("Figure_System").getModelOfPartByOrderNum(tPart, tNumber, pPropsToServer["sex"])
    if tPartProps.ilk = #propList then
      tColorList = tPartProps["firstcolor"]
      tSetID = tPartProps["setid"]
      tColorId = 1
      if not listp(tColorList) then
        tColorList = list(tColorList)
      end if
      repeat with f = 1 to tPartProps["changeparts"].count
        tMultiPart = tPartProps["changeparts"].getPropAt(f)
        tmodel = string(tPartProps["changeparts"][tMultiPart])
        if tmodel.char.count = 1 then
          tmodel = "00" & tmodel
        else
          if tmodel.char.count = 2 then
            tmodel = "0" & tmodel
          end if
        end if
        if tColorList.count >= f then
          tColor = rgb(tColorList[f])
        else
          tColor = rgb(tColorList[1])
        end if
        me.setPartModel(tMultiPart, tmodel)
        me.setPartColor(tMultiPart, tColor)
        pPropsToServer["figure"][tMultiPart] = ["model": tmodel, "color": tColor, "setid": tSetID, "colorid": tColorId]
        me.setIndexNumOfPartOrColor("partcolor", tMultiPart, 0)
      end repeat
    end if
  end repeat
  me.updateFigurePreview()
  me.updateAllPrewIcons()
end

on createTemplateHuman me
  if not voidp(pBodyPartObjects) then
    return 0
  end if
  tProps = pPropsToServer
  pPeopleSize = "h"
  pBuffer = image(1, 1, 8)
  pFlipList = [0, 1, 2, 3, 2, 1, 0, 7]
  pBodyPartObjects = [:]
  repeat with tPart in ["lh", "ls", "bd", "sh", "lg", "ch", "hd", "fc", "ey", "hr", "rh", "rs"]
    tmodel = pPropsToServer["figure"][tPart]["model"]
    tColor = pPropsToServer["figure"][tPart]["color"]
    tDirection = 1
    tAction = "std"
    tAncestor = me
    tTempPartObj = createObject(#temp, "Bodypart Template Class")
    tTempPartObj.define(tPart, tmodel, tColor, tDirection, tAction, tAncestor)
    pBodyPartObjects.addProp(tPart, tTempPartObj)
  end repeat
end

on getSetID me, tPart
  if voidp(pPropsToServer["figure"][tPart]) then
    return error(me, "Part missing:" && tPart, #getSetID)
  end if
  if voidp(pPropsToServer["figure"][tPart]["setid"]) then
    return error(me, "Part setid missing:" && tPart, #getSetID)
  end if
  return pPropsToServer["figure"][tPart]["setid"]
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
      tdestrect = tPrewImg.rect - (tHumanImg.rect * 2)
      tMargins = rect(-11, -6, -11, -6)
      tdestrect = rect(0, tdestrect.bottom, tHumanImg.width * 2, tPrewImg.rect.bottom) + tMargins
      tPrewImg.copyPixels(tHumanImg, tdestrect, tHumanImg.rect)
      if tWndObj.elementExists("human.preview.img") then
        tWndObj.getElement("human.preview.img").feedImage(tPrewImg)
      end if
    end if
  end if
end

on updateAllPrewIcons me
  repeat with tPart in ["hr", "hd", "ch", "lg", "sh"]
    me.setIndexNumOfPartOrColor("partcolor", tPart, 0)
    me.setIndexNumOfPartOrColor("partmodel", tPart, 0)
    if not voidp(pPropsToServer["figure"][tPart]["color"]) then
      me.updatePartColorPreview(tPart, pPropsToServer["figure"][tPart]["color"])
      case tPart of
        "hd":
          tTemp = ["hd": pPropsToServer["figure"]["hd"]["model"], "ey": pPropsToServer["figure"]["ey"]["model"], "fc": pPropsToServer["figure"]["fc"]["model"]]
          me.updatePartPreview(tPart, tTemp)
        "ch":
          tTemp = ["ls": pPropsToServer["figure"]["ls"]["model"], "ch": pPropsToServer["figure"]["ch"]["model"], "rs": pPropsToServer["figure"]["rs"]["model"]]
          me.updatePartPreview(tPart, tTemp)
        otherwise:
          tTemp = [:]
          tTemp.addProp(tPart, pPropsToServer["figure"][tPart]["model"])
          me.updatePartPreview(tPart, tTemp)
      end case
    end if
  end repeat
end

on updatePartPreview me, tPart, tChangingPartPropList
  tElemID = "part." & tPart & ".preview"
  tWndObj = getWindow(pWindowTitle)
  tElem = tWndObj.getElement(tElemID)
  if not voidp(pBodyPartObjects) and (tElem <> 0) then
    tTempPartImg = image(64, 102, 16)
    tPartList = []
    case tPart of
      "hd":
        tTempChangingParts = ["hd", "ey", "fc"]
      "ch":
        tTempChangingParts = ["ls", "ch", "rs"]
      otherwise:
        tTempChangingParts = [tPart]
    end case
    repeat with tChancePart in tTempChangingParts
      tMultiPart = tChancePart
      tTempChangeParts = ["hr", "hd", "ch", "lg", "sh", "ey", "fc", "ls", "rs", "ls", "rs"]
      if tTempChangeParts.getOne(tMultiPart) > 0 then
        tmodel = string(tChangingPartPropList[tMultiPart])
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
  repeat with tPart in tPartList
    call(#copyPicture, [pBodyPartObjects[tPart]], tImg)
  end repeat
end

on setPartColor me, tPart, tColor
  if not voidp(pBodyPartObjects) then
    call(#setColor, [pBodyPartObjects[tPart]], tColor)
  end if
end

on setPartModel me, tPart, tmodel
  if not voidp(pBodyPartObjects) then
    call(#setModel, [pBodyPartObjects[tPart]], tmodel)
  end if
end

on setIndexNumOfPartOrColor me, tChange, tPart, tOrderNum, tMaxValue
  if voidp(pPartChangeButtons[tChange]) then
    pPartChangeButtons[tChange] = [:]
  end if
  if voidp(pPartChangeButtons[tChange][tPart]) then
    pPartChangeButtons[tChange][tPart] = [:]
  end if
  if tOrderNum = 0 then
    pPartChangeButtons[tChange][tPart] = 1
  else
    if (pPartChangeButtons[tChange][tPart] + tOrderNum) > tMaxValue then
      pPartChangeButtons[tChange][tPart] = 1
    else
      if (pPartChangeButtons[tChange][tPart] + tOrderNum) < 1 then
        pPartChangeButtons[tChange][tPart] = tMaxValue
      else
        pPartChangeButtons[tChange][tPart] = pPartChangeButtons[tChange][tPart] + tOrderNum
      end if
    end if
  end if
  return pPartChangeButtons[tChange][tPart]
end

on changePart me, tPart, tButtonDir
  if not objectExists("Figure_System") then
    return error(me, "Figure system object not found", #changePart)
  end if
  tSetID = me.getSetID(tPart)
  if tSetID = 0 then
    return error(me, "Incorrect part data", #changePart)
  end if
  tMaxValue = getObject("Figure_System").getCountOfPart(tPart, pPropsToServer["sex"])
  tPartIndexNum = me.setIndexNumOfPartOrColor("partmodel", tPart, tButtonDir, tMaxValue)
  tPartProps = getObject("Figure_System").getModelOfPartByOrderNum(tPart, tPartIndexNum, pPropsToServer["sex"])
  if tPartProps.ilk = #propList then
    tColorList = tPartProps["firstcolor"]
    tSetID = tPartProps["setid"]
    tColorId = 1
    if not listp(tColorList) then
      tColorList = list(tColorList)
    end if
    repeat with f = 1 to tPartProps["changeparts"].count
      tMultiPart = tPartProps["changeparts"].getPropAt(f)
      tmodel = string(tPartProps["changeparts"][tMultiPart])
      if tmodel.char.count = 1 then
        tmodel = "00" & tmodel
      else
        if tmodel.char.count = 2 then
          tmodel = "0" & tmodel
        end if
      end if
      if tColorList.count >= f then
        tColor = rgb(tColorList[f])
      else
        tColor = rgb(tColorList[1])
      end if
      me.setPartModel(tMultiPart, tmodel)
      me.setPartColor(tMultiPart, tColor)
      pPropsToServer["figure"][tMultiPart] = ["model": tmodel, "color": tColor, "setid": tSetID, "colorid": tColorId]
      me.setIndexNumOfPartOrColor("partcolor", tMultiPart, 0)
    end repeat
    if not voidp(pPropsToServer["figure"][tPart]) then
      if not voidp(pPropsToServer["figure"][tPart]["color"]) then
        tColor = pPropsToServer["figure"][tPart]["color"]
      end if
    end if
    me.updateFigurePreview()
    me.updatePartColorPreview(tPart, tColor)
    me.updatePartPreview(tPart, tPartProps["changeparts"])
  end if
end

on changePartColor me, tPart, tButtonDir
  if not objectExists("Figure_System") then
    return error(me, "Figure system object not found", #changePartColor)
  end if
  tSetID = me.getSetID(tPart)
  if tSetID = 0 then
    return error(me, "Incorrect part data", #changePartColor)
  end if
  tMaxValue = getObject("Figure_System").getCountOfPartColors(tPart, tSetID, pPropsToServer["sex"])
  tColorIndexNum = me.setIndexNumOfPartOrColor("partcolor", tPart, tButtonDir, tMaxValue)
  tPartProps = getObject("Figure_System").getColorOfPartByOrderNum(tPart, tColorIndexNum, tSetID, pPropsToServer["sex"])
  if tPartProps.ilk = #propList then
    tColorList = tPartProps["color"]
    if not listp(tColorList) then
      tColorList = list(tColorList)
    end if
    repeat with f = 1 to tPartProps["changeparts"].count
      tMultiPart = tPartProps["changeparts"].getPropAt(f)
      if tColorList.count >= f then
        tColor = rgb(tColorList[f])
      else
        tColor = rgb(tColorList[1])
      end if
      me.setPartColor(tMultiPart, tColor)
      pPropsToServer["figure"][tMultiPart]["color"] = tColor
      pPropsToServer["figure"][tMultiPart]["colorid"] = tColorIndexNum
    end repeat
    if not voidp(pPropsToServer["figure"][tPart]) then
      if not voidp(pPropsToServer["figure"][tPart]["color"]) then
        tColor = pPropsToServer["figure"][tPart]["color"]
      end if
    end if
    me.updateFigurePreview()
    me.updatePartColorPreview(tPart, tColor)
    me.updatePartPreview(tPart, tPartProps["changeparts"])
  end if
end

on focusKeyboardToSprite me, tElemID
  getWindow(pWindowTitle).getElement(tElemID).setFocus(1)
end

on checkName me
  if (pmode = "registration") or (pmode = "parent_email") or (pmode = "parent_email_strong_coppa") then
    tField = getWindow(pWindowTitle).getElement("char_name_field")
    if tField = 0 then
      return error(me, "Couldn't perform name check!", #checkName)
    end if
    tName = tField.getText().word[1]
    tField.setText(tName)
    if length(tName) = 0 then
      executeMessage(#alert, [#Msg: "Alert_NoNameSet", #id: "nonameset", #modal: 1])
      return 0
    else
      if length(tName) < getIntVariable("name.length.min", 3) then
        executeMessage(#alert, [#Msg: "Alert_YourNameIstooShort", #id: "name2short", #modal: 1])
        me.focusKeyboardToSprite("char_name_field")
        return 0
      else
        if pLastNameCheck <> tName then
          if me.getComponent().checkUserName(tName) = 0 then
            return 0
          end if
        end if
      end if
    end if
  end if
  getObject(#session).set(#userName, tName)
  pNameChecked = 1
  return 1
end

on checkPasswords me, tPwd1, tPwd2
  if voidp(tPwd1) or voidp(tPwd2) then
    pErrorMsg = pErrorMsg & getText("Alert_WrongPassword") & RETURN
    return 0
  end if
  if (tPwd1.length < 1) or (tPwd2.length < 1) or (tPwd1 <> tPwd2) then
    pErrorMsg = pErrorMsg & getText("Alert_WrongPassword") & RETURN
    return 0
  end if
  return 1
end

on validateBirthday me, tYear, tMonth, tDay
  if the paramCount < 4 then
    return 0
  end if
  tBirthOK = 1
  if voidp(tDay) or (tDay < 1) or (tDay > 31) then
    tBirthOK = 0
  end if
  if voidp(tMonth) or (tMonth < 1) or (tMonth > 12) then
    tBirthOK = 0
  end if
  if voidp(tYear) or (tYear < 1900) or (tYear > 2100) then
    tBirthOK = 0
  end if
  if (tBirthOK = 1) and getObject(#session).exists("server_date") then
    tServerDate = getObject(#session).GET("server_date")
    tDelim = the itemDelimiter
    the itemDelimiter = "."
    tServerDay = integer(tServerDate.item[1])
    tServerMonth = integer(tServerDate.item[2])
    tServerYear = integer(tServerDate.item[3])
    if tYear > tServerYear then
      tBirthOK = 0
    else
      if (tMonth > tServerMonth) and (tYear = tServerYear) then
        tBirthOK = 0
      else
        if (tDay > tServerDay) and (tMonth = tServerMonth) and (tYear = tServerYear) then
          tBirthOK = 0
        end if
      end if
    end if
    the itemDelimiter = tDelim
  end if
  return tBirthOK
end

on validateEmail me, tEmail
  tEmailOK = 0
  if (length(tEmail) > 6) and (tEmail contains "@") then
    repeat with f = offset("@", tEmail) + 1 to length(tEmail)
      if tEmail.char[f] = "." then
        tEmailOK = 1
      end if
      if tEmail.char[f] = "@" then
        tEmailOK = 0
        exit repeat
      end if
    end repeat
  end if
  return tEmailOK
end

on checkAgreeTerms me
  if getText("reg_terms") = "reg_terms" then
    return 0
  end if
  tWndObj = getWindow(pWindowTitle)
  if tWndObj.elementExists("reg_termstxt") then
    tScroll = tWndObj.getElement("char_scrollbar").getScrollOffset()
    tMaxH = tWndObj.getElement("reg_termstxt").getProperty(#image).height - tWndObj.getElement("reg_termstxt").getProperty(#height)
    if (tScroll + 2) < tMaxH then
      pErrorMsg = pErrorMsg & getText("reg_readterms_alert") & RETURN
      return 0
    end if
  else
    return 0
  end if
  if pPropsToServer["has_read_agreement"] <> "1" then
    pErrorMsg = pErrorMsg & getText("reg_agree_alert") & RETURN
    return 0
  else
    return 1
  end if
end

on parentEmailNotNeeded me
  if pRegProcess.ilk = #list then
    tPos = pRegProcess.findPos("reg_parent_email")
    if tPos > 0 then
      pRegProcess.deleteAt(tPos)
    end if
  end if
end

on clearUserNameField me
  pNameChecked = 0
  tElem = getWindow(pWindowTitle).getElement("char_name_field")
  if tElem = 0 then
    return 0
  end if
  tElem.setText(EMPTY)
  tElem.setFocus(1)
end

on ClearPasswordFields me
  tWndObj = getWindow(pWindowTitle)
  tWndObj.getElement("char_pw_field").setText(EMPTY)
  tWndObj.getElement("char_pwagain_field").setText(EMPTY)
  pTempPassword["char_pw_field"] = EMPTY
  pTempPassword["char_pwagain_field"] = EMPTY
  tWndObj.getElement("char_pw_field").setFocus(1)
end

on registrationReady me
  getObject(#session).set(#userName, pPropsToServer["name"])
  getObject(#session).set(#password, pPropsToServer["password"])
  getObject(#session).set("user_figure", pPropsToServer["figure"].duplicate())
  if (pmode = "registration") or (pmode = "parent_email") or (pmode = "parent_email_strong_coppa") then
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
  if pRegProcess = 0 then
    return error(me, "registration process not found", #changePage)
  end if
  if tParm.ilk = #string then
    me.getMyDataFromFields()
    me.enterPage(tParm)
  else
    if tParm.ilk = #integer then
      if tParm > 0 then
        if me.leavePage(pOpenWindow) = 0 then
          return 0
        end if
      else
        me.getMyDataFromFields()
      end if
      pRegProcessLocation = pRegProcessLocation + tParm
      if pRegProcessLocation < 1 then
        pRegProcessLocation = 1
      end if
      if pRegProcessLocation > pRegProcess.count then
        pRegProcessLocation = pRegProcess.count
      end if
      tNextWindow = pRegProcess[pRegProcessLocation]
      me.enterPage(tNextWindow & ".window")
    end if
  end if
end

on leavePage me, tCurrentWindow
  case tCurrentWindow of
    "reg_legal.window":
      pErrorMsg = EMPTY
      tProceed = 1
      tProceed = tProceed and me.checkAgreeTerms()
      if tProceed then
        me.getMyDataFromFields()
      else
        executeMessage(#alert, [#title: "alert_reg_t", #Msg: pErrorMsg, #id: "problems", #modal: 1])
        return 0
      end if
    "reg_namepage.window":
      me.getMyDataFromFields()
      if pNameChecked = 0 then
        if me.checkName() = 1 then
          me.ChangeWindowView("reg_loading.window")
        end if
        return 0
      end if
    "reg_namepage_mission.window":
      me.getMyDataFromFields()
    "reg_infopage.window":
      if not windowExists(pWindowTitle) then
        return 0
      end if
      tWndObj = getWindow(pWindowTitle)
      tDay = integer(tWndObj.getElement("char_dd_field").getText())
      if not tWndObj.elementExists("monthDrop") then
        return error(me, "No month drop!", #leavePage)
      end if
      tMonthSelection = tWndObj.getElement("monthDrop").getSelection()
      tMonth = integer(chars(tMonthSelection, tMonthSelection.length - 1, tMonthSelection.length))
      tYear = integer(tWndObj.getElement("char_yyyy_field").getText())
      tEmail = tWndObj.getElement("char_email_field").getText()
      pErrorMsg = EMPTY
      tProceed = 1
      tProceed = tProceed and me.checkPasswords(pTempPassword["char_pw_field"], pTempPassword["char_pwagain_field"])
      tBirthOK = me.validateBirthday(tYear, tMonth, tDay)
      tProceed = tProceed and tBirthOK
      tEmailOK = me.validateEmail(tEmail)
      tProceed = tProceed and tEmailOK
      if not tBirthOK then
        pErrorMsg = pErrorMsg & getText("alert_reg_birthday") & RETURN
      end if
      if not tEmailOK then
        pErrorMsg = pErrorMsg & getText("alert_reg_email") & RETURN
      end if
      if pPasswordErrors <> EMPTY then
        tProceed = 0
        pErrorMsg = pErrorMsg & pPasswordErrors & RETURN
        pPasswordErrors = EMPTY
      end if
      if not tProceed then
        executeMessage(#alert, [#title: "alert_reg_t", #Msg: pErrorMsg, #id: "problems", #modal: 1])
        return 0
      end if
      pPropsToServer["password"] = pTempPassword["char_pw_field"]
      me.getMyDataFromFields()
      if not pPasswordChecked then
        pPasswordErrors = EMPTY
        pErrorMsg = EMPTY
        me.getComponent().sendValidatePassword(pPropsToServer["password"])
        return 0
      end if
      if not pEmailChecked then
        me.getComponent().checkEmailAddress(tEmail)
        return 0
      end if
      if (pmode = "parent_email") or (pmode = "parent_email_strong_coppa") then
        if me.getComponent().getParentEmailNeededFlag() <> 1 then
          tItemD = the itemDelimiter
          the itemDelimiter = "."
          tBirthday = pPropsToServer["birthday"].item[3]
          tBirthday = tBirthday & "." & pPropsToServer["birthday"].item[2]
          tBirthday = tBirthday & "." & pPropsToServer["birthday"].item[1]
          the itemDelimiter = tItemD
          tHabboID = pPropsToServer["name"]
          me.getComponent().parentEmailNeedQuery(tBirthday, tHabboID)
          me.ChangeWindowView("reg_loading.window")
          return 0
        end if
      end if
    "reg_infopage_no_age.window":
      if not windowExists(pWindowTitle) then
        return 0
      end if
      tWndObj = getWindow(pWindowTitle)
      tEmail = tWndObj.getElement("char_email_field").getText()
      pErrorMsg = EMPTY
      tProceed = 1
      tProceed = tProceed and me.checkPasswords(pTempPassword["char_pw_field"], pTempPassword["char_pwagain_field"])
      tEmailOK = me.validateEmail(tEmail)
      tProceed = tProceed and tEmailOK
      if not tEmailOK then
        pErrorMsg = pErrorMsg & getText("alert_reg_email") & RETURN
      end if
      if pPasswordErrors <> EMPTY then
        tProceed = 0
        pErrorMsg = pErrorMsg & pPasswordErrors & RETURN
        pPasswordErrors = EMPTY
      end if
      if not tProceed then
        executeMessage(#alert, [#title: "alert_reg_t", #Msg: pErrorMsg, #id: "problems", #modal: 1])
        return 0
      end if
      pPropsToServer["password"] = pTempPassword["char_pw_field"]
      me.getMyDataFromFields()
      if not pPasswordChecked then
        pPasswordErrors = EMPTY
        pErrorMsg = EMPTY
        me.getComponent().sendValidatePassword(pPropsToServer["password"])
        return 0
      end if
      if not pEmailChecked then
        me.getComponent().checkEmailAddress(tEmail)
        return 0
      end if
      if (pmode = "parent_email") or (pmode = "parent_email_strong_coppa") then
        if me.getComponent().getParentEmailNeededFlag() <> 1 then
          tItemD = the itemDelimiter
          the itemDelimiter = "."
          tBirthday = pPropsToServer["birthday"].item[3] & "." & pPropsToServer["birthday"].item[2] & "." & pPropsToServer["birthday"].item[1]
          the itemDelimiter = tItemD
          tHabboID = pPropsToServer["name"]
          me.getComponent().parentEmailNeedQuery(tBirthday, tHabboID)
          me.ChangeWindowView("reg_loading.window")
          return 0
        end if
      end if
    "reg_confirm.window":
      if getObject(#session).GET("conf_coppa") then
        tItemD = the itemDelimiter
        the itemDelimiter = "."
        tdata = pPropsToServer["birthday"].item[3] & "." & pPropsToServer["birthday"].item[2] & "." & pPropsToServer["birthday"].item[1]
        the itemDelimiter = tItemD
        me.getComponent().checkAge(tdata)
        me.ChangeWindowView("reg_loading.window")
        return 0
      else
        return 1
      end if
    "reg_parent_email.window":
      tWndObj = getWindow(pWindowTitle)
      tParentEmail = tWndObj.getElement("reg_parent_email_field").getText()
      tEmailOK = me.validateEmail(tParentEmail)
      if not tEmailOK then
        executeMessage(#alert, [#Msg: "alert_reg_parent_email", #id: "parentemailincorrect", #modal: 1])
        return 0
      end if
      tUserEmail = pPropsToServer["email"]
      if tParentEmail = EMPTY then
        return me.parentEmailIncorrect()
      end if
      me.getComponent().validateParentEmail(tUserEmail, tParentEmail)
      me.ChangeWindowView("reg_loading.window")
      return 0
    "reg_age_check.window":
      tWndObj = getWindow(pWindowTitle)
      tDay = integer(tWndObj.getElement("char_dd_field").getText())
      if not tWndObj.elementExists("monthDrop") then
        return error(me, "No month drop!", #leavePage)
      end if
      tMonthSelection = tWndObj.getElement("monthDrop").getSelection()
      tMonth = integer(chars(tMonthSelection, tMonthSelection.length - 1, tMonthSelection.length))
      tYear = integer(tWndObj.getElement("char_yyyy_field").getText())
      if voidp(tDay) or voidp(tMonth) or voidp(tYear) or (tYear < 1900) or (tMonth > 12) or (tDay > 31) then
        executeMessage(#alert, [#title: "alert_reg_t", #Msg: "Alert_CheckBirthday", #id: "problems", #modal: 1])
        return 0
      end if
      if tDay < 10 then
        tDay = "0" & tDay
      end if
      if tMonth < 10 then
        tMonth = "0" & tMonth
      end if
      tdata = tYear & "." & tMonth & "." & tDay
      pPropsToServer["birthday"] = tDay & "." & tMonth & "." & tYear
      me.getComponent().checkAge(tdata)
      me.ChangeWindowView("reg_loading.window")
      return 0
  end case
  return 1
end

on enterPage me, tWindow
  me.ChangeWindowView(tWindow)
  case tWindow of
    "reg_legal.window":
      me.setMyDataToFields()
      me.updateCheckButton("char_terms_checkbox", "has_read_agreement")
    "reg_namepage.window":
      me.setMyDataToFields()
      if (pmode = "registration") or (pmode = "parent_email") or (pmode = "parent_email_strong_coppa") then
        pNameChecked = 0
      else
        pNameChecked = 1
      end if
      if pPropsToServer["figure"].count = 0 then
        me.createDefaultFigure()
      end if
      me.createTemplateHuman()
      me.updateSexRadioButtons()
      me.updateFigurePreview()
      me.updateAllPrewIcons()
    "reg_namepage_mission.window":
      me.setMyDataToFields()
      if pPropsToServer["figure"].count = 0 then
        me.createDefaultFigure()
      end if
      me.createTemplateHuman()
      me.updateSexRadioButtons()
      me.updateFigurePreview()
      me.updateAllPrewIcons()
    "reg_infopage.window":
      pPasswordChecked = 0
      me.setMyDataToFields()
      tWinObj = getWindow(pWindowTitle)
      if tWinObj.elementExists("monthDrop") then
        tWinObj.getElement("monthDrop").setOrdering(0)
      end if
      if pmode = "update" then
        executeMessage(#alert, [#title: "reg_note_title", #Msg: "reg_note_text", #id: "pwnote", #modal: 1])
      end if
    "reg_infopage_no_age":
      pPasswordChecked = 0
      me.setMyDataToFields()
      me.updateCheckButton("char_spam_checkbox", "directMail")
    "reg_info_update.window":
      me.setMyDataToFields()
      me.updateCheckButton("char_spam_checkbox", "directMail")
      tWinObj = getWindow(pWindowTitle)
      tStr = tWinObj.getElement("update_change_email").getText()
      tStr = tStr & " >>"
      tWinObj.getElement("update_change_email").setText(tStr)
      tStr = tWinObj.getElement("update_change_pwd").getText()
      tStr = tStr & " >>"
      tWinObj.getElement("update_change_pwd").setText(tStr)
    "reg_confirm.window":
      me.updateCheckButton("char_spam_checkbox", "directMail")
      me.setMyDataToFields()
    "reg_done.window":
      me.registrationReady()
      tWndObj = getWindow(pWindowTitle)
      getObject(#session).set("user_figure", pPropsToServer["figure"].duplicate())
      if objectExists("Figure_Preview") then
        tBuffer = getObject("Figure_Preview").createTemplateHuman("h", 2, "gest", "temp sml")
        tWndObj.getElement("reg_ownhabbo").setProperty(#buffer, tBuffer)
      end if
      if tWndObj.elementExists("reg_tutorial_link") then
        tLinkURL = getText("reg_tutorial_url", EMPTY)
        if not stringp(tLinkURL) or (tLinkURL.length < 10) then
          tWndObj.getElement("reg_tutorial_link").setProperty(#visible, 0)
        else
          tWndObj.getElement("reg_tutorial_link").setText(getText("reg_tutorial_txt") && ">>")
        end if
      end if
    "reg_welcome.window":
      if variableExists("balloon.margin.offset.v") then
        tWinObj = getWindow(pWindowTitle)
        if tWinObj.elementExists("reg_welcome_balloon") then
          tWinObj.getElement("reg_welcome_balloon").moveBy(0, getVariable("balloon.margin.offset.v"))
        end if
      end if
      me.setMyDataToFields()
    "reg_age_check.window":
      tWinObj = getWindow(pWindowTitle)
      if tWinObj.elementExists("monthDrop") then
        tWinObj.getElement("monthDrop").setOrdering(0)
      end if
      me.setMyDataToFields()
    otherwise:
      me.setMyDataToFields()
  end case
end

on flipImage me, tImg_a
  tImg_b = image(tImg_a.width, tImg_a.height, tImg_a.depth)
  tQuad = [point(tImg_a.width, 0), point(0, 0), point(0, tImg_a.height), point(tImg_a.width, tImg_a.height)]
  tImg_b.copyPixels(tImg_a, tQuad, tImg_a.rect)
  return tImg_b
end

on highlightVerifyTopic me
  getWindow(pVerifyChangeWndID).getElement("updateaccount_topic").setProperty(#color, rgb(220, 80, 0))
end

on responseToAccountUpdate me, tStatus
  tWndObj = getWindow(pVerifyChangeWndID)
  tWndObj.unmerge()
  case tStatus of
    "0":
      tWndObj.merge("reg_update_success.window")
    "1":
      tWndObj.merge(pLastWindow)
      tWndObj.getElement("updateaccount_topic").setText(getText("reg_verification_incorrectPassword"))
      if tWndObj.elementExists("monthDrop") then
        tWndObj.getElement("monthDrop").setOrdering(0)
      end if
      me.highlightVerifyTopic()
    "2":
      tWndObj.merge(pLastWindow)
      if tWndObj.elementExists("monthDrop") then
        tWndObj.getElement("monthDrop").setOrdering(0)
      end if
      tWndObj.getElement("updateaccount_topic").setText(getText("reg_verification_incorrectBirthday"))
      me.highlightVerifyTopic()
    otherwise:
      return error(me, "Invalid parameter in ACCOUNT_UPDATE_STATUS", #responseToAccountUpdate)
  end case
  if pPwdEmailUpdateForced and tWndObj.elementExists("update_cancel_button") then
    tWndObj.getElement("update_cancel_button").deactivate()
  end if
end

on blinkChecking me
  if not windowExists(pVerifyChangeWndID) then
    return 0
  end if
  if timeoutExists(#checking_blinker) then
    return 0
  end if
  tElem = getWindow(pVerifyChangeWndID).getElement("updating_text")
  if not tElem then
    return 0
  end if
  tElem.setProperty(#visible, not tElem.getProperty(#visible))
  return createTimeout(#checking_blinker, 500, #blinkChecking, me.getID(), VOID, 1)
end

on updatePasswordAsterisks me, tParams
  tWndObj = getWindow(tParams[1])
  if tWndObj = 0 then
    return 0
  end if
  tElementId = tParams[2]
  tPwdElement = tWndObj.getElement(tElementId)
  if tPwdElement = 0 then
    return 0
  end if
  tPwdTxt = tPwdElement.getText()
  repeat with i = 1 to tPwdTxt.length
    tChar = chars(tPwdTxt, i, i)
    if (tChar <> "*") and (tChar <> " ") then
      pTempPassword[tElementId] = chars(pTempPassword[tElementId], 1, i - 1) & tChar & chars(pTempPassword[tElementId], i + 1, i + 1)
    end if
  end repeat
  tStars = EMPTY
  repeat with i = 1 to pTempPassword[tElementId].length
    tStars = tStars & "*"
  end repeat
  tPwdElement.setText(tStars)
end

on eventProcFigurecreator me, tEvent, tSprID, tParm, tWndID
  tRect = getWindow(tWndID).getElement(tSprID).getProperty(#rect)
  if tEvent = #mouseUp then
    case tSprID of
      "close", "reg_cancel_button", "reg_exit_button":
        if (pmode = "registration") or (pmode = "parent_email") or (pmode = "parent_email_strong_coppa") then
          if pRegProcess.ilk = #list then
            if pRegProcessLocation = pRegProcess.count then
              me.registrationReady()
            end if
          end if
        end if
        me.getComponent().closeFigureCreator()
        me.getComponent().updateState("start")
        if objectExists(#session) then
          if getObject(#session).GET("userLoggedIn") = 0 then
            if threadExists(#login) then
              getThread(#login).getInterface().showLogin()
            end if
            if connectionExists(getVariable("connection.info.id")) then
              removeConnection(getVariable("connection.info.id"))
            end if
          end if
        end if
      "reg_underage_button":
        if getObject(#session).GET("conf_coppa") and (pmode <> "forced") then
          me.getComponent().getRealtime()
        else
          pPropsToServer["parentagree"] = 1
          me.changePage(1)
        end if
      "reg_olderage_button":
        pPropsToServer["parentagree"] = 0
        me.changePage(1)
      "reg_next_button":
        me.changePage(1)
      "reg_prev_button":
        me.changePage(-1)
      "reg_done_button":
        if me.leavePage(pOpenWindow) = 1 then
          getObject(#session).set("user_figure", pPropsToServer["figure"].duplicate())
          me.getComponent().sendFigureUpdateToServer(pPropsToServer)
          me.getComponent().updateState("start")
          return me.closeFigureCreator()
        else
          return 0
        end if
      "reg_ready":
        me.closeFigureCreator()
        me.getComponent().updateState("start")
        if objectExists("Figure_Preview") then
          tBuffer = getObject("Figure_Preview").createTemplateHuman("h", 2, "remove")
        end if
        me.getComponent().tryLoginAfterRegistration()
      "char_sex_m":
        pPropsToServer["sex"] = "M"
        me.createDefaultFigure(1)
        me.updateSexRadioButtons()
      "char_sex_f":
        pPropsToServer["sex"] = "F"
        me.createDefaultFigure(1)
        me.updateSexRadioButtons()
      "char_spam_checkbox":
        me.updateCheckButton("char_spam_checkbox", "directMail", 1)
      "char_terms_checkbox":
        me.updateCheckButton("char_terms_checkbox", "has_read_agreement", 1)
      "char_permission_checkbox":
        me.updateCheckButton("char_permission_checkbox", "parent_permission", 1)
      "char_name_field":
        if pNameChecked = 1 then
          if (pmode = "registration") or (pmode = "parent_email") or (pmode = "parent_email_strong_coppa") then
            pNameChecked = 0
          end if
        end if
      "char_email_field":
        pEmailChecked = 0
      "char_continent_drop":
        tCountryListImg = getObject("CountryMngr").getCountryListImg(tParm)
        getWindow(pWindowTitle).getElement("char_country_field").feedImage(tCountryListImg)
      "char_terms_linktext":
        openNetPage("url_helpterms")
      "char_pledge_linktext":
        openNetPage("url_helppledge")
      "char_ppledge_linktext":
        openNetPage("url_privacypledge")
      "char_pglink":
        openNetPage("url_helpparents")
      "reg_parentemail_link1":
        openNetPage("reg_parentemail_link_url1")
      "reg_parentemail_link2":
        openNetPage("reg_parentemail_link_url2")
      "update_change_pwd":
        me.openPwdEmailUpdate(#password)
      "update_change_email":
        me.openPwdEmailUpdate(#email)
      "reg_tutorial_link":
        openNetPage("reg_tutorial_url")
      otherwise:
        if (tSprID contains "change") and (tSprID contains "button") then
          tTempDelim = the itemDelimiter
          the itemDelimiter = "."
          tPart = tSprID.item[2]
          tButtonType = tSprID.item[tSprID.item.count - 1]
          the itemDelimiter = tTempDelim
          if tButtonType contains "left" then
            tButtonType = -1
          else
            tButtonType = 1
          end if
          if not (tSprID contains "color") then
            me.changePart(tPart, tButtonType)
          else
            me.changePartColor(tPart, tButtonType)
          end if
        end if
    end case
  else
    if tEvent = #keyDown then
      case tSprID of
        "char_name_field":
          if charToNum(the key) = 0 then
            return 0
          end if
          tValidKeys = getVariable("permitted.name.chars")
          tDeniedKeys = getVariable("denied.name.chars", EMPTY)
          if not (tValidKeys contains the key) then
            case the keyCode of
              36:
                return 1
              48:
                me.checkName()
                return 0
              49:
                if tValidKeys.length > 0 then
                  executeMessage(#helptooltip, [#Msg: getText("reg_use_allowed_chars") && tValidKeys, #pos: tRect])
                end if
                return 1
              51:
                return 0
              117:
                getWindow(pWindowTitle).getElement(tSprID).setText(EMPTY)
                return 0
              123, 124, 125, 126:
                return 0
              otherwise:
                if tDeniedKeys contains the key then
                  executeMessage(#helptooltip, [#Msg: getText("reg_use_allowed_chars") && tValidKeys, #pos: tRect])
                  return 1
                end if
                if tValidKeys = EMPTY then
                  return 0
                else
                  executeMessage(#helptooltip, [#Msg: getText("reg_use_allowed_chars") && tValidKeys, #pos: tRect])
                  return 1
                end if
            end case
          else
            return 0
          end if
        "char_pw_field", "char_pwagain_field":
          tValidKeys = getVariable("permitted.password.chars")
          if pNameChecked = 0 then
            if not me.checkName() then
              return 1
            end if
          end if
          if voidp(pTempPassword[tSprID]) then
            pTempPassword[tSprID] = EMPTY
          end if
          case the keyCode of
            36:
              return 1
            48:
              return 0
            49:
              if tValidKeys.length > 0 then
                executeMessage(#helptooltip, [#Msg: getText("reg_use_allowed_chars") && tValidKeys, #pos: tRect])
              end if
              return 1
            123, 124, 125, 126:
              return 1
            51:
              if pTempPassword[tSprID].length > 0 then
                tTempPass = pTempPassword[tSprID]
                pTempPassword[tSprID] = chars(tTempPass, 1, tTempPass.length - 1)
              end if
            117:
              getWindow(tWndID).getElement(tSprID).setText(EMPTY)
              pTempPassword[tSprID] = EMPTY
            otherwise:
              tValidKeys = getVariable("permitted.password.chars")
              tTheKey = the key
              if not (tValidKeys = EMPTY) then
                if not (tValidKeys contains tTheKey) then
                  executeMessage(#helptooltip, [#Msg: getText("reg_use_allowed_chars") && tValidKeys, #pos: tRect])
                  return 1
                end if
                if pTempPassword[tSprID].length > getIntVariable("pass.length.max", 16) then
                  executeMessage(#helptooltip, [#Msg: "alert_shortenPW", #pos: tRect])
                  return 1
                end if
              end if
          end case
          pPasswordChecked = 0
          tTimeoutHideName = "asteriskUpdate" & the milliSeconds
          createTimeout(tTimeoutHideName, 1, #updatePasswordAsterisks, me.getID(), [tWndID, tSprID], 1)
          return 0
        "char_email_field":
          return 0
        "char_dd_field":
          case the keyCode of
            48:
              return 0
            51:
              return 0
            117:
              return 0
            otherwise:
              if getWindow(tWndID).getElement(tSprID).getText().length >= 2 then
                return 1
              end if
              tASCII = charToNum(the key)
              if (tASCII < 48) or (tASCII > 57) then
                return 1
              end if
          end case
        "char_yyyy_field":
          case the keyCode of
            48:
              return 0
            51:
              return 0
            117:
              return 0
            otherwise:
              if getWindow(tWndID).getElement(tSprID).getText().length >= 4 then
                return 1
              end if
              tASCII = charToNum(the key)
              if (tASCII < 48) or (tASCII > 57) then
                return 1
              end if
          end case
      end case
    end if
  end if
end

on eventProcVerifyWindow me, tEvent, tSprID, tParm, tWndID
  tWndObj = getWindow(tWndID)
  if not tWndObj then
    return 0
  end if
  if voidp(pTempPassword[tSprID]) then
    pTempPassword[tSprID] = EMPTY
  end if
  tRect = getWindow(tWndID).getElement(tSprID).getProperty(#rect)
  if tEvent = #keyDown then
    case the keyCode of
      36:
        return 1
      48:
        return 0
      49:
        return 1
      51:
        if pTempPassword[tSprID].length > 0 then
          tTempPass = pTempPassword[tSprID]
          pTempPassword[tSprID] = chars(tTempPass, 1, tTempPass.length - 1)
        end if
      117:
        pTempPassword[tSprID] = EMPTY
      otherwise:
        tPasswordFields = list("char_currpwd_field", "char_newpwd1_field", "char_newpwd2_field")
        tDOBFields = list("char_dd_field", "char_yyyy_field")
        tTheKey = the key
        tASCII = charToNum(tTheKey)
        if tPasswordFields.getPos(tSprID) > 0 then
          if (the keyCode > 122) and (the keyCode < 127) then
            return 1
          end if
          tValidKeys = getVariable("permitted.password.chars")
          tTheKey = the key
          if not (tValidKeys = EMPTY) then
            if not (tValidKeys contains tTheKey) then
              executeMessage(#helptooltip, [#Msg: getText("reg_use_allowed_chars") && tValidKeys, #pos: tRect])
              return 1
            end if
            if pTempPassword[tSprID].length > getIntVariable("pass.length.max", 16) then
              executeMessage(#helptooltip, [#Msg: "alert_shortenPW", #pos: tRect])
              return 1
            end if
            pPasswordChecked = 0
          end if
          tTimeoutHideName = "asteriskUpdate" & the milliSeconds
          createTimeout(tTimeoutHideName, 1, #updatePasswordAsterisks, me.getID(), [tWndID, tSprID], 1)
          return 0
        else
          if tDOBFields.getPos(tSprID) > 0 then
            if (tASCII < 48) or (tASCII > 57) then
              return 1
            else
              if (tSprID = "char_dd_field") and (tWndObj.getElement("char_dd_field").getText().length >= 2) then
                return 1
              else
                if (tSprID = "char_yyyy_field") and (tWndObj.getElement("char_yyyy_field").getText().length >= 4) then
                  return 1
                end if
              end if
            end if
          end if
        end if
    end case
  else
    case tSprID of
      "update_cancel_button", "updateok_ok_button":
        pTempPassword = [:]
        removeWindow(tWndID)
        pPwdEmailUpdateForced = 0
        pUpdatingPassword = 0
      "updatepw_ok_button":
        pPasswordChecked = 0
        pUpdatingPassword = 1
        pErrorMsg = EMPTY
        pUpdatePropsToServer = [:]
        tCurrPwd = pTempPassword["char_currpwd_field"]
        pUpdatePropsToServer[#currPwd] = tCurrPwd
        if voidp(tCurrPwd) or (tCurrPwd.length < 1) then
          tWndObj.getElement("updateaccount_topic").setText(getText("Alert_ForgotSetPassword"))
          me.highlightVerifyTopic()
          return 0
        end if
        tDay = integer(tWndObj.getElement("char_dd_field").getText())
        if not tWndObj.elementExists("monthDrop") then
          return error(me, "No month drop!", #leavePage)
        end if
        tMonthSelection = tWndObj.getElement("monthDrop").getSelection()
        tMonth = integer(chars(tMonthSelection, tMonthSelection.length - 1, tMonthSelection.length))
        tYear = integer(tWndObj.getElement("char_yyyy_field").getText())
        if (tDay < 1) or (tMonth < 1) or (tYear < 1) then
          tWndObj.getElement("updateaccount_topic").setText(getText("Alert_CheckBirthday"))
          me.highlightVerifyTopic()
          return 0
        end if
        pUpdatePropsToServer[#day] = tDay
        pUpdatePropsToServer[#month] = tMonth
        pUpdatePropsToServer[#year] = tYear
        tPw1 = pTempPassword["char_newpwd1_field"]
        tPw2 = pTempPassword["char_newpwd2_field"]
        if not me.checkPasswords(tPw1, tPw2) then
          tWndObj.getElement("char_newpwd1_field").setText(EMPTY)
          tWndObj.getElement("char_newpwd2_field").setText(EMPTY)
          tWndObj.getElement("char_newpwd1_field").setFocus(1)
          tWndObj.getElement("updateaccount_topic").setText(pErrorMsg)
          me.highlightVerifyTopic()
          pTempPassword["char_newpwd1_field"] = EMPTY
          pTempPassword["char_newpwd2_field"] = EMPTY
          return 0
        end if
        tNewPwd = tPw1
        pUpdatePropsToServer[#newPwd] = tNewPwd
        tWndObj.unmerge()
        tWndObj.merge("reg_update_progress.window")
        pLastWindow = "reg_update_password.window"
        pTempPassword = [:]
        me.blinkChecking()
        pPasswordErrors = EMPTY
        pErrorMsg = EMPTY
        me.getComponent().sendValidatePassword(tNewPwd)
        return 0
      "updatemail_ok_button":
        tWndObj = getWindow(pVerifyChangeWndID)
        tEmail = tWndObj.getElement("char_newemail_field").getText()
        tYear = integer(tWndObj.getElement("char_yyyy_field").getText())
        if not tWndObj.elementExists("monthDrop") then
          return error(me, "No month drop!", #leavePage)
        end if
        tMonthSelection = tWndObj.getElement("monthDrop").getSelection()
        tMonth = integer(chars(tMonthSelection, tMonthSelection.length - 1, tMonthSelection.length))
        tDay = integer(tWndObj.getElement("char_dd_field").getText())
        tCurrPwd = pTempPassword["char_currpwd_field"]
        if voidp(tCurrPwd) or (ilk(tCurrPwd) <> #string) then
          tWndObj.getElement("updateaccount_topic").setText(getText("Alert_ForgotSetPassword"))
          me.highlightVerifyTopic()
          return 0
        end if
        if (tDay < 1) or (tMonth < 1) or (tYear < 1) then
          tWndObj.getElement("updateaccount_topic").setText(getText("Alert_CheckBirthday"))
          me.highlightVerifyTopic()
          return 0
        end if
        tEmailOK = 0
        if (length(tEmail) > 6) and (tEmail contains "@") then
          repeat with f = offset("@", tEmail) + 1 to length(tEmail)
            if tEmail.char[f] = "." then
              tEmailOK = 1
            end if
            if tEmail.char[f] = "@" then
              tEmailOK = 0
              exit repeat
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
          tProp = ["oldpassword": tCurrPwd, "birthday": tDOB, "email": tEmail]
          me.getComponent().sendUpdateAccountMsg(tProp)
        end if
    end case
  end if
end

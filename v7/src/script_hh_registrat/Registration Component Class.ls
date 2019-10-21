on construct(me)
  pValidPartProps = []
  pValidPartGroups = []
  pFigurePartListLoadedFlag = 0
  pAvailableSetListLoadedFlag = 0
  pState = 0
  pAgeCheckFlag = void()
  pParentEmailNeededFlag = void()
  pParentEmailAddress = ""
  pRegMsgStruct = []
  pRegMsgStruct.setAt("parentagree", [#id:1, "type":#boolean])
  pRegMsgStruct.setAt("name", [#id:2, "type":#string])
  pRegMsgStruct.setAt("password", [#id:3, "type":#string])
  pRegMsgStruct.setAt("figure", [#id:4, "type":#string])
  pRegMsgStruct.setAt("sex", [#id:5, "type":#string])
  pRegMsgStruct.setAt("customData", [#id:6, "type":#string])
  pRegMsgStruct.setAt("email", [#id:7, "type":#string])
  pRegMsgStruct.setAt("birthday", [#id:8, "type":#string])
  pRegMsgStruct.setAt("directMail", [#id:9, "type":#boolean])
  pRegMsgStruct.setAt("has_read_agreement", [#id:10, "type":#boolean])
  pRegMsgStruct.setAt("isp_id", [#id:11, "type":#string])
  pRegMsgStruct.setAt("partnersite", [#id:12, "type":#string])
  pRegMsgStruct.setAt("oldpassword", [#id:13, "type":#string])
  registerMessage(#enterRoom, me.getID(), #closeFigureCreator)
  registerMessage(#changeRoom, me.getID(), #closeFigureCreator)
  registerMessage(#leaveRoom, me.getID(), #closeFigureCreator)
  registerMessage(#show_registration, me.getID(), #openFigureCreator)
  registerMessage(#hide_registration, me.getID(), #closeFigureCreator)
  registerMessage(#figure_ready, me.getID(), #figureSystemReady)
  exit
end

on deconstruct(me)
  unregisterMessage(#enterRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#show_registration, me.getID())
  unregisterMessage(#hide_registration, me.getID())
  unregisterMessage(#figure_ready, me.getID())
  return(me.updateState("reset"))
  exit
end

on setBlockTime(me, tdata)
  setPref("blocktime", tdata)
  me.closeFigureCreator()
  executeMessage(#alert, [#title:"alert_win_coppa", #msg:"alert_reg_age", #id:"underage", #modal:1])
  return(removeConnection(getVariable("connection.info.id")))
  exit
end

on continueBlocking(me)
  me.closeFigureCreator()
  executeMessage(#alert, [#title:"alert_win_coppa", #msg:"alert_reg_blocked", #id:"underage", #modal:1])
  return(removeConnection(getVariable("connection.info.id")))
  exit
end

on getRealtime(me)
  getConnection(getVariable("connection.info.id")).send("COPPA_REG_GETREALTIME")
  exit
end

on checkBlockTime(me)
  tdata = getPref("Blocktime")
  getConnection(getVariable("connection.info.id")).send("COPPA_REG_CHECKTIME", [#string:tdata])
  exit
end

on resetBlockTime(me)
  setPref("blocktime", "0")
  return(me.updateState("openFigureCreator"))
  exit
end

on openFigureCreator(me)
  return(me.updateState("openFigureCreator"))
  exit
end

on openFigureUpdate(me)
  return(me.updateState("openFigureUpdate"))
  exit
end

on closeFigureCreator(me)
  return(me.getInterface().closeFigureCreator())
  exit
end

on reRegistrationRequired(me)
  return(me.updateState("openForcedUpdate"))
  exit
end

on figureSystemReady(me)
  return(me.updateState(pState))
  exit
end

on checkUserName(me, tNameStr)
  if objectExists(#string_validator) then
    if not getObject(#string_validator).validateString(tNameStr) then
      tFailed = getObject(#string_validator).getFailedChar()
      setText("alert_InvalidChar", replaceChunks(getText("alert_InvalidUserName"), "\\x", tFailed))
      executeMessage(#alert, [#msg:"alert_InvalidChar", #id:"nameinvalid"])
      return(0)
    end if
  end if
  pCheckingName = tNameStr
  if connectionExists(getVariable("connection.info.id", #info)) then
    getConnection(getVariable("connection.info.id", #info)).send("APPROVENAME", [#string:tNameStr, #short:0])
  end if
  return(1)
  exit
end

on checkIsNameAvailable(me, tNameStr)
  if connectionExists(getVariable("connection.info.id", #info)) then
    getConnection(getVariable("connection.info.id", #info)).send("FINDUSER", pCheckingName & "\t" & "REGNAME")
  end if
  exit
end

on sendNewFigureDataToServer(me, tPropList)
  if not objectExists("Figure_System") then
    return(error(me, "Figure system object not found", #sendNewFigureDataToServer))
  end if
  if not voidp(tPropList.getAt("figure")) then
    tFigure = getObject("Figure_System").GenerateFigureDataToServerMode(tPropList.getAt("figure"), tPropList.getAt("sex"))
    tPropList.setAt("figure", tFigure.getAt("figuretoServer"))
  end if
  if variableExists("user_isp") then
    if not voidp(getVariable("user_isp")) then
      tPropList.setAt("isp_id", getVariable("user_isp"))
    end if
  end if
  if variableExists("user_partnersite") then
    if not voidp(getVariable("user_partnersite")) then
      tPropList.setAt("partnersite", getVariable("user_partnersite"))
    end if
  end if
  tMsg = []
  f = 1
  repeat while f <= tPropList.count
    tProp = tPropList.getPropAt(f)
    if voidp(tPropList.getAt(tProp)) then
      return(error(me, "Data missing!!" && tProp, #sendFigureUpdateToServer))
    end if
    tValue = tPropList.getAt(tProp)
    if not voidp(pRegMsgStruct.getAt(tProp)) then
      tMsg.addProp(#short, pRegMsgStruct.getAt(tProp).id)
      if pRegMsgStruct.getAt(tProp).type = #boolean then
        tValue = integer(tValue)
      end if
      if pRegMsgStruct.getAt(tProp).type = #string and tValue.ilk <> #string then
        tValue = string(tValue)
      end if
      if pRegMsgStruct.getAt(tProp).type = #short and tValue.ilk <> #integer then
        tValue = integer(tValue)
      end if
      tMsg.addProp(pRegMsgStruct.getAt(tProp).type, tValue)
    end if
    f = 1 + f
  end repeat
  if connectionExists(getVariable("connection.info.id")) then
    return(getConnection(getVariable("connection.info.id")).send("REGISTER", tMsg))
  else
    return(error(me, "Connection not found:" && getVariable("connection.info.id"), #sendNewFigureDataToServer))
  end if
  exit
end

on sendFigureUpdateToServer(me, tPropList)
  if not objectExists("Figure_System") then
    return(error(me, "Figure system object not found", #sendFigureUpdateToServer))
  end if
  if not voidp(tPropList.getAt("figure")) then
    tFigure = getObject("Figure_System").GenerateFigureDataToServerMode(tPropList.getAt("figure"), tPropList.getAt("sex"))
    tPropList.setAt("figure", tFigure.getAt("figuretoServer"))
  end if
  if not voidp(tPropList.getAt("password")) then
    if me <> "" then
      if me = void() then
        return(error(me, "Password was reseted, abort update!", #sendFigureUpdateToServer))
      end if
      tMsg = []
      f = 1
      repeat while f <= tPropList.count
        tProp = tPropList.getPropAt(f)
        if voidp(tPropList.getAt(tProp)) then
          return(error(me, "Data missing!!" && tProp, #sendFigureUpdateToServer))
        end if
        tValue = tPropList.getAt(tProp)
        if not [tValue].getPos(getObject(#session).get("user_" & tProp)) then
          if not voidp(pRegMsgStruct.getAt(tProp)) then
            tMsg.addProp(#short, pRegMsgStruct.getAt(tProp).id)
            if pRegMsgStruct.getAt(tProp).type = #boolean then
              tValue = integer(tValue)
            end if
            if pRegMsgStruct.getAt(tProp).type = #string and tValue.ilk <> #string then
              tValue = string(tValue)
            end if
            if pRegMsgStruct.getAt(tProp).type = #short and tValue.ilk <> #integer then
              tValue = integer(tValue)
            end if
            tMsg.addProp(pRegMsgStruct.getAt(tProp).type, tValue)
          end if
        end if
        f = 1 + f
      end repeat
      if connectionExists(getVariable("connection.info.id")) then
        return(getConnection(getVariable("connection.info.id")).send("UPDATE", tMsg))
      else
        return(error(me, "Connection not found:" && getVariable("connection.info.id"), #sendFigureUpdateToServer))
      end if
      exit
    end if
  end if
end

on newFigureReady(me)
  me.closeFigureCreator()
  me.updateState("start")
  return(1)
  exit
end

on figureUpdateReady(me)
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("INFORETRIEVE")
  else
    error(me, "Connection not found:" && getVariable("connection.info.id"), #figureUpdateReady)
  end if
  if getObject(#session).exists("conf_parent_email_request_reregistration") then
    if getObject(#session).get("conf_parent_email_request_reregistration") then
      me.sendParentEmail()
    end if
  end if
  me.closeFigureCreator()
  return(me.updateState("start"))
  exit
end

on setAvailableSetList(me, tList)
  if pFigurePartListLoadedFlag and not voidp(tList) then
    me.initializeSelectablePartList(tList)
    pAvailableSetListLoadedFlag = 1
    if me = "openFigureCreator" then
      return(me.updateState("openFigureCreator"))
    else
      if me = "openFigureUpdate" then
        return(me.updateState("openFigureUpdate"))
      end if
    end if
  end if
  exit
end

on getAvailableSetList(me)
  if pFigurePartListLoadedFlag = 1 and pAvailableSetListLoadedFlag = 0 then
    if connectionExists(getVariable("connection.info.id")) then
      getConnection(getVariable("connection.info.id")).send("GETAVAILABLESETS")
    end if
  end if
  exit
end

on checkAge(me, tAge)
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("AC", tAge)
  end if
  exit
end

on parentEmailNeedGuery(me, tBirthday, tHabboID)
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("PARENT_EMAIL_REQUIRED", [#string:tBirthday, #string:tHabboID])
  end if
  exit
end

on sendParentEmail(me)
  if pParentEmailAddress <> "" then
    tParentEmail = pParentEmailAddress
    if connectionExists(getVariable("connection.info.id")) then
      getConnection(getVariable("connection.info.id")).send("SEND_PARENT_EMAIL", [#string:tParentEmail])
    end if
  end if
  exit
end

on validateParentEmail(me, tUserEmail, tParentEmail)
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("VALIDATE_PARENT_EMAIL", [#string:tUserEmail, #string:tParentEmail])
  end if
  pParentEmailAddress = tParentEmail
  exit
end

on setAgeCheckResult(me, tFlag)
  pAgeCheckFlag = tFlag
  me.getInterface().finishRegistration(tFlag)
  exit
end

on getAgeCheckResult(me)
  return(pAgeCheckFlag)
  exit
end

on parentEmailNeedGueryResult(me, tFlag)
  pParentEmailNeededFlag = tFlag
  me.getInterface().parentEmailQueryStatus(tFlag)
  exit
end

on parentEmailValidated(me, tFlag)
  if tFlag then
    me.getInterface().parentEmailOk()
  else
    pParentEmailAddress = ""
    me.getInterface().parentEmailIncorrect()
  end if
  exit
end

on getParentEmailNeededFlag(me)
  return(pParentEmailNeededFlag)
  exit
end

on sendUpdateAccountMsg(me, tPropList)
  if not ilk(tPropList, #propList) then
    return(error(me, "tPropList was not propertylist:" && tPropList, #sendUpdateMsg))
  else
    if voidp(tPropList.getAt("oldpassword")) or voidp(tPropList.getAt("birthday")) then
      return(error(me, "Missing old password or birthday:" && tPropList, #sendUpdateMsg))
    else
      if voidp(tPropList.getAt("password")) and voidp(tPropList.getAt("email")) then
        return(error(me, "Password or email required:" && tPropList, #sendUpdateMsg))
      else
        if not voidp(tPropList.getAt("password")) and not voidp(tPropList.getAt("email")) then
          return(error(me, "Password and email cannot appear together:" && tPropList, #sendUpdateMsg))
        end if
      end if
    end if
  end if
  tMsg = []
  f = 1
  repeat while f <= tPropList.count
    tProp = tPropList.getPropAt(f)
    if voidp(tPropList.getAt(tProp)) then
      return(error(me, "Data missing!!" && tProp, #sendUpdateMsg))
    end if
    tValue = tPropList.getAt(tProp)
    if not voidp(pRegMsgStruct.getAt(tProp)) then
      tMsg.addProp(#short, pRegMsgStruct.getAt(tProp).id)
      if pRegMsgStruct.getAt(tProp).type = #boolean then
        tValue = integer(tValue)
      end if
      if pRegMsgStruct.getAt(tProp).type = #string and tValue.ilk <> #string then
        tValue = string(tValue)
      end if
      if pRegMsgStruct.getAt(tProp).type = #short and tValue.ilk <> #integer then
        tValue = integer(tValue)
      end if
      tMsg.addProp(pRegMsgStruct.getAt(tProp).type, tValue)
    else
      return(error(me, "Data property not found from structs!" && tProp, #sendUpdateMsg))
    end if
    f = 1 + f
  end repeat
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("UPDATE_ACCOUNT", tMsg)
  end if
  exit
end

on getState(me)
  return(pState)
  exit
end

on updateState(me, tstate, tProps)
  if me = "reset" then
    pState = tstate
    me.construct()
    return(0)
  else
    if me = "loadFigurePartList" then
      return()
      pState = tstate
      tURL = getVariable("external.figurepartlist.txt")
      tMem = tURL
      if the moviePath contains "http://" then
        tURL = tURL & "?" & the milliSeconds
      else
        if tURL contains "http://" then
          tURL = tURL & "?" & the milliSeconds
        end if
      end if
      tmember = queueDownload(tURL, tMem, #field, 1)
      return(registerDownloadCallback(tmember, #updateState, me.getID(), "initialize"))
    else
      if me = "initialize" then
        pState = tstate
        tMemName = getVariable("external.figurepartlist.txt")
        if tMemName = 0 then
          tMemName = ""
        end if
        if not memberExists(tMemName) then
          tValidpartList = void()
          error(me, "Failure while loading part list", #updateState)
        else
          try()
          tValidpartList = value(member(getmemnum(tMemName)).text)
          if catch() then
            tValidpartList = void()
          end if
        end if
        me.initializeValidPartLists(tValidpartList)
        pFigurePartListLoadedFlag = 1
        setVariable("figurepartlist.loaded", 1)
        if memberExists(tMemName) then
          removeMember(tMemName)
        end if
        return(me.updateState("start"))
      else
        if me = "start" then
          pState = tstate
          return(1)
        else
          if me = "openFigureCreator" then
            pState = tstate
            if not objectExists("Figure_System") then
              return(error(me, "Figure system object not found", #updateState))
            end if
            if not objectExists(#session) then
              return(error(me, "Session object not found", #updateState))
            end if
            if threadExists(#login) and not connectionExists(getVariable("connection.info.id")) then
              getThread(#login).getComponent().connect()
              me.getInterface().showLoadingWindow()
            else
              if objectExists(#getServerDate) then
                if not getObject(#session).exists("server_date") then
                  getObject(#getServerDate).getDate()
                end if
              end if
              tRegistrationProcessMode = "registration"
              if getObject(#session).exists("conf_parent_email_request") then
                if getObject(#session).get("conf_parent_email_request") then
                  tRegistrationProcessMode = "parent_email"
                end if
              end if
              if getObject(#session).get("conf_coppa") and getPref("Blocktime") > 0 then
                return(me.checkBlockTime())
              end if
              if not getObject("Figure_System").isFigureSystemReady() then
                me.getInterface().showLoadingWindow()
                return(0)
              else
                me.getInterface().openFigureCreator(tRegistrationProcessMode)
              end if
            end if
            return(1)
          else
            if me = "openFigureUpdate" then
              pState = tstate
              if not objectExists("Figure_System") then
                return(error(me, "Figure system object not found", #updateState))
              end if
              if not getObject("Figure_System").isFigureSystemReady() then
                me.getInterface().showLoadingWindow("update")
                return()
              end if
              tFigure = getObject("Figure_System").validateFigure(getObject(#session).get("user_figure"), getObject(#session).get("user_sex"))
              getObject(#session).set("user_figure", tFigure)
              me.getInterface().showHideFigureCreator("update")
              return(1)
            else
              if me = "openForcedUpdate" then
                pState = tstate
                if not objectExists("Figure_System") then
                  return(error(me, "Figure system object not found", #updateState))
                end if
                if not getObject("Figure_System").isFigureSystemReady() then
                  me.getInterface().showLoadingWindow("forced")
                  return()
                end if
                tFigure = getObject("Figure_System").validateFigure(getObject(#session).get("user_figure"), getObject(#session).get("user_sex"))
                getObject(#session).set("user_figure", tFigure)
                tCoppaFlag = getObject(#session).get("conf_coppa")
                tParentEmailFlag = getObject(#session).get("conf_parent_email_request_reregistration")
                if tCoppaFlag = 1 and tParentEmailFlag = 0 then
                  me.getInterface().showHideFigureCreator("coppa_forced")
                else
                  if tCoppaFlag = 1 and tParentEmailFlag = 1 then
                    me.getInterface().showHideFigureCreator("parent_email_coppa_forced")
                  else
                    if tCoppaFlag = 0 and tParentEmailFlag = 1 then
                      me.getInterface().showHideFigureCreator("parent_email_forced")
                    else
                      me.getInterface().showHideFigureCreator("forced")
                    end if
                  end if
                end if
                if getObject(#session).get("conf_parent_email_request_reregistration") then
                  tTempBirthday = getObject(#session).get("user_birthday")
                  tBirthday = ""
                  if stringp(tTempBirthday) then
                    tDelim = the itemDelimiter
                    the itemDelimiter = "."
                    if tTempBirthday.count(#item) = 3 then
                      tBirthday = tTempBirthday.getProp(#item, 3) & "." & tTempBirthday.getProp(#item, 2) & "." & tTempBirthday.getProp(#item, 1)
                    end if
                    the itemDelimiter = tDelim
                  end if
                  tHabboID = getObject(#session).get("user_name")
                  me.parentEmailNeedGuery(tBirthday, tHabboID)
                end if
                return(1)
              else
                return(error(me, "Unknown state:" && tstate, #updateState))
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  exit
end
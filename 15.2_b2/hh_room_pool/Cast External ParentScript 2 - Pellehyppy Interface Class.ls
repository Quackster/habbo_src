property pWindowTitle, pSwimSuitIndex, pSwimSuitModel, pSwimSuitColor, pBottomBarId, pWindowName, pChatmode, pSelectedObj, pMessengerFlash, pNewMsgCount, pNewBuddyReq, pFloodblocking, pFloodTimer, pFloodEnterCount, pSignImg, pSignState, pOldPosH, pOldPosV

on construct me
  pWindowTitle = "pellehyppy"
  pBottomBarId = "Room_bar"
  pSignState = VOID
  pChatmode = "CHAT"
  if not objectExists("Figure_System_Pool") then
    createObject("Figure_System_Pool", ["Figure System Class"])
    getObject("Figure_System_Pool").define(["type": "member", "source": "swimfigure_ids_"])
  end if
  return removeWindow(pBottomBarId)
end

on deconstruct me
  if objectExists("Figure_System_Pool") then
    removeObject("Figure_System_Pool")
  end if
  me.closeUimaKoppi()
  me.hideRoomBar()
  return 1
end

on openUimakoppi me
  pSwimSuitIndex = 1
  if getObject(#session).get("user_sex") = "F" then
    pSwimSuitModel = "s01"
  else
    pSwimSuitModel = "s02"
  end if
  me.getDefaultSwimSuitColor()
  me.changeUimakoppiWindow("ph_swimsuit.window", "uimakoppi")
end

on closeUimaKoppi me
  if windowExists("uimakoppi") then
    pSwimSuitIndex = 1
    removeWindow("uimakoppi")
  end if
end

on changeUimakoppiWindow me, tWindowName, tWindowTitle
  if voidp(tWindowTitle) then
    tWindowTitle = pWindowTitle
  end if
  createWindow(tWindowTitle, tWindowName)
  tWndObj = getWindow(tWindowTitle)
  tWndObj.center()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcUimakoppi, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProcUimakoppi, me.getID(), #mouseDown)
  tWndObj.registerProcedure(#eventProcUimakoppi, me.getID(), #keyDown)
  me.createFigurePrew()
  return 1
end

on createFigurePrew me
  if not objectExists("Figure_Preview") then
    return error(me, "Figure preview not found!", #createFigurePrew)
  end if
  tFigure = getObject(#session).get("user_figure").duplicate()
  tFigure["hd"]["model"] = "001"
  tFigure["fc"]["model"] = "001"
  if getObject(#session).get("user_sex") = "F" then
    tFigure["ch"]["model"] = pSwimSuitModel
  else
    tFigure["ch"]["model"] = pSwimSuitModel
  end if
  if voidp(pSwimSuitColor) then
    pSwimSuitColor = rgb("#EEEEEE")
  end if
  tWndObj = getWindow("uimakoppi")
  tFigure["ch"]["color"] = pSwimSuitColor
  tPartList = ["lh", "bd", "ch", "hd", "fc", "hr", "rh"]
  tHumanImg = image(32, 60, 16)
  tHumanImg = getObject("Figure_Preview").getHumanPartImg(tPartList, tFigure, 2, "sh")
  tImgWidth = tWndObj.getElement("ph_swimsuit.preview.img").getProperty(#width)
  tImgHeight = tWndObj.getElement("ph_swimsuit.preview.img").getProperty(#height)
  tPrewImg = image(tImgWidth, tImgHeight, 16)
  tMargins = rect(-11, 24, -11, 24)
  tdestrect = rect(0, tPrewImg.height - (tHumanImg.height * 4), tHumanImg.width * 4, tPrewImg.height) + tMargins
  tPrewImg.copyPixels(tHumanImg, tdestrect, tHumanImg.rect)
  tPrewImg = me.flipImage(tPrewImg)
  if tWndObj.elementExists("ph_swimsuit.preview.img") then
    tWndObj.getElement("ph_swimsuit.preview.img").feedImage(tPrewImg)
  end if
  if tWndObj.elementExists("ph_swimsuit.preview") then
    tWndObj.getElement("ph_swimsuit.preview").setProperty(#bgColor, pSwimSuitColor)
  end if
end

on getDefaultSwimSuitColor me
  if not objectExists("Figure_System_Pool") then
    return error(me, "Figure system Pool object not found", #getDefaultSwimSuitColor)
  end if
  if getObject(#session).get("user_sex") = "F" then
    tSetID = 20
  else
    tSetID = 10
  end if
  tPartProps = getObject("Figure_System_Pool").getColorOfPartByOrderNum("ch", 1, tSetID, getObject(#session).get("user_sex"))
  if tPartProps.ilk = #propList then
    tColor = rgb(tPartProps["color"])
    pSwimSuitColor = tColor
  end if
end

on changeSwimSuitColor me, tPart, tButtonDir
  if not objectExists("Figure_System_Pool") then
    return error(me, "Figure system Pool object not found", #changeSwimSuitColor)
  end if
  if getObject(#session).get("user_sex") = "F" then
    tSetID = 20
  else
    tSetID = 10
  end if
  tMaxValue = getObject("Figure_System_Pool").getCountOfPartColors(tPart, tSetID, getObject(#session).get("user_sex"))
  if tButtonDir = 0 then
    pSwimSuitIndex = 1
  else
    if (pSwimSuitIndex + tButtonDir) > tMaxValue then
      pSwimSuitIndex = tMaxValue
    else
      if (pSwimSuitIndex + tButtonDir) < 1 then
        pSwimSuitIndex = 1
      else
        pSwimSuitIndex = pSwimSuitIndex + tButtonDir
      end if
    end if
  end if
  if getObject(#session).get("user_sex") = "F" then
    tSetID = 20
  else
    tSetID = 10
  end if
  tPartProps = getObject("Figure_System_Pool").getColorOfPartByOrderNum(tPart, pSwimSuitIndex, tSetID, getObject(#session).get("user_sex"))
  if tPartProps.ilk = #propList then
    tColor = rgb(tPartProps["color"])
    pSwimSuitColor = tColor
  end if
  me.createFigurePrew()
end

on eventProcUimakoppi me, tEvent, tSprID, tParam
  if tEvent = #mouseUp then
    case tSprID of
      "ph_swimsuit_exitbutton":
        me.closeUimaKoppi()
        getConnection(getVariable("connection.room.id")).send("SWIMSUIT")
        getConnection(getVariable("connection.room.id")).send("CLOSE_UIMAKOPPI")
      "ph_swimsuit_gobutton":
        me.closeUimaKoppi()
        tTempDelim = the itemDelimiter
        the itemDelimiter = ","
        tColor = string(pSwimSuitColor)
        tR = value(tColor.item[1].char[5..tColor.item[1].length])
        tG = value(tColor.item[2])
        tB = value(tColor.item[3].char[1..tColor.item[3].length - 1])
        the itemDelimiter = tTempDelim
        tColor = tR & "," & tG & "," & tB
        tswimsuit = "ch=" & pSwimSuitModel & "/" & tColor
        getConnection(getVariable("connection.room.id")).send("SWIMSUIT", tswimsuit)
        getConnection(getVariable("connection.room.id")).send("CLOSE_UIMAKOPPI")
      "ph_swimsuit.left.button":
        me.changeSwimSuitColor("ch", -1)
      "ph_swimsuit.right.button":
        me.changeSwimSuitColor("ch", 1)
    end case
  end if
end

on showRoomBar me, tRoomData
  if not windowExists(pBottomBarId) then
    createWindow(pBottomBarId, "room_pellehyppy_bar.window", 0, 486)
    tWndObj = getWindow(pBottomBarId)
    tWndObj.lock(1)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseDown)
    tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #keyDown)
    tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseWithin)
    tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseUpOutSide)
    executeMessage(#messageUpdateRequest)
    executeMessage(#buddyUpdateRequest)
    if tWndObj.elementExists("int_drop_vote") then
      tWndObj.getElement("int_drop_vote").feedImage(member(getmemnum("pelle_kyltti1")).image)
      pSignState = VOID
      pOldPosH = -1
      pOldPosV = -1
      pSignImg = image(member(getmemnum("pelle_kyltti2")).width, member(getmemnum("pelle_kyltti2")).height, 16)
    end if
    registerMessage(#updateMessageCount, me.getID(), #updateMessageCount)
    registerMessage(#updateBuddyrequestCount, me.getID(), #updateBuddyrequestCount)
    return 1
  end if
  return 0
end

on hideRoomBar me
  unregisterMessage(#updateMessageCount, me.getID())
  unregisterMessage(#updateBuddyrequestCount, me.getID())
  if timeoutExists(#flash_messenger_icon) then
    removeTimeout(#flash_messenger_icon)
  end if
  if windowExists(pBottomBarId) then
    return removeWindow(pBottomBarId)
  end if
  pSignImg = VOID
  return 1
end

on deactivateChatField me
  if not windowExists(pBottomBarId) then
    return 0
  end if
  getWindow(pBottomBarId).getElement("chat_field").setEdit(0)
  return 1
end

on activateChatField me
  if not windowExists(pBottomBarId) then
    return 0
  end if
  getWindow(pBottomBarId).getElement("chat_field").setEdit(1)
  return 1
end

on updateMessageCount me, tMsgCount
  if windowExists(pBottomBarId) then
    pNewMsgCount = value(tMsgCount)
    if pNewMsgCount > 0 then
      me.flashMessengerIcon()
    end if
  end if
  return 1
end

on updateBuddyrequestCount me, tReqCount
  if windowExists(pBottomBarId) then
    pNewBuddyReq = value(tReqCount)
    if pNewBuddyReq > 0 then
      me.flashMessengerIcon()
    end if
  end if
  return 1
end

on flashMessengerIcon me
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return 0
  end if
  if not tWndObj.elementExists("int_messenger_image") then
    return 0
  end if
  if pMessengerFlash then
    tmember = "mes_lite_icon"
    pMessengerFlash = 0
  else
    tmember = "mes_dark_icon"
    pMessengerFlash = 1
  end if
  if (pNewMsgCount = 0) and (pNewBuddyReq = 0) then
    tmember = "mes_dark_icon"
    removeTimeout(#flash_messenger_icon)
  else
    if not timeoutExists(#flash_messenger_icon) then
      createTimeout(#flash_messenger_icon, 500, #flashMessengerIcon, me.getID(), VOID, 0)
    end if
  end if
  tWndObj.getElement("int_messenger_image").getProperty(#sprite).setMember(member(getmemnum(tmember)))
  return 1
end

on eventProcRoomBar me, tEvent, tSprID, tParam
  tWndObj = getWindow(pBottomBarId)
  if tWndObj.getElement(tSprID).getProperty(#blend) < 100 then
    return 0
  end if
  if (tEvent = #keyDown) and (tSprID = "chat_field") then
    tChatField = tWndObj.getElement("chat_field")
    if the commandDown and ((the keyCode = 8) or (the keyCode = 9)) then
      if not getObject(#session).get("user_rights").getOne("fuse_debug_window") then
        tChatField.setText(EMPTY)
        return 1
      end if
    end if
    if the keyCode = 36 then
      if pFloodblocking then
        if the milliSeconds < pFloodTimer then
          return 0
        end if
      else
        pFloodEnterCount = VOID
      end if
      if voidp(pFloodEnterCount) then
        pFloodEnterCount = 0
        pFloodblocking = 0
        pFloodTimer = the milliSeconds
      else
        pFloodEnterCount = pFloodEnterCount + 1
        if pFloodEnterCount > 2 then
          if the milliSeconds < (pFloodTimer + 3000) then
            tChatField.setText(EMPTY)
            createObject("FloodBlocking", "Flood Blocking Class")
            getObject("FloodBlocking").Init(tChatField, 30000)
            pFloodblocking = 1
            pFloodTimer = the milliSeconds + 30000
          else
            pFloodEnterCount = VOID
          end if
        end if
      end if
      getThread(#room).getComponent().sendChat(tChatField.getText())
      tChatField.setText(EMPTY)
      return 1
    else
      if the keyCode = 117 then
        tChatField.setText(EMPTY)
      end if
    end if
    return 0
  end if
  if tEvent = #mouseUp then
    if tWndObj.getElement(tSprID).getProperty(#blend) = 100 then
      case tSprID of
        "int_messenger_image":
          executeMessage(#show_hide_messenger)
        "int_nav_image":
          executeMessage(#show_hide_navigator)
        "int_speechmode_dropmenu":
          getThread(#room).getComponent().setChatMode(tParam)
        "int_purse_image":
          executeMessage(#openGeneralDialog, #purse)
        "int_help_image":
          executeMessage(#openGeneralDialog, #help)
      end case
    end if
  end if
  if tEvent = #mouseDown then
    getWindow(pBottomBarId).lock(0)
    getWindowManager().Activate(pBottomBarId)
    getWindow(pBottomBarId).lock(1)
  end if
  if tSprID = "int_drop_vote" then
    if tEvent = #mouseDown then
      tSignMem = member(getmemnum("pelle_kyltti2"))
      tDropElem = tWndObj.getElement("int_drop_vote")
      tDropElem.getProperty(#buffer).image = tSignMem.image.duplicate()
      tDropElem.getProperty(#buffer).regPoint = point(0, 120)
      tDropElem.setProperty(#height, tSignMem.height)
      pSignState = 1
    else
      if tEvent = #mouseUp then
        tSignMem = member(getmemnum("pelle_kyltti1"))
        tDropElem = tWndObj.getElement("int_drop_vote")
        tDropElem.getProperty(#buffer).image = tSignMem.image.duplicate()
        tDropElem.getProperty(#buffer).regPoint = point(0, 0)
        tDropElem.setProperty(#height, tSignMem.height)
        if voidp(pSignState) or (pOldPosV < 7) then
          tSignMode = (pOldPosH * 7) + (pOldPosV + 1)
          if tSignMode > 14 then
            tSignMode = 14
          else
            if tSignMode < 1 then
              tSignMode = 1
            end if
          end if
          me.getComponent().sendSign(tSignMode)
        end if
        pSignState = VOID
      else
        if tEvent = #mouseUpOutSide then
          tSignMem = member(getmemnum("pelle_kyltti1"))
          tDropElem = tWndObj.getElement("int_drop_vote")
          tDropElem.getProperty(#buffer).image = tSignMem.image.duplicate()
          tDropElem.getProperty(#buffer).regPoint = point(0, 0)
          tDropElem.setProperty(#height, tSignMem.height)
          pSignState = VOID
        else
          if tEvent = #mouseWithin then
            if voidp(pSignState) then
              return 
            end if
            w = 40
            h = 17
            pSignState = 11
            tSignMem = member(getmemnum("pelle_kyltti2"))
            tDropElem = tWndObj.getElement("int_drop_vote")
            tSpr = tDropElem.getProperty(#sprite)
            if (pOldPosH <> ((the mouseH - tSpr.left) / w)) or (pOldPosV <> ((the mouseV - tSpr.top) / h)) then
              if ((the mouseV - tSpr.top) / h) < 7 then
                pOldPosH = (the mouseH - tSpr.left) / w
                pOldPosV = (the mouseV - tSpr.top) / h
                pSignImg.copyPixels(tSignMem.image, pSignImg.rect, pSignImg.rect)
                tSignHiliterImg = member(getmemnum("kyltti_hiliter")).image
                tSignHiliterImg = image(w, h, 16)
                tSignHiliterImg.fill(tSignHiliterImg.rect, rgb(187, 187, 187))
                pSignImg.copyPixels(tSignHiliterImg, tSignHiliterImg.rect + rect((w * pOldPosH) + 1, (h * pOldPosV) + 1, (w * pOldPosH) + 1, (h * pOldPosV) + 1), tSignHiliterImg.rect, [#ink: 39])
              else
                pOldPosH = (the mouseH - tSpr.left) / w
                pOldPosV = (the mouseV - tSpr.top) / h
                pSignImg.copyPixels(tSignMem.image, pSignImg.rect, pSignImg.rect)
              end if
              tDropElem.getProperty(#buffer).image = pSignImg
              tDropElem.getProperty(#buffer).regPoint = point(0, 120)
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
  return tImg_b
end

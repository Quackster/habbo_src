property pWindowID, pmode, pCamMember, pCamShotImage, pDisplaymem, pZoomLevel, pNextHNoiseSetup, pNextVNoiseSetup, pHNoiseCenter, pVNoiseCenter, pDialogId, pHandItemData

on construct me
  pCamMember = member(createMember("__cam_display_mem", #bitmap))
  pWindowID = #photo_camera_window
  pDialogId = #camera_dialog
  return 1
end

on deconstruct me
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  if windowExists(pDialogId) then
    removeWindow(pDialogId)
  end if
  if memberExists("__cam_display_mem") then
    removeMember("__cam_display_mem")
  end if
  removeUpdate(me.getID())
  return 1
end

on open me
  if not createWindow(pWindowID) then
    return 0
  end if
  tWndObj = getWindow(pWindowID)
  tWndObj.merge("photo_camera.window")
  tWndObj.moveTo(100, 100)
  tWndObj.registerProcedure(#eventProcCameraMouseDown, me.getID(), #mouseDown)
  tWndObj.registerProcedure(#eventProcCameraMouseEnter, me.getID(), #mouseEnter)
  tWndObj.registerProcedure(#eventProcCameraMouseLeave, me.getID(), #mouseLeave)
  pmode = #live
  pDisplaymem = tWndObj.getElement("cam_display").getProperty(#buffer)
  me.setCameraToLiveMode()
  me.setButtonHilites()
  me.updateFilm()
  tWndObj.getElement("cam_savetxt").setProperty(#visible, 0)
  getConnection(getVariable("connection.room.id")).send("CARRYITEM", "20")
  registerMessage(#leaveRoom, me.getID(), #close)
  registerMessage(#changeRoom, me.getID(), #close)
  return receiveUpdate(me.getID())
end

on close me
  if connectionExists(getVariable("connection.room.id")) then
    getConnection(getVariable("connection.room.id")).send("STOP", "CarryItem")
  end if
  pmode = #closed
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  if windowExists(pDialogId) then
    removeWindow(pDialogId)
  end if
  removeUpdate(me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  return 1
end

on updateFilm me
  if windowExists(pWindowID) then
    getWindow(pWindowID).getElement("photo_picnumber").setText(me.getComponent().getFilm())
  end if
end

on update me
  if not windowExists(pWindowID) then
    return removeUpdate(me.getID())
  end if
  if pmode = #live then
    tWndObj = getWindow(pWindowID)
    tDispWidth = tWndObj.getElement("cam_display").getProperty(#width)
    tDispHeight = tWndObj.getElement("cam_display").getProperty(#height)
    tDispLocX = tWndObj.getElement("cam_display").getProperty(#locH)
    tDispLocY = tWndObj.getElement("cam_display").getProperty(#locV)
    if (the milliSeconds - pNextHNoiseSetup) > 0 then
      pNextHNoiseSetup = the milliSeconds + random(12000)
      pHNoiseCenter = abs(random(tDispWidth / 2)) + (tDispWidth / 4)
    end if
    if (the milliSeconds - pNextVNoiseSetup) > 0 then
      pNextVNoiseSetup = the milliSeconds + random(12000)
      pVNoiseCenter = abs(random(tDispHeight / 2)) + (tDispHeight / 4)
    end if
    tLocX = tWndObj.getElement("cam_display_noise_vertical").getProperty(#locH)
    tLocY = pHNoiseCenter + (cos((pNextVNoiseSetup - the milliSeconds) / 10000.0 * 2 * PI) * tDispHeight / 4)
    if tLocY > (tDispLocY + tDispHeight) then
      tLocY = tDispLocY + tDispHeight
    end if
    if tLocY < tDispLocY then
      tLocY = tDispLocY
    end if
    tWndObj.getElement("cam_display_noise_vertical").moveTo(tLocX, tLocY)
    tLocX = pVNoiseCenter + (sin((pNextHNoiseSetup - the milliSeconds) / 10000.0 * 2 * PI) * tDispWidth / 4)
    tLocY = tWndObj.getElement("cam_display_noise_horizontal").getProperty(#locV)
    if tLocX > (tDispLocX + tDispWidth) then
      tLocX = tDispLocX + tDispWidth
    end if
    if tLocX < tDispLocX then
      tLocX = tDispLocX
    end if
    tWndObj.getElement("cam_display_noise_horizontal").moveTo(tLocX, tLocY)
  end if
end

on setCameraToLiveMode me
  tWndObj = getWindow(pWindowID)
  tWndObj.getElement("cam_display_noise_horizontal").setProperty(#visible, 1)
  tWndObj.getElement("cam_display_noise_horizontal").setProperty(#blend, 100)
  tWndObj.getElement("cam_display_noise_vertical").setProperty(#visible, 1)
  tWndObj.getElement("cam_display_noise_vertical").setProperty(#blend, 100)
  tWndObj.getElement("cam_display").setProperty(#buffer, pDisplaymem)
  tWndObj.getElement("cam_display").setProperty(#blend, 100)
  tWndObj.getElement("cam_display").setProperty(#ink, 33)
  tWndObj.getElement("cam_display").setProperty(#color, rgb("#000000"))
  tWndObj.getElement("cam_display").setProperty(#bgColor, rgb("#ffffff"))
  return 1
end

on eventProcCameraMouseEnter me, tEvent, tSprID, tParam
  if not getThread(#room).getComponent().roomExists(VOID) then
    return 0
  end if
  me.showHelpLine(tSprID)
end

on eventProcCameraMouseLeave me, tEvent, tSprID, tParam
  if not getThread(#room).getComponent().roomExists(VOID) then
    return 0
  end if
  me.hideHelpLine(tSprID)
end

on eventProcCameraMouseDown me, tEvent, tSprID, tParam
  if not getThread(#room).getComponent().roomExists(VOID) then
    return 0
  end if
  tWndObj = getWindow(pWindowID)
  case tSprID of
    "cam_close":
      me.close()
    "cam_shoot":
      if pmode <> #live then
        return 
      end if
      getConnection(getVariable("connection.room.id")).send("USEITEM", "20" & TAB & "1500")
      pZoomLevel = 1
      tWndObj.getElement("cam_display").setProperty(#visible, 0)
      tWndObj.getElement("cam_display_noise_horizontal").setProperty(#visible, 0)
      tWndObj.getElement("cam_display_noise_vertical").setProperty(#visible, 0)
      getThread(#room).getComponent().getBalloon().hideBalloons()
      tHandVis = getThread(#room).getInterface().getContainer().getVisual()
      if tHandVis <> 0 then
        tHandVis.hide()
      end if
      hideWindows()
      executeMessage(#takingPhoto)
      tWndObj.show()
      updateStage()
      tRect = tWndObj.getElement("cam_display").getProperty(#rect)
      pCamShotImage = image(tRect.right - tRect.left, tRect.bottom - tRect.top, 8, #grayscale)
      pCamShotImage.copyPixels((the stage).image, pCamShotImage.rect, tRect)
      pCamShotImage.draw(pCamShotImage.rect.left, pCamShotImage.rect.top, pCamShotImage.rect.right, pCamShotImage.rect.bottom, [#color: rgb(0, 0, 0), #shapeType: #rect])
      pCamMember.image = pCamShotImage
      pCamMember.regPoint = point(0, 0)
      getThread(#room).getComponent().getBalloon().showBalloons()
      tHandVis = getThread(#room).getInterface().getContainer().getVisual()
      if tHandVis <> 0 then
        tHandVis.show()
      end if
      showWindows()
      executeMessage(#photoTaken)
      tDispElem = tWndObj.getElement("cam_display")
      tDispElem.setProperty(#buffer, pCamMember)
      tDispElem.setProperty(#visible, 1)
      tDispElem.setProperty(#blend, 100)
      tDispElem.setProperty(#color, rgb("681F10"))
      tDispElem.setProperty(#bgColor, rgb("FFCC66"))
      tDispElem.setProperty(#ink, 41)
      updateStage()
      pmode = #still
    "cam_release":
      if pmode = #still then
        me.setCameraToLiveMode()
        pmode = #live
      end if
    "cam_save":
      if (pmode = #still) and (me.getComponent().getFilm() > 0) then
        tWndObj.getElement("cam_display").setProperty(#blend, 50)
        tWndObj.getElement("cam_savetxt").setProperty(#visible, 1)
        tWndObj.getElement("cam_display").setProperty(#buffer, pDisplaymem)
        me.getComponent().storePicture(pCamMember, tWndObj.getElement("photo_text").getText())
        pmode = #save
      else
        beep(1)
      end if
      if (pmode = #still) and (me.getComponent().getFilm() = 0) then
        executeMessage(#alert, [#Msg: "cam_save_nofilm"])
      end if
    "cam_zoom_in":
      if pmode = #still then
        if pZoomLevel < 11 then
          pZoomLevel = pZoomLevel + 1
        end if
        me.zoom()
      else
        beep(1)
      end if
    "cam_zoom_out":
      if pmode = #still then
        pZoomLevel = pZoomLevel - 1
        if pZoomLevel < 1 then
          pZoomLevel = 1
        end if
        me.zoom()
      else
        beep(1)
      end if
  end case
  me.setButtonHilites()
end

on setButtonHilites me
  if not windowExists(pWindowID) then
    return 0
  end if
  case pmode of
    #live:
      me.hilite(["cam_shoot"])
      me.unhilite(["cam_release", "cam_save", "cam_zoom_in", "cam_zoom_out", "cam_txtscreen"])
    #still:
      if me.getComponent().getFilm() > 0 then
        me.hilite(["cam_save", "cam_zoom_in", "cam_zoom_out"])
      end if
      me.unhilite(["cam_shoot"])
      me.hilite(["cam_release", "cam_txtscreen"])
    #save:
      me.unhilite(["cam_shoot", "cam_release", "cam_save", "cam_zoom_in", "cam_zoom_out", "cam_txtscreen"])
  end case
end

on saveOk me
  if not windowExists(pWindowID) then
    return 0
  end if
  pmode = #live
  me.setCameraToLiveMode()
  getWindow(pWindowID).getElement("cam_savetxt").setProperty(#visible, 0)
  me.setButtonHilites()
  me.updateFilm()
  return 1
end

on hilite me, tElements
  tWndObj = getWindow(pWindowID)
  repeat with tid in tElements
    tName = tid & "_hi"
    tWndObj.getElement(tid).setProperty(#buffer, member(getmemnum(tName)))
  end repeat
end

on unhilite me, tElements
  tWndObj = getWindow(pWindowID)
  repeat with tid in tElements
    tName = tid
    tWndObj.getElement(tid).getProperty(#buffer, member(getmemnum(tName)))
  end repeat
end

on zoom me
  tRect = pCamShotImage.rect
  tH = pCamShotImage.height / pZoomLevel
  tW = pCamShotImage.width / pZoomLevel
  tRect.top = (pCamShotImage.height / 2) - (tH / 2)
  tRect.bottom = tRect.top + tH
  tRect.left = (pCamShotImage.width / 2) - (tW / 2)
  tRect.right = tRect.left + tW
  pCamMember.image.copyPixels(pCamShotImage, pCamMember.image.rect, tRect, [#bgColor: rgb(238, 238, 238)])
end

on showHelpLine me, tElemID
  tElement = getWindow(pWindowID).getElement("cam_statusbar")
  case tElemID of
    "cam_shoot":
      tText = getText("cam_shoot.help")
    "cam_release":
      tText = getText("cam_release.help")
    "cam_save":
      tText = getText("cam_save.help")
    "cam_zoom_in":
      tText = getText("cam_zoom_in.help")
    "cam_zoom_out":
      tText = getText("cam_zoom_out.help")
    "cam_txtscreen":
      tText = getText("cam_txtscreen.help")
    "photo_picnumber":
      tText = getText("cam_film.help")
  end case
  if tText <> VOID then
    tElement.setText(tText)
  end if
end

on hideHelpLine me
  getWindow(pWindowID).getElement("cam_statusbar").setText(EMPTY)
end

on handItemSelect me, tdata
  if getThread(#room).getComponent().getRoomID() <> "private" then
    me.open()
  else
    pHandItemData = tdata
    createWindow(pDialogId, "habbo_simple.window", 300, 300)
    tWndObj = getWindow(pDialogId)
    tWndObj.merge("camera_dialog.window")
    tWndObj.registerProcedure(#eventProcDialogMouseUp, me.getID(), #mouseUp)
  end if
end

on eventProcDialogMouseUp me, tEvent, tElemID, tParam
  case tElemID of
    "camera_dialog_open":
      me.open()
      removeWindow(pDialogId)
    "camera_dialog_place":
      removeWindow(pDialogId)
      if threadExists(#room) then
        getThread(#room).getInterface().getContainer().startItemPlacing(pHandItemData)
      end if
  end case
end

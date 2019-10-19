property pWindowID, pDialogId, pMode, pNextHNoiseSetup, pNextVNoiseSetup, pHNoiseCenter, pVNoiseCenter, pDisplaymem, pCamShotImage, pCamMember, pCS, pZoomLevel, pHandItemData

on construct me 
  pCamMember = member(createMember("__cam_display_mem", #bitmap))
  pWindowID = #photo_camera_window
  pDialogId = #camera_dialog
  return(1)
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
  return(1)
end

on open me 
  if not createWindow(pWindowID) then
    return(0)
  end if
  tWndObj = getWindow(pWindowID)
  tWndObj.merge("photo_camera.window")
  tWndObj.moveTo(100, 100)
  tWndObj.registerProcedure(#eventProcCameraMouseDown, me.getID(), #mouseDown)
  tWndObj.registerProcedure(#eventProcCameraMouseEnter, me.getID(), #mouseEnter)
  tWndObj.registerProcedure(#eventProcCameraMouseLeave, me.getID(), #mouseLeave)
  pMode = #live
  pDisplaymem = tWndObj.getElement("cam_display").getProperty(#buffer)
  me.setCameraToLiveMode()
  me.setButtonHilites()
  me.updateFilm()
  tWndObj.getElement("cam_savetxt").setProperty(#visible, 0)
  getConnection(getVariable("connection.room.id")).send(#room, "CarryItem cam")
  registerMessage(#leaveRoom, me.getID(), #close)
  registerMessage(#changeRoom, me.getID(), #close)
  return(receiveUpdate(me.getID()))
end

on close me 
  if connectionExists(getVariable("connection.room.id")) then
    getConnection(getVariable("connection.room.id")).send(#room, "STOP CarryItem")
  end if
  pMode = #closed
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  if windowExists(pDialogId) then
    removeWindow(pDialogId)
  end if
  removeUpdate(me.getID())
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  return(1)
end

on updateFilm me 
  if windowExists(pWindowID) then
    getWindow(pWindowID).getElement("photo_picnumber").setText(me.getComponent().getFilm())
  end if
end

on update me 
  if not windowExists(pWindowID) then
    return(removeUpdate(me.getID()))
  end if
  if pMode = #live then
    tWndObj = getWindow(pWindowID)
    tDispWidth = tWndObj.getElement("cam_display").getProperty(#width)
    tDispHeight = tWndObj.getElement("cam_display").getProperty(#height)
    if the milliSeconds - pNextHNoiseSetup > 0 then
      pNextHNoiseSetup = the milliSeconds + random(12000)
      pHNoiseCenter = abs(random((tDispWidth / 2))) + (tDispWidth / 4)
    end if
    if the milliSeconds - pNextVNoiseSetup > 0 then
      pNextVNoiseSetup = the milliSeconds + random(12000)
      pVNoiseCenter = abs(random((tDispHeight / 2))) + (tDispHeight / 4)
    end if
    tLocX = tWndObj.getElement("cam_display_noise_vertical").getProperty(#locX)
    tLocY = pHNoiseCenter + ((cos((((pNextVNoiseSetup - the milliSeconds / 10000) * 2) * pi())) * tDispHeight) / 4)
    tWndObj.getElement("cam_display_noise_vertical").moveTo(tLocX, tLocY)
    tLocX = pVNoiseCenter + ((sin((((pNextHNoiseSetup - the milliSeconds / 10000) * 2) * pi())) * tDispWidth) / 4)
    tLocY = tWndObj.getElement("cam_display_noise_horizontal").getProperty(#locY)
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
  return(1)
end

on eventProcCameraMouseEnter me, tEvent, tSprID, tParam 
  if not getThread(#room).getComponent().roomExists(void()) then
    return(0)
  end if
  me.showHelpLine(tSprID)
end

on eventProcCameraMouseLeave me, tEvent, tSprID, tParam 
  if not getThread(#room).getComponent().roomExists(void()) then
    return(0)
  end if
  me.hideHelpLine(tSprID)
end

on eventProcCameraMouseDown me, tEvent, tSprID, tParam 
  if not getThread(#room).getComponent().roomExists(void()) then
    return(0)
  end if
  tWndObj = getWindow(pWindowID)
  if tSprID = "cam_close" then
    me.close()
  else
    if tSprID = "cam_shoot" then
      if pMode <> #live then
        return()
      end if
      getConnection(getVariable("connection.room.id")).send(#room, "UseItem cam" & "\t" & "1500")
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
      tWndObj.show()
      updateStage()
      tRect = tWndObj.getElement("cam_display").getProperty(#rect)
      pCamShotImage = image(tRect.right - tRect.left, tRect.bottom - tRect.top, 8, #grayscale)
      pCamShotImage.copyPixels(the stage.image, pCamShotImage.rect, tRect)
      rect.top.draw(pCamShotImage, rect.right, pCamShotImage, rect.bottom, [#color:rgb(0, 0, 0), #shapeType:#rect])
      pCamMember.image = pCamShotImage
      pCamMember.regPoint = point(0, 0)
      pCS = me.getComponent().countCS(pCamMember.image)
      getThread(#room).getComponent().getBalloon().showBalloons()
      tHandVis = getThread(#room).getInterface().getContainer().getVisual()
      if tHandVis <> 0 then
        tHandVis.show()
      end if
      showWindows()
      tDispElem = tWndObj.getElement("cam_display")
      tDispElem.setProperty(#buffer, pCamMember)
      tDispElem.setProperty(#visible, 1)
      tDispElem.setProperty(#blend, 100)
      tDispElem.setProperty(#color, rgb("681F10"))
      tDispElem.setProperty(#bgColor, rgb("FFCC66"))
      tDispElem.setProperty(#ink, 41)
      updateStage()
      pMode = #still
    else
      if tSprID = "cam_release" then
        if pMode = #still then
          me.setCameraToLiveMode()
          pMode = #live
        end if
      else
        if tSprID = "cam_save" then
          if pMode = #still and me.getComponent().getFilm() > 0 then
            tWndObj.getElement("cam_display").setProperty(#blend, 50)
            tWndObj.getElement("cam_savetxt").setProperty(#visible, 1)
            tWndObj.getElement("cam_display").setProperty(#buffer, pDisplaymem)
            me.getComponent().storePicture(pCamMember, tWndObj.getElement("photo_text").getText(), pCS)
            pMode = #save
          else
            beep(1)
          end if
          if pMode = #still and me.getComponent().getFilm() = 0 then
            executeMessage(#alert, [#msg:"cam_save_nofilm"])
          end if
        else
          if tSprID = "cam_zoom_in" then
            if pMode = #still then
              pZoomLevel = pZoomLevel + 1
              me.zoom()
            else
              beep(1)
            end if
          else
            if tSprID = "cam_zoom_out" then
              if pMode = #still then
                pZoomLevel = pZoomLevel - 1
                if pZoomLevel < 1 then
                  pZoomLevel = 1
                end if
                me.zoom()
              else
                beep(1)
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  me.setButtonHilites()
end

on setButtonHilites me 
  if not windowExists(pWindowID) then
    return(0)
  end if
  if pMode = #live then
    me.hilite(["cam_shoot"])
    me.unhilite(["cam_release", "cam_save", "cam_zoom_in", "cam_zoom_out", "cam_txtscreen"])
  else
    if pMode = #still then
      if me.getComponent().getFilm() > 0 then
        me.hilite(["cam_save", "cam_zoom_in", "cam_zoom_out"])
      end if
      me.unhilite(["cam_shoot"])
      me.hilite(["cam_release", "cam_txtscreen"])
    else
      if pMode = #save then
        me.unhilite(["cam_shoot", "cam_release", "cam_save", "cam_zoom_in", "cam_zoom_out", "cam_txtscreen"])
      end if
    end if
  end if
end

on saveOk me 
  if not windowExists(pWindowID) then
    return(0)
  end if
  pMode = #live
  me.setCameraToLiveMode()
  getWindow(pWindowID).getElement("cam_savetxt").setProperty(#visible, 0)
  me.setButtonHilites()
  me.updateFilm()
  return(1)
end

on hilite me, tElements 
  tWndObj = getWindow(pWindowID)
  repeat while tElements <= undefined
    tid = getAt(undefined, tElements)
    tName = tid & "_hi"
    tWndObj.getElement(tid).setProperty(#buffer, member(getmemnum(tName)))
  end repeat
end

on unhilite me, tElements 
  tWndObj = getWindow(pWindowID)
  repeat while tElements <= undefined
    tid = getAt(undefined, tElements)
    tName = tid
    tWndObj.getElement(tid).getProperty(#buffer, member(getmemnum(tName)))
  end repeat
end

on zoom me 
  tRect = pCamShotImage.rect
  tH = (pCamShotImage.height / pZoomLevel)
  tW = (pCamShotImage.width / pZoomLevel)
  tRect.top = (pCamShotImage.height / 2) - (tH / 2)
  tRect.bottom = tRect.top + tH
  tRect.left = (pCamShotImage.width / 2) - (tW / 2)
  tRect.right = tRect.left + tW
  pCamShotImage.copyPixels(pCamMember, image.rect, tRect)
  pCS = me.getComponent().countCS(pCamMember.image)
end

on showHelpLine me, tElemID 
  tElement = getWindow(pWindowID).getElement("cam_statusbar")
  if tElemID = "cam_shoot" then
    tText = getText("cam_shoot.help")
  else
    if tElemID = "cam_release" then
      tText = getText("cam_release.help")
    else
      if tElemID = "cam_save" then
        tText = getText("cam_save.help")
      else
        if tElemID = "cam_zoom_in" then
          tText = getText("cam_zoom_in.help")
        else
          if tElemID = "cam_zoom_out" then
            tText = getText("cam_zoom_out.help")
          else
            if tElemID = "cam_txtscreen" then
              tText = getText("cam_txtscreen.help")
            else
              if tElemID = "photo_picnumber" then
                tText = getText("cam_film.help")
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  if tText <> void() then
    tElement.setText(tText)
  end if
end

on hideHelpLine me 
  getWindow(pWindowID).getElement("cam_statusbar").setText("")
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
  if tElemID = "camera_dialog_open" then
    me.open()
    removeWindow(pDialogId)
  else
    if tElemID = "camera_dialog_place" then
      removeWindow(pDialogId)
      if threadExists(#room) then
        getThread(#room).getInterface().getContainer().startItemPlacing(pHandItemData)
      end if
    end if
  end if
end

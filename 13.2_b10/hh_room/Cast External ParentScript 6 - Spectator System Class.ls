property pSpectatorMode, pVisualizerId, pSpecCountId, pSpecCountTimerId, pWriterBold

on construct me
  pSpectatorMode = 0
  pVisualizerId = "passive_tv_screen"
  pSpecCountId = "spec_count_id"
  pSpecCountTimerId = "spec_count_timer"
  pWriterBold = "dialog_writer_bold"
  tFontBold = getStructVariable("struct.font.bold")
  tFontBold.setaProp(#color, rgb(240, 240, 240))
  createWriter(pWriterBold, tFontBold)
  registerMessage(#leaveRoom, me.getID(), #hideSpectatorView)
  registerMessage(#changeRoom, me.getID(), #hideSpectatorView)
  return 1
end

on deconstruct me
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  if windowExists(pSpecCountId) then
    removeWindow(pSpecCountId)
  end if
  if timeoutExists(pSpecCountTimerId) then
    removeTimeout(pSpecCountTimerId)
  end if
  if writerExists(pWriterBold) then
    removeWriter(pWriterBold)
  end if
  return 1
end

on getSpectatorMode me
  return pSpectatorMode
end

on setSpectatorMode me, tstate, tSpaceType
  if tstate = 1 then
    pSpectatorMode = 1
    me.showSpectatorView()
    me.getSpectatorCount()
    executeMessage(#spectatorMode_on)
  else
    pSpectatorMode = 0
    case tSpaceType of
      #public:
        if getConnection(#info) <> 0 then
          getConnection(#info).send("QUIT")
        end if
        executeMessage(#leaveRoom)
        executeMessage(#spectatorMode_off)
      #private:
      #game:
        executeMessage(#spectatorMode_off)
    end case
  end if
  return 1
end

on updateSpectatorCount me, tSpectatorCount, tSpectatorMax
  createTimeout(pSpecCountTimerId, 15000, #getSpectatorCount, me.getID(), VOID, 1)
  if tSpectatorCount = -1 then
    if windowExists(pSpecCountId) then
      removeWindow(pSpecCountId)
    end if
    return 1
  end if
  tUnmerge = 1
  if not windowExists(pSpecCountId) then
    createWindow(pSpecCountId, "spec_count.window")
    tUnmerge = 0
  end if
  tText = getText("spectator_count")
  tTextImg = getWriter(pWriterBold).render(tText).duplicate()
  tTextWd = tTextImg.width
  tTextHt = tTextImg.height
  tText = replaceChunks(tText, "%cnt%", tSpectatorCount)
  tText = replaceChunks(tText, "%max%", tSpectatorMax)
  tTextImg = getWriter(pWriterBold).render(tText).duplicate()
  tWndObj = getWindow(pSpecCountId)
  if tWndObj = 0 then
    return 0
  end if
  tWndObj.lock(1)
  if tUnmerge then
    tWndObj.unmerge()
  end if
  if not tWndObj.merge("spec_count_2.window") then
    return 0
  end if
  tElem = tWndObj.getElement("spec_count_text")
  if tElem <> 0 then
    tElem.setText(tText)
    tElemWd = tElem.getProperty(#width)
    tWindowWd = tWndObj.getProperty(#width)
    tWindowHt = tWndObj.getProperty(#height)
    tWndObj.resizeTo(tTextWd + (tWindowWd - tElemWd), tWindowHt)
    tElem.resizeTo(tTextWd, tElem.getProperty(#height))
    tElem.moveBy((tTextWd - tTextImg.width) / 2, (tWindowHt - tTextHt) / 2)
    tElem.feedImage(tTextImg)
  end if
  tWndObj.center()
  tWndObj.moveTo(tWndObj.getProperty(#locX), 2)
  return 1
end

on showSpectatorView me
  tRoomInt = getObject(#room_interface)
  if objectp(tRoomInt) then
    tRoomInt.hideInterface(#Remove)
    tInfoStand = tRoomInt.getInfoStandObject()
    if not voidp(tInfoStand) then
      tInfoStand.hideObjectInfo()
      tInfoStand.hideInfoStand()
    end if
    tRoomInt.showRoomBar()
    if tRoomInt.getHiliter() <> 0 then
      removeUpdate(tRoomInt.getHiliter().getID())
      removeObject(tRoomInt.getHiliter().getID())
    end if
  end if
  if visualizerExists(pVisualizerId) then
    return 1
  end if
  createVisualizer(pVisualizerId, "habbo_tv.visual")
  tVisObj = getVisualizer(pVisualizerId)
  tRoomVis = tRoomInt.getRoomVisualizer()
  if tRoomVis = 0 then
    return 0
  end if
  tVisObj.moveZ(getIntVariable("window.default.locz") - 10)
  return 1
end

on hideSpectatorView me
  pSpectatorMode = 0
  if visualizerExists(pVisualizerId) then
    removeVisualizer(pVisualizerId)
  end if
  if windowExists(pSpecCountId) then
    removeWindow(pSpecCountId)
  end if
  if timeoutExists(pSpecCountTimerId) then
    removeTimeout(pSpecCountTimerId)
  end if
  return 1
end

on getSpectatorCount me
  getConnection(getVariable("connection.room.id")).send("GET_SPECTATOR_AMOUNT")
end

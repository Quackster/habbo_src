property pItemList, pTotalCount, pHandVisID, pAnimMode, pAnimLocs, pAnimFrm, pAppendFlag, pHandButtonsWnd, pNextActive, pPrevActive, pDragging, pDragPos, pIconPlaceholderName

on construct me
  pItemList = [:]
  pTotalCount = 0
  pHandVisID = "Hand_visualizer"
  pAnimMode = #close
  pAnimLocs = [[-54, 27], [-42, 21], [-36, 18], [-28, 14], [-22, 11], [-18, 9], [-12, 6], [-10, 5], [-8, 4]]
  pAnimFrm = 1
  pAppendFlag = 0
  pHandButtonsWnd = "habbo_hand_buttons"
  pNextActive = 1
  pPrevActive = 1
  pIconPlaceholderName = "icon_placeholder"
  registerMessage(#roomReady, me.getID(), #checkContainerOnRoomForward)
  registerMessage(#requestContainerOpen, me.getID(), #showContainerItems)
  registerMessage(#furniture_expired, me.getID(), #expireStripItem)
  return 1
end

on deconstruct me
  repeat with i = 1 to 9
    if memberExists("handcontainer_" & i) then
      removeMember("handcontainer_" & i)
    end if
  end repeat
  unregisterMessage(#roomReady, me.getID())
  unregisterMessage(#requestContainerOpen, me.getID())
  unregisterMessage(#furniture_expired, me.getID())
  removeWindow(pHandButtonsWnd)
  removeUpdate(me.getID())
  if visualizerExists(pHandVisID) then
    removeVisualizer(pHandVisID)
  end if
  pItemList = [:]
  pTotalCount = 0
  return 1
end

on open me, tStripInfo
  if tStripInfo then
    if visualizerExists(pHandVisID) then
      return 0
    end if
    if not createVisualizer(pHandVisID, "habbo_hand.visual") then
      return 0
    end if
    tScreenWidth = the stageRight - the stageLeft
    tHandVisualizer = getVisualizer(pHandVisID)
    tHandVisualizer.moveTo(tScreenWidth - 26, -137)
    tHandVisualizer.setProperty(#locZ, -1000)
    tSprList = tHandVisualizer.getProperty(#spriteList)
    call(#registerProcedure, tSprList, #eventProcContainer, me.getID(), #mouseDown)
    call(#registerProcedure, tSprList, #eventProcContainer, me.getID(), #mouseUp)
    call(#registerProcedure, tSprList, #eventProcContainer, me.getID(), #mouseUpOutSide)
    pAnimMode = #open
    pAnimFrm = 1
    receiveUpdate(me.getID())
  else
    tConnection = getThread(#room).getComponent().getRoomConnection()
    if tConnection <> 0 then
      tConnection.send("GETSTRIP", [#integer: 3])
    end if
  end if
  executeMessage(#tutorial_hand_opened)
  return 1
end

on close me
  if not visualizerExists(pHandVisID) then
    return 0
  end if
  pAnimMode = #close
  removeWindow(pHandButtonsWnd)
  receiveUpdate(me.getID())
  return 1
end

on openClose me
  if visualizerExists(pHandVisID) then
    return me.close()
  else
    return me.open()
  end if
end

on isOpen me
  return pAnimMode = #open
end

on checkContainerOnRoomForward me
  tForwardVarId = "forward.open.hand"
  if variableExists(tForwardVarId) then
    if getVariable(tForwardVarId) = 1 then
      me.open()
      setVariable(tForwardVarId, 0)
    end if
  end if
end

on Refresh me
  me.hideContainerItems()
  me.showContainerItems()
  return 1
end

on updateStripItems me, tList
  if pAppendFlag then
    pAppendFlag = 0
  else
    pItemList = [:]
  end if
  repeat with tItem in tList
    me.createStripItem(tItem)
  end repeat
  return 1
end

on appendStripItem me, tdata
  if pItemList.count = 0 then
    pAppendFlag = 1
    tConnection = getThread(#room).getComponent().getRoomConnection()
    if tConnection <> 0 then
      tConnection.send("GETSTRIP", [#integer: 3])
    end if
  end if
  return me.createStripItem(tdata)
end

on createStripItem me, tdata
  tIconClassStr = EMPTY
  case tdata[#striptype] of
    "active":
      if offset("*", tdata[#class]) > 0 then
        tIconClassStr = tdata[#class].char[1..offset("*", tdata[#class]) - 1]
      else
        tIconClassStr = tdata[#class]
      end if
    "item":
      tIconClassStr = EMPTY
      if tdata[#class] = "poster" then
        tIconClassStr = "poster" && tdata[#props]
      else
        if tdata[#class] contains "post.it" then
          tPostnums = integer(value(tdata[#props]) / (20.0 / 6.0))
          if tPostnums > 6 then
            tPostnums = 6
          end if
          if tPostnums < 1 then
            tPostnums = 1
          end if
          tdata[#member] = tdata[#class] & "_" & tPostnums & "_small"
        else
          if tdata[#class] = "wallpaper" then
            tdata[#member] = "wallpaper_small"
          else
            if tdata[#class] = "floor" then
              tdata[#member] = "floor_small"
            else
              if tdata[#class] = "landscape" then
                tdata[#member] = "landscape_small"
              else
                if memberExists(tdata[#class] & "_small") then
                  tIconClassStr = tdata[#class]
                else
                  tIconClassStr = tdata[#class]
                end if
              end if
            end if
          end if
        end if
      end if
    otherwise:
      error(me, "Unknown strip item type:" && tdata[#striptype], #createStripItem, #major)
      tdata[#member] = "room_object_placeholder"
  end case
  if not voidp(tdata[#member]) then
    nothing()
  else
    if memberExists(tdata[#class] & "_small") then
      tdata[#member] = tdata[#class] & "_small"
    else
      if memberExists(tIconClassStr & "_small") then
        tdata[#member] = tIconClassStr & "_small"
      else
        tdata[#member] = pIconPlaceholderName
        tdata[#truemember] = tIconClassStr & "_small"
        tdata[#downloadLocked] = 1
        tDownloadIdName = tIconClassStr
        tDynThread = getThread(#dynamicdownloader)
        if tDynThread = 0 then
          error(me, "Icon member not found and no dynamic download possibility: " & tdata[#member], #createStripItem, #major)
        else
          tDynComponent = tDynThread.getComponent()
          tRoomSizePrefix = EMPTY
          tRoomThread = getThread(#room)
          if tRoomThread <> 0 then
            tTileSize = tRoomThread.getInterface().getGeometry().getTileWidth()
            if tTileSize = 32 then
              tRoomSizePrefix = "s_"
            end if
          end if
          tDownloadIdName = tRoomSizePrefix & tDownloadIdName
          tDynComponent.downloadCastDynamically(tDownloadIdName, tdata[#striptype], me.getID(), #stripItemDownloadCallback, 1)
        end if
      end if
    end if
  end if
  pItemList[tdata[#stripId]] = tdata
  return 1
end

on stripItemDownloadCallback me, tDownloadedClass
  tIconSuffix = "_small"
  tSmallScalePrefix = "s_"
  if chars(tDownloadedClass, 1, tSmallScalePrefix.length) = tSmallScalePrefix then
    tDownloadedClass = chars(tDownloadedClass, tSmallScalePrefix.length + 1, tDownloadedClass.length)
  end if
  repeat with tItem in pItemList
    tTrueMem = tItem[#truemember]
    if not voidp(tTrueMem) then
      if chars(tTrueMem, tTrueMem.length - tIconSuffix.length + 1, tTrueMem.length) = tIconSuffix then
        tTrueMem = chars(tTrueMem, 1, tTrueMem.length - tIconSuffix.length)
      end if
      if tTrueMem = tDownloadedClass then
        tItem[#member] = tItem[#truemember]
        tItem[#downloadLocked] = 0
      end if
    end if
  end repeat
  me.showContainerItems()
end

on removeStripItem me, tID
  return pItemList.deleteProp(tID)
end

on expireStripItem me, tObjID
  tObjID = string(tObjID)
  if not listp(pItemList) then
    return 0
  end if
  tItemList = pItemList.duplicate()
  repeat with tNo = 1 to tItemList.count
    tItem = tItemList[tNo]
    if tItem[#id] = tObjID then
      tCloudEffect = createObject(#random, "Cloud Animation Effect Class")
      if tCloudEffect <> 0 then
        if visualizerExists(pHandVisID) then
          tHand = getVisualizer(pHandVisID)
          tHandSpr = tHand.getSprById("room_hand")
          tLocZOffset = 500
          tCloudEffect.defineWithSprite(tHandSpr, #large, point(-tHandSpr.width / 4, tHandSpr.height), tLocZOffset)
        end if
      end if
      me.removeStripItem(tItem[#stripId])
      me.Refresh()
      exit repeat
    end if
  end repeat
end

on getStripItem me, tID
  if voidp(tID) then
    tID = EMPTY
  end if
  if tID = #list then
    return pItemList
  end if
  if voidp(pItemList[tID]) then
    return 0
  end if
  return pItemList[tID]
end

on stripItemExists me, tID
  return not voidp(pItemList[tID])
end

on setStripItemCount me, tCount
  if integerp(tCount) then
    pTotalCount = tCount
  end if
  if visualizerExists(pHandVisID) then
    if pTotalCount > pItemList.count then
      me.setHandButtonsVisible()
    end if
  end if
  return 1
end

on placeItemToRoom me, tID
  if getThread(#room).getComponent().getRoomID() <> "private" then
    return 0
  end if
  if not me.stripItemExists(tID) then
    return error(me, "Attempted to access unexisting stripitem:" && tID, #placeItemToRoom, #major)
  end if
  tdata = me.getStripItem(tID).duplicate()
  tdata[#x] = 0
  tdata[#y] = 0
  tdata[#h] = 0.0
  if not voidp(tdata[#props]) then
    tdata[#type] = tdata[#props]
  end if
  if tdata[#striptype] = "active" then
    tdata[#props] = [:]
    tdata[#direction] = [0, 0, 0]
    tdata[#altitude] = 100.0
    getThread(#room).getComponent().createActiveObject(tdata)
    if getThread(#room).getComponent().getActiveObject(tdata[#id]) = 0 then
      return 0
    end if
    getThread(#room).getComponent().getActiveObject(tdata[#id]).setaProp(#stripId, tdata[#stripId])
    removeStripItem(me, tID)
    return 1
  else
    if tdata[#striptype] = "item" then
      case tdata[#class] of
        "poster", "post.it", "post.it.vd", "photo":
          if tdata[#class] = "post.it" then
            tdata[#type] = "#ffff33"
          end if
          tdata[#direction] = "leftwall"
          if not getThread(#room).getComponent().createItemObject(tdata) then
            return 0
          end if
          getThread(#room).getComponent().getItemObject(tdata[#id]).setaProp(#stripId, tdata[#stripId])
          if not (tdata[#class] contains "post.it") then
            me.removeStripItem(tID)
          end if
          return 1
        "floor", "wallpaper", "landscape":
          if not threadExists(#room) then
            return error(me, "Room thread not found", #placeItemToRoom, #major)
          end if
          tRoomComp = getThread(#room).getComponent()
          if tdata[#class] = "landscape" then
            tPrivRoomEngine = tRoomComp.getRoomPrg()
            if tPrivRoomEngine.getWallMaskCount() = 0 then
              executeMessage(#alert, [#Msg: getText("landscape_no_windows")])
            end if
          end if
          tRoomComp.getRoomConnection().send("FLATPROPBYITEM", [#integer: integer(tdata[#stripId])])
          removeStripItem(me, tID)
          return 0
        "Chess":
          tdata[#direction] = [0, 0, 0]
          getThread(#room).getComponent().createItemObject(tdata)
          getThread(#room).getComponent().getItemObject(tdata[#id]).setaProp(#stripId, tdata[#stripId])
          removeStripItem(me, tID)
          return 1
        otherwise:
          tdata[#direction] = "leftwall"
          if not getThread(#room).getComponent().createItemObject(tdata) then
            return 0
          end if
          getThread(#room).getComponent().getItemObject(tdata[#id]).setaProp(#stripId, tdata[#stripId])
          me.removeStripItem(tID)
          return 1
      end case
    end if
  end if
end

on getVisual me
  return getVisualizer(pHandVisID)
end

on print me
  repeat with tItem in pItemList
    put tItem
  end repeat
end

on setHandButton me, tButtonID, tActive
  if voidp(tButtonID) then
    return 0
  end if
  case tButtonID of
    "next":
      pNextActive = tActive
    "prev":
      pPrevActive = tActive
    otherwise:
      return 0
  end case
end

on update me
  if not visualizerExists(pHandVisID) then
    return removeUpdate(me.getID())
  end if
  tHand = getVisualizer(pHandVisID)
  tLocModX = pAnimLocs[pAnimFrm][1]
  tLocModY = pAnimLocs[pAnimFrm][2]
  if pAnimMode = #open then
    pAnimFrm = pAnimFrm + 1
    tHand.moveBy(tLocModX, tLocModY)
    if pAnimFrm > pAnimLocs.count then
      pAnimFrm = pAnimLocs.count
    end if
    if pAnimFrm = 4 then
      tHand.getSprById("room_hand").setMember(member(getmemnum("room_hand_2")))
      tHand.getSprById("room_hand_mask").blend = 100
    else
      if pAnimFrm = 6 then
        me.showContainerItems()
        tHand.getSprById("room_hand").setMember(member(getmemnum("room_hand_3")))
        tHand.getSprById("room_hand_mask").visible = 0
      end if
    end if
    if pAnimFrm = pAnimLocs.count then
      if pTotalCount > pItemList.count then
        me.setHandButtonsVisible()
      end if
      removeUpdate(me.getID())
    end if
  else
    pAnimFrm = pAnimFrm - 1
    if pAnimFrm < 1 then
      pAnimFrm = 1
    end if
    tHand.moveBy(-tLocModX, -tLocModY)
    if pAnimFrm = 4 then
      tHand.getSprById("room_hand").setMember(member(getmemnum("room_hand_1")))
      tHand.getSprById("room_hand_mask").visible = 0
      me.hideContainerItems()
    else
      if pAnimFrm = 6 then
        tHand.getSprById("room_hand").setMember(member(getmemnum("room_hand_2")))
        tHand.getSprById("room_hand_mask").visible = 1
      end if
    end if
    if pAnimFrm = 1 then
      removeVisualizer(pHandVisID)
      removeUpdate(me.getID())
    end if
  end if
end

on showContainerItems me
  if pAnimMode = #close then
    return 0
  end if
  if not visualizerExists(pHandVisID) then
    return 0
  end if
  tHand = getVisualizer(pHandVisID)
  tList = me.getStripItem(#list)
  tCount = tList.count
  tAddRecyclerTags = 0
  tRecyclerThread = getThread(#recycler)
  if not (tRecyclerThread = 0) and memberExists("recycler_icon_tag") then
    if tRecyclerThread.getComponent().isRecyclerOpenAndVisible() then
      tAddRecyclerTags = 1
    end if
  end if
  repeat with i = 1 to 9
    if getmemnum("handcontainer_" & i) < 1 then
      createMember("handcontainer_" & i, #bitmap)
    end if
    tMem = getmemnum("handcontainer_" & i)
    tVisible = 1
    if i <= tCount then
      tItem = tList[i]
      tPreviewImage = getObject("Preview_renderer").renderPreviewImage(tItem[#member], VOID, tItem[#colors], tItem[#class])
      tTempImage = image(tPreviewImage.width, tPreviewImage.height, 32)
      tTempImage.copyPixels(tPreviewImage, tPreviewImage.rect, tPreviewImage.rect)
      if voidp(tPreviewImage) then
        error(me, "Preview image was void!", #showContainerItems, #major)
        return 0
      end if
      if tAddRecyclerTags and (integer(tItem[#isRecyclable]) = 1) then
        tRecyclableTagImg = getMember("recycler_icon_tag").image
        tRect = tRecyclableTagImg.rect
        tTempImage.copyPixels(tRecyclableTagImg, tRect, tRect, [#ink: 36])
      end if
      member(tMem).image = tTempImage
      tInTrade = getThread(#room).getInterface().getSafeTrader().isUnderTrade(pItemList.getPropAt(i))
      tInRecycler = getThread(#recycler).getComponent().isFurniInRecycler(pItemList.getPropAt(i))
      tVisible = not (tInTrade or tInRecycler)
      if tVisible then
        if not (tItem[#class] contains "post.it") then
          tVisible = not (getThread(#room).getInterface().getObjectMover().pClientID = pItemList.getPropAt(i))
        end if
      end if
    else
      tMem = member(getmemnum("room_object_placeholder_sd"))
      tVisible = 0
    end if
    tSpr = tHand.getSprById("room_hand_item_" & i)
    if not voidp(tSpr) then
      tSpr.setMember(tMem)
      tSpr.blend = 100
      tSpr.visible = tVisible
      tSpr.ink = 8
    end if
  end repeat
  me.setHandButtonsVisible()
  return 1
end

on hideContainerItems me
  if not visualizerExists(pHandVisID) then
    return 0
  end if
  tHand = getVisualizer(pHandVisID)
  repeat with i = 1 to 9
    tSpr = tHand.getSprById("room_hand_item_" & i)
    if not voidp(tSpr) then
      tSpr.setMember(member(getmemnum("room_object_placeholder_sd")))
      tSpr.visible = 0
    end if
  end repeat
  return 1
end

on eventProcContainer me, tEvent, tSprID, tParam
  if tEvent <> #mouseUp then
    return 0
  end if
  case getThread(#room).getInterface().getProperty(#clickAction) of
    "placeActive", "placeItem":
      getThread(#room).getInterface().stopObjectMover()
      return getThread(#room).getComponent().getRoomConnection().send("GETSTRIP", [#integer: 4])
    "moveActive", "moveItem":
      if not getObject(#session).GET("room_owner") then
        return 0
      end if
      ttype = ["active": 2, "item": 1][getThread(#room).getInterface().pSelectedType]
      tObj = getThread(#room).getInterface().pSelectedObj
      getThread(#room).getInterface().stopObjectMover()
      return getThread(#room).getComponent().getRoomConnection().send("ADDSTRIPITEM", [#integer: ttype, #integer: integer(tObj)])
  end case
  if tSprID contains "room_hand_item" then
    tItemNum = integer(tSprID.char[16])
    tStripList = me.getStripItem(#list)
    if tItemNum > tStripList.count then
      return error(me, "Attempted to place unexisting strip item!", #eventProcContainer, #major)
    end if
    tdata = tStripList[tItemNum]
    tItemID = tdata[#stripId]
    if tdata[#downloadLocked] then
      return 0
    end if
    if getThread(#room).getInterface().getSafeTrader().isUnderTrade(tItemID) then
      return 0
    end if
    if variableExists("handitem." & tdata[#class] & ".select_handler") then
      tSpecialHandler = symbol(getVariable("handitem." & tdata[#class] & ".select_handler"))
      if objectExists(tSpecialHandler) then
        call(#handItemSelect, getObject(tSpecialHandler), tdata)
        return 
      end if
    end if
    if me.placeItemToRoom(tItemID) then
      me.setItemPlacingMode(tdata)
    else
      getThread(#room).getInterface().pSelectedObj = EMPTY
      getThread(#room).getInterface().pSelectedType = EMPTY
      getThread(#room).getInterface().setProperty(#clickAction, "moveHuman")
    end if
    me.Refresh()
  end if
end

on startItemPlacing me, tdata
  if me.placeItemToRoom(tdata[#stripId]) then
    me.setItemPlacingMode(tdata)
    me.Refresh()
  end if
end

on setItemPlacingMode me, tdata
  tRoomInterface = getThread(#room).getInterface()
  tRoomInterface.pSelectedObj = tdata[#id]
  tRoomInterface.pSelectedType = tdata[#striptype]
  if tdata[#striptype] = "active" then
    tRoomInterface.startObjectMover(tdata[#id], tdata[#stripId], tdata)
    tRoomInterface.setProperty(#clickAction, "placeActive")
  else
    if tdata[#striptype] = "item" then
      tRoomInterface.startObjectMover(tdata[#id], tdata[#stripId], tdata)
      tRoomInterface.setProperty(#clickAction, "placeItem")
    end if
  end if
end

on setHandButtonsVisible me, tVisible
  if voidp(tVisible) then
    tVisible = 1
  end if
  if not windowExists(pHandButtonsWnd) then
    if not createWindow(pHandButtonsWnd, "habbo_hand_buttons.window") then
      return 0
    end if
    tWndObj = getWindow(pHandButtonsWnd)
    if tWndObj = 0 then
      return 0
    end if
    tWndObj.moveZ(-999)
    tWndObj.lock()
    tElem1 = tWndObj.getElement("habbo_hand_next")
    if tElem1 = 0 then
      return 0
    end if
    tElem2 = tWndObj.getElement("habbo_hand_close")
    if tElem2 = 0 then
      return 0
    end if
    tElem3 = tWndObj.getElement("habbo_hand_prev")
    if tElem3 = 0 then
      return 0
    end if
    tLocX3 = tElem3.getProperty(#locX)
    tcenter = tLocX3 + ((tElem1.getProperty(#locX) + tElem1.getProperty(#width) - tLocX3) / 2)
    tElem2.moveTo(tcenter - (tElem2.getProperty(#width) / 2), tElem2.getProperty(#locY))
  end if
  tWndObj = getWindow(pHandButtonsWnd)
  if not tWndObj.elementExists("habbo_hand_next") or not tWndObj.elementExists("habbo_hand_next") then
    return 0
  end if
  if tVisible then
    tWndObj.setProperty(#visible, 1)
    tStageRight = the stageRight - the stageLeft
    tTopOffset = 5
    tWndObj.moveTo(tStageRight - tWndObj.getProperty(#width) - 5, tTopOffset)
    if pNextActive then
      tWndObj.getElement("habbo_hand_next").Activate()
    else
      tWndObj.getElement("habbo_hand_next").deactivate()
    end if
    if pPrevActive then
      tWndObj.getElement("habbo_hand_prev").Activate()
    else
      tWndObj.getElement("habbo_hand_prev").deactivate()
    end if
    tWndObj.registerProcedure(#eventProcHandButtons, me.getID())
  else
    tWndObj.setProperty(#visible, 0)
  end if
end

on eventProcHandButtons me, tEvent, tSprID, tParam
  if tEvent <> #mouseUp then
    return 0
  end if
  case tSprID of
    "habbo_hand_next":
      getThread(#room).getComponent().getRoomConnection().send("GETSTRIP", [#integer: 1])
    "habbo_hand_prev":
      getThread(#room).getComponent().getRoomConnection().send("GETSTRIP", [#integer: 2])
    "habbo_hand_close":
      me.close()
    otherwise:
      return 0
  end case
end

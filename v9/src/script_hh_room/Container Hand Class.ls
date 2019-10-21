property pHandButtonsWnd, pHandVisID, pAppendFlag, pItemList, pTotalCount, pAnimLocs, pAnimFrm, pAnimMode, pNextActive, pPrevActive

on construct me 
  pItemList = [:]
  pTotalCount = 0
  pHandVisID = "Hand_visualizer"
  pAnimMode = #open
  pAnimLocs = [[-54, 27], [-42, 21], [-36, 18], [-28, 14], [-22, 11], [-18, 9], [-12, 6], [-10, 5], [-8, 4]]
  pAnimFrm = 1
  pAppendFlag = 0
  pHandButtonsWnd = "habbo_hand_buttons"
  pNextActive = 1
  pPrevActive = 1
  return TRUE
end

on deconstruct me 
  i = 1
  repeat while i <= 9
    if memberExists("handcontainer_" & i) then
      removeMember("handcontainer_" & i)
    end if
    i = (1 + i)
  end repeat
  removeWindow(pHandButtonsWnd)
  removeUpdate(me.getID())
  if visualizerExists(pHandVisID) then
    removeVisualizer(pHandVisID)
  end if
  pItemList = [:]
  pTotalCount = 0
  return TRUE
end

on open me, tStripInfo 
  if tStripInfo then
    if visualizerExists(pHandVisID) then
      return FALSE
    end if
    if not createVisualizer(pHandVisID, "habbo_hand.visual") then
      return FALSE
    end if
    tHandVisualizer = getVisualizer(pHandVisID)
    tHandVisualizer.moveTo(694, -137)
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
      tConnection.send("GETSTRIP", "new")
    end if
  end if
  return TRUE
end

on close me 
  if not visualizerExists(pHandVisID) then
    return FALSE
  end if
  pAnimMode = #close
  removeWindow(pHandButtonsWnd)
  receiveUpdate(me.getID())
  return TRUE
end

on openClose me 
  if visualizerExists(pHandVisID) then
    return(me.close())
  else
    return(me.open())
  end if
end

on Refresh me 
  me.hideContainerItems()
  me.showContainerItems()
  return TRUE
end

on updateStripItems me, tList 
  if pAppendFlag then
    pAppendFlag = 0
  else
    pItemList = [:]
  end if
  repeat while tList <= undefined
    tItem = getAt(undefined, tList)
    me.createStripItem(tItem)
  end repeat
  return TRUE
end

on appendStripItem me, tdata 
  if (pItemList.count = 0) then
    pAppendFlag = 1
    tConnection = getThread(#room).getComponent().getRoomConnection()
    if tConnection <> 0 then
      tConnection.send("GETSTRIP", "new")
    end if
  end if
  return(me.createStripItem(tdata))
end

on createStripItem me, tdata 
  if (tdata.getAt(#striptype) = "active") then
    if memberExists(tdata.getAt(#class) & "_small") then
      tdata.setAt(#member, tdata.getAt(#class) & "_small")
    else
      if offset("*", tdata.getAt(#class)) > 0 then
        tClass = tdata.getAt(#class).getProp(#char, 1, (offset("*", tdata.getAt(#class)) - 1))
        tdata.setAt(#member, tClass & "_small")
      else
        tClass = tdata.getAt(#class)
        error(me, "Member not found:" && tClass & "_small", #createStripItem)
        tdata.setAt(#member, "room_object_placeholder")
      end if
    end if
  else
    if (tdata.getAt(#striptype) = "item") then
      if (tdata.getAt(#class) = "poster") then
        tdata.setAt(#member, "poster" && tdata.getAt(#props) & "_small")
      else
        if tdata.getAt(#class) contains "post.it" then
          tPostnums = integer((value(tdata.getAt(#props)) / (20 / 6)))
          if tPostnums > 6 then
            tPostnums = 6
          end if
          if tPostnums < 1 then
            tPostnums = 1
          end if
          tdata.setAt(#member, tdata.getAt(#class) & "_" & tPostnums & "_small")
        else
          if (tdata.getAt(#class) = "wallpaper") then
            tdata.setAt(#member, "wallpaper_small")
          else
            if (tdata.getAt(#class) = "floor") then
              tdata.setAt(#member, "floor_small")
            else
              if memberExists(tdata.getAt(#class) & "_small") then
                tdata.setAt(#member, tClass & "_small")
              else
                error(me, "Unknown item type:" && tdata.getAt(#class), #createStripItem)
                tdata.setAt(#member, "room_object_placeholder")
              end if
            end if
          end if
        end if
      end if
    else
      error(me, "Unknown strip item type:" && tdata.getAt(#striptype), #createStripItem)
      tdata.setAt(#member, "room_object_placeholder")
    end if
  end if
  pItemList.setAt(tdata.getAt(#stripId), tdata)
  return TRUE
end

on removeStripItem me, tid 
  return(pItemList.deleteProp(tid))
end

on getStripItem me, tid 
  if voidp(tid) then
    tid = ""
  end if
  if (tid = #list) then
    return(pItemList)
  end if
  if voidp(pItemList.getAt(tid)) then
    return FALSE
  end if
  return(pItemList.getAt(tid))
end

on stripItemExists me, tid 
  return(not voidp(pItemList.getAt(tid)))
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
  return TRUE
end

on placeItemToRoom me, tid 
  if getThread(#room).getComponent().getRoomID() <> "private" then
    return FALSE
  end if
  if not me.stripItemExists(tid) then
    return(error(me, "Attempted to access unexisting stripitem:" && tid, #placeItemToRoom))
  end if
  tdata = me.getStripItem(tid).duplicate()
  tdata.setAt(#x, 0)
  tdata.setAt(#y, 0)
  tdata.setAt(#h, 0)
  if not voidp(tdata.getAt(#props)) then
    tdata.setAt(#type, tdata.getAt(#props))
  end if
  if (tdata.getAt(#striptype) = "active") then
    tdata.setAt(#props, [:])
    tdata.setAt(#direction, [0, 0, 0])
    tdata.setAt(#altitude, 100)
    getThread(#room).getComponent().createActiveObject(tdata)
    if (getThread(#room).getComponent().getActiveObject(tdata.getAt(#id)) = 0) then
      return FALSE
    end if
    getThread(#room).getComponent().getActiveObject(tdata.getAt(#id)).setaProp(#stripId, tdata.getAt(#stripId))
    removeStripItem(me, tid)
    return TRUE
  else
    if (tdata.getAt(#striptype) = "item") then
      if tdata.getAt(#class) <> "poster" then
        if tdata.getAt(#class) <> "post.it" then
          if tdata.getAt(#class) <> "post.it.vd" then
            if (tdata.getAt(#class) = "photo") then
              if (tdata.getAt(#class) = "post.it") then
                tdata.setAt(#type, "#ffff33")
              end if
              tdata.setAt(#direction, "leftwall")
              getThread(#room).getComponent().createItemObject(tdata)
              getThread(#room).getComponent().getItemObject(tdata.getAt(#id)).setaProp(#stripId, tdata.getAt(#stripId))
              if not tdata.getAt(#class) contains "post.it" then
                me.removeStripItem(tid)
              end if
              return TRUE
            else
              if tdata.getAt(#class) <> "floor" then
                if (tdata.getAt(#class) = "wallpaper") then
                  getThread(#room).getComponent().getRoomConnection().send("FLATPROPBYITEM", tdata.getAt(#class) & "/" & tdata.getAt(#stripId))
                  removeStripItem(me, tid)
                  return FALSE
                else
                  if (tdata.getAt(#class) = "Chess") then
                    tdata.setAt(#direction, [0, 0, 0])
                    getThread(#room).getComponent().createItemObject(tdata)
                    getThread(#room).getComponent().getItemObject(tdata.getAt(#id)).setaProp(#stripId, tdata.getAt(#stripId))
                    removeStripItem(me, tid)
                    return TRUE
                  else
                    return(error(me, "Unknown item class:" && tdata.getAt(#class), #placeItemToRoom))
                    removeStripItem(me, tid)
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
end

on getVisual me 
  return(getVisualizer(pHandVisID))
end

on print me 
  repeat while pItemList <= undefined
    tItem = getAt(undefined, undefined)
    put(tItem)
  end repeat
end

on setHandButton me, tButtonID, tActive 
  if voidp(tButtonID) then
    return FALSE
  end if
  if (tButtonID = "next") then
    pNextActive = tActive
  else
    if (tButtonID = "prev") then
      pPrevActive = tActive
    else
      return FALSE
    end if
  end if
end

on update me 
  if not visualizerExists(pHandVisID) then
    return(removeUpdate(me.getID()))
  end if
  tHand = getVisualizer(pHandVisID)
  tLocModX = pAnimLocs.getAt(pAnimFrm).getAt(1)
  tLocModY = pAnimLocs.getAt(pAnimFrm).getAt(2)
  if (pAnimMode = #open) then
    pAnimFrm = (pAnimFrm + 1)
    tHand.moveBy(tLocModX, tLocModY)
    if pAnimFrm > pAnimLocs.count then
      pAnimFrm = pAnimLocs.count
    end if
    if (pAnimFrm = 4) then
      tHand.getSprById("room_hand").setMember(member(getmemnum("room_hand_2")))
      tHand.getSprById("room_hand_mask").blend = 100
    else
      if (pAnimFrm = 6) then
        me.showContainerItems()
        tHand.getSprById("room_hand").setMember(member(getmemnum("room_hand_3")))
        tHand.getSprById("room_hand_mask").visible = 0
      end if
    end if
    if (pAnimFrm = pAnimLocs.count) then
      if pTotalCount > pItemList.count then
        me.setHandButtonsVisible()
      end if
      removeUpdate(me.getID())
    end if
  else
    pAnimFrm = (pAnimFrm - 1)
    if pAnimFrm < 1 then
      pAnimFrm = 1
    end if
    tHand.moveBy(-tLocModX, -tLocModY)
    if (pAnimFrm = 4) then
      tHand.getSprById("room_hand").setMember(member(getmemnum("room_hand_1")))
      tHand.getSprById("room_hand_mask").visible = 0
      me.hideContainerItems()
    else
      if (pAnimFrm = 6) then
        tHand.getSprById("room_hand").setMember(member(getmemnum("room_hand_2")))
        tHand.getSprById("room_hand_mask").visible = 1
      end if
    end if
    if (pAnimFrm = 1) then
      removeVisualizer(pHandVisID)
      removeUpdate(me.getID())
    end if
  end if
end

on showContainerItems me 
  if not visualizerExists(pHandVisID) then
    return FALSE
  end if
  tHand = getVisualizer(pHandVisID)
  tList = me.getStripItem(#list)
  tCount = tList.count
  i = 1
  repeat while i <= 9
    if getmemnum("handcontainer_" & i) < 1 then
      createMember("handcontainer_" & i, #bitmap)
    end if
    tMem = getmemnum("handcontainer_" & i)
    tVisible = 1
    if i <= tCount then
      tItem = tList.getAt(i)
      tImage = getObject("Preview_renderer").renderPreviewImage(tItem.getAt(#member), void(), tItem.getAt(#colors), tItem.getAt(#class))
      member(tMem).image = tImage
      tVisible = not getThread(#room).getInterface().getSafeTrader().isUnderTrade(pItemList.getPropAt(i))
      if tVisible then
        if not tItem.getAt(#class) contains "post.it" then
          tVisible = not (getThread(#room).getInterface().getObjectMover().pClientID = pItemList.getPropAt(i))
        end if
      end if
    else
      tMem = member(getmemnum("room_object_placeholder_sd"))
      tVisible = 0
    end if
    tSpr = tHand.getSprById("room_hand_item_" & i)
    tSpr.setMember(tMem)
    tSpr.blend = 100
    tSpr.visible = tVisible
    tSpr.ink = 8
    i = (1 + i)
  end repeat
  me.setHandButtonsVisible()
  return TRUE
end

on hideContainerItems me 
  if not visualizerExists(pHandVisID) then
    return FALSE
  end if
  tHand = getVisualizer(pHandVisID)
  i = 1
  repeat while i <= 9
    tSpr = tHand.getSprById("room_hand_item_" & i)
    tSpr.setMember(member(getmemnum("room_object_placeholder_sd")))
    tSpr.visible = 0
    i = (1 + i)
  end repeat
  return TRUE
end

on eventProcContainer me, tEvent, tSprID, tParam 
  if tEvent <> #mouseUp then
    return FALSE
  end if
  if getThread(#room).getInterface().getProperty(#clickAction) <> "placeActive" then
    if (getThread(#room).getInterface().getProperty(#clickAction) = "placeItem") then
      getThread(#room).getInterface().stopObjectMover()
      return(getThread(#room).getComponent().getRoomConnection().send("GETSTRIP", "update"))
    else
      if getThread(#room).getInterface().getProperty(#clickAction) <> "moveActive" then
        if (getThread(#room).getInterface().getProperty(#clickAction) = "moveItem") then
          if not getObject(#session).get("room_owner") then
            return FALSE
          end if
          ttype = ["active":"stuff", "item":"item"].getAt(getThread(#room).getInterface().pSelectedType)
          tObj = getThread(#room).getInterface().pSelectedObj
          getThread(#room).getInterface().stopObjectMover()
          return(getThread(#room).getComponent().getRoomConnection().send("ADDSTRIPITEM", "new" && ttype && tObj))
        end if
        if tSprID contains "room_hand_item" then
          tItemNum = integer(tSprID.getProp(#char, 16))
          tStripList = me.getStripItem(#list)
          if tItemNum > tStripList.count then
            return(error(me, "Attempted to place unexisting strip item!", #eventProcContainer))
          end if
          tdata = tStripList.getAt(tItemNum)
          tItemID = tdata.getAt(#stripId)
          if getThread(#room).getInterface().getSafeTrader().isUnderTrade(tItemID) then
            return FALSE
          end if
          if variableExists("handitem." & tdata.getAt(#class) & ".select_handler") then
            tSpecialHandler = symbol(getVariable("handitem." & tdata.getAt(#class) & ".select_handler"))
            if objectExists(tSpecialHandler) then
              call(#handItemSelect, getObject(tSpecialHandler), tdata)
              return()
            end if
          end if
          if me.placeItemToRoom(tItemID) then
            me.setItemPlacingMode(tdata)
          else
            getThread(#room).getInterface().pSelectedObj = ""
            getThread(#room).getInterface().pSelectedType = ""
            getThread(#room).getInterface().setProperty(#clickAction, "moveHuman")
          end if
          me.Refresh()
        end if
      end if
    end if
  end if
end

on startItemPlacing me, tdata 
  if me.placeItemToRoom(tdata.getAt(#stripId)) then
    me.setItemPlacingMode(tdata)
    me.Refresh()
  end if
end

on setItemPlacingMode me, tdata 
  tRoomInterface = getThread(#room).getInterface()
  tRoomInterface.pSelectedObj = tdata.getAt(#id)
  tRoomInterface.pSelectedType = tdata.getAt(#striptype)
  if (tdata.getAt(#striptype) = "active") then
    tRoomInterface.startObjectMover(tdata.getAt(#id), tdata.getAt(#stripId))
    tRoomInterface.setProperty(#clickAction, "placeActive")
  else
    if (tdata.getAt(#striptype) = "item") then
      tRoomInterface.startObjectMover(tdata.getAt(#id), tdata.getAt(#stripId))
      tRoomInterface.setProperty(#clickAction, "placeItem")
    end if
  end if
end

on setHandButtonsVisible me 
  if not windowExists(pHandButtonsWnd) then
    if not createWindow(pHandButtonsWnd, "habbo_hand_buttons.window") then
      return FALSE
    end if
  end if
  tWndObj = getWindow(pHandButtonsWnd)
  tStageRight = (the stageRight - the stageLeft)
  tTopOffset = 5
  tWndObj.moveTo(((tStageRight - tWndObj.getProperty(#width)) - 5), tTopOffset)
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
end

on eventProcHandButtons me, tEvent, tSprID, tParam 
  if tEvent <> #mouseUp then
    return FALSE
  end if
  if (tSprID = "habbo_hand_next") then
    getThread(#room).getComponent().getRoomConnection().send("GETSTRIP", "next")
  else
    if (tSprID = "habbo_hand_prev") then
      getThread(#room).getComponent().getRoomConnection().send("GETSTRIP", "prev")
    else
      if (tSprID = "habbo_hand_close") then
        me.close()
      else
        return FALSE
      end if
    end if
  end if
end

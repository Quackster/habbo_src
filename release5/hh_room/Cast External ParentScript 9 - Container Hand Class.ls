property pItemList, pTotalCount, pHandVisID, pAnimMode, pAnimLocs, pAnimFrm, pAppendFlag

on construct me
  pItemList = [:]
  pTotalCount = 0
  pHandVisID = "Hand_visualizer"
  pAnimMode = #open
  pAnimLocs = [[-54, 27], [-42, 21], [-36, 18], [-28, 14], [-22, 11], [-18, 9], [-12, 6], [-10, 5], [-8, 4]]
  pAnimFrm = 1
  pAppendFlag = 0
  return 1
end

on deconstruct me
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
    createVisualizer(pHandVisID, "habbo_hand.visual")
    tHandVisualizer = getVisualizer(pHandVisID)
    tHandVisualizer.moveTo(694, -137)
    tHandVisualizer.setProperty(#locZ, -1000)
    tHandVisualizer.getSprById("room_hand_next").visible = 0
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
      tConnection.send(#room, "GETSTRIP new")
    end if
  end if
  return 1
end

on close me
  if not visualizerExists(pHandVisID) then
    return 0
  end if
  getVisualizer(pHandVisID).getSprById("room_hand_next").visible = 0
  pAnimMode = #close
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

on refresh me
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
      tConnection.send(#room, "GETSTRIP new")
    end if
  end if
  return me.createStripItem(tdata)
end

on createStripItem me, tdata
  case tdata[#striptype] of
    "active":
      if memberExists(tdata[#class] & "_small") then
        tdata[#member] = tdata[#class] & "_small"
      else
        if offset("*", tdata[#class]) > 0 then
          tClass = tdata[#class].char[1..offset("*", tdata[#class]) - 1]
          tdata[#class] = tClass
          tdata[#member] = tClass & "_small"
        else
          tClass = tdata[#class]
          error(me, "Member not found:" && tClass & "_small", #createStripItem)
          tdata[#member] = "room_object_placeholder"
        end if
      end if
    "item":
      if tdata[#class] = "poster" then
        tdata[#member] = "poster" && tdata[#props] & "_small"
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
              if memberExists(tdata[#class] & "_small") then
                tdata[#member] = tdata[#class] & "_small"
              else
                error(me, "Unknown item type:" && tdata[#class], #createStripItem)
                tdata[#member] = "room_object_placeholder"
              end if
            end if
          end if
        end if
      end if
    otherwise:
      error(me, "Unknown strip item type:" && tdata[#striptype], #createStripItem)
      tdata[#member] = "room_object_placeholder"
  end case
  if memberExists(tdata[#class] & "_small_sd") then
    tdata[#shadow] = tdata[#class] & "_small_sd"
  else
    tdata[#shadow] = "room_object_placeholder_sd"
  end if
  pItemList[tdata[#stripId]] = tdata
  return 1
end

on removeStripItem me, tid
  return pItemList.deleteProp(tid)
end

on getStripItem me, tid
  if voidp(tid) then
    tid = EMPTY
  end if
  if tid = #list then
    return pItemList
  end if
  if voidp(pItemList[tid]) then
    return 0
  end if
  return pItemList[tid]
end

on stripItemExists me, tid
  return not voidp(pItemList[tid])
end

on setStripItemCount me, tCount
  if integerp(tCount) then
    pTotalCount = tCount
  end if
  if visualizerExists(pHandVisID) then
    if pTotalCount > pItemList.count then
      getVisualizer(pHandVisID).getSprById("room_hand_next").visible = 1
    end if
  end if
  return 1
end

on placeItemToRoom me, tid
  if getThread(#room).getComponent().getRoomID() <> "private" then
    return 0
  end if
  if not me.stripItemExists(tid) then
    return error(me, "Attempted to access unexisting stripitem:" && tid, #placeItemToRoom)
  end if
  tdata = me.getStripItem(tid).duplicate()
  tdata[#x] = 0
  tdata[#y] = 0
  tdata[#h] = 0.0
  if not voidp(tdata[#props]) then
    tdata[#type] = tdata[#props]
  end if
  if tdata[#striptype] = "active" then
    tdata[#props] = [:]
    tdata[#direction] = [0, 0, 0]
    tdata[#altitude] = 0.0
    getThread(#room).getComponent().createActiveObject(tdata)
    getThread(#room).getComponent().getActiveObject(tdata[#id]).setaProp(#stripId, tdata[#stripId])
    removeStripItem(me, tid)
    return 1
  else
    if tdata[#striptype] = "item" then
      case tdata[#class] of
        "poster", "post.it", "post.it.vd", "photo":
          if tdata[#class] = "post.it" then
            tdata[#type] = "#ffff33"
          end if
          tdata[#direction] = "leftwall"
          getThread(#room).getComponent().createItemObject(tdata)
          getThread(#room).getComponent().getItemObject(tdata[#id]).setaProp(#stripId, tdata[#stripId])
          if not (tdata[#class] contains "post.it") then
            me.removeStripItem(tid)
          end if
          return 1
        "floor", "wallpaper":
          getThread(#room).getComponent().getRoomConnection().send(#room, "FLATPROPERTYBYITEM" && "/" & tdata[#class] & "/" & tdata[#stripId])
          removeStripItem(me, tid)
          return 0
        "Chess":
          tdata[#direction] = [0, 0, 0]
          getThread(#room).getComponent().createItemObject(tdata)
          getThread(#room).getComponent().getItemObject(tdata[#id]).setaProp(#stripId, tdata[#stripId])
          removeStripItem(me, tid)
          return 1
        otherwise:
          return error(me, "Unknown item class:" && tdata[#class], #placeItemToRoom)
          removeStripItem(me, tid)
          return 0
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
        tHand.getSprById("room_hand_next").loc = point(630, 10)
        tHand.getSprById("room_hand_next").visible = 1
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
  if not visualizerExists(pHandVisID) then
    return 0
  end if
  tHand = getVisualizer(pHandVisID)
  tList = me.getStripItem(#list)
  tCount = tList.count
  repeat with i = 1 to 9
    tVisible = 1
    if i <= tCount then
      tItem = tList[i]
      tMem = member(getmemnum(tItem[#member]))
      tShd = member(getmemnum(tItem[#shadow]))
      tVisible = not getThread(#room).getInterface().getSafeTrader().isUnderTrade(pItemList.getPropAt(i))
    else
      tMem = member(getmemnum("room_object_placeholder_sd"))
      tShd = member(getmemnum("room_object_placeholder_sd"))
    end if
    tSpr = tHand.getSprById("room_hand_item_" & i & "_sd")
    tSpr.setMember(tShd)
    tSpr.blend = 20
    tSpr.visible = tVisible
    tSpr = tHand.getSprById("room_hand_item_" & i)
    tSpr.setMember(tMem)
    tSpr.blend = 100
    tSpr.visible = tVisible
    if not voidp(tItem) then
      if not tItem[#stripColor] then
        tSpr.ink = 8
        tSpr.bgColor = rgb(255, 255, 255)
        next repeat
      end if
      tSpr.ink = 41
      tSpr.bgColor = tItem[#stripColor]
    end if
  end repeat
  return 1
end

on hideContainerItems me
  if not visualizerExists(pHandVisID) then
    return 0
  end if
  tHand = getVisualizer(pHandVisID)
  repeat with i = 1 to 5
    tHand.getSprById("room_hand_item_" & i).setMember(member(getmemnum("room_object_placeholder_sd")))
    tHand.getSprById("room_hand_item_" & i & "_sd").setMember(member(getmemnum("room_object_placeholder_sd")))
  end repeat
  return 1
end

on eventProcContainer me, tEvent, tSprID, tParam
  if tSprID = "room_hand_next" then
    case tEvent of
      #mouseDown:
        getVisualizer(pHandVisID).getSprById("room_hand_next").setMember(member(getmemnum("room_hand_next hi")))
      #mouseUpOutSide:
        getVisualizer(pHandVisID).getSprById("room_hand_next").setMember(member(getmemnum("room_hand_next")))
      #mouseUp:
        getVisualizer(pHandVisID).getSprById("room_hand_next").setMember(member(getmemnum("room_hand_next")))
        getThread(#room).getComponent().getRoomConnection().send(#room, "GETSTRIP" && "next")
    end case
    return 1
  end if
  if tEvent <> #mouseUp then
    return 0
  end if
  case getThread(#room).getInterface().pClickAction of
    "moveHuman", "tradeItem":
      if tSprID = "room_hand" then
        return me.close()
      end if
    "placeActive", "placeItem":
      getThread(#room).getInterface().stopObjectMover()
      return getThread(#room).getComponent().getRoomConnection().send(#room, "GETSTRIP" && "new")
    "moveActive", "moveItem":
      if not getObject(#session).get("room_owner") then
        return 0
      end if
      ttype = ["active": "stuff", "item": "item"][getThread(#room).getInterface().pSelectedType]
      tObj = getThread(#room).getInterface().pSelectedObj
      getThread(#room).getInterface().stopObjectMover()
      return getThread(#room).getComponent().getRoomConnection().send(#room, "ADDSTRIPITEM" && "new" && ttype && tObj)
  end case
  if tSprID contains "room_hand_item" then
    if (getThread(#room).getInterface().pClickAction = "placeActive") or (getThread(#room).getInterface().pClickAction = "placeItem") then
      me.returnItemToHand()
    end if
    tItemNum = integer(tSprID.char[16])
    tStripList = me.getStripItem(#list)
    if tItemNum > tStripList.count then
      return error(me, "Attempted to place unexisting strip item!", #eventProcContainer)
    end if
    tdata = tStripList[tItemNum]
    tItemID = tdata[#stripId]
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
      getThread(#room).getInterface().pClickAction = "moveHuman"
    end if
    me.refresh()
  end if
end

on startItemPlacing me, tdata
  if me.placeItemToRoom(tdata[#stripId]) then
    me.setItemPlacingMode(tdata)
    me.refresh()
  end if
end

on setItemPlacingMode me, tdata
  tRoomInterface = getThread(#room).getInterface()
  tRoomInterface.pSelectedObj = tdata[#id]
  tRoomInterface.pSelectedType = tdata[#striptype]
  if tdata[#striptype] = "active" then
    tRoomInterface.startObjectMover(tdata[#id], tdata[#stripId])
    tRoomInterface.pClickAction = "placeActive"
  else
    if tdata[#striptype] = "item" then
      tRoomInterface.startObjectMover(tdata[#id], tdata[#stripId])
      tRoomInterface.pClickAction = "placeItem"
    end if
  end if
end

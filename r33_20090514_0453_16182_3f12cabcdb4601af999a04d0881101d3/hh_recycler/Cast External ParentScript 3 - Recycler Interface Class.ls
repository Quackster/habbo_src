property pWindowObj, pFurnisPerPage, pAcceptBtnActive, pProgressAnimation, pStatusIcon, pTimeLeftTimeoutID, pHeaderMemberName

on construct me
  pWindowObj = VOID
  pFurnisPerPage = 5
  pAcceptBtnActive = 0
  pTimeLeftTimeoutID = "timeLeftTimeout"
  return 1
end

on deconstruct me
  removeObject(pProgressAnimation)
  removeObject(pStatusIcon)
  return 1
end

on setHostWindowObject me, tHostWindowObj
  pWindowObj = tHostWindowObj
end

on setHeaderMemberName me, tMemberName
  pHeaderMemberName = tMemberName
end

on updateView me
  if voidp(pWindowObj) then
    return 0
  end if
  tstate = me.getComponent().getState()
  case tstate of
    #waiting:
      pWindowObj.unmerge()
      pWindowObj.merge("ctlg_recycler_simple.window")
      tHeaderText = EMPTY
    #open:
      pWindowObj.unmerge()
      pWindowObj.merge("ctlg_recycler_simple.window")
      if timeoutExists(pTimeLeftTimeoutID) then
        removeTimeout(pTimeLeftTimeoutID)
      end if
      getThread(#room).getInterface().getContainer().open()
      tHeaderText = getText("recycler_info_open")
    #closed:
      pWindowObj.unmerge()
      pWindowObj.merge("ctlg_recycler_simple.window")
      tHeaderText = getText("recycler_info_closed")
    #timeout:
      pWindowObj.unmerge()
      pWindowObj.merge("ctlg_recycler_simple.window")
      tHeaderText = getText("recycler_info_timeout")
      tHeaderText = me.replaceTimeKeys(tHeaderText, me.getComponent().getTimeout())
    otherwise:
      return 0
  end case
  me.updateBg()
  me.updateRecycleButton()
  me.updateDynamicContent()
  tHeaderImgElement = pWindowObj.getElement("ctlg_header_img")
  if not voidp(tHeaderImgElement) then
    tMemNum = getmemnum(pHeaderMemberName)
    if tMemNum <> 0 then
      tHeaderImgElement.setProperty(#image, member(tMemNum).image)
    end if
  end if
  tHeaderTextElement = pWindowObj.getElement("ctlg_header_text")
  if tHeaderTextElement <> 0 then
    tHeaderTextElement.setText(tHeaderText)
  end if
end

on updateBg me
  if voidp(pWindowObj) then
    return 0
  end if
  tstate = me.getComponent().getState()
  case tstate of
    #open:
      tBlend = 100
    #closed, #timeout, #waiting:
      tBlend = 30
  end case
  tBg = pWindowObj.getElement("bg")
  if tBg <> 0 then
    tBg.setProperty(#blend, tBlend)
  end if
  tSlotBg = pWindowObj.getElement("slot_bg")
  if tSlotBg <> 0 then
    tSlotBg.setProperty(#blend, tBlend)
  end if
end

on eventProc me, tEvent, tSprID, tProp
  if tEvent = #mouseEnter then
    tObjMover = getThread(#room).getInterface().getObjectMover()
    if tObjMover <> 0 then
      tObjMover.moveTrade()
    end if
    return 1
  end if
  if tEvent <> #mouseUp then
    return 1
  end if
  tstate = me.getComponent().getState()
  if tstate <> #open then
    return 1
  end if
  if tSprID contains "rec_drop_slot_" then
    me.eventProcSlot(tEvent, tSprID, tProp)
  end if
  case tSprID of
    "recycler_recycle_button":
      me.getComponent().startRecycling()
    otherwise:
      nothing()
  end case
  return 0
end

on eventProcSlot me, tEvent, tSprID, tProp
  tObjMover = getThread(#room).getInterface().getObjectMover()
  tContainer = getThread(#room).getInterface().getContainer()
  if objectp(tObjMover) then
    tClientObj = tObjMover.getProperty(#clientObj)
    if objectp(tClientObj) then
      if tObjMover.getProperty(#stripId) = EMPTY then
        return 0
      end if
      if me.getComponent().isPoolFull() then
        return 0
      end if
      tClientProps = tObjMover.getProperty(#clientProps)
      tClass = tClientProps[#class]
      tClientID = tObjMover.getProperty(#clientID)
      tClientProps[#type] = tObjMover.pObjType
      if not integer(tClientProps[#isRecyclable]) then
        executeMessage(#alert, [#Msg: getText("recycler_furni_not_recyclable")])
        me.getComponent().clearObjectMover()
        return 0
      end if
      me.getComponent().addFurnitureToGivePool(tClass, tClientID, tClientProps)
      me.getComponent().clearObjectMover()
      me.updateDynamicContent()
      return 1
    else
      tDelim = the itemDelimiter
      the itemDelimiter = "_"
      tSlotNo = tSprID.item[4]
      the itemDelimiter = tDelim
      me.removeItemFromSlot(tSlotNo)
    end if
    tContainer.Refresh()
  end if
end

on updateDynamicContent me
  tstate = me.getComponent().getState()
  case tstate of
    "open":
      me.updateFurniSlots()
      me.updateAcceptButtonOpenState()
    "progress":
      me.updateCancelButton()
    "ready":
      me.updateAcceptButton()
      me.updateCancelButton()
    "timeout":
      me.updateCancelButton()
    "disabled":
      me.hideCancelButton()
  end case
end

on replaceTimeKeys me, tText, tTotalSeconds, tKeyPrefix
  tTotalSeconds = integer(tTotalSeconds)
  if voidp(tTotalSeconds) then
    return tText
  end if
  tTotalMinutes = tTotalSeconds / 60
  tHours = tTotalMinutes / 60
  tMinutes = tTotalMinutes mod 60
  tSeconds = tTotalSeconds mod 60
  tText = replaceChunks(tText, "%" & tKeyPrefix & "hours%", tHours)
  tText = replaceChunks(tText, "%" & tKeyPrefix & "minutes%", tMinutes)
  tText = replaceChunks(tText, "%" & tKeyPrefix & "seconds%", tSeconds)
  return tText
end

on removeItemFromSlot me, tSlotNo
  tSlotNo = integer(tSlotNo)
  me.getComponent().removeFurniFromGivePool(tSlotNo)
  me.updateDynamicContent()
  me.updateSlots()
end

on updateSlots me
  me.updateFurniSlots()
  me.updateRecycleButton()
end

on updateFurniSlots me
  tGiveFurniPool = me.getComponent().getGiveFurniPool()
  tFurniAmount = tGiveFurniPool.count
  tSlotWidth = pWindowObj.getElement("rec_drop_slot_1").getProperty(#width)
  tSlotHeight = pWindowObj.getElement("rec_drop_slot_1").getProperty(#height)
  tEmptyImage = image(tSlotWidth, tSlotHeight, 8)
  repeat with tTemp = 1 to pFurnisPerPage
    tElement = pWindowObj.getElement("rec_drop_slot_" & tTemp)
    tElement.feedImage(tEmptyImage)
  end repeat
  tSlotNo = 1
  repeat with tFurniIndex = 1 to tGiveFurniPool.count
    tFurniItem = tGiveFurniPool[tFurniIndex]
    tIconImage = image(tSlotWidth, tSlotHeight, 32)
    tIconImage.fill(0, 0, tSlotWidth, tSlotHeight, [#color: color(255, 255, 255)])
    tSlotElement = pWindowObj.getElement("rec_drop_slot_" & tSlotNo)
    tProps = tFurniItem[#props]
    tClass = tFurniItem[#class]
    tMemStr = me.detectMemberName(tClass, tProps)
    tFurniImage = getObject("Preview_renderer").renderPreviewImage(tMemStr, VOID, tProps[#colors], tProps[#class])
    tWidthMargin = (tSlotWidth - tFurniImage.width) / 2
    tHeightMargin = (tSlotHeight - tFurniImage.height) / 2
    tTargetRect = tFurniImage.rect + rect(tWidthMargin, tHeightMargin, tWidthMargin, tHeightMargin)
    tIconImage.copyPixels(tFurniImage, tTargetRect, tFurniImage.rect)
    tSlotElement.feedImage(tIconImage)
    tSlotElement.setProperty(#blend, 100)
    tSlotNo = tSlotNo + 1
  end repeat
end

on updateRecycleButton me
  if not objectp(pWindowObj) then
    return 0
  end if
  tButton = pWindowObj.getElement("recycler_recycle_button")
  if not tButton then
    return 0
  end if
  tstate = me.getComponent().getState()
  if me.getComponent().isPoolFull() and (tstate = #open) then
    tButton.Activate()
  else
    tButton.deactivate()
  end if
end

on detectMemberName me, tClass, tProps
  tMemStr = "no_icon_small"
  tDelim = the itemDelimiter
  the itemDelimiter = "*"
  tClass = tClass.item[1]
  the itemDelimiter = tDelim
  if tClass contains "post.it" then
    tCount = integer(value(tProps[#props]) / (20.0 / 6.0))
    if tCount > 6 then
      tCount = 6
    end if
    if tCount < 1 then
      tCount = 1
    end if
    if memberExists(tClass & "_" & tCount & "_" & "small") then
      tMemStr = tClass & "_" & tCount & "_" & "small"
    else
      error(me, "Couldn't define member for recycler item!" & RETURN & tProps, #detectMemberNameString, #minor)
    end if
  else
    if memberExists(tProps[#class] & "_" & tProps[#props] & "_small") then
      tMemStr = tProps[#class] & "_" & tProps[#props] & "_small"
    else
      if memberExists(tProps[#class] & "_small") then
        tMemStr = tProps[#class] & "_small"
      else
        if memberExists(tClass && tProps[#props] & "_small") then
          tMemStr = tClass && tProps[#props] & "_small"
        else
          if memberExists(tClass & "_small") then
            tMemStr = tClass & "_small"
          else
            if memberExists("rightwall" && tClass && tProps[#props]) then
              tMemStr = "rightwall" && tClass && tProps[#props]
            end if
          end if
        end if
      end if
    end if
  end if
  return tMemStr
end

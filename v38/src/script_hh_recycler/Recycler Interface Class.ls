property pProgressAnimation, pStatusIcon, pWindowObj, pTimeLeftTimeoutID, pHeaderMemberName, pFurnisPerPage

on construct me 
  pWindowObj = void()
  pFurnisPerPage = 5
  pAcceptBtnActive = 0
  pTimeLeftTimeoutID = "timeLeftTimeout"
  return TRUE
end

on deconstruct me 
  removeObject(pProgressAnimation)
  removeObject(pStatusIcon)
  return TRUE
end

on setHostWindowObject me, tHostWindowObj 
  pWindowObj = tHostWindowObj
end

on setHeaderMemberName me, tMemberName 
  pHeaderMemberName = tMemberName
end

on updateView me 
  if voidp(pWindowObj) then
    return FALSE
  end if
  tstate = me.getComponent().getState()
  if (tstate = #waiting) then
    pWindowObj.unmerge()
    pWindowObj.merge("ctlg_recycler_simple.window")
    tHeaderText = ""
  else
    if (tstate = #open) then
      pWindowObj.unmerge()
      pWindowObj.merge("ctlg_recycler_simple.window")
      if timeoutExists(pTimeLeftTimeoutID) then
        removeTimeout(pTimeLeftTimeoutID)
      end if
      getThread(#room).getInterface().getContainer().open()
      tHeaderText = getText("recycler_info_open")
    else
      if (tstate = #closed) then
        pWindowObj.unmerge()
        pWindowObj.merge("ctlg_recycler_simple.window")
        tHeaderText = getText("recycler_info_closed")
      else
        if (tstate = #timeout) then
          pWindowObj.unmerge()
          pWindowObj.merge("ctlg_recycler_simple.window")
          tHeaderText = getText("recycler_info_timeout")
          tHeaderText = me.replaceTimeKeys(tHeaderText, me.getComponent().getTimeout())
        else
          return FALSE
        end if
      end if
    end if
  end if
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
    return FALSE
  end if
  tstate = me.getComponent().getState()
  if (tstate = #open) then
    tBlend = 100
  else
    if tstate <> #closed then
      if tstate <> #timeout then
        if (tstate = #waiting) then
          tBlend = 30
        end if
        tBg = pWindowObj.getElement("bg")
        if tBg <> 0 then
          tBg.setProperty(#blend, tBlend)
        end if
        tSlotBg = pWindowObj.getElement("slot_bg")
        if tSlotBg <> 0 then
          tSlotBg.setProperty(#blend, tBlend)
        end if
      end if
    end if
  end if
end

on eventProc me, tEvent, tSprID, tProp 
  if (tEvent = #mouseEnter) then
    tObjMover = getThread(#room).getInterface().getObjectMover()
    if tObjMover <> 0 then
      tObjMover.moveTrade()
    end if
    return TRUE
  end if
  if tEvent <> #mouseUp then
    return TRUE
  end if
  tstate = me.getComponent().getState()
  if tstate <> #open then
    return TRUE
  end if
  if tSprID contains "rec_drop_slot_" then
    me.eventProcSlot(tEvent, tSprID, tProp)
  end if
  if (tSprID = "recycler_recycle_button") then
    me.getComponent().startRecycling()
  else
    nothing()
  end if
  return FALSE
end

on eventProcSlot me, tEvent, tSprID, tProp 
  tObjMover = getThread(#room).getInterface().getObjectMover()
  tContainer = getThread(#room).getInterface().getContainer()
  if objectp(tObjMover) then
    tClientObj = tObjMover.getProperty(#clientObj)
    if objectp(tClientObj) then
      if (tObjMover.getProperty(#stripId) = "") then
        return FALSE
      end if
      if me.getComponent().isPoolFull() then
        return FALSE
      end if
      tClientProps = tObjMover.getProperty(#clientProps)
      tClass = tClientProps.getAt(#class)
      tClientID = tObjMover.getProperty(#clientID)
      tClientProps.setAt(#type, tObjMover.pObjType)
      if not integer(tClientProps.getAt(#isRecyclable)) then
        executeMessage(#alert, [#Msg:getText("recycler_furni_not_recyclable")])
        me.getComponent().clearObjectMover()
        return FALSE
      end if
      me.getComponent().addFurnitureToGivePool(tClass, tClientID, tClientProps)
      me.getComponent().clearObjectMover()
      me.updateDynamicContent()
      return TRUE
    else
      tDelim = the itemDelimiter
      the itemDelimiter = "_"
      tSlotNo = tSprID.getProp(#item, 4)
      the itemDelimiter = tDelim
      me.removeItemFromSlot(tSlotNo)
    end if
    tContainer.Refresh()
  end if
end

on updateDynamicContent me 
  tstate = me.getComponent().getState()
  if (tstate = "open") then
    me.updateFurniSlots()
    me.updateAcceptButtonOpenState()
  else
    if (tstate = "progress") then
      me.updateCancelButton()
    else
      if (tstate = "ready") then
        me.updateAcceptButton()
        me.updateCancelButton()
      else
        if (tstate = "timeout") then
          me.updateCancelButton()
        else
          if (tstate = "disabled") then
            me.hideCancelButton()
          end if
        end if
      end if
    end if
  end if
end

on replaceTimeKeys me, tText, tTotalSeconds, tKeyPrefix 
  tTotalSeconds = integer(tTotalSeconds)
  if voidp(tTotalSeconds) then
    return(tText)
  end if
  tTotalMinutes = (tTotalSeconds / 60)
  tHours = (tTotalMinutes / 60)
  tMinutes = (tTotalMinutes mod 60)
  tSeconds = (tTotalSeconds mod 60)
  tText = replaceChunks(tText, "%" & tKeyPrefix & "hours%", tHours)
  tText = replaceChunks(tText, "%" & tKeyPrefix & "minutes%", tMinutes)
  tText = replaceChunks(tText, "%" & tKeyPrefix & "seconds%", tSeconds)
  return(tText)
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
  tTemp = 1
  repeat while tTemp <= pFurnisPerPage
    tElement = pWindowObj.getElement("rec_drop_slot_" & tTemp)
    tElement.feedImage(tEmptyImage)
    tTemp = (1 + tTemp)
  end repeat
  tSlotNo = 1
  tFurniIndex = 1
  repeat while tFurniIndex <= tGiveFurniPool.count
    tFurniItem = tGiveFurniPool.getAt(tFurniIndex)
    tIconImage = image(tSlotWidth, tSlotHeight, 32)
    tIconImage.fill(0, 0, tSlotWidth, tSlotHeight, [#color:color(255, 255, 255)])
    tSlotElement = pWindowObj.getElement("rec_drop_slot_" & tSlotNo)
    tProps = tFurniItem.getAt(#props)
    tClass = tFurniItem.getAt(#class)
    tMemStr = me.detectMemberName(tClass, tProps)
    tFurniImage = getObject("Preview_renderer").renderPreviewImage(tMemStr, void(), tProps.getAt(#colors), tProps.getAt(#class))
    tWidthMargin = ((tSlotWidth - tFurniImage.width) / 2)
    tHeightMargin = ((tSlotHeight - tFurniImage.height) / 2)
    tTargetRect = (tFurniImage.rect + rect(tWidthMargin, tHeightMargin, tWidthMargin, tHeightMargin))
    tIconImage.copyPixels(tFurniImage, tTargetRect, tFurniImage.rect)
    tSlotElement.feedImage(tIconImage)
    tSlotElement.setProperty(#blend, 100)
    tSlotNo = (tSlotNo + 1)
    tFurniIndex = (1 + tFurniIndex)
  end repeat
end

on updateRecycleButton me 
  if not objectp(pWindowObj) then
    return FALSE
  end if
  tButton = pWindowObj.getElement("recycler_recycle_button")
  if not tButton then
    return FALSE
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
  tClass = tClass.getProp(#item, 1)
  the itemDelimiter = tDelim
  if tClass contains "post_it" then
    tCount = integer((value(tProps.getAt(#props)) / (20 / 6)))
    if tCount > 6 then
      tCount = 6
    end if
    if tCount < 1 then
      tCount = 1
    end if
    if memberExists(tClass & "_" & tCount & "_" & "small") then
      tMemStr = tClass & "_" & tCount & "_" & "small"
    else
      error(me, "Couldn't define member for recycler item!" & "\r" & tProps, #detectMemberNameString, #minor)
    end if
  else
    if memberExists(tProps.getAt(#class) & "_" & tProps.getAt(#props) & "_small") then
      tMemStr = tProps.getAt(#class) & "_" & tProps.getAt(#props) & "_small"
    else
      if memberExists(tProps.getAt(#class) & "_small") then
        tMemStr = tProps.getAt(#class) & "_small"
      else
        if memberExists(tClass && tProps.getAt(#props) & "_small") then
          tMemStr = tClass && tProps.getAt(#props) & "_small"
        else
          if memberExists(tClass & "_small") then
            tMemStr = tClass & "_small"
          else
            if memberExists("rightwall" && tClass && tProps.getAt(#props)) then
              tMemStr = "rightwall" && tClass && tProps.getAt(#props)
            end if
          end if
        end if
      end if
    end if
  end if
  return(tMemStr)
end

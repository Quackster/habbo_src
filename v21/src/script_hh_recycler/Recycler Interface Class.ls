property pProgressAnimation, pStatusIcon, pWindowObj, pTimeLeftTimeoutID, pHeaderImageNum, pLastPageIndex, pCurrentPageIndex, pAcceptBtnActive, pFurnisPerPage

on construct me 
  pWindowObj = void()
  pCurrentPageIndex = 1
  pLastPageIndex = 1
  pFurnisPerPage = 12
  pAcceptBtnActive = 0
  pTimeLeftTimeoutID = "timeLeftTimeout"
  pProgressAnimation = createObject("rec_prg_anim", getClassVariable("recycler.progress.animation.class"))
  pStatusIcon = createObject("rec_status_icon", getClassVariable("recycler.status.icon.class"))
  registerMessage(#gamesystem_constructed, me.getID(), #hideRecyclerStatusButton)
  registerMessage(#gamesystem_deconstructed, me.getID(), #showRecyclerStatusButton)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#gamesystem_constructed, me.getID())
  unregisterMessage(#gamesystem_deconstructed, me.getID())
  removeObject(pProgressAnimation)
  removeObject(pStatusIcon)
  return TRUE
end

on setHostWindowObject me, tHostWindowObj 
  pWindowObj = tHostWindowObj
end

on setHeaderImage me, tMemberNo 
  pHeaderImageNum = tMemberNo
end

on setViewToState me, tstate 
  if tstate <> "open" then
    if (tstate = "disabled") then
      me.hideRecyclerStatusButton()
    else
      if tstate <> "progress" then
        if tstate <> "ready" then
          if (tstate = "timeout") then
            me.showRecyclerStatusButton()
          end if
          if voidp(pWindowObj) then
            return FALSE
          end if
          if (tstate = "open") then
            pCurrentPageIndex = 1
            pWindowObj.unmerge()
            pWindowObj.merge("ctlg_recycler_open.window")
            tHeaderText = getText("recycler_info_open")
            tMinutesToRecycle = me.getComponent().getRecyclingMinutes()
            tHeaderText = me.replaceTimeKeysText(tHeaderText, tMinutesToRecycle, "total_")
            tQuarantineMinutes = me.getComponent().getQuarantineMinutes()
            tHeaderText = me.replaceTimeKeysText(tHeaderText, tQuarantineMinutes, "quarantine_")
            if timeoutExists(pTimeLeftTimeoutID) then
              removeTimeout(pTimeLeftTimeoutID)
            end if
            pProgressAnimation.stopAnimation()
          else
            if (tstate = "progress") then
              pWindowObj.unmerge()
              pWindowObj.merge("ctlg_recycler_progress.window")
              tHeaderText = getText("recycler_info_progress")
              tRecyclingMinutes = me.getComponent().getRecyclingMinutes()
              tHeaderText = me.replaceTimeKeysText(tHeaderText, tRecyclingMinutes)
              pProgressAnimation.startAnimation(pWindowObj)
              me.updateInProgressText()
              if not timeoutExists(pTimeLeftTimeoutID) then
                createTimeout(pTimeLeftTimeoutID, 60000, #updateInProgressText, me.getID(), void(), 0)
              end if
            else
              if (tstate = "ready") then
                pWindowObj.unmerge()
                pWindowObj.merge("ctlg_recycler_ready.window")
                tHeaderText = getText("recycler_info_ready")
                if pWindowObj.elementExists("rec_ready_outcome") then
                  tOutcomeElement = pWindowObj.getElement("rec_ready_outcome")
                  tOutcomeText = getText("recycler_ready_outcome")
                  tRewardName = me.getComponent().getRewardProps(#name)
                  tOutcomeText = replaceChunks(tOutcomeText, "%outcome%", tRewardName)
                  tOutcomeElement.setText(tOutcomeText)
                end if
                if timeoutExists(pTimeLeftTimeoutID) then
                  removeTimeout(pTimeLeftTimeoutID)
                end if
                pProgressAnimation.stopAnimation()
              else
                if (tstate = "timeout") then
                  pWindowObj.unmerge()
                  pWindowObj.merge("ctlg_recycler_progress.window")
                  tHeaderText = getText("recycler_info_timeout")
                else
                  if (tstate = "disabled") then
                    pWindowObj.unmerge()
                    pWindowObj.merge("ctlg_recycler_progress.window")
                    tHeaderText = getText("recycler_info_closed")
                  else
                    return FALSE
                  end if
                end if
              end if
            end if
          end if
          me.updateDynamicContent()
          tHeaderImgElement = pWindowObj.getElement("ctlg_header_img")
          if not voidp(tHeaderImgElement) then
            if pHeaderImageNum <> 0 then
              tHeaderImgElement.setProperty(#image, member(pHeaderImageNum).image)
            end if
          end if
          tHeaderTextElement = pWindowObj.getElement("ctlg_header_text")
          if not voidp(tHeaderTextElement) then
            tHeaderTextElement.setText(tHeaderText)
          end if
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
  else
    if (tEvent = #mouseUp) then
      if tSprID contains "rec_drop_slot_" then
        tObjMover = getThread(#room).getInterface().getObjectMover()
        tContainer = getThread(#room).getInterface().getContainer()
        if objectp(tObjMover) then
          tClientObj = tObjMover.getProperty(#clientObj)
          if objectp(tClientObj) then
            if (tObjMover.getProperty(#stripId) = "") then
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
            me.updateLastPageIndex()
            pCurrentPageIndex = pLastPageIndex
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
      end if
      if (tSprID = "rec_next") then
        pCurrentPageIndex = (pCurrentPageIndex + 1)
        me.updateDynamicContent()
      else
        if (tSprID = "rec_prev") then
          pCurrentPageIndex = (pCurrentPageIndex - 1)
          me.updateDynamicContent()
        else
          if tSprID <> "rec_accept_text" then
            if (tSprID = "rec_current_btn") then
              if (me.getComponent().getState() = "open") and (pAcceptBtnActive = 1) then
                me.getComponent().startRecycling()
              else
                if (me.getComponent().getState() = "ready") then
                  me.getComponent().acceptRecycling()
                end if
              end if
            else
              if tSprID <> "rec_cancel_text" then
                if (tSprID = "rec_cancel_btn") then
                  me.getComponent().cancelRecycling()
                else
                  if (tSprID = "rec_moreinfo_link") then
                    openNetPage("recycler_info_link_url")
                  end if
                end if
                return FALSE
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on updateDynamicContent me 
  tstate = me.getComponent().getState()
  if (tstate = "open") then
    me.updateFurniSlots()
    me.updateNextAndPrevButtons()
    me.updatePageIndexes()
    me.updateAcceptButtonOpenState()
    me.updateProgressBar()
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

on updateInProgressText me 
  if me.getComponent().getState() <> "progress" or voidp(pWindowObj) then
    return FALSE
  end if
  tTimeLeftText = getText("recycler_progress_timeleft")
  tMinutesLeft = (me.getComponent().getMinutesLeftToRecycle() + 1)
  tTimeLeftText = me.replaceTimeKeysText(tTimeLeftText, tMinutesLeft)
  if pWindowObj.elementExists("ctlg_time_left") then
    pWindowObj.getElement("ctlg_time_left").setText(tTimeLeftText)
  end if
end

on replaceTimeKeysText me, tText, tMinutes, tKeyPrefix 
  if not voidp(tMinutes) then
    tHours = (tMinutes / 60)
    tMinutes = (tMinutes - (tHours * 60))
    tText = replaceChunks(tText, "%" & tKeyPrefix & "hours%", tHours)
    tText = replaceChunks(tText, "%" & tKeyPrefix & "minutes%", tMinutes)
  end if
  return(tText)
end

on showRecyclerStatusButton me 
  tstate = me.getComponent().getState()
  if (tstate = "ready") or (tstate = "timeout") then
    pStatusIcon.showRecyclerButton("highlight")
  else
    if (tstate = "progress") then
      pStatusIcon.showRecyclerButton("normal")
    else
      nothing()
    end if
  end if
end

on hideRecyclerStatusButton me 
  pStatusIcon.hideRecyclerButton()
end

on updateLastPageIndex me 
  tGivenAmount = me.getComponent().getGiveFurniPool().count
  if tGivenAmount < pFurnisPerPage then
    pLastPageIndex = 1
  else
    pLastPageIndex = ((tGivenAmount / pFurnisPerPage) + 1)
  end if
end

on removeItemFromSlot me, tSlotNo 
  tSlotNo = integer(tSlotNo)
  tCurrentPageFirstIndex = (((pCurrentPageIndex - 1) * pFurnisPerPage) + 1)
  tRemovedIndex = ((tCurrentPageFirstIndex + tSlotNo) - 1)
  me.getComponent().removeFurniFromGivePool(tRemovedIndex)
  me.updateLastPageIndex()
  if pCurrentPageIndex > pLastPageIndex then
    pCurrentPageIndex = pLastPageIndex
  end if
  me.updateDynamicContent()
end

on updateFurniSlots me 
  tGiveFurniPool = me.getComponent().getGiveFurniPool()
  tFurniAmount = tGiveFurniPool.count
  tCurrentPageFirstIndex = (((pCurrentPageIndex - 1) * pFurnisPerPage) + 1)
  tSlotWidth = pWindowObj.getElement("rec_drop_slot_1").getProperty(#width)
  tSlotHeight = pWindowObj.getElement("rec_drop_slot_1").getProperty(#height)
  tEmptyImage = image(tSlotWidth, tSlotHeight, 8)
  tTemp = 1
  repeat while tTemp <= pFurnisPerPage
    tElement = pWindowObj.getElement("rec_drop_slot_" & tTemp)
    tElement.feedImage(tEmptyImage)
    tTemp = (1 + tTemp)
  end repeat
  tLastFurniIndexOnPage = min([tFurniAmount, ((tCurrentPageFirstIndex + pFurnisPerPage) - 1)])
  tSlotNo = 1
  tFurniIndex = tCurrentPageFirstIndex
  repeat while tFurniIndex <= tLastFurniIndexOnPage
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

on updateNextAndPrevButtons me 
  if pWindowObj.elementExists("rec_next") and pWindowObj.elementExists("rec_prev") then
    tNextElement = pWindowObj.getElement("rec_next")
    tPrevElement = pWindowObj.getElement("rec_prev")
  else
    return FALSE
  end if
  if (pCurrentPageIndex = 1) then
    tPrevElement.setProperty(#visible, 0)
  else
    tPrevElement.setProperty(#visible, 1)
  end if
  if (pCurrentPageIndex = pLastPageIndex) then
    tNextElement.setProperty(#visible, 0)
  else
    tNextElement.setProperty(#visible, 1)
  end if
end

on updatePageIndexes me 
  if pWindowObj.elementExists("rec_page") then
    pWindowObj.getElement("rec_page").setText(pCurrentPageIndex & "/" & pLastPageIndex)
  else
    return FALSE
  end if
end

on updateAcceptButtonOpenState me 
  tComponent = me.getComponent()
  tCurrentAmount = tComponent.getGiveFurniPool().count
  tCurrentSelectableFurni = tComponent.getRewardItemForCurrentAmount()
  tCurrentFurniElement = pWindowObj.getElement("rec_current_name")
  tCurrentBarElement = pWindowObj.getElement("rec_current_btn")
  tCurrentBarTextElement = pWindowObj.getElement("rec_accept_text")
  tBarWidth = tCurrentBarElement.getProperty(#width)
  tActive = 0
  if tCurrentSelectableFurni <> void() then
    if tCurrentSelectableFurni.getAt(#furniValue) <= tCurrentAmount then
      tActive = 1
      tCurrentFurniElement.setProperty(#blend, 100)
      tCurrentBarElement.setProperty(#image, me.getCustomButtonImage(tBarWidth, "green"))
      tCurrentBarElement.setProperty(#cursor, "cursor.finger")
      tCurrentBarElement.setProperty(#blend, 100)
      tCurrentBarTextElement.setProperty(#blend, 100)
      tCurrentFurniElement.setText(tCurrentSelectableFurni.getAt(#name))
      tCurrentBarTextElement.setProperty(#cursor, "cursor.finger")
      pAcceptBtnActive = 1
    end if
  end if
  if not tActive then
    tCurrentFurniElement.setProperty(#blend, 0)
    tCurrentBarElement.setProperty(#image, me.getCustomButtonImage(tBarWidth, "gray"))
    tCurrentBarElement.setProperty(#cursor, "cursor.arrow")
    tCurrentBarElement.setProperty(#blend, 0)
    tCurrentBarTextElement.setProperty(#blend, 0)
    tCurrentBarTextElement.setProperty(#cursor, "cursor.arrow")
    pAcceptBtnActive = 0
  end if
end

on updateAcceptButton me 
  tCurrentBarElement = pWindowObj.getElement("rec_accept_btn")
  tBarWidth = tCurrentBarElement.getProperty(#width)
  tCurrentBarElement.setProperty(#image, me.getCustomButtonImage(tBarWidth, "green"))
end

on updateCancelButton me 
  tCurrentBarElement = pWindowObj.getElement("rec_cancel_btn")
  tBarTextElement = pWindowObj.getElement("rec_cancel_text")
  tBarWidth = tCurrentBarElement.getProperty(#width)
  tCurrentBarElement.setProperty(#visible, 1)
  tBarTextElement.setProperty(#visible, 1)
  tCurrentBarElement.setProperty(#image, me.getCustomButtonImage(tBarWidth, "orange"))
end

on hideCancelButton me 
  tCurrentBarElement = pWindowObj.getElement("rec_cancel_btn")
  tCurrentBarElement.setProperty(#visible, 0)
  tBarTextElement = pWindowObj.getElement("rec_cancel_text")
  tBarTextElement.setProperty(#visible, 0)
end

on updateProgressBar me 
  tComponent = me.getComponent()
  tCurrentAmount = tComponent.getGiveFurniPool().count
  tNextItem = tComponent.getNextRewardItemForCurrentAmount()
  tNextFurniElement = pWindowObj.getElement("rec_target_name")
  tProgressBarElement = pWindowObj.getElement("rec_target_bar")
  tNextCounterElement = pWindowObj.getElement("rec_target_counter")
  tBarWidth = tProgressBarElement.getProperty(#width)
  if tNextItem <> void() then
    tCurrentAcceptapleCount = 0
    tCurrentSelectableFurni = tComponent.getRewardItemForCurrentAmount()
    tNextAmount = tNextItem.getAt(#furniValue)
    if tCurrentSelectableFurni <> void() then
      tCurrentAcceptableCount = tCurrentSelectableFurni.getAt(#furniValue)
      tPercentage = integer(((float((tCurrentAmount - tCurrentAcceptableCount)) / (tNextAmount - tCurrentAcceptableCount)) * 100))
    else
      tPercentage = integer(((float(tCurrentAmount) / tNextAmount) * 100))
    end if
    tNextFurniElement.setProperty(#blend, 100)
    tNextFurniElement.setText(tNextItem.getAt(#name))
    tProgressBarElement.setProperty(#blend, 100)
    tProgressBarElement.setProperty(#image, me.getBarImage(tBarWidth, tPercentage, "yellow"))
    tNextCounterElement.setProperty(#blend, 100)
    tNextCounterElement.setText(tCurrentAmount & "/" & tNextAmount)
  else
    tNextFurniElement.setProperty(#blend, 0)
    tProgressBarElement.setProperty(#blend, 0)
    tNextCounterElement.setProperty(#blend, 0)
  end if
end

on getCustomButtonImage me, tWidth, tColor 
  if voidp(tColor) then
    tColor = "green"
  end if
  return(me.getBarImage(tWidth, 100, tColor))
end

on getBarImage me, tBarWidth, tPercentage, tColor 
  if voidp(tColor) then
    tColor = "orange"
  end if
  tBarHeight = 29
  tMarginWidth = 8
  tBgColor = "gray"
  if (tPercentage = 100) then
    tBgColor = tColor
  else
    if (tPercentage = 0) then
      tColor = tBgColor
    end if
  end if
  tMarginLeftImg = member(getmemnum("ctlg_recycler_bar_left_" & tColor)).image
  tMarginRightImg = member(getmemnum("ctlg_recycler_bar_right_" & tBgColor)).image
  tBarBgImg = member(getmemnum("ctlg_recycler_bar_middle_" & tBgColor)).image
  tBarPercentageImg = member(getmemnum("ctlg_recycler_bar_middle_" & tColor)).image
  tBarImage = image(tBarWidth, tBarHeight, 32)
  tTargetRect = rect(0, 0, tMarginWidth, tBarHeight)
  tBarImage.copyPixels(tMarginLeftImg, tTargetRect, tMarginLeftImg.rect)
  tTargetRect = rect((tBarWidth - tMarginWidth), 0, tBarWidth, tBarHeight)
  tBarImage.copyPixels(tMarginRightImg, tTargetRect, tMarginRightImg.rect)
  tTargetRect = rect(tMarginWidth, 0, (tBarWidth - tMarginWidth), tBarHeight)
  tBarImage.copyPixels(tBarBgImg, tTargetRect, tBarBgImg.rect)
  tPercentagePixels = integer(((tBarWidth - (2 * tMarginWidth)) * (tPercentage / 100)))
  tTargetRect = rect(tMarginWidth, 0, (tMarginWidth + tPercentagePixels), tBarHeight)
  tBarImage.copyPixels(tBarPercentageImg, tTargetRect, tBarPercentageImg.rect)
  return(tBarImage)
end

on detectMemberName me, tClass, tProps 
  tMemStr = "no_icon_small"
  tDelim = the itemDelimiter
  the itemDelimiter = "*"
  tClass = tClass.getProp(#item, 1)
  the itemDelimiter = tDelim
  if tClass contains "post.it" then
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

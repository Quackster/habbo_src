property pBuffer, pCanvasMem, pMeAgreeBoxRect, pItemCanvasRectMe, pTradeItemListMe, pTradeItemListHe, pTradeItemDataList, pClosing, pClosingCounter, pMouseAgreeRect, pItemMouseRectMe, pChanges, pMeAgree, pItemMoverObj, pCheckBoxOn, pCheckBoxOff, pHeAgreeBoxRect, pHeAgree, pItemImgListMe, pItemBoxListMe, pItemBoxRect, pItemColorListMe, pItemCanvasRectHe, pItemImgListHe, pItemBoxListHe, pItemColorListHe, pTradeBoxImg, pHisHerName, pMeGettingImg, pHeGettingImg, pRollOverSaved, pRollOverFlag, pInteractive, spriteNum

on initTrade me 
  if not voidp(pBuffer) then
    return()
  end if
  member("confirm_title_e").text = "Safe trading"
  pBuffer = image(340, 180, 32)
  pCanvasMem = sprite(me.spriteNum).member
  pCanvasMem.image = pBuffer
  pTradeBoxImg = member("trade_box").image.duplicate()
  pHisHerName = ""
  pMeGettingImg = image(1, 1, 8)
  pHeGettingImg = image(1, 1, 8)
  pMeAgree = 0
  pMeAgreeBoxRect = rect(182, 141, 194, 153)
  pHeAgreeBoxRect = rect(16, 141, 28, 153)
  pMouseAgreeRect = rect((pMeAgreeBoxRect.getAt(1) + 241), (pMeAgreeBoxRect.getAt(2) + 189), (pMeAgreeBoxRect.getAt(3) + 241), (pMeAgreeBoxRect.getAt(4) + 189))
  pHeAgree = 0
  pCheckBoxOn = member("checkbox on").image.duplicate()
  pCheckBoxOff = member("checkbox off").image.duplicate()
  pFingerCursor = member("cursor_finger").number
  pFingerMask = member("cursor_finger_mask").number
  pItemImgListHe = []
  pItemImgListMe = []
  pItemColorListMe = []
  pItemColorListHe = []
  pItemCanvasRectHe = rect(18, 25, 156, 131)
  pItemCanvasRectMe = rect(184, 25, 322, 131)
  pItemBoxListHe = [rect(20, 25, 63, 77), rect(65, 25, 108, 77), rect(110, 25, 153, 77), rect(20, 79, 63, 131), rect(65, 79, 108, 131), rect(110, 79, 153, 131)]
  pItemBoxListMe = [rect(185, 25, 228, 77), rect(230, 25, 273, 77), rect(275, 25, 318, 77), rect(185, 79, 228, 131), rect(230, 79, 273, 131), rect(275, 79, 318, 131)]
  pItemBoxRect = rect(0, 0, 43, 52)
  pItemMouseRectMe = rect((pItemCanvasRectMe.getAt(1) + 241), (pItemCanvasRectMe.getAt(2) + 189), (pItemCanvasRectMe.getAt(3) + 241), (pItemCanvasRectMe.getAt(4) + 189))
  pClosing = 0
  pClosingCounter = 0
  pTradeItemDataList = []
  pTradeItemListMe = []
  pTradeItemListHe = []
  pItemMoverObj = void()
  pRollOverFlag = 0
  pRollOverSaved = 0
  i = 1
  repeat while i <= 6
    pTradeItemListMe.setAt(i, void())
    pTradeItemListHe.setAt(i, void())
    pTradeItemDataList.setAt(i, void())
    i = (1 + i)
  end repeat
  pTradeItemStripIdList = []
  buildCanvas(me)
  pInteractive = 1
  pChanges = 1
  tOpenerItemID = void()
  if stringp(gTraderWindow) then
    tOpenerItemID = gTraderWindow
  end if
  gTraderWindow = sprite(me.spriteNum).getProp(#scriptInstanceList, 1)
  if not voidp(tOpenerItemID) then
    tSpr = sendAllSprites(#returnSprByID, tOpenerItemID)
    sprite(tSpr).mouseUp()
  end if
  sendFuseMsg("GETSTRIP new")
end

on exitFrame me 
  if pClosing then
    pClosingCounter = (pClosingCounter + 1)
    if pClosingCounter >= 40 then
      sprite(me.spriteNum).scriptInstanceList = []
      close(gConfirmPopUp)
      gConfirmPopUp = void()
      sendFuseMsg("GETSTRIP new")
      return()
    end if
  end if
  if voidp(gTraderWindow) then
    return()
  end if
  tFinger = 0
  pRollOverFlag = 0
  if the mouseLoc.inside(pMouseAgreeRect) then
    tFinger = 1
  else
    if the mouseLoc.inside(pItemMouseRectMe) then
      tFinger = 1
      pRollOverFlag = 1
    end if
  end if
  mouseOverItemRect(me)
  if tFinger then
    if (sprite(me.spriteNum).cursor = 0) then
      sprite(me.spriteNum).cursor = [member("cursor_finger").number, member("cursor_finger_mask").number]
    end if
  else
    if sprite(me.spriteNum).cursor <> 0 then
      sprite(me.spriteNum).cursor = 0
    end if
  end if
  if pChanges then
    updateCanvas(me)
    pCanvasMem.image.copyPixels(pBuffer, pBuffer.rect, pBuffer.rect)
    pChanges = 0
  end if
end

on mouseDown me 
end

on mouseUp me 
  if pClosing then
    return()
  end if
  if the mouseLoc.inside(pMouseAgreeRect) then
    if (pMeAgree = 1) then
      pInteractive = 1
      sendFuseMsg("TRADE_UNACCEPT ")
    else
      if (pMeAgree = 0) then
        pInteractive = 0
        sendFuseMsg("TRADE_ACCEPT ")
      end if
    end if
  else
    if the mouseLoc.inside(pItemMouseRectMe) then
      if objectp(pItemMoverObj) then
        sendFuseMsg("TRADE_ADDITEM " & "\t" & pItemMoverObj.pStripID)
        addTradeItemToList(me, pItemMoverObj.pStripID, pItemMoverObj.pItemType)
        tDraggedItemID = pItemMoverObj.kill()
        tDraggedItemSpr = sendAllSprites(#returnSprByID, tDraggedItemID)
        if not voidp(tDraggedItemSpr) then
          sprite(tDraggedItemSpr).visible = 0
        end if
        pItemMoverObj = void()
      else
        checkChosenItem(me)
      end if
    end if
  end if
  dontPassEvent()
end

on updateCanvas me 
  if pMeAgree then
    pBuffer.copyPixels(pCheckBoxOn, pMeAgreeBoxRect, rect(0, 0, 12, 12))
  else
    pBuffer.copyPixels(pCheckBoxOff, pMeAgreeBoxRect, rect(0, 0, 12, 12))
  end if
  pBuffer.fill(pHeAgreeBoxRect, rgb(240, 240, 240))
  if pHeAgree then
    pBuffer.copyPixels(pCheckBoxOn, pHeAgreeBoxRect, rect(0, 0, 12, 12), [#blendLevel:75])
  else
    pBuffer.copyPixels(pCheckBoxOff, pHeAgreeBoxRect, rect(0, 0, 12, 12), [#blendLevel:75])
  end if
  if pMeAgree or pHeAgree then
    tBlend = 100
  else
    tBlend = 255
  end if
  pBuffer.fill(pItemCanvasRectMe, rgb(240, 240, 240))
  i = 1
  repeat while i <= pItemImgListMe.count
    tOffSet = rect(0, 0, 0, 0)
    tImg = pItemImgListMe.getAt(i)
    tRect = pItemBoxListMe.getAt(i)
    if tImg.width < pItemBoxRect.width then
      tOffSet.setAt(1, integer(((tRect.width - tImg.width) / 2)))
      tOffSet.setAt(3, tOffSet.getAt(1))
    end if
    if tImg.height < pItemBoxRect.height then
      tOffSet.setAt(2, integer(((tRect.height - tImg.height) / 2)))
      tOffSet.setAt(4, tOffSet.getAt(2))
    end if
    pBuffer.copyPixels(tImg, (tRect + tOffSet), pItemBoxRect, [#maskImage:tImg.createMatte(), #ink:41, #blendLevel:tBlend, #bgColor:pItemColorListMe.getAt(i)])
    if tImg.width > pItemBoxRect.width or tImg.height > pItemBoxRect.height then
      pBuffer.draw(pItemBoxListMe.getAt(i), [#shapeType:#rect, #color:rgb(120, 120, 120)])
    end if
    i = (1 + i)
  end repeat
  pBuffer.fill(pItemCanvasRectHe, rgb(240, 240, 240))
  i = 1
  repeat while i <= pItemImgListHe.count
    tOffSet = rect(0, 0, 0, 0)
    tImg = pItemImgListHe.getAt(i)
    tRect = pItemBoxListHe.getAt(i)
    if tImg.width < pItemBoxRect.width then
      tOffSet.setAt(1, integer(((tRect.width - tImg.width) / 2)))
      tOffSet.setAt(3, tOffSet.getAt(1))
    end if
    if tImg.height < pItemBoxRect.height then
      tOffSet.setAt(2, integer(((tRect.height - tImg.height) / 2)))
      tOffSet.setAt(4, tOffSet.getAt(2))
    end if
    pBuffer.copyPixels(tImg, (tRect + tOffSet), pItemBoxRect, [#maskImage:tImg.createMatte(), #ink:41, #blendLevel:tBlend, #bgColor:pItemColorListHe.getAt(i)])
    if tImg.width > pItemBoxRect.width or tImg.height > pItemBoxRect.height then
      pBuffer.draw(pItemBoxListHe.getAt(i), [#shapeType:#rect, #color:rgb(120, 120, 120)])
    end if
    i = (1 + i)
  end repeat
end

on buildCanvas me 
  pBuffer.fill(pBuffer.rect, rgb(240, 240, 240))
  pBuffer.copyPixels(pTradeBoxImg, rect(15, 22, 160, 135), pTradeBoxImg.rect, [#blendLevel:120])
  pBuffer.copyPixels(pTradeBoxImg, rect(180, 22, 325, 135), pTradeBoxImg.rect)
  pBuffer.copyPixels(pCheckBoxOff, pHeAgreeBoxRect, rect(0, 0, 12, 12), [#blendLevel:120])
  pBuffer.copyPixels(pCheckBoxOff, pMeAgreeBoxRect, rect(0, 0, 12, 12))
  member("trade_he_you_agrees").text = pHisHerName && "offers:"
  pMeGettingImg = image(140, 10, 8)
  pMeGettingImg.copyPixels(member("trade_he_you_agrees").image, pMeGettingImg.rect, pMeGettingImg.rect)
  member("trade_he_you_agrees").text = "You offer:"
  pHeGettingImg = image(140, 10, 8)
  pHeGettingImg.copyPixels(member("trade_he_you_agrees").image, pHeGettingImg.rect, pHeGettingImg.rect)
  member("trade_he_you_agrees").text = "You agree"
  tImg = member("trade_he_you_agrees").image.duplicate()
  pBuffer.copyPixels(tImg, rect(198, 143, 326, 163), rect(0, 0, 128, 20))
  member("trade_he_you_agrees").text = pHisHerName && "agrees"
  tImg = member("trade_he_you_agrees").image.duplicate()
  pBuffer.copyPixels(tImg, rect(32, 143, 160, 163), rect(0, 0, 128, 20), [#blendLevel:100])
  pBuffer.copyPixels(pMeGettingImg, (pMeGettingImg.rect + rect(16, 6, 16, 6)), pMeGettingImg.rect, [#ink:36, #blendLevel:120])
  pBuffer.copyPixels(pHeGettingImg, (pHeGettingImg.rect + rect(180, 6, 180, 6)), pHeGettingImg.rect, [#ink:36])
  errorMsg(me, "Waiting for" && pHisHerName)
end

on mouseOverItemRect me 
  if (pRollOverSaved = pRollOverFlag) then
    return()
  end if
  pRollOverSaved = pRollOverFlag
  if pRollOverFlag then
    tColor = rgb(0, 0, 0)
    pRollOverFlag = 0
  else
    tColor = rgb(250, 250, 250)
  end if
  pCanvasMem.image.draw((pItemCanvasRectMe + rect(-6, -5, 5, 6)), [#shapeType:#rect, #color:tColor])
end

on checkChosenItem me 
  if pClosing then
    return()
  end if
  if not pInteractive then
    return()
  end if
  tMouseLoc = (the mouseLoc - point(sprite(spriteNum).left, sprite(spriteNum).top))
  i = 1
  repeat while i <= 6
    if tMouseLoc.inside(pItemBoxListMe.getAt(i)) then
      if pTradeItemListMe.count >= i then
        errorMsg(me, pTradeItemListMe.getAt(i))
      else
        errorMsg(me, "You can't take items back, please cancel if necessary!")
      end if
      pChanges = 1
    else
      i = (1 + i)
    end if
  end repeat
end

on errorMsg me, tMsg 
  member("trade_helptxt").text = tMsg
  tImg = member("trade_helptxt").image
  pBuffer.fill(rect(16, 162, 246, 184), rgb(240, 240, 240))
  pBuffer.copyPixels(tImg, rect(16, 162, 246, 184), rect(0, 0, 230, 22), [#ink:36])
  pCanvasMem.image.copyPixels(pBuffer, pBuffer.rect, pBuffer.rect)
end

on cancelMsg me 
  if pMeAgree and pHeAgree then
    tMsg = "Trade completed."
    tOffSet = 18
  else
    tMsg = "Cancel..."
    tOffSet = 50
  end if
  member("trade_helptxt").text = tMsg
  tImg = member("trade_helptxt").image
  pBuffer.fill(pItemCanvasRectMe, rgb(240, 240, 240))
  pBuffer.fill(pItemCanvasRectHe, rgb(240, 240, 240))
  pBuffer.copyPixels(tImg, rect((15 + tOffSet), 74, (115 + tOffSet), 96), rect(0, 0, 100, 22), [#ink:36])
  pBuffer.copyPixels(tImg, rect((182 + tOffSet), 74, (282 + tOffSet), 96), rect(0, 0, 100, 22), [#ink:36])
  pCanvasMem.image.copyPixels(pBuffer, pBuffer.rect, pBuffer.rect)
end

on endSprite me 
  sprite(me.spriteNum).cursor = 0
end

on placeItemToTradeWindow me, tdata, tStripID, tSpr, tBgColor 
  if (pItemImgListMe.count = 6) then
    return FALSE
  end if
  if not voidp(pItemMoverObj) then
    sprite(pItemMoverObj.pSprite).blend = 100
    sprite(pItemMoverObj.pSprite).visible = 1
    pItemMoverObj.kill()
  end if
  tThisItem = tdata
  if tThisItem contains "*" then
    tSaveDL = the itemDelimiter
    the itemDelimiter = "*"
    tThisItem = tThisItem.getProp(#item, 1)
    the itemDelimiter = tSaveDL
  end if
  if voidp(tBgColor) then
    tBgColor = rgb(255, 255, 255)
  end if
  pItemMoverObj = new(script("tradeItemMover Class"), tThisItem, tStripID, tSpr, tBgColor)
end

on addTradeItemToList me, tid, ttype 
  tFlagA = 0
  tFlagB = 0
  i = 1
  repeat while i <= 6
    if voidp(pTradeItemDataList.getAt(i)) then
      if not tFlagA then
        tFlagA = i
      end if
    else
      if (pTradeItemDataList.getAt(i).getAt(1) = tid) then
        tFlagB = 1
      end if
    end if
    i = (1 + i)
  end repeat
  if tFlagA <> 0 and (tFlagB = 0) then
    pTradeItemDataList.setAt(tFlagA, [tid, ttype])
  end if
end

on checkIfItemIsUnderTrade me, tid 
  i = 1
  repeat while i <= pTradeItemDataList.count
    if not voidp(pTradeItemDataList.getAt(i)) then
      if (pTradeItemDataList.getAt(i).getAt(1) = tid) then
        return TRUE
      end if
    end if
    i = (1 + i)
  end repeat
  return FALSE
end

on amIFull me 
  if voidp(pTradeItemDataList.getAt(6)) then
    return FALSE
  end if
  return TRUE
end

on tradeItems me, tMsg 
  put(tMsg)
  if pClosing then
    return()
  end if
  errorMsg(me, "Add items to box.")
  saveDelim = the itemDelimiter
  the itemDelimiter = "\t"
  tdata = tMsg.getProp(#line, 2, 3)
  put(tdata)
  i = 1
  repeat while i <= 2
    tLine = tdata.getProp(#line, i)
    if (tLine.getProp(#item, 1) = gMyName) then
      pMeAgree = value(tLine.getProp(#item, 2))
      tItemList = tLine.getProp(#item, 3)
      the itemDelimiter = "/"
      pItemImgListMe = []
      pTradeItemListMe = []
      pItemColorListMe = []
      y = 1
      repeat while y <= tItemList.count(#item)
        tThisItem = ""
        tItem = tItemList.getProp(#item, y)
        the itemDelimiter = ";"
        tThisItem = tItem.getProp(#item, 6)
        tThisName = tItem.getProp(#item, 8)
        tThisColor = rgb(255, 255, 255)
        if tThisItem contains "*" then
          tThisColor = tItem.getProp(#item, 11)
          tSaveD = the itemDelimiter
          the itemDelimiter = ","
          tThisColor = tThisColor.getProp(#item, tThisColor.count(#item))
          the itemDelimiter = tSaveD
          tThisColor = tThisColor.getProp(#char, 2, tThisColor.count(#char))
          if stringp(tThisColor) then
            tThisColor = rgb(tThisColor)
          end if
          if not ilk(tThisColor, #color) then
            tThisColor = rgb(255, 255, 255)
          end if
          tSaveDL = the itemDelimiter
          the itemDelimiter = "*"
          tThisItem = tThisItem.getProp(#item, 1)
          the itemDelimiter = tSaveDL
        end if
        if member(string(tThisItem & "_small")).number > 0 then
          pItemImgListMe.add(member(tThisItem & "_small").image.duplicate())
          pItemColorListMe.add(tThisColor)
          pTradeItemListMe.add(tThisName)
        else
          tFlag = 0
          u = 1
          repeat while u <= the number of undefineds
            if tFlag then
            else
              tMemNum = getmemnum(string(castLib(u).name && "memberaliases"))
              if tMemNum > 0 then
                tList = member(tMemNum).text
                tSaveDelimX = the itemDelimiter
                the itemDelimiter = "="
                o = 1
                repeat while o <= tList.count(#line)
                  if (tList.getPropRef(#line, o).getProp(#item, 1) = string(tThisItem & "_small")) then
                    tThisItem = tList.getPropRef(#line, o).getProp(#item, 2)
                  else
                    o = (1 + o)
                  end if
                end repeat
                the itemDelimiter = tSaveDelimX
                if getmemnum(tThisItem) > 0 then
                  pItemImgListMe.add(member(tThisItem).image.duplicate())
                  pItemColorListMe.add(tThisColor)
                  pTradeItemListMe.add(tThisName)
                  tFlag = 1
                end if
              end if
              u = (1 + u)
            end if
          end repeat
        end if
        the itemDelimiter = "/"
        y = (1 + y)
      end repeat
      the itemDelimiter = "\t"
    else
      if (pHisHerName = "") then
        pHisHerName = tLine.getProp(#item, 1)
        buildCanvas(me)
      end if
      pHeAgree = value(tLine.getProp(#item, 2))
      tItemList = tLine.getProp(#item, 3)
      the itemDelimiter = "/"
      pItemImgListHe = []
      pTradeItemListHe = []
      pItemColorListHe = []
      y = 1
      repeat while y <= tItemList.count(#item)
        tThisItem = ""
        tItem = tItemList.getProp(#item, y)
        the itemDelimiter = ";"
        tThisItem = tItem.getProp(#item, 6)
        tThisName = tItem.getProp(#item, 8)
        tThisColor = rgb(255, 255, 255)
        if tThisItem contains "*" then
          tThisColor = tItem.getProp(#item, 11)
          tSaveD = the itemDelimiter
          the itemDelimiter = ","
          tThisColor = tThisColor.getProp(#item, tThisColor.count(#item))
          the itemDelimiter = tSaveD
          tThisColor = tThisColor.getProp(#char, 2, tThisColor.count(#char))
          if stringp(tThisColor) then
            tThisColor = rgb(tThisColor)
          end if
          if not ilk(tThisColor, #color) then
            tThisColor = rgb(255, 255, 255)
          end if
          tSaveDL = the itemDelimiter
          the itemDelimiter = "*"
          tThisItem = tThisItem.getProp(#item, 1)
          the itemDelimiter = tSaveDL
        end if
        if member(string(tThisItem & "_small")).number > 0 then
          pItemImgListHe.add(member(tThisItem & "_small").image.duplicate())
          pItemColorListHe.add(tThisColor)
          pTradeItemListHe.add(tThisName)
        else
          tFlag = 0
          u = 1
          repeat while u <= the number of undefineds
            if tFlag then
            else
              tMemNum = getmemnum(string(castLib(u).name && "memberaliases"))
              if tMemNum > 0 then
                tList = member(tMemNum).text
                tSaveDelimX = the itemDelimiter
                the itemDelimiter = "="
                o = 1
                repeat while o <= tList.count(#line)
                  if (tList.getPropRef(#line, o).getProp(#item, 1) = string(tThisItem & "_small")) then
                    tThisItem = tList.getPropRef(#line, o).getProp(#item, 2)
                  else
                    o = (1 + o)
                  end if
                end repeat
                the itemDelimiter = tSaveDelimX
                if getmemnum(tThisItem) > 0 then
                  pItemImgListHe.add(member(tThisItem).image.duplicate())
                  pItemColorListHe.add(tThisColor)
                  pTradeItemListHe.add(tThisName)
                  tFlag = 1
                end if
              end if
              u = (1 + u)
            end if
          end repeat
        end if
        the itemDelimiter = "/"
        y = (1 + y)
      end repeat
      the itemDelimiter = "\t"
    end if
    i = (1 + i)
  end repeat
  pChanges = 1
end

on tradeClose me 
  if pClosing then
    return()
  end if
  i = 1
  repeat while i <= pItemBoxListMe.count
    pTradeItemDataList.setAt(i, void())
    i = (1 + i)
  end repeat
  errorMsg(me, "")
  cancelMsg(me)
  pClosing = 1
  if objectp(pItemMoverObj) then
    tDraggedItemID = pItemMoverObj.kill()
    tDraggedItemSpr = sendAllSprites(#returnSprByID, tDraggedItemID)
    if not voidp(tDraggedItemSpr) then
      sprite(tDraggedItemSpr).visible = 1
      sprite(tDraggedItemSpr).blend = 100
    end if
  end if
  gTraderWindow = void()
  sendFuseMsg("GETSTRIP new")
end

on tradeAccept me, tMsg 
  if pClosing then
    return()
  end if
  saveDelim = the itemDelimiter
  the itemDelimiter = "/"
  tdata = tMsg.getProp(#line, 2, tMsg.count(#line))
  if (tdata.getProp(#item, 1) = gMyName) then
    pMeAgree = value(tdata.getProp(#item, 2))
  else
    pHeAgree = value(tdata.getProp(#item, 2))
  end if
  the itemDelimiter = saveDelim
  if pMeAgree and pHeAgree then
    errorMsg(me, "Both accepts this trade.")
  else
    if pMeAgree then
      errorMsg(me, "You accept this trade.")
    else
      if pHeAgree then
        errorMsg(me, pHisHerName && "accepts this trade.")
      else
        errorMsg(me, "Neither of you accepts this trade.")
      end if
    end if
  end if
  pChanges = 1
end

on tradeCompleted me, tMsg 
  if pClosing then
    return()
  end if
  sendFuseMsg("TRADE_CLOSE ")
end

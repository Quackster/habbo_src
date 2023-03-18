property spriteNum, pChanges, pInteractive, pBuffer, pCanvasMem, pMeAgree, pMeAgreeBoxRect, pMouseAgreeRect, pHeAgree, pHeAgreeBoxRect, pHisHerName, pMeGettingImg, pHeGettingImg, pCheckBoxOn, pCheckBoxOff, pTradeBoxImg, pRollOverFlag, pRollOverSaved, pFingerCursor, pFingerMask, pItemImgListMe, pItemColorListMe, pItemCanvasRectMe, pItemBoxListMe, pItemMouseRectMe, pItemImgListHe, pItemColorListHe, pItemCanvasRectHe, pItemBoxListHe, pItemBoxRect, pTradeItemListMe, pTradeItemListHe, pClosing, pClosingCounter, pTradeItemDataList, pItemMoverObj
global gMyName, hiliter, gTraderWindow

on initTrade me
  if not voidp(pBuffer) then
    return 
  end if
  member("confirm_title_e").text = "Safe trading"
  pBuffer = image(340, 180, 32)
  pCanvasMem = sprite(me.spriteNum).member
  pCanvasMem.image = pBuffer
  pTradeBoxImg = member("trade_box").image.duplicate()
  pHisHerName = EMPTY
  pMeGettingImg = image(1, 1, 8)
  pHeGettingImg = image(1, 1, 8)
  pMeAgree = 0
  pMeAgreeBoxRect = rect(182, 141, 194, 153)
  pHeAgreeBoxRect = rect(16, 141, 28, 153)
  pMouseAgreeRect = rect(pMeAgreeBoxRect[1] + 241, pMeAgreeBoxRect[2] + 189, pMeAgreeBoxRect[3] + 241, pMeAgreeBoxRect[4] + 189)
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
  pItemMouseRectMe = rect(pItemCanvasRectMe[1] + 241, pItemCanvasRectMe[2] + 189, pItemCanvasRectMe[3] + 241, pItemCanvasRectMe[4] + 189)
  pClosing = 0
  pClosingCounter = 0
  pTradeItemDataList = []
  pTradeItemListMe = []
  pTradeItemListHe = []
  pItemMoverObj = VOID
  pRollOverFlag = 0
  pRollOverSaved = 0
  repeat with i = 1 to 6
    pTradeItemListMe[i] = VOID
    pTradeItemListHe[i] = VOID
    pTradeItemDataList[i] = VOID
  end repeat
  pTradeItemStripIdList = []
  buildCanvas(me)
  pInteractive = 1
  pChanges = 1
  tOpenerItemID = VOID
  if stringp(gTraderWindow) then
    tOpenerItemID = gTraderWindow
  end if
  gTraderWindow = sprite(me.spriteNum).scriptInstanceList[1]
  if not voidp(tOpenerItemID) then
    tSpr = sendAllSprites(#returnSprByID, tOpenerItemID)
    sprite(tSpr).mouseUp()
  end if
  sendFuseMsg("GETSTRIP new")
end

on exitFrame me
  global gConfirmPopUp
  if pClosing then
    pClosingCounter = pClosingCounter + 1
    if pClosingCounter >= 40 then
      sprite(me.spriteNum).scriptInstanceList = []
      close(gConfirmPopUp)
      gConfirmPopUp = VOID
      sendFuseMsg("GETSTRIP new")
      return 
    end if
  end if
  if voidp(gTraderWindow) then
    return 
  end if
  tFinger = 0
  pRollOverFlag = 0
  if (the mouseLoc).inside(pMouseAgreeRect) then
    tFinger = 1
  else
    if (the mouseLoc).inside(pItemMouseRectMe) then
      tFinger = 1
      pRollOverFlag = 1
    end if
  end if
  mouseOverItemRect(me)
  if tFinger then
    if sprite(me.spriteNum).cursor = 0 then
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
    return 
  end if
  if (the mouseLoc).inside(pMouseAgreeRect) then
    case pMeAgree of
      1:
        pInteractive = 1
        sendFuseMsg("TRADE_UNACCEPT ")
      0:
        pInteractive = 0
        sendFuseMsg("TRADE_ACCEPT ")
    end case
  else
    if (the mouseLoc).inside(pItemMouseRectMe) then
      if objectp(pItemMoverObj) then
        sendFuseMsg("TRADE_ADDITEM " & TAB & pItemMoverObj.pStripID)
        addTradeItemToList(me, pItemMoverObj.pStripID, pItemMoverObj.pItemType)
        tDraggedItemID = pItemMoverObj.kill()
        tDraggedItemSpr = sendAllSprites(#returnSprByID, tDraggedItemID)
        if not voidp(tDraggedItemSpr) then
          sprite(tDraggedItemSpr).visible = 0
        end if
        pItemMoverObj = VOID
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
    pBuffer.copyPixels(pCheckBoxOn, pHeAgreeBoxRect, rect(0, 0, 12, 12), [#blendLevel: 75])
  else
    pBuffer.copyPixels(pCheckBoxOff, pHeAgreeBoxRect, rect(0, 0, 12, 12), [#blendLevel: 75])
  end if
  if pMeAgree or pHeAgree then
    tBlend = 100
  else
    tBlend = 255
  end if
  pBuffer.fill(pItemCanvasRectMe, rgb(240, 240, 240))
  repeat with i = 1 to pItemImgListMe.count
    tOffSet = rect(0, 0, 0, 0)
    tImg = pItemImgListMe[i]
    tRect = pItemBoxListMe[i]
    if tImg.width < pItemBoxRect.width then
      tOffSet[1] = integer((tRect.width - tImg.width) / 2)
      tOffSet[3] = tOffSet[1]
    end if
    if tImg.height < pItemBoxRect.height then
      tOffSet[2] = integer((tRect.height - tImg.height) / 2)
      tOffSet[4] = tOffSet[2]
    end if
    pBuffer.copyPixels(tImg, tRect + tOffSet, pItemBoxRect, [#maskImage: tImg.createMatte(), #ink: 41, #blendLevel: tBlend, #bgColor: pItemColorListMe[i]])
    if (tImg.width > pItemBoxRect.width) or (tImg.height > pItemBoxRect.height) then
      pBuffer.draw(pItemBoxListMe[i], [#shapeType: #rect, #color: rgb(120, 120, 120)])
    end if
  end repeat
  pBuffer.fill(pItemCanvasRectHe, rgb(240, 240, 240))
  repeat with i = 1 to pItemImgListHe.count
    tOffSet = rect(0, 0, 0, 0)
    tImg = pItemImgListHe[i]
    tRect = pItemBoxListHe[i]
    if tImg.width < pItemBoxRect.width then
      tOffSet[1] = integer((tRect.width - tImg.width) / 2)
      tOffSet[3] = tOffSet[1]
    end if
    if tImg.height < pItemBoxRect.height then
      tOffSet[2] = integer((tRect.height - tImg.height) / 2)
      tOffSet[4] = tOffSet[2]
    end if
    pBuffer.copyPixels(tImg, tRect + tOffSet, pItemBoxRect, [#maskImage: tImg.createMatte(), #ink: 41, #blendLevel: tBlend, #bgColor: pItemColorListHe[i]])
    if (tImg.width > pItemBoxRect.width) or (tImg.height > pItemBoxRect.height) then
      pBuffer.draw(pItemBoxListHe[i], [#shapeType: #rect, #color: rgb(120, 120, 120)])
    end if
  end repeat
end

on buildCanvas me
  pBuffer.fill(pBuffer.rect, rgb(240, 240, 240))
  pBuffer.copyPixels(pTradeBoxImg, rect(15, 22, 160, 135), pTradeBoxImg.rect, [#blendLevel: 120])
  pBuffer.copyPixels(pTradeBoxImg, rect(180, 22, 325, 135), pTradeBoxImg.rect)
  pBuffer.copyPixels(pCheckBoxOff, pHeAgreeBoxRect, rect(0, 0, 12, 12), [#blendLevel: 120])
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
  pBuffer.copyPixels(tImg, rect(32, 143, 160, 163), rect(0, 0, 128, 20), [#blendLevel: 100])
  pBuffer.copyPixels(pMeGettingImg, pMeGettingImg.rect + rect(16, 6, 16, 6), pMeGettingImg.rect, [#ink: 36, #blendLevel: 120])
  pBuffer.copyPixels(pHeGettingImg, pHeGettingImg.rect + rect(180, 6, 180, 6), pHeGettingImg.rect, [#ink: 36])
  errorMsg(me, "Waiting for" && pHisHerName)
end

on mouseOverItemRect me
  if pRollOverSaved = pRollOverFlag then
    return 
  end if
  pRollOverSaved = pRollOverFlag
  if pRollOverFlag then
    tColor = rgb(0, 0, 0)
    pRollOverFlag = 0
  else
    tColor = rgb(250, 250, 250)
  end if
  pCanvasMem.image.draw(pItemCanvasRectMe + rect(-6, -5, 5, 6), [#shapeType: #rect, #color: tColor])
end

on checkChosenItem me
  if pClosing then
    return 
  end if
  if not pInteractive then
    return 
  end if
  tMouseLoc = the mouseLoc - point(sprite(spriteNum).left, sprite(spriteNum).top)
  repeat with i = 1 to 6
    if tMouseLoc.inside(pItemBoxListMe[i]) then
      if pTradeItemListMe.count >= i then
        errorMsg(me, pTradeItemListMe[i])
      else
        errorMsg(me, "You can't take items back, please cancel if necessary!")
      end if
      pChanges = 1
      exit repeat
    end if
  end repeat
end

on errorMsg me, tMsg
  member("trade_helptxt").text = tMsg
  tImg = member("trade_helptxt").image
  pBuffer.fill(rect(16, 162, 246, 184), rgb(240, 240, 240))
  pBuffer.copyPixels(tImg, rect(16, 162, 246, 184), rect(0, 0, 230, 22), [#ink: 36])
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
  pBuffer.copyPixels(tImg, rect(15 + tOffSet, 74, 115 + tOffSet, 96), rect(0, 0, 100, 22), [#ink: 36])
  pBuffer.copyPixels(tImg, rect(182 + tOffSet, 74, 282 + tOffSet, 96), rect(0, 0, 100, 22), [#ink: 36])
  pCanvasMem.image.copyPixels(pBuffer, pBuffer.rect, pBuffer.rect)
end

on endSprite me
  sprite(me.spriteNum).cursor = 0
end

on placeItemToTradeWindow me, tdata, tStripID, tSpr, tBgColor
  if pItemImgListMe.count = 6 then
    return 0
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
    tThisItem = tThisItem.item[1]
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
  repeat with i = 1 to 6
    if voidp(pTradeItemDataList[i]) then
      if not tFlagA then
        tFlagA = i
      end if
      next repeat
    end if
    if pTradeItemDataList[i][1] = tid then
      tFlagB = 1
    end if
  end repeat
  if (tFlagA <> 0) and (tFlagB = 0) then
    pTradeItemDataList[tFlagA] = [tid, ttype]
  end if
end

on checkIfItemIsUnderTrade me, tid
  repeat with i = 1 to pTradeItemDataList.count
    if not voidp(pTradeItemDataList[i]) then
      if pTradeItemDataList[i][1] = tid then
        return 1
      end if
    end if
  end repeat
  return 0
end

on amIFull me
  if voidp(pTradeItemDataList[6]) then
    return 0
  end if
  return 1
end

on tradeItems me, tMsg
  put tMsg
  if pClosing then
    return 
  end if
  errorMsg(me, "Add items to box.")
  saveDelim = the itemDelimiter
  the itemDelimiter = TAB
  tdata = tMsg.line[2..3]
  put tdata
  repeat with i = 1 to 2
    tLine = tdata.line[i]
    if tLine.item[1] = gMyName then
      pMeAgree = value(tLine.item[2])
      tItemList = tLine.item[3]
      the itemDelimiter = "/"
      pItemImgListMe = []
      pTradeItemListMe = []
      pItemColorListMe = []
      repeat with y = 1 to tItemList.item.count
        tThisItem = EMPTY
        tItem = tItemList.item[y]
        the itemDelimiter = ";"
        tThisItem = tItem.item[6]
        tThisName = tItem.item[8]
        tThisColor = rgb(255, 255, 255)
        if tThisItem contains "*" then
          tThisColor = tItem.item[11]
          tSaveD = the itemDelimiter
          the itemDelimiter = ","
          tThisColor = tThisColor.item[tThisColor.item.count]
          the itemDelimiter = tSaveD
          tThisColor = tThisColor.char[2..tThisColor.char.count]
          if stringp(tThisColor) then
            tThisColor = rgb(tThisColor)
          end if
          if not ilk(tThisColor, #color) then
            tThisColor = rgb(255, 255, 255)
          end if
          tSaveDL = the itemDelimiter
          the itemDelimiter = "*"
          tThisItem = tThisItem.item[1]
          the itemDelimiter = tSaveDL
        end if
        if member(string(tThisItem & "_small")).number > 0 then
          pItemImgListMe.add(member(tThisItem & "_small").image.duplicate())
          pItemColorListMe.add(tThisColor)
          pTradeItemListMe.add(tThisName)
        else
          tFlag = 0
          repeat with u = 1 to the number of castLibs
            if tFlag then
              exit repeat
            end if
            tMemNum = getmemnum(string(castLib(u).name && "memberaliases"))
            if tMemNum > 0 then
              tList = member(tMemNum).text
              tSaveDelimX = the itemDelimiter
              the itemDelimiter = "="
              repeat with o = 1 to tList.line.count
                if tList.line[o].item[1] = string(tThisItem & "_small") then
                  tThisItem = tList.line[o].item[2]
                  exit repeat
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
          end repeat
        end if
        the itemDelimiter = "/"
      end repeat
      the itemDelimiter = TAB
      next repeat
    end if
    if pHisHerName = EMPTY then
      pHisHerName = tLine.item[1]
      buildCanvas(me)
    end if
    pHeAgree = value(tLine.item[2])
    tItemList = tLine.item[3]
    the itemDelimiter = "/"
    pItemImgListHe = []
    pTradeItemListHe = []
    pItemColorListHe = []
    repeat with y = 1 to tItemList.item.count
      tThisItem = EMPTY
      tItem = tItemList.item[y]
      the itemDelimiter = ";"
      tThisItem = tItem.item[6]
      tThisName = tItem.item[8]
      tThisColor = rgb(255, 255, 255)
      if tThisItem contains "*" then
        tThisColor = tItem.item[11]
        tSaveD = the itemDelimiter
        the itemDelimiter = ","
        tThisColor = tThisColor.item[tThisColor.item.count]
        the itemDelimiter = tSaveD
        tThisColor = tThisColor.char[2..tThisColor.char.count]
        if stringp(tThisColor) then
          tThisColor = rgb(tThisColor)
        end if
        if not ilk(tThisColor, #color) then
          tThisColor = rgb(255, 255, 255)
        end if
        tSaveDL = the itemDelimiter
        the itemDelimiter = "*"
        tThisItem = tThisItem.item[1]
        the itemDelimiter = tSaveDL
      end if
      if member(string(tThisItem & "_small")).number > 0 then
        pItemImgListHe.add(member(tThisItem & "_small").image.duplicate())
        pItemColorListHe.add(tThisColor)
        pTradeItemListHe.add(tThisName)
      else
        tFlag = 0
        repeat with u = 1 to the number of castLibs
          if tFlag then
            exit repeat
          end if
          tMemNum = getmemnum(string(castLib(u).name && "memberaliases"))
          if tMemNum > 0 then
            tList = member(tMemNum).text
            tSaveDelimX = the itemDelimiter
            the itemDelimiter = "="
            repeat with o = 1 to tList.line.count
              if tList.line[o].item[1] = string(tThisItem & "_small") then
                tThisItem = tList.line[o].item[2]
                exit repeat
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
        end repeat
      end if
      the itemDelimiter = "/"
    end repeat
    the itemDelimiter = TAB
  end repeat
  pChanges = 1
end

on tradeClose me
  if pClosing then
    return 
  end if
  repeat with i = 1 to pItemBoxListMe.count
    pTradeItemDataList[i] = VOID
  end repeat
  errorMsg(me, EMPTY)
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
  gTraderWindow = VOID
  sendFuseMsg("GETSTRIP new")
end

on tradeAccept me, tMsg
  if pClosing then
    return 
  end if
  saveDelim = the itemDelimiter
  the itemDelimiter = "/"
  tdata = tMsg.line[2..tMsg.line.count]
  if tdata.item[1] = gMyName then
    pMeAgree = value(tdata.item[2])
  else
    pHeAgree = value(tdata.item[2])
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
    return 
  end if
  sendFuseMsg("TRADE_CLOSE ")
end

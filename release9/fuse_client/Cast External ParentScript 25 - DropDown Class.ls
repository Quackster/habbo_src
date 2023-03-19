property pState, pProp, pTextKeys, pTextlist, pShowOrder, pDropMenuImg, pDropActiveBtnImg, pDropDownImg, pLineHeight, pMarginTop, pMarginBottom, pMarginLeft, pAlignment, pOpenDir, pMaxWidth, pDotLineImg, pFont, pFonSize, pSelectedItemNum, pRollOverItem, pLoc, pFixedSize, pOrigWidth, pLastRollOver, pTextWidth, pClickPass, pDelayID, pOnFirstChoise, pDropDownType, pmodel, pOrdering

on define me, tProps
  tField = tProps[#type] & tProps[#model] & ".element"
  pProp = getObject(#layout_parser).parse(tField)
  if pProp = 0 then
    return 0
  end if
  pState = #close
  me.pID = tProps[#id]
  me.pBuffer = tProps[#buffer]
  me.pSprite = tProps[#sprite]
  me.pLocX = me.pSprite.left
  me.pLocY = me.pSprite.top
  me.pmodel = tProps[#model]
  pAlignment = tProps[#alignment]
  pTextKeys = tProps[#keylist]
  pOrigWidth = tProps[#width]
  pLineHeight = tProps[#fixedLineSpace]
  pOpenDir = tProps[#direction]
  pMaxWidth = tProps[#maxwidth]
  pLineHeight = tProps[#height]
  pFixedSize = tProps[#fixedsize]
  pOrdering = 1
  if not voidp(pProp[#dropDownType]) then
    pDropDownType = pProp[#dropDownType].getProp(#content)
  else
    pDropDownType = #default
  end if
  pTextlist = []
  if pTextKeys.ilk <> #list then
    pTextKeys = []
  end if
  repeat with tKey in pTextKeys
    pTextlist.add(getText(tKey))
  end repeat
  if pTextlist.count = 0 then
    pTextlist.add("...")
  end if
  pShowOrder = []
  repeat with i = 1 to pTextlist.count
    pShowOrder.add(i)
  end repeat
  if voidp(me.pPalette) then
    if variableExists("interface.palette") then
      me.pPalette = member(getmemnum(getVariable("interface.palette")))
    else
      me.pPalette = #systemMac
    end if
  else
    if stringp(me.pPalette) then
      me.pPalette = member(getmemnum(me.pPalette))
    end if
  end if
  if voidp(pFixedSize) then
    pFixedSize = 0
  end if
  if voidp(pMaxWidth) then
    pMaxWidth = pOrigWidth
  end if
  if pMaxWidth < pOrigWidth then
    pMaxWidth = pOrigWidth
  end if
  if pLineHeight mod 2 then
    pLineHeight = pLineHeight + 1
  end if
  pSelectedItemNum = 1
  if me.pmodel = 2 then
    pLineHeight = pLineHeight - 1
  end if
  me.UpdateImageObjects(VOID, #up)
  pDropMenuImg = me.createDropImg(pTextlist, 1, #up)
  me.pimage = pDropMenuImg
  me.pwidth = me.pimage.width
  pheight = me.pimage.height
  pDropActiveBtnImg = me.createDropImg([pTextlist[1]], 0, #up)
  me.pimage = pDropActiveBtnImg
  tTempOffset = me.pBuffer.regPoint
  me.pBuffer.image = me.pimage
  me.pBuffer.regPoint = tTempOffset
  me.pSprite.blend = tProps[#blend]
  return 1
end

on prepare me
  me.pLocX = me.pSprite.locH
  me.pLocY = me.pSprite.locV
  case pAlignment of
    #center:
      me.pLocX = me.pLocX - ((me.pwidth - pOrigWidth) / 2)
    #right:
      me.pLocX = me.pLocX - (me.pwidth - pOrigWidth)
  end case
  me.pSprite.loc = point(me.pLocX, me.pLocY)
end

on Activate me
  me.pSprite.blend = 100
  return 1
end

on deactivate me
  me.pSprite.blend = 50
  return 1
end

on updateData me, tTextList, tTextKeys, tChosenIndex, tChosenValue
  pTextlist = tTextList
  pTextKeys = tTextKeys
  pShowOrder = []
  repeat with i = 1 to pTextlist.count
    pShowOrder.add(i)
  end repeat
  if (tChosenIndex > 0) and (tChosenIndex <= pShowOrder.count) then
    pSelectedItemNum = tChosenIndex
  end if
  if not voidp(tChosenValue) then
    me.setSelection(tChosenValue)
  end if
  pDropActiveBtnImg = me.createDropImg([pTextlist[pSelectedItemNum]], 0, #up)
  me.pimage = me.pDropActiveBtnImg
  me.render()
  return 1
end

on getSelection me, tReturnType
  if tReturnType = #text then
    return pTextlist[pShowOrder[pSelectedItemNum]]
  else
    if tReturnType = #key then
      return pTextKeys[pShowOrder[pSelectedItemNum]]
    end if
  end if
  return pTextKeys[pShowOrder[pSelectedItemNum]]
end

on setSelection me, tSelNumOrStr, tUpdate
  tEarlierSelection = pSelectedItemNum
  if stringp(tSelNumOrStr) then
    tSelNum = pTextlist.getPos(tSelNumOrStr)
    if tSelNum = 0 then
      tSelNum = pTextKeys.getPos(tSelNumOrStr)
    end if
  else
    tSelNum = tSelNumOrStr
  end if
  if tSelNum <= 0 then
    return 0
  end if
  pSelectedItemNum = pShowOrder.getPos(tSelNum)
  if not pSelectedItemNum > 0 then
    pSelectedItemNum = 1
  end if
  if tEarlierSelection = pSelectedItemNum then
    return 1
  end if
  if tUpdate then
    me.arrangeTextList(#choose)
    pDropActiveBtnImg = me.createDropImg([pTextlist[pShowOrder[pSelectedItemNum]]], 0, #up)
    me.pimage = pDropActiveBtnImg
    me.pSprite.loc = pLoc
    me.render()
  end if
  return 1
end

on setShowOrder me, tStyle, tFirstNum, tDeleteOne, tOpenDir
  if not pOrdering then
    return 1
  end if
  tChoise = pShowOrder[pSelectedItemNum]
  case tStyle of
    #reverse:
      repeat with i = 1 to pTextlist.count
        pShowOrder[i] = pTextlist.count + 1 - i
      end repeat
    #normal:
      repeat with i = 1 to pTextlist.count
        pShowOrder[i] = i
      end repeat
  end case
  if tFirstNum > 0 then
    if tOpenDir = #down then
      tTemp = pShowOrder[1]
      tTempPlace = pShowOrder.getPos(tFirstNum)
      pShowOrder[1] = tFirstNum
      pShowOrder[tTempPlace] = tTemp
    else
      tTemp = pShowOrder[pShowOrder.count]
      tTempPlace = pShowOrder.getPos(tFirstNum)
      pShowOrder[pShowOrder.count] = tFirstNum
      pShowOrder[tTempPlace] = tTemp
    end if
  end if
  if tDeleteOne > 0 then
    pShowOrder.deleteOne(tDeleteOne)
  end if
  pSelectedItemNum = pShowOrder.getPos(tChoise)
  return 0
end

on setOrdering me, tMode
  pOrdering = tMode
  return 1
end

on arrangeTextList me, tStyle
  if pDropDownType = #titleWithCancel then
    case tStyle of
      #open:
        if pShowOrder[pSelectedItemNum] > 2 then
          me.setShowOrder(#normal, pShowOrder[pSelectedItemNum], 1)
        else
          me.setShowOrder(#reverse, 1, 2)
        end if
        pDropMenuImg = me.createDropImg(pTextlist, 1, #up)
      #choose:
        if pShowOrder[pSelectedItemNum] <= 2 then
          me.setShowOrder(#normal)
          pSelectedItemNum = 1
        end if
    end case
  end if
  if (pDropDownType = #default) and (pOpenDir = #up) then
    case tStyle of
      #open:
        me.setShowOrder(#normal, pShowOrder[pSelectedItemNum])
        pDropMenuImg = me.createDropImg(pTextlist, 1, #up)
      #choose:
        me.setShowOrder(#reverse, pShowOrder[pSelectedItemNum], #down)
    end case
  end if
  if (pDropDownType = #default) and (pOpenDir = #down) then
    case tStyle of
      #open:
        me.setShowOrder(#reverse, pShowOrder[pSelectedItemNum], VOID, #down)
        pDropMenuImg = me.createDropImg(pTextlist, 1, #up)
      #choose:
        me.setShowOrder(#reverse, pShowOrder[pSelectedItemNum], #down)
    end case
  end if
end

on getProperty me, tProp
  case tProp of
    #width:
      return me.pSprite.width
    #height:
      return me.pSprite.height
    #locX:
      return me.pLocX
    #locY:
      return me.pLocY
    #depth:
      return me.pimage.depth
    #blend:
      return me.pSprite.blend
    #selection:
      return pTextKeys[pShowOrder[pSelectedItemNum]]
    #sprite:
      return me.pSprite
    otherwise:
      return 0
  end case
end

on openMenu me
  me.arrangeTextList(#open)
  me.pimage = pDropMenuImg
  pLoc = me.pSprite.loc
  case pOpenDir of
    #lastselected:
      me.pSprite.loc = pLoc - point(0, (pSelectedItemNum - 1) * pLineHeight)
    #up:
      me.pSprite.loc = pLoc - point(0, (pShowOrder.count - 1) * pLineHeight)
  end case
  me.render()
  pState = #open
  pLastRollOver = -2
  pOnFirstChoise = 1
  return 1
end

on chooseFromMenu me
  pClickPass = 0
  pState = #close
  pLastRollOver = VOID
  if (pRollOverItem > 0) and (pRollOverItem <= pShowOrder.count) then
    pSelectedItemNum = pRollOverItem
    me.arrangeTextList(#choose)
    pDropActiveBtnImg = me.createDropImg([pTextlist[pShowOrder[pSelectedItemNum]]], 0, #up)
    me.pimage = pDropActiveBtnImg
    me.pSprite.loc = pLoc
    me.render()
    if not voidp(pTextKeys[pShowOrder[pSelectedItemNum]]) then
      return pTextKeys[pShowOrder[pSelectedItemNum]]
    end if
  end if
end

on mouseDown me
  if me.pSprite.blend < 100 then
    return 0
  end if
  pClickPass = 1
  if pState <> #open then
    return me.openMenu()
  end if
end

on mouseUp me
  if pOnFirstChoise then
    pOnFirstChoise = 0
    return 0
  end if
  if me.pSprite.blend < 100 then
    return 0
  end if
  if pClickPass = 0 then
    return 0
  end if
  me.cancelDelay()
  return me.chooseFromMenu()
end

on mouseUpOutSide me
  if me.pSprite.locH > 5000 then
    return 0
  end if
  pClickPass = 0
  pState = #close
  pLastRollOver = VOID
  me.pimage = pDropActiveBtnImg
  me.render()
  me.pSprite.loc = pLoc
  return 0
end

on mouseEnter me
  me.cancelDelay()
end

on cancelDelay me
  if not voidp(pDelayID) then
    me.cancel(pDelayID)
    pDelayID = VOID
  end if
end

on mouseLeave me
  if pState = #open then
    pDelayID = me.delay(500, #mouseUpOutSide)
  end if
end

on mouseWithin me
  if pState = #open then
    if voidp(pLastRollOver) then
      pLastRollOver = 0
    end if
    pRollOverItem = ((the mouseV - me.pSprite.top - 1) / pLineHeight) + 1
    if pLastRollOver = -2 then
      pLastRollOver = -1
      return 1
    end if
    if pOnFirstChoise and (pLastRollOver = -1) then
      pLastRollOver = pRollOverItem
    end if
    if pRollOverItem <> pLastRollOver then
      pOnFirstChoise = 0
      if pRollOverItem > pShowOrder.count then
        pRollOverItem = pShowOrder.count
      end if
      if pShowOrder.count = pRollOverItem then
        tMaskFix = pMarginBottom
      else
        tMaskFix = 0
      end if
      tTempImage = pDropMenuImg.duplicate()
      tTempActiveBoxImg = image(me.pwidth, pLineHeight + tMaskFix, 8, me.pPalette)
      tMemberDesc = pProp[#up][#members][#activeline]
      tmember = member(getmemnum(tMemberDesc[#member]))
      tTempActiveBoxImg.copyPixels(tmember.image, tTempActiveBoxImg.rect, tmember.rect)
      tActiveTop = (pRollOverItem - 1) * pLineHeight
      tdestrect = rect(0, tActiveTop, me.pwidth, tActiveTop + pLineHeight + tMaskFix)
      tTempImage.copyPixels(tTempActiveBoxImg, tdestrect, tTempActiveBoxImg.rect, [#maskImage: pDropMenuImg.createMatte(), #maskOffset: point(0, -tActiveTop), #ink: 39])
      me.pimage = tTempImage
      me.reDraw()
      pLastRollOver = pRollOverItem
    end if
  end if
end

on reDraw me
  me.pBuffer.image.copyPixels(me.pimage, me.pimage.rect, me.pimage.rect)
end

on render me
  tTempOffset = me.pBuffer.regPoint
  me.pSprite.width = me.pimage.width
  me.pSprite.height = me.pimage.height
  me.pBuffer.image = me.pimage
  me.pBuffer.regPoint = tTempOffset
end

on UpdateImageObjects me, tPalette, tstate
  pDropDownImg = [:]
  if voidp(tPalette) then
    tPalette = me.pPalette
  else
    if stringp(tPalette) then
      tPalette = member(getmemnum(tPalette))
    end if
  end if
  repeat with tV in [#top, #middle, #bottom]
    repeat with tH in [#left, #middle, #right]
      tSymbol = symbol(tV & tH)
      tDesc = pProp[tstate][#members][tSymbol]
      tmember = member(getmemnum(tDesc[#member]))
      tImage = tmember.image.duplicate()
      if tImage.paletteRef <> tPalette then
        tImage.paletteRef = tPalette
      end if
      if tDesc[#flipH] then
        tImage = me.flipH(tImage)
      end if
      if tDesc[#flipV] then
        tImage = me.flipV(tImage)
      end if
      if not voidp(tDesc[#rotate]) then
        tImage = me.rotateImg(tImage, tDesc[#rotate])
      end if
      pDropDownImg.addProp(tV & "_" & tH, tImage)
    end repeat
  end repeat
  if not voidp(pProp[#optionalimage]) then
    tOptionalImages = pProp[#optionalimage][#members]
    repeat with i = 1 to tOptionalImages.count()
      tDesc = tOptionalImages[tOptionalImages.getPropAt(i)]
      tMemName = tDesc[#member]
      tmember = member(getmemnum(tMemName))
      tImage = tmember.image.duplicate()
      if tImage.paletteRef <> tPalette then
        tImage.paletteRef = tPalette
      end if
      if tDesc[#flipH] then
        tImage = me.flipH(tImage)
      end if
      if tDesc[#flipV] then
        tImage = me.flipV(tImage)
      end if
      pDropDownImg.addProp("optionalimage_" & tOptionalImages.getPropAt(i), tImage)
    end repeat
  end if
  pDotLineImg = image(pMaxWidth, 1, 8, tPalette)
  repeat with tXPoint = 0 to pMaxWidth / 2
    pDotLineImg.setPixel(tXPoint * 2, 0, rgb(0, 0, 0))
  end repeat
  me.pPalette = tPalette
  return tPalette
end

on createDropImg me, tItemsList, tListOfAllItemsOrNot, tstate, tSort
  tStr = EMPTY
  if not tListOfAllItemsOrNot then
    tStr = tStr & tItemsList[1] & RETURN
  else
    repeat with f = 1 to pShowOrder.count
      tStr = tStr & tItemsList[pShowOrder[f]] & RETURN
    end repeat
  end if
  tMemNum = getmemnum("dropdown.button.text")
  if tMemNum = 0 then
    tMemNum = createMember("dropdown.button.text", #text)
  end if
  tTextMember = member(tMemNum)
  tFontDesc = pProp[tstate][#text]
  pMarginTop = tFontDesc[#marginV]
  pMarginLeft = tFontDesc[#marginH]
  pMarginBottom = tFontDesc[#marginbottom]
  tTextMember.wordWrap = 0
  tTextMember.font = string(tFontDesc[#font])
  tTextMember.fontStyle = list(symbol(tFontDesc[#fontStyle]))
  tTextMember.fontSize = tFontDesc[#fontSize]
  tTextMember.color = rgb(tFontDesc[#color])
  tTextMember.text = tStr.line[1..tStr.line.count - 1]
  tTextMember.fixedLineSpace = pLineHeight
  if (tListOfAllItemsOrNot = 1) and not voidp(pProp[#optionalimage]) then
    tOptionalImages = pProp[#optionalimage][#members]
    tOptionalImagesWidth = 0
    repeat with i = 1 to tOptionalImages.count()
      tOptionalImagesWidth = tOptionalImagesWidth + pDropDownImg["optionalimage_" & tOptionalImages.getPropAt(i)].width
    end repeat
  else
    tOptionalImagesWidth = 0
  end if
  if pFixedSize = 1 then
    tTextMember.alignment = tFontDesc[#alignment]
    pTextWidth = pOrigWidth - (pMarginLeft * 2)
    tTextMember.rect = rect(0, 0, pTextWidth, tTextMember.height)
    tTextImg = tTextMember.image
    me.pwidth = pOrigWidth
  else
    tTextMember.alignment = #left
    if tListOfAllItemsOrNot = 1 then
      tMaxLengt = 1
      tCharNum = 1
      tSofarChars = 0
      repeat with tLineN = 1 to tStr.line.count
        tSofarChars = tSofarChars + tStr.line[tLineN].char.count
        if tStr.line[tLineN].char.count > tMaxLengt then
          tMaxLengt = tSofarChars
          tCharNum = tSofarChars
          tLineWidth = tTextMember.charPosToLoc(tCharNum).locH + (tFontDesc[#fontSize] * 2)
          if tLineWidth > pTextWidth then
            pTextWidth = tLineWidth
          end if
        end if
      end repeat
      me.pwidth = pTextWidth + (pMarginLeft * 2) + tOptionalImagesWidth
      pFixedSize = 1
      pOrigWidth = me.pwidth
    end if
    tTextMember.rect = rect(0, 0, pTextWidth, tTextMember.height)
    tTextMember.alignment = tFontDesc[#alignment]
    tTextImg = tTextMember.image
  end if
  tWidth = me.pwidth
  if tItemsList.count = 1 then
    if me.pmodel = 2 then
      tNewImg = image(tWidth, pLineHeight, 8, me.pPalette)
    else
      tNewImg = image(tWidth, pLineHeight + pMarginBottom, 8, me.pPalette)
    end if
  else
    tNewImg = image(tWidth, (pShowOrder.count * pLineHeight) + pMarginBottom, 8, me.pPalette)
  end if
  tdestrect = rect(0, 0, 0, 0)
  tEndPointX = 0
  tEndPointY = 0
  tLastX = 0
  tStartPoint = 0
  if tItemsList.count = 1 then
    tItemCount = 1
  else
    tItemCount = pShowOrder.count
  end if
  repeat with f in ["top", "middle", "bottom"]
    tStartPoint = tEndPointY
    tEndPointX = 0
    case f of
      "top":
        tEndPointY = tEndPointY + pDropDownImg[1].height
      "middle":
        tEndPointY = tEndPointY + (tItemCount * pLineHeight) - (tEndPointY * 2) + pMarginBottom
      "bottom":
        tEndPointY = tEndPointY + pDropDownImg[1].height
    end case
    repeat with i in ["left", "middle", "right"]
      tLastX = tEndPointX
      case i of
        "left":
          tEndPointX = tEndPointX + pDropDownImg.getProp(f & "_" & i).width
        "middle":
          tEndPointX = tEndPointX + tWidth - pDropDownImg.getProp(#top_left).width - pDropDownImg.getProp(#top_right).width
        "right":
          tEndPointX = tEndPointX + pDropDownImg.getProp(f & "_" & i).width
      end case
      tdestrect = rect(tLastX, tStartPoint, tEndPointX, tEndPointY)
      tNewImg.copyPixels(pDropDownImg.getProp(f & "_" & i), tdestrect, pDropDownImg.getProp(f & "_" & i).rect)
    end repeat
  end repeat
  if (tListOfAllItemsOrNot = 0) and not voidp(pProp[#optionalimage]) then
    tOptionalImages = pProp[#optionalimage][#members]
    repeat with i = 1 to tOptionalImages.count()
      tPosition = tOptionalImages.getPropAt(i)
      tOptionalImg = pDropDownImg["optionalimage_" & tOptionalImages.getPropAt(i)]
      tOptionImgRect = tOptionalImg.rect
      tOptionImgMargH = tOptionalImages[tOptionalImages.getPropAt(i)][#marginH]
      tOptionImgMargV = (tNewImg.height / 2) - (tOptionImgRect.height / 2)
      if tPosition = #right then
        tdestrect = tOptionImgRect + rect(me.pwidth - tOptionImgMargH - tOptionImgRect.width, tOptionImgMargV, me.pwidth - tOptionImgMargH - tOptionImgRect.width, tOptionImgMargV)
      else
        if tPosition = #left then
          tdestrect = tOptionImgRect + rect(tOptionImgMargH, tOptionImgMargV, tOptionImgMargH, tOptionImgMargV)
        end if
      end if
      tNewImg.copyPixels(tOptionalImg, tdestrect, tOptionImgRect, [#ink: 36])
    end repeat
  end if
  if tItemCount > 1 then
    repeat with f = 1 to tItemCount - 1
      tdestrect = rect(0, f * pLineHeight, tWidth - 1, (f * pLineHeight) + 1)
      tNewImg.copyPixels(pDotLineImg, tdestrect, rect(0, 0, tWidth - 1, 1), [#ink: 36])
    end repeat
  end if
  tdestrect = tTextImg.rect + rect(0, pMarginTop, 0, pMarginTop)
  case tFontDesc[#alignment] of
    #left:
      tdestrect = tdestrect + rect(pMarginLeft, 0, pMarginLeft, 0)
    #center:
      tdestrect = tdestrect + rect(tNewImg.width / 2, 0, tNewImg.width / 2, 0) - rect(pTextWidth / 2, 0, pTextWidth / 2, 0)
    #right:
      tdestrect = tdestrect + rect(tNewImg.width, 0, tNewImg.width, 0) - rect(pTextWidth + pDropDownImg.getProp("top_right").width, 0, pTextWidth + pDropDownImg.getProp("top_right").width, 0)
  end case
  if variableExists("dropdown.top.offset") then
    tdestrect = tdestrect + rect(0, getVariable("dropdown.top.offset"), 0, getVariable("dropdown.top.offset"))
  end if
  tNewImg.copyPixels(tTextImg, tdestrect, tTextImg.rect)
  return tNewImg
end

on flipH me, tImg
  tImage = image(tImg.width, tImg.height, tImg.depth, tImg.paletteRef)
  tQuad = [point(tImg.width, 0), point(0, 0), point(0, tImg.height), point(tImg.width, tImg.height)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return tImage
end

on flipV me, tImg
  tImage = image(tImg.width, tImg.height, tImg.depth, tImg.paletteRef)
  tQuad = [point(0, tImg.height), point(tImg.width, tImg.height), point(tImg.width, 0), point(0, 0)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return tImage
end

on rotateImg me, tImg, tDirection
  tImage = image(tImg.height, tImg.width, tImg.depth, tImg.paletteRef)
  tQuad = [point(0, 0), point(tImg.height, 0), point(tImg.height, tImg.width), point(0, tImg.width)]
  tQuad = me.RotateQuad(tQuad, tDirection)
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return tImage
end

on RotateQuad me, tDestquad, tClockwise
  tPoint1 = tDestquad[1]
  tPoint2 = tDestquad[2]
  tPoint3 = tDestquad[3]
  tPoint4 = tDestquad[4]
  if tClockwise = 1 then
    tDestquad = [tPoint2, tPoint3, tPoint4, tPoint1]
  else
    tDestquad = [tPoint4, tPoint1, tPoint2, tPoint3]
  end if
  return tDestquad
end

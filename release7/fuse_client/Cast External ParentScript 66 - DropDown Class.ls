property pState, pProp, pTextlist, pMenuItems, pDropMenuImg, pDropActiveBtnImg, pDropDownImg, pLineHeight, pMarginTop, pMarginBottom, pMarginLeft, pTextKeys, pAlignment, pOpenDir, pMaxWidth, pDotLineImg, pFont, pFonSize, pNumberOfMenuItems, pSelectedItemNum, pRollOverItem, pLoc, pFixedSize, pOrigWidth, pLastRollOver, pTextWidth, pClickPass

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
  pmodel = tProps[#model]
  pAlignment = tProps[#alignment]
  pTextKeys = tProps[#keylist]
  pOrigWidth = tProps[#width]
  pLineHeight = tProps[#fixedLineSpace]
  pOpenDir = tProps[#direction]
  pMaxWidth = tProps[#maxwidth]
  pLineHeight = tProps[#height]
  pFixedSize = tProps[#fixedsize]
  pTextlist = []
  repeat with tKey in pTextKeys
    if textExists(tKey) then
      pTextlist.add(getText(tKey))
    end if
  end repeat
  if pTextlist.count = 0 then
    pTextlist.add("...")
  end if
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
  pMenuItems = pTextlist
  pNumberOfMenuItems = pTextlist.count()
  me.UpdateImageObjects(VOID, #up)
  pDropMenuImg = me.createDropImg(pMenuItems, 1, #up)
  me.pimage = pDropMenuImg
  me.pwidth = me.pimage.width
  pheight = me.pimage.height
  pDropActiveBtnImg = me.createDropImg([pMenuItems[1]], 0, #up)
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

on getSelection me, tReturnType
  if tReturnType = #text then
    return pTextlist[pSelectedItemNum]
  else
    if tReturnType = #key then
      return pTextKeys[pSelectedItemNum]
    end if
  end if
  return pTextKeys[pSelectedItemNum]
end

on setSelection me, tSelNumOrStr
  if stringp(tSelNumOrStr) then
    tSelNum = pMenuItems.getPos(tSelNumOrStr)
    if tSelNum = 0 then
      tSelNum = pTextKeys.getPos(tSelNumOrStr)
    end if
  else
    tSelNum = tSelNumOrStr
  end if
  if (tSelNum > 0) and (tSelNum <= pNumberOfMenuItems) then
    pSelectedItemNum = tSelNum
    pDropActiveBtnImg = me.createDropImg([pMenuItems[pSelectedItemNum]], 0, #up)
    me.pimage = pDropActiveBtnImg
    me.pSprite.loc = pLoc
    me.render()
    return 1
  else
    return 0
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
      return pTextKeys[pSelectedItemNum]
    otherwise:
      return 0
  end case
end

on mouseDown me
  if me.pSprite.blend < 100 then
    return 0
  end if
  pClickPass = 1
  if pState <> #open then
    me.pimage = pDropMenuImg
    pLoc = me.pSprite.loc
    case pOpenDir of
      #lastselected:
        me.pSprite.loc = pLoc - point(0, (pSelectedItemNum - 1) * pLineHeight)
      #up:
        me.pSprite.loc = pLoc - point(0, (pTextlist.count() - 1) * pLineHeight)
    end case
    me.render()
    pState = #open
    return 1
  end if
end

on mouseUp me
  if me.pSprite.blend < 100 then
    return 0
  end if
  if pClickPass = 0 then
    return 0
  end if
  pClickPass = 0
  pState = #close
  pLastRollOver = VOID
  if (pRollOverItem > 0) and (pRollOverItem <= pNumberOfMenuItems) then
    pSelectedItemNum = pRollOverItem
    pDropActiveBtnImg = me.createDropImg([pMenuItems[pSelectedItemNum]], 0, #up)
    me.pimage = pDropActiveBtnImg
    me.pSprite.loc = pLoc
    me.render()
    updateStage()
    if not voidp(pTextKeys[pSelectedItemNum]) then
      return pTextKeys[pSelectedItemNum]
    end if
  end if
end

on mouseUpOutSide me
  pClickPass = 0
  pState = #close
  pLastRollOver = VOID
  me.pimage = pDropActiveBtnImg
  me.render()
  me.pSprite.loc = pLoc
  return 0
end

on mouseWithin me
  if pState = #open then
    if voidp(pLastRollOver) then
      pLastRollOver = 0
    end if
    pRollOverItem = ((the mouseV - me.pSprite.top - 1) / pLineHeight) + 1
    if pRollOverItem <> pLastRollOver then
      if pRollOverItem > pNumberOfMenuItems then
        pRollOverItem = pNumberOfMenuItems
      end if
      if pNumberOfMenuItems = pRollOverItem then
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

on createDropImg me, tItemsList, tListOfAllItemsOrNot, tstate
  tStr = EMPTY
  repeat with f = 1 to tItemsList.count
    tStr = tStr & tItemsList[f] & RETURN
  end repeat
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
          tTempline = tLineN
        end if
      end repeat
      pTextWidth = tTextMember.charPosToLoc(tCharNum).locH + (tFontDesc[#fontSize] * 2)
      pTextWidth = pTextWidth + (10 - (pTextWidth mod 10)) - tOptionalImagesWidth
      me.pwidth = pTextWidth + (pMarginLeft * 2) + tOptionalImagesWidth
    end if
    tTextMember.rect = rect(0, 0, pTextWidth, tTextMember.height)
    tTextMember.alignment = tFontDesc[#alignment]
    tTextImg = tTextMember.image
  end if
  tWidth = me.pwidth
  tNewImg = image(tWidth, (tItemsList.count * pLineHeight) + pMarginBottom, 8, me.pPalette)
  tdestrect = rect(0, 0, 0, 0)
  tEndPointX = 0
  tEndPointY = 0
  tLastX = 0
  tStartPoint = 0
  repeat with f in ["top", "middle", "bottom"]
    tStartPoint = tEndPointY
    tEndPointX = 0
    case f of
      "top":
        tEndPointY = tEndPointY + pDropDownImg[1].height
      "middle":
        tEndPointY = tEndPointY + (tItemsList.count * pLineHeight) - (tEndPointY * 2) + pMarginBottom
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
  if tItemsList.count() > 1 then
    repeat with f = 1 to tItemsList.count - 1
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
  tNewImg.copyPixels(tTextImg, tdestrect, tTextImg.rect)
  return tNewImg
end

on setActiveItemTo me, tItem
  if voidp(pTextKeys.findPos(tItem)) then
    return error(me, "Cannot activate the item of dropmenu:" && tItem)
  end if
  pSelectedItemNum = pTextKeys.findPos(tItem)
  pDropActiveBtnImg = me.createDropImg([pMenuItems[pSelectedItemNum]], 0, #up)
  me.pimage = pDropActiveBtnImg
  me.render()
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

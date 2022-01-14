property pProp, pTextKeys, pTextlist, pFixedSize, pMaxWidth, pOrigWidth, pLineHeight, pMenuItems, pDropMenuImg, pDropActiveBtnImg, pAlignment, pSelectedItemNum, pNumberOfMenuItems, pLoc, pState, pOpenDir, pClickPass, pRollOverItem, pLastRollOver, pMarginBottom, pDropDownImg, pDotLineImg, pMarginLeft, pTextWidth, pMarginTop

on define me, tProps 
  tField = tProps.getAt(#type) & tProps.getAt(#model) & ".element"
  pProp = getObject(#layout_parser).parse(tField)
  if (pProp = 0) then
    return FALSE
  end if
  pState = #close
  me.pID = tProps.getAt(#id)
  me.pBuffer = tProps.getAt(#buffer)
  me.pSprite = tProps.getAt(#sprite)
  me.pLocX = me.pSprite.left
  me.pLocY = me.pSprite.top
  pmodel = tProps.getAt(#model)
  pAlignment = tProps.getAt(#alignment)
  pTextKeys = tProps.getAt(#keylist)
  pOrigWidth = tProps.getAt(#width)
  pLineHeight = tProps.getAt(#fixedLineSpace)
  pOpenDir = tProps.getAt(#direction)
  pMaxWidth = tProps.getAt(#maxwidth)
  pLineHeight = tProps.getAt(#height)
  pFixedSize = tProps.getAt(#fixedsize)
  pTextlist = []
  repeat while pTextKeys <= 1
    tKey = getAt(1, count(pTextKeys))
    if textExists(tKey) then
      pTextlist.add(getText(tKey))
    end if
  end repeat
  if (pTextlist.count = 0) then
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
  if (pLineHeight mod 2) then
    pLineHeight = (pLineHeight + 1)
  end if
  pSelectedItemNum = 1
  pMenuItems = pTextlist
  pNumberOfMenuItems = pTextlist.count()
  me.UpdateImageObjects(void(), #up)
  pDropMenuImg = me.createDropImg(pMenuItems, 1, #up)
  me.pimage = pDropMenuImg
  me.pwidth = me.pimage.width
  pheight = me.pimage.height
  pDropActiveBtnImg = me.createDropImg([pMenuItems.getAt(1)], 0, #up)
  me.pimage = pDropActiveBtnImg
  tTempOffset = me.pBuffer.regPoint
  me.pBuffer.image = me.pimage
  me.pBuffer.regPoint = tTempOffset
  me.pSprite.blend = tProps.getAt(#blend)
  return TRUE
end

on prepare me 
  me.pLocX = me.pSprite.locH
  me.pLocY = me.pSprite.locV
  if (pAlignment = #center) then
    me.pLocX = (me.pLocX - ((me.pwidth - pOrigWidth) / 2))
  else
    if (pAlignment = #right) then
      me.pLocX = (me.pLocX - (me.pwidth - pOrigWidth))
    end if
  end if
  me.pSprite.loc = point(me.pLocX, me.pLocY)
end

on Activate me 
  me.pSprite.blend = 100
  return TRUE
end

on deactivate me 
  me.pSprite.blend = 50
  return TRUE
end

on getSelection me, tReturnType 
  if (tReturnType = #text) then
    return(pTextlist.getAt(pSelectedItemNum))
  else
    if (tReturnType = #key) then
      return(pTextKeys.getAt(pSelectedItemNum))
    end if
  end if
  return(pTextKeys.getAt(pSelectedItemNum))
end

on setSelection me, tSelNumOrStr 
  if stringp(tSelNumOrStr) then
    tSelNum = pMenuItems.getPos(tSelNumOrStr)
    if (tSelNum = 0) then
      tSelNum = pTextKeys.getPos(tSelNumOrStr)
    end if
  else
    tSelNum = tSelNumOrStr
  end if
  if tSelNum > 0 and tSelNum <= pNumberOfMenuItems then
    pSelectedItemNum = tSelNum
    pDropActiveBtnImg = me.createDropImg([pMenuItems.getAt(pSelectedItemNum)], 0, #up)
    me.pimage = pDropActiveBtnImg
    me.pSprite.loc = pLoc
    me.render()
    return TRUE
  else
    return FALSE
  end if
end

on getProperty me, tProp 
  if (tProp = #width) then
    return(me.pSprite.width)
  else
    if (tProp = #height) then
      return(me.pSprite.height)
    else
      if (tProp = #locX) then
        return(me.pLocX)
      else
        if (tProp = #locY) then
          return(me.pLocY)
        else
          if (tProp = #depth) then
            return(me.pimage.depth)
          else
            if (tProp = #blend) then
              return(me.pSprite.blend)
            else
              if (tProp = #selection) then
                return(pTextKeys.getAt(pSelectedItemNum))
              else
                return FALSE
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on mouseDown me 
  if me.pSprite.blend < 100 then
    return FALSE
  end if
  pClickPass = 1
  if pState <> #open then
    me.pimage = pDropMenuImg
    pLoc = me.pSprite.loc
    if (pOpenDir = #lastselected) then
      me.pSprite.loc = (pLoc - point(0, ((pSelectedItemNum - 1) * pLineHeight)))
    else
      if (pOpenDir = #up) then
        me.pSprite.loc = (pLoc - point(0, ((pTextlist.count() - 1) * pLineHeight)))
      end if
    end if
    me.render()
    pState = #open
    return TRUE
  end if
end

on mouseUp me 
  if me.pSprite.blend < 100 then
    return FALSE
  end if
  if (pClickPass = 0) then
    return FALSE
  end if
  pClickPass = 0
  pState = #close
  pLastRollOver = void()
  if pRollOverItem > 0 and pRollOverItem <= pNumberOfMenuItems then
    pSelectedItemNum = pRollOverItem
    pDropActiveBtnImg = me.createDropImg([pMenuItems.getAt(pSelectedItemNum)], 0, #up)
    me.pimage = pDropActiveBtnImg
    me.pSprite.loc = pLoc
    me.render()
    updateStage()
    if not voidp(pTextKeys.getAt(pSelectedItemNum)) then
      return(pTextKeys.getAt(pSelectedItemNum))
    end if
  end if
end

on mouseUpOutSide me 
  pClickPass = 0
  pState = #close
  pLastRollOver = void()
  me.pimage = pDropActiveBtnImg
  me.render()
  me.pSprite.loc = pLoc
  return FALSE
end

on mouseWithin me 
  if (pState = #open) then
    if voidp(pLastRollOver) then
      pLastRollOver = 0
    end if
    pRollOverItem = ((((the mouseV - me.pSprite.top) - 1) / pLineHeight) + 1)
    if pRollOverItem <> pLastRollOver then
      if pRollOverItem > pNumberOfMenuItems then
        pRollOverItem = pNumberOfMenuItems
      end if
      if (pNumberOfMenuItems = pRollOverItem) then
        tMaskFix = pMarginBottom
      else
        tMaskFix = 0
      end if
      tTempImage = pDropMenuImg.duplicate()
      tTempActiveBoxImg = image(me.pwidth, (pLineHeight + tMaskFix), 8, me.pPalette)
      tMemberDesc = pProp.getAt(#up).getAt(#members).getAt(#activeline)
      tmember = member(getmemnum(tMemberDesc.getAt(#member)))
      tTempActiveBoxImg.copyPixels(tmember.image, tTempActiveBoxImg.rect, tmember.rect)
      tActiveTop = ((pRollOverItem - 1) * pLineHeight)
      tdestrect = rect(0, tActiveTop, me.pwidth, ((tActiveTop + pLineHeight) + tMaskFix))
      tTempImage.copyPixels(tTempActiveBoxImg, tdestrect, tTempActiveBoxImg.rect, [#maskImage:pDropMenuImg.createMatte(), #maskOffset:point(0, -tActiveTop), #ink:39])
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
  repeat while [#top, #middle, #bottom] <= 1
    tV = getAt(1, count([#top, #middle, #bottom]))
    repeat while [#top, #middle, #bottom] <= 1
      tH = getAt(1, count([#top, #middle, #bottom]))
      tSymbol = symbol(tV & tH)
      tDesc = pProp.getAt(tstate).getAt(#members).getAt(tSymbol)
      tmember = member(getmemnum(tDesc.getAt(#member)))
      tImage = tmember.image.duplicate()
      if tImage.paletteRef <> tPalette then
        tImage.paletteRef = tPalette
      end if
      if tDesc.getAt(#flipH) then
        tImage = me.flipH(tImage)
      end if
      if tDesc.getAt(#flipV) then
        tImage = me.flipV(tImage)
      end if
      if not voidp(tDesc.getAt(#rotate)) then
        tImage = me.rotateImg(tImage, tDesc.getAt(#rotate))
      end if
      pDropDownImg.addProp(tV & "_" & tH, tImage)
    end repeat
  end repeat
  if not voidp(pProp.getAt(#optionalimage)) then
    tOptionalImages = pProp.getAt(#optionalimage).getAt(#members)
    i = 1
    repeat while i <= tOptionalImages.count()
      tDesc = tOptionalImages.getAt(tOptionalImages.getPropAt(i))
      tMemName = tDesc.getAt(#member)
      tmember = member(getmemnum(tMemName))
      tImage = tmember.image.duplicate()
      if tImage.paletteRef <> tPalette then
        tImage.paletteRef = tPalette
      end if
      if tDesc.getAt(#flipH) then
        tImage = me.flipH(tImage)
      end if
      if tDesc.getAt(#flipV) then
        tImage = me.flipV(tImage)
      end if
      pDropDownImg.addProp("optionalimage_" & tOptionalImages.getPropAt(i), tImage)
      i = (1 + i)
    end repeat
  end if
  pDotLineImg = image(pMaxWidth, 1, 8, tPalette)
  tXPoint = 0
  repeat while tXPoint <= (pMaxWidth / 2)
    pDotLineImg.setPixel((tXPoint * 2), 0, rgb(0, 0, 0))
    tXPoint = (1 + tXPoint)
  end repeat
  me.pPalette = tPalette
  return(tPalette)
end

on createDropImg me, tItemsList, tListOfAllItemsOrNot, tstate 
  tStr = ""
  f = 1
  repeat while f <= tItemsList.count
    tStr = tStr & tItemsList.getAt(f) & "\r"
    f = (1 + f)
  end repeat
  tMemNum = getmemnum("dropdown.button.text")
  if (tMemNum = 0) then
    tMemNum = createMember("dropdown.button.text", #text)
  end if
  tTextMember = member(tMemNum)
  tFontDesc = pProp.getAt(tstate).getAt(#text)
  pMarginTop = tFontDesc.getAt(#marginV)
  pMarginLeft = tFontDesc.getAt(#marginH)
  pMarginBottom = tFontDesc.getAt(#marginbottom)
  tTextMember.wordWrap = 0
  tTextMember.font = string(tFontDesc.getAt(#font))
  tTextMember.fontStyle = list(symbol(tFontDesc.getAt(#fontStyle)))
  tTextMember.fontSize = tFontDesc.getAt(#fontSize)
  tTextMember.color = rgb(tFontDesc.getAt(#color))
  tTextMember.text = tStr.getProp(#line, 1, (tStr.count(#line) - 1))
  tTextMember.fixedLineSpace = pLineHeight
  if (tListOfAllItemsOrNot = 1) and not voidp(pProp.getAt(#optionalimage)) then
    tOptionalImages = pProp.getAt(#optionalimage).getAt(#members)
    tOptionalImagesWidth = 0
    i = 1
    repeat while i <= tOptionalImages.count()
      tOptionalImagesWidth = (tOptionalImagesWidth + pDropDownImg.getAt("optionalimage_" & tOptionalImages.getPropAt(i)).width)
      i = (1 + i)
    end repeat
    exit repeat
  end if
  tOptionalImagesWidth = 0
  if (pFixedSize = 1) then
    tTextMember.alignment = tFontDesc.getAt(#alignment)
    pTextWidth = (pOrigWidth - (pMarginLeft * 2))
    tTextMember.rect = rect(0, 0, pTextWidth, tTextMember.height)
    tTextImg = tTextMember.image
    me.pwidth = pOrigWidth
  else
    tTextMember.alignment = #left
    if (tListOfAllItemsOrNot = 1) then
      tMaxLengt = 1
      tCharNum = 1
      tSofarChars = 0
      tLineN = 1
      repeat while tLineN <= tStr.count(#line)
        tSofarChars = (tSofarChars + tStr.getPropRef(#line, tLineN).count(#char))
        if tStr.getPropRef(#line, tLineN).count(#char) > tMaxLengt then
          tMaxLengt = tSofarChars
          tCharNum = tSofarChars
          tTempline = tLineN
        end if
        tLineN = (1 + tLineN)
      end repeat
      pTextWidth = (tTextMember.charPosToLoc(tCharNum).locH + (tFontDesc.getAt(#fontSize) * 2))
      pTextWidth = ((pTextWidth + (10 - (pTextWidth mod 10))) - tOptionalImagesWidth)
      me.pwidth = ((pTextWidth + (pMarginLeft * 2)) + tOptionalImagesWidth)
    end if
    tTextMember.rect = rect(0, 0, pTextWidth, tTextMember.height)
    tTextMember.alignment = tFontDesc.getAt(#alignment)
    tTextImg = tTextMember.image
  end if
  tWidth = me.pwidth
  tNewImg = image(tWidth, ((tItemsList.count * pLineHeight) + pMarginBottom), 8, me.pPalette)
  tdestrect = rect(0, 0, 0, 0)
  tEndPointX = 0
  tEndPointY = 0
  tLastX = 0
  tStartPoint = 0
  repeat while ["top", "middle", "bottom"] <= 1
    f = getAt(1, count(["top", "middle", "bottom"]))
    tStartPoint = tEndPointY
    tEndPointX = 0
    if (["top", "middle", "bottom"] = "top") then
      tEndPointY = (tEndPointY + pDropDownImg.getAt(1).height)
    else
      if (["top", "middle", "bottom"] = "middle") then
        tEndPointY = (((tEndPointY + (tItemsList.count * pLineHeight)) - (tEndPointY * 2)) + pMarginBottom)
      else
        if (["top", "middle", "bottom"] = "bottom") then
          tEndPointY = (tEndPointY + pDropDownImg.getAt(1).height)
        end if
      end if
    end if
    repeat while ["top", "middle", "bottom"] <= 1
      i = getAt(1, count(["top", "middle", "bottom"]))
      tLastX = tEndPointX
      if (["top", "middle", "bottom"] = "left") then
        tEndPointX = (tEndPointX + pDropDownImg.getProp(f & "_" & i).width)
      else
        if (["top", "middle", "bottom"] = "middle") then
          tEndPointX = (((tEndPointX + tWidth) - pDropDownImg.getProp(#top_left).width) - pDropDownImg.getProp(#top_right).width)
        else
          if (["top", "middle", "bottom"] = "right") then
            tEndPointX = (tEndPointX + pDropDownImg.getProp(f & "_" & i).width)
          end if
        end if
      end if
      tdestrect = rect(tLastX, tStartPoint, tEndPointX, tEndPointY)
      tNewImg.copyPixels(pDropDownImg.getProp(f & "_" & i), tdestrect, pDropDownImg.getProp(f & "_" & i).rect)
    end repeat
  end repeat
  if (tListOfAllItemsOrNot = 0) and not voidp(pProp.getAt(#optionalimage)) then
    tOptionalImages = pProp.getAt(#optionalimage).getAt(#members)
    i = 1
    repeat while i <= tOptionalImages.count()
      tPosition = tOptionalImages.getPropAt(i)
      tOptionalImg = pDropDownImg.getAt("optionalimage_" & tOptionalImages.getPropAt(i))
      tOptionImgRect = tOptionalImg.rect
      tOptionImgMargH = tOptionalImages.getAt(tOptionalImages.getPropAt(i)).getAt(#marginH)
      tOptionImgMargV = ((tNewImg.height / 2) - (tOptionImgRect.height / 2))
      if (tPosition = #right) then
        tdestrect = (tOptionImgRect + rect(((me.pwidth - tOptionImgMargH) - tOptionImgRect.width), tOptionImgMargV, ((me.pwidth - tOptionImgMargH) - tOptionImgRect.width), tOptionImgMargV))
      else
        if (tPosition = #left) then
          tdestrect = (tOptionImgRect + rect(tOptionImgMargH, tOptionImgMargV, tOptionImgMargH, tOptionImgMargV))
        end if
      end if
      tNewImg.copyPixels(tOptionalImg, tdestrect, tOptionImgRect, [#ink:36])
      i = (1 + i)
    end repeat
  end if
  if tItemsList.count() > 1 then
    f = 1
    repeat while f <= (tItemsList.count - 1)
      tdestrect = rect(0, (f * pLineHeight), (tWidth - 1), ((f * pLineHeight) + 1))
      tNewImg.copyPixels(pDotLineImg, tdestrect, rect(0, 0, (tWidth - 1), 1), [#ink:36])
      f = (1 + f)
    end repeat
  end if
  tdestrect = (tTextImg.rect + rect(0, pMarginTop, 0, pMarginTop))
  if (tFontDesc.getAt(#alignment) = #left) then
    tdestrect = (tdestrect + rect(pMarginLeft, 0, pMarginLeft, 0))
  else
    if (tFontDesc.getAt(#alignment) = #center) then
      tdestrect = ((tdestrect + rect((tNewImg.width / 2), 0, (tNewImg.width / 2), 0)) - rect((pTextWidth / 2), 0, (pTextWidth / 2), 0))
    else
      if (tFontDesc.getAt(#alignment) = #right) then
        tdestrect = ((tdestrect + rect(tNewImg.width, 0, tNewImg.width, 0)) - rect((pTextWidth + pDropDownImg.getProp("top_right").width), 0, (pTextWidth + pDropDownImg.getProp("top_right").width), 0))
      end if
    end if
  end if
  tNewImg.copyPixels(tTextImg, tdestrect, tTextImg.rect)
  return(tNewImg)
end

on setActiveItemTo me, tItem 
  if voidp(pTextKeys.findPos(tItem)) then
    return(error(me, "Cannot activate the item of dropmenu:" && tItem))
  end if
  pSelectedItemNum = pTextKeys.findPos(tItem)
  pDropActiveBtnImg = me.createDropImg([pMenuItems.getAt(pSelectedItemNum)], 0, #up)
  me.pimage = pDropActiveBtnImg
  me.render()
end

on flipH me, tImg 
  tImage = image(tImg.width, tImg.height, tImg.depth, tImg.paletteRef)
  tQuad = [point(tImg.width, 0), point(0, 0), point(0, tImg.height), point(tImg.width, tImg.height)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return(tImage)
end

on flipV me, tImg 
  tImage = image(tImg.width, tImg.height, tImg.depth, tImg.paletteRef)
  tQuad = [point(0, tImg.height), point(tImg.width, tImg.height), point(tImg.width, 0), point(0, 0)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return(tImage)
end

on rotateImg me, tImg, tDirection 
  tImage = image(tImg.height, tImg.width, tImg.depth, tImg.paletteRef)
  tQuad = [point(0, 0), point(tImg.height, 0), point(tImg.height, tImg.width), point(0, tImg.width)]
  tQuad = me.RotateQuad(tQuad, tDirection)
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return(tImage)
end

on RotateQuad me, tDestquad, tClockwise 
  tPoint1 = tDestquad.getAt(1)
  tPoint2 = tDestquad.getAt(2)
  tPoint3 = tDestquad.getAt(3)
  tPoint4 = tDestquad.getAt(4)
  if (tClockwise = 1) then
    tDestquad = [tPoint2, tPoint3, tPoint4, tPoint1]
  else
    tDestquad = [tPoint4, tPoint1, tPoint2, tPoint3]
  end if
  return(tDestquad)
end

property pIconImg

on prepare me
  tField = me.pType & me.pProps[#model] & ".element"
  me.pProp = getObject(#layout_parser).parse(tField)
  if me.pProp = 0 then
    return 0
  end if
  me.pOrigWidth = me.pProps[#width]
  me.pMaxWidth = me.pProps[#maxwidth]
  me.pFixedSize = me.pProps[#fixedsize]
  me.pAlignment = me.pProps[#alignment]
  me.pButtonText = getText(me.pProps[#key])
  me.pBlend = me.pProps[#blend]
  me.pCachedImgs = [:]
  if not voidp(me.pProps[#icon]) then
    tMemNum = getmemnum(me.pProps[#icon])
    if tMemNum > 0 then
      pIconImg = member(tMemNum).image.duplicate()
    end if
  end if
  if not integerp(me.pMaxWidth) then
    me.pMaxWidth = 300
  end if
  if voidp(me.pFixedSize) then
    me.pFixedSize = 0
  end if
  me.UpdateImageObjects(VOID, #up)
  me.pimage = me.createButtonImg(me.pButtonText, #up)
  tTempOffset = me.pSprite.member.regPoint
  me.pBuffer.image = me.pimage
  me.pBuffer.regPoint = tTempOffset
  me.pwidth = me.pimage.width
  me.pheight = me.pimage.height
  me.pLocX = me.pSprite.locH
  me.pLocY = me.pSprite.locV
  me.pSprite.width = me.pwidth
  me.pSprite.height = me.pheight
  return 1
end

on createButtonImg me, tText, tstate
  if not voidp(me.pCachedImgs[tstate]) then
    return me.pCachedImgs[tstate]
  end if
  tMemNum = getmemnum("icon.button.text")
  if tMemNum = 0 then
    tMemNum = createMember("icon.button.text", #text)
  end if
  tTextMem = member(tMemNum)
  tFontDesc = me.pProp[tstate][#text]
  tFont = tFontDesc[#font]
  tFontStyle = list(symbol(tFontDesc[#fontStyle]))
  tFontSize = tFontDesc[#fontSize]
  tColor = rgb(tFontDesc[#color])
  tBgColor = rgb(tFontDesc[#bgColor])
  tBoxType = tFontDesc[#boxType]
  tSpace = tFontDesc[#fontSize] + 2
  tMarginH = tFontDesc[#marginH]
  tMarginV = tFontDesc[#marginV]
  if tTextMem.wordWrap = 1 then
    tTextMem.wordWrap = 0
  end if
  if tTextMem.font <> tFont then
    tTextMem.font = tFont
  end if
  if tTextMem.fontStyle <> tFontStyle then
    tTextMem.fontStyle = tFontStyle
  end if
  if tTextMem.fontSize <> tFontSize then
    tTextMem.fontSize = tFontSize
  end if
  if tTextMem.color <> tColor then
    tTextMem.color = tColor
  end if
  if tTextMem.bgColor <> tBgColor then
    tTextMem.bgColor = tBgColor
  end if
  if tTextMem.boxType <> tBoxType then
    tTextMem.boxType = tBoxType
  end if
  if tTextMem.fixedLineSpace <> tSpace then
    tTextMem.fixedLineSpace = tSpace
  end if
  if tTextMem.text <> tText then
    tTextMem.text = tText
  end if
  tOptImgWidth = 0
  if not voidp(me.pProp[#icon]) and not voidp(pIconImg) then
    tAlignment = me.pProp[#icon][#props].getPropAt(1)
    tOptImgMargH = me.pProp[#icon][#props][tAlignment][#marginH]
    tOptImgWidth = pIconImg.width + tOptImgMargH
  end if
  if me.pFixedSize = 1 then
    tCharPosH = tTextMem.locToCharPos(point(me.pOrigWidth - (tMarginH * 2), 5))
    tTextWidth = me.getTextWidth(tTextMem)
    tTextMem.rect = rect(0, 0, tTextWidth, tTextMem.height)
    tTextImg = tTextMem.image
    tWidth = me.pOrigWidth
  else
    tTextWidth = me.getTextWidth(tTextMem)
    if (tTextWidth + (tMarginH * 2)) > me.pMaxWidth then
      tTextWidth = me.pMaxWidth - (tMarginH * 2) + tOptImgWidth
    end if
    tTextMem.rect = rect(0, 0, tTextWidth, tTextMem.height)
    tTextImg = tTextMem.image
    tWidth = tTextWidth + (tMarginH * 2) + tOptImgWidth
  end if
  tNewImg = image(tWidth, me.pButtonImg[#left].height, 8, member(me.pPalette))
  tStartPointY = 0
  tEndPointY = tNewImg.height
  tStartPointX = 0
  tEndPointX = 0
  repeat with i in [#left, #middle, #right]
    tStartPointX = tEndPointX
    case i of
      #left:
        tEndPointX = tEndPointX + me.pButtonImg.getProp(i).width
      #middle:
        tEndPointX = tEndPointX + tWidth - me.pButtonImg.getProp(#left).width - me.pButtonImg.getProp(#right).width
      #right:
        tEndPointX = tEndPointX + me.pButtonImg.getProp(i).width
    end case
    tDstRect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
    tNewImg.copyPixels(me.pButtonImg.getProp(i), tDstRect, me.pButtonImg.getProp(i).rect)
  end repeat
  if not voidp(me.pProp[#icon]) and not voidp(pIconImg) then
    tAlignment = me.pProp[#icon][#props].getPropAt(1)
    tOptImgRect = pIconImg.rect
    tOptImgMargH = me.pProp[#icon][#props][tAlignment][#marginH]
    tOptImgMargV = (tNewImg.height / 2) - (tOptImgRect.height / 2)
    case tAlignment of
      #right:
        tDstRect = tOptImgRect + rect(me.pwidth - tOptImgMargH - tOptImgRect.width, tOptImgMargV, me.pwidth - tOptImgMargH - tOptImgRect.width, tOptImgMargV)
      #left:
        tDstRect = tOptImgRect + rect(tOptImgMargH, tOptImgMargV, tOptImgMargH, tOptImgMargV)
      #center:
        tDstRect = tOptImgRect + rect(tNewImg.width / 2, 0, tNewImg.width / 2, 0) - rect(pIconImg / 2, 0, pIconImg / 2, 0)
    end case
    tInk = me.pProp[#icon][#props][tAlignment][#ink]
    if voidp(tInk) then
      tInk = 36
    end if
    tNewImg.copyPixels(pIconImg, tDstRect, tOptImgRect, [#ink: tInk])
  end if
  tDstRect = tTextImg.rect + rect(1, tMarginV, 1, tMarginV)
  case tFontDesc[#alignment] of
    #left:
      tDstRect = tDstRect + rect(me.pButtonImg.getProp(#left).width, 0, me.pButtonImg.getProp(#left).width, 0)
    #center:
      tDstRect = tDstRect + rect(tNewImg.width / 2, 0, tNewImg.width / 2, 0) - rect(tTextWidth / 2, 0, tTextWidth / 2, 0)
    #right:
      tDstRect = tDstRect + rect(tNewImg.width, 0, tNewImg.width, 0) - rect(tTextWidth + me.pButtonImg.getProp(#right).width, 0, tTextWidth + me.pButtonImg.getProp(#right).width, 0)
  end case
  tNewImg.copyPixels(tTextImg, tDstRect, tTextImg.rect)
  me.pCachedImgs[tstate] = tNewImg
  return tNewImg
end

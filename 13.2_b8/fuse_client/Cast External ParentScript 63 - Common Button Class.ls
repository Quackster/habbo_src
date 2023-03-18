property pmodel, pOrigWidth, pMaxWidth, pFixedSize, pAlignment, pButtonImg, pButtonText, pCachedImgs, pClickPass, pBlend, pProp

on prepare me
  tField = me.pProps[#type] & me.pProps[#model] & ".element"
  pProp = getObject(#layout_parser).parse(tField)
  if pProp = 0 then
    return 0
  end if
  pmodel = me.pProps[#model]
  pOrigWidth = me.pProps[#width]
  pMaxWidth = me.pProps[#maxwidth]
  pFixedSize = me.pProps[#fixedsize]
  pAlignment = me.pProps[#alignment]
  pButtonText = getText(me.pProps[#key])
  pBlend = me.pProps[#blend]
  pCachedImgs = [:]
  if not integerp(pMaxWidth) then
    pMaxWidth = 300
  end if
  if voidp(pFixedSize) then
    pFixedSize = 0
  end if
  me.UpdateImageObjects(VOID, #up)
  return me.setButtonImage()
end

on setButtonImage me
  me.pimage = me.createButtonImg(pButtonText, #up)
  tTempOffset = me.pSprite.member.regPoint
  me.pBuffer.image = me.pimage
  me.pBuffer.regPoint = tTempOffset
  me.pwidth = me.pimage.width
  me.pheight = me.pimage.height
  me.pLocX = me.pSprite.locH
  me.pLocY = me.pSprite.locV
  case pAlignment of
    #center:
      me.pLocX = me.pLocX - ((me.pwidth - pOrigWidth) / 2)
    #right:
      me.pLocX = me.pLocX - (me.pwidth - pOrigWidth)
  end case
  me.pSprite.loc = point(me.pLocX, me.pLocY)
  me.pSprite.width = me.pwidth
  me.pSprite.height = me.pheight
  return 1
end

on Activate me
  me.pSprite.blend = 100
  pBlend = 100
  return 1
end

on deactivate me
  me.changeState(#up)
  me.pSprite.blend = 50
  pBlend = 50
  return 1
end

on setText me, tText
  pButtonText = tText
  pCachedImgs = [:]
  return me.setButtonImage()
end

on mouseDown me
  if (pBlend < 100) or (me.pSprite.blend < 100) then
    return 0
  end if
  pClickPass = 1
  me.changeState(#down)
  return 1
end

on mouseUp me
  if (pBlend < 100) or (me.pSprite.blend < 100) then
    return 0
  end if
  if pClickPass = 0 then
    return 0
  end if
  pClickPass = 0
  me.changeState(#up)
  return 1
end

on mouseUpOutSide me
  if (pBlend < 100) or (me.pSprite.blend < 100) then
    return 0
  end if
  pClickPass = 0
  me.changeState(#up)
  return 0
end

on render me
  me.pBuffer.image.fill(me.pBuffer.image.rect, rgb(255, 255, 255))
  me.pBuffer.image.copyPixels(me.pimage, me.pBuffer.image.rect, me.pimage.rect, me.pParams)
end

on changeState me, tstate
  me.UpdateImageObjects(VOID, tstate)
  me.pimage = me.createButtonImg(pButtonText, tstate)
  me.render()
end

on UpdateImageObjects me, tPalette, tstate
  pButtonImg = [:]
  if voidp(tPalette) then
    tPalette = me.pPalette
  else
    if stringp(tPalette) then
      tPalette = member(getmemnum(tPalette))
    end if
  end if
  repeat with f in [#left, #middle, #right]
    tDesc = pProp[tstate][#members][f]
    tmember = member(getmemnum(tDesc[#member]))
    if not voidp(tDesc[#palette]) then
      me.pPalette = member(getmemnum(tDesc[#palette]))
    else
      me.pPalette = tPalette
    end if
    tImage = tmember.image.duplicate()
    if tDesc[#flipH] then
      tImage = me.flipH(tImage)
    end if
    if tDesc[#flipV] then
      tImage = me.flipV(tImage)
    end if
    pButtonImg.addProp(symbol(f), tImage)
  end repeat
end

on createButtonImg me, tText, tstate
  if not voidp(pCachedImgs[tstate]) then
    return pCachedImgs[tstate]
  end if
  tMemNum = getmemnum("common.button.text")
  if tMemNum = 0 then
    tMemNum = createMember("common.button.text", #text)
  end if
  tTextMem = member(tMemNum)
  tFontDesc = pProp[tstate][#text]
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
  if pFixedSize = 1 then
    tTextWidth = me.getTextWidth(tTextMem)
    if (tTextWidth + (tMarginH * 2)) > pOrigWidth then
      tTextWidth = pOrigWidth - (tMarginH * 2)
    end if
    tTextMem.rect = rect(0, 0, tTextWidth, tTextMem.height)
    tTextImg = tTextMem.image
    tWidth = pOrigWidth
  else
    tTextWidth = me.getTextWidth(tTextMem)
    if (tTextWidth + (tMarginH * 2)) > pMaxWidth then
      tTextWidth = pMaxWidth - (tMarginH * 2)
    end if
    tTextMem.rect = rect(0, 0, tTextWidth, tTextMem.height)
    tTextImg = tTextMem.image
    tWidth = tTextWidth + (tMarginH * 2)
  end if
  tNewImg = image(tWidth, pButtonImg[#left].height, me.pDepth, me.pPalette)
  tStartPointY = 0
  tEndPointY = tNewImg.height
  tStartPointX = 0
  tEndPointX = 0
  repeat with i in [#left, #middle, #right]
    tStartPointX = tEndPointX
    case i of
      #left:
        tEndPointX = tEndPointX + pButtonImg.getProp(i).width
      #middle:
        tEndPointX = tEndPointX + tWidth - pButtonImg.getProp(#left).width - pButtonImg.getProp(#right).width
      #right:
        tEndPointX = tEndPointX + pButtonImg.getProp(i).width
    end case
    tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
    tNewImg.copyPixels(pButtonImg.getProp(i), tdestrect, pButtonImg.getProp(i).rect)
  end repeat
  tDstRect = tTextImg.rect + rect(0, tMarginV, 0, tMarginV)
  case tFontDesc[#alignment] of
    #left:
      tDstRect = tDstRect + rect(pButtonImg.getProp(#left).width, 0, pButtonImg.getProp(#left).width, 0)
    #center:
      tDstRect = tDstRect + rect(tNewImg.width / 2, 0, tNewImg.width / 2, 0) - rect(tTextWidth / 2, 0, tTextWidth / 2, 0)
    #right:
      tDstRect = tDstRect + rect(tNewImg.width, 0, tNewImg.width, 0) - rect(tTextWidth + pButtonImg.getProp(#right).width, 0, tTextWidth + pButtonImg.getProp(#right).width, 0)
  end case
  tNewImg.copyPixels(tTextImg, tDstRect, tTextImg.rect, [#ink: 36])
  pCachedImgs[tstate] = tNewImg
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

on getTextWidth me, tTextMem
  tOrigWidth = pMaxWidth
  tOrigHeight = 30
  tStoreRect = tTextMem.rect
  tTextMem.rect = rect(0, 0, tOrigWidth, tOrigHeight)
  tImage = image(tOrigWidth, tOrigHeight, 32)
  tImage.copyPixels(tTextMem.image, rect(0, 0, tOrigWidth, tOrigHeight), rect(0, 0, tOrigWidth, tOrigHeight))
  tTextWidth = tImage.trimWhiteSpace().width
  tTextMem.rect = tStoreRect
  return tTextWidth
end

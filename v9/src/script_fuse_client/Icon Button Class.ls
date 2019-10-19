property pIconImg

on prepare me 
  tField = me.pType & me.getProp(#pProps, #model) & ".element"
  me.pProp = getObject(#layout_parser).parse(tField)
  if me.pProp = 0 then
    return(0)
  end if
  me.pOrigWidth = me.getProp(#pProps, #width)
  me.pMaxWidth = me.getProp(#pProps, #maxwidth)
  me.pFixedSize = me.getProp(#pProps, #fixedsize)
  me.pAlignment = me.getProp(#pProps, #alignment)
  me.pButtonText = getText(me.getProp(#pProps, #key))
  me.pBlend = me.getProp(#pProps, #blend)
  me.pCachedImgs = [:]
  if not voidp(me.getProp(#pProps, #icon)) then
    tMemNum = getmemnum(me.getProp(#pProps, #icon))
    if tMemNum > 0 then
      pIconImg = undefined.duplicate()
    end if
  end if
  if not integerp(me.pMaxWidth) then
    me.pMaxWidth = 300
  end if
  if voidp(me.pFixedSize) then
    me.pFixedSize = 0
  end if
  me.UpdateImageObjects(void(), #up)
  me.pimage = me.createButtonImg(me.pButtonText, #up)
  tTempOffset = member.regPoint
  me.image = me.pimage
  me.regPoint = tTempOffset
  me.pwidth = me.width
  me.pheight = me.height
  me.pLocX = pSprite.locH
  me.pLocY = pSprite.locV
  pSprite.width = me.pwidth
  pSprite.height = me.pheight
  return(1)
end

on createButtonImg me, tText, tstate 
  if not voidp(me.getProp(#pCachedImgs, tstate)) then
    return(me.getProp(#pCachedImgs, tstate))
  end if
  tMemNum = getmemnum("icon.button.text")
  if tMemNum = 0 then
    tMemNum = createMember("icon.button.text", #text)
  end if
  tTextMem = member(tMemNum)
  tFontDesc = me.getPropRef(#pProp, tstate).getAt(#text)
  tFont = tFontDesc.getAt(#font)
  tFontStyle = list(symbol(tFontDesc.getAt(#fontStyle)))
  tFontSize = tFontDesc.getAt(#fontSize)
  tColor = rgb(tFontDesc.getAt(#color))
  tBgColor = rgb(tFontDesc.getAt(#bgColor))
  tBoxType = tFontDesc.getAt(#boxType)
  tSpace = tFontDesc.getAt(#fontSize) + 2
  tMarginH = tFontDesc.getAt(#marginH)
  tMarginV = tFontDesc.getAt(#marginV)
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
  if not voidp(me.getProp(#pProp, #icon)) and not voidp(pIconImg) then
    tAlignment = me.getPropRef(#pProp, #icon).getAt(#props).getPropAt(1)
    tOptImgMargH = me.getPropRef(#pProp, #icon).getAt(#props).getAt(tAlignment).getAt(#marginH)
    tOptImgWidth = pIconImg.width + tOptImgMargH
  end if
  if me.pFixedSize = 1 then
    tCharPosH = tTextMem.locToCharPos(point(me.pOrigWidth - (tMarginH * 2), 5))
    tTextWidth = tTextMem.charPosToLoc(tCharPosH).locH
    tTextMem.rect = rect(0, 0, tTextWidth, tTextMem.height)
    tTextImg = tTextMem.image
    tWidth = me.pOrigWidth
  else
    tTextWidth = tTextMem.charPosToLoc(tTextMem.count(#char)).locH + (tFontDesc.getAt(#fontSize) * 2)
    if tTextWidth + (tMarginH * 2) > me.pMaxWidth then
      tTextWidth = me.pMaxWidth - (tMarginH * 2) + tOptImgWidth
    end if
    tTextMem.rect = rect(0, 0, tTextWidth, tTextMem.height)
    tTextImg = tTextMem.image
    tWidth = tTextWidth + (tMarginH * 2) + tOptImgWidth
  end if
  tNewImg = image(tWidth, me.getPropRef(#pButtonImg, #left).height, 8, member(me.pPalette))
  tStartPointY = 0
  tEndPointY = tNewImg.height
  tStartPointX = 0
  tEndPointX = 0
  repeat while [#left, #middle, #right] <= tstate
    i = getAt(tstate, tText)
    tStartPointX = tEndPointX
    if [#left, #middle, #right] = #left then
      tEndPointX = tEndPointX + me.getProp(i).width
    else
      if [#left, #middle, #right] = #middle then
        tEndPointX = tEndPointX + tWidth - me.getProp(#left).width - me.getProp(#right).width
      else
        if [#left, #middle, #right] = #right then
          tEndPointX = tEndPointX + me.getProp(i).width
        end if
      end if
    end if
    tDstRect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
    tNewImg.copyPixels(me.getProp(i), tDstRect, me.getProp(i).rect)
  end repeat
  if not voidp(me.getProp(#pProp, #icon)) and not voidp(pIconImg) then
    tAlignment = me.getPropRef(#pProp, #icon).getAt(#props).getPropAt(1)
    tOptImgRect = pIconImg.rect
    tOptImgMargH = me.getPropRef(#pProp, #icon).getAt(#props).getAt(tAlignment).getAt(#marginH)
    tOptImgMargV = (tNewImg.height / 2) - (tOptImgRect.height / 2)
    if [#left, #middle, #right] = #right then
      tDstRect = tOptImgRect + rect(me.pwidth - tOptImgMargH - tOptImgRect.width, tOptImgMargV, me.pwidth - tOptImgMargH - tOptImgRect.width, tOptImgMargV)
    else
      if [#left, #middle, #right] = #left then
        tDstRect = tOptImgRect + rect(tOptImgMargH, tOptImgMargV, tOptImgMargH, tOptImgMargV)
      else
        if [#left, #middle, #right] = #center then
          tDstRect = tOptImgRect + rect((tNewImg.width / 2), 0, (tNewImg.width / 2), 0) - rect((pIconImg / 2), 0, (pIconImg / 2), 0)
        end if
      end if
    end if
    tInk = me.getPropRef(#pProp, #icon).getAt(#props).getAt(tAlignment).getAt(#ink)
    if voidp(tInk) then
      tInk = 36
    end if
    tNewImg.copyPixels(pIconImg, tDstRect, tOptImgRect, [#ink:tInk])
  end if
  tDstRect = tTextImg.rect + rect(1, tMarginV, 1, tMarginV)
  if [#left, #middle, #right] = #left then
    tDstRect = tDstRect + rect(me.getProp(#left).width, 0, me.getProp(#left).width, 0)
  else
    if [#left, #middle, #right] = #center then
      tDstRect = tDstRect + rect((tNewImg.width / 2), 0, (tNewImg.width / 2), 0) - rect((tTextWidth / 2), 0, (tTextWidth / 2), 0)
    else
      if [#left, #middle, #right] = #right then
        tDstRect = tDstRect + rect(tNewImg.width, 0, tNewImg.width, 0) - rect(tTextWidth + me.getProp(#right).width, 0, tTextWidth + me.getProp(#right).width, 0)
      end if
    end if
  end if
  tNewImg.copyPixels(tTextImg, tDstRect, tTextImg.rect)
  me.setProp(#pCachedImgs, tstate, tNewImg)
  return(tNewImg)
end

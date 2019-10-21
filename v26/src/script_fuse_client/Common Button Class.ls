on prepare(me)
  tField = me.getProp(#pProps, #type) & me.getProp(#pProps, #model) & ".element"
  pProp = getObject(#layout_parser).parse(tField)
  if pProp = 0 then
    return(0)
  end if
  pmodel = me.getProp(#pProps, #model)
  pOrigWidth = me.getProp(#pProps, #width)
  pMaxWidth = me.getProp(#pProps, #maxwidth)
  pFixedSize = me.getProp(#pProps, #fixedsize)
  pAlignment = me.getProp(#pProps, #alignment)
  pButtonText = getText(me.getProp(#pProps, #key))
  pBlend = me.getProp(#pProps, #blend)
  pCachedImgs = []
  if not integerp(pMaxWidth) then
    pMaxWidth = 300
  end if
  if voidp(pFixedSize) then
    pFixedSize = 0
  end if
  me.UpdateImageObjects(void(), #up)
  return(me.setButtonImage())
  exit
end

on setButtonImage(me)
  tOrigWidth = me.pwidth
  me.pimage = me.createButtonImg(pButtonText, #up)
  tTempOffset = member.regPoint
  me.image = me.pimage
  me.regPoint = tTempOffset
  me.pwidth = me.width
  me.pheight = me.height
  me.pLocX = pSprite.locH
  me.pLocY = pSprite.locV
  if me = #center then
    me.pLocX = me.pLocX - me.pwidth - tOrigWidth / 2
  else
    if me = #right then
      me.pLocX = me.pLocX - me.pwidth - tOrigWidth
    end if
  end if
  pSprite.loc = point(me.pLocX, me.pLocY)
  pSprite.width = me.pwidth
  pSprite.height = me.pheight
  return(1)
  exit
end

on Activate(me)
  pSprite.blend = 100
  pBlend = 100
  return(1)
  exit
end

on deactivate(me)
  me.changeState(#up)
  pSprite.blend = 50
  pBlend = 50
  return(1)
  exit
end

on setText(me, tText)
  pButtonText = tText
  pCachedImgs = []
  return(me.setButtonImage())
  exit
end

on mouseDown(me)
  if me or pSprite.blend < 100 then
    return(0)
  end if
  pClickPass = 1
  me.changeState(#down)
  return(1)
  exit
end

on mouseUp(me)
  if me or pSprite.blend < 100 then
    return(0)
  end if
  if pClickPass = 0 then
    return(0)
  end if
  pClickPass = 0
  me.changeState(#up)
  return(1)
  exit
end

on mouseUpOutSide(me)
  if me or pSprite.blend < 100 then
    return(0)
  end if
  pClickPass = 0
  me.changeState(#up)
  return(0)
  exit
end

on render(me)
  undefined.fill(undefined.rect, rgb(255, 255, 255))
  undefined.copyPixels(me.pimage, undefined.rect, me.rect, me.pParams)
  exit
end

on changeState(me, tstate)
  me.UpdateImageObjects(void(), tstate)
  me.pimage = me.createButtonImg(pButtonText, tstate)
  me.render()
  exit
end

on UpdateImageObjects(me, tPalette, tstate)
  pButtonImg = []
  if voidp(tPalette) then
    tPalette = me.pPalette
  else
    if stringp(tPalette) then
      tPalette = member(getmemnum(tPalette))
    end if
  end if
  repeat while me <= tstate
    f = getAt(tstate, tPalette)
    tDesc = pProp.getAt(tstate).getAt(#members).getAt(f)
    tmember = member(getmemnum(tDesc.getAt(#member)))
    if not voidp(tDesc.getAt(#palette)) then
      me.pPalette = member(getmemnum(tDesc.getAt(#palette)))
    else
      me.pPalette = tPalette
    end if
    tImage = tmember.duplicate()
    if tDesc.getAt(#flipH) then
      tImage = me.flipH(tImage)
    end if
    if tDesc.getAt(#flipV) then
      tImage = me.flipV(tImage)
    end if
    pButtonImg.addProp(symbol(f), tImage)
  end repeat
  exit
end

on createButtonImg(me, tText, tstate)
  if not voidp(pCachedImgs.getAt(tstate)) then
    return(pCachedImgs.getAt(tstate))
  end if
  tMemNum = getmemnum("common.button.text")
  if tMemNum = 0 then
    tMemNum = createMember("common.button.text", #text)
  end if
  tTextMem = member(tMemNum)
  tFontDesc = pProp.getAt(tstate).getAt(#text)
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
  if pFixedSize = 1 then
    tTextWidth = me.getTextWidth(tTextMem)
    if tTextWidth + tMarginH * 2 > pOrigWidth then
      tTextWidth = pOrigWidth - tMarginH * 2
    end if
    tTextMem.rect = rect(0, 0, tTextWidth, tTextMem.height)
    tTextImg = tTextMem.image
    tWidth = pOrigWidth
  else
    tTextWidth = me.getTextWidth(tTextMem)
    if tTextWidth + tMarginH * 2 > pMaxWidth then
      tTextWidth = pMaxWidth - tMarginH * 2
    end if
    tTextMem.rect = rect(0, 0, tTextWidth, tTextMem.height)
    tTextImg = tTextMem.image
    tWidth = tTextWidth + tMarginH * 2
  end if
  tNewImg = image(tWidth, pButtonImg.getAt(#left).height, me.pDepth, me.pPalette)
  tStartPointY = 0
  tEndPointY = tNewImg.height
  tStartPointX = 0
  tEndPointX = 0
  repeat while me <= tstate
    i = getAt(tstate, tText)
    tStartPointX = tEndPointX
    if me = #left then
      tEndPointX = tEndPointX + pButtonImg.getProp(i).width
    else
      if me = #middle then
        tEndPointX = tEndPointX + tWidth - pButtonImg.getProp(#left).width - pButtonImg.getProp(#right).width
      else
        if me = #right then
          tEndPointX = tEndPointX + pButtonImg.getProp(i).width
        end if
      end if
    end if
    tdestrect = rect(tStartPointX, tStartPointY, tEndPointX, tEndPointY)
    tNewImg.copyPixels(pButtonImg.getProp(i), tdestrect, pButtonImg.getProp(i).rect)
  end repeat
  tDstRect = tTextImg.rect + rect(0, tMarginV, 0, tMarginV)
  if me = #left then
    tDstRect = tDstRect + rect(pButtonImg.getProp(#left).width, 0, pButtonImg.getProp(#left).width, 0)
  else
    if me = #center then
      tDstRect = tDstRect + rect(tNewImg.width / 2, 0, tNewImg.width / 2, 0) - rect(tTextWidth / 2, 0, tTextWidth / 2, 0)
    else
      if me = #right then
        tDstRect = tDstRect + rect(tNewImg.width, 0, tNewImg.width, 0) - rect(tTextWidth + pButtonImg.getProp(#right).width, 0, tTextWidth + pButtonImg.getProp(#right).width, 0)
      end if
    end if
  end if
  tNewImg.copyPixels(tTextImg, tDstRect, tTextImg.rect, [#ink:36])
  pCachedImgs.setAt(tstate, tNewImg)
  return(tNewImg)
  exit
end

on flipH(me, tImg)
  tImage = image(tImg.width, tImg.height, tImg.depth, tImg.paletteRef)
  tQuad = [point(tImg.width, 0), point(0, 0), point(0, tImg.height), point(tImg.width, tImg.height)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return(tImage)
  exit
end

on flipV(me, tImg)
  tImage = image(tImg.width, tImg.height, tImg.depth, tImg.paletteRef)
  tQuad = [point(0, tImg.height), point(tImg.width, tImg.height), point(tImg.width, 0), point(0, 0)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return(tImage)
  exit
end

on getTextWidth(me, tTextMem)
  tOrigWidth = pMaxWidth
  tOrigHeight = 30
  tStoreRect = tTextMem.rect
  tTextMem.rect = rect(0, 0, tOrigWidth, tOrigHeight)
  tImage = image(tOrigWidth, tOrigHeight, 32)
  tImage.copyPixels(tTextMem.image, rect(0, 0, tOrigWidth, tOrigHeight), rect(0, 0, tOrigWidth, tOrigHeight))
  tTextWidth = tImage.trimWhiteSpace().width
  tTextMem.rect = tStoreRect
  return(tTextWidth)
  exit
end
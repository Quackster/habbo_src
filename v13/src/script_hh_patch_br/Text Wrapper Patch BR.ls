on createImgFromTxt me 
  pTextMem.rect = rect(0, 0, me.pOwnW, me.pOwnH)
  if not listp(me.getProp(#pFontData, #fontStyle)) then
    tList = []
    tDelim = the itemDelimiter
    the itemDelimiter = ","
    i = 1
    repeat while i <= me.getPropRef(#pFontData, #fontStyle).count(#item)
      tList.add(symbol(me.getPropRef(#pFontData, #fontStyle).getProp(#item, i)))
      i = 1 + i
    end repeat
    the itemDelimiter = tDelim
    me.setProp(#pFontData, #fontStyle, tList)
  end if
  if not voidp(me.getProp(#pFontData, #text)) then
    pTextMem.text = me.getProp(#pFontData, #text)
    me.setProp(#pFontData, #text, void())
  else
    if me.getProp(#pFontData, #key) = "" then
      pTextMem.text = ""
    else
      if me.getPropRef(#pFontData, #key).getProp(#char, 1) = "%" then
        tKey = symbol(me.getPropRef(#pFontData, #key).getProp(#char, 2, length(me.getProp(#pFontData, #key))))
        pTextMem.text = string(getObject(me.pMotherId).getProperty(tKey))
      else
        if textExists(me.getProp(#pFontData, #key)) then
          pTextMem.text = getTextManager().get(me.getProp(#pFontData, #key))
        else
          error(me, "Text not found:" && me.getProp(#pFontData, #key), #createImgFromTxt)
          pTextMem.text = me.getProp(#pFontData, #key)
        end if
      end if
    end if
  end if
  #pFontData.setProp(#text, me, pTextMem.text)
  if pTextMem.fontStyle <> me.getProp(#pFontData, #fontStyle) then
    pTextMem.fontStyle = me.getProp(#pFontData, #fontStyle)
  end if
  if pTextMem.wordWrap <> me.getProp(#pFontData, #wordWrap) then
    pTextMem.wordWrap = me.getProp(#pFontData, #wordWrap)
  end if
  if pTextMem.alignment <> me.getProp(#pFontData, #alignment) then
    pTextMem.alignment = me.getProp(#pFontData, #alignment)
  end if
  if pTextMem.bgColor <> me.getProp(#pFontData, #bgColor) then
    pTextMem.bgColor = me.getProp(#pFontData, #bgColor)
  end if
  if pTextMem.font <> me.getProp(#pFontData, #font) then
    pTextMem.font = me.getProp(#pFontData, #font)
  end if
  if pTextMem.fontSize <> me.getProp(#pFontData, #fontSize) then
    pTextMem.fontSize = me.getProp(#pFontData, #fontSize)
  end if
  if pTextMem.color <> me.getProp(#pFontData, #color) then
    pTextMem.color = me.getProp(#pFontData, #color)
  end if
  if pTextMem.fixedLineSpace <> me.getProp(#pFontData, #fixedLineSpace) then
    pTextMem.fixedLineSpace = me.getProp(#pFontData, #fixedLineSpace)
  end if
  if pTextMem.topSpacing < 10 then
    pTextMem.topSpacing = 1
  end if
  if me.pScaleH = #center then
    tWidth = me.charPosToLoc(pTextMem.count(#char)).locH + 16
    if me.getProp(#pProps, #style) = #unique then
      me.pLocX = me.pLocX + me.pwidth - tWidth / 2
      me.pwidth = tWidth
      me.pOwnW = tWidth
    else
      me.pOwnX = me.pOwnX + me.pOwnW - tWidth / 2
      me.pOwnW = tWidth
    end if
    0.rect = rect(0, tWidth, me, pTextMem.height)
  else
    if me.getProp(#pProps, #style) = #unique then
      pTextMem.pwidth = image.width
      me.pOwnW = me.pwidth
    else
      pTextMem.pOwnW = image.width
    end if
  end if
  if me.count(#pScrolls) > 0 then
    tHeight = rect.height
  else
    tHeight = me.pOwnH
  end if
  me.pimage = image(me.pOwnW, tHeight, me.pDepth, me.pPalette)
  if me.pimage = void() then
    return(0)
  end if
  if me.pTextMem = void() then
    return(0)
  end if
  if me.pNeedFill then
    me.fill(pimage.rect, me.getProp(#pFontData, #bgColor))
  end if
  me.copyPixels(pimage.rect, me, pimage.rect, [#ink:8])
  return(1)
end
